<cfif CGI.https NEQ "on">
  <cflocation url="https://#APPLICATION.DOMAIN##CGI.SCRIPT_NAME#" addtoken="false">
</cfif>

<cfinclude template="ValidateLoginUser.cfm">

<cfparam name="URL.ZUserID" default="1">
<cfparam name="URL.ZFromForm" default="" type="String">

<cfif IsDefined("Cookie.ZUserID") is "False">
  <cflocation url="System.Login.cfm" addtoken="false">
</cfif>

<cfquery datasource="GSTS" name="PERM_CHECK">
  SELECT IsAllowed 
  FROM   GSTS.dbo.UserActions 
  INNER JOIN GSTS.dbo.ActionDefs ON UserActions.ActionDefID = ActionDefs.ActionDefID
  WHERE ActionDefs.DESC1 = 'Mobile Time Clock'
  AND UserID = <cfqueryparam value="#Cookie.ZUserID#" cfsqltype="cf_sql_numeric">
</cfquery>

<cfif PERM_CHECK.RecordCount NEQ 0 AND PERM_CHECK.IsAllowed EQ 1>
  <cflocation url="Mobile2/Profile$TimeClock.cfm?ZUserID=#Cookie.ZUserID#&ZFromForm=LoginForm" addtoken="false">
</cfif>

<cfquery name="Me" datasource="GSTS">
SELECT	Users.UserID,
		Users.Desc1, 
		Users.LoginName, 
		Users.SecurityLevelID, 
		Users.Password, 
        Profiles.ProfileID,
		CASE LEN(LTRIM(RTRIM(ISNULL(Profiles.ProfilePicturePath,' ')))) WHEN 0 THEN 'art/profilepictures/TrimITLogo.png' ELSE Profiles.ProfilePicturePath END AS ProfilePicturePath,
        dbo.GetQueueItems(Users.UserID) AS VQueueItems,
        Users.ResourceGroup,
        ISNULL(Users.IsSoundOn,0) AS IsSoundOn,
        ISNULL(Users.DefaultContentForm, 'Overview/Quick$Base.cfm') AS DefaultContentForm,
        ISNULL(Users.IsPayrollItem,0) AS IsPayrollItem
FROM dbo.Profiles
	INNER JOIN flow.Users ON Profiles.UserID = Users.UserID
WHERE Users.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">  
</cfquery>

<cfquery name="CurrentWeekDef" datasource="GSTS">
SELECT ROUND(dbo.GetWeekDef$OAPerc(WeekDefID) * 100,1) AS OAPerc
FROM dbo.WeekDefs
WHERE GetDate() BETWEEN StartDate AND EndDate
</cfquery>


<cfquery name="CurrentPeriod" datasource="GSTS">
SELECT 	Periods.PeriodID AS PeriodID,
		Periods.YearID AS YearID,
		CAST(MONTH(Periods.StartDate) AS VARCHAR)+'-'+CAST(DAY(Periods.StartDate) AS VARCHAR)+'-'+CAST(YEAR(Periods.StartDate) AS VARCHAR) AS StartDate,
        MONTH(Periods.EndDate)+'-'+DAY(Periods.EndDate)+'-'+YEAR(Periods.EndDate) AS EndDate
FROM dbo.Periods 
WHERE Periods.PeriodID = dbo.GetPeriodIDFromDate(GetDate()); 
</cfquery>

<cfquery name="CurrentCalendar" datasource="GSTS">
SELECT 	Calendars.CalendarID
FROM dbo.Calendars
WHERE Calendars.CalendarID = dbo.GetCalendarIDFromDate(GetDate());
</cfquery>

<cfquery name="DayBeforeCalendar" datasource="GSTS">
SELECT 	Calendars.CalendarID
FROM dbo.Calendars
WHERE Calendars.CalendarID = dbo.GetCalendarIDFromDate(GetDate()-2);
</cfquery>

<cfquery name="YesterdayCalendar" datasource="GSTS">
SELECT 	Calendars.CalendarID
FROM dbo.Calendars
WHERE Calendars.CalendarID = dbo.GetCalendarIDFromDate(GetDate()-1);
</cfquery>

<cfquery name="TomorrowCalendar" datasource="GSTS">
SELECT 	Calendars.CalendarID
FROM dbo.Calendars
WHERE Calendars.CalendarID = dbo.GetCalendarIDFromDate(GetDate()+1);
</cfquery>

<cfquery name="NextDayCalendar" datasource="GSTS">
SELECT 	Calendars.CalendarID
FROM dbo.Calendars
WHERE Calendars.CalendarID = dbo.GetCalendarIDFromDate(GetDate()+2);
</cfquery>





<cfquery name="Sec" datasource="GSTS">
SELECT	dbo.GetUserSecurityLevel(Users.UserID,'FIND') AS FindLevel,
		dbo.GetUserSecurityLevel(Users.UserID,'QUALIFY') AS QualifyLevel,
		dbo.GetUserSecurityLevel(Users.UserID,'SOLVE') AS SolveLevel,
		dbo.GetUserSecurityLevel(Users.UserID,'CLOSE') AS CloseLevel,
		dbo.GetUserSecurityLevel(Users.UserID,'SCHEDULING') AS SchedulingLevel,
		dbo.GetUserSecurityLevel(Users.UserID,'PRODUCTION') AS ProductionLevel,
		dbo.GetUserSecurityLevel(Users.UserID,'BILLING') AS BillingLevel,
		dbo.GetUserSecurityLevel(Users.UserID,'EXECUTIVE') AS ExecutiveLevel,        
		dbo.GetUserSecurityLevel(Users.UserID,'MAINTENANCE') AS MaintenanceLevel,
   		dbo.GetUserSecurityLevel(Users.UserID,'FLEET') AS FleetLevel,
   		dbo.GetUserSecurityLevel(Users.UserID,'HR') AS HRLevel        
        
FROM flow.Users
WHERE Users.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric"> 
</cfquery>
<cfquery name="MyReports" datasource="GSTS">
SELECT 'AppForms' AS TableName, AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1,AppForms.AppFormID,Profiles.UserID,AppForms.FormType
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
WHERE AppForms.FormType = 'Report'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyFindItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'FIND'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MySolveItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'SOLVE'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyCloseItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'CLOSE'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyProductionItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'PRODUCTION'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1

</cfquery>

<cfquery name="MyFleetItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
  INNER JOIN dbo.statusdefs on statusdefs.statusdefid = AppForms.statusdefid  
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'FLEET'
  AND statusdefs.desc1 <> 'Inactive'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="TimeAttendancePerm" datasource="GSTS">
  SELECT IsAllowed 
  FROM   GSTS.dbo.UserActions 
  INNER JOIN GSTS.dbo.ActionDefs ON UserActions.ActionDefID = ActionDefs.ActionDefID
  WHERE ActionDefs.DESC1 = 'Time & Attendance Dashboard - View Time Entry'
  AND UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
</cfquery>

<cfset NavCommissionAccess = (findNoCase(",SaleCommissionAdmin,", ",#GetUserRoles()#,", 0) GTE 1 OR findNoCase(",SaleCommissionAdminReadOnly,", ",#GetUserRoles()#,", 0) GTE 1)>

<cfquery name="MyHRItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'HR'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyITItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'IT'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyBillingItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'BILLING'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyExecutiveItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'EXECUTIVE'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyMaintenanceItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'MAINTENANCE'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1  
 
</cfquery>

<cfquery name="MyGroupTextItems" datasource="GSTS">
SELECT AppForms.Desc1, AppForms.ObjectPath, AppForms.TargetDesc1
FROM dbo.MyAppForms
  INNER JOIN dbo.Profiles ON MyAppForms.ProfileID = Profiles.ProfileID
  INNER JOIN dbo.AppForms ON MyAppForms.AppFormID = AppForms.AppFormID
  INNER JOIN dbo.Statusdefs AS AppFormsStatusdefs ON AppFormsStatusdefs.StatusdefID = AppForms.StatusdefID     
  INNER JOIN flow.Steps ON AppForms.StepID = Steps.StepID
WHERE AppForms.FormType = 'Form'
  AND Steps.Desc1 = 'Group Text'
  AND Profiles.UserID = <cfqueryparam value="#URL.ZUserID#" cfsqltype="cf_sql_numeric">
  AND AppFormsStatusdefs.StatusDefID = dbo.GetStatus('AppForms','Active')   
ORDER BY AppForms.Desc1
</cfquery>
<cfquery name="UserCalendar" datasource="GSTS">
SELECT UserCalendarID, Desc1, UserID, CalendarID, CompletedItems, MidLatitude, MidLongitude, MinLatitude, MaxLatitude, MinLongitude, MaxLongitude, ActStart, ActEnd, BreakTime, ActOfficeHours
FROM dbo.UserCalendars
WHERE CalendarID = #CurrentCalendar.CalendarID#
  AND UserID = #Me.UserID#
</cfquery>

<cfquery name="HasWebUserAccount" datasource="GSTS">
SELECT	TOP 1 	'External' AS ZScope,
				WebUsers.WebUserID AS ZPK,
				'WebPortal/'+ISNULL(WebUserAccounts.WebPortalVersion,'index.cfm')+'?ZProjectID='+CAST(WebUsers.ProjectID AS VARCHAR)+'&ref='+WebUserAccounts.WebUserAccountHash AS ZDirect
FROM dbo.WebUsers
	LEFT JOIN dbo.WebUserAccounts ON WebUsers.WebUserAccountID = WebUserAccounts.WebUserAccountID
    CROSS JOIN flow.Users
WHERE Users.UserID = #Me.UserID#
  AND Users.UserEmail = WebUsers.EmailAddress
  AND WebUsers.StatusDefID = dbo.GetStatus('WebUsers','Active')
</cfquery>  

<cfquery name="HasFieldAppAccount" datasource="GSTS">
SELECT	TOP 1 	'External' AS ZScope,
				WebUsers.WebUserID AS ZPK,
				'Yellow/index.cfm?ZUserID=#URL.ZUserID#' AS ZDirect
FROM dbo.WebUsers
	LEFT JOIN dbo.WebUserAccounts ON WebUsers.WebUserAccountID = WebUserAccounts.WebUserAccountID
    CROSS JOIN flow.Users
WHERE Users.UserID = #Me.UserID#
  AND Users.UserEmail = WebUsers.EmailAddress
  AND WebUsers.StatusDefID = dbo.GetStatus('WebUsers','Active')
</cfquery>  

<cfquery name="HasWaterAppAccount" datasource="GSTS">
SELECT	TOP 1 	'External' AS ZScope,
				WebUsers.WebUserID AS ZPK,
				'Water/index.cfm?ZUserID=#URL.ZUserID#' AS ZDirect
FROM dbo.WebUsers
	LEFT JOIN dbo.WebUserAccounts ON WebUsers.WebUserAccountID = WebUserAccounts.WebUserAccountID
    CROSS JOIN flow.Users
WHERE Users.UserID = #Me.UserID#
  AND Users.UserID = 108
  AND Users.UserEmail = WebUsers.EmailAddress
  AND WebUsers.StatusDefID = dbo.GetStatus('WebUsers','Active')
</cfquery>  

<cfquery name="HasChromeAppAccount" datasource="GSTS">
SELECT	TOP 1 	'External' AS ZScope,
				WebUsers.WebUserID AS ZPK,
				'Chrome/index.cfm?ZUserID=#URL.ZUserID#' AS ZDirect
FROM dbo.WebUsers
	LEFT JOIN dbo.WebUserAccounts ON WebUsers.WebUserAccountID = WebUserAccounts.WebUserAccountID
    CROSS JOIN flow.Users
WHERE Users.UserID = #Me.UserID#
  AND Users.UserID = 110
  AND Users.UserEmail = WebUsers.EmailAddress
  AND WebUsers.StatusDefID = dbo.GetStatus('WebUsers','Active')
</cfquery>  
  
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!-- DW6 -->
<head>
<!-- Copyright 2005 Macromedia, Inc. All rights reserved. -->
<title><cfoutput>#Me.Desc1# Profile</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="mm_health_nutr.css" type="text/css" />

<script src="SpryAssets/SpryTabbedPanels.js" type="text/javascript"></script>
<script src="SpryAssets/SpryMenuBar.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	var Paint=null;
	function PaintFrame(VPage,VFrame,VKey)  {
		frames[VFrame].location.href=[VPage];
	  }
</script>  
<script language="javascript" type="text/javascript">
var win=null;
function NewWindow(mypage,myname,w,h,scroll,pos){
if(pos=="random"){LeftPosition=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;TopPosition=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;}
if(pos=="center"){LeftPosition=(screen.width)?(screen.width-w)/2:100;TopPosition=(screen.height)?(screen.height-h)/2:100;}
else if((pos!="center" && pos!="random") || pos==null){LeftPosition=0;TopPosition=20}
settings='width='+w+',height='+h+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',location=yes,directories=yes,status=yes,menubar=yes,toolbar=yes,resizable=yes';
win=window.open(mypage,myname,settings);}
// -->
</script>

<script>
  var gotoURL;

  function getLocation(myURL) {
    gotoURL = myURL;
    // Try sessionStorage first
    var cachedGeo = sessionStorage.getItem('geoData') || localStorage.getItem('geoData');
    if (cachedGeo) {
      try {
        var geoData = JSON.parse(cachedGeo);
        var currentTime = new Date().getTime();
        // Log cache check for debugging
        console.log('Checking cache: timestamp=' + geoData.timestamp + ', currentTime=' + currentTime);
        // Use cached coordinates if less than 5 minutes (300,000 ms)
        if (currentTime - geoData.timestamp < 300000) {
          console.log('Using cached coordinates: lat=' + geoData.latitude + ', lng=' + geoData.longitude);
          showPosition({
            coords: {
              latitude: geoData.latitude,
              longitude: geoData.longitude
            }
          });
          return;
        } else {
          console.log('Cache expired, requesting new location');
        }
      } catch (e) {
        console.error('Error parsing geoData: ', e);
      }
    }
    // Request new geolocation with maximumAge to allow cached results
    if (navigator.geolocation) {
      console.log('Requesting geolocation');
      navigator.geolocation.getCurrentPosition(showPosition, errorFunction, {
        maximumAge: 300000, // Allow cached location up to 5 minutes old
        timeout: 5000 // Timeout after 5 seconds
      });
    } else {
      alert('You need to share your location with a browser that supports sharing geolocation data in order to punch the time clocks.');
      location.reload();
    }
  }

  function showPosition(position) {
    // Cache the geolocation data in both sessionStorage and localStorage
    var geoData = {
      latitude: position.coords.latitude,
      longitude: position.coords.longitude,
      timestamp: new Date().getTime()
    };
    try {
      sessionStorage.setItem('geoData', JSON.stringify(geoData));
      localStorage.setItem('geoData', JSON.stringify(geoData)); // Fallback for Firefox
      console.log('Cached coordinates: lat=' + geoData.latitude + ', lng=' + geoData.longitude);
    } catch (e) {
      console.error('Error saving geoData: ', e);
    }
    // Redirect parent window with coordinates
    parent.location.href = gotoURL + '&latitude=' + position.coords.latitude + '&longitude=' + position.coords.longitude;
  }

  function errorFunction(error) {
    console.error('Geolocation error: ', error.message);
    alert('Unable to retrieve location: ' + error.message + '. Please ensure location services are enabled.');
    location.reload();
  }
</script>

<style type="text/css">
<!--
#MainDiv {
	position:absolute;
	left:17px;
	top:94px;
	width:949px;
	height:449px;
	z-index:1;
	background-color: #D5EDB3;
}
#HeaderDiv {
	position:absolute;
	left:2px;
	top:-1px;
	width:1008px;
	height:51px;
	z-index:2;
}
-->
</style>
<link href="SpryAssets/SpryTabbedPanels.css" rel="stylesheet" type="text/css" />
<style type="text/css">
.myLogoutBtn 
{
  border-radius:5px;
  background-color:#DDD;
  color:black;
  padding:5px 10px;
  border:solid 1px black;
  cursor:pointer;
}

.myLogoutBtn:hover 
{
  background-color:#999;
}
<!--
#apDiv1 {
	position:absolute;
	left:81px;
	top:176px;
	width:900px;
	height:30px;
	z-index:2;
}
.style4 {color: #FFFFFF}
.style7 {
	font-size: 18px;
	color: #FFFFFF;
}
#apDiv2 {
	position:absolute;
	width:200px;
	height:115px;
	z-index:1;
}
-->
</style>
<link href="SpryAssets/SpryMenuBarVertical.css" rel="stylesheet" type="text/css" />
<style type="text/css">
<!--
/* Fluid shell �?" replaces the legacy fixed absolute layout */
:root { --app-header-h: 47px; }

html, body {
	margin: 0;
	padding: 0;
	width: 100%;
	height: 100%;
	overflow-x: hidden;
	background: #f5f5f5;
}

.gsts-shell {
	display: flex;
	flex-direction: row;
	min-height: calc(100vh - var(--app-header-h));
	box-sizing: border-box;
}

#LeftNavWrap {
	flex: 0 0 138px;
	position: relative;
	background: #f5f5f5;
}

/* IDs kept (other pages/JS reference them) �?" positioning rewritten */
#ActionMenuDiv {
	position: absolute;
	left: 3px;
	top: 144px;
	width: 132px;
	z-index: 7;
}
#apDiv4 {
	position: absolute;
	left: 3px;
	top: 40px;
	width: 130px;
	height: 100px;
	z-index: 5;
}
#CenterContentDiv {
	position: relative;
	left: auto;
	top: 0;
	flex: 1 1 auto;
	width: auto;
	min-width: 0;
	height: auto;
	background: #ffffff;
	box-shadow: 0 0 0 1px #e3e3e3;
}
#ProfileBaseFrame {
	display: block;
	width: 100%;
	height: 100%;
	min-height: calc(100vh - var(--app-header-h));
	border: 0;
}

/* Customer Broadcast widget �?" pinned to the viewport's bottom-LEFT below
   the nav, where nothing else lives. Map legend sits in the map's top-right
   so the two no longer fight over the bottom-right corner. */
#apDiv5 {
	position: fixed;
	left: 16px;
	bottom: 16px;
	right: auto;
	top:   auto;
	width: 154px;
	height: 256px;
	z-index: 20;
}

/* Untouched legacy layers (utility widgets) */
#AdsDiv {
	position: absolute;
	left: 1152px;
	top: 34px;
	width: 74px;
	height: 729px;
	z-index: 8;
}
#apDiv3 {
	position: absolute;
	left: 27px;
	top: 700px;
	width: 258px;
	height: 56px;
	z-index: 8;
}

/* Header recolor 2026-05-22 �?" match Dashboard-CustomerLeads palette.
   #5C743D = dark green (matches topbar). #D5EDB3 = light-green accent.
   !important is used to override the inline style="background-color:#D5EDB3"
   on the legacy MenuBarVertical markup. */
#ActionBar { background: #5C743D !important; }
#ActionBar > li,
#ActionBar > li > a.MenuBarItem,
#ActionBar > li > a.MenuBarItemSubmenu {
    background-color: #5C743D !important;
    color: #fff !important;
}
#ActionBar > li > a.MenuBarItem:hover,
#ActionBar > li > a.MenuBarItemSubmenu:hover,
#ActionBar > li > a.MenuBarItemSubmenuHover {
    background-color: #2a4a18 !important;
    color: #D5EDB3 !important;
}
/* Sub-items (the dropdown panels) keep the light-green accent like the
   Dashboard's badges/hover rows. */
#ActionBar ul li a {
    background-color: #D5EDB3 !important;
    color: #2a4a18 !important;
}
#ActionBar ul li a:hover {
    background-color: #5C743D !important;
    color: #fff !important;
}
-->
</style>
<script>
function resize(which, max) {
  var elem = document.getElementById(which);
  if (elem == undefined || elem == null) return false;
  var maxwidth = 130;
  var maxheight = 100;
  if (elem.width > elem.height) {
    if (elem.width > maxwidth) {
		elem.height = elem.height * (elem.width/130)
		elem.width = maxwidth;
		}
  } else {
    if (elem.height > maxheight) {
		elem.width = elem.width * (elem.height/100)
		elem.height = maxheight;
		}
  }
}

	function evalReferrer() {
		<cfif IsDefined("Cookie.ZUserID") is "False">
			parent.location.href="System.Login.cfm";
		<cfelse>
			return false;
		</cfif>
	}

</script>
</head>
<body onLoad="evalReferrer();">


<!---TempOut Exchange Upgrade

<cfpop 
        	server = "green.gstsinc.com" 
            username = "trimit@gstsinc.com" 
            password = "gsts2020"
        	action = "getall"
            name = "GetHeaders">
--->



<!---<div id="apDiv3" style="border:none"><table border="0">
  <tr>
    <td align="center" bgcolor="#99FFCC" class="subHeader style11">O&A</td>
  </tr>
  <tr>
    <td align="center"><cfoutput><span class="style10">#CurrentWeekDef.OAPerc#%</span></cfoutput></td>
  </tr>
</table>
</div>--->




<table width="100%" border="0">
  <tr>
    <td bgcolor="#5C743D">
      <table width="100%" border="0">
        <tr>
          <td width="109" class="style7" style="padding-left: 8px;"><span>Trim</span><span style="color:#d5edb3">IT</span></td>
          <td width="33">&nbsp;</td>
          <td width="42">&nbsp;</td>
          <td width="25">&nbsp;</td>
          <td width="55">&nbsp;</td>
          <!---<td colspan="3" width="247"><cfoutput><span class="style4">#Me.Desc1#<BR />#Cookie.CurrentUserRoles#/#isUserInRole("adminmunicipal")#/#GetUserRoles()#/#GetAuthUser()#</span></cfoutput></td>--->
          <td colspan="3" width="247"><cfoutput><span class="style4">#Me.Desc1#<BR />#GetUserRoles()#</span></cfoutput></td>
          <cfif 1 EQ 0><td><cfif #Me.IsPayrollItem# EQ 1><iframe name="ProfileTimeClockFrame" frameborder="0" height="25"  width="700" id="ProfileTimeClockFrame" scrolling="no" src="Profile$TimeClock.cfm?ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>"></iframe><cfelse>&nbsp;</cfif>  </td></cfif>

<td width="90" style="padding-right: 8px;">
<cfif Me.IsPayrollItem EQ 1>
  <button type="button" class="btn btn-success myLogoutBtn" onclick="window.open('/gsts/Mobile2/Profile$TimeClock.cfm?ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>&ZFromForm=LoginForm', '_blank')">Time Clock</button>
</cfif>
</td>

<td width="38" style="padding-right: 8px;">

		<button type="button" class="btn btn-success myLogoutBtn" onclick="location.href='/logout.cfm'">Logout</button>
	  </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

<div class="gsts-shell">
<div id="LeftNavWrap">

<div id="ActionMenuDiv"<cfif Me.ProfilePicturePath EQ "art/profilepictures/TrimITLogo.png"> style="top: 47px;"</cfif>>
  <ul id="ActionBar" class="MenuBarVertical"  style="background-color:#D5EDB3">
	<li style="background-color:#D5EDB3"><a href="Overview/Quick$Base$WithList.cfm?ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="ProfileBaseFrame" >My Queue (<cfoutput>#Me.VQueueItems#</cfoutput>)</a> </li>  

	<cfinclude template="dashboard-access-check.cfm"><!--- sets request.dashOK from the SAME access list the page gate uses → link shows only for authorized users, like the other menus --->
	<cfif request.dashOK>
	<li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Dashboards</a>
      <ul>
        <li><a href="Dashboard-RevenuePerformance.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank" rel="noopener">Revenue Performance</a></li>
        <li><a href="Dashboard-ProductionPerf.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank" rel="noopener">Production Performance</a></li>
        <li><a href="Dashboard-CrewPerformance.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank" rel="noopener">Crew Performance</a></li>
        <li><a href="Dashboard-SalesCockpit.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank" rel="noopener">Sales Cockpit</a></li>
        <li><a href="SalesProductionMeetingDashboard.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank" rel="noopener">Sales Production Meeting</a></li>
        <li><a href="Dashboard-CityBudgets.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank" rel="noopener">City Budgets &amp; Forecast</a></li>
        <li><a href="Executive$Financial$Overview$Frame.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank" rel="noopener">Sales Performance</a></li>
        <cfif listFind("9,3", val(Cookie.ZUserID))><li><a href="Dashboard-Access.cfm" class="MenuBarItem navText" style="background-color:#D5EDB3;border-top:1px solid #7f9a52;font-style:italic" target="_blank" rel="noopener">Manage Access&hellip;</a></li></cfif>
      </ul>
  </li>
	</cfif>

	<cfif #Sec.ProductionLevel# GT 2>
	<li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Day Lists</a>
      <ul>
       	<li><a href="ReportDev/Report$Production$DayList.cfr?ZCalendarID=<cfoutput>#DayBeforeCalendar.CalendarID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="ProfileBaseFrame" >Day Before Yesterday</a></li>
        <li><a href="ReportDev/Report$Production$DayList.cfr?ZCalendarID=<cfoutput>#YesterdayCalendar.CalendarID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="ProfileBaseFrame" >Yesterday</a></li>
		<li><a href="ReportDev/Report$Production$DayList.cfr?ZCalendarID=<cfoutput>#CurrentCalendar.CalendarID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="ProfileBaseFrame" >Today</a></li>
    	<li><a href="ReportDev/Report$Production$DayList.cfr?ZCalendarID=<cfoutput>#TomorrowCalendar.CalendarID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="ProfileBaseFrame" >Tomorrow</a></li>
	    <li><a href="ReportDev/Report$Production$DayList.cfr?ZCalendarID=<cfoutput>#NextDayCalendar.CalendarID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="ProfileBaseFrame" >Next Day</a></li>
      </ul>
  </li>

    </cfif>  
    



  <cfif #Sec.FindLevel# GT 2>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Customers</a>
      <ul>
        <cfif #Sec.FindLevel# GT 2><li><a href="Profile.Companies.Focus.cfm" class="navText"  target="ProfileBaseFrame">Companies</a></li></cfif>
        <cfif #Sec.QualifyLevel# GT 2><li><a href="Profile.Projects.Focus.Mini.cfm" target="ProfileBaseFrame" class="navText">Projects</a></li></cfif>
         <cfif #Sec.QualifyLevel# GT 2><li><a href="Profile.System-Wide.RFPs.Focus.Mini.cfm" target="ProfileBaseFrame" class="navText">RFPs</a></li></cfif>
        <cfif #Sec.FindLevel# GT 4><li><a href="Profile.Contacts.Focus.cfm" class="navText"  target="ProfileBaseFrame">Contacts</a></li></cfif>        
        <cfif #Sec.ProductionLevel# GT 2><li><a href="Profile.Companies.Top.Content.cfm" target="ProfileBaseFrame" class="navText">Top 200</a></li></cfif>
         <cfif #Sec.QualifyLevel# GT 2><li><a href="Profile.Contracts.Content.cfm" target="ProfileBaseFrame" class="navText">Active Contracts</a></li></cfif>
         <li><a href="Profile.Proposals.Focus.Mini.cfm" target="ProfileBaseFrame" class="navText">Proposal Search</a></li>
      </ul>
  </li>
  </cfif>

<li style="background-color:#D5EDB3">&nbsp;
  </li>  
  
   <cfif #Sec.FindLevel# GT 3>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Find</a>
      <ul>
        <cfoutput query="MyFindItems"><li><a href="#MyFindItems.ObjectPath#" target="#MyFindItems.TargetDesc1#" class="navText">#MyFindItems.Desc1#</a></li>
      </cfoutput>
        <li><a href="Dashboard-CustomerLeads.cfm" target="_top" class="navText">Customer Leads Dashboard</a></li>
      </ul>
  </li>
  </cfif>
  
   <cfif #Sec.SolveLevel# GT 3 AND #MySolveItems.RecordCount# GT 0>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Solve</a>
      <ul>
        <cfoutput query="MySolveItems"><li><a href="#MySolveItems.ObjectPath#" target="#MySolveItems.TargetDesc1#" class="navText">#MySolveItems.Desc1#</a></li>
      </cfoutput>

      </ul>
  </li>
  </cfif>
  
   <cfif #Sec.CloseLevel# GT 2 AND #MyCloseItems.RecordCount# GT 0>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Close</a>
      <ul>
        <cfoutput query="MyCloseItems"><li><a href="#MyCloseItems.ObjectPath#" target="#MyCloseItems.TargetDesc1#" class="navText">#MyCloseItems.Desc1#</a></li>
      </cfoutput>

      </ul>
  </li>
  </cfif>

   <cfif #Sec.ProductionLevel# GT 2 AND #MyProductionItems.RecordCount# GT 0>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Production</a>
      <ul>
        <cfoutput query="MyProductionItems"><li><a href="#MyProductionItems.ObjectPath#" target="#MyProductionItems.TargetDesc1#" class="navText">#MyProductionItems.Desc1#</a></li>
      </cfoutput>

      </ul>
  </li>
  </cfif>

  <cfif #Sec.BillingLevel# GT 2 AND #MyBillingItems.RecordCount# GT 0>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Billing</a>
      <ul>
        <cfoutput query="MyBillingItems"><li><a href="#MyBillingItems.ObjectPath#" target="#MyBillingItems.TargetDesc1#" class="navText">#MyBillingItems.Desc1#</a></li>
      </cfoutput>

      </ul>
  </li>
  </cfif>

  <cfif #Sec.FleetLevel# GT 2 AND #MyFleetItems.RecordCount# GT 0>
  <li>
  	<a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Fleet</a>
     <ul>
        <cfoutput query="MyFleetItems">
        	<li>
            	<a href="#MyFleetItems.ObjectPath#" target="#MyFleetItems.TargetDesc1#" class="navText">#MyFleetItems.Desc1#</a>
        	</li>
		</cfoutput>
        	<!---<li>
				<a href="Fleet$Schedule$User.cfm?ZCalendarID=<cfoutput>#CurrentCalendar.CalendarID#</cfoutput>&amp;ZUserID=<cfoutput>#Cookie.ZUserID#</cfoutput>" class="navText" target="ProfileBaseFrame" >My Repair Schedule</a>
            </li>--->

      </ul>
  </li>
  </cfif>
  
   <cfif (#Sec.HRLevel# GT 4 AND #MyHRItems.RecordCount# GT 0) OR NavCommissionAccess>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">HR</a>
      <ul>
        <cfif #Sec.HRLevel# GT 4>
          <cfoutput query="MyHRItems">
          	<li>
              	<a href="#MyHRItems.ObjectPath#" target="#MyHRItems.TargetDesc1#" class="navText">#MyHRItems.Desc1#</a>
          	</li>
  		</cfoutput>
        </cfif>
        <cfif NavCommissionAccess>
          <li>
            <a href="/gsts/SaleRepCommissionDashboard.cfm?ZUserID=<cfoutput>#URL.ZUserID#</cfoutput>" target="_blank" class="navText">Sales Rep Commission Report</a>
          </li>
        </cfif>
      </ul>
  </li>
  </cfif>
  
   <cfif #MyITItems.RecordCount# GT 0>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">IT</a>
      <ul>
        <cfoutput query="MyITItems">
        	<li>
            	<a href="#MyITItems.ObjectPath#" target="#MyITItems.TargetDesc1#" class="navText">#MyITItems.Desc1#</a>
        	</li>
		</cfoutput>
      </ul>
  </li>
  </cfif>

  
  
  <li><a href="#" class="navText MenuBarItemSubmenu"  style="background-color:#D5EDB3">Reports</a>
    <ul>
      <cfoutput query="MyReports">
      <!---<li><a href="#MyReports.ObjectPath#" target="#MyReports.TargetDesc1#" class="navText">#MyReports.Desc1#</a></li>--->
      <li><a onClick="javascript:OpenPage('#replace(MyReports.Desc1, "'", "\'", "All")#','#MyReports.ObjectPath#','#MyReports.TargetDesc1#',#MyReports.AppFormID#,#MyReports.UserID#,'#MyReports.FormType#','#MyReports.TableName#')" class="navText">#MyReports.Desc1#</a></li>
      </cfoutput>
    </ul>
    <!--- <li><a onClick="javascript:OpenPage('#MyReports.ObjectPath#','#MyReports.TargetDesc1#',#MyReports.AppFormID#,#MyReports.UserID#,'#MyReports.FormType#','#MyReports.TableName#')" class="navText">#MyReports.Desc1#</a></li>--->
    <!---<cfif #URL.ZUserID# eq 115>
      <li>
      <a onClick="javascript:OpenPage('ProjectsTPHReport.cfm','ProfileBaseFrame',1156,115,'Report','AppForms')" class="navText"><cfoutput>#URL.ZUserID#</cfoutput>test Report</a>
       </li>
	</cfif>--->
  </li>
  
   <cfif #Sec.ExecutiveLevel# GT 2>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Executive</a>
      <ul>
        <cfoutput query="MyExecutiveItems"><li><a href="#MyExecutiveItems.ObjectPath#" target="#MyExecutiveItems.TargetDesc1#" class="navText">#MyExecutiveItems.Desc1#</a></li>
      </cfoutput>

      </ul>
  </li>
  </cfif>
  
   <cfif #Sec.MaintenanceLevel# GT 1>
  <li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Maintenance</a>
      <ul>
        <cfoutput query="MyMaintenanceItems"><li><a href="#MyMaintenanceItems.ObjectPath#" target="#MyMaintenanceItems.TargetDesc1#" class="navText">#MyMaintenanceItems.Desc1#</a></li>
      </cfoutput>

      </ul>
  </li>
  </cfif>
  <cfif #HasWebUserAccount.ZPK# NEQ ''>
      <li>
      	<a href="<cfoutput>#HasWebUserAccount.ZDirect#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="WebPortalWindow">Web Portal</a>
        
  </li>
  </cfif>
  
  <cfif #HasFieldAppAccount.ZPK# NEQ ''>
      <li>
      	<a href="<cfoutput>#HasFieldAppAccount.ZDirect#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="FieldAppWindow">Field App</a>
        
  </li>

      <li><a href="/gsts/FieldApp/index.cfm?ZUserID=<cfoutput>#URL.ZUserID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="FieldAppWindow">Field App (BETA)</a></li>

  </cfif>

  <cfif TimeAttendancePerm.RecordCount GT 0 AND TimeAttendancePerm.IsAllowed EQ 1>
  <li><a href="/gsts/TimeAttendanceDashboard.cfm?ZUserID=<cfoutput>#URL.ZUserID#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="_blank">Time &amp; Attendance</a></li>
  </cfif>
  
   <cfif #MyGroupTextItems.RecordCount# GT 0>
  	<li><a href="#" class="MenuBarItemSubmenu navText" style="background-color:#D5EDB3">Group Text</a>
      <ul>
        <cfoutput query="MyGroupTextItems"><li><a href="#MyGroupTextItems.ObjectPath#?UserID=#URL.ZUserID#" target="_blank" class="navText">#MyGroupTextItems.Desc1#</a></li>
      </cfoutput>
      </ul>
 	</li>
  </cfif>

  <cfif #MyGroupTextItems.RecordCount# GT 0>
  	<li><a href="http://greatscotttreecare.net/Account/LogInConnection?loginTrimitUserID=<cfoutput>#URL.ZUserID#</cfoutput>" target="_blank" class="MenuBarItem navText" style="background-color:#D5EDB3">Base App</a></li>
  </cfif>

  
  
  <cfif #HasWaterAppAccount.ZPK# NEQ ''>
      <li>
      	<a href="<cfoutput>#HasWaterAppAccount.ZDirect#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="FieldAppWindow">Watering App</a>
        
  </li>
  </cfif>
  
  <cfif #HasChromeAppAccount.ZPK# NEQ ''>
      <li>
      	<a href="<cfoutput>#HasChromeAppAccount.ZDirect#</cfoutput>" class="MenuBarItem navText" style="background-color:#D5EDB3" target="FieldAppWindow">Vacant Site App</a>
        
  </li>
  </cfif>

</ul>
 
</div>

<cfif Me.ProfilePicturePath NEQ "art/profilepictures/TrimITLogo.png">
  <div id="apDiv4"><img id="ProfileImage" onload="resize('ProfileImage')" src="<cfoutput>#Me.ProfilePicturePath#</cfoutput>" width="130" height="100" /></div>
</cfif>

</div><!-- /#LeftNavWrap -->

<div id="CenterContentDiv">
<iframe name="ProfileBaseFrame" frameborder="0" id="ProfileBaseFrame" scrolling="auto" src="Overview/Quick$Base$WithList.cfm?ZUserID=<cfoutput>#URL.ZUserID#</cfoutput>&ZCalendarID=<cfoutput>#CurrentCalendar.CalendarID#</cfoutput>"></iframe></div>

</div><!-- /.gsts-shell -->

<div id="apDiv5">
<iframe name="ProfileWidgetsFrame" frameborder="0" allowtransparency="true" id="ProfileWidgetsFrame" scrolling="no" src="Maint-Customer-Broadcast.cfm" style="width:100%;height:100%;border:0;"></iframe></div>



<script type="text/javascript">
<!--
var MenuBar1 = new Spry.Widget.MenuBar("ActionBar", {imgRight:"SpryAssets/SpryMenuBarRightHover.gif"});
//-->
function OpenPage(desc1,objectPath,targetDesc1,appFormID,userID,formType,tableName)
{ 
	var Desc1  = desc1
    var SourceName  = formType
    var LogMessage  = 'View Count'
    var SourceID  = 0
    var TableName  = tableName
    var TableID  = 0
	var TableRowID = appFormID
    var OldValue  = ''
    var NewValue  = ''
    var LastModByUserID  = userID
    var LastModByUserName = ''
	
	$.ajax({
		  url: "cfc/AppLogs.cfc"
		  , type: "post"
		  , dataType: "json"
		  , async:false
		  , data: {
		  	method: "SaveAppLogs"
			, zDesc1: Desc1
			, zSourceName: SourceName
			, zLogMessage: LogMessage
			, zSourceID: SourceID
			, zTableName: TableName
			, zTableID: TableID
			, zTableRowID: TableRowID
			, zOldValue: OldValue
			, zNewValue: NewValue
			, zLastModByUserID: LastModByUserID
			, zLastModByUserName: LastModByUserName
			, returnFormat: "JSON"
			}
		  , success: function (data){
		  }
		  , error: function (xhr, textStatus, errorThrown){
			  alert("Fail to insert into AppLogs Table");
		  }
		});
		
	var newWindow = window.open(objectPath, targetDesc1);
	newWindow.focus();
	return false;
}


</script>



<div style="visibility:hidden">
<iframe name="SynchCodeFrame" id="SynchCodeFrame" width="1" height="1"></iframe>
<cfif #Me.IsSoundOn# EQ 1>
<iframe name="MainSoundFrame" id="MainSoundFrame" width="1" height="1" src="Audio/Sound$Check$New$RFPAction.cfm?ZUserID=<cfoutput>#URL.ZUserID#</cfoutput>"></iframe>
<cfelse>
<iframe name="MainSoundFrame" id="MainSoundFrame" width="1" height="1"></iframe>
</cfif>
</div>
</body>
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
</html>

