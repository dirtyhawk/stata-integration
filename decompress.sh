#! /bin/sh
# This script installs Stata icons as mimetype icons, as well as the Stata
# mimetypes for .gph, .sem, .dta, .do, .stpr, .sthlp and .smcl files,
# into the system 
## Checking for root privileges
SCRIPTNAME=$(basename "$0")
if [ `id -u` != "0" ]; then
        echo "\nERROR!\nYou need root-privileges to run this script!\nTry running 'sudo ${SCRIPTNAME}'.\nExiting '{$SCRIPTNAME}'."
        exit $EXIT_ERROR
fi
echo "\nExtracting installer payload...\n"
PAYLOADPATH="$(mktemp -d /tmp/stata-integration.XXXXXX)"
ARCHIVE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' ${0})
tail -n+${ARCHIVE} ${0} | tar xzv -C ${PAYLOADPATH}
CDIR=$(pwd)
cd "${PAYLOADPATH}"
echo "\nRunning installer...\n"
./stata_integration_exec.sh "$@" --caller "${SCRIPTNAME}"
cd "${CDIR}"
rm -rf "${PAYLOADPATH}"
exit 0
# here starts the payload content
__ARCHIVE_BELOW__
