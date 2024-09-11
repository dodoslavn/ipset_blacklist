SERVICE='[Unit]
Description=Custom script to refresh blocked IP addresses and subnets for firewall

[Service]
Type=simple
ExecStart=/opt/git/host_jump_keys/scripts/refresh.sh

[Install]
WantedBy=timers.target'
