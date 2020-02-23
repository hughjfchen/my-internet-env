#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "Cont. Deploy and Test"

${SCRIPT_ABS_PATH}/../../../../DevOps/kamatera-hk/test/prepare.sh
${SCRIPT_ABS_PATH}/../../../../DevOps/kamatera-hk/test/deploy/prepare.sh

${SCRIPT_ABS_PATH}/deploy/prepare.sh
${SCRIPT_ABS_PATH}/deploy/deploy.sh
${SCRIPT_ABS_PATH}/deploy/finishing.sh

${SCRIPT_ABS_PATH}/../../../../DevOps/kamatera-hk/test/deploy/finishing.sh

${SCRIPT_ABS_PATH}/../../../../DevOps/kamatera-hk/test/test/prepare.sh

${SCRIPT_ABS_PATH}/test/prepare.sh
${SCRIPT_ABS_PATH}/test/test.sh
${SCRIPT_ABS_PATH}/test/finishing.sh
${SCRIPT_ABS_PATH}/finishing.sh

${SCRIPT_ABS_PATH}/../../../../DevOps/kamatera-hk/test/finishing.sh

done_banner "ss" "Cont. Deploy and Test"
