:::: Offerings Parsing Tool ::::::::::::::::::::::::::::::::::::

::#############################################################################
::							#DESCRIPTION#
::
::	
::	
::#############################################################################

:::: Developer ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: GitHub :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	https://github.com/The-Evergreen-State-College/Offerings
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: License ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL v3 (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: Versioning Schema ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::		VERSIONING INFORMATION												 ::
::		Semantic Versioning used											 ::
::		http://semver.org/													 ::
::		Major.Minor.Revision												 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::: Command shell ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
@SETLOCAL enableextensions
SET $PROGRAM_NAME=Offerings-Parsing-Tool
SET $Version=0.4.0
SET $BUILD=2023-10-30 1300
Title %$PROGRAM_NAME%
Prompt OPT$G
color 8F
mode con:cols=90 lines=50
echo %$PROGRAM_NAME%
echo Version: %$Version%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables [Defaults]
::###########################################################################::

	
:: Directories
::	Program Directory
::	default shuold be %~dp0 where the program was executed from
SET "$DIRECTORY_PROJECT=%~dp0"

:: Log file
SET $LOG_FILE=Offerings.log

:: Adminweb Web URI to fetch export
SET "$URI_ADMINWEB=https://adminweb.evergreen.edu/banner/public/offerings/export"
::	Adminweb xml export file
SET $ADMINWEB_OFFERINGS_EXPORT_FILE=adminweb_Offering_export.xml

:: XMLStarlet Tool
::	https://xmlstar.sourceforge.net/
:: PATH to exe
SET $PATH_XML=.\bin

:::: Configuration - Advanced :::::::::::::::::::::::::::::::::::::::::::::::::
:: Advanced Settings

:: LOGGING LEVEL CONTROL
::  by default, ALL=0 & TRACE=0
::	Debug mode will turn on ALL logging
SET $LOG_LEVEL_ALL=0
SET $LOG_LEVEL_INFO=1
SET $LOG_LEVEL_WARN=1
SET $LOG_LEVEL_ERROR=1
SET $LOG_LEVEL_FATAL=1
SET $LOG_LEVEL_DEBUG=0
SET $LOG_LEVEL_TRACE=0

:: Debug Mode
:: {0 [Off/No] , 1 [On/Yes]}
SET $DEBUG_MODE=0

:: Nuke logs
:: {0 [Off/No] , 1 [On/Yes]}
SET $NUKE_LOGS=0

:: To cleanup or Not to cleanup, cache folder
::  0 = OFF (NO)
::  1 = ON (YES)
SET $NUKE_CACHE=0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::#############################################################################
::	!!!!	Everything below here is 'hard-coded' [DO NOT MODIFY]	!!!!
::#############################################################################

:::: Start Time Start Date	:::::::::::::::::::::::::::::::::::::::::::::::::::
SET $START_TIME=%Time%
SET $START_DATE=%Date%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: PATH for XMLStarlet
::	append to existing path
SET PATH=%PATH%;%$PATH_XML%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Change directory to the project, based on execution location
CD /D %$DIRECTORY_PROJECT%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check for directory structure
::	Inspired by R-Package "Project"
IF NOT EXIST ".\cache\" MD ".\cache\"
IF NOT EXIST ".\data\index" MD ".\data\index"
IF NOT EXIST ".\data\xml" MD ".\data\xml"
IF NOT EXIST ".\logs" MD ".\logs"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:fISO8601
:: Function to ensure ISO 8601 Date format yyyy-mmm-dd
:: Easiest way to get ISO date
@powershell Get-Date -format "yyyy-MM-dd"> ".\cache\var_ISO8601_Date.txt"
SET /P $ISO_DATE= < ".\cache\var_ISO8601_Date.txt"
@powershell Get-Date -format "HHmm"> ".\cache\var_time.txt"
SET /P $TIME= < ".\cache\var_time.txt"
:: Time zone
IF EXIST ".\cache\TimeZone.txt" GoTo skipTZ
@powershell Get-TimeZone> ".\cache\TimeZone.txt"
:skipTZ
FOR /F "skip=2 tokens=2 delims=:" %%P IN ('FIND /I "Id" ".\cache\TimeZone.txt"') DO echo %%P> ".\cache\var_timezone_Id.txt"
SET /P $TIMEZONE_ID= < ".\cache\var_timezone_Id.txt"
FOR /F "tokens=2 delims=:" %%P IN ('FIND /I "BaseUtcOffset" ".\cache\TimeZone.txt"') DO echo %%P> ".\cache\var_timezone_UTC.txt"
SET /P $TIMEZONE_UTC= < ".\cache\var_timezone_UTC.txt"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: DEBUG MODE :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF %$DEBUG_MODE% EQU 0 GoTo skipDM
IF %$DEBUG_MODE% EQU 1 ECHO %TIME% [INFO]	Debug Mode is turned on! >> .\logs\%$LOG_FILE%
IF %$DEBUG_MODE% EQU 1 (SET $LOG_LEVEL_ALL=1) & (SET $NUKE_CACHE=0) & (SET $NUKE_LOGS=0)
IF %$DEBUG_MODE% EQU 1 ECHO %TIME% [DEBUG]	VARIABLE: LOG_LEVEL_ALL: {%$LOG_LEVEL_ALL%} >> .\logs\%$LOG_FILE%
:skipDM
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Log level configuration
IF %$LOG_LEVEL_ALL% EQU 1 (
	SET $LOG_LEVEL_INFO=1
	SET $LOG_LEVEL_WARN=1
	SET $LOG_LEVEL_ERROR=1
	SET $LOG_LEVEL_FATAL=1
	SET $LOG_LEVEL_DEBUG=1
	SET $LOG_LEVEL_TRACE=1
	)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: Start Logging	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Start
echo. >> .\logs\%$LOG_FILE%
IF %$LOG_LEVEL_INFO% EQU 1 Echo %$ISO_DATE%	%Time%	[INFO]	Start... >> .\logs\%$LOG_FILE%
IF %$LOG_LEVEL_INFO% EQU 1 echo %Time%	[INFO]	TimeZone Id: %$TIMEZONE_ID% [UTC:%$TIMEZONE_UTC%] >> .\logs\%$LOG_FILE%
IF %$LOG_LEVEL_INFO% EQU 1 Echo %Time%	[INFO]	%$PROGRAM_NAME% %$Version% >> .\logs\%$LOG_FILE%
IF %$LOG_LEVEL_DEBUG% EQU 1 echo %Time%	[DEBUG]	Build: %$BUILD% >> .\logs\%$LOG_FILE%
IF %$LOG_LEVEL_INFO% EQU 1 echo %Time%	[INFO]	Program Path: %$DIRECTORY_PROJECT% >> .\logs\%$LOG_FILE%
IF %$LOG_LEVEL_INFO% EQU 1 echo %Time%	[INFO]	User: %USERNAME% >> .\logs\%$LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check for XMLStartlet
xml --version > .\cache\xmlstartlet-version.txt
SET $ERROR_XML=%ERRORLEVEL%
IF %$ERROR_XML% NEQ 0 (
	IF %$LOG_LEVEL_ERROR% EQU 1 echo %Time%	[ERROR]	XMLSTARTLET command failed! >> .\logs\%$LOG_FILE%
	IF %$LOG_LEVEL_INFO% EQU 1 echo %Time%	[INFO]	Check for .\bin\xml.exe >> .\logs\%$LOG_FILE%
	IF %$LOG_LEVEL_INFO% EQU 1 echo %Time%	[INFO]	Check for PATH includes .\bin\ >> .\logs\%$LOG_FILE%
	GoTo skipXMLS
	)
IF %$LOG_LEVEL_DEBUG% EQU 1 echo %Time%	[DEBUG]	XMLSTARTLET Check: {%$ERROR_XML%} >> .\logs\%$LOG_FILE%
FINDSTR /R /C:"[0-9].[0-9].[0-9]" .\cache\xmlstartlet-version.txt 2> nul 1> nul && SET /P $XMLSTARTLET_VERSION= < .\cache\xmlstartlet-version.txt
IF DEFINED $XMLSTARTLET_VERSION IF %$LOG_LEVEL_INFO% EQU 1 echo %time%	[INFO]	XMLStartlet Version: %$XMLSTARTLET_VERSION% >> .\logs\%$LOG_FILE%
:skipXMLS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: archive XML
IF EXIST ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%.old" DEL /F /Q ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%.old"
IF EXIST ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" Rename ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" %$ADMINWEB_OFFERINGS_EXPORT_FILE%.old
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Retrieve XML feed
wget --tries=2 --connect-timeout=10 --waitretry=5 --no-check-certificate "%$URI_ADMINWEB%" --output-document=.\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%
SET $ERROR_WGET=%ERRORLEVEL%
IF %$LOG_LEVEL_DEBUG% EQU 1 echo %Time%	[DEBUG]	WGET error: %$ERROR_WGET% >> .\logs\%$LOG_FILE%
echo Retrieve offerings XML file error: %$ERROR_WGET%
IF %$ERROR_WGET% NEQ 0 (
	@powershell Write-Host "Failed to retrieve latest xml, information may not be up to date!" -ForegroundColor DarkRed
	timeout /t 5
	FIND "offerings" ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" 2>nul 1> nul || GoTo Exit
	)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Validate XML
:: Validating XML file
xml val -e .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > .\cache\xmlstartlet-XML-Validation.txt
SET $XML_VALIDATION=%ERRORLEVEL%
IF %$LOG_LEVEL_DEBUG% EQU 1 echo %Time%	[DEBUG]	Variable: $XML_VALIDATION: {%$XML_VALIDATION%} >> .\logs\%$LOG_FILE%
IF %$XML_VALIDATION% NEQ 0 (
	IF %$LOG_LEVEL_ERROR% EQU 1 echo %Time%	[ERROR]	XML {%$ADMINWEB_OFFERINGS_EXPORT_FILE%} export feed is invalid! >> .\logs\%$LOG_FILE%
	echo XML export feed is invalid!
	echo Aborting!
	GoTo exit)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check for change
COMP ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%.old" ".\data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" /M > ".\cache\Compare_XML_Feed.txt"
(FIND "Files compare OK" ".\cache\Compare_XML_Feed.txt" 2> nul) & (SET $FLAG_XML_COMP=%ERRORLEVEL%)
IF %$FLAG_XML_COMP% EQU 1 echo Delta change to XML Offerings!
IF %$FLAG_XML_COMP% EQU 1 IF %$LOG_LEVEL_INFO% EQU 1 echo %time%	[INFO]	Delta change to XML Offerings! >> .\logs\%$LOG_FILE%
IF %$FLAG_XML_COMP% EQU 0 (
	IF %$LOG_LEVEL_INFO% EQU 1 echo %time%	[INFO]	No delta change to XML Offerings. Nothing to do, exiting. >> .\logs\%$LOG_FILE%
	@powershell Write-Host "No change in XML feed, nothing to do, exiting..." -ForegroundColor Green
	timeout /t 5
	GoTo Exit)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get Count of offerings in export
xml.exe sel -t -v "count(/offerings/offering/title)" .\data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\cache\offerings_count.txt
SET /P $OFFERINGS_TOTAL_COUNT= < .\cache\offerings_count.txt
IF %$LOG_LEVEL_INFO% EQU 1 echo %time%	[INFO]	Offerings Total Count: %$OFFERINGS_TOTAL_COUNT% >> .\logs\%$LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Fall back for some config files
::	Asumes Quarters are a constant
IF EXIST ".\Config\Quarters.txt" GoTo skipQ
echo Fall> ".\Config\Quarters.txt"
echo Winter>> ".\Config\Quarters.txt"
echo Spring>> ".\Config\Quarters.txt"
echo Summer>> ".\Config\Quarters.txt"
:skipQ
:: Assumes term codes are constant
::	as value pair
IF EXIST ".\Config\Quarters_Code.txt" GoTo skipQCFB
echo Fall=10> ".\Config\Quarters_Code.txt"
echo Winter=20>> ".\Config\Quarters_Code.txt"
echo Spring=30>> ".\Config\Quarters_Code.txt"
echo Summer=40>> ".\Config\Quarters_Code.txt"
:skipQCFB
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get Year
xml sel -T -t -m //offering[@status='Confirmed'] -s A:N:U @year -v @year  -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > .\cache\offerings_year.txt
SET /P $OFFERING_YEAR= < .\cache\offerings_year.txt
IF %$LOG_LEVEL_INFO% EQU 1 echo %time%	[INFO]	Offering Year: %$OFFERING_YEAR% >> .\logs\%$LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get Cancelled Offerings
xml sel -t -m //offering[@status='Cancelled'] -v "concat(@id, '|', @status, '|', title)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > .\Data\%$OFFERING_YEAR%-Offerings-Cancelled.txt
:: Get number of cancelled
xml sel -t -v "count(//offering[@status='Cancelled'])" .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\cache\offerings_cancelled_total.txt
SET /P $OFFERINGS_CANCELLED_TOTAL= < .\cache\offerings_cancelled_total.txt
IF %$LOG_LEVEL_INFO% EQU 1 echo %time%	[INFO]	Offerings cancelled total: %$OFFERINGS_CANCELLED_TOTAL% >> .\logs\%$LOG_FILE%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get unfiltered list of offerings
::	Complete
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U title -v "concat(title, '|', @offering_type, '|', @curr_area, '|', @liaison_area, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\Data\Complete-Offerings-Listing-Confirmed.txt
:: total confirmed
xml sel -t -v "count(//offering[@status='Confirmed'])" .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\data\Offerings-Confirmed-total.txt
SET /P $OFFERINGS_CONFIRMED_TOTAL= < .\data\Offerings-Confirmed-total.txt
IF %$LOG_LEVEL_INFO% EQU 1 echo %time%	[INFO]	Offerings confirmed total: %$OFFERINGS_CONFIRMED_TOTAL% >> .\logs\%$LOG_FILE%
:: Fall, Complete, Confirmed
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U title --if "terms/term[@code='%$OFFERING_YEAR%10']" -v "concat(title, '|', @offering_type, '|', @curr_area, '|', @liaison_area, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\Data\%$OFFERING_YEAR%-Offerings-Fall-Confirmed-Listing.txt
:: Winter, Complete, Confirmed
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U title --if "terms/term[@code='%$OFFERING_YEAR%20']" -v "concat(title, '|', @offering_type, '|', @curr_area, '|', @liaison_area, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\Data\%$OFFERING_YEAR%-Offerings-Winter-Confirmed-Listing.txt
:: Spring, Complete, Confirmed
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U title --if "terms/term[@code='%$OFFERING_YEAR%30']" -v "concat(title, '|', @offering_type, '|', @curr_area, '|', @liaison_area, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\Data\%$OFFERING_YEAR%-Offerings-Spring-Confirmed-Listing.txt
:: Summer, Complete, Confirmed
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U title --if "terms/term[@code='%$OFFERING_YEAR%40']" -v "concat(title, '|', @offering_type, '|', @curr_area, '|', @liaison_area, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\Data\%$OFFERING_YEAR%-Offerings-Summer-Confirmed-Listing.txt

:: Get Offerings by Liaison_area
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U @curr_area -s A:T:U @liaison_area -v "concat(@curr_area, '|', @liaison_area, '|', @id, '|', title, '|', @year)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > .\Data\%$OFFERING_YEAR%-Complete-Offerings_by_area.txt
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get Offerings that are Confirmed build index
::xml sel -t -c //offering[@status='Confirmed'] -m offerings/offering/oars_offerings/oars_offering -v @code -o "|" -m "//offering" -v "concat(@id, '|' ,@status, '|', @year, '|', @offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m "faculties/faculty" -v "@display_name" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > .\Data\Offerings_Parsed.txt

:: Future code, but not working
::	in order for this work, it would have to call a function that takes parameters {quarter, quarter_code}.
:: SET would need to be outside the FOR loop to work properly
::IF "%1"=="Fall" SET $TERM_CODE=10
::IF "%1"=="Winter" SET $TERM_CODE=20
::IF "%1"=="Spring" SET $TERM_CODE=30
::IF "%1"=="Summer" SET $TERM_CODE=40
::FOR /F "tokens=1 delims=" %%P IN (.\Config\Quarters.txt) DO (
::xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%%$TERM_CODE%']" -v @id -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > ".\Data\index\%$OFFERING_YEAR%-%%P-ID-Index.txt")

:: Fall
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MIT'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%10']" -v @id -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > ".\Data\index\%$OFFERING_YEAR%-Fall-ID-Index.txt"

:: Winter
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MIT'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%20']" -v @id -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > ".\Data\index\%$OFFERING_YEAR%-Winter-ID-Index.txt"

:: Spring
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MIT'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%30']" -v @id -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > ".\Data\index\%$OFFERING_YEAR%-Spring-ID-Index.txt"

:: Summer
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MIT'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%40']" -v @id -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > ".\Data\index\%$OFFERING_YEAR%-Summer-ID-Index.txt"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Using Quarter index on Id's, parse xml for offerings by Quarter 
:: Fall
IF EXIST ".\Data\%$OFFERING_YEAR%-Fall-Offerings-Parsed.txt" DEL /F /Q ".\Data\%$OFFERING_YEAR%-Fall-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Fall-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%  >> .\Data\%$OFFERING_YEAR%-Fall-Offerings-Subset-Science.txt)

:: Winter
IF EXIST ".\Data\%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt" DEL /F /Q ".\Data\%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Winter-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% >> .\Data\%$OFFERING_YEAR%-Winter-Offerings-Subset-Science.txt)

:: Spring
IF EXIST ".\Data\%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt" DEL /F /Q ".\Data\%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Spring-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%  >> .\Data\%$OFFERING_YEAR%-Spring-Offerings-Subset-Science.txt)

:: Summer
IF EXIST ".\Data\%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt" DEL /F /Q ".\Data\%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Summer-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%  >> .\Data\%$OFFERING_YEAR%-Summer-Offerings-Subset-Science.txt)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Format import file
:: replace "|" with TAB
::	let powershell do it
::	Hard coded file to FR: Offerings-Parsed.txt

::	@powershell ".\Lib\Find-and-Replace.ps1"



:exit
IF %$LOG_LEVEL_INFO% EQU 1 Echo %$ISO_DATE%	%Time%	[INFO]	Stop. >> .\logs\%$LOG_FILE%
timeout /t 10
exit