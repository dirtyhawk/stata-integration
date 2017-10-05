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
PAYLOADPATH=$(dirname "$0")
# DEFAULT STATA INSTALLATION PATH
DEFAULTPATH='/usr/local/stata'
# MINIMUM AND MAXIMUM OF SUPPORTED STATA VERSIONS
MINSUPPORTEDVERSION=11
MAXSUPPORTEDVERSION=15
## Checking for root privileges
if [ `id -u` != "0" ]; then
        echo "\nERROR!\nYou need root-privileges to run this script!\nTry running 'sudo $SCRIPTNAME'.\nExiting '$SCRIPTNAME'."
        exit $EXIT_ERROR
fi
# parse arguments
TEMP=$(getopt --options v:f:p:u:c: --longoptions version:,flavour:,path:,users:,caller: -n "${SCRIPTNAME}" -- "$@")
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
echo "For this script to run, you must have Stata already installed in your system; this script will install icons and mimetypes for all Stata file types to your system and add entries for Stata (console and windowed version) in your application menu -- not more, not less!\n\nIn order to do this, this script will ask you to provide the following information about your Stata installation:\n(1) The Stata flavour of your installation ('small', 'IC', 'SE', or 'MP');\n(2) the version number of your Stata installation (integer number, e.g. '13' or '14');\n(3) the exact and full installation path to your Stata installation (most likely '/usr/local/stata', if you did not change the default);\n(4) the user name(s) of all users to create filetype associations for.\n\nAll Stata icons and logos as well as the term 'Stata' are, of course, property of StataCorp."
while true; do
	echo "\nDid you read an understand the above?"
	read UNDERSTOOD
	case ${UNDERSTOOD} in
		[Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
			break
		;;
		* )
			echo "Sorry, this script is not meant for you."
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
			echo "Valid flavours are 'MP', 'SE', 'IC', or 'small'; you specified '--flavour ${ARGFLAVOUR}'"
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
		echo "only positive integer values are allowed as version numbers"
		exit ${EXIT_ERROR}
	else
		VERSION=${QUERIEDVERSION}
	fi
else
	if [ -z "${ARGVERSION##*[!0-9]*}" ] ; then
		echo "only positive integer values are allowed as version numbers"
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
## query users to create file type associations for
if [ -z "${ARGUSERS}" ] ; then
	echo "\n(4) Please specify a space-separated (!) list of all users you want to create file type associations for [${SUDO_USER}]:"
	read QUERIEDTARGETUSERS
	echo "\n"
	if [ "${QUERIEDTARGETUSERS}" = "" ] ; then
		TARGETUSERS="${SUDO_USER}"
	else
		TARGETUSERS="${QUERIEDTARGETUSERS}"
	fi
else
	TARGETUSERS="${ARGUSERS}"
	echo "\nYou already answered (4) via command line: users '${ARGUSERS}'"
fi
## check if given installation directory is valid
if [ ! -d "${INSTALLPATH}" ]; then
	echo "'${INSTALLPATH}' is not a valid directory."
	exit ${EXIT_ERROR}
fi
## check if Stata executables are found in the installation directory
for EXE in "${WINDOWED}" "${CONSOLE}" ; do
	if [ ! -x "${INSTALLPATH}/${EXE}" ]; then
		echo "Stata executable '${EXE}' not found in install directory '${INSTALLPATH}'."
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
		echo "Congratulations! You found a bug in this script. Your version number ${VERSION} is neither larger than the latest supported Stata version, nor lower than the earliest supported Stata version. Please report this to the author."
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
				echo "Sorry, this script is not meant for you."
				exit ${EXIT_ERROR}
			;;
		esac
	done
	ICONVERSION=${FALLBACKVERSION}
	else
	ICONVERSION=${VERSION}
fi
ICONPATH="${PAYLOADPATH}/icons/${ICONVERSION}"
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
	-e "s/!!FLAVOUR!!/${FLAVOUR}/" \
	-e "s/!!VERSION!!/${VERSION}/" \
	-e "s/!!CONSOLE!!/${CONSOLE}/" \
	-e "s:!!INSTALLPATH!!:${INSTALLPATH}:" \
	<"${PAYLOADPATH}/shortcuts/stata-stata_console.desktop" >"${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
sed \
	-e "s/!!FLAVOUR!!/${FLAVOUR}/" \
	-e "s/!!VERSION!!/${VERSION}/" \
	-e "s/!!WINDOWED!!/${WINDOWED}/" \
	-e "s:!!INSTALLPATH!!:${INSTALLPATH}:" \
	<"${PAYLOADPATH}/shortcuts/stata-stata_windowed.desktop" >"${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
xdg-desktop-menu install --noupdate --mode system "${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
xdg-desktop-menu install --noupdate --mode system "${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
xdg-desktop-menu forceupdate
rm "${PAYLOADPATH}/stata-stata${VERSION}_windowed.desktop"
rm "${PAYLOADPATH}/stata-stata${VERSION}_console.desktop"
echo "...finished installing application shortcuts to system"
echo "setting default application for mimetypes..."
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
echo "refreshing icon database..."
xdg-icon-resource forceupdate --mode system
echo "...finished refreshing icon database"
echo "refreshing mimetype database..."
update-mime-database /usr/share/mime
echo "...finished refreshing mimetype database"
echo "refreshing application shortcuts database..."
update-desktop-database /usr/share/applications
echo "...finished refreshing application shortcuts database"
# return command line parameters for repeating this, and exit
echo "\nEverything has finished; you can repeat this process via command line using the following command:\n\t${CALLER} --version ${VERSION} --flavour ${SHORTFLAVOUR} --path \"${INSTALLPATH}\" --users \"${TARGETUSERS}\""
exit ${EXIT_SUCCESS}
# EOF
