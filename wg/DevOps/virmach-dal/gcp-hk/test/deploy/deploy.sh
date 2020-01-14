#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "wg" "deploy deploy"

sg docker -c "docker run -dt --rm --name wg-for-phone --cap-add net_admin --cap-add sys_module -v /var/wg/config/wg0:/etc/wireguard -p 5555:5555/udp wireguard:local"

sg docker -c "docker run -dt --rm --name wg-for-laptop --cap-add net_admin --cap-add sys_module -v /var/wg/config/wg1:/etc/wireguard -p 6666:6666/udp wireguard:local"

done_banner "wg" "deploy deploy"
