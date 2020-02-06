#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "Cont. UnTest"

# I don't think we need to undo the top-level finishing and prepare
#${SCRIPT_ABS_PATH}/../../../../DevOps/linode-sg/test/unfinishing.sh
#${SCRIPT_ABS_PATH}/../../../../DevOps/linode-sg/test/test/unfinishing.sh

${SCRIPT_ABS_PATH}/unfinishing.sh
${SCRIPT_ABS_PATH}/test/unfinishing.sh
${SCRIPT_ABS_PATH}/test/untest.sh
${SCRIPT_ABS_PATH}/test/unprepare.sh
${SCRIPT_ABS_PATH}/unprepare.sh

# I don't think we need this either
#${SCRIPT_ABS_PATH}/../../../../DevOps/linode-sg/test/test/unprepare.sh
#${SCRIPT_ABS_PATH}/../../../../DevOps/linode-sg/test/unprepare.sh

done_banner "ss" "Cont. UnTest"
