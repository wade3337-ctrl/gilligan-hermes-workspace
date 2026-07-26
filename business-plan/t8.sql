-- When exactly did the regular/OT split stop being recorded?
SELECT FORMAT(cal.CalDate,'yyyy-MM') AS month,
       ROUND(SUM(ISNULL(cmc.TotalHours,0)),0) AS total_hrs,
       ROUND(SUM(ISNULL(cmc.RegularHours,0)),0) AS regular,
       ROUND(SUM(ISNULL(cmc.OTHours,0)),0) AS ot
FROM dbo.CrewMemberCalendars cmc JOIN dbo.Calendars cal ON cal.CalendarID=cmc.CalendarID
WHERE cal.CalDate >= '2025-01-01' AND cal.CalDate < '2026-07-27'
GROUP BY FORMAT(cal.CalDate,'yyyy-MM') ORDER BY month;
