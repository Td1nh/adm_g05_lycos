-- Q4: Mỗi ngày trong tuần chứa những loại tấn công nào và với quy mô ra sao?
-- Chiều: DimTime (Ngày), DimAttackLabel (Nhóm tấn công -> Loại tấn công)
-- Độ đo: số luồng, tỷ trọng của mỗi loại trong tổng luồng tấn công của ngày
-- Nguồn: CubeFlow. Chỉ lấy luồng tấn công (is_attack = 1)

CREATE OR ALTER VIEW dbo.view_Q4_AttackTypeByDay
AS
SELECT dt.full_date, dt.day_name, dt.day_of_week,
       dal.attack_group, dal.label_raw,
       SUM(cf.flow_count) AS flow_count,
       CAST(SUM(cf.flow_count) * 1.0 / SUM(SUM(cf.flow_count)) OVER (PARTITION BY dt.full_date)
            AS DECIMAL(6, 4)) AS share_in_day
FROM dbo.CubeFlow cf
INNER JOIN dbo.DimTime dt  ON dt.time_key = cf.time_key
INNER JOIN dbo.DimAttackLabel dal ON dal.label_key = cf.label_key
WHERE dal.is_attack = 1
GROUP BY dt.full_date, dt.day_name, dt.day_of_week, dal.attack_group, dal.label_raw
GO

-- Pivot: Loại tấn công x Ngày (số luồng)
SELECT q4.attack_group, q4.label_raw,
       SUM(CASE WHEN q4.day_name = 'Monday'    THEN q4.flow_count ELSE 0 END) AS Monday,
       SUM(CASE WHEN q4.day_name = 'Tuesday'   THEN q4.flow_count ELSE 0 END) AS Tuesday,
       SUM(CASE WHEN q4.day_name = 'Wednesday' THEN q4.flow_count ELSE 0 END) AS Wednesday,
       SUM(CASE WHEN q4.day_name = 'Thursday'  THEN q4.flow_count ELSE 0 END) AS Thursday,
       SUM(CASE WHEN q4.day_name = 'Friday'    THEN q4.flow_count ELSE 0 END) AS Friday
FROM dbo.view_Q4_AttackTypeByDay q4
GROUP BY q4.attack_group, q4.label_raw
ORDER BY q4.attack_group, q4.label_raw

-- Roll-up Loại -> Nhóm tấn công theo ngày, kèm tỷ trọng trong tổng luồng tấn công của ngày
SELECT q4.day_name, q4.attack_group,
       SUM(q4.flow_count)  AS flow_count,
       SUM(q4.share_in_day) AS share_in_day
FROM dbo.view_Q4_AttackTypeByDay q4
GROUP BY q4.day_of_week, q4.day_name, q4.attack_group
ORDER BY q4.day_of_week, flow_count DESC

-- Drill-down: từ nhóm DoS xuống bốn loại DoS theo ngày
SELECT q4.day_name, q4.label_raw, q4.flow_count, q4.share_in_day
FROM dbo.view_Q4_AttackTypeByDay q4
WHERE q4.attack_group = 'DoS'
ORDER BY q4.day_of_week, q4.flow_count DESC
