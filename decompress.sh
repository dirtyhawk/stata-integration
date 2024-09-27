#! /bin/sh
# shellcheck enable=require-variable-braces
# This script installs Stata icons as mimetype icons, as well as the Stata
# mimetypes for .gph, .stsem, .dta, .do, .stpr, .sthlp and .smcl files,
# into the system 
SCRIPTNAME=$(basename "$0")
## Checking for root privileges
if is_root; then
        error_msg "$(printf "Do not invoke this script with superuser privileges!\n\tTry running \e[1m%s\e[0m instead of \e[1msudo %s\e[0m.\n\tExiting." "${SCRIPTNAME}" "${SCRIPTNAME}")"
        exit "${EXIT_ERROR}"
fi
status_msg "$(printf "Extracting installer payload...")"
PAYLOADPATH="$(mktemp -d /tmp/stata-integration.XXXXXX)"
status_msg "$(printf "\t...temporary directory is %s" "${PAYLOADPATH}")"
ARCHIVE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "${0}")
tail -n+"${ARCHIVE}" "${0}" | tar xz -C "${PAYLOADPATH}"
CDIR="$(pwd)"
cd "${PAYLOADPATH}" || exit
status_msg "$(printf "Running installer...")"
./stata_integration_exec.sh "$@" --caller "${SCRIPTNAME}"
cd "${CDIR}" || exit
rm -rf "${PAYLOADPATH}"
exit 0
# here starts the payload content
# shellcheck disable=SC2317
__ARCHIVE_BELOW__
