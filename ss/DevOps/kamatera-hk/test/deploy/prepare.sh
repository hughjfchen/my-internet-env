#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "deploy prepare"

if [ ! -L ${SCRIPT_ABS_PATH}/../../../../result ]; then
    warn "no ss build result found, suppose that the image would be pull from registry"
else
    sudo sg docker -c "docker load -i ${SCRIPT_ABS_PATH}/../../../../result"
fi

set +e
myGroup2=$(awk -F":" '{print $1}' /etc/group | grep -w ss)
set -e
if [ "X${myGroup2}" = "X" ]; then
    info "no ss group defined yet, create it..."
    sudo groupadd -f --gid 90001 ss
fi

set +e
myUser2=$(awk -F":" '{print $1}' /etc/passwd | grep -w ss)
set -e
if [ "X${myUser2}" = "X" ]; then
    info "no ss user defined yet, create it..."
    sudo useradd -G docker -m -p Passw0rd --uid 90001 --gid 90001 ss
fi

if [ ! -d /var/ss ]; then
    info "no /var/ss directory found, create it..."
    sudo mkdir -p /var/ss/data
    sudo mkdir -p /var/ss/config
    sudo chown -R ss:ss /var/ss
fi

sudo cp ${SCRIPT_ABS_PATH}/docker-compose.yml /var/ss/docker-compose-ss.yml.orig
sudo chown ss:ss /var/ss/docker-compose-ss.yml.orig

sudo sed "s:ss_config_path:/var/ss/config:g" < /var/ss/docker-compose-ss.yml.orig | sudo su -p -c "dd of=/var/ss/docker-compose-ss.yml.01" ss 
sudo sed "s:ss_data_path:/var/ss/data:g" < /var/ss/docker-compose-ss.yml.01 | sudo su -p -c "dd of=/var/ss/docker-compose-ss.yml" ss

if [ -L ${SCRIPT_ABS_PATH}/../../../../result ]; then
    ss_IMAGE_ID=$(sudo sg docker -c "docker images"|grep -w ss|awk '{print $3}')
    cmdPath=$(sudo sg docker -c "docker image inspect ${ss_IMAGE_ID}" | grep "/nix/store/" | awk -F"/" '{print "/nix/store/"$4}')
    sudo sed "s:static_ss_nix_store_path:${cmdPath}:g" < /var/ss/docker-compose-ss.yml | sudo su -p -c "dd of=/var/ss/docker-compose-ss.yml.02" ss
    sudo cat /var/ss/docker-compose-ss.yml.02 | sudo su -p -c "dd of=/var/ss/docker-compose-ss.yml" ss
fi

done_banner "ss" "deploy prepare"
