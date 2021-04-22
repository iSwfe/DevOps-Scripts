#! /bin/bash

[ -z $1 ] && echo "miss param 1 for package key." && exit;

PACKAGE_KEY=$1
DEPLOY_KEY=`[ $2 ] && echo $2 || echo $1`

packagePath=./$PACKAGE_KEY*.zip
deployPath=./$DEPLOY_KEY

# exit if PACKAGE_NAME not exist
[ ! -e $PACKAGE_KEY*.zip ] && echo "$PACKAGE_KEY*.zip not exist, check param 1." && exit

# clean exist folder
[ -e .tmp ] && rm -rf .tmp
[ -e $deployPath ] && rm -rf $deployPath/*

# unpkg
unzip -oqd .tmp $packagePath
#unar -q -f -o "unpkg_$PACKAGE_NAME" $PACKAGE_NAME

# move unpackaged folder to deployPath
# create deployPath if not exist
[ ! -e $deployPath ] && mkdir -p $deployPath
tmpContentCount=`ls .tmp | awk 'END{print NR}'`
if [[ $tmpContentCount -eq 1 ]]; then
    mv .tmp/$PACKAGE_KEY*/* $deployPath
else
    mv .tmp/* $deployPath
fi

# fix nginx permission
./fix_permission.sh $deployPath

# clean unpkg folder
rm -rf .tmp

