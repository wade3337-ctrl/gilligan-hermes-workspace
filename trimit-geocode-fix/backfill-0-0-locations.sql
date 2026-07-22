/* ============================================================
   Backfill coordinates for locations currently at 0/0.
   Run AFTER Locations_LatLong_upr.PROD-ALTER.sql is deployed and
   'Ole Automation Procedures' = 1 is confirmed on prod.

   Default scope = ALL locations at 0/0 that have a street address.

   Cautious first pass (optional): process a small batch, verify, then
   re-run for the rest. Replace the SELECT below with:
       SELECT TOP (100) l.LocationID ... ORDER BY l.LocationID
   Already-fixed rows drop out automatically on the next run, so this
   script is safe to re-run until 'still_zero_after' stops shrinking.
   ============================================================ */
SET NOCOUNT ON;

DECLARE @ids TABLE (LocationID int PRIMARY KEY);

INSERT INTO @ids (LocationID)
SELECT l.LocationID
FROM dbo.Locations l
WHERE (l.Latitude IS NULL OR l.Latitude = 0 OR l.Longitude IS NULL OR l.Longitude = 0)
  AND NULLIF(LTRIM(RTRIM(ISNULL(l.Street, ''))), '') IS NOT NULL
;

DECLARE @total int = (SELECT COUNT(*) FROM @ids);
PRINT 'Locations to backfill: ' + CAST(@total AS varchar(20));

DECLARE @id int;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT LocationID FROM @ids;
OPEN c; FETCH NEXT FROM c INTO @id;
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.Locations_LatLong_upr @ZLocationID = @id;
	FETCH NEXT FROM c INTO @id;
END
CLOSE c; DEALLOCATE c;

-- Report: how many are still at 0/0 (addresses Census couldn't match — usually a typo/PO box).
SELECT COUNT(*) AS still_zero_after
FROM dbo.Locations l
WHERE (l.Latitude IS NULL OR l.Latitude = 0 OR l.Longitude IS NULL OR l.Longitude = 0)
  AND l.LocationID IN (SELECT LocationID FROM @ids);
