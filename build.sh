#!/bin/sh
# shellcheck enable=require-variable-braces
CDIR=$(pwd)
PARENTDIR=$(dirname "${0}")
cd "${PARENTDIR}/payload" || exit
tar cf ../payload.tar ./*
cd ..
if [ -e "payload.tar" ]; then
    gzip payload.tar
    if [ -e "payload.tar.gz" ]; then
        cat "decompress.sh" "payload.tar.gz" > "build/stata-integration.bin"
	chmod u+x "build/stata-integration.bin"
    else
        echo "payload.tar.gz does not exist"
        exit 1
    fi
else
    echo "payload.tar does not exist"
    exit 1
fi
rm "payload.tar.gz"
cd "${CDIR}" || exit
echo "build/stata-integration.bin created"
exit 0
