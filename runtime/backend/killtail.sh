#!/bin/bash -il

pid=`ps -ef | awk '$8 ~ /tail/ {print $2}'`
[ -z "$pid" ] && echo 'not found.' && exit;

echo "=====found pid====="
echo "$pid"
echo "==================="
kill -9 $pid && echo 'killed.'

