#! /bin/sh
# This script batch-extracts PNG icons from ICO files using -icotool-
SCRIPTNAME=$(basename "$0")
# ERROR-LEVELS
EXIT_SUCCESS=0 # everything fine
EXIT_ERROR=1 # user input error
EXIT_ABORT=2 # script exit upon user request
EXIT_USAGE=64 # wrong syntax
EXIT_FAILURE=3 # program error
for SUBDIR in */ ; do
	rm ${SUBDIR}png/*.png
	for ICOFILE in ${SUBDIR}ico/*.ico ; do
		icotool -x -o ${SUBDIR}png/ "${ICOFILE}"
	done
	for PNGFILE in ${SUBDIR}png/*.png ; do
		TARGET=$(echo "${PNGFILE}" | sed -r 's/stata-([a-z]+)_([0-9]+)_(([0-9]+)x([0-9]+)x([0-9]+)\.png)/stata-\1_\3/')
		mv "${PNGFILE}" "${TARGET}"
	done
done
exit ${EXIT_SUCCESS}
# EOF
