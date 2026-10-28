-- Q1: Lưu lượng tấn công tập trung vào ngày nào, khung giờ nào; tỷ lệ tấn công thay đổi ra sao theo thời gian?
-- Chiều: DimTime (Ngày -> Khung giờ -> Giờ). Độ đo: số luồng, số luồng tấn công, tỷ lệ tấn công
-- Nguồn: CubeFlow (chỉ gồm các giờ có dữ liệu, is_observed = 1)

CREATE OR ALTER VIEW dbo.view_Q1_AttackByTime
AS
SELECT dt.time_key, dt.full_date, dt.day_name, dt.day_of_week, dt.time_slot, dt.[hour],
       SUM(cf.flow_count)                    AS flow_count,
       SUM(cf.attack_count)                  AS attack_count,
       SUM(cf.flow_count - cf.attack_count)  AS benign_count,
       CAST(SUM(cf.attack_count) * 1.0 / SUM(cf.flow_count) AS DECIMAL(6, 4)) AS attack_rate
FROM dbo.CubeFlow cf
INNER JOIN dbo.DimTime dt ON dt.time_key = cf.time_key
GROUP BY dt.time_key, dt.full_date, dt.day_name, dt.day_of_week, dt.time_slot, dt.[hour]
GO

-- Roll-up: Giờ -> Khung giờ
SELECT q1.day_name, q1.time_slot,
       SUM(q1.flow_count)   AS flow_count,
       SUM(q1.attack_count) AS attack_count,
       CAST(SUM(q1.attack_count) * 1.0 / SUM(q1.flow_count) AS DECIMAL(6, 4)) AS attack_rate
FROM dbo.view_Q1_AttackByTime q1
GROUP BY q1.day_of_week, q1.day_name, q1.time_slot
ORDER BY q1.day_of_week, MIN(q1.[hour])

-- Roll-up: Giờ -> Ngày, chuẩn hóa theo số giờ có quan sát (thứ Năm chỉ có 4 giờ)
SELECT q1.day_name,
       COUNT(*)             AS observed_hours,
       SUM(q1.flow_count)   AS flow_count,
       SUM(q1.attack_count) AS attack_count,
       CAST(SUM(q1.attack_count) * 1.0 / SUM(q1.flow_count) AS DECIMAL(6, 4)) AS attack_rate,
       SUM(q1.attack_count) / COUNT(*) AS attack_per_hour
FROM dbo.view_Q1_AttackByTime q1
GROUP BY q1.day_of_week, q1.day_name
ORDER BY q1.day_of_week

-- Drill-down: Ngày -> Giờ (ví dụ thứ Tư)
SELECT q1.[hour], q1.flow_count, q1.attack_count, q1.attack_rate
FROM dbo.view_Q1_AttackByTime q1
WHERE q1.day_name = 'Wednesday'
ORDER BY q1.[hour]
