-- OT vs STRAIGHT TIME AUDIT BY CREW — 2026-01-01 to date. California daily rules.
WITH asg AS (
  SELECT ca.CrewMemberID, CAST(ca.ActStart AS date) AS d, cs.CrewNameID,
         DATEDIFF(minute, ca.ActStart, ca.ActEnd)/60.0 - ISNULL(ca.BreakTime,0) AS hrs
  FROM dbo.CrewAssignments ca JOIN dbo.CrewSheets cs ON cs.CrewSheetID=ca.CrewSheetID
  WHERE cs.WorkDate >= '2026-01-01' AND cs.WorkDate < '2026-07-27'
    AND ca.ActStart IS NOT NULL AND ca.ActEnd IS NOT NULL
), perday AS (   -- one row per person per day; crew = where most of the day was spent
  SELECT CrewMemberID, d, SUM(hrs) AS day_hours,
         (SELECT TOP 1 a2.CrewNameID FROM asg a2
           WHERE a2.CrewMemberID=a.CrewMemberID AND a2.d=a.d
           GROUP BY a2.CrewNameID ORDER BY SUM(a2.hrs) DESC) AS CrewNameID
  FROM asg a GROUP BY CrewMemberID, d
), split AS (
  SELECT CrewNameID, CrewMemberID, d, day_hours,
         CASE WHEN day_hours <= 8 THEN day_hours ELSE 8 END                              AS straight,
         CASE WHEN day_hours <= 8 THEN 0 WHEN day_hours <= 12 THEN day_hours-8 ELSE 4 END AS ot,
         CASE WHEN day_hours > 12 THEN day_hours-12 ELSE 0 END                            AS dt
  FROM perday
)
SELECT cn.Desc1 AS crew,
  COUNT(*) AS person_days,
  ROUND(SUM(s.day_hours),0) AS total_hrs,
  ROUND(SUM(s.straight),0)  AS straight_hrs,
  ROUND(SUM(s.ot),0)        AS ot_hrs,
  ROUND(SUM(s.dt),0)        AS dt_hrs,
  CAST(ROUND(100.0*SUM(s.ot+s.dt)/NULLIF(SUM(s.day_hours),0),1) AS decimal(5,1)) AS pct_premium,
  CAST(ROUND(AVG(s.day_hours),2) AS decimal(5,2)) AS avg_day_hrs
FROM split s LEFT JOIN dbo.CrewNames cn ON cn.CrewNameID=s.CrewNameID
GROUP BY cn.Desc1
HAVING COUNT(*) >= 50
ORDER BY SUM(s.ot+s.dt) DESC;
