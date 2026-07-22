-- PROD deliverable: ALTER dbo.Locations_LatLong_upr — free US Census geocoder (Gilligan 2026-07-22)
-- Requires: Ole Automation Procedures = 1 on the target server (Travis: confirm on prod).

SET NOCOUNT ON;
GO
/* Option A (corrected) — Locations_LatLong_upr via free US Census geocoder.
   Fixes vs first cut: OLE output param must be FIXED size (varchar(8000)),
   not varchar(max) [ODSOLE "Error in srv_paramset"]; open() async = 0. */
ALTER PROCEDURE [dbo].[Locations_LatLong_upr]
	@ZLocationID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@VStreet       varchar(120),
		@VCity         varchar(60),
		@VState        varchar(40),
		@VZip          varchar(20),
		@VAddress      varchar(400),
		@VURL          varchar(1024),
		@VGPSLatitude  numeric(9,6),
		@VGPSLongitude numeric(9,6),
		@VGeoCodeCount int,
		@VResponse     varchar(8000),   -- FIXED size required for OLE OUTPUT (not varchar(max))
		@VObj          int,
		@VResult       int,
		@VHTTPStatus   int,
		@VErrorMsg     varchar(4000);

	SELECT @VGeoCodeCount = ISNULL(Calendars.GeoCodeCount, 0)
	FROM dbo.Calendars
	WHERE Calendars.CalendarID = dbo.GetCalendarIDFromDate(GetDate());

	IF ISNULL(@VGeoCodeCount, 0) > 2400 RETURN;

	SELECT
		@VStreet = REPLACE(Locations.Street, CHAR(38), 'and'),
		@VCity   = Locations.City,
		@VState  = Locations.State,
		@VZip    = LEFT(LTRIM(RTRIM(ISNULL(CAST(ZipCodes.ZipCode AS varchar(20)), ''))), 10)
	FROM dbo.Locations
		LEFT JOIN dbo.ZipCodes ON Locations.ZipCodeID = ZipCodes.ZipCodeID
	WHERE Locations.LocationID = @ZLocationID;

	IF NULLIF(LTRIM(RTRIM(ISNULL(@VStreet, ''))), '') IS NULL RETURN;

	SET @VAddress = @VStreet
		+ CASE WHEN NULLIF(LTRIM(RTRIM(@VCity)),  '') IS NOT NULL THEN ', ' + @VCity  ELSE '' END
		+ CASE WHEN NULLIF(LTRIM(RTRIM(@VState)), '') IS NOT NULL THEN ', ' + @VState ELSE '' END
		+ CASE WHEN NULLIF(LTRIM(RTRIM(@VZip)),   '') IS NOT NULL THEN ' '  + @VZip   ELSE '' END;

	SET @VURL = 'https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?benchmark=Public_AR_Current&format=json&address='
		+ REPLACE(REPLACE(REPLACE(@VAddress, '%', '%25'), ' ', '+'), ',', '%2C');

	EXEC @VResult = sp_OACreate 'MSXML2.ServerXMLHttp', @VObj OUT;
	IF @VResult <> 0 RETURN;

	BEGIN TRY
		EXEC @VResult = sp_OAMethod @VObj, 'open', NULL, 'GET', @VURL, 0;   -- 0 = synchronous
		EXEC @VResult = sp_OAMethod @VObj, 'send', NULL, '';
		EXEC @VResult = sp_OAGetProperty @VObj, 'status', @VHTTPStatus OUT;
		EXEC @VResult = sp_OAGetProperty @VObj, 'responseText', @VResponse OUT;
	END TRY
	BEGIN CATCH
		SET @VErrorMsg = ERROR_MESSAGE();
	END CATCH

	EXEC sp_OADestroy @VObj;

	IF @VErrorMsg IS NOT NULL OR ISNULL(@VHTTPStatus, 0) <> 200
	   OR @VResponse IS NULL OR ISJSON(@VResponse) = 0
		RETURN;   -- geocode failed: leave coordinates unchanged, never abort the save

	SET @VGPSLatitude  = TRY_CAST(JSON_VALUE(@VResponse, '$.result.addressMatches[0].coordinates.y') AS numeric(9,6));
	SET @VGPSLongitude = TRY_CAST(JSON_VALUE(@VResponse, '$.result.addressMatches[0].coordinates.x') AS numeric(9,6));

	IF @VGPSLatitude IS NOT NULL AND @VGPSLongitude IS NOT NULL
	   AND @VGPSLatitude <> 0 AND @VGPSLongitude <> 0
	BEGIN
		UPDATE dbo.Locations
		SET Latitude       = @VGPSLatitude,
			Longitude      = @VGPSLongitude,
			ModifiedDate   = GetDate(),
			ModifiedDetail = LTRIM(ISNULL(ModifiedDetail, ' ') + ' GEOCODE')
		WHERE LocationID = @ZLocationID;
	END
END
GO
