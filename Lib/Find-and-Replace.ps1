# Format import file
# replace "|" with TAB
$DIRECTORY_PROJECT = (Get-Item -Path ".\" -Verbose).FullName
$TAB = [char]9
(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
#(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
#(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
#(Get-Content .\Data\Offerings-Parsed.txt).replace('|', "$TAB") | Set-Content .\Data\Offerings-Parsed.txt
EXIT