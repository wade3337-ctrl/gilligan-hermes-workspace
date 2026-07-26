WITH asg AS (
  SELECT ca.CrewMemberID, CAST(ca.ActStart AS date) AS d,
         DATEDIFF(minute, ca.ActStart, ca.ActEnd)/60.0 - ISNULL(ca.BreakTime,0) AS hrs
  FROM dbo.CrewAssignments ca JOIN dbo.CrewSheets cs ON cs.CrewSheetID=ca.CrewSheetID
  WHERE cs.WorkDate >= '2026-01-01' AND cs.WorkDate < '2026-07-27'
    AND ca.ActStart IS NOT NULL AND ca.ActEnd IS NOT NULL
), perday AS (
  SELECT CrewMemberID, d, SUM(hrs) AS day_hours FROM asg GROUP BY CrewMemberID, d
), split AS (
  SELECT p.CrewMemberID, p.day_hours,
    CASE WHEN day_hours<=8 THEN day_hours ELSE 8 END AS straight,
    CASE WHEN day_hours<=8 THEN 0 WHEN day_hours<=12 THEN day_hours-8 ELSE 4 END AS ot,
    CASE WHEN day_hours>12 THEN day_hours-12 ELSE 0 END AS dt,
    ISNULL(NULLIF(cm.HourlyRate,0), 27.45) AS rate
  FROM perday p LEFT JOIN dbo.CrewMembers cm ON cm.CrewMemberID=p.CrewMemberID
)
SELECT COUNT(*) AS person_days, COUNT(DISTINCT CrewMemberID) AS people,
  ROUND(SUM(day_hours),0) AS total_hrs, ROUND(SUM(straight),0) AS straight_hrs,
  ROUND(SUM(ot),0) AS ot_hrs, ROUND(SUM(dt),0) AS dt_hrs,
  CAST(ROUND(100.0*SUM(ot+dt)/SUM(day_hours),1) AS decimal(5,1)) AS pct_premium_hours,
  ROUND(SUM(ot*rate*0.5) + SUM(dt*rate*1.0),0) AS premium_cost_base,
  ROUND((SUM(ot*rate*0.5) + SUM(dt*rate*1.0))*1.3,0) AS premium_cost_loaded,
  ROUND((SUM(ot*rate*0.5)+SUM(dt*rate*1.0))/ (7.0/12.0),0) AS premium_annualised_base
FROM split;
