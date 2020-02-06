#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "deploy prepare"

if [ ! -L ${SCRIPT_ABS_PATH}/../../../../result ]; then
    warn "no ss build result found, suppose that the image would be pull from registry or already built  locally"
else
    sg docker -c "docker load -i ${SCRIPT_ABS_PATH}/../../../../result"
fi

done_banner "ss" "deploy prepare"
