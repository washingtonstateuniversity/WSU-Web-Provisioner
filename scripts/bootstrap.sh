#!/bin/bash
sh /tmp/wsu-web/provision/bootstrap_salt.sh -K stable
cp /tmp/wsu-web/provision/salt/minions/wsu-general.conf /etc/salt/minion.d/