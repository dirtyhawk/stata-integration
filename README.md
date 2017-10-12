# stata-integration
A bundled Linux binary script integrating an already installed Stata instance into the desktop environment

## About
The script will do the following:
1. ask for some information regarding the Stata environment it is faced with (installation path, Stata version, etc);
1. apply a workaround which fixes an issue where all menu icons in Stata's GUI are missing in modern Linux distributions; this is done by manually downloading and building older variants of `zlib` (1.2.3) and `libpng` (1.6.2); details on why this might be necessary can be found [here on Statalist](http://www.statalist.org/forums/forum/general-stata-discussion/general/2199-linux-stata-bug-libpng-on-newer-opensuse-possibly-other-distributions); the blueprint for the installation procedure has been sketched from [this script on BitBucket](https://bitbucket.org/vilhuberl/stata-png-fix) by [Lars Vilhuber](https://www.vilhuber.com/lars/);
1. install an application menu entry for Stata's windowed and console variant;
1. install all mimetypes relevant to Stata (.do, .dta, .smcl, .gph, .stpr, .stsem);
1. install file-type associations for each newly installed mimetype to Stata;
1. install Stata icons for the application menu entry as well as each mimetype in several sizes;
1. make Stata the default application for opening the newly installed mimetypes for each user requested

Use at your own risk. The script has been tested on Ubuntu (16.04 through 17.10) and should work in all modern Linux desktop environments that support the [freedesktop.org](https://www.freedesktop.org) specifications on [icons](https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html), [application shortcuts](https://specifications.freedesktop.org/desktop-entry-spec/latest/) and [mimetypes](https://www.freedesktop.org/wiki/Specifications/shared-mime-info-spec/). I, however, do no not warrant this. Actually, I do not even warrant that the script works at all. That's *your own risk*.

## Usage
Simply run `sudo stata-integration.bin` in a terminal window and **read** and follow the on-screen instructions.

## Copyright notice
All icons have been extracted from the official Stata for Windows binaries and are, as well as the term 'Stata', of course copyrighted property of StataCorp LLC.

