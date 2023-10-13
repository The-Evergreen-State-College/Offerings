# Developer :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Author:	David Geeraerts
# Location:	Olympia, Washington USA
# E-Mail:	dgeeraerts.evergreen@gmail.com
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

##############################################################################
#							#DESCRIPTION#
#	Acts as a library to find and replace.
# 	Used for formatting files for import.
#	
##############################################################################

# Format import file
# replace "|" with TAB
$DIRECTORY_PROJECT = (Get-Item -Path ".\" -Verbose).FullName
$TAB = [char]9
(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
#(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
#(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
#(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
EXIT