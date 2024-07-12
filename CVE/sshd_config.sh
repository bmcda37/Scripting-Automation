#! /usr/bin/env bash

CONFIG_FILE="/etc/ssh/sshd_config"

sed -i "s/#LoginGraceTime 2m/LoginGraceTime 0m/g" $CONFIG_FILE
sed -i "s/" $CONFIG_FILE

systemctl restart sshd

status=$(systemctl status sshd)

echo "$status"