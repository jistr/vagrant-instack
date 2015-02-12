#!/bin/bash

useradd stack
passwd stack --stdin <<< 'stack'
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

cp /vagrant-master/instack.answers /home/stack/instack.answers
chown stack: /home/stack/instack.answers

rpm -Uvh http://rhos-release.virt.bos.redhat.com/repos/rhos-release/rhos-release-latest.noarch.rpm

echo "Master configured."
