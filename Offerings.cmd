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
SET $BUILD=2023-10-05 0915
Title %$PROGRAM_NAME%
Prompt OPT$G
color 8F
mode con:cols=85 lines=50
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

:: Adminweb Web URI to fetch export
SET "$URI_ADMINWEB=https://adminweb.evergreen.edu/banner/public/offerings/export"


::#############################################################################
::	!!!!	Everything below here is 'hard-coded' [DO NOT MODIFY]	!!!!
::#############################################################################



:::: Start Time Start Date	:::::::::::::::::::::::::::::::::::::::::::::::::::
SET $START_TIME=%Time%
SET $START_DATE=%Date%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CD /D %$DIRECTORY_PROJECT%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



wget --no-check-certificate "https://adminweb.evergreen.edu/banner/public/offerings/export" --output-document=.\Data\adminweb_Offering_export.xml




:exit
PAUSE
exit