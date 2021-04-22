# 获取监听指定端口程序 eg. get_port "8080"
function get_port() {
	netstat -tunl | awk 'NR>2{print $1"_"$4"_"$NF}' | grep -P "^tcp6?_.*:$1_LISTEN$";
}

# 获取监听指定端口程序数量 eg. count_port "8080"
function count_port() {
	get_port $1 | grep -c '';	# | grep -Pc 也可以
}

# 获取程序pid（通过jar包标识名称） eg. get_pid_by_jar "police-property-server"
function get_jar_pid() {
	ps -ef | awk '$8 ~ /^java$/ && $0 ~ /'"$1"'/ {print $2}'
}

# 获取程序pid（通过jar包标识名称） eg. get_pid_by_jar "8080" "police-property-server"
function get_jar_port_pid() {
	ps -ef | awk '$8 ~ /^java$/ && $0 ~ /'"=$1"'\s/ && $0 ~ /'"$2"'/ {print $2}'
}
