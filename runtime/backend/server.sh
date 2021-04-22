#!/bin/bash -il
##### 必须使用 bash -il server.sh <someParams> 来运行该脚本！！！ #####

source ~/shell_util.sh;

SERVER_DEBUG_ENABLE=false
SERVER_DEBUG_PORT=48888

curFile=${0##*/}
echo "========== $curFile: start... ==========";

# 检查参数$1，不存在则退出
[ -z $1 ] && echo "========== $curFile: param \$1 not found, exit. ==========" && exit;

JAR_FLAG=$1
SERVER_PORT=`[ $2 ] && echo $2 || echo 8080`
JAR_ENV=`[ $3 ] && echo $3 || echo 'test'`
JAR_PATH=`[ $4 ] && echo $4 || echo 'fromJenkins'`
echo "========== $curFile: \$JAR_FLAG=$JAR_FLAG, \$SERVER_PORT=$SERVER_PORT, \$JAR_PATH=$JAR_PATH, \$SERVER_DEBUG_ENABLE=$SERVER_DEBUG_ENABLE \$SERVER_DEBUG_PORT=$SERVER_DEBUG_PORT =========="

# create "history" directory when not exist
[ ! -d history ] && mkdir history

# check
for file in "$JAR_PATH"/"$JAR_FLAG"*.jar
do
  if [ -e "$file" ]
  then
    echo "========== $curFile: [check] Jar file checked, continue =========="
    break
  else
    echo "========== $curFile: [check] Jar file in $JAR_PATH not exist, exit ==========" && exit
  fi
done

# shutdown
echo "========== $curFile: [shutdown] Ready to shutdown exist process... =========="
# pid=$(ps -ef | grep -v grep | grep '\-jar' | grep "$JAR_FLAG" | awk '{print $2}')
pid=$(get_jar_pid $SERVER_PORT $JAR_FLAG)
if [ -z "$pid" ]; then
	echo "========== $curFile: [shutdown] pid not exist, continue =========="
else
	echo "========== $curFile: [shutdown] Exist process pid($pid), killing... =========="
	kill -9 $pid && \
	echo "========== $curFile: [shutdown] Process killed, continue =========="
fi


# backup
now=$(date '+%Y-%m-%d_%H:%M:%S')
echo "========== $curFile: [backup] Ready to backup for $now ... =========="
cd $JAR_PATH && jar_file_name=$(ls $JAR_FLAG*.jar) && cd ..
cp $JAR_PATH/$JAR_FLAG*.jar history/"$jar_file_name.$now"
cp $JAR_FLAG.log history/$JAR_FLAG.log."$now"
echo "========== $curFile: [backup] Backup finished, continue =========="


# startup
echo "========== $curFile: [startup] Ready to start... =========="
SERVER_DEBUG_PARAM=""
if [[ true == $SERVER_DEBUG_ENABLE  ]]; then
	SERVER_DEBUG_PARAM="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$SERVER_DEBUG_PORT"
fi;
nohup script -qfc "java $SERVER_DEBUG_PARAM -Dserver.port=$SERVER_PORT -jar -Dspring.profiles.active=$JAR_ENV $JAR_PATH/$JAR_FLAG.jar" $JAR_FLAG.log > /dev/null 2>&1 &

# pid=$(ps -ef | grep -v grep | grep '\-jar' | grep "$JAR_FLAG" | awk '{print $2}')
pid=$(get_jar_pid $JAR_FLAG)
echo "========== $curFile: [startup] Started: pid($pid), continue =========="


# check log
echo "========== $curFile: [check log] Start daemon process for checking log... =========="
{
	tail -500f $JAR_FLAG.log
} &
echo "========== $curFile: [check log] Daemon process started, continue =========="
echo "========== $curFile: [check log] Wait for 5s of display... =========="
sleep 5


# check server port
echo "========== $curFile: [check server port] Start... =========="
until [[ $(count_port $SERVER_PORT) > 0 ]]
# until (($(netstat -an | grep ":$SERVER_PORT" | awk '$1 == "tcp6" && $NF == "LISTEN" {print $0}' | wc -l) > 0))
do
	echo "========== $curFile: [check server port] Wait for port($SERVER_PORT) start... =========="
	sleep 2
done
echo "========== $curFile: [check server port] Port($SERVER_PORT) checked. =========="

# kill all sub process (include daemon process for checking log)
subPid=$(ps --ppid $$ | awk '/bash/ {print $1}' | awk 'NR==1') # && echo "subPid=$subPid"
echo "========== $curFile: [check server port] Exit after 3s... =========="
sleep 3
ps --ppid "$subPid" | awk 'NR>1 {print $1}' | xargs kill -9
echo "========== $curFile: [check server port] Script exit... =========="

