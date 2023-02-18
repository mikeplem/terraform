#!/usr/bin/env bash
# idea taken from
# https://www.linuxbabe.com/ubuntu/how-to-install-mastodon-on-ubuntu
# userdata log file
# /var/log/cloud-init-output.log

echo "install software" | systemd-cat -t USERDATA -p info
yum install -y jq nvme-cli

echo "making directories" | systemd-cat -t USERDATA -p info
mkdir -p /var/log/amazon/ssm

echo "getting env vars" | systemd-cat -t USERDATA -p info
export AWS_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
export EC2ID=$(curl -s -H "X-aws-ec2-metadata-token: $AWS_TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
export SSMVOL=$(aws ec2 describe-volumes --filter "Name=attachment.instance-id,Values=${EC2ID}" "Name=tag:disk_role,Values=ssm_log" --query 'Volumes[].VolumeId' --region us-east-1 --output text)

echo "getting nvme device list" | systemd-cat -t USERDATA -p info
/usr/sbin/nvme list -o json 2> /dev/null | jq -r '.Devices[].DevicePath' > /tmp/dev.list

while read -r _disk; do
    echo "Checking ${_disk}" | systemd-cat -t USERDATA -p info
    NVME_DB=$(/usr/sbin/nvme id-ctrl -v "${_disk}" | tr -d ' ' | grep '^sn' | awk -F ':' '{print $2}' | sed 's/^vol/vol-/')

    if [[ "${SSMVOL}" == "${NVME_DB}" ]]; then
        echo "setting up SSM mount point" | systemd-cat -t USERDATA -p info
        mkfs.xfs -L SSMVOL "${_disk}"
        echo "LABEL=SSMVOL /var/log/amazon/ xfs defaults,noatime 0 0" >> /etc/fstab
        mount /var/log/amazon
        chown root:root /var/log/amazon
        chown root:root /var/log/amazon/ssm
        chmod 0700 /var/log/amazon
        chmod 0700 /var/log/amazon/ssm
    fi
done < /tmp/dev.list

echo "Checking if ssm log mount in fstab" | systemd-cat -t USERDATA -p info
if ! grep -q 'LABEL=SSMVOL' /etc/fstab; then
    exit
fi

if ! df /var/log/amazon > /dev/null 2>&1; then
    echo "/var/log/amazon is NOT mounted" | systemd-cat -t USERDATA -p info
    exit
fi

echo "Cleaning up" | systemd-cat -t USERDATA -p info
rm -f /tmp/dev.list

echo "Restart SSM Agent" | systemd-cat -t USERDATA -p info
systemctl restart amazon-ssm-agent
