yum install unzip

mkdir -p /srv/pillar/
mkdir -p /srv/pillar/config/
touch /srv/pillar/top.sls
touch /srv/pillar/network.sls
touch /srv/pillar/mysql.sls

groupadd ucadmin
useradd ucadmin -m -g ucadmin
passwd ucadmin
visudo