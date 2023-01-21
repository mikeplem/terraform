#!/usr/bin/env bash

# crontab -e
# @hourly $HOME/checks.sh

TWILIO_ACCOUNT_SID="XXXXX"
TWILIO_AUTH_TOKEN="XXXX"
TWILIO_NUMBER="XXXX"
TO_NUMBER="XXXX"

disk_util=$(df /dev/nvme0n1p1 | tail -1 | awk '{print $5}' | tr -d '%')

echo "Disk util is ${disk_util}" | systemd-cat -t CHECKS -p info

if [ "${disk_util}" -gt 50 ]; then
    echo "Disk util is above 50%" | systemd-cat -t CHECKS -p alert
    curl -X POST \
    -d "Body=Mastadon Disk util is above 50%" \
    -d "From=$TWILIO_NUMBER" \
    -d "To=$TO_NUMBER" \
    "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages" \
    -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
fi
