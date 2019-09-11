#! /bin/sh
# This script batch-extracts ICO icons from a Windows executable using -wrestool-
# Mandatory parameters for invocation: 
#	--binary "<path_to_Stata_for_Windows_executable>"
#	--version "<Stata version>"
### SCRIPT-INTERNAL VARIABLES, DON'T CHANGE ###
SCRIPTNAME=$(basename "$0")
# ERROR-LEVELS
EXIT_SUCCESS=0 # everything fine
EXIT_ERROR=1 # user input error
EXIT_ABORT=2 # script exit upon user request
EXIT_USAGE=64 # wrong syntax
EXIT_FAILURE=3 # program error
### PARSE COMMAND-LINE ARGUMENTS ###
TEMP=$(getopt --options b:v: --longoptions binary:,version: -n "${SCRIPTNAME}" -- "$@")
if [ $? -ne 0 ];
then
	exit ${EXIT_USAGE}
fi
eval set -- "$TEMP"
unset STATA_BINARY_VERSION
unset STATA_BINARY
while true ; do
	case "$1" in
		-v|--version)
			STATA_BINARY_VERSION="$2"; shift 2; continue;;
		-b|--binary)
			STATA_BINARY="$2"; shift 2; continue;;
		--)
                        shift; break ;;
        esac
done
if [ -z ${STATA_BINARY_VERSION} ];
then
	echo "argument '--version <Stata version>' required"
	exit ${EXIT_USAGE}
fi
if [ -z ${STATA_BINARY} ];
then
	echo "argument '--binary <path_to_Stata_for_Windows_executable>' required"
	exit ${EXIT_USAGE}
fi
### VARIABLES THAT MAY CHANGE WITH NEW Stata VERSIONs ###
# list of filetype icons to extract ("statalogo" means the main application icon)
ICON_LIST="statalogo dta gph do smcl sem stpr"
# index numbers of each of the filetype icons in the Windows .exe-binary of Stata
# you can determine these index numbers by running 'wrestool --type=-14 -l "${STATA_BINARY}"'
ICON_INDEX_statalogo="130"
ICON_INDEX_dta="131"
ICON_INDEX_gph="132"
ICON_INDEX_do="133"
ICON_INDEX_smcl="134"
ICON_INDEX_sem="135"
ICON_INDEX_stpr="136"
### START OF SCRIPT ###
SUBDIR="${STATA_BINARY_VERSION}/"
mkdir -p ${SUBDIR}ico/
rm -f ${SUBDIR}ico/*.ico
for RESOURCE in ${ICON_LIST} ; do
	INDEXED_RESOURCE="ICON_INDEX_${RESOURCE}"
	INDEXED_RESOURCE=$(eval "echo \$$INDEXED_RESOURCE")
	echo "extracting stata-${RESOURCE}.ico [resource index ${INDEXED_RESOURCE}] from ${STATA_BINARY}"
	wrestool --verbose --extract --name=-${INDEXED_RESOURCE} --type=-14 "${STATA_BINARY}" --output="${SUBDIR}ico/stata-${RESOURCE}.ico"
done
exit ${EXIT_SUCCESS}
# EOF
