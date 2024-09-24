[Installation](#installation) | [Usage](#usage) | [Configuration](#configuration) | [ChangeLog](#changelog)
# Offerings
A tool to export The Evergreen State College Offering catalogue from Banner, via Adminweb.

## About
This project came about due to Lab Management Software (LMS) migration for the [Science Support Center](https://www.evergreen.edu/academics/academic-career-services/science-support-center). The SSC ran a custom Drupal application called _Merci_ and migrated to using [Gigatrak](https://www.gigatrak.com/). GigaTrak has many imports, one of which is for members/patrons. Offerings/Programs are used to check equipment out to. It would be helpful to import Science Offerings into Gigatrak so that Offerings/Programs don't have to be manually entered. There's an XML feed from Banner through Adminweb interface, which requires being on the _office VLAN_.

The XML Offerings feed needs to be parsed (and filtered), and I chose to use [XMLSTARTLET](https://xmlstar.sourceforge.net/) for that since the Offerings tool is written for Windows Command shell. The documentation for XMLStartlet is sparse and it took much digging + trial and error to get things working. This is to say that this project would be helpful for learning XMLStartlet. I've tried to document most of the work in my [XMLStartlet notes](docs/XMLStartlet_Notes.md).

## :building_construction: Installation

Download the latest version from GitHub [Release](https://github.com/The-Evergreen-State-College/Offerings/releases); this will provide an archive compressed ``.zip`` file that can be extracted to a directory of your choosing -- hopefully you are following [Filesystem Hierarchy Standard](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard), and just like *NIX, Windows has a [Directory structure Standard](https://en.wikipedia.org/wiki/Directory_structure) as well. Once extracted, lets say to ``%SYSTEMDRIVE%\Users\Public\Tools`` the path wil then be: ``C:\Users\Public\Tools\Offerings-0.0.0\Offerings-0.0.0``; I recommend moving the contents to the top folder: ``C:\Users\Public\Tools\Offerings-0.4.0`` 
To run the program, run ``Offerings.cmd``. _I haven't figured out yet how to path the release, so that it's not redundant._

### :fish: :ocean: Dependency
[XMLStartlet](https://xmlstar.sourceforge.net/) -- the [xml] executable must be in the ``\bin`` directory.

## Usage

_not all folders will be present with installation, but will be created on first run._

``\bin`` -- contains the XMLStartlet executable.

``\cache`` -- contains working cache, mostly in txt files.

``\config`` -- contains offering configuration for quarters.

``\data`` -- Output for Offerings as txt files that are data structured, using either "|" or TAB as delimiters.

``\data\index`` -- contains the index files by quarters.

``\data\xml`` -- contains the offering XML feed file.


``\Docs`` -- contains documentation, such as [XMLStartlet Notes](docs/XMLStartlet_Notes.md).

``\lib`` -- contains libraries for [munging data](https://en.wikipedia.org/wiki/Data_wrangling).



### :wrench: Configuration
_For most users, there's no need to change any variables_

Some global variables can be changed in the ``Offerings.cmd`` **Declare Global Variables** section:

:: Log file

``SET $LOG_FILE=Offerings.log``

:: Adminweb Web URI to fetch export

``SET "$URI_ADMINWEB=https://adminweb.evergreen.edu/banner/public/offerings/export"``

::	Adminweb xml export file

``SET $ADMINWEB_OFFERINGS_EXPORT_FILE=adminweb_Offering_export.xml``

:: PATH to xml exe

``SET $PATH_XML=.\bin``


## :notebook: ChangeLog
[ChangeLog](ChangeLog.md)

## :page_with_curl: License
[GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)

_Free Software (as in, **Software Freedom**)_