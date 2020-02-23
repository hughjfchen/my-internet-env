#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "ss" "deploy unprepare"

if [ -d /var/ss ]; then
    info "/var/ss directory found, delete it..."
    sudo rm -fr /var/ss
fi

set +e
myUser2=$(awk -F":" '{print $1}' /etc/passwd | grep -w ss)
if [ "X${myUser2}" != "X" ]; then
    info "ss user defined, delete it..."
    sudo userdel -fr ss
fi

myGroup2=$(awk -F":" '{print $1}' /etc/group | grep -w ss)
if [ "X${myGroup2}" != "X" ]; then
    info "ss group defined, delete it..."
    sudo groupdel -f ss
fi
set -e

MY_TO_REMOVE_IMAGES=$(sudo sg docker -c "docker images"|grep -w ss|awk '{print $3}')
for MY_TO_REMOVE_IMAGE in ${MY_TO_REMOVE_IMAGES}
do
    sudo sg docker -c "docker image rm -f ${MY_TO_REMOVE_IMAGE}"
done

done_banner "ss" "deploy unprepare"
