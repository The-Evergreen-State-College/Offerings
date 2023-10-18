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
SET $Version=0.3.0
SET $BUILD=2023-10-18 1500
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

:: PATH for XMLStarlet
SET PATH=%PATH%;%$PATH_XML%

:::: Start Time Start Date	:::::::::::::::::::::::::::::::::::::::::::::::::::
SET $START_TIME=%Time%
SET $START_DATE=%Date%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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
IF EXIST ".\cache\TimeZone.txt" GoTo skipTZ
@powershell Get-TimeZone> ".\cache\TimeZone.txt"
:skipTZ
FOR /F "skip=2 tokens=2 delims=:" %%P IN ('FIND /I "Id" ".\cache\TimeZone.txt"') DO echo %%P> ".\cache\var_timezone_Id.txt"
SET /P $TIMEZONE_ID= < ".\cache\var_timezone_Id.txt"
FOR /F "tokens=2 delims=:" %%P IN ('FIND /I "BaseUtcOffset" ".\cache\TimeZone.txt"') DO echo %%P> ".\cache\var_timezone_UTC.txt"
SET /P $TIMEZONE_UTC= < ".\cache\var_timezone_UTC.txt"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Check for XMLStartlet
xml --version > .\cache\xmlstartlet-version.txt
SET $ERROR_XML=%ERRORLEVEL%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: archive XML
IF EXIST ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%.old" DEL /F /Q ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%.old"
IF EXIST ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" Rename ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" %$ADMINWEB_OFFERINGS_EXPORT_FILE%.old
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Retrieve XML feed
wget --tries=2 --connect-timeout=10 --waitretry=5 --no-check-certificate "%$URI_ADMINWEB%" --output-document=.\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%
SET $ERROR_WGET=%ERRORLEVEL%
echo Retrieve offerings XML file error: %$ERROR_WGET%
IF %$ERROR_WGET% NEQ 0 (
	@powershell Write-Host "Failed to retrieve latest xml, information may not be up to date!" -ForegroundColor DarkRed
	timeout /t 10
	FIND "offerings" ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" 2>nul 1> nul || GoTo Exit
	)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check for change
COMP ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%.old" ".\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%" /M > ".\cache\Compare_XML_Feed.txt"
(FIND "Files compare OK" ".\cache\Compare_XML_Feed.txt" 2> nul) & (SET $FLAG_XML_COMP=%ERRORLEVEL%)
IF %$FLAG_XML_COMP% EQU 1 echo Delta change to XML Offerings!
IF %$FLAG_XML_COMP% EQU 0 (
	@powershell Write-Host "No change in XML feed, nothing to do, exiting..." -ForegroundColor Green
	timeout /t 10
	exit)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get Count of offerings in export
xml.exe sel -t -v "count(/offerings/offering/title)" .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > .\cache\offerings_count.txt
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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get Cancelled Offerings
xml sel -t -m //offering[@status='Cancelled'] -v "concat(@id, '|', @status, '|', title)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% > .\Data\%$OFFERING_YEAR%-Offerings-Cancelled.txt
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Get unfiltered list of offerings
::	Complete
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U title -v "concat(title, '|', @offering_type, '|', @curr_area, '|', @liaison_area, '|', faculties/faculty[1]/@display_name, ';', faculties/faculty[2]/@display_name, ';', faculties/faculty[3]/@display_name)" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE%> .\Data\Complete-Offerings-Listing-Confirmed.txt
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
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', @curr_area, '|', @liaison_area, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% >> .\Data\%$OFFERING_YEAR%-Fall-Offerings-Parsed.txt)

:: Winter
IF EXIST ".\Data\%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt" DEL /F /Q ".\Data\%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Winter-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% >> .\Data\%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt)

:: Spring
IF EXIST ".\Data\%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt" DEL /F /Q ".\Data\%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Spring-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% >> .\Data\%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt)

:: Summer
IF EXIST ".\Data\%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt" DEL /F /Q ".\Data\%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Summer-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\xml\%$ADMINWEB_OFFERINGS_EXPORT_FILE% >> .\Data\%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



:: Format import file
:: replace "|" with TAB
::	let powershell do it
::	Hard coded file to FR: Offerings-Parsed.txt

::	@powershell ".\Lib\Find-and-Replace.ps1"



:exit
timeout /t 10
exit