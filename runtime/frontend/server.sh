#!/bin/basecond-pay-applet
targetDir="."	# current path

curFile=${0##*/}
echo "========== $curFile: start... =========="

# 检查参数$1，不存在则退出
[ -z $1 ] && echo "========== $curFile: param \$1 not found, exit. ==========" && exit;

pkgName=$1
pkgPath=`[ $2 ] && echo $2 || echo 'fromJenkins'`;
echo "========== $curFile: \$pkgName=$pkgName, \$pkgPath=$pkgPath ==========";

# check
for file in "$pkgPath"/"$pkgName"*.zip
do
  if [ -e "$file" ]
  then
    echo "========== $curFile: [check] Package checked, continue =========="
    break
  else
    echo "========== $curFile: [check] Package file in $pkgPath not exist, exit ==========" && exit
  fi
done

# clean
[ -e $pkgName ] && rm -rf ./$pkgName && echo "========== $curFile: $pkgName cleaned. ==========";

# unpackage
unzip -oqd ./$pkgName $pkgPath/$pkgName.zip;

# backup
now=$(date '+%Y-%m-%d_%H:%M:%S')
cp -f $pkgPath/$pkgName.zip history/"$pkgName.zip.$now";

# serve reload
nginx -s reload && echo "========== $curFile: nginx reloaded. ==========";

# update owner
chmod o+x /root
chmod o+x /root/runtime/
chmod o+x /root/runtime/frontend/
chown -R nginx:nginx $targetDir/$pkgName
chmod -R 701 $targetDir/$pkgName

echo "========== $curFile: finished. ==========";

