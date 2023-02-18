#!/usr/bin/env bash
# idea taken from
# https://www.linuxbabe.com/ubuntu/how-to-install-mastodon-on-ubuntu
# userdata log file
# /var/log/cloud-init-output.log

MASTADON_VERSION="v4.0.2"

export DEBIAN_FRONTEND=noninteractive

echo "running apt-get update" | systemd-cat -t USERDATA -p info
apt-get update -y

echo "running apt-get install nvme, jq, xfs" | systemd-cat -t USERDATA -p info
apt-get install -y nvme-cli jq xfsprogs ca-certificates gnupg

echo "installing postgres apt key" | systemd-cat -t USERDATA -p info
curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null

echo "adding postgresl package source" | systemd-cat -t USERDATA -p info
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

echo "after postgresql apt-get update" | systemd-cat -t USERDATA -p info
apt-get update -y

echo "making directories" | systemd-cat -t USERDATA -p info
mkdir -p /tmp/ssm
mkdir -p /var/www
mkdir -p /var/lib/postgresql
mkdir -p /var/www/cache/

echo "installing and starting amazon ssm agent" | systemd-cat -t USERDATA -p info
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_arm64/amazon-ssm-agent.deb
dpkg --install amazon-ssm-agent.deb
rm /tmp/ssm/amazon-ssm-agent.deb
systemctl restart amazon-ssm-agent

echo "getting env vars" | systemd-cat -t USERDATA -p info
export AWS_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
export EC2ID=$(curl -s -H "X-aws-ec2-metadata-token: $AWS_TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
export DBVOL=$(aws ec2 describe-volumes --filter "Name=attachment.instance-id,Values=${EC2ID}" "Name=tag:disk_role,Values=db" --query 'Volumes[].VolumeId' --region us-east-1 --output text)
export MASTVOL=$(aws ec2 describe-volumes --filter "Name=attachment.instance-id,Values=${EC2ID}" "Name=tag:disk_role,Values=mastadon" --query 'Volumes[].VolumeId' --region us-east-1 --output text)

echo "getting nvme device list" | systemd-cat -t USERDATA -p info
/usr/sbin/nvme list -o json 2> /dev/null | jq -r '.Devices[].DevicePath' > /tmp/dev.list

while read -r _disk; do
    echo "Checking ${_disk}" | systemd-cat -t USERDATA -p info
    NVME_DB=$(/usr/sbin/nvme id-ctrl -v "${_disk}" | tr -d ' ' | grep '^sn' | awk -F ':' '{print $2}' | sed 's/^vol/vol-/')

    if [[ "${DBVOL}" == "${NVME_DB}" ]]; then
        echo "setting up postgresl mount point" | systemd-cat -t USERDATA -p info
        mkfs.xfs -L DB "${_disk}"
        echo "LABEL=DB /var/lib/postgresql xfs defaults,noatime 0 0" >> /etc/fstab
        mount /var/lib/postgresql
    fi

    if [[ "${MASTVOL}" == "${NVME_DB}" ]]; then
        echo "setting up mastadon mount point" | systemd-cat -t USERDATA -p info
        mkfs.xfs -L MASTADON "${_disk}"
        echo "LABEL=MASTADON /var/www xfs defaults,noatime 0 0" >> /etc/fstab
        mount /var/www
    fi
done < /tmp/dev.list

echo "Checking if postgresql mount in fstab" | systemd-cat -t USERDATA -p info
if ! grep -q 'LABEL=DB' /etc/fstab; then
    exit
fi

echo "Checking if mastadon mount in fstab" | systemd-cat -t USERDATA -p info
if ! grep -q 'LABEL=MASTADON' /etc/fstab; then
    exit
fi


if ! df /var/lib/postgresql > /dev/null 2>&1; then
    echo "postgresql is NOT mounted" | systemd-cat -t USERDATA -p info
    exit
fi

if ! df /var/www > /dev/null 2>&1; then
    echo "www is NOT mounted" | systemd-cat -t USERDATA -p info
    exit
fi

echo "Installing dependency software" | systemd-cat -t USERDATA -p info
apt-get install -y ruby ruby-dev \
    git redis-server optipng pngquant jhead jpegoptim gifsicle nodejs \
    imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file g++ \
    libprotobuf-dev protobuf-compiler pkg-config gcc autoconf bison \
    build-essential libssl-dev libyaml-dev libreadline-dev zlib1g-dev \
    libncurses5-dev libffi-dev libgdbm-dev libidn11-dev libicu-dev libjemalloc-dev \
    postgresql-15 postgresql-contrib nginx certbot python3-certbot-nginx

echo "creating mastadon user" | systemd-cat -t USERDATA -p info
adduser mastodon --system --group --disabled-login

echo "Creating mastadon db creation script" | systemd-cat -t USERDATA -p info
cat << EOF > /tmp/mastadon.sql
CREATE DATABASE mastodon;
CREATE USER mastodon;
ALTER USER mastodon WITH ENCRYPTED PASSWORD "$(aws ssm get-parameter --name /mastadon/db_pass --with-decryption --query 'Parameter.Value' --region us-east-1 --output text)";
ALTER USER mastodon createdb;
ALTER DATABASE mastodon OWNER TO mastodon;
\q
EOF

sed -i "s/\"/'/g" /tmp/mastadon.sql

cat << EOF > /tmp/run_mastadon_sql.sh
psql < /tmp/mastadon.sql
EOF

chown postgres:postgres /tmp/mastadon.sql /tmp/run_mastadon_sql.sh
chmod 755 /tmp/run_mastadon_sql.sh

echo "Running db creation script" | systemd-cat -t USERDATA -p info
sudo -u postgres -i /tmp/run_mastadon_sql.sh

echo "clone mastadon repo" | systemd-cat -t USERDATA -p info
cd /var/www
git clone https://github.com/mastodon/mastodon.git
chown -R mastodon:mastodon /var/www/mastodon/
cd /var/www/mastodon/
sudo -u mastodon git checkout "${MASTADON_VERSION}"

echo "Install nodejs" | systemd-cat -t USERDATA -p info
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

echo "setup yarn package source" | systemd-cat -t USERDATA -p info
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list

echo "install ruby bundler" | systemd-cat -t USERDATA -p info
gem install bundler

echo "install yarn" | systemd-cat -t USERDATA -p info
apt-get update -y
apt-get -y install yarn

echo "setup bundler environment" | systemd-cat -t USERDATA -p info
sudo -u mastodon bundle config deployment 'true'
sudo -u mastodon bundle config without 'development test'
sudo -u mastodon bundle install -j$(getconf _NPROCESSORS_ONLN)

echo "setup nginx" | systemd-cat -t USERDATA -p info
cp /var/www/mastodon/dist/nginx.conf /etc/nginx/conf.d/mastodon.conf
sed -i 's/example\.com/social\.n1mtp\.com/' /etc/nginx/conf.d/mastodon.conf
sed -i 's%/home/mastodon/live/public%/var/www/mastodon/public%' /etc/nginx/conf.d/mastodon.conf
sed -i 's%/var/cache/nginx%/var/www/nginx%' /etc/nginx/conf.d/mastodon.conf
sed -i -e 's%#[[:space:]]*ssl_certificate[[:space:]]*/etc/letsencrypt/live/social.n1mtp.com/fullchain.pem%ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem%' -e 's%#[[:space:]]*ssl_certificate_key[[:space:]]*/etc/letsencrypt/live/social.n1mtp.com/privkey.pem%ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key%' /etc/nginx/conf.d/mastodon.conf

if ! nginx -t; then
    echo "nginx config is invalid" | systemd-cat -t USERDATA -p info
else
    systemctl restart nginx
fi

#echo "certbot" | systemd-cat -t USERDATA -p info
# certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email <email> -d social.n1mtp.com
# certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email <email> -d files.social.n1mtp.com

#echo "configure mastadon" | systemd-cat -t USERDATA -p info
#cd /var/www/mastadon
#sudo -u mastodon RAILS_ENV=production bundle exec rake mastodon:setup

#echo "Copy service files" | systemd-cat -t USERDATA -p info
#cp /var/www/mastodon/dist/mastodon*.service /etc/systemd/system/
#sed -i 's/home\/mastodon\/live/var\/www\/mastodon/g' /etc/systemd/system/mastodon-*.service
#sed -i 's/home\/mastodon\/.rbenv\/shims/usr\/local\/bin/g' /etc/systemd/system/mastodon-*.service
#systemctl daemon-reload
#sudo systemctl enable --now mastodon-web mastodon-sidekiq mastodon-streaming

echo "Cleaning up" | systemd-cat -t USERDATA -p info
rm -f /tmp/mastadon.sql
rm -f /tmp/run_mastadon_sql.sh
rm -f /tmp/dev.list
