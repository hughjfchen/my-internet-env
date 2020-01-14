#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "wg" "deploy prepare"

wg_IMAGE_ID=$(sg docker -c "docker images"|grep -w wireguard|awk '{print $3}')
if [ "${wg_IMAGE_ID}X" == "X" ]; then
    my_exit "no wg local build image found, abort" 1
fi

begin_banner "wg" "deploy prepare - install kernel DKMS module"
sg docker -c "docker run -it --rm --cap-add sys_module -v /lib/modules:/lib/modules wireguard:local install-module"
done_banner "wg" "deploy prepare - install kernel DKMS module"

wg_config_path="/var/wg/config"
wg_data_path="/var/wg/data"

if [ ! -d /var/wg ]; then
    info "no /var/wg directory found, create it..."
    sudo mkdir -p /var/wg/data
    sudo mkdir -p /var/wg/config/wg0
    sudo mkdir -p /var/wg/config/wg1
fi

sudo cp ${SCRIPT_ABS_PATH}/config/wg0/wg0.conf /var/wg/config/wg0/wg0.conf.orig

sudo "sed \"s:MY_PRI_TO_REPLACE:6CEKWiwOLhgl5jTDzsckRYEwVJhHS/l65/BV6NZRPX0=:g\" < /var/wg/config/wg0/wg0.conf.orig > /var/wg/config/wg0/wg0.conf.01"
sudo "sed \"s:MY_PUB_TO_REPLACE:W+qjMI6v4vZsOHEYUBxTJNwBQ+uzzpbXaY4ExBkRVR4=:g\" < /var/wg/config/wg0/wg0.conf.01 > /var/wg/config/wg0/wg0.conf"

sudo cp ${SCRIPT_ABS_PATH}/config/wg1/wg1.conf /var/wg/config/wg1/wg1.conf.orig

sudo "sed \"s:MY_PRI_TO_REPLACE:eCgvpTXAcR8jwPoOLzsNUAyyeNexQC3zxsCfjS69c2w=:g\" < /var/wg/config/wg1/wg1.conf.orig > /var/wg/config/wg1/wg1.conf.01"
sudo "sed \"s:MY_PUB_TO_REPLACE:s9X5DSidTMY2EppGgNzWvN/XJfWFBcsGFW2QPbuPyiI=:g\" < /var/wg/config/wg1/wg1.conf.01 > /var/wg/config/wg1/wg1.conf"

done_banner "wg" "deploy prepare"
