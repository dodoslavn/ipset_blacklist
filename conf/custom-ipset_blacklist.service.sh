SERVICE='[Unit]
Description=Custom script to refresh ssh key

[Service]
Type=simple
ExecStart=/opt/git/host_jump_keys/scripts/refresh.sh

[Install]
WantedBy=timers.target'
