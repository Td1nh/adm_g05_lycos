--Author: NhiQB
--DATA WAREHOUSE - LYCOS-IDS2017
--Desciption : tạo các bảng DimTime, DimProtocol, DimService, DimAttackLabel, FactNetworkFlow, FlowFeature, CubeFlow

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- 0. Xóa các bảng DW theo thứ tự ref foreign key
CREATE OR ALTER PROCEDURE dbo.usp_DW_DropAll
AS
BEGIN
    SET NOCOUNT ON

    DROP TABLE IF EXISTS dbo.CubeFlow
    DROP TABLE IF EXISTS dbo.FlowFeature
    DROP TABLE IF EXISTS dbo.FactNetworkFlow
    DROP TABLE IF EXISTS dbo.DimTime
    DROP TABLE IF EXISTS dbo.DimProtocol
    DROP TABLE IF EXISTS dbo.DimService
    DROP TABLE IF EXISTS dbo.DimAttackLabel
END
GO

-- 1. DimTime: Ngay -> Khung gio -> Gio (UTC-3)
CREATE OR ALTER PROCEDURE dbo.usp_DW_BuildTable
    @_UtcOffsetHours INT = -3,
    @_TestRatio      DECIMAL(4,3) = 0.200,
    @_Seed           INT          = 42
AS
BEGIN
    SET NOCOUNT ON

    -- xóa bảng cũ theo đúng thứ tự khóa ngoại để chạy lại được nhiều lần
    EXEC dbo.usp_DW_DropAll

    DROP TABLE IF EXISTS dbo.DimTime
    CREATE TABLE dbo.DimTime (
        time_key     INT          NOT NULL CONSTRAINT PK_DimTime PRIMARY KEY,  -- YYYYMMDDHH
        full_date    DATE         NOT NULL,
        day_name     VARCHAR(10)  NOT NULL,                                    -- source_day
        day_of_week  TINYINT      NOT NULL,                                    -- Monday = 2, Tuesday = 3,...
        day_scenario VARCHAR(100) NOT NULL,                                    -- kịch bản tấn công theo ngày
        time_slot    VARCHAR(20)  NOT NULL,
        [hour]       TINYINT      NOT NULL,
        is_observed  BIT          NOT NULL
    )

    -- khung giờ có ít nhất một dòng trong data_raw 
    DROP TABLE IF EXISTS #obs
    SELECT DISTINCT
           CAST(lt.local_dt AS DATE)   AS obs_date,
           DATEPART(HOUR, lt.local_dt) AS obs_hour
    INTO #obs
    FROM dbo.data_raw dr
    CROSS APPLY (SELECT DATEADD(HOUR, @_UtcOffsetHours,
                        DATEADD(SECOND, CAST(dr.[timestamp] / 1000000 AS INT), '19700101')) AS local_dt) lt

   ;WITH hrs AS (
                SELECT gs.value AS h
                FROM GENERATE_SERIES(0, 23) gs),
         dys AS (
                SELECT DISTINCT obs_date AS d FROM #obs)
    INSERT INTO dbo.DimTime (time_key, full_date, day_name, day_of_week,
                             day_scenario, time_slot, [hour], is_observed)
    SELECT YEAR(dys.d) * 1000000 + MONTH(dys.d) * 10000 + DAY(dys.d) * 100 + hrs.h,
           dys.d,
           DATENAME(WEEKDAY, dys.d),
           DATEPART(WEEKDAY, dys.d),
           CASE DATEPART(WEEKDAY, dys.d)
           WHEN 2 THEN 'Benign'
           WHEN 3 THEN 'Brute Force FTP/SSH'
           WHEN 4 THEN 'DoS and Heartbleed'
           WHEN 5 THEN 'Web Attack'
           WHEN 6 THEN 'Bot, PortScan, DDoS'
           ELSE 'No scenario' END,
           CASE WHEN hrs.h BETWEEN 8 AND 11  THEN 'Morning'
                WHEN hrs.h = 12              THEN 'Noon'
                WHEN hrs.h BETWEEN 13 AND 17 THEN 'Afternoon'
                ELSE 'Off-hours' END,
           hrs.h,
           CASE WHEN EXISTS (SELECT 1 FROM #obs ob
                             WHERE ob.obs_date = dys.d AND ob.obs_hour = hrs.h)
                THEN 1 ELSE 0 END
    FROM dys
    CROSS JOIN hrs

    --SELECT * FROM DimTime

    DROP TABLE #obs
-- 2. DimProtocol: các giao thức trong dữ liệu

    DROP TABLE IF EXISTS dbo.DimProtocol
    CREATE TABLE dbo.DimProtocol (
        protocol_key           INT         IDENTITY(1, 1) CONSTRAINT PK_DimProtocol PRIMARY KEY,
        ip_protocol_number     INT         NOT NULL CONSTRAINT UQ_DimProtocol_number UNIQUE,
        protocol_name          VARCHAR(20) NOT NULL,
        is_connection_oriented BIT         NOT NULL
    );

   WITH pm AS (
    SELECT pv.num, pv.name, pv.connection
    FROM (VALUES (1, 'ICMP', 0), (2, 'IGMP', 0), (6, 'TCP', 1),
                 (17, 'UDP', 0), (132, 'SCTP', 1)) pv (num, name, connection)
    )
    INSERT INTO dbo.DimProtocol (ip_protocol_number, protocol_name, is_connection_oriented)
    SELECT ip.ip_prot, ISNULL(pm.name, 'Unknown'), ISNULL(pm.connection, 0)
    FROM (SELECT DISTINCT ip_prot FROM dbo.data_raw) ip
    LEFT JOIN pm ON pm.num = ip.ip_prot
    ORDER BY ip.ip_prot

   -- SELECT * FROM DimProtocol
-- 3. DimService: mỗi cổng đích là 1 dòng. Nhóm dịch vụ -> Dịch vụ -> Cổng

    DROP TABLE IF EXISTS dbo.DimService
    CREATE TABLE dbo.DimService (
        service_key   INT         IDENTITY(1, 1) CONSTRAINT PK_DimService PRIMARY KEY,
        dst_port      INT         NOT NULL CONSTRAINT UQ_DimService_port UNIQUE,
        service_name  VARCHAR(50) NOT NULL,
        service_group VARCHAR(50) NOT NULL,
        port_range    VARCHAR(20) NOT NULL
    );

    WITH svm AS (
        SELECT sv.port, sv.svc_name, sv.svc_group
        FROM (VALUES
            (80,   'HTTP',                'Web'),
            (443,  'HTTPS/QUIC',          'Web'),
            (8080, 'HTTP-Alt',            'Web'),
            (444,  'HTTPS-Test',          'Web'),
            (53,   'DNS',                 'Name Resolution'),
            (5353, 'mDNS',                'Name Resolution'),
            (5355, 'LLMNR',               'Name Resolution'),
            (88,   'Kerberos',            'Authentication & Directory'),
            (389,  'LDAP',                'Authentication & Directory'),
            (3268, 'LDAP Global Catalog', 'Authentication & Directory'),
            (135,  'MS-RPC',              'File Sharing & Windows'),
            (137,  'NetBIOS',             'File Sharing & Windows'),
            (138,  'NetBIOS',             'File Sharing & Windows'),
            (139,  'NetBIOS',             'File Sharing & Windows'),
            (445,  'SMB',                 'File Sharing & Windows'),
            (22,   'SSH',                 'Remote Access'),
            (23,   'Telnet',              'Remote Access'),
            (3389, 'RDP',                 'Remote Access'),
            (21,   'FTP',                 'File Transfer'),
            (25,   'SMTP',                'Email'),
            (110,  'POP3',                'Email'),
            (143,  'IMAP',                'Email'),
            (465,  'SMTPS',               'Email'),
            (587,  'Submission',          'Email'),
            (993,  'IMAPS',               'Email'),
            (67,   'DHCP',                'Network Infrastructure'),
            (68,   'DHCP',                'Network Infrastructure'),
            (123,  'NTP',                 'Network Infrastructure'),
            (161,  'SNMP',                'Network Infrastructure'),
            (1900, 'SSDP',                'Network Infrastructure')
        ) sv (port, svc_name, svc_group)
    )
    INSERT INTO dbo.DimService (dst_port, service_name, service_group, port_range)
    SELECT pt.dst_port,
           ISNULL(svm.svc_name, CASE WHEN pt.dst_port = 0 THEN 'Not applicable' ELSE 'Unknown' END),
           ISNULL(svm.svc_group, 'Other'),
           CASE WHEN pt.dst_port <= 1023  THEN 'Well-known'
                WHEN pt.dst_port <= 49151 THEN 'Registered'
                ELSE 'Dynamic' END
    FROM (SELECT DISTINCT dst_port FROM dbo.data_raw) pt
    LEFT JOIN svm ON svm.port = pt.dst_port
    ORDER BY pt.dst_port

    --SELECT * FROM DimService

--4. DimAttackLabel: chiều nhãn tấn công. Lớp nhị phân -> Nhóm tấn công -> Loại tấn công

    DROP TABLE IF EXISTS dbo.DimAttackLabel
    CREATE TABLE dbo.DimAttackLabel (
        label_key    INT         IDENTITY(1, 1) CONSTRAINT PK_DimAttackLabel PRIMARY KEY,
        label_raw    VARCHAR(50) NOT NULL CONSTRAINT UQ_DimAttackLabel_raw UNIQUE,
        attack_group VARCHAR(30) NOT NULL,
        binary_class VARCHAR(10) NOT NULL,
        is_attack    TINYINT     NOT NULL
    )

    INSERT INTO dbo.DimAttackLabel (label_raw, attack_group, binary_class, is_attack)
    SELECT lb.label,
           CASE WHEN lb.label = 'benign'            THEN 'Benign'
                WHEN lb.label LIKE 'dos[_]%'        THEN 'DoS'
                WHEN lb.label = 'ddos'              THEN 'DDoS'
                WHEN lb.label LIKE '%[_]patator'    THEN 'Brute Force'
                WHEN lb.label LIKE 'webattack[_]%'  THEN 'Web Attack'
                WHEN lb.label = 'portscan'          THEN 'PortScan'
                WHEN lb.label = 'bot'               THEN 'Bot'
                WHEN lb.label = 'heartbleed'        THEN 'Heartbleed'
                ELSE 'Other' END,
           CASE WHEN lb.label = 'benign' THEN 'Benign' ELSE 'Attack' END,
           CASE WHEN lb.label = 'benign' THEN 0 ELSE 1 END
    FROM (SELECT DISTINCT label FROM dbo.data_raw) lb
    ORDER BY CASE WHEN lb.label = 'benign' THEN 0 ELSE 1 END, lb.label

   -- SELECT * FROM DimAttackLabel

-- 5. FactNetworkFlow: grain = 1 luong, flow_key = data_raw.id 

    DECLARE @src BIGINT = (SELECT COUNT_BIG(*) FROM dbo.data_raw)

    DROP TABLE IF EXISTS dbo.CubeFlow
    DROP TABLE IF EXISTS dbo.FlowFeature
    DROP TABLE IF EXISTS dbo.FactNetworkFlow

    CREATE TABLE dbo.FactNetworkFlow (
        flow_key      BIGINT       NOT NULL,
        time_key      INT          NOT NULL,
        protocol_key  INT          NOT NULL,
        service_key   INT          NOT NULL,
        label_key     INT          NOT NULL,
        flow_id       VARCHAR(255) NOT NULL,
        flow_start_us BIGINT       NOT NULL,
        data_split    VARCHAR(5)   NOT NULL,
        flow_count    INT          NOT NULL,
        is_attack     TINYINT      NOT NULL,
        fwd_bytes     BIGINT       NOT NULL,
        bwd_bytes     BIGINT       NOT NULL,
        total_bytes   BIGINT       NOT NULL,
        fwd_packets   BIGINT       NOT NULL,
        bwd_packets   BIGINT       NOT NULL,
        total_packets BIGINT       NOT NULL,
        flow_duration BIGINT       NOT NULL,
        bytes_per_s   FLOAT        NOT NULL,
        CONSTRAINT PK_FactNetworkFlow PRIMARY KEY CLUSTERED (flow_key),
        CONSTRAINT FK_Fact_Time     FOREIGN KEY (time_key)     REFERENCES dbo.DimTime (time_key),
        CONSTRAINT FK_Fact_Protocol FOREIGN KEY (protocol_key) REFERENCES dbo.DimProtocol (protocol_key),
        CONSTRAINT FK_Fact_Service  FOREIGN KEY (service_key)  REFERENCES dbo.DimService (service_key),
        CONSTRAINT FK_Fact_Label    FOREIGN KEY (label_key)    REFERENCES dbo.DimAttackLabel (label_key),
        CONSTRAINT CK_Fact_Split    CHECK (data_split IN ('train', 'test'))
    );

    WITH src AS (
        SELECT dr.id, dr.flow_id, dr.[timestamp], dr.ip_prot, dr.dst_port, dr.label,
               dr.fwd_pkt_len_tot, dr.bwd_pkt_len_tot, dr.fwd_pkt_cnt, dr.bwd_pkt_cnt,
               dr.flow_duration, dr.bytes_per_s, lt.local_dt
        FROM dbo.data_raw dr
        CROSS APPLY (SELECT DATEADD(HOUR, @_UtcOffsetHours,
                            DATEADD(SECOND, CAST(dr.[timestamp] / 1000000 AS INT), '19700101')) AS local_dt) lt
    ),
    lkp AS (
        SELECT src.*, dal.label_key, dal.is_attack, dp.protocol_key, ds.service_key,
               YEAR(src.local_dt) * 1000000 + MONTH(src.local_dt) * 10000
                   + DAY(src.local_dt) * 100 + DATEPART(HOUR, src.local_dt) AS time_key
        FROM src
        JOIN dbo.DimAttackLabel dal ON dal.label_raw = src.label
        JOIN dbo.DimProtocol    dp  ON dp.ip_protocol_number = src.ip_prot
        JOIN dbo.DimService     ds  ON ds.dst_port = src.dst_port
    ),
    rnk AS (
        SELECT lkp.*,
               ROW_NUMBER() OVER (PARTITION BY lkp.is_attack
                                  ORDER BY HASHBYTES('SHA1', CONCAT(@_Seed, '-', lkp.id))) AS rn,
               COUNT_BIG(*) OVER (PARTITION BY lkp.is_attack) AS cnt
        FROM lkp
    )
    INSERT INTO dbo.FactNetworkFlow WITH (TABLOCK)
           (flow_key, time_key, protocol_key, service_key, label_key, flow_id, flow_start_us,
            data_split, flow_count, is_attack, fwd_bytes, bwd_bytes, total_bytes,
            fwd_packets, bwd_packets, total_packets, flow_duration, bytes_per_s)
    SELECT rnk.id, rnk.time_key, rnk.protocol_key, rnk.service_key, rnk.label_key,
           rnk.flow_id, rnk.[timestamp],
           CASE WHEN rnk.rn <= CEILING(@_TestRatio * rnk.cnt) THEN 'test' ELSE 'train' END,
           1, rnk.is_attack,
           rnk.fwd_pkt_len_tot, rnk.bwd_pkt_len_tot, rnk.fwd_pkt_len_tot + rnk.bwd_pkt_len_tot,
           rnk.fwd_pkt_cnt, rnk.bwd_pkt_cnt, rnk.fwd_pkt_cnt + rnk.bwd_pkt_cnt,
           rnk.flow_duration, rnk.bytes_per_s
    FROM rnk
    INNER JOIN dbo.DimTime dt ON dt.time_key = rnk.time_key

    IF ROWCOUNT_BIG() <> @src
        THROW 50001, 'FactNetworkFlow: so dong nap khac data_raw (co khoa Dim khong map duoc)', 1

    CREATE INDEX IX_Fact_Time     ON dbo.FactNetworkFlow (time_key)
    CREATE INDEX IX_Fact_Protocol ON dbo.FactNetworkFlow (protocol_key)
    CREATE INDEX IX_Fact_Service  ON dbo.FactNetworkFlow (service_key)
    CREATE INDEX IX_Fact_Label    ON dbo.FactNetworkFlow (label_key)
    CREATE INDEX IX_Fact_Split    ON dbo.FactNetworkFlow (data_split)

    --SELECT TOP (100) * FROM dbo.FactNetworkFlow

-- 6. FlowFeature: 30 đặc trưng đã chọn ở notebook (MI + loại cột tương quan >= 0.95), quan hệ 1-1 với Fact

    DROP TABLE IF EXISTS dbo.FlowFeature

    SELECT CAST(dr.id AS BIGINT) AS flow_key,
           dr.bwd_pkt_len_mean, dr.bwd_pkt_len_tot, dr.pkt_len_max, dr.fwd_pkt_hdr_len_tot,
           dr.flag_ack, dr.fwd_pkt_len_max, dr.fwd_pkt_len_mean, dr.fwd_subflow_bytes_mean,
           dr.fwd_pkt_len_tot, dr.bwd_pkt_hdr_len_tot, dr.bwd_tcp_init_win_bytes, dr.iat_max,
           dr.fwd_iat_max, dr.fwd_tcp_init_win_bytes, dr.bwd_pkt_len_std, dr.bytes_per_s,
           dr.flag_SYN, dr.bwd_pkt_per_s, dr.bwd_iat_max, dr.fwd_pkt_len_std,
           dr.fwd_subflow_pkt_mean, dr.down_up_ratio, dr.fwd_pkt_cnt, dr.bwd_pkt_cnt,
           dr.fwd_iat_std, dr.fwd_non_empty_pkt_cnt, dr.bwd_subflow_pkt_mean,
           dr.bwd_non_empty_pkt_cnt, dr.fwd_pkt_len_min, dr.bwd_pkt_hdr_len_min
    INTO dbo.FlowFeature
    FROM dbo.data_raw dr

    ALTER TABLE dbo.FlowFeature ALTER COLUMN flow_key BIGINT NOT NULL
    ALTER TABLE dbo.FlowFeature ADD CONSTRAINT PK_FlowFeature PRIMARY KEY CLUSTERED (flow_key)
    ALTER TABLE dbo.FlowFeature ADD CONSTRAINT FK_FlowFeature_Fact
        FOREIGN KEY (flow_key) REFERENCES dbo.FactNetworkFlow (flow_key)

    --SELECT TOP (100) * FROM dbo.FlowFeature

-- 7. CubeFlow: cuboid Giờ x Giao thức x Cổng x Loại tấn công

    DROP TABLE IF EXISTS dbo.CubeFlow
    CREATE TABLE dbo.CubeFlow (
        time_key          INT    NOT NULL,
        protocol_key      INT    NOT NULL,
        service_key       INT    NOT NULL,
        label_key         INT    NOT NULL,
        flow_count        BIGINT NOT NULL,
        attack_count      BIGINT NOT NULL,
        total_bytes       BIGINT NOT NULL,
        total_packets     BIGINT NOT NULL,
        sum_flow_duration BIGINT NOT NULL,
        sum_bytes_per_s   FLOAT  NOT NULL,
        CONSTRAINT PK_CubeFlow PRIMARY KEY CLUSTERED (time_key, protocol_key, service_key, label_key)
    )

    INSERT INTO dbo.CubeFlow WITH (TABLOCK)
           (time_key, protocol_key, service_key, label_key, flow_count, attack_count,
            total_bytes, total_packets, sum_flow_duration, sum_bytes_per_s)
    SELECT fnf.time_key, fnf.protocol_key, fnf.service_key, fnf.label_key,
           SUM(CAST(fnf.flow_count AS BIGINT)),
           SUM(CAST(fnf.is_attack AS BIGINT)),
           SUM(fnf.total_bytes),
           SUM(fnf.total_packets),
           SUM(fnf.flow_duration),
           SUM(fnf.bytes_per_s)
    FROM dbo.FactNetworkFlow fnf
    GROUP BY fnf.time_key, fnf.protocol_key, fnf.service_key, fnf.label_key

    --SELECT TOP (100) * FROM dbo.CubeFlow

END
GO
--EXEC usp_DW_BuildTable