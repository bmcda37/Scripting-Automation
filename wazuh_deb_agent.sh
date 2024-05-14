#! bin/bash


adding_agent() {

local agentname="$1"



wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.4-1_amd64.deb && sudo WAZUH_MANAGER='192.168.8.197' WAZUH_AGENT_GROUP='.8.184' WAZUH_AGENT_NAME="$agentname" dpkg -i ./wazuh-agent_4.7.4-1_amd64.deb

sleep 5

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

echo "wazuh_command.remote_commands=1" | sudo tee -a  /var/ossec/etc/local_internal_options.conf > /dev/null

echo systemctl status wazuh-agent

}


while true; do
    read -p "Enter agent name (or 'q' to quit): " agentname
    if [ "$agentname" = "q" ]; then
        break
    fi
    adding_agent "$agentname"
done