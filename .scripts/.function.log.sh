#!/bin/bash

# Color Settings
BLACK=0
RED=1
BLUE=4
# Log Functions
LOG_SCRIPT=${0##*/}
function log() {
    tput bold; tput smul; tput setaf $1;
    echo "[${LOG_SCRIPT}] $2";
    tput init;
}
function infolog() {
    log $BLUE "$1";
}
function errorlog() {
    log $RED "$1";
}

function checkResult() {
    result=$1
    action=$2
    [[ 0 != ${result} ]] && errorlog "${action} failed." && exit -1;
    infolog "${action} success."
}
