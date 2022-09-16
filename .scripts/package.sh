#!/bin/bash
source ~/.scripts/.function.log.sh

projectRoot=$1
gitBranch=$2

cd ${projectRoot}
git reset --hard > /dev/null
git fetch > /dev/null \
    && git checkout -t remotes/origin/${gitBranch} -B ${gitBranch} > /dev/null 2>&1

infolog "Update remote branch [${gitBranch}]... ↓↓↓"
git pull origin

infolog "Get latest commit: ↓↓↓"
git reset --hard
checkResult $? "Update remote branch"
sleep 3

mvn clean package -Dmaven.test.skip=true

