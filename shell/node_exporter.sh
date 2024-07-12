#! /bin/bash

node_service="/usr/lib/systemd/system/node_exporter.service"

if [ -f "$node_service" ]; then
    echo "Node Exporter is already installed"
    exit 1
else
    cd /opt

    sudo groupadd -f node_exporter
    sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
    sudo mkdir /etc/node_exporter
    sudo chown node_exporter:node_exporter /etc/node_exporter

    sudo wget  https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
    sudo tar -xvf node_exporter-1.8.1.linux-amd64.tar.gz
    sudo mv node_exporter-1.8.1.linux-amd64 node_exporter-files

    sudo cp node_exporter-files/node_exporter /usr/bin/
    sudo chown node_exporter:node_exporter /usr/bin/node_exporter

    cat <<EOL | sudo tee /usr/lib/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter  --web.listen-address=:9100
[Install]
WantedBy=multi-user.target
EOL

    sudo chmod 664 /usr/lib/systemd/system/node_exporter.service

    systemctl daemon-reload
    systemctl start node_exporter
    systemctl enable node_exporter.service
    systemctl status node_exporter

fi