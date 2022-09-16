#!/bin/bash -il
source ~/.scripts/.function.jar-util.sh
source ~/.scripts/.function.log.sh
##### 必须使用 bash -il server.sh <someParams> 来运行该脚本！！！ #####

curFile=${0##*/}
infolog "start...";

# 检查参数$1，不存在则退出
[ -z $1 ] && errorlog "param \$1 not found, exit." && exit;

# 接收参数列表
JAR_FLAG=$1
SERVER_PORT=`[ $2 ] && echo $2 || echo 8080`
JAR_ENV=`[ $3 ] && echo $3 || echo 'test'`
JAR_PATH=`[ $4 ] && echo $4 || echo 'upload'`
SERVER_DEBUG_PORT=`[ $5 ] && echo $5`

WORK_PATH=$(pwd)
JAR_FILE_PATH=$(cd ${JAR_PATH}; pwd)/${JAR_FLAG}.jar
cd ${JAR_PATH}
LOG_FILE=log_$JAR_FLAG.log
LOG_FILE_PATH=$WORK_PATH/$LOG_FILE
SERVER_DEBUG_ENABLE=`[[ $SERVER_DEBUG_PORT -gt 0 ]] && echo TRUE || echo FALSE`
infolog "print env variables..."
infolog "   SERVER_PORT=$SERVER_PORT"
infolog "   JAR_ENV=$JAR_ENV"
infolog "   WORK_PATH=$WORK_PATH"
infolog "   JAR_FILE_PATH=$JAR_FILE_PATH"
infolog "   LOG_FILE_PATH=$LOG_FILE_PATH"
infolog "   SERVER_DEBUG_ENABLE=$SERVER_DEBUG_ENABLE, SERVER_DEBUG_PORT=$SERVER_DEBUG_PORT"
infolog "print finished."

# create "history" directory when not exist
HISTORY_PATH=$WORK_PATH/history
[ ! -d $HISTORY_PATH ] && mkdir $HISTORY_PATH

# check
if [ -e $JAR_FILE_PATH ]; then
  infolog "[check] Jar file checked, continue"
else
  errorlog "[check] Jar file in $JAR_FILE_PATH not exist, exit" && exit
fi

# shutdown
infolog "[shutdown] Ready to shutdown exist process..."
# pid=$(ps -ef | grep -v grep | grep '\-jar' | grep "$JAR_FLAG" | awk '{print $2}')
pid=$(get_jar_pid $SERVER_PORT $JAR_FLAG)
if [ -z "$pid" ]; then
    infolog "[shutdown] pid not exist, continue"
else
    infolog "[shutdown] Exist process pid($pid), killing..."
    kill -9 $pid && \
    infolog "[shutdown] Process killed, continue"
fi


# backup
now=$(date '+%Y-%m-%d_%H:%M:%S')
infolog "[backup] Ready to backup for '"$now"'..."
cp $JAR_FILE_PATH ${HISTORY_PATH}/${JAR_FLAG}.jar.${now}
mv $LOG_FILE_PATH ${HISTORY_PATH}/$LOG_FILE.${now}
infolog "[backup] Backup finished, continue"


# startup
infolog "[startup] Ready to start..."
SERVER_DEBUG_PARAM=""
if [[ TRUE == $SERVER_DEBUG_ENABLE ]]; then
    SERVER_DEBUG_PARAM="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$SERVER_DEBUG_PORT"
fi;
export JAVA_OPTS="-XX:+HeapDumpOnOutOfMemoryError"
nohup script -qfc "java -Xms2048m -Xmx2048m $SERVER_DEBUG_PARAM -Dserver.port=$SERVER_PORT -jar -Dspring.profiles.active=$JAR_ENV $JAR_FILE_PATH" $LOG_FILE_PATH > /dev/null 2>&1 &
sleep 2

# pid=$(ps -ef | grep -v grep | grep '\-jar' | grep "$JAR_FLAG" | awk '{print $2}')
pid=$(get_jar_pid $JAR_FLAG)
infolog "[startup] Started: pid($pid), continue"


# check log
infolog "[check log] Start daemon process for checking log..."
{
    tail -500f $LOG_FILE_PATH
} &
infolog "[check log] Daemon process started, continue"
infolog "[check log] Wait for 5s of display..."
sleep 5


# check server port
infolog "[check server port] Start..."
until [[ $(count_port $SERVER_PORT) > 0 ]]
# until (($(netstat -an | grep ":$SERVER_PORT" | awk '$1 == "tcp6" && $NF == "LISTEN" {print $0}' | wc -l) > 0))
do
    infolog "[check server port] Wait for port($SERVER_PORT) start..."
    sleep 2
done
infolog "[check server port] Port($SERVER_PORT) checked."

# kill all sub process (include daemon process for checking log)
subPid=$(ps --ppid $$ | awk '/bash/ {print $1}' | awk 'NR==1') # && echo "subPid=$subPid"
infolog "[check server port] Exit after 3s..."
sleep 3
ps --ppid "$subPid" | awk 'NR>1 {print $1}' | xargs kill -9
infolog "[check server port] Script exit."

