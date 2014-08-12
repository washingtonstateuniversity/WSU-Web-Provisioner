#!/bin/bash
cd /tmp && rm -fr wsu-web
cd /tmp && curl -o wsu-web.zip -L https://github.com/washingtonstateuniversity/wsu-web-provisioner/archive/master.zip
cd /tmp && unzip wsu-web.zip
cd /tmp && mv WSU-Web-Provisioner-master wsu-web
cp -fr /tmp/wsu-web/provision/salt /srv/
cp /tmp/wsu-web/provision/salt/config/yum.conf /etc/yum.conf