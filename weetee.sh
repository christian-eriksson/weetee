#!/bin/sh

script_dir="${0%/*}"

. $script_dir/.env

old_ip_file="$script_dir/old.ip"

new_ip=$(curl -s $WHAT_IS_MY_IP_ENDPOINT)

old_ip="-"
if [ -e $old_ip_file ]; then
    old_ip=$(cat $old_ip_file)
fi

if [ "$new_ip" != "$old_ip" ]; then
    sed -e "/{{old-ip}}/s/{{old-ip}}/$old_ip/g" -e "/{{new-ip}}/s/{{new-ip}}/$new_ip/g" $TEMPLATE | sendmail $EMAIL
fi

echo "$new_ip" > $old_ip_file

