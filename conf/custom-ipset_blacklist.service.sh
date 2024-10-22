SERVICE='[Unit]
Description=Custom script to refresh blocked IP addresses and subnets for firewall

[Service]
Type=simple
ExecStart='$FOLDER'
TimeoutStartSec=50m

[Install]
WantedBy=timers.target'
