#! /bin/bash

package=cpm-populace-server-test
app=java
port="9090"

tailPid=$(ps -ef | awk '!/awk/ && /tail.*'${package}'/ {print $2}')
[[ -n $tailPid ]] && kill -9 $tailPid

pid=$(ps -ef | awk '$8 ~ /'$app'/ && /'$port'/ {print $2}')
[ -z $pid ] && echo "port($port) not found." && exit;

echo pid=$pid
kill -9 $pid && echo "port($port) killed."

