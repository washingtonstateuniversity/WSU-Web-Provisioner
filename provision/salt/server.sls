# server.sls
#
# This state file should provide states for many of the common things
# that a server should be configured with before much else is provisioned.
# This is the first state file processed during provisioning.

# Prevent any kind of DHCP activity from overwriting our
# custom resolv.conf. This allows us to control the nameservers
# that we use.
/etc/dhcp/dhclient-enter-hooks:
  file.managed:
    - source: salt://config/dhclient-enter-hooks
    - user: root
    - group: root
    - mode: 755
    - require_in:
      - file: /etc/resolv.conf

# Provide specific nameservers to use on the server. These can vary
# depending on production or development. The primary nameservers
# may not be reliable from remote locations when developing, and public
# nameservers may not be accessible from inside the firewall in production.
/etc/resolv.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents_pillar: network:nameservers
    - require_in:
      - pkgrepo: remi-repo
      - pkgrepo: remi-php56-repo
      - pkgrepo: centos-plus-repo

# Use packages from the Remi Repository rather than some of the older
# RPMs that are included in the default CentOS repository.
remi-repo:
  pkgrepo.managed:
    - humanname: Remi Repository
    - baseurl: http://rpms.famillecollet.com/enterprise/6/remi/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkgrepo: remi-php56-repo

# Remi has a repository specifically setup for PHP 5.6. This continues
# to reply on the standard Remi repository for some packages.
remi-php56-repo:
  pkgrepo.managed:
    - humanname: Remi PHP 5.6 Repository
    - baseurl: http://rpms.famillecollet.com/enterprise/6/php56/x86_64/
    - gpgcheck: 0

# MySQL maintains a repository for MySQL 5.6. The default CentOS and Remi
# repositories only provide 5.5.
mysql-community-repo:
  pkgrepo.managed:
    - humanname: MySQL 5.6 Community Server
    - baseurl: http://repo.mysql.com/yum/mysql-5.6-community/el/6/x86_64/
    - gpgcheck: 0

# Use packages from the CentOS plus repository when applicable.
centos-plus-repo:
  pkgrepo.managed:
    - humanname: CentOS Plus
    - baseurl: http://mirror.centos.org/centos/6/centosplus/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: postfix

# Update the server's CA Certificates
#
# This is handled separately from other package installations as the
# CA certificates may affect those installs depending on the repository.
#
ca-certificates:
  pkg.latest:
    - name: ca-certificates
    - disablerepo: epel

# Provide some packages that the Nginx build relies on.
src-build-prereq:
  pkg.installed:
    - pkgs:
      - gcc-c++
      - pcre-devel
      - zlib-devel
      - make

# Always check for the latest versions of several packages.
#
# Of interest:
#    - munin is a utility used to track server resources
#    - vnStat is a console based network traffic monitor
#
core-pkgs-latest:
  pkg.latest:
    - pkgs:
      - glibc
      - bash
      - wget
      - curl
      - yum
      - openssl
      - postfix
      - git
      - munin
      - vnstat

/etc/munin/munin.conf:
  file.managed:
    - source: salt://config/munin/munin.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: munin

/etc/munin/plugin-conf.d/munin-node:
  file.managed:
    - source: salt://config/munin/munin-node
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: munin

/etc/munin/plugins/nginx_status:
  file.symlink:
    - target: /usr/share/munin/plugins/nginx_status
    - require:
      - pkg: munin

/etc/munin/plugins/nginx_request:
  file.symlink:
    - target: /usr/share/munin/plugins/nginx_request
    - require:
      - pkg: munin

/var/www-munin:
  file.directory:
    - user: munin
    - group: munin
    - mode: 755
    - require:
      - pkg: munin

munin-node:
  service.running:
    - name: munin-node
    - require:
      - pkg: munin
      - file: /etc/munin/munin.conf
    - watch:
      - file: /etc/munin/munin.conf
      - file: /etc/munin/plugin-conf.d/munin-node

# htop is a useful server resource monitoring tool
htop:
  pkg.installed:
    - name: htop

# iotop is useful for monitoring disk activity
iotop:
  pkg.installed:
    - name: iotop

# Ensure the vnstat service is started.
vnstat-service:
  service.running:
    - name: vnstat
    - require:
      - pkg: vnstat

# The telnet package can be used for various connection testing.
telnet:
  pkg.installed:
    - name: telnet

# The samba-client package helps to connect to shared drives.
samba-client:
  pkg.installed:
    - name: samba-client

# The cifs-utils package works in combination with Samba.
cifs-utils:
  pkg.installed:
    - name: cifs-utils

# Make sure the ntpd service is running.
ntpd-service:
  service.running:
    - name: ntpd
