#!/bin/sh
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
echo -e "${green}正在安装依赖${plain}"
if cat /etc/os-release | grep "centos" > /dev/null
    then
    yum install unzip wget curl -y > /dev/null
    yum update curl -y
else
    apt-get install unzip wget curl -y > /dev/null
    apt-get upgrade curl -y
    echo -e "${green}环境优化${plain}"
    ulimit -n 51200
    echo "soft nofile 51200" >> /etc/security/limits.conf
    echo "hard nofile 51200" >> /etc/security/limits.conf
    (cat <<EOF
fs.file-max = 102400
net.core.somaxconn = 1048576
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_fin_timeout = 30
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_max_syn_backlog = 1048576
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_orphan_retries = 1
net.ipv4.ip_local_port_range = 32768 65535
net.ipv4.tcp_mem = 88560 118080 177120
net.ipv4.tcp_wmem = 4096 16384 8388608
EOF
    ) > /etc/sysctl.conf
fi

api=$1 
token=$2
node_id=$3
server_name='server-trojan'
folder="xflash-${server_name}"


#kill process and delete dir
kill -9 $(ps -ef | grep ${server_name} | grep -v grep | grep -v bash | awk '{print $2}') 1 > /dev/null
echo -e "${green}结束进程${plain}"
rm -rf $folder

#install
last_version=$(curl -Ls "https://api.github.com/repos/xflash-panda/${server_name}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ ! -n "$last_version" ]]; then
    echo -e "${red}检测 ${server_name}版本失败，可能是超出 Github API 限制，请稍后再试.${plain}"
    exit 1
fi
echo -e "${green}检测到${server_name}最新版本：${last_version}，开始安装${plain}"
wget -N --no-check-certificate  https://github.com/xflash-panda/${server_name}/releases/download/${last_version}/${server_name}-linux-64.zip
if [[ $? -ne 0 ]]; then
    echo -e "${red}下载 ${server_name} 失败，请确保你的服务器能够下载 Github 的文件.${plain}"
    exit 1
fi 

unzip  -d ${folder} ${server_name}-linux-64.zip
rm ${server_name}-linux-64.zip -f
chmod +x ${folder}/${server_name}
mkdir ${folder}/logs
chmod -R 755 ${folder}/logs

if ls /root/.cert | grep "key" > /dev/null
    then
    echo -e "${green}证书正常${plain}"
else
    echo -e "${green}请签发证书后在执行${}"
    exit
fi

#run server
echo -e "${green}启动参数:${plain}"
echo -e "${yellow} api:${api}${plain}"
echo -e "${yellow} token:${token}${plain}"
echo -e "${yellow} node:${node_id}${plain}"
nohup `pwd`/${folder}/${server_name} --api=${api} --token=${token} --node=${node_id}  > `pwd`/${folder}/logs/${server_name}.log 2>&1 &
echo -e "${green}部署完成${plain}"
sleep 3
cat `pwd`/${folder}/logs/${server_name}.log 
if [[ $(ps -ef | grep ${server_name} |wc -l) -gt 1 ]];
then
    echo -e "${green}启动成功${plain}"
else
    echo -e "${red}启动失败，请仔细检查启动参数${plain}"
fi
