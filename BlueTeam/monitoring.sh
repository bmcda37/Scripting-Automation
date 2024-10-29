#!bin/bash

LOG_FILE="/var/log/auth.log"
THRESHOLD=3
WINDOW=15
WATCH="./watch_list.txt"
FAILED="Failed|failure|incorrect"
HISTORY="./threshold_breach_history.txt"
FIREWALL_LOG="./firewall_log.txt"

#Create an associative array for key:value pairs ip_tables=([ip]="attempt#")
declare -A ip_attempts 
#Create an associative array for key:value pairs ip_time=([ip]="unix timestamp")
declare -A ip_time

#Create file for documenting history of threshold breachs
touch "$HISTORY"

# Synthetic Log Example Used for testing... Tested with actual ssh attempts once power was restore and workedd as intended.
#Feb 10 15:45:14 ubuntu-lts sshd[47343]: Failed password for root from 103.106.189.143 port 33990 ssh2


monitor_auth(){
    #Continuously monitor the log file.
    tail -F $LOG_FILE | while read line; do
        if echo "$line" | egrep --line-buffered -i "$FAILED"; then
            #If line contains the words from followed by an ipV4. Chosen as all failed attempts will have this wording.
            if [[ "$line" =~ .*from\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
                 #Extract the IP address. Refers to first captured group by regexp
                 offending_ip="${BASH_REMATCH[1]}"
                 # Get the unix timestamp
                 current_time=$(date +%s)
            
                #Check if the offending_ip key has no value 
                if [[ -z "${ip_attempts["$offending_ip"]}" ]]; then
                    ip_attempts["$offending_ip"]=0
                    ip_time["$offending_ip"]=""
                fi

                #Get the number of attempts for the offending_ip
                ip_time["$offending_ip"]+="$current_time "
                ip_attempts["$offending_ip"]=$((ip_attempts["$offending_ip"]+1))
            

                ATTEMPTS="${ip_attempts["$offending_ip"]}"
                #If the number of attempts for the offending_ip is greater than or equal to the threshold, then begin the investigation 
                if [[ $ATTEMPTS -eq "$THRESHOLD" ]]; then
                    echo "IP:$offending_ip flagged. Begining test..." >> "$HISTORY"
                    investigate "$offending_ip" "$current_time" "$ATTEMPTS"

                fi
            fi
        fi
    done
}


investigate(){
    local offending_ip=$1
    local current_time=$2
    local ATTEMPTS=$3
    #Check if the time difference is less than or equal to the window, if the function returns true call high_alert and firewall functions.
    if comp_time "$offending_ip" "$current_time" "$ATTEMPTS"; then
        high_alert "$offending_ip"
        firewall "$offending_ip"
    else
        watch_alert "$offending_ip" "$ATTEMPTS" "$diff"
    fi
}


comp_time(){
    local offending_ip=$1
    local current_time=$2
    local ATTEMPTS=$3

    timestamp_list=${ip_time["$offending_ip"]}
    #Retrieve the first field in the timestamp_list
    first_time=$(awk '{print $1}' <<< "$timestamp_list")
    #Retrieve the last field in the timestamp_list
    last_time=$(awk '{print $NF}' <<< "$timestamp_list")
    #Get the time difference
    diff=$((last_time - first_time))
    #Window is set for 15 seconds in this case but can be adjusted at top of the script.
    if [[ $diff -le $WINDOW ]]; then
        echo "Threshold exceeded for: $offending_ip. IP was successfully blocked in the firewall." >> "$HISTORY"
        return 0
    else
        echo "$offending_ip did not meet threshold, but may need to be monitored. $ATTEMPTS within $diff time window" >> "$WATCH"
        return 1
    fi
}


#Send High alert to the admin via temporary slack channel created for assingment
high_alert(){
    local offending_ip=$1
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Threshold exceeded for: $offending_ip. IP was successfully blocked in the firewall.\"}" https://hooks.slack.com/services/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 
}

#Send watch alert to the admin via temporary slack channel created for assingment.
watch_alert(){
    local offending_ip=$1
    local ATTEMPTS=$2
    local diff=$3
    #Remove the IP from the arrays after logging as a watch so that they can be continuously monitored reseting the threshold.
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Watch may be neccessary for : $offending_ip. IP was not blocked in the firewall. $ATTEMPTS within $diff time window\"}" https://hooks.slack.com/services/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 
    unset ip_attempts["$offending_ip"]
    unset ip_time["$offending_ip"]
}


# Firewall rule to block Offending_ip
firewall(){
    local offending_ip=$1
    #Block the offending_ip
    sudo ufw deny from "$offending_ip" 

    echo "Blocked IP: $offending_ip" >>"$FIREWALL_LOG"
    #Check if the IP was successfully blocked
    if [[ $? -eq 0 ]]; then
        #Remove ip from array after blocking it
        unset ip_attempts["$offending_ip"]
        unset ip_time["$offending_ip"]
    else
        echo "Failed to block IP $offending_ip" >> "$FIREWALL_LOG"
    fi
}

#Call the main function
monitor_auth