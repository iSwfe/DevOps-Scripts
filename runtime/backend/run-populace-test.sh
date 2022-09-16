#! /bin/bash

package=cpm-populace-server-test
port=9090
debugPort=44004
profile=test
path=./upload
configPath=./config/application-populace-${profile}.yml
supplyPath=

bash -il ~/.scripts/run-server.sh \
    ${package} \
    ${port} \
    ${debugPort} \
    ${profile} \
    ${path} \
    ${configPath} \
    ${supplyPath}

