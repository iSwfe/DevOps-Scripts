#! /bin/bash
source ~/.scripts/.function.log.sh

package=$1
port=$2
debugPort=$3
profile=$4
path=$5
configPath=$6
supplyPath=$7

# 检查环境
uploadPackagePath=${path}/${package}.jar
[[ ! -e $uploadPackagePath ]] && errorlog "Miss package file:[${uploadPackagePath}]." && exit -1
[[ ! -e $configPath ]] && errorlog "Miss config file:[${configPath}]." && exit -1

# 初始化目录
runPath=.run/${package}
[[ ! -d $runPath ]] && mkdir -p $runPath
rm -rf $runPath/*

# 分离项目环境
configFileSuffer=${configPath##*.}
cp $configPath $runPath/application-${profile}.${configFileSuffer}
cp $uploadPackagePath $runPath/
[[ -d ${supplyPath} ]] && cp -R $supplyPath/* $runPath

# 运行
bash -il ~/.scripts/server.sh $package $port $profile $runPath $debugPort

