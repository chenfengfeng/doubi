#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

ssr_folder="/usr/local/shadowsocksr"
jq_file="${ssr_folder}/jq"
config_folder="/etc/shadowsocksr"
config_user_file="${config_folder}/user-config.json"
port=`${jq_file} '.server_port' ${config_user_file}`

# 读取 IP配置信息
Get_IP(){
	ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
	if [[ -z "${ip}" ]]; then
		ip=$(wget -qO- -t1 -T2 api.ip.sb/ip)
		if [[ -z "${ip}" ]]; then
			ip=$(wget -qO- -t1 -T2 members.3322.org/dyndns/getip)
			if [[ -z "${ip}" ]]; then
				ip="VPS_IP"
			fi
		fi
	fi
}

# 设置 配置信息
Modify_config_port(){
	ls_date=`date +%m%d`
	getTime=3${ls_date}
	sed -i 's/"server_port": '"$(echo ${port})"'/"server_port": '"$(echo ${getTime})"'/g' ${config_user_file}
}

# 重启服务
check_pid(){
	PID=`ps -ef |grep -v grep | grep server.py |awk '{print $2}'`
}
Restart_SSR(){
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/ssr stop
	/etc/init.d/ssr start
	check_pid
	[[ ! -z ${PID} ]]
}

# start
Get_IP
Modify_config_port
Restart_SSR

# 调用API
curl -k "https://ffhub.top/api/port.php?host=${ip}&port=${getTime}"