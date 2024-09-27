#! /bin/sh
# shellcheck enable=require-variable-braces
# This script installs Stata icons as mimetype icons, as well as the Stata
# mimetypes for .gph, .stsem, .dta, .do, .stpr, .sthlp and .smcl files,
# into the system 
SCRIPTNAME=$(basename "$0")
# ERROR-LEVELS
EXIT_SUCCESS=0 # everything fine
EXIT_ERROR=1 # user input error
EXIT_ABORT=2 # script exit upon user request
EXIT_USAGE=64 # wrong syntax
EXIT_FAILURE=3 # program error
# (TEMPORARY) PATH TO PAYLOAD DATA
PAYLOADPATH=$(cd "$(dirname "$0")" || exit; pwd)
# DEFAULT STATA INSTALLATION PATH
DEFAULTPATH='/usr/local/stata'
# EXACT VERSION NUMBER FOR LIBPNG 1.6
LIBPNG16VERSION="1.6.2"
# DOWNLOAD URL FOR LIBPNG 1.6
LIBPNG16URL="https://downloads.sourceforge.net/project/libpng/libpng16/older-releases/${LIBPNG16VERSION}/libpng-${LIBPNG16VERSION}.tar.gz"
# EXACT VERSION NUMBER FOR LIBPNG 1.2
LIBPNG12VERSION="1.2.59"
# DOWNLOAD URL FOR LIBPNG 1.2
LIBPNG12URL="https://downloads.sourceforge.net/project/libpng/libpng12/${LIBPNG12VERSION}/libpng-${LIBPNG12VERSION}.tar.gz"
# EXACT VERSION NUMBER FOR ZLIB 1.2
ZLIB12VERSION="1.2.3"
# DOWNLOAD URL FOR ZLIB
ZLIB12URL="https://downloads.sourceforge.net/project/libpng/zlib/${ZLIB12VERSION}/zlib-${ZLIB12VERSION}.tar.gz"
# MINIMUM AND MAXIMUM OF SUPPORTED STATA VERSIONS
MINSUPPORTEDVERSION=11
MAXSUPPORTEDVERSION=18
# DEFINE FUNCTIONS
prompt_msg(){
    MESSAGE=$*
    printf '\e[1;34mQuestion:\e[0m\t %b\n' "${MESSAGE}"
}

status_msg(){
    MESSAGE=$*
    printf '\e[1;32mInfo:\e[0m\t %b\n' "${MESSAGE}"
}

warning_msg(){
    MESSAGE=$*
    printf '\e[1;33mWARNING:\e[0m %b\n' "${MESSAGE}" 1>&2
}

error_msg(){
    MESSAGE=$*
    printf '\e[1;31mERROR:\e[0m\t %b\n' "${MESSAGE}" 1>&2
}

## Checking for root privileges
if [ "$(id -u)" != "0" ]; then
        error_msg "$(printf "You need root-privileges to run this script!\nTry running 'sudo %s'.\nExiting '%s'.\n" "${SCRIPTNAME}" "${SCRIPTNAME}")"
        exit "${EXIT_ERROR}"
fi
# parse arguments
TEMP=$(getopt --options v:f:p:u:l:c: --longoptions version:,flavour:,path:,users:,libpngfix: -- "$@")
# shellcheck disable=SC2181
if [ "$?" -ne 0 ];
then
	exit ${EXIT_USAGE}
fi
eval set -- "${TEMP}"
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
		--)
			shift;
			break;
		;;
	esac
done
## make clear what this script will do
status_msg "$(printf "For this script to run, you must have Stata already installed in your system;\n\tthis script will install icons and mimetypes for all Stata file types to your system,\n\tand add entries for Stata (console and windowed version) in your application menu -- not more, not less!\n\n\tIn order to do this, this script will ask you to provide the following information about your Stata environment:\n\t(1) The Stata flavour of your installation ('BE', 'small', 'IC', 'SE', or 'MP');\n\t(2) the version number of your Stata installation (integer number from '%s' through '%s');\n\t(3) the exact and full installation path to your Stata installation (most likely '/usr/local/stata', if you did not change the default);\n\t(4) if you want to install a workaround for using old variants of libpng and zlib, in case you attempt to use Stata 15 or older;\n\t(5) the user name(s) of all users to create filetype associations for.\n\nAll icons have been extracted from the official Stata for Windows binaries and are, as well as the term 'Stata', of course copyrighted property of StataCorp LLC.\n" "${MINSUPPORTEDVERSION}" "${MAXSUPPORTEDVERSION}")"
while true; do
	prompt_msg "$(printf 'Did you read an understand the above?')"
	read -r UNDERSTOOD
	case ${UNDERSTOOD} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
			break
		;;
		* )
			error_msg "$(printf 'Sorry, this script is not meant for you.')"
			exit ${EXIT_ERROR}
		;;
	esac
done
## query Stata flavour that has been installed
if [ -z "${ARGFLAVOUR}" ] ; then
	while true; do
		prompt_msg "$(printf '(1) Which Stata flavour do you have installed?')"
		read -r QUERIEDFLAVOUR
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
			[Ss][Mm][Aa][Ll][Ll]|[Bb][Ee] )
				FLAVOUR='small Stata'
				WINDOWED=xstata-sm
				CONSOLE=stata-sm
				break
			;;
			* )
				warning_msg "$(printf "Valid answers are 'MP', 'SE', 'IC', 'BE', or 'small'")"
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
		[Ss][Mm][Aa][Ll][Ll]|[Bb][Ee] )
			FLAVOUR='small Stata'
			WINDOWED=xstata-sm
			CONSOLE=stata-sm
		;;
		* )
			error_msg "$(printf "Valid arguments to \e[1m--flavour\e[0m are 'MP', 'SE', 'IC', 'BE', or 'small'; you specified \e[1m--flavour %s\e[0m" "${ARGFLAVOUR}")"
			exit ${EXIT_USAGE}
		;;
	esac
	SHORTFLAVOUR="${ARGFLAVOUR}"
	status_msg "$(printf "You already answered (1) via command line: \e[1m--flavour %s\e[0m" "${SHORTFLAVOUR}")"
fi
## query Stata version number
if [ -z "${ARGVERSION}" ] ; then
	prompt_msg "$(printf '(2) Please specify the Stata version number of your Stata installation [%s]:' "${MAXSUPPORTEDVERSION}")"
	read -r QUERIEDVERSION
	if [ "${QUERIEDVERSION}" = "" ] ; then
		VERSION=${MAXSUPPORTEDVERSION}
	elif [ -z "${QUERIEDVERSION##*[!0-9]*}" ] ; then
		error_msg "$(printf 'only positive integer values are allowed as version numbers')"
		exit ${EXIT_ERROR}
	else
		VERSION=${QUERIEDVERSION}
	fi
else
	if [ -z "${ARGVERSION##*[!0-9]*}" ] ; then
		error_msg "$(printf 'only positive integer values are allowed as version numbers')"
		exit ${EXIT_ERROR}
	else
		VERSION=${ARGVERSION}
	fi
	status_msg "$(printf "You already answered (2) via command line: \e[1m--version %s\e[0m" "${ARGVERSION}")"
fi
## query Stata installation directory
if [ -z "${ARGPATH}" ] ; then
	while true; do
		prompt_msg "$(printf '(3) Please specify the directory of your Stata installation [%s]:' "${DEFAULTPATH}")"
		read -r QUERIEDPATH
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
	status_msg "$(printf "You already answered (3) via command line: \e[1m--path %s\e[0m" "${ARGPATH}")"
fi
## query whether to apply the libpng/zlib to manually use older versions of the two named libraries
if [ -z "${ARGLIBPNGFIX}" ] ; then
	if [ "${VERSION}" -le "15" ]; then
		prompt_msg "$(printf "(4) Stata 15 or older relies on libpng versions %s and %s as well as zlib version %s.\n\tModern Linux distributions feature newer versions of these libraries.\n\tThis leads to Stata not being able to display icons in its menu bars,\n\tbut showing icons with question marks everywhere in the graphical user interface.\n\n\tYou should now have a look at your Stata installation; if you see normal icons in Stata's graphical user interface, you're fine.\n\tIf not, this script can try to work around this issue by\n\t\t(a) manually auto-downloading the old library variants,\n\t\t(b) building these libraries from source, and\n\t\t(c) telling Stata explicitly to use these manually saved variants instead of the system libraries.\n\n\tThis will erase the directory '%s/libpngworkaround/' and all its contents, if existing, without further notice.\n\n\tRemember that this is not required (and would have no effect at all) in Stata 16 or younger.\n\n\tPlease specify whether you want the script to implement this workaround:" "${LIBPNG12VERSION}" "${LIBPNG16VERSION}" "${ZLIB12VERSION}" "${INSTALLPATH}")"
		read -r QUERIEDLIBPNGFIX
		case ${QUERIEDLIBPNGFIX} in
			[Yy]|[Yy][Ee]|[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee] )
				LIBPNGFIX="true"
			;;
			[Nn]|[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee] )
				LIBPNGFIX="false"
			;;
			* )
				error_msg "$(printf 'Sorry, this script is not meant for you.')"
				exit ${EXIT_ERROR}
			;;
		esac
	else
		LIBPNGFIX="false"
	fi
else
	case ${ARGLIBPNGFIX} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee] )
			LIBPNGFIX="true"
		;;
		[Nn]|[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee] )
			LIBPNGFIX="false"
		;;
		* )
			error_msg "$(printf 'Invalid argument for option \e[1m--libpngfix\e[0m: \e[1m%s\e[0m' "${ARGLIBPNGFIX}")"
			exit ${EXIT_ERROR}
		;;
	esac
	status_msg "$(printf "You already answered (4) via command line: \e[1m--libpngfix %s\e[0m" "${ARGLIBPNGFIX}")"
fi
## query users to create file type associations for
if [ -z "${ARGUSERS}" ] ; then
	prompt_msg "$(printf "(5) Please specify a space-separated (!) list of all users you want to create file type associations for [%s]:" "${SUDO_USER}")"
	read -r QUERIEDTARGETUSERS
	if [ "${QUERIEDTARGETUSERS}" = "" ] ; then
		TARGETUSERS="${SUDO_USER}"
	else
		TARGETUSERS="${QUERIEDTARGETUSERS}"
	fi
else
	TARGETUSERS="${ARGUSERS}"
	status_msg "$(printf "You already answered (5) via command line: \e[1m--users %s\e[0m" "${ARGUSERS}")"
fi
## check if given installation directory is valid
if [ ! -d "${INSTALLPATH}" ]; then
	error_msg "$(printf '\e[1m%s\e[0m is not a valid directory.' "${INSTALLPATH}")"
	exit ${EXIT_ERROR}
fi
## check if Stata executables are found in the installation directory
for EXE in "${WINDOWED}" "${CONSOLE}" ; do
	if [ ! -x "${INSTALLPATH}/${EXE}" ]; then
		error_msg "$(printf 'Stata executable \e[1m%s\e[0m not found in install directory \e[1m%s\e[0m' "${EXE}" "${INSTALLPATH}")"
		exit ${EXIT_ERROR}
	fi
done
## check if this script is capable to work with specified Stata version
if [ ! -d "${PAYLOADPATH}/icons/${VERSION}" ]; then
	if [ "${VERSION}" -gt "${MAXSUPPORTEDVERSION}" ] ; then
		FALLBACKVERSION=${MAXSUPPORTEDVERSION}
	elif [ "${VERSION}" -lt "${MINSUPPORTEDVERSION}" ] ; then
		FALLBACKVERSION=${MINSUPPORTEDVERSION}
	else
		error_msg "$(printf 'Congratulations! You found a bug in this script. Your version number \e[1m%s\e[0m is neither larger than the latest supported Stata version, nor lower than the earliest supported Stata version. Please report this to the author.' "${VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	while true; do
		warning_msg "$(printf 'Warning: this script does not contain specific icons and mimetype associations for Stata \e[1m%s\e[0m; do you want to use icons from Stata \e[1m%s\e[0m instead?' "${VERSION}" "${FALLBACKVERSION}")"
		read -r USEFALLBACK
		case ${USEFALLBACK} in
			[Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
				break
			;;
			[Nn]|[Nn][Oo] )
				error_msg "$(printf 'Script aborted.')"
				exit ${EXIT_ABORT}
			;;
			* )
				error_msg "$(printf 'Sorry, this script is not meant for you.')"
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
status_msg "$(printf 'Everything you entered seems to be fine;\n\tyou can use the same configuration parameters again via command line using the following arguments:\n\n\t\e[1m--version %s --flavour %s --libpngfix %s --path "%s" --users "%s"\e[0m' "${VERSION}" "${SHORTFLAVOUR}" "${LIBPNGFIX}" "${INSTALLPATH}" "${TARGETUSERS}")"
while true; do
	prompt_msg "$(printf "Shall we begin the installation task?")"
	read -r LETSRIDE
	case ${LETSRIDE} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
			break
		;;
		* )
			status_msg "$(printf 'Okay, see you next time.')"
			exit ${EXIT_ABORT}
		;;
	esac
done
## get Gnome icon pack name
CURRENT_ICON_THEME=$(dconf read /org/gnome/desktop/interface/icon-theme | tr -d '\047')
if [ -z "${CURRENT_ICON_THEME}" ]; then
	CURRENT_ICON_THEME="hicolor"
fi
## applying fix for libpng and zlib, if requested
## source: https://bitbucket.org/vilhuberl/stata-png-fix and 
## http://www.statalist.org/forums/forum/general-stata-discussion/general/2199-linux-stata-bug-libpng-on-newer-opensuse-possibly-other-distributions
if [ "${LIBPNGFIX}" = "true" ]; then
	status_msg "$(printf 'Starting to apply workaround for PNG icons not showing up correctly in Stata GUI...')"
	if [ -x "${INSTALLPATH}/libpngworkaround" ]; then
		rm -rf "${INSTALLPATH}/libpngworkaround"
	fi
	mkdir "${INSTALLPATH}/libpngworkaround"
	BUILDDIR="${PAYLOADPATH}/build"
	CWD=$(pwd)
	mkdir "${BUILDDIR}"
	cd "${BUILDDIR}" || exit
	status_msg "$(printf 't...downloading zlib %s' "${ZLIB12VERSION}")"
	if ! wget -q --show-progress "${ZLIB12URL}"
	then
		error_msg "$(printf '\t...error downloading zlib, we can not continue; please check if you have internet access and try again')"
		exit "${EXIT_FAILURE}"
	fi
	status_msg "$(printf '\t...downloading libpng 1.2')"
	if ! wget -q --show-progress "${LIBPNG12URL}"
	then
		error_msg "$(printf '\t...error downloading libpng 1.2, we can not continue; please check if you have internet access and try again')"
		exit "${EXIT_FAILURE}"
	fi
	status_msg "$(printf '\t...downloading libpng %s' "${LIBPNG16VERSION}")"
	if ! wget -q --show-progress "${LIBPNG16URL}"
	then
		error_msg "$(printf '\t...error downloading libpng %s, we can not continue; please check if you have internet access and try again' "${LIBPNG16VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	echo "--- libpng-${LIBPNG16VERSION}/scripts/pnglibconf.dfa	2013-04-25 08:24:45.000000000 -0400
+++ libpng-${LIBPNG16VERSION}/scripts/pnglibconf.dfa.patched	2014-04-25 22:28:34.273329264 -0400
@@ -232,7 +232,7 @@
 # The TEXT values are the defaults when writing compressed text (all forms)
 #
 # Include the zlib header too, so that the defaults below are known
-@#  include <zlib.h>
+#@#  include <zlib.h>
 
 # The '@' here means to substitute the value when pnglibconf.h is built
 setting Z_DEFAULT_COMPRESSION default @Z_DEFAULT_COMPRESSION" > stata-png16.patch
	status_msg "$(printf '\t...unpacking zlib')"
	if ! tar zxf "zlib-${ZLIB12VERSION}.tar.gz"
	then
		error_msg "$(printf '\t...error unpacking zlib %s, we can not continue' "${ZLIB12VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	cd zlib-${ZLIB12VERSION} || exit
	status_msg "$(printf '\t...compiling zlib')"
	export CFLAGS="-fPIC"
	if ! ./configure --prefix="${INSTALLPATH}"/libpngworkaround >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error configuring zlib, we can not continue')"
		exit "${EXIT_FAILURE}"
	fi
	if ! make -s >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error making zlib, we can not continue')"
		exit "${EXIT_FAILURE}"
	fi
	status_msg "$(printf '\t...installing zlib to %s/libpngworkaround/lib' "${INSTALLPATH}")"
	if ! make -s install >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error installing zlib, we can not continue')"
		exit "${EXIT_FAILURE}"
	fi
	cd "${BUILDDIR}" || exit
	status_msg "$(printf '\t...unpacking libpng %s' "${LIBPNG12VERSION}")"
	if ! tar xzf "libpng-${LIBPNG12VERSION}.tar.gz"
	then
		error_msg "$(printf '\t...error unpacking libpng %s, we can not continue' "${LIBPNG12VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	cd libpng-${LIBPNG12VERSION} || exit
	status_msg "$(printf '\t...compiling libpng %s' "${LIBPNG12VERSION}")"
	export CFLAGS="-I${INSTALLPATH}/libpngworkaround/include -fPIC"
	export LDFLAGS="-L${INSTALLPATH}/libpngworkaround/lib"
	if ! ./configure --prefix="${INSTALLPATH}/libpngworkaround" >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error configuring libpng %s, we can not continue' "${LIBPNG12VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	if ! make -s >/dev/null 2>&1
	then
		error_msg "$(printf "\t...error making libpng %s, we can not continue; is please check if your distribution's package 'zlib1g-dev' is installed, and try again" "${LIBPNG12VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	status_msg "$(printf '\t...installing libpng %s to %s/libpngworkaround/lib' "${LIBPNG12VERSION}" "${INSTALLPATH}")"
	if ! make -s install >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error installing libpng %s, we can not continue' "${LIBPNG12VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	cd "${BUILDDIR}" || exit
	status_msg "$(printf '\t...unpacking libpng %s' "${LIBPNG16VERSION}")"
	if ! tar xzf "libpng-${LIBPNG16VERSION}.tar.gz"
	then
		error_msg "$(printf '\t...error unpacking libpng %s, we can not continue' "${LIBPNG12VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	cd "libpng-${LIBPNG16VERSION}" || exit
	status_msg "$(printf '\t...compiling libpng %s' "${LIBPNG16VERSION}")"
	export CFLAGS="-I${INSTALLPATH}/libpngworkaround/include -fPIC"
	export LDFLAGS="-L${INSTALLPATH}/libpngworkaround/lib"
	if ! ./configure --prefix="${INSTALLPATH}/libpngworkaround" >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error configuring libpng %s, we can not continue' "${LIBPNG16VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	patch -p1 < ../stata-png16.patch >/dev/null 2>&1
	if ! make -s >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error making libpng %s, we can not continue' "${LIBPNG16VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	status_msg "$(printf '\t...installing libpng %s to %s/libpngworkaround/lib' "${LIBPNG16VERSION}" "${INSTALLPATH}")"
	if ! make -s install >/dev/null 2>&1
	then
		error_msg "$(printf '\t...error installing libpng %s, we can not continue' "${LIBPNG16VERSION}")"
		exit "${EXIT_FAILURE}"
	fi
	INSTALLPATHWITHLIBS="/usr/bin/env LD_LIBRARY_PATH=${INSTALLPATH}/libpngworkaround/lib\:${INSTALLPATH}/libpngworkaround/lib64 ${INSTALLPATH}"
	cd "${CWD}" || exit
	status_msg "$(printf '...finished applying workaround for PNG icons not showing up correctly in Stata GUI')"
else
	INSTALLPATHWITHLIBS="${INSTALLPATH}"
fi
## run icon and mimetype install loop
status_msg "$(printf 'installing mimetypes and icons to system...')"
for FILE in "${ICONPATH}"/png/*.png ; do
	FILEBASE=$(basename "${FILE}")
	TARGET=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\1/')
	HPIXEL=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\2/')
	WPIXEL=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\3/')
	DEPTH=$(echo "${FILEBASE}" | sed -r 's/stata-([a-z]+)_([0-9]+)x([0-9]+)x([0-9]+)\.png/\4/')
	if [ "${TARGET}" = 'statalogo' ] ; then
		status_msg "$(printf '\t...installing Stata application icon (%sx%spx, %s bits)' "${HPIXEL}" "${WPIXEL}" "${DEPTH}")"
		status_msg "$(printf '\t\t...to the fallback theme: \e[1mhicolor\e[0m')"
		xdg-icon-resource install --noupdate --context apps --mode system --size "${HPIXEL}" "${FILE}" "application-x-stata-stata${VERSION}logo"
		if [ "${CURRENT_ICON_THEME}" != "hicolor" ]; then
			status_msg "$(printf '\t\t...to the current theme: \e[1m%s\e[0m' "${CURRENT_ICON_THEME}")"
			xdg-icon-resource install --theme "${CURRENT_ICON_THEME}" --noupdate --context apps --mode system --size "${HPIXEL}" "${FILE}" "application-x-stata-stata${VERSION}logo"
		fi
	else
		if [ "${TARGETLIST#*"${TARGET}"}" = "${TARGETLIST}" ] ; then
			status_msg "$(printf '\t...installing mimetype for file extension \e[1m%s\e[0m to system' "${TARGET}")"
			xdg-mime install --mode system "${PAYLOADPATH}/mimetypes/stata-statamimetype_${TARGET}.xml"
			TARGETLIST="${TARGETLIST} ${TARGET}"
		fi
		status_msg "$(printf '\t...installing mimetype icon for file extension \e[1m%s\e[0m (%sx%spx, %s bits) to system' "${TARGET}" "${HPIXEL}" "${WPIXEL}" "${DEPTH}")"
		status_msg "$(printf '\t\t...to the fallback theme: \e[1mhicolor\e[0m')"
		xdg-icon-resource install --noupdate --context mimetypes --mode system --size "${HPIXEL}" "${FILE}" "application-x-stata-${TARGET}"
		if [ "${CURRENT_ICON_THEME}" != "hicolor" ]; then
			status_msg "$(printf '\t\t...to the current theme: \e[1m%s\e[0m' "${CURRENT_ICON_THEME}")"
			xdg-icon-resource install --theme "${CURRENT_ICON_THEME}" --noupdate --context mimetypes --mode system --size "${HPIXEL}" "${FILE}" "application-x-stata-${TARGET}"
		fi
	fi
done
status_msg "$(printf '...finished installing icons and mimetypes to system')"
## install application shortcuts
status_msg "$(printf 'installing application shortcuts to system...')"
sed \
	-e "s:!!FLAVOUR!!:${FLAVOUR}:" \
	-e "s:!!VERSION!!:${VERSION}:" \
	-e "s:!!CONSOLE!!:${CONSOLE}:" \
	-e "s:!!INSTALLPATH!!:${INSTALLPATHWITHLIBS}:" \
	<"${PAYLOADPATH}/shortcuts/stata-stata_console.desktop" >"${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
sed \
	-e "s:!!FLAVOUR!!:${FLAVOUR}:" \
	-e "s:!!VERSION!!:${VERSION}:" \
	-e "s:!!WINDOWED!!:${WINDOWED}:" \
	-e "s:!!INSTALLPATH!!:${INSTALLPATHWITHLIBS}:" \
	<"${PAYLOADPATH}/shortcuts/stata-stata_windowed.desktop" >"${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
xdg-desktop-menu install --noupdate --mode system "${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
xdg-desktop-menu install --noupdate --mode system "${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
xdg-desktop-menu forceupdate
rm "${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
rm "${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
status_msg "$(printf '...finished installing application shortcuts to system')"
status_msg "$(printf 'setting default application for mimetypes...')"
for TARGET in ${TARGETLIST} ; do
	MIMETYPE="application/x-stata-${TARGET}"
	for TARGETUSER in ${TARGETUSERS} ; do
		status_msg "$(printf '\t...setting default application for mimetype \e[1m%s\e[0m for user \e[1m%s\e[0m' "${MIMETYPE}" "${TARGETUSER}")"
		if test "${TARGETUSER}" = "${SUDO_USER}" ; then
			xdg-mime default "stata-stata${VERSION}_windowed.desktop" "${MIMETYPE}"
		else
			sudo -u "${TARGETUSER}" -H xdg-mime default stata-stata"${VERSION}"_windowed.desktop "${MIMETYPE}"
		fi
	done
done
status_msg "$(printf '...finished setting default application for mimetypes')"
status_msg "$(printf 'refreshing icon database...')"
xdg-icon-resource forceupdate --mode system
status_msg "$(printf '...finished refreshing icon database')"
status_msg "$(printf 'refreshing mimetype database...')"
update-mime-database /usr/share/mime
status_msg "$(printf '...finished refreshing mimetype database')"
status_msg "$(printf 'refreshing application shortcuts database...')"
update-desktop-database /usr/share/applications
status_msg "$(printf '...finished refreshing application shortcuts database')"
# return command line parameters for repeating this, and exit
status_msg "$(printf 'Everything has finished; you can repeat this process via command line using the following arguments:\n\n\t\e[1m--version %s --flavour %s --libpngfix %s --path "%s" --users "%s"\e[0m' "${VERSION}" "${SHORTFLAVOUR}" "${LIBPNGFIX}" "${INSTALLPATH}" "${TARGETUSERS}")"
exit ${EXIT_SUCCESS}
# EOF
