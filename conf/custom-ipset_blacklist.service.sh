SERVICE='[Unit]
Description=Custom script to refresh blocked IP addresses and subnets for firewall

[Service]
Type=simple
ExecStart='$FOLDER'

[Install]
WantedBy=timers.target'
