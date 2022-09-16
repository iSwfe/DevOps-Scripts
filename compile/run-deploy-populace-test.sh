#!/bin/bash

projectRoot=gz-public-security-server
gitBranch=master
packageName=cpm-populace-server
packageFile=${projectRoot}/target/${packageName}.jar
env=test

server=lc227
serverDeployPath=./runtime/backend
serverPath=${serverDeployPath}/upload/${packageName}-${env}.jar
serverDeployScript=run-populace-${env}.sh

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
    ${serverDeployScript} \
" logs/${0##*/}_${now}.log

