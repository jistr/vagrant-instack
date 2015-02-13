#!/bin/bash

set -euo pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

if [[ "$(whoami)" != 'root' ]]; then
    echo "This script must be run as root."
    exit 1
fi

pushd "$DIR/.." > /dev/null
ansible-playbook -i ansible/inventories/local $@ ansible/playbooks/tripleo_host.yml
popd > /dev/null
