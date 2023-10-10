# Banner Offering Feed
`wget --no-check-certificate "https://adminweb.evergreen.edu/banner/public/offerings/export" --output-document=H:\adminweb_Offering_export.xml`

# Validating XML file
xml val -e adminweb_Offering_export.xml

# XML Structure
## long form
xml.exe el adminweb_Offering_export.xml

## short form
xml.exe el -u adminweb_Offering_export.xml

offerings
offerings/offering
offerings/offering/faculties
offerings/offering/faculties/faculty
offerings/offering/oars_offerings
offerings/offering/oars_offerings/oars_offering
offerings/offering/short_title
offerings/offering/terms
offerings/offering/terms/term
offerings/offering/title

# XML Structure with attributes "@"
## long form
###	There's no short form of the command
xml.exe el -a adminweb_Offering_export.xml


offerings/offering
offerings/offering/@id
offerings/offering/@status
offerings/offering/@year
offerings/offering/@offering_type
offerings/offering/@liaison_area
offerings/offering/@curr_area
offerings/offering/@crns
offerings/offering/@time_category
offerings/offering/title
offerings/offering/short_title
offerings/offering/oars_offerings
offerings/offering/oars_offerings/oars_offering
offerings/offering/oars_offerings/oars_offering/@code
offerings/offering/faculties
offerings/offering/faculties/faculty
offerings/offering/faculties/faculty/@display_name
offerings/offering/faculties/faculty/@user_name
offerings/offering/faculties/faculty/@id
offerings/offering/faculties/faculty/@phone
offerings/offering/faculties/faculty/@location
offerings/offering/faculties/faculty/@email
offerings/offering/faculties/faculty/@coordinator
offerings/offering/terms
offerings/offering/terms/term
offerings/offering/terms/term/@code
offerings/offering/terms/term/@season
offerings/offering/terms/term/@start_date
offerings/offering/terms/term/@end_date


# Get a count for the number of records
xml.exe sel -t -v "count(/offerings/offering/title)" adminweb_Offering_export.xml

## Count the total number of nodes in xml file(s)
xml sel -t -f -o " " -v "count(//node())" adminweb_Offering_export.xml

## Count for a specific element or attribute
xml sel -t -f -o " " -v "count(offerings/offering/faculties/faculty/@user_name)" adminweb_Offering_export.xml

# Show  XSLT format with "-C" switch
xml.exe sel -C -t -v "count(/offerings/offering/title)" adminweb_Offering_export.xml


Every -t option is mapped into XSLT template. Options after '-t' are mapped into XSLT elements:

*   \-v to <xsl:value-of>
    
*   \-c to <xsl:copy-of>
    
*   \-e to <xsl:element>
    
*   \-a to <xsl:attribute>
    
*   \-s to <xsl:sort>
    
*   \-m to <xsl:for-each>
    
*   \-i to <xsl:if>
    
*   and so on


# -c Returns the entire node
## DONT USE -T to get NODE
xml sel -t -c "offerings/offering[@id="26188"]" -n adminweb_Offering_export.xml

# Get a list of titles
xml.exe sel -t -v "offerings/offering/title" adminweb_Offering_export.xml

# or same results
xml.exe sel -t -m //offerings/offering -v title -n adminweb_Offering_export.xml


## Do titles as sorted
xml.exe sel -t -m //offerings/offering -s A:T:U title -v title -n adminweb_Offering_export.xml

## Get Offering ID's
xml.exe sel -t -m "//offerings/offering" -v @id -n adminweb_Offering_export.xml

## Get status
xml.exe sel -t -m "//offerings/offering" -v @status -n adminweb_Offering_export.xml

## Get year
xml.exe sel -t -m "//offerings/offering" -v @year -n adminweb_Offering_export.xml

## offering_type
xml.exe sel -t -m "//offerings/offering" -v @offering_type -n adminweb_Offering_export.xml

## liaison_area
xml.exe sel -t -m "//offerings/offering" -v @liaison_area -n adminweb_Offering_export.xml

## curr_area
xml.exe sel -t -m "//offerings/offering" -v @curr_area -n adminweb_Offering_export.xml

## Program Code
xml.exe sel -t -m "offerings/offering/oars_offerings/oars_offering" -v @code -n adminweb_Offering_export.xml
### Return Offering Code formated
xml sel -E utf-8 -T -t --if "offerings/offering[@id='38286']" -v "concat(offerings/offering/oars_offerings/oars_offering/@code, '|', offerings/offering/@id, '|', offerings/offering/title)" -n .\Data\adminweb_Offering_export.xml


xml sel -T -t -m offerings/offering[@id='42846'] -v "concat(//oars_offerings/oars_offering/@code, '|', @id, '|', title)" -n .\Data\adminweb_Offering_export.xml

## try conditional for proper formatting
xml sel -T -t -m offerings/offering[@id='43486'] -v "concat(@id, '|', title)" -o "|" -if "oars_offerings/oars_offering[starts-with(@code, '2024')]" -v oars_offerings/oars_offering/@code --else -o "" -n .\Data\adminweb_Offering_export.xml


## Program Code using sort
xml.exe sel -t -m "offerings/offering/oars_offerings/oars_offering" -s A:T:U code -v @code -n adminweb_Offering_export.xml

## Multiple values as once with a ";"
xml.exe sel -T -t -m "offerings/offering" -v "concat(@id, ';' ,@status, ';', @year, ';', @offering_type, ';', @liaison_area, ';', @curr_area)"  -n adminweb_Offering_export.xml
### example
xml sel -T -t -m offerings/offering -s A:T:U "@id" -v "concat(@id, '|', @status, '|', @year, '|',  @offering_type, '|', @liaison_area, '|', @curr_area)" -n
 adminweb_Offering_export.xml

# Get a node with a specific value, e.g. attribute
## Seems to only work if the value is numeric; it fails on any alpha or alphanumeric.
### -E specifies encoding;
### -c returns the node (everything)
xml sel -E utf-8 -t -c "offerings/offering[@id="38286"]" -n adminweb_Offering_export.xml
### Just return specific values
xml sel -E utf-8 -t -m "offerings/offering[@id='38286']" -v "concat(@id, '|', title)" -n adminweb_Offering_export.xml

### When value is alpha or alphanumeric, the condition string MUST use single quote '
xml sel -t -m //offering[@status='Cancelled'] -v "concat(@id, '|', @status, '|', title)" -n adminweb_Offering_export.xml

## Get node with multiple attributes filter
xml sel -t -m //offering[@status='Confirmed'][@liaison_area='SI'] -v "concat(@id, '|' ,@offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m oars_offerings/oars_offering -v @code -o "|" -n .\Data\adminweb_Offering_export.xml

## Starts with
###	When using expression such as starts-with, it must be encased in double quotes
xml sel -T -t -m "offerings/offering[starts-with(@status, 'Con')]" -v @id -n .\Data\adminweb_Offering_export.xml
xml sel -T -t -m offerings/offering[@status='Confirmed'] -v @id -o "|" -m "oars_offerings/oars_offering[starts-with(@code, '202410')]" -v @code -n .\Data\adminweb_Offering_export.xml

xml sel -T -t -m offerings/offering[@status='Confirmed'] -v @id -o "|" --if /terms/term[@code='202410'] --elif offering/oars_offerings/oars_offering[starts-with(@code, '202410')] -v "concat(@id, '|', offering/oars_offerings/oars_offering/@code)"  -n .\Data\adminweb_Offering_export.xml


### Search for attribute that is liaison_area=MES sorted by title
xml sel -t -m //offering[@liaison_area='MES'] -s A:T:U title -v "concat(@id, '|', @liaison_area, '|', title)" -n adminweb_Offering_export.xml
## Group by liaison_area
xml sel -t -m //offering -s A:T:U @liaison_area -v "concat(@liaison_area, '|', @id, '|', title)" -n adminweb_Offering_export.xml > .\Data\Offerings_by_liaison_area.txt

## Get offerings based on term

xml sel -t -m //offering[@status='Confirmed'] -v "concat(@id, '|' ,@offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m /terms/term -v @season -n .\Data\adminweb_Offering_export.xml


## Subset a node
xml sel -t -m //offering[2] -s A:T:U @liaison_area -v "concat(@liaison_area, '|', @id, '|', title)" -n adminweb_Offering_export.xml

### All of the confirmed offerings with Program code
xml sel -t -c //offering[@status='Confirmed'] -m //offering/oars_offerings/oars_offering -v @code -n .\Data\adminweb_Offering_export.xml

xml.exe sel -T -t -c "offerings/offering" -m "offerings/offering" -v "concat(@id, ';' ,@status, ';', @year, ';', @offering_type, ';', @liaison_area, ';', @curr_area)" -m "offerings/offering/oars_offerings/oars_offering" -v @code -n adminweb_Offering_export.xml

## Trying to output two values from different elements at the same time
xml.exe sel -t -m //offerings/offering/oars_offerings/oars_offering -v @code -o "|" -m //offerings/offering -v "concat(@id, "|", @code)" -n .\Data\adminweb_Offering_export.xml | more


# Parsed file
xml sel -t -m "//offering" -v "concat(@id, ';' ,@status, ';', @year, ';', @offering_type, ';', @liaison_area, ';', @curr_area, title)" -o ";" -m oars_offerings/oars_offering -v @code -n .\Data\adminweb_Offering_export.xml > adminweb_offerings_parsed.txt



# Parsed file to output file
## Doesn't oout put correctly
xml sel -t -m offerings/offering/oars_offerings/oars_offering -v @code -o ";" -m "//offering" -v "concat(@id, '|' ,@status, '|', @year, '|', @offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m "faculties/faculty" -v "@display_name" -n .\Data\adminweb_Offering_export.xml > .\Data\Offerings_Parsed.txt

### Doesen't works
xml sel -t -c //offering[@status='Confirmed'] -m "//offering" -v "concat(@id, '|', @year, '|', @offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m "faculties/faculty" -v "@display_name" -o "|" -m "oars_offerings/oars_offering/@code" -n .\Data\adminweb_Offering_export.xml > .\Data\Offerings_Parsed.txt
xml sel -t -c //offering[@status='Confirmed'] -m "oars_offerings/oars_offering" -v "@code" -n .\Data\adminweb_Offering_export.xml 





## Corrected ouput (mostly)
### Faculties don't come in likely due to XPATH order
xml sel -t -m //offering[@status='Confirmed'] -v "concat(@id, '|' ,@status, '|', @year, '|', @offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m oars_offerings/oars_offering -v @code -o "|" -m "offering/faculties/faculty" -v "@display_name" -n .\Data\adminweb_Offering_export.xml > .\Data\Sample-output.txt > .\Data\Sample-output.txt
### Heavily filterd and correct output
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] -v @id -o "|" -v @liaison_area -o "|" -v @offering_type -o "|" -v title -o "|" -n .\Data\adminweb_Offering_export.xml > .\Data\Sample-output.txt




#### Try this
xml sel -t -m //offering[@status='Confirmed'] -v "concat(@id, '|' ,@offering_type, '|', @liaison_area, '|', @curr_area, '|', title)" -o "|" -m oars_offerings/oars_offering -v @code -o "|" -m "faculties/faculty" -v "@display_name" -n .\Data\adminweb_Offering_export.xml > .\Data\Sample-output.txt

## Problems
###	the term code causes multiple records on a single line
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'] -s A:T:U @liaison_area -v @id -o "|" -v @liaison_area -o "|" -v @offering_type -o "|" -v title -o "|" -m terms/term[@code='202410'] -v @code -o "|" -n .\Data\adminweb_Offering_export.xml

## Mappings
### id - Offering Code
xml sel -T -t -m //offering[@status='Confirmed'] -v @id -o "|" -m oars_offerings/oars_offering -v @code -o "|" -n .\Data\adminweb_Offering_export.xml


## IF / --ELIF
xml sel -T -t --if "offerings/offering/terms/term[@code='202410']" -v //offerings/offering/@id --else -o "" -n .\Data\adminweb_Offering_export.xml
### Get Offering ID's based on conditions
xml sel -T -t -i "offerings/offering/terms/term/[@Code='202410']" -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] -v @id-n .\Data\adminweb_Offering_export.xml

### Code to generate ID's for condition
xml sel -T -t -m //offering[@status='Confirmed'][@liaison_area!='TAC'][@liaison_area!='CON'][@liaison_area!='CTL'][@liaison_area!='EA'][@liaison_area!='MPA'][@liaison_area!='CCP'][@liaison_area!='NP'][@offering_type!='Research'] --if "terms/term[@code='202420']" -v @id -n .\Data\adminweb_Offering_export.xml > .\Data\2024-Fall-ID-Index.txt

## Resources

[XSLT Introduction](https://www.w3schools.com/xml/xsl_intro.asp)
[Free Software Magazine](http://freesoftwaremagazine.com/articles/xml_starlet/)
[XSLT Tutorial](http://zvon.org/xxl/XSLTutorial/Output/contents.html#id8)
[XMLStartlet Documentation](https://xmlstar.sourceforge.net/docs.php)
[Stackoverflow: Questions tagged xmlstarlet](https://stackoverflow.com/questions/tagged/xmlstarlet)
[Stackoverflow: using xmlstarlet to parse a list in a specific order](https://stackoverflow.com/questions/54930452/using-xmlstarlet-to-parse-a-list-in-a-specific-order)
[Stackoverflow: inserting missing node with attributes in xml file at a specific line only](https://stackoverflow.com/questions/75586193/inserting-missing-node-with-attributes-in-xml-file-at-a-specific-line-only)