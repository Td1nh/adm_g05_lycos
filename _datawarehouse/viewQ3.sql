-- Q3: Mỗi loại tấn công có hồ sơ lưu lượng (số luồng, byte, gói, thời lượng, tốc độ) khác Benign thế nào?
-- Chiều: DimAttackLabel (Lớp nhị phân -> Nhóm tấn công -> Loại tấn công)
-- Thời lượng tính bằng microsecond. Trung bình = tổng / số luồng (độ đo đại số, tính được từ CubeFlow)
-- Trung vị là độ đo toàn thể, không tính được từ tổng đã gộp nên phải đọc từ FactNetworkFlow

-- View 1: trung bình theo loại tấn công (đọc từ CubeFlow, chạy nhanh)
CREATE OR ALTER VIEW dbo.view_Q3_ProfileByLabel
AS
SELECT dal.binary_class, dal.attack_group, dal.label_raw,
       SUM(cf.flow_count)         AS flow_count,
       SUM(cf.total_bytes)        AS total_bytes,
       SUM(cf.total_packets)      AS total_packets,
       SUM(cf.sum_flow_duration)  AS sum_flow_duration,
       SUM(cf.sum_bytes_per_s)    AS sum_bytes_per_s,
       CAST(SUM(cf.total_bytes)       * 1.0 / SUM(cf.flow_count) AS DECIMAL(18, 2)) AS bytes_per_flow,
       CAST(SUM(cf.total_packets)     * 1.0 / SUM(cf.flow_count) AS DECIMAL(18, 2)) AS packets_per_flow,
       CAST(SUM(cf.sum_flow_duration) * 1.0 / SUM(cf.flow_count) AS DECIMAL(18, 2)) AS avg_duration,
       CAST(SUM(cf.sum_bytes_per_s)   * 1.0 / SUM(cf.flow_count) AS DECIMAL(18, 2)) AS avg_bytes_per_s
FROM dbo.CubeFlow cf
INNER JOIN dbo.DimAttackLabel dal ON dal.label_key = cf.label_key
GROUP BY dal.binary_class, dal.attack_group, dal.label_raw
GO

-- View 2: trung vị thời lượng và byte mỗi luồng theo loại tấn công
-- Tính lại trên toàn bộ 1,8 triệu dòng mỗi lần truy vấn nên chậm; nếu dùng vẽ biểu đồ nên lưu kết quả ra bảng
CREATE OR ALTER VIEW dbo.view_Q3_MedianByLabel
AS
SELECT DISTINCT dal.binary_class, dal.attack_group, dal.label_raw,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fnf.flow_duration)
           OVER (PARTITION BY fnf.label_key) AS median_duration,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fnf.total_bytes)
           OVER (PARTITION BY fnf.label_key) AS median_bytes
FROM dbo.FactNetworkFlow fnf
JOIN dbo.DimAttackLabel dal ON dal.label_key = fnf.label_key
GO

-- Roll-up Loại -> Lớp nhị phân: Benign so với Attack
SELECT q3.binary_class,
       SUM(q3.flow_count) AS flow_count,
       CAST(SUM(q3.total_bytes)       * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS bytes_per_flow,
       CAST(SUM(q3.total_packets)     * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS packets_per_flow,
       CAST(SUM(q3.sum_flow_duration) * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS avg_duration,
       CAST(SUM(q3.sum_bytes_per_s)   * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS avg_bytes_per_s
FROM dbo.view_Q3_ProfileByLabel q3
GROUP BY q3.binary_class

-- Roll-up Loại -> Nhóm tấn công
SELECT q3.attack_group,
       SUM(q3.flow_count) AS flow_count,
       CAST(SUM(q3.total_bytes)       * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS bytes_per_flow,
       CAST(SUM(q3.total_packets)     * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS packets_per_flow,
       CAST(SUM(q3.sum_flow_duration) * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS avg_duration,
       CAST(SUM(q3.sum_bytes_per_s)   * 1.0 / SUM(q3.flow_count) AS DECIMAL(18, 2)) AS avg_bytes_per_s
FROM dbo.view_Q3_ProfileByLabel q3
GROUP BY q3.attack_group
ORDER BY flow_count DESC

-- Drill-down: từ nhóm DoS xuống bốn loại DoS
SELECT q3.label_raw, q3.flow_count, q3.bytes_per_flow, q3.avg_duration, q3.avg_bytes_per_s
FROM dbo.view_Q3_ProfileByLabel q3
WHERE q3.attack_group = 'DoS'
ORDER BY q3.flow_count DESC

-- Đối chiếu trung bình với trung vị (dữ liệu lệch phải mạnh nên hai giá trị có thể khác xa nhau)
SELECT q3.label_raw, q3.avg_duration, md.median_duration, q3.bytes_per_flow, md.median_bytes
FROM dbo.view_Q3_ProfileByLabel q3
JOIN dbo.view_Q3_MedianByLabel md ON md.label_raw = q3.label_raw
ORDER BY q3.flow_count DESC
