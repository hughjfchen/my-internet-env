#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "build prepare"

#clone the source tree into a src directory and checkout the appropriate branch.
git clone https://github.com/mritd/dockerfile

done_banner "ss" "build prepare"
