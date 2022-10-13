#!/bin/bash
#
#  Faveo Helpdesk Docker Development Environment
#
#  Copyright (C) 2020 Ladybird Web Solution Pvt Ltd
#
#  Author Thirumoorthi Duraipandi & Viswash S
#  Email  vishwas.s@ladybirdweb.com thirumoorthi.duraipandi@gmail.com
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses>.


# Colour variables for the script.
red=`tput setaf 1`

green=`tput setaf 2`

yellow=`tput setaf 11`

skyblue=`tput setaf 14`

white=`tput setaf 15`

reset=`tput sgr0`

# Faveo Banner.

echo -e "$skyblue                                                                                                                         $reset"
sleep 0.05
echo -e "$skyblue                                        _______ _______ _     _ _______ _______                                          $reset"
sleep 0.05   
echo -e "$skyblue                                       (_______|_______|_)   (_|_______|_______)                                         $reset"
sleep 0.05
echo -e "$skyblue                                        _____   _______ _     _ _____   _     _                                          $reset"
sleep 0.05
echo -e "$skyblue                                       |  ___) |  ___  | |   | |  ___) | |   | |                                         $reset"
sleep 0.05
echo -e "$skyblue                                       | |     | |   | |\ \ / /| |_____| |___| |                                         $reset"
sleep 0.05
echo -e "$skyblue                                       |_|     |_|   |_| \___/ |_______)\_____/                                          $reset"
sleep 0.05
echo -e "$skyblue                                                                                                                         $reset"
sleep 0.05 
echo -e "$skyblue                               _     _ _______ _       ______ ______  _______  ______ _     _                            $reset"
sleep 0.05     
echo -e "$skyblue                             (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |                            $reset"
sleep 0.05
echo -e "$skyblue                              _______ _____   _       _____) )     _ _____  ( (____  _____| |                            $reset"
sleep 0.05
echo -e "$skyblue                             |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)                            $reset"
sleep 0.05
echo -e "$skyblue                             | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \                             $reset"
sleep 0.05
echo -e "$skyblue                             |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)                            $reset"
sleep 0.05
echo -e "$skyblue                                                                                                                         $reset"
sleep 0.05
echo -e "$skyblue                                                                                                                         $reset"
                                                                                        
                                                                                        
                                                                                        
echo -e "$yellow               This script configures Development Environment for Faveo Helpdesk on any Docker enabled Linux Machine $reset"
echo -e "                                                                                                          "
sleep 0.5

if readlink /proc/$$/exe | grep -q "dash"; then
	echo '&red This installer needs to be run with "bash", not "sh". $reset'
	exit 1
fi

# Checking for the Super User.

if [[ $EUID -ne 0 ]]; then
   echo -e "$red This script must be run as root $reset"
   exit 1
fi

echo "Checking Prerequisites....."
apt update; apt install unzip curl -y || yum install unzip curl -y

DockerVersion=$(docker --version)

if [[ $? != 0 ]]; then
echo -e "\n";
echo -e "$red Docker is not found in this server, Please install Docker and try again. $reset"
echo -e "\n";
exit 1;
else 
echo -e "\n";
echo  $green $DockerVersion $reset
fi

DockerComposeVersion=$(docker-compose --version)

if [[ $? != 0 ]]; then
echo -e "\n";
echo -e "$red Docker Compose is not found in this server please install Docker Compose and try again. $reset"
echo -e "\n";
exit 1;
else 
echo -e "\n";
echo  "$green $DockerComposeVersion $reset"
fi

if [[ $? -eq 0 ]]; then

    echo  -e "\n";
    echo "$green Prerequisites check completed. $reset"
else
    echo -e "\n";
    echo "$red Check failed please make sure to execute the script as sudo user and also check your Internet connectivity. $reset"
    echo  -e "\n";
    exit 1;
fi

echo -e "\n";
read -p "$skyblue Enter a Domain Name of your choice to generate Self Signed Certificates: $reset" DomainName

echo -e "\n";
read -p "$skyblue Enter the prefered version for Nodejs (Ex: 12.x,13.x,14.x etc..): $reset" Nodejs
sed -i "s:nodejs-version:setup_$Nodejs:g" apache/Dockerfile

echo -e "\n";
read -p "$skyblue Give the name for the Directory in which you would like to have your development files: $reset" RootDir 

read -p "$skyblue Enter Password for Database ROOT User: $reset" db_root_pw
read -p "$skyblue Enter the Name for the Development Database: $reset" db_name
read -p "$skyblue Enter the Database Username: $reset" db_user
read -p "$skyblue Enter Database Password: $reset" db_user_pw

CUR_DIR=$(pwd)

if [ ! -d $CUR_DIR/$RootDir ]; then
    mkdir -p $CUR_DIR/$RootDir
else
    echo -e "\n";
    echo -e "$red Directory already exists. Please re-run the script and give a different directory name. $reset"
    exit 1;
fi

echo -e "$skyblue Generating Certificates for $DomainName .....  $reset"
mkdir -p $CUR_DIR/ssl
openssl ecparam -out $CUR_DIR/ssl/faveoroot.key -name prime256v1 -genkey
openssl req -new -sha256 -key $CUR_DIR/ssl/faveoroot.key -out $CUR_DIR/ssl/faveoroot.csr -subj "/C=/ST=/L=/O=/OU=/CN="
openssl x509 -req -sha256 -days 7300 -in $CUR_DIR/ssl/faveoroot.csr -signkey $CUR_DIR/ssl/faveoroot.key -out $CUR_DIR/ssl/faveorootCA.crt
openssl ecparam -out $CUR_DIR/ssl/private.key -name prime256v1 -genkey
openssl req -new -sha256 -key $CUR_DIR/ssl/private.key -out $CUR_DIR/ssl/faveolocal.csr -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Ladybird Web Solutions Pvt Ltd/OU=Development Team/CN=$DomainName"
openssl x509 -req -in $CUR_DIR/ssl/faveolocal.csr -CA  $CUR_DIR/ssl/faveorootCA.crt -CAkey $CUR_DIR/ssl/faveoroot.key -CAcreateserial -out $CUR_DIR/ssl/faveolocal.crt -days 7300 -sha256
openssl x509 -in $CUR_DIR/ssl/faveolocal.crt -text -noout

cp $CUR_DIR/ssl/faveorootCA.crt apache/

if [[ $? -eq 0 ]]; then
    echo -e "$green Certificates generated successfully for $DomainName $reset"
else
    echo -e "$red Certification generation failed. $reset"
    exit 1;
fi;

echo -e '<h1> This is the Test Page of your Faveo Docker Development Environment </h1>' > $RootDir/index.html

if [[ $? -eq 0 ]]; then
    rm -f .env
    cp example.env .env
    sed -i 's:MYSQL_ROOT_PASSWORD=:&'$db_root_pw':' .env
    sed -i 's/MYSQL_DATABASE=/&'$db_name'/' .env
    sed -i 's/MYSQL_USER=/&'$db_user'/' .env
    sed -i 's:MYSQL_PASSWORD=:&'$db_user_pw':' .env
    sed -i 's/DOMAINNAME=/&'$DomainName'/' .env
    sed -i '/ServerName/c\    ServerName '$DomainName'' ./apache/000-default.conf
    sed -i 's:domainrewrite:'$DomainName':g' ./apache/000-default.conf
    sed -i 's/HOST_ROOT_DIR=/&'$RootDir'/' .env
    sed -i 's:CUR_DIR=:&'$PWD':' .env
else
    echo "Database Password Generation Failed"
fi

if [[ $? -eq 0 ]]; then
    docker volume create --name ${DomainName}-faveoDB
fi

docker network rm ${DomainName}-faveo

docker network create ${DomainName}-faveo --driver=bridge 
if [[ $? -eq 0 ]]; then
    echo " Faveo Docker Network ${DomainName}-faveo Created"
else
    echo " Faveo Docker Network Creation failed"
    exit 1;
fi

if [[ $? -eq 0 ]]; then
    docker compose up -d
fi

if [[ $? -eq 0 ]]; then
    echo -e "\n"
    echo "#########################################################################"
    echo -e "\n"
    echo "Faveo Docker installed successfully. Visit https://$Domainname from your browser."
    echo "Please save the following credentials."
    echo "Database Hostname: faveo-mariadb"
    echo "Mysql Database root password: $db_root_pw"
    echo "Faveo Helpdesk name: $db_name"
    echo "Faveo Helpdesk DB User: $db_user"
    echo "Faveo Helpdesk DB Password: $db_user_pw"
    echo -e "\n"
    echo "#########################################################################"
else
    echo "Script Failed unknown error."
    exit 1;
fi


