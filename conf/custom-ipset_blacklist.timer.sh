TIMER='[Unit]
Description=Run script to refresh my keys every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target'
