#!/bin/bash

#
#
# This script was developed for simple install proxy-server Squid only to CentOS Linux only version 6.X and 7.X
#
#

SRCLIST=(195.191.175.200)

IPLIST=(`ip -4 addr show | grep 'inet' | grep -v grep | grep -v 127.0.0.1 | awk '/[ ]+/ {print $2}' | cut -d / -f 1`)

if [[ -f /etc/os-release ]];
    then REL=`cat /etc/os-release | grep PRETTY_NAME | awk -F "[\=\" ]" '{print $3}'`;
elif [[ -f /etc/redhat-release ]];
    then REL=`cat /etc/redhat-release | awk -F "[ ]" '{print $1}'`
else clear; printf "\nThe distribution of this Linux system is not from the Linux family! The script  works only on Linux!\n\n"; exit
fi

if [[ $REL = "CentOS" ]];
    then clear; printf "\nThe distribution of this Linux system is CentOS! We are continuing!\n\n"
elif [[ $REL = "Debian" ]];
    then clear; printf "\nThe distribution of this Linux system is Debian! We are continuing!\n\n"
else
    clear; printf "\nThe distribution of this Linux system is not CentOS or Debian! The script  works only on CentOS and Debian!\n\n"; exit
fi

if [[ $REL = "CentOS" ]];
    then yum -y update
else
    apt-get update; apt-get -y upgrade
fi

clear

if [[ -f /etc/os-release ]];
    then VER=`cat /etc/os-release | grep PRETTY_NAME | awk -F "[\=\" ]" '{print $5}'`
else
    VER="6"
fi
if [[ $REL = "CentOS" && $VER = "7" || $VER = "6" ]];
    then printf "\nYour CentOS-linux version is $VER\n\n"
elif [[ $REL = "Debian" && $VER = "9" || $VER = "8" || $VER = "7" ]];
    then printf "\nYour Debian-linux version is $VER\n\n"
else
    printf "\nCan't determine Linux version\n\n"; exit
fi

if [[ $REL = "CentOS" && $VER = "7" ]];
    then yum -y install squid
elif [[ $REL = "CentOS" && $VER = "6" ]];
    then yum -y install squid34
elif [[ $REL = "Debian" && $VER = "9" ]];
    then apt-get -y install squid
elif [[ $REL = "Debian" && $VER = "7" ]];
    then apt-get -y install squid3; ln -s /etc/squid3 /etc/squid
else
    apt-get -y install squid3; ln -s /etc/squid3 /etc/squid
fi

if [[ $REL = "CentOS" ]];
    then yum -y install httpd-tools
else
    apt-get -y install apache2-utils
fi

#####     Block of login-password autorization     #########
#
#echo
#echo "Enter the name for connect to proxy-server [test]:"
#read NAME
#if [[ -z "$NAME" ]]; then
#    NAME="test"
#fi
#
#echo
#echo "Enter the password for connect to proxy-server [test]:"
#read PASS
#if [[ -z "$PASS" ]]; then
#    PASS="test"
#fi
#
#htpasswd -cb /etc/squid/users $NAME $PASS
#
#############################################################

echo
echo "Enter the port of proxy-server [3128]:"
read PORT
if [[ -z "$PORT" ]]; then
    PORT="3128"
fi


cp /dev/null /etc/squid/squid.conf

echo "

#auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/users
#auth_param basic realm =NoName Proxy-Server=
#auth_param basic credentialsttl 8 hours

acl localhost src 127.0.0.1/32 ::1

#acl users proxy_auth REQUIRED
" > /etc/squid/squid.conf

for IP in ${SRCLIST[*]}
    do
	SRC_IP=$IP
	echo "
acl users src $SRC_IP ">> /etc/squid/squid.conf
    done

echo "

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

#http_access allow manager localhost
#http_access deny manager

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports

http_access allow localhost

http_access deny !users


http_port $PORT

coredump_dir /var/spool/squid3

refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
" >> /etc/squid/squid.conf

for IP in ${IPLIST[*]}
    do
	NAME=${IP//./_}
	echo "
acl my_ip_$NAME myip $IP
tcp_outgoing_address $IP my_ip_$NAME">> /etc/squid/squid.conf
    done

iptables -I INPUT -s 0.0.0.0/0 -p tcp -m tcp --dport "$PORT" -j REJECT

for IP in ${SRCLIST[*]}
    do
	SRC_IP=$IP
	iptables -I INPUT -s $SRC_IP -p tcp -m tcp --dport "$PORT" -j ACCEPT
    done

if [[ $REL = "CentOS" ]];
then 
    case $VER in
     7)
     systemctl enable squid
     systemctl start squid
     systemctl restart squid
     ;;
     6)
     chkconfig squid on
     service squid start
     service squid restart
     ;;
     *)
     echo "\nWho's here?\n\n"
     exit
     ;;
    esac
else
    case $VER in
     9)
     systemctl enable squid
     systemctl start squid
     systemctl restart squid
     ;;
     8)
     systemctl enable squid3
     systemctl start squid3
     systemctl restart squid3
     ;;
     7)
     update-rc.d squid3 enable
     service squid3 start
     service squid3 restart
     ;;
     *)
     echo "\nWho's here?\n\n"
     exit
     ;;
    esac
fi

ON=`ps ax | grep squid | grep -v grep | awk '/[ ]+/ {print $5}'`
echo $ON
if [[ -n "$ON" ]];
    then printf "\nProxy-server Squid is successfully installed to the following addresses:\n\n"
    for IP in ${IPLIST[*]}
        do
            printf "$IP:$PORT\n"
        done
    echo
    echo
else printf "\nSomething went wrong, please contact Vitaliy!\n\n"
fi
