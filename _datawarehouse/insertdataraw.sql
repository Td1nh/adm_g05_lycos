

SET NOCOUNT ON;

CREATE TABLE [dbo].[data_raw] (
    -- Thêm khóa chính tự tăng
    [id] BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Tối ưu kiểu chuỗi (VARCHAR thay vì VARCHAR(MAX))
    [flow_id] VARCHAR(255),
    [src_addr] VARCHAR(45),               -- Chứa IPv4/IPv6
    [src_port] INT,                       -- Port 0 - 65535
    [dst_addr] VARCHAR(45),
    [dst_port] INT,
    [ip_prot] TINYINT,                    -- Protocol ID (0 - 255)
    
    -- Các trường thời gian và dung lượng gói tin
    [timestamp] BIGINT,
    [flow_duration] BIGINT,
    [down_up_ratio] FLOAT,
    [pkt_len_max] FLOAT,
    [pkt_len_min] FLOAT,
    [pkt_len_mean] FLOAT,
    [pkt_len_var] FLOAT,
    [pkt_len_std] FLOAT,
    [bytes_per_s] FLOAT,
    [pkt_per_s] FLOAT,
    [fwd_pkt_per_s] FLOAT,
    [bwd_pkt_per_s] FLOAT,
    
    [fwd_pkt_cnt] BIGINT,
    [fwd_pkt_len_tot] BIGINT,
    [fwd_pkt_len_max] FLOAT,
    [fwd_pkt_len_min] FLOAT,
    [fwd_pkt_len_mean] FLOAT,
    [fwd_pkt_len_std] FLOAT,
    [fwd_pkt_hdr_len_tot] BIGINT,
    [fwd_pkt_hdr_len_min] BIGINT,
    [fwd_non_empty_pkt_cnt] BIGINT,
    
    [bwd_pkt_cnt] BIGINT,
    [bwd_pkt_len_tot] BIGINT,
    [bwd_pkt_len_max] FLOAT,
    [bwd_pkt_len_min] FLOAT,
    [bwd_pkt_len_mean] FLOAT,
    [bwd_pkt_len_std] FLOAT,
    [bwd_pkt_hdr_len_tot] BIGINT,
    [bwd_pkt_hdr_len_min] BIGINT,
    [bwd_non_empty_pkt_cnt] BIGINT,
    
    [iat_max] FLOAT,
    [iat_min] FLOAT,
    [iat_mean] FLOAT,
    [iat_std] FLOAT,
    
    [fwd_iat_tot] BIGINT,
    [fwd_iat_max] FLOAT,
    [fwd_iat_min] FLOAT,
    [fwd_iat_mean] FLOAT,
    [fwd_iat_std] FLOAT,
    
    [bwd_iat_tot] BIGINT,
    [bwd_iat_max] FLOAT,
    [bwd_iat_min] FLOAT,
    [bwd_iat_mean] FLOAT,
    [bwd_iat_std] FLOAT,
    
    [active_max] FLOAT,
    [active_min] FLOAT,
    [active_mean] FLOAT,
    [active_std] FLOAT,
    
    [idle_max] FLOAT,
    [idle_min] FLOAT,
    [idle_mean] FLOAT,
    [idle_std] FLOAT,
    
    -- Tối ưu cờ TCP Flags (dùng TINYINT 1 byte)
    [flag_SYN] TINYINT,
    [flag_fin] TINYINT,
    [flag_rst] TINYINT,
    [flag_ack] TINYINT,
    [flag_psh] TINYINT,
    [fwd_flag_psh] TINYINT,
    [bwd_flag_psh] TINYINT,
    [flag_urg] TINYINT,
    [fwd_flag_urg] TINYINT,
    [bwd_flag_urg] TINYINT,
    [flag_cwr] TINYINT,
    [flag_ece] TINYINT,
    
    [fwd_bulk_bytes_mean] FLOAT,
    [fwd_bulk_pkt_mean] FLOAT,
    [fwd_bulk_rate_mean] FLOAT,
    [bwd_bulk_bytes_mean] FLOAT,
    [bwd_bulk_pkt_mean] FLOAT,
    [bwd_bulk_rate_mean] FLOAT,
    
    [fwd_subflow_bytes_mean] FLOAT,
    [fwd_subflow_pkt_mean] FLOAT,
    [bwd_subflow_bytes_mean] FLOAT,
    [bwd_subflow_pkt_mean] FLOAT,
    
    [fwd_tcp_init_win_bytes] BIGINT,
    [bwd_tcp_init_win_bytes] BIGINT,
    
    [label] VARCHAR(100),
    [source_day] VARCHAR(100)
);

-- Tạo Index theo nhãn
CREATE INDEX idx_label ON [dbo].[data_raw]([label]);

-- Đổi kiểu dữ liệu sang BIGINT
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_SYN] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_fin] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_rst] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_ack] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_psh] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [fwd_flag_psh] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [bwd_flag_psh] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_urg] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [fwd_flag_urg] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [bwd_flag_urg] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_cwr] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [flag_ece] BIGINT;
ALTER TABLE [dbo].[data_raw] ALTER COLUMN [ip_prot] INT;

DROP TABLE IF EXISTS #tbl

-- đổ dữ liệu
CREATE TABLE #tbl (
    [flow_id] VARCHAR(255),
    [src_addr] VARCHAR(45),
    [src_port] INT,
    [dst_addr] VARCHAR(45),
    [dst_port] INT,
    [ip_prot] INT,
    [timestamp] BIGINT,
    [flow_duration] BIGINT,
    [down_up_ratio] FLOAT,
    [pkt_len_max] FLOAT,
    [pkt_len_min] FLOAT,
    [pkt_len_mean] FLOAT,
    [pkt_len_var] FLOAT,
    [pkt_len_std] FLOAT,
    [bytes_per_s] FLOAT,
    [pkt_per_s] FLOAT,
    [fwd_pkt_per_s] FLOAT,
    [bwd_pkt_per_s] FLOAT,
    [fwd_pkt_cnt] BIGINT,
    [fwd_pkt_len_tot] BIGINT,
    [fwd_pkt_len_max] FLOAT,
    [fwd_pkt_len_min] FLOAT,
    [fwd_pkt_len_mean] FLOAT,
    [fwd_pkt_len_std] FLOAT,
    [fwd_pkt_hdr_len_tot] BIGINT,
    [fwd_pkt_hdr_len_min] BIGINT,
    [fwd_non_empty_pkt_cnt] BIGINT,
    [bwd_pkt_cnt] BIGINT,
    [bwd_pkt_len_tot] BIGINT,
    [bwd_pkt_len_max] FLOAT,
    [bwd_pkt_len_min] FLOAT,
    [bwd_pkt_len_mean] FLOAT,
    [bwd_pkt_len_std] FLOAT,
    [bwd_pkt_hdr_len_tot] BIGINT,
    [bwd_pkt_hdr_len_min] BIGINT,
    [bwd_non_empty_pkt_cnt] BIGINT,
    [iat_max] FLOAT,
    [iat_min] FLOAT,
    [iat_mean] FLOAT,
    [iat_std] FLOAT,
    [fwd_iat_tot] BIGINT,
    [fwd_iat_max] FLOAT,
    [fwd_iat_min] FLOAT,
    [fwd_iat_mean] FLOAT,
    [fwd_iat_std] FLOAT,
    [bwd_iat_tot] BIGINT,
    [bwd_iat_max] FLOAT,
    [bwd_iat_min] FLOAT,
    [bwd_iat_mean] FLOAT,
    [bwd_iat_std] FLOAT,
    [active_max] FLOAT,
    [active_min] FLOAT,
    [active_mean] FLOAT,
    [active_std] FLOAT,
    [idle_max] FLOAT,
    [idle_min] FLOAT,
    [idle_mean] FLOAT,
    [idle_std] FLOAT,
    [flag_SYN] BIGINT,
    [flag_fin] BIGINT,
    [flag_rst] BIGINT,
    [flag_ack] BIGINT,
    [flag_psh] BIGINT,
    [fwd_flag_psh] BIGINT,
    [bwd_flag_psh] BIGINT,
    [flag_urg] BIGINT,
    [fwd_flag_urg] BIGINT,
    [bwd_flag_urg] BIGINT,
    [flag_cwr] BIGINT,
    [flag_ece] BIGINT,
    [fwd_bulk_bytes_mean] FLOAT,
    [fwd_bulk_pkt_mean] FLOAT,
    [fwd_bulk_rate_mean] FLOAT,
    [bwd_bulk_bytes_mean] FLOAT,
    [bwd_bulk_pkt_mean] FLOAT,
    [bwd_bulk_rate_mean] FLOAT,
    [fwd_subflow_bytes_mean] FLOAT,
    [fwd_subflow_pkt_mean] FLOAT,
    [bwd_subflow_bytes_mean] FLOAT,
    [bwd_subflow_pkt_mean] FLOAT,
    [fwd_tcp_init_win_bytes] BIGINT,
    [bwd_tcp_init_win_bytes] BIGINT,
    [label] VARCHAR(100),
    [source_day] VARCHAR(100)
);
GO

-- 2. BULK INSERT từ CSV vào staging
--    Sửa đường dẫn file nếu bạn chạy script này từ máy/ổ đĩa khác.
BULK INSERT #tbl
FROM 'E:\MASTER NHI\5. DATA MINING\adm_claude\data\data_raw.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK,
    BATCHSIZE = 100000
);
GO

 --3. Đổ dữ liệu sang data_raw 
INSERT INTO dbo.data_raw (
    [flow_id], [src_addr], [src_port], [dst_addr], [dst_port], [ip_prot],
    [timestamp], [flow_duration], [down_up_ratio], [pkt_len_max], [pkt_len_min],
    [pkt_len_mean], [pkt_len_var], [pkt_len_std], [bytes_per_s], [pkt_per_s],
    [fwd_pkt_per_s], [bwd_pkt_per_s], [fwd_pkt_cnt], [fwd_pkt_len_tot],
    [fwd_pkt_len_max], [fwd_pkt_len_min], [fwd_pkt_len_mean], [fwd_pkt_len_std],
    [fwd_pkt_hdr_len_tot], [fwd_pkt_hdr_len_min], [fwd_non_empty_pkt_cnt],
    [bwd_pkt_cnt], [bwd_pkt_len_tot], [bwd_pkt_len_max], [bwd_pkt_len_min],
    [bwd_pkt_len_mean], [bwd_pkt_len_std], [bwd_pkt_hdr_len_tot],
    [bwd_pkt_hdr_len_min], [bwd_non_empty_pkt_cnt], [iat_max], [iat_min],
    [iat_mean], [iat_std], [fwd_iat_tot], [fwd_iat_max], [fwd_iat_min],
    [fwd_iat_mean], [fwd_iat_std], [bwd_iat_tot], [bwd_iat_max], [bwd_iat_min],
    [bwd_iat_mean], [bwd_iat_std], [active_max], [active_min], [active_mean],
    [active_std], [idle_max], [idle_min], [idle_mean], [idle_std], [flag_SYN],
    [flag_fin], [flag_rst], [flag_ack], [flag_psh], [fwd_flag_psh],
    [bwd_flag_psh], [flag_urg], [fwd_flag_urg], [bwd_flag_urg], [flag_cwr],
    [flag_ece], [fwd_bulk_bytes_mean], [fwd_bulk_pkt_mean], [fwd_bulk_rate_mean],
    [bwd_bulk_bytes_mean], [bwd_bulk_pkt_mean], [bwd_bulk_rate_mean],
    [fwd_subflow_bytes_mean], [fwd_subflow_pkt_mean], [bwd_subflow_bytes_mean],
    [bwd_subflow_pkt_mean], [fwd_tcp_init_win_bytes], [bwd_tcp_init_win_bytes],
    [label], [source_day]
)
SELECT
    [flow_id], [src_addr], [src_port], [dst_addr], [dst_port], [ip_prot],
    [timestamp], [flow_duration], [down_up_ratio], [pkt_len_max], [pkt_len_min],
    [pkt_len_mean], [pkt_len_var], [pkt_len_std], [bytes_per_s], [pkt_per_s],
    [fwd_pkt_per_s], [bwd_pkt_per_s], [fwd_pkt_cnt], [fwd_pkt_len_tot],
    [fwd_pkt_len_max], [fwd_pkt_len_min], [fwd_pkt_len_mean], [fwd_pkt_len_std],
    [fwd_pkt_hdr_len_tot], [fwd_pkt_hdr_len_min], [fwd_non_empty_pkt_cnt],
    [bwd_pkt_cnt], [bwd_pkt_len_tot], [bwd_pkt_len_max], [bwd_pkt_len_min],
    [bwd_pkt_len_mean], [bwd_pkt_len_std], [bwd_pkt_hdr_len_tot],
    [bwd_pkt_hdr_len_min], [bwd_non_empty_pkt_cnt], [iat_max], [iat_min],
    [iat_mean], [iat_std], [fwd_iat_tot], [fwd_iat_max], [fwd_iat_min],
    [fwd_iat_mean], [fwd_iat_std], [bwd_iat_tot], [bwd_iat_max], [bwd_iat_min],
    [bwd_iat_mean], [bwd_iat_std], [active_max], [active_min], [active_mean],
    [active_std], [idle_max], [idle_min], [idle_mean], [idle_std], [flag_SYN],
    [flag_fin], [flag_rst], [flag_ack], [flag_psh], [fwd_flag_psh],
    [bwd_flag_psh], [flag_urg], [fwd_flag_urg], [bwd_flag_urg], [flag_cwr],
    [flag_ece], [fwd_bulk_bytes_mean], [fwd_bulk_pkt_mean], [fwd_bulk_rate_mean],
    [bwd_bulk_bytes_mean], [bwd_bulk_pkt_mean], [bwd_bulk_rate_mean],
    [fwd_subflow_bytes_mean], [fwd_subflow_pkt_mean], [bwd_subflow_bytes_mean],
    [bwd_subflow_pkt_mean], [fwd_tcp_init_win_bytes], [bwd_tcp_init_win_bytes],
    [label], [source_day]
FROM #tbl;
GO


DROP TABLE #tbl;
GO
