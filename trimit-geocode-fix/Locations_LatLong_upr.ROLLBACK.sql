ALTER PROCEDURE [dbo].[Locations_LatLong_upr]
	@ZLocationID INT
AS
BEGIN
 SET NOCOUNT ON
	DECLARE 
		@VAddress varchar(80),
		@VCity varchar(40),
		@VState varchar(40),
		@VCountry varchar(40),
		@VPostalCode varchar(20),
		@VCounty varchar(40),
		@VGPSLatitude numeric(9,6),
		@VGPSLongitude numeric(9,6),
		@VMapURL varchar(1024),
		@VURL varchar(MAX),
		@VGeoCodeCount INT;
	BEGIN
		BEGIN
			SELECT @VGeoCodeCount = ISNULL(Calendars.GeoCodeCount,0)
			FROM dbo.Calendars
			WHERE Calendars.CalendarID = dbo.GetCalendarIDFromDate(GetDate());
		END;
		IF ISNULL(@VGeoCodeCount,0) <= 2400
			BEGIN
				BEGIN
					SELECT	@VAddress = REPLACE(Locations.Street,CHAR(38),'and'),
							@VCity = Locations.City,
							@VState = Locations.State,
							@VCountry = 'USA',
							@VPostalCode = NULL,
							@VCounty = ZipCodes.County
					FROM dbo.Locations
						INNER JOIN dbo.ZipCodes ON Locations.ZipCodeID = ZipCodes.ZipCodeID
					WHERE Locations.LocationID = @ZLocationID;
				END;
				SET @VURL = 'http://maps.google.com/maps/api/geocode/xml?sensor=false&address=' +
				CASE WHEN @VAddress IS NOT NULL THEN @VAddress ELSE '' END +
				CASE WHEN @VCity IS NOT NULL THEN ', ' + @VCity ELSE '' END +
				CASE WHEN @VState IS NOT NULL THEN ', ' + @VState ELSE '' END +
				CASE WHEN @VPostalCode IS NOT NULL THEN '  ' + @VPostalCode ELSE '' END +
				CASE WHEN @VCountry IS NOT NULL THEN '  ' + @VCountry ELSE '' END
				SET @VURL = REPLACE(@VURL, ' ', '+')

				 DECLARE @VResponse varchar(8000)
				 DECLARE @VXML xml
				 DECLARE @VObj int 
				 DECLARE @VResult int 
				 DECLARE @VHTTPStatus int 
				 DECLARE @VErrorMsg varchar(MAX)

				EXEC @VResult = sp_OACreate 'MSXML2.ServerXMLHttp', @VObj OUT 

				 BEGIN TRY
				 EXEC @VResult = sp_OAMethod @VObj, 'open', NULL, 'GET', @VURL, false
				 EXEC @VResult = sp_OAMethod @VObj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
				 EXEC @VResult = sp_OAMethod @VObj, send, NULL, ''
				 EXEC @VResult = sp_OAGetProperty @VObj, 'status', @VHTTPStatus OUT 
				 EXEC @VResult = sp_OAGetProperty @VObj, 'responseXML.xml', @VResponse OUT 
				 END TRY
				 BEGIN CATCH
				 SET @VErrorMsg = ERROR_MESSAGE()
				 END CATCH

				 EXEC @VResult = sp_OADestroy @VObj

				IF (@VErrorMsg IS NOT NULL) OR (@VHTTPStatus <> 200) BEGIN
				 SET @VErrorMsg = 'Error in spGeocode: ' + ISNULL(@VErrorMsg, 'HTTP result is: ' + CAST(@VHTTPStatus AS varchar(10)))
				 RAISERROR(@VErrorMsg, 16, 1, @VHTTPStatus)
				 RETURN 
				 END

				SET @VXML = CAST(@VResponse AS XML)

				 SET @VGPSLatitude = @VXML.value('(/GeocodeResponse/result/geometry/location/lat) [1]', 'numeric(9,6)')
				 SET @VGPSLongitude = @VXML.value('(/GeocodeResponse/result/geometry/location/lng) [1]', 'numeric(9,6)')

				SET @VCity = @VXML.value('(/GeocodeResponse/result/address_component[type="locality"]/long_name) [1]', 'varchar(40)') 
				 SET @VState = @VXML.value('(/GeocodeResponse/result/address_component[type="administrative_area_level_1"]/short_name) [1]', 'varchar(40)') 
				 SET @VPostalCode = @VXML.value('(/GeocodeResponse/result/address_component[type="postal_code"]/long_name) [1]', 'varchar(20)') 
				 SET @VCountry = @VXML.value('(/GeocodeResponse/result/address_component[type="country"]/short_name) [1]', 'varchar(40)') 
				 SET @VCounty = @VXML.value('(/GeocodeResponse/result/address_component[type="administrative_area_level_2"]/short_name) [1]', 'varchar(40)') 

				 SET @VAddress = 
				 ISNULL(@VXML.value('(/GeocodeResponse/result/address_component[type="street_number"]/long_name) [1]', 'varchar(40)'), '???') + ' ' +
				 ISNULL(@VXML.value('(/GeocodeResponse/result/address_component[type="route"]/long_name) [1]', 'varchar(40)'), '???') 
				 SET @VMapURL = 'http://maps.google.com/maps?f=q&hl=en&q=' + CAST(@VGPSLatitude AS varchar(20)) + '+' + CAST(@VGPSLongitude AS varchar(20))


				IF @VGPSLatitude IS NOT NULL
					BEGIN 
						UPDATE dbo.Locations
						SET Locations.Latitude = @VGPSLatitude,
							Locations.Longitude = @VGPSLongitude,
							Locations.ModifiedDate = GetDate(),
							Locations.ModifiedDetail = LTRIM(ISNULL(Locations.ModifiedDetail,' ')+' GEOCODE')
						WHERE Locations.LocationID = @ZLocationID;
					END;
			END;

	END;

END




