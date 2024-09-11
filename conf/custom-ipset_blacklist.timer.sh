TIMER='[Unit]
Description=Run script to refresh blacklists for firewall

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target'
