#!/bin/bash

# This script check domain name ssl certificate and send message to Telegram chat if ssl certificate not valid

# for use need that in operation system has utilities:
# bash, echo, date, grep, awk, curl, nmap, nmap-scripts

# example how to run:
# ./ssl-check.sh google.com

#-------------------

if [ "$(nmap --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo; echo "To use this application, you need to have NMAP installed on the system (example: apt-get install nmap)"; echo; exit 127; fi

if [ "$(nmap -p 443 --script ssl-cert google.com > /tmp/test 2>&1; cat /tmp/test | grep nse > /dev/null 2>&1; echo $?)" -eq "0" ]; then echo; echo "To use this application, you need to have NMAP-SCRIPTS installed on the system (example: apt-get install nmap-scripts)"; echo; exit 127; fi

if [ "$(echo 0 | awk '{print $1}' > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo; echo "To use this application, you need to have AWK installed on the system (example: apt-get install awk)"; echo; exit 127; fi

if [ "$(date --help > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo; echo "To use this application, you need to have DATE installed on the system (example: apt-get install date)"; echo; exit 127; fi

if [ "$(grep --help > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo; echo "To use this application, you need to have GREP installed on the system (example: apt-get install grep)"; echo; exit 127; fi

if [ "$(curl --version > /dev/null 2>&1; echo $?)" -ne "0" ]; then echo; echo "To use this application, you need to have CURL installed on the system (example: apt-get install curl)"; echo; exit 127; fi


if [ "$#" -lt 1 ]; then
    echo "No set domain name !"
    exit 101
fi

#-------------------

domain_name=$1

token="botXXXXXXXXX:YYYYYYYYYYYYYYYYYYYYYYYYY" # need to set real token for Telegram Api

chat_id="ZZZZZZZZZZZ" # need to set real chat_id for Telegram Api

#-------------------

ssl_valid_date="$(date -d $(echo $(nmap -p 443 --script ssl-cert $domain_name | grep "Not valid after" | awk '{print $5}' | tr 'T' ' ' | awk '{print $1}')) +%Y%m%d)"

today_date="$(date +%Y%m%d)"

diff="$(($ssl_valid_date-today_date))"

if [ "$ssl_valid_date" -lt "$today_date" ]
   then
       echo "Certificate expired !"
       curl -s -X POST "https://api.telegram.org/$token/sendMessage" -d chat_id="$chat_id" -d text="Certificate for $1 expired !"

   else
       echo "Certificate valid"
fi

if [[ "$diff" -le "7" && "$diff" -gt "0" ]]
   then
       echo "$diff days to expired certificate for $1 !"
       curl -s -X POST "https://api.telegram.org/$token/sendMessage" -d chat_id="$chat_id" -d text="$diff days to expired certificate for $1 !"
fi

