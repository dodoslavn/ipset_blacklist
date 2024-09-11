#!/bin/bash





cat ../conf/"$SERVICE_NAME".service > /etc/systemd/system/"$SERVICE_NAME".service
cat ../conf/"$SERVICE_NAME".timer > /etc/systemd/system/"$SERVICE_NAME".timer

systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME 
systemctl status $SERVICE_NAME 
