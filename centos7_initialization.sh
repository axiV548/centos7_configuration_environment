#!/bin/bash
#判断系统
if [ ! -e '/etc/redhat-release' ]; then
echo "仅支持centos7"
exit
fi
if  [ -n "$(grep ' 6\.' /etc/redhat-release)" ]; then
echo "仅支持centos7"
exit
fi

function blue(){
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green(){
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}

#安装python3.6
install_py36(){
    yum install -y openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel wget gcc automake autoconf libtool make
    mkdir -p /usr/soft/py3.6
    cd /usr/soft/py3.6
    wget https://cdn.npm.taobao.org/dist/python/3.6.0/Python-3.6.0.tgz
    tar -xzvf Python-3.6.0.tgz
    cd Python-3.6.0
    ./configure --prefix=/usr/local
    make && make altinstall
    
    
    rm -rf /usr/bin/python
    ln -s /usr/local/bin/python3.6 /usr/bin/python
    rm -rf /usr/bin/pip
    ln -s /usr/local/bin/pip3.6 /usr/bin/pip
    
    ln -s /usr/local/bin/python2.7 /usr/bin/python2
    
    cat /usr/bin/yum | grep '/usr/bin/python2'
    if [ $? -ne 0 ] ;then
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python2|' /usr/bin/yum
    echo "yum配置已修改"
    else
    echo "yum配置已存在"
    fi
    
    cat /usr/libexec/urlgrabber-ext-down | grep '/usr/bin/python2'
    if [ $? -ne 0 ] ;then
    sed -i 's|#! /usr/bin/python|#! /usr/bin/python2|' /usr/libexec/urlgrabber-ext-down
    echo "urlgrabber-ext-down配置已修改"
    else
    echo "urlgrabber-ext-down配置已存在"
    fi
    
    cat /usr/bin/firewall-cmd | grep '/usr/bin/python2'
    if [ $? -ne 0 ] ;then
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python2|' /usr/bin/firewall-cmd
    echo "firewall-cmd配置已修改"
    else
    echo "firewall-cmd配置已存在"
    fi
    
    cat /usr/sbin/firewalld | grep '/usr/bin/python2'
    if [ $? -ne 0 ] ;then
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python2|' /usr/sbin/firewalld
    echo "firewalld配置已修改"
    else
    echo "firewalld配置已存在"
    fi
    rm -rf /usr/soft/py3.6
}

#安装JDK8u202
install_jdk8u202(){

    yum install -y wget
    mkdir -p /usr/soft/
    cd /usr/soft
    wget https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz
    tar -xzvf jdk-8u202-linux-x64.tar.gz
    
    sed -i '$aexport JAVA_HOME=/usr/soft/jdk1.8.0_202' /etc/profile
    sed -i '$aexport CLASSPATH=.:${JAVA_HOME}/jre/lib/rt.jar:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar' /etc/profile
    sed -i '$aexport PATH=$PATH:${JAVA_HOME}/bin' /etc/profile
    
    echo "请手动执行：source /etc/profile"
    
}

#安装mysql5.7
install_mysql5.7(){

    mkdir -p /usr/soft/mysql5.7
    cd /usr/soft/mysql5.7
    wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
    rpm -ivh mysql57-community-release-el7-9.noarch.rpm
    yum install -y mysql-server
    systemctl start mysqld
    
    mysql_password=$(grep -o 'localhost: .*' /var/log/mysqld.log)
    echo "数据库密码为:"${mysql_password: 11}

}

#安装docker
install_docker(){
    yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    yum update -y
    yum install -y yum-utils device-mapper-persistent-data lvm2 
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce
    systemctl start docker
    systemctl enable docker
    
}

start_menu(){
    clear
    green " ===================================="
    green " 介绍：centos7初始化配置           "
    green " 系统：centos7                       "
    green " 作者：axiV548                      "
    green " 网站：www.mocho.top              "
    green " ===================================="
    echo
    green " 1. 安装python3.6"
    green " 2. 安装mysql5.7"
    green " 3. 安装jdk8u202"
    green " 4. 安装docker"
    yellow " 0. 退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    install_py36
    ;;
    2)
    install_mysql5.7
    ;;
    3)
    install_jdk8u202 
    ;;
    4)
    install_docker 
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    red "请输入正确数字"
    sleep 2s
    start_menu
    ;;
    esac
}

start_menu
