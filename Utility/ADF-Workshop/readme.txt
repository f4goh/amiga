@LLLLLLL00LLLLLLLLftt1i;::,.  ..,:;i11tfLLfft1ii;:@LLLLLLLL@@@@@
@LLLLLLLLLLLLLLLLLftt1i;::,.  ..,:;i11tfLLftt1ii;:GLLLLLLLLLL@@@
@LLLLLLLLLLLLLLLLLft11i;::,.  ..,:;iLLLLLLLLL1ii;:GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  ..,:;iLLLLLLLLL1i;;:GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  ..,:;iLLLLLLLLL1ii;:GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  .,,:;iLLLLLLLLL1i;;:GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  .,,:;iLLLLLLLLL1i;;:GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  .,,:;iLLLLLLLLL1i;;:GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  .,::;iLLLLLLLLL1i;::GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  .,::;iLLLLLLLLL1i;::GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLft11i;::,.  .,::;i11tfLLftt1i;::GLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL@
@LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL@
@LLLLLLL                                               iLLLLLLL@
@LLLLLLL                                               iLLLLLLL@
@LLLLLLL                                .11111:111110  iLLLLLLL@
@LLLLLLL                               11111L;1111t;   iLLLLLLL@
@LLLLLLL                             :LLLLLiLLLLLG     iLLLLLLL@
@LLLLLLL                            tttttC1ttttf       iLLLLLLL@
@LLLLLLL                          ,iiiii:iiiiiC        iLLLLLLL@
@LLLLLLL                         ,,,,,t.,,,,:.         iLLLLLLL@
@LLLLLLL                       .:::::::::::C           iLLLLLLL@
@LLLLLLL                      iiiiiL;iiii1.            iLLLLLLL@
@LLLLLLL                    .11111,111110              iLLLLLLL@
@LLLLLLL    LLLLLL1LLLLLi  iiiiiL;iiii1.               iLLLLLLL@
@LLLLLLL     ,LLLLLCLLLLLtiiiii,iiiiiL                 iLLLLLLL@
@LLLLLLL       LLLLLLiLL;;;;;L;;;;;1                   iLLLLLLL@
@LLLLLLL        ,CCCCCftttttCtttttL                    iLLLLLLL@
@L@@@CLL          GGGLLLLLGLLLLLC                      iLLLLLLL@
@L@@@CLL           ,11111 11111,                       iLLLLLLL@
@LLLLLLL@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@0LLLLLLL@

ADF-Workshop v20150426
Copyright (c)2012-2015 Crashdisk/TOSEC


 -------------
| Description |
 -------------

ADF-Workshop is utility that allows you to manage your ADF collection.
Why this name? Originally, I wrote a small program to understand the
structure of DMS and discover programming with PureBasic. Gradually, I
added more possibilities and options. A year and a half later, this is
the result of my work between two fixes for TOSEC ;-)

Feature:
 - Support in reading of ADF, ADZ, DMS and ABB (bootblock) files
 - Preliminary support for Warp files
 - Conversion to ADF
 - Automatic decryption of protected DMS
 - Bug workaround for some bugged DMS
 - Extraction of additional content for DMS
 - Fusion of several files (to apply a DMS patch or join a DMS file
   divided into parts)
 - Comparison and identification with TOSEC database
 - Search engine in the TOSEC database (standard ADF only)
 - Recognition of bootblock
 - Support for ABR (Amiga Bootblock Reader) database by jasonver2.0
 - Viewing or extract files on the disk as well as their health status
 - Identification of some viruses/trojan/link-virus (but this is not an
   antivirus!)
 - Fix some damage (Saddam virus, Pestilence virus, overflow bootblock)
 - Batch mode
 - 100% written in PureBasic


 ---------------------
| System Requirements |
 ---------------------

This utility has been tested on Windows XP/Vista/Seven (x86/x64). I
cannot guarantee the functioning on other systems.


 --------------------
| Using ADF-Workshop |
 --------------------

ADF-Workshop doesn't require any installation process or additional DLL
files. You can add ADF databases putting the *.db files in the
"database_ADF" folder. Please note that the loading of databases slowed
the loading time of the utility. In order to start using it, simply run
the executable file. All functions are accessible from the "File" menu
and options in other menus.


 ------------------
| Versions History |
 ------------------

 Version 20150426
 - Added partial support of Warp files (no decompression!)
 - Added option to hide the results not TOSEC
 - Added system to avoid hash collisions during identification by CRC32
 - Added support for debugging encrypted files
 - Added support for ADF files protected with 3 versions of Meikel's
   Password-Tool
 - Added an option to display a pseudo password for DMS files
 - Improved identification files
 - Improved detection of doscopy
 - Improved and fixed calculation of dates and times
 - Updated external database to detect ads/loader
 - Updated internal database to detect executable
 - Updated auto-fix DMS databases
 - Updated auto-decrypt DMS databases
 - Fixed an infinite loop when parsing a corrupted DMS file
 - Fixed of the repair of the damage by Saddam virus
 - Fixed some stuff
 
 Version 20141212
 - Added viewing comments of files/folders
 - Added a function to correct the BAM (Only for the pro version)
 - Improved detection of doscopy
 - Improved file repair report (Only for the pro version)
 - Updated external database to detect ads/loader
 - Updated auto-fix DMS databases
 - Updated auto-decrypt DMS databases
 - Fixed an old problem to decompress few DMS files using the Heavy2 mode
 - Some cosmetic changes
 
 Version 20140905
 - Updated external database to detect virus/trojan/ads/...
 - Added support for some hacked file structure compatible only on KS1.X
 - Added detection of some link-virus (HNY98, FileGhost 1/2/3, IRQ 2, ...)
 - Fixed some stuff

 Version 20140606
 - Improved and updated auto-decrypt DMS databases
 - Updated auto-fix DMS databases
 - Updated bootblock database (a major update coming soon)
 - Added detection of bootblock file on a disk
 - Added detection of VirusExpert/BootX bootblock database on a disk
 - Added an external database to detect virus/trojan/ads/...
 - Added support for "deadlock" sectors
 - Added the ability to modify the settings of identifications of the disks
   (Global options/ADF analyze/Options...)
 - Fixed some stuff

 Version 20140310
 - Improved method for discovering the decryption key
 - Improved control of the application during decryption
 - Updated auto-decrypt DMS databases with 904 keys
 - Added a menu to set a default decryption key
 - Added option to automatically switch the decryption key
 - Added detection of another "empty" sector

 Version 20140305
 - Fixed a rare problem with crypted DMS files
 - Updated auto-fix DMS databases
 - Updated auto-decrypt DMS databases

 Version 20140302 [Private release]
 - Enhanced support for protected DMS
 - Enhanced ANSI filter for bootblock and startup-sequence
 - Updated auto-fix DMS databases
 - Added specific support for "RattleHead BootPage" bootloader
 - Added auto-decrypt DMS databases

Version 20140220 [Private release]
 - Fixed and enhanced support for bootloaders
 - Updated auto-fix DMS databases
 - Added detection of some "empty" sectors

Version 20140123 [Private release]
 - Fixed some texts (thanks Arnie)
 - Fixed a rare problem with damaged DMS files (thanks mai)
 - Updated auto-fix DMS databases
 - Added support for hacks done with DmsChecker
 - Added support for "Sanity Operating System" (thanks Cybfree)
 - Added preliminary support for noDOS data used by the bootloaders
 - Better management for duplicate filenames

Version 20131222
 - First Public Release


 ----------------
| Known problems |
 ----------------

 - Batch processing of a large number of files can slow down the display
   and therefore the treatment itself. It is possible to take a break to
   clear the report or stop the process via a special menu


 ---------
| License |
 ---------

This utility is released as freeware. You are allowed to freely
distribute this utility via floppy disk, CD-ROM, Internet, or in any
other way, as long as you don't charge anything for this. If you
distribute this utility, you must include all files in the distribution
package, without any modification!


 ------------
| Disclaimer |
 ------------

The software is provided "AS IS" without any warranty, either expressed
or implied, including, but not limited to, the implied warranties of
merchantability and fitness for a particular purpose. The author will
not be liable for any special, incidental, consequential or indirect
damages due to loss of data or any other reason.


 ----------
| Feedback |
 ----------

If you have any problem, suggestion, comment or you find a bug in my
utility, you can post a message on the EAB forum.


 -------
| Links |
 -------

Download the latest version
http://www.tosecdev.org/

All databases
http://eab.abime.net/showthread.php?t=71922

Bug report or suggestion
http://eab.abime.net/showthread.php?t=71922

TOSEC, what is it?
http://en.wikipedia.org/wiki/TOSEC
 
TOSEC Project Homepage
http://www.tosecdev.org/

TOSEC Amiga Forum
http://eab.abime.net/forumdisplay.php?f=33

Amiga Bootblock Reader v2
http://eab.abime.net/showthread.php?t=64476

PureBasic
http://www.purebasic.com
