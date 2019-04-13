#! /bin/sh
# This script installs Stata icons as mimetype icons, as well as the Stata
# mimetypes for .gph, .sem, .dta, .do, .stpr, .sthlp and .smcl files,
# into the system 
SCRIPTNAME=$(basename "$0")
# ERROR-LEVELS
EXIT_SUCCESS=0 # everything fine
EXIT_ERROR=1 # user input error
EXIT_ABORT=2 # script exit upon user request
EXIT_USAGE=64 # wrong syntax
EXIT_FAILURE=3 # program error
# (TEMPORARY) PATH TO PAYLOAD DATA
PAYLOADPATH=$(echo "$(dirname '$0')" | sed -e "s:^\.:$(pwd):")
# DEFAULT STATA INSTALLATION PATH
DEFAULTPATH='/usr/local/stata'
# DOWNLOAD URL FOR LIBPNG
LIBPNGURL="http://downloads.sourceforge.net/project/libpng/libpng16/older-releases/1.6.2/libpng-1.6.2.tar.gz"
# DOWNLOAD URL FOR ZLIB
ZLIBURL="http://downloads.sourceforge.net/project/libpng/zlib/1.2.3/zlib-1.2.3.tar.gz"
# MINIMUM AND MAXIMUM OF SUPPORTED STATA VERSIONS
MINSUPPORTEDVERSION=11
MAXSUPPORTEDVERSION=15
## Checking for root privileges
if [ $(id -u) != "0" ]; then
        echo "\nERROR!\nYou need root-privileges to run this script!\nTry running 'sudo $SCRIPTNAME'.\nExiting '$SCRIPTNAME'." >&2
        exit $EXIT_ERROR
fi
# parse arguments
TEMP=$(getopt --options v:f:p:u:l:c: --longoptions version:,flavour:,path:,users:,libpngfix:,caller: -n "${SCRIPTNAME}" -- "$@")
if [ $? -ne 0 ];
then
	exit ${EXIT_USAGE}
fi
eval set -- "$TEMP"
while true ; do
	case "$1" in
		-v|--version)
			shift;
			ARGVERSION="$1";
			shift;
		;;
		-f|--flavour)
			shift;
			ARGFLAVOUR="$1";
			shift;
		;;
		-p|--path)
			shift;
			ARGPATH="$1";
			shift;
		;;
		-u|--users)
			shift;
			ARGUSERS="$1";
			shift;
		;;
		-l|--libpngfix)
			shift;
			ARGLIBPNGFIX="$1";
			shift;
		;;
		-c|--caller)
			shift;
			CALLER="$1";
			shift;
		;;
		--)
			shift;
			break;
		;;
	esac
done
## make clear what this script will do
echo "For this script to run, you must have Stata already installed in your system; this script will install icons and mimetypes for all Stata file types to your system and add entries for Stata (console and windowed version) in your application menu -- not more, not less!\n\nIn order to do this, this script will ask you to provide the following information about your Stata environment:\n(1) The Stata flavour of your installation ('small', 'IC', 'SE', or 'MP');\n(2) the version number of your Stata installation (integer number from '${MINSUPPORTEDVERSION}' through '${MAXSUPPORTEDVERSION}');\n(3) the exact and full installation path to your Stata installation (most likely '/usr/local/stata', if you did not change the default);\n(4) if you want to install a workaround for using old variants of libpng and zlib;\n(5) the user name(s) of all users to create filetype associations for.\n\nAll icons have been extracted from the official Stata for Windows binaries and are, as well as the term 'Stata', of course copyrighted property of StataCorp LLC."
while true; do
	echo "\nDid you read an understand the above?"
	read UNDERSTOOD
	case ${UNDERSTOOD} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
			break
		;;
		* )
			echo "Sorry, this script is not meant for you." >&2
			exit ${EXIT_ERROR}
		;;
	esac
done
## query Stata flavour that has been installed
if [ -z "${ARGFLAVOUR}" ] ; then
	while true; do
		echo "\n(1) Which Stata flavour do you have installed?"
		read QUERIEDFLAVOUR
		case ${QUERIEDFLAVOUR} in
			[Mm][Pp] )
				FLAVOUR='Stata MP'
				WINDOWED=xstata-mp
				CONSOLE=stata-mp
				break
			;;
			[Ss][Ee] )
				FLAVOUR='Stata SE'
				WINDOWED=xstata-se
				CONSOLE=stata-se
				break
			;;
			[Ii][Cc] )
				FLAVOUR='Stata IC'
				WINDOWED=xstata
				CONSOLE=stata
				break
			;;
			[Ss][Mm][Aa][Ll][Ll] )
				FLAVOUR='small Stata'
				WINDOWED=xstata-sm
				CONSOLE=stata-sm
				break
			;;
			* )
				echo "Valid answers are 'MP', 'SE', 'IC', or 'small'"
			;;
		esac
	done
	SHORTFLAVOUR="${QUERIEDFLAVOUR}"
else
	case ${ARGFLAVOUR} in
		[Mm][Pp] )
			FLAVOUR='Stata MP'
			WINDOWED=xstata-mp
			CONSOLE=stata-mp
		;;
		[Ss][Ee] )
			FLAVOUR='Stata SE'
			WINDOWED=xstata-se
			CONSOLE=stata-se
		;;
		[Ii][Cc] )
			FLAVOUR='Stata IC'
			WINDOWED=xstata
			CONSOLE=stata
		;;
		[Ss][Mm][Aa][Ll][Ll] )
			FLAVOUR='small Stata'
			WINDOWED=xstata-sm
			CONSOLE=stata-sm
		;;
		* )
			echo "Valid flavours are 'MP', 'SE', 'IC', or 'small'; you specified '--flavour ${ARGFLAVOUR}'" >&2
			exit ${EXIT_USAGE}
		;;
	esac
	SHORTFLAVOUR="${ARGFLAVOUR}"
	echo "\nYou already answered (1) via command line: flavour '${SHORTFLAVOUR}'"
fi
## query Stata version number
if [ -z "${ARGVERSION}" ] ; then
	echo "\n(2) Please specify the Stata version number of your Stata installation [${MAXSUPPORTEDVERSION}]:"
	read QUERIEDVERSION
	echo "\n"
	if [ "${QUERIEDVERSION}" = "" ] ; then
		VERSION=${MAXSUPPORTEDVERSION}
	elif [ -z "${QUERIEDVERSION##*[!0-9]*}" ] ; then
		echo "only positive integer values are allowed as version numbers" >&2
		exit ${EXIT_ERROR}
	else
		VERSION=${QUERIEDVERSION}
	fi
else
	if [ -z "${ARGVERSION##*[!0-9]*}" ] ; then
		echo "only positive integer values are allowed as version numbers" >&2
		exit ${EXIT_ERROR}
	else
		VERSION=${ARGVERSION}
	fi
	echo "\nYou already answered (2) via command line: version '${ARGVERSION}'"
fi
## query Stata installation directory
if [ -z "${ARGPATH}" ] ; then
	while true; do
		echo "\n(3) Please specify the directory of your Stata installation [${DEFAULTPATH}]:"
		read QUERIEDPATH
		echo "\n"
		case ${QUERIEDPATH} in
			"" )
				INSTALLPATH="${DEFAULTPATH}"
				break
			;;
			* )
				INSTALLPATH="${QUERIEDPATH}"
				break
			;;
		esac
	done
else
	INSTALLPATH="${ARGPATH}"
	echo "\nYou already answered (3) via command line: path '${ARGPATH}'"
fi
## query whether to apply the libpng/zlib to manually use older versions of the two named libraries
if [ -z "${ARGLIBPNGFIX}" ] ; then
	echo "\n(4) Stata relies on libpng version 1.6.2 and zlib 1.2.3. Modern Linux distributions feature newer versions of these libraries.\nThis leads to Stata not being able to display icons in its menu bars, but showing icons with question marks everywhere in the graphical user interface.\nYou should now have a look at your Stata installation; if you see normal icons in Stata's user interface, you're fine. If not, this script can try to work around this issue by\n\t(a) manually auto-downloading the old library variants,\n\t(b) building these libraries from source, and\n\t(c) telling Stata explicitly to use these manually saved variants instead of the system libraries.\n\nThis will erase the directory '${INSTALLPATH}/libpngworkaround/' and all its contents, if existing, without further notice.\n\nPlease specify whether you want the script to implement this workaround:"
	read QUERIEDLIBPNGFIX
	echo "\n"
	case ${QUERIEDLIBPNGFIX} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee] )
			LIBPNGFIX="true"
			break
		;;
		[Nn]|[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee] )
			LIBPNGFIX="false"
			break
		;;
		* )
			echo "Sorry, this script is not meant for you." >&2
			exit ${EXIT_ERROR}
		;;
	esac
else
	case ${ARGLIBPNGFIX} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee] )
			LIBPNGFIX="true"
			break
		;;
		[Nn]|[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee] )
			LIBPNGFIX="false"
			break
		;;
		* )
			echo "Invalid value for option --libpngfix: ${ARGLIBPNGFIX}" >&2
			exit ${EXIT_ERROR}
		;;
	esac
	echo "\nYou already answered (4) via command line: '${ARGLIBPNGFIX}'"
fi
## query users to create file type associations for
if [ -z "${ARGUSERS}" ] ; then
	echo "\n(5) Please specify a space-separated (!) list of all users you want to create file type associations for [${SUDO_USER}]:"
	read QUERIEDTARGETUSERS
	echo "\n"
	if [ "${QUERIEDTARGETUSERS}" = "" ] ; then
		TARGETUSERS="${SUDO_USER}"
	else
		TARGETUSERS="${QUERIEDTARGETUSERS}"
	fi
else
	TARGETUSERS="${ARGUSERS}"
	echo "\nYou already answered (5) via command line: users '${ARGUSERS}'"
fi
## check if given installation directory is valid
if [ ! -d "${INSTALLPATH}" ]; then
	echo "'${INSTALLPATH}' is not a valid directory." >&2
	exit ${EXIT_ERROR}
fi
## check if Stata executables are found in the installation directory
for EXE in "${WINDOWED}" "${CONSOLE}" ; do
	if [ ! -x "${INSTALLPATH}/${EXE}" ]; then
		echo "Stata executable '${EXE}' not found in install directory '${INSTALLPATH}'." >&2
		exit ${EXIT_ERROR}
	fi
done
## check if this script is capable to work with specified Stata version
if [ ! -d "${PAYLOADPATH}/icons/${VERSION}" ]; then
	if test "${VERSION}" -gt "${MAXSUPPORTEDVERSION}" ; then
		FALLBACKVERSION=${MAXSUPPORTEDVERSION}
	elif test "${VERSION}" -lt "${MINSUPPORTEDVERSION}" ; then
		FALLBACKVERSION=${MINSUPPORTEDVERSION}
	else
		echo "Congratulations! You found a bug in this script. Your version number ${VERSION} is neither larger than the latest supported Stata version, nor lower than the earliest supported Stata version. Please report this to the author." >&2
		exit ${EXIT_FAILURE}
	fi
	while true; do
		echo "Warning: this script does not contain specific icons and mimetype associations for Stata ${VERSION}; do you want to use icons from Stata ${FALLBACKVERSION} instead?"
		read USEFALLBACK
		case ${USEFALLBACK} in
			[Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
				break
			;;
			[Nn]|[Nn][Oo] )
				echo "Script aborted."
				exit ${EXIT_ABORT}
			;;
			* )
				echo "Sorry, this script is not meant for you." >&2
				exit ${EXIT_ERROR}
			;;
		esac
	done
	ICONVERSION=${FALLBACKVERSION}
	else
	ICONVERSION=${VERSION}
fi
ICONPATH="${PAYLOADPATH}/icons/${ICONVERSION}"
## output command line for later referral
echo "\nEverything you entered seems to be fine; you can use the same configuration parameters again via command line using the following command:\n\t${CALLER} --version ${VERSION} --flavour ${SHORTFLAVOUR} --libpngfix ${LIBPNGFIX} --path \"${INSTALLPATH}\" --users \"${TARGETUSERS}\""
while true; do
	echo "\nShall we begin the installation task?"
	read LETSRIDE
	case ${LETSRIDE} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
			break
		;;
		* )
			echo "Okay, see you next time."
			exit ${EXIT_ABORT}
		;;
	esac
done
## applying fix for libpng and zlib, if requested
## source: https://bitbucket.org/vilhuberl/stata-png-fix and 
## http://www.statalist.org/forums/forum/general-stata-discussion/general/2199-linux-stata-bug-libpng-on-newer-opensuse-possibly-other-distributions
if [ "${LIBPNGFIX}" = "true" ]; then
	echo "\nstarting to apply workaround for PNG icons not showing up correctly in Stata GUI..."
	if [ -x "${INSTALLPATH}/libpngworkaround" ]; then
		rm -rf "${INSTALLPATH}/libpngworkaround"
	fi
	mkdir "${INSTALLPATH}/libpngworkaround"
	BUILDDIR="${PAYLOADPATH}/build"
	CWD=$(pwd)
	mkdir "${BUILDDIR}"
	cd "${BUILDDIR}"
	echo "\t...downloading zlib 1.2.3"
	wget -q --show-progress ${ZLIBURL}
	if [ $? != 0 ]; then
		echo "\t...error downloading zlib, we can not continue; please check if you have internet access and try again" >&2
		exit ${EXIT_FAILURE}
	fi
	echo "\t...downloading libpng 1.6.2"
	wget -q --show-progress ${LIBPNGURL}
	if [ $? != 0 ]; then
		echo "\t...error downloading libpng, we can not continue; please check if you have internet access and try again" >&2
		exit ${EXIT_FAILURE}
	fi
	echo "--- libpng-1.6.2/scripts/pnglibconf.dfa	2013-04-25 08:24:45.000000000 -0400
+++ libpng-1.6.2/scripts/pnglibconf.dfa.patched	2014-04-25 22:28:34.273329264 -0400
@@ -232,7 +232,7 @@
 # The TEXT values are the defaults when writing compressed text (all forms)
 #
 # Include the zlib header too, so that the defaults below are known
-@#  include <zlib.h>
+#@#  include <zlib.h>
 
 # The '@' here means to substitute the value when pnglibconf.h is built
 setting Z_DEFAULT_COMPRESSION default @Z_DEFAULT_COMPRESSION" > stata-png.patch
	echo "\t...unpacking zlib"
	tar zxf zlib-1.2.3.tar.gz
	cd zlib-1.2.3
	echo "\t...compiling zlib"
	export CFLAGS="-fPIC"
	./configure --prefix=${INSTALLPATH}/libpngworkaround >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "\t...error configuring zlib, we can not continue" >&2
		exit ${EXIT_FAILURE}
	fi
	make -s >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "\t...error making zlib, we can not continue" >&2
		exit ${EXIT_FAILURE}
	fi
	echo "\t...installing zlib to ${INSTALLPATH}/libpngworkaround/lib"
	make -s install >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "\t...error installing zlib, we can not continue" >&2
		exit ${EXIT_FAILURE}
	fi
	cd ${BUILDDIR}
	echo "\t...unpacking libpng"
	tar xzf libpng-1.6.2.tar.gz
	cd libpng-1.6.2
	echo "\t...compiling libpng"
	export CFLAGS="-I${INSTALLPATH}/libpngworkaround/include -fPIC"
	export LDFLAGS="-L${INSTALLPATH}/libpngworkaround/lib"
	./configure --prefix=${INSTALLPATH}/libpngworkaround >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "\t...error configuring libpng, we can not continue" >&2
		exit ${EXIT_FAILURE}
	fi
	patch -p1 < ../stata-png.patch >/dev/null 2>&1
	make -s >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "\t...error making libpng, we can not continue" >&2
		exit ${EXIT_FAILURE}
	fi
	echo "\t...installing libpng to ${INSTALLPATH}/libpngworkaround/lib"
	make -s install >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "\t...error installing libpng, we can not continue" >&2
		exit ${EXIT_FAILURE}
	fi
	WINDOWEDINSTALLPATH="/usr/bin/env LD_LIBRARY_PATH=${INSTALLPATH}/libpngworkaround/lib\:${INSTALLPATH}/libpngworkaround/lib64 ${INSTALLPATH}"
	cd "${CWD}"
	echo "...finished applying workaround for PNG icons not showing up correctly in Stata GUI"
else
	WINDOWEDINSTALLPATH="${INSTALLPATH}"
fi
## run icon and mimetype install loop
echo "\ninstalling mimetypes and icons to system..."
for FILE in ${ICONPATH}/png/*.png ; do
	FILEBASE=$(basename "${FILE}")
	TARGET=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\1/')
	HPIXEL=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\2/')
	WPIXEL=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\3/')
	DEPTH=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\4/')
	if test "$TARGET" = 'statalogo' ; then
		echo "\t...installing Stata application icon (${HPIXEL}x${WPIXEL}px, ${DEPTH} bits)"
		xdg-icon-resource install --noupdate --context apps --mode system --size ${HPIXEL} "${FILE}" application-x-stata-stata${VERSION}logo
	else
		if test "${TARGETLIST#*${TARGET}}" = "${TARGETLIST}" ; then
			echo "\t...installing mimetype for file extension '.${TARGET}' to system"
			xdg-mime install --mode system "${PAYLOADPATH}/mimetypes/stata-statamimetype_${TARGET}.xml"
			TARGETLIST="${TARGETLIST} ${TARGET}"
		fi
		echo "\t...installing mimetype icon for file extension '.${TARGET}' (${HPIXEL}x${WPIXEL}px, ${DEPTH} bits) to system"
		xdg-icon-resource install --noupdate --context mimetypes --mode system --size ${HPIXEL} "${FILE}" application-x-stata-${TARGET}
	fi
done
echo "...finished installing icons and mimetypes to system"
## install application shortcuts
echo "installing application shortcuts to system..."
sed \
	-e "s:!!FLAVOUR!!:${FLAVOUR}:" \
	-e "s:!!VERSION!!:${VERSION}:" \
	-e "s:!!CONSOLE!!:${CONSOLE}:" \
	-e "s:!!INSTALLPATH!!:${INSTALLPATH}:" \
	<"${PAYLOADPATH}/shortcuts/stata-stata_console.desktop" >"${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
sed \
	-e "s:!!FLAVOUR!!:${FLAVOUR}:" \
	-e "s:!!VERSION!!:${VERSION}:" \
	-e "s:!!WINDOWED!!:${WINDOWED}:" \
	-e "s:!!INSTALLPATH!!:${WINDOWEDINSTALLPATH}:" \
	<"${PAYLOADPATH}/shortcuts/stata-stata_windowed.desktop" >"${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
xdg-desktop-menu install --noupdate --mode system "${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
xdg-desktop-menu install --noupdate --mode system "${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
xdg-desktop-menu forceupdate
rm "${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
rm "${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
echo "...finished installing application shortcuts to system"
echo "\nsetting default application for mimetypes..."
for TARGET in ${TARGETLIST} ; do
	MIMETYPE="application/x-stata-${TARGET}"
	for TARGETUSER in ${TARGETUSERS} ; do
		echo "\t...setting default application for mimetype '${MIMETYPE}' for user '${TARGETUSER}'"
		if test "${TARGETUSER}" = "${SUDO_USER}" ; then
			xdg-mime default stata-stata${VERSION}_windowed.desktop ${MIMETYPE}
		else
			sudo -u ${TARGETUSER} -H xdg-mime default stata-stata${VERSION}_windowed.desktop ${MIMETYPE}
		fi
	done
done
echo "...finished setting default application for mimetypes"
echo "\nrefreshing icon database..."
xdg-icon-resource forceupdate --mode system
echo "...finished refreshing icon database"
echo "\nrefreshing mimetype database..."
update-mime-database /usr/share/mime
echo "...finished refreshing mimetype database"
echo "\nrefreshing application shortcuts database..."
update-desktop-database /usr/share/applications
echo "...finished refreshing application shortcuts database"
# return command line parameters for repeating this, and exit
echo "\nEverything has finished; you can repeat this process via command line using the following command:\n\t${CALLER} --version ${VERSION} --flavour ${SHORTFLAVOUR} --libpngfix ${LIBPNGFIX} --path \"${INSTALLPATH}\" --users \"${TARGETUSERS}\""
exit ${EXIT_SUCCESS}
# EOF
