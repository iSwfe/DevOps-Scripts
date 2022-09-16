#!/bin/bash
source ~/.scripts/.function.log.sh

uploadFile=$1
server=$2
serverPath=$3

[[ ! -e ${uploadFile} ]] && errorlog "Miss jar file:[${uploadFile}]" && exit -1

ls -l ${uploadFile}
scp ${uploadFile} ${server}:${serverPath}

