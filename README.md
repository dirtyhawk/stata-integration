# stata-integration
A bundled Linux binary script integrating an already installed Stata instance into the desktop environment

## About
The script will install
1. an application menu entry for Stata's windowed and console variant
1. all mimetypes relevant to Stata (.do, .dta, .smcl, .gph, .stpr, .stsem)
1. file-type associations for each newly installed mimetype to Stata
1. Stata icons for the application menu entry as well as each mimetype in several sizes

Use at your own risk; the script has been tested on Ubuntu (16.04 through 17.10) and should work in all modern Linux desktop environments that support freedesktop.org spcifications on icons an mimetypes. I, however, do no not warrant this.

## Usage
Simply run `sudo build/stata-integration.bin` in a terminal window and **read** and follow the on-screen instructions.

## Copyright notice
All icons have been extracted from the official Stata windows binaries and copyright by StataCorp LLC.
