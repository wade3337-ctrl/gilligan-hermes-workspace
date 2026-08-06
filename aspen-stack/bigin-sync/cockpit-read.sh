#!/usr/bin/env bash
# Aspen cockpit-read v2 — MIRRORS the live Sales Cockpit (Dashboard-SalesCockpit.cfm), scoped to one rep.
# Replicates the cockpit's canonical stage flags (WorkOrders-driven) + the exact mutually-exclusive
# stageOf() priority cascade, so Aspen's Bigin cards match the board the Skipper sees. READ-ONLY.
# Usage: cockpit-read.sh <SalesRepID>            (e.g. 1140 = Ethan)
# Output pipe-delimited: ProjectID|Account|Property|Val|Lane|RunningDry|ReSell|BidAmt|LastActivity
# Canonical source: wiki CANONICAL-cockpit-alignment.md + cockpit .cfm (verified 2026-08-06).
set -euo pipefail
REP="${1:?usage: cockpit-read.sh <SalesRepID>}"
GATEWAY="$HOME/aspen-gateway/trimit-ro-query.sh"

sql=$(cat <<SQL
SET NOCOUNT ON;
WITH c AS (
  SELECT
    p.ProjectID,
    LTRIM(RTRIM(ISNULL(p.BillingName,''))) AS Account,
    LTRIM(RTRIM(LEFT(ja.j, CASE WHEN CHARINDEX(CHAR(10),ja.j)>0 THEN CHARINDEX(CHAR(10),ja.j)-1 ELSE LEN(ja.j) END))) AS Property,
    CAST(ISNULL(p.CurrentYear,0) AS INT) AS Val,
    /* --- canonical cockpit flags (WorkOrders-driven, verified 2026-07-04) --- */
    CASE WHEN EXISTS (SELECT 1 FROM dbo.WorkOrders wo WHERE wo.ProjectID=p.ProjectID AND wo.StatusDefID IN (46,109)) THEN 1 ELSE 0 END AS WActive,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.WorkOrders wo WHERE wo.ProjectID=p.ProjectID AND wo.StatusDefID IN (46,109) AND (wo.StartDate<=CAST(GETDATE() AS date) OR wo.StartDate IS NULL)) THEN 1 ELSE 0 END AS WInProgress,
    CASE WHEN ob.dt IS NOT NULL THEN 1 ELSE 0 END AS BidOpen,
    CASE WHEN dc.d IS NOT NULL AND dc.d>=DATEADD(day,-90,CAST(GETDATE() AS date)) THEN 1 ELSE 0 END AS DoneRecent,
    ob.amt AS BidAmt,
    CONVERT(varchar(10), (SELECT MAX(d) FROM (VALUES (lw.d),(lp.d),(ob.dt),(dc.d)) v(d)), 23) AS LastActivity,
    /* IsActive = live pipeline gate (same as cockpit) */
    CASE WHEN ob.dt IS NOT NULL
          OR (dc.d IS NOT NULL AND dc.d>=DATEADD(day,-90,CAST(GETDATE() AS date)))
          OR lw.d>=DATEADD(month,-6,GETDATE()) OR lp.d>=DATEADD(month,-6,GETDATE())
          OR EXISTS (SELECT 1 FROM dbo.WorkOrders wo WHERE wo.ProjectID=p.ProjectID AND wo.StatusDefID IN (46,109))
          OR EXISTS (SELECT 1 FROM dbo.WorkOrders wo WHERE wo.ProjectID=p.ProjectID AND wo.StatusDefID IN (46,109,38) AND wo.EndDate>=CAST(GETDATE() AS date))
         THEN 1 ELSE 0 END AS IsActive,
    CASE WHEN fw.d IS NOT NULL AND fw.d<DATEADD(month,3,GETDATE()) AND ob.dt IS NULL
          AND (p.ProjectTypeID<>4 OR ca.active=0)
          AND (dc.d IS NULL OR dc.d<DATEADD(day,-60,CAST(GETDATE() AS date))) THEN 1 ELSE 0 END AS RunningDry,
    CASE WHEN dc.d IS NOT NULL AND dc.d>=DATEADD(day,-90,CAST(GETDATE() AS date)) AND fw.d IS NULL AND ob.dt IS NULL
          AND NOT EXISTS (SELECT 1 FROM dbo.Contracts k JOIN dbo.StatusDefs ks ON k.StatusDefID=ks.StatusDefID AND ks.Desc1='Approved' WHERE k.ProjectID=p.ProjectID) THEN 1 ELSE 0 END AS ReSell
  FROM dbo.Projects p
  INNER JOIN dbo.StatusDefs sd ON p.StatusDefID=sd.StatusDefID
  INNER JOIN dbo.Locations  l  ON p.LocationID=l.LocationID
  LEFT  JOIN dbo.SalesReps  sr ON p.SalesRepID=sr.SalesRepID
  OUTER APPLY ( SELECT MAX(wo.EndDate) AS d FROM dbo.WorkOrders wo WHERE wo.ProjectID=p.ProjectID AND wo.StatusDefID=48 AND wo.EndDate IS NOT NULL ) lw
  OUTER APPLY ( SELECT MAX(pr.ProposalDate) AS d FROM dbo.Proposals pr WHERE pr.ProjectID=p.ProjectID AND pr.StatusDefID NOT IN (140) AND pr.ProposalDate IS NOT NULL ) lp
  OUTER APPLY ( SELECT TOP 1 pr.ProposalSentDate AS dt, pr.Total AS amt FROM dbo.Proposals pr WHERE pr.ProjectID=p.ProjectID AND pr.StatusDefID IN (41,106) AND pr.ProposalSentDate IS NOT NULL AND pr.ProposalSentDate>=DATEADD(month,-6,GETDATE()) ORDER BY pr.ProposalSentDate DESC ) ob
  OUTER APPLY ( SELECT MAX(wo.EndDate) AS d FROM dbo.WorkOrders wo WHERE wo.ProjectID=p.ProjectID AND wo.StatusDefID IN (46,109,38) AND wo.EndDate>=CAST(GETDATE() AS date) ) fw
  OUTER APPLY ( SELECT MAX(wo.DateCompleted) AS d FROM dbo.WorkOrders wo WHERE wo.ProjectID=p.ProjectID AND wo.StatusDefID=48 AND wo.DateCompleted IS NOT NULL ) dc
  OUTER APPLY ( SELECT CASE WHEN
                  EXISTS (SELECT 1 FROM dbo.WorkOrders w2 JOIN dbo.Projects p2 ON w2.ProjectID=p2.ProjectID WHERE p2.CompanyID=p.CompanyID AND w2.StatusDefID IN (46,109,38) AND w2.EndDate>=CAST(GETDATE() AS date))
                 AND EXISTS (SELECT 1 FROM dbo.WorkOrders w3 JOIN dbo.Projects p3 ON w3.ProjectID=p3.ProjectID WHERE p3.CompanyID=p.CompanyID AND w3.StatusDefID=48 AND w3.DateCompleted>=DATEADD(day,-90,CAST(GETDATE() AS date)))
                 THEN 1 ELSE 0 END AS active ) ca
  CROSS APPLY ( SELECT REPLACE(REPLACE(REPLACE(ISNULL(p.JobAddress,''),CHAR(13)+CHAR(10),CHAR(10)),CHAR(13),CHAR(10)),CHAR(10)+CHAR(10),CHAR(10)) AS j ) ja
  WHERE sd.Desc1 IN ('InProcess','Pending') AND p.SalesRepID=${REP}
)
SELECT ProjectID, Account, Property, Val,
  /* --- EXACT cockpit stageOf() priority cascade -> Aspen Feed lane --- */
  CASE
    WHEN BidOpen=1 AND WActive=0 THEN 'Bidding'
    WHEN WInProgress=1           THEN 'Working'
    WHEN WActive=1               THEN 'Scheduled (Won)'
    WHEN DoneRecent=1            THEN 'Recently Done'
    ELSE 'Follow Up'
  END AS Lane,
  RunningDry, ReSell, ISNULL(BidAmt,0) AS BidAmt, LastActivity
FROM c
WHERE IsActive=1
ORDER BY Val DESC;
SQL
)
echo "$sql" | "$GATEWAY"
