#!/bin/bash
source ~/.scripts/.function.log.sh

projectRoot=$1
gitBranch=$2
packageName=$3
packageFile=$4
env=$5

server=$6
serverDeployPath=$7
serverPath=$8
serverDeployScript=$9

infolog "Start package... gitBranch=${gitBranch} packageName=${packageName}"
bash ~/.scripts/package.sh ${projectRoot} ${gitBranch}
checkResult $? "Package"

infolog "Start upload... ${packageFile} => ${server}(server)"
bash ~/.scripts/upload.sh ${packageFile} ${server} ${serverPath}
checkResult $? "Upload"

infolog "Start deploy... server=${server} serverPath=${serverPath}"
ssh -t ${server} "cd ${serverDeployPath} && bash ${serverDeployScript}"
checkResult $? "Deploy"

