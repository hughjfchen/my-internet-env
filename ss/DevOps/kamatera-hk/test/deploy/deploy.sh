#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "deploy deploy"

docker run -dt --rm --name ssserver-kcptun -p 6443:6443 -p 6500:6500/udp shadowsocks:local -m "ss-server" -s "-s 0.0.0.0 -p 6443 -m chacha20-ietf -k Passw0rd" -x -e "kcpserver" -k "-t 127.0.0.1:6443 -l :6500 -mode fast2"
docker run -dt --rm --name ssserver-obfs -p 8443:8443  shadowsocks:local -m "ss-server" -s "-s 0.0.0.0 -p 8443 -m chacha20-ietf -k Passw0rd --plugin obfs-server --plugin-opts obfs=tls"

done_banner "ss" "deploy deploy"
