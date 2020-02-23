#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "build unbuild"
begin_banner "ss" "build unbuild - clean up the local docker image"
sg docker -c "docker rmi -f $(docker images|grep -w shadowsocks|awk '{print $3}')"
done_banner "ss" "build unbuild - clean up the local docker image"
done_banner "ss" "build unbuild"
