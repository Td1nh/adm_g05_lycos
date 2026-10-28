-- Q2: Giao thức và dịch vụ nào mang lưu lượng tấn công; mỗi loại tấn công nhắm vào bao nhiêu cổng đích khác nhau?
-- Chiều: DimProtocol, DimService (Nhóm dịch vụ -> Dịch vụ -> Cổng), DimAttackLabel (Nhóm -> Loại), DimTime (Ngày)
-- Nguồn: CubeFlow. Mức chi tiết của view: Giao thức x Cổng x Loại tấn công x Ngày
-- Giữ chiều Cổng ở mức chi tiết nhất để COUNT(DISTINCT dst_port) tính đúng ở mọi mức roll-up

CREATE OR ALTER VIEW dbo.view_Q2_AttackByService
AS
SELECT dp.protocol_name,
       ds.service_group, ds.service_name, ds.dst_port, ds.port_range,
       dal.attack_group, dal.label_raw, dal.binary_class,
       dt.day_name, dt.day_of_week,
       SUM(cf.flow_count)   AS flow_count,
       SUM(cf.attack_count) AS attack_count
FROM dbo.CubeFlow cf
INNER JOIN dbo.DimProtocol    dp  ON dp.protocol_key = cf.protocol_key
INNER JOIN dbo.DimService     ds  ON ds.service_key  = cf.service_key
INNER JOIN dbo.DimAttackLabel dal ON dal.label_key   = cf.label_key
INNER JOIN dbo.DimTime        dt  ON dt.time_key     = cf.time_key
GROUP BY dp.protocol_name,
         ds.service_group, ds.service_name, ds.dst_port, ds.port_range,
         dal.attack_group, dal.label_raw, dal.binary_class,
         dt.day_name, dt.day_of_week
GO

-- Slice theo giao thức: phân bố luồng Benign / Attack theo giao thức
SELECT q2.protocol_name,
       SUM(q2.flow_count)   AS flow_count,
       SUM(q2.attack_count) AS attack_count,
       CAST(SUM(q2.attack_count) * 1.0 / SUM(q2.flow_count) AS DECIMAL(6, 4)) AS attack_rate
FROM dbo.view_Q2_AttackByService q2
GROUP BY q2.protocol_name
ORDER BY attack_count DESC

-- Roll-up Cổng -> Dịch vụ -> Nhóm dịch vụ: nhóm dịch vụ bị nhắm tới nhiều nhất
SELECT q2.service_group,
       SUM(q2.flow_count)   AS flow_count,
       SUM(q2.attack_count) AS attack_count,
       CAST(SUM(q2.attack_count) * 1.0 / SUM(q2.flow_count) AS DECIMAL(6, 4)) AS attack_rate
FROM dbo.view_Q2_AttackByService q2
GROUP BY q2.service_group
ORDER BY attack_count DESC

-- Mức đa dạng cổng đích của từng loại tấn công (độ đo toàn thể, cần giữ chiều Cổng)
SELECT q2.attack_group, q2.label_raw,
       COUNT(DISTINCT q2.dst_port) AS distinct_ports,
       SUM(q2.attack_count)        AS attack_count
FROM dbo.view_Q2_AttackByService q2
WHERE q2.binary_class = 'Attack'
GROUP BY q2.attack_group, q2.label_raw
ORDER BY distinct_ports DESC

-- Dice: giao thức TCP x cổng 80 x thứ Sáu, theo loại tấn công
SELECT q2.label_raw,
       SUM(q2.flow_count)   AS flow_count,
       SUM(q2.attack_count) AS attack_count
FROM dbo.view_Q2_AttackByService q2
WHERE q2.protocol_name = 'TCP' AND q2.dst_port = 80 AND q2.day_name = 'Friday'
GROUP BY q2.label_raw
ORDER BY flow_count DESC

-- Drill-down: từ nhóm Web xuống từng dịch vụ và cổng
SELECT q2.service_name, q2.dst_port,
       SUM(q2.flow_count)   AS flow_count,
       SUM(q2.attack_count) AS attack_count
FROM dbo.view_Q2_AttackByService q2
WHERE q2.service_group = 'Web'
GROUP BY q2.service_name, q2.dst_port
ORDER BY attack_count DESC
