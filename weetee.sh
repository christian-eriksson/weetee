#!/bin/sh

set -e

script_dir="${0%/*}"

. $script_dir/.env

old_ip_file="$script_dir/old.ip"

new_ip=$(curl -s $WHAT_IS_MY_IP_ENDPOINT)
new_ip=$(echo $new_ip | xargs echo -n)

old_ip="-"
if [ -e $old_ip_file ]; then
    old_ip=$(cat $old_ip_file)
fi

if [ "$new_ip" != "$old_ip" ]; then
    if [ -n "$new_ip" ] || [ -z "$IGNORE_EMPTY_NEW_IP" ]; then
        sed -e "/{{old-ip}}/s/{{old-ip}}/$old_ip/g" -e "/{{new-ip}}/s/{{new-ip}}/$new_ip/g" $TEMPLATE | sendmail $EMAIL
        echo "$new_ip" >$old_ip_file
    fi
fi
