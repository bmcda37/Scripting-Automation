#! /usr/bin/env bash

CONFIG_FILE="/etc/dnf/automatic.conf"
UPGRADE_TYPE="security"
SLEEP="60"

sudo dnf install -y dnf-automatic

sudo dnf update -y

sed -i "s/upgrade_type = .*/upgrade_type = $UPGRADE_TYPE/" $CONFIG_FILE

sed -i "s/random_sleep = .*/random_sleep = $SLEEP/" $CONFIG_FILE

systemctl enable --now dnf-automatic.timer
systemctl start dnf-automatic.timer

status=$(systemctl status dnf-automatic.timer)

current_timers=$(systemctl list-timers dnf-automatic.timer)

echo "$status"
echo "$current_timers"
