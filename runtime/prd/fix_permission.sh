#! /bin/bash

[ -z $1 ] && echo "miss param 1 for folder name." && exit;
FOLDER_NAME=$1;

chown -R nginx:nginx $FOLDER_NAME
chmod -R 701 $FOLDER_NAME

