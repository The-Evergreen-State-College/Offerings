:::: Offerings Parsing Tool ::::::::::::::::::::::::::::::::::::

::#############################################################################
::							#DESCRIPTION#
::
::	SCRIPT STYLE: 
::	Program is 
::#############################################################################

:::: Developer ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: GitHub :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	https://github.com/DavidGeeraerts/
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
SET $Version=0.1.0
SET $BUILD=2023-10-10 1430
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


:: XMLStarlet Tool
::	https://xmlstar.sourceforge.net/
:: PATH to exe
SET $PATH_XML=.\Bin

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
IF NOT EXIST ".\Data\index" MD ".\Data\index"
IF NOT EXIST ".\Logs" MD ".\Logs"


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


wget --no-check-certificate "https://adminweb.evergreen.edu/banner/public/offerings/export" --output-document=.\Data\adminweb_Offering_export.xml
SET $ERROR_WGET=%ERRORLEVEL%
echo %$ERROR_WGET%
IF %$ERROR_WGET% NEQ 0 timeout /t 60


:: Get Count of offerings in export
xml.exe sel -t -v "count(/offerings/offering/title)" .\Data\adminweb_Offering_export.xml > .\cache\offerings_count.txt


:: Get Year
xml sel -T -t -m //offering[@status='Confirmed'] -s A:N:U @year -v @year  -n .\Data\adminweb_Offering_export.xml > .\cache\offerings_year.txt
SET /P $OFFERING_YEAR= < .\cache\offerings_year.txt

:: Get Cancelled Offerings
xml sel -t -m //offering[@status='Cancelled'] -v "concat(@id, '|', @status, '|', title)" -n .\Data\adminweb_Offering_export.xml > .\Data\%$OFFERING_YEAR%-Offerings-Cancelled.txt

:: Get Offerings by Liaison_area
xml sel -t -m //offering[@status='Confirmed'] -s A:T:U @liaison_area -v "concat(@liaison_area, '|', @id, '|', title)" -n .\Data\adminweb_Offering_export.xml > .\Data\%$OFFERING_YEAR%-Offerings_by_liaison_area.txt


:: Get Offerings that are Confirmed build index
::xml sel -t -c //offering[@status='Confirmed'] -m offerings/offering/oars_offerings/oars_offering -v @code -o "|" -m "//offering" -v "concat(@id, '|' ,@status, '|', @year, '|', @offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m "faculties/faculty" -v "@display_name" -n .\Data\adminweb_Offering_export.xml > .\Data\Offerings_Parsed.txt
:: Fall
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%10']" -v @id -n .\Data\adminweb_Offering_export.xml > ".\Data\index\%$OFFERING_YEAR%-Fall-ID-Index.txt"

:: Winter
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%20']" -v @id -n .\Data\adminweb_Offering_export.xml > ".\Data\index\%$OFFERING_YEAR%-Winter-ID-Index.txt"

:: Spring
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%30']" -v @id -n .\Data\adminweb_Offering_export.xml > ".\Data\index\%$OFFERING_YEAR%-Spring-ID-Index.txt"

:: Summer
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='%$OFFERING_YEAR%40']" -v @id -n .\Data\adminweb_Offering_export.xml > ".\Data\index\%$OFFERING_YEAR%-Summer-ID-Index.txt"



:: Fall
IF EXIST "%$OFFERING_YEAR%-Fall-Offerings-Parsed.txt" DEL /F /Q "%$OFFERING_YEAR%-Fall-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Fall-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\adminweb_Offering_export.xml >> .\Data\%$OFFERING_YEAR%-Fall-Offerings-Parsed.txt)

:: Winter
IF EXIST "%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt" DEL /F /Q "%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Winter-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\adminweb_Offering_export.xml >> .\Data\%$OFFERING_YEAR%-Winter-Offerings-Parsed.txt)

:: Spring
IF EXIST "%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt" DEL /F /Q "%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Spring-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\adminweb_Offering_export.xml >> .\Data\%$OFFERING_YEAR%-Spring-Offerings-Parsed.txt)

:: Summer
IF EXIST "%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt" DEL /F /Q "%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt"
FOR /F "tokens=1 delims=" %%P IN (.\Data\index\%$OFFERING_YEAR%-Summer-ID-Index.txt) DO (
xml sel -T -t -m offerings/offering[@id='%%P'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering" -v oars_offerings/oars_offering/@code -n --else -o "" -n .\Data\adminweb_Offering_export.xml >> .\Data\%$OFFERING_YEAR%-Summer-Offerings-Parsed.txt)

:: Format import file
:: replace "|" with TAB
::	let powershell do it
::	Hard coded file to FR: Offerings-Parsed.txt

::	@powershell ".\Lib\Find-and-Replace.ps1"



:exit
timeout /t 10
exit