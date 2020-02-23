#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "wg" "deploy prepare"

if [ ! -L ${SCRIPT_ABS_PATH}/../../../../result ]; then
    warn "no wg build result found, suppose that the image would be pull from registry"
else
    sudo sg docker -c "docker load -i ${SCRIPT_ABS_PATH}/../../../../result"
fi

set +e
myGroup2=$(awk -F":" '{print $1}' /etc/group | grep -w wg)
set -e
if [ "X${myGroup2}" = "X" ]; then
    info "no wg group defined yet, create it..."
    sudo groupadd -f --gid 90001 wg
fi

set +e
myUser2=$(awk -F":" '{print $1}' /etc/passwd | grep -w wg)
set -e
if [ "X${myUser2}" = "X" ]; then
    info "no wg user defined yet, create it..."
    sudo useradd -G docker -m -p Passw0rd --uid 90001 --gid 90001 wg
fi

if [ ! -d /var/wg ]; then
    info "no /var/wg directory found, create it..."
    sudo mkdir -p /var/wg/data
    sudo mkdir -p /var/wg/config
    sudo chown -R wg:wg /var/wg
fi

sudo cp ${SCRIPT_ABS_PATH}/docker-compose.yml /var/wg/docker-compose-wg.yml.orig
sudo chown wg:wg /var/wg/docker-compose-wg.yml.orig

sudo sed "s:wg_config_path:/var/wg/config:g" < /var/wg/docker-compose-wg.yml.orig | sudo su -p -c "dd of=/var/wg/docker-compose-wg.yml.01" wg 
sudo sed "s:wg_data_path:/var/wg/data:g" < /var/wg/docker-compose-wg.yml.01 | sudo su -p -c "dd of=/var/wg/docker-compose-wg.yml" wg

if [ -L ${SCRIPT_ABS_PATH}/../../../../result ]; then
    wg_IMAGE_ID=$(sudo sg docker -c "docker images"|grep -w wg|awk '{print $3}')
    cmdPath=$(sudo sg docker -c "docker image inspect ${wg_IMAGE_ID}" | grep "/nix/store/" | awk -F"/" '{print "/nix/store/"$4}')
    sudo sed "s:static_wg_nix_store_path:${cmdPath}:g" < /var/wg/docker-compose-wg.yml | sudo su -p -c "dd of=/var/wg/docker-compose-wg.yml.02" wg
    sudo cat /var/wg/docker-compose-wg.yml.02 | sudo su -p -c "dd of=/var/wg/docker-compose-wg.yml" wg
fi

done_banner "wg" "deploy prepare"
