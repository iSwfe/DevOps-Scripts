#!/bin/bash

projectRoot=gz-public-security-server
gitBranch=master
packageName=cpm-populace-server
packageFile=${projectRoot}/target/${packageName}.jar
env=test

server=lc227
serverDeployPath=./runtime/backend
serverPath=${serverDeployPath}/upload/${packageName}-${env}.jar
serverDeployCommand="bash -il run-populace-${env}.sh"

[ ! -d logs ] && mkdir logs
now=$(date '+%Y-%m-%d_%H:%M')
script -qfc "bash deploy.sh \
    ${projectRoot} \
    ${gitBranch} \
    ${packageName} \
    ${packageFile} \
    ${env} \
    ${server} \
    ${serverDeployPath} \
    ${serverPath} \
    '${serverDeployCommand}' \
" logs/${0##*/}_${now}.log

