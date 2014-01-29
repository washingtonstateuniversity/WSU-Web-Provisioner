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

# Use packages from the Remi Repository rather than some of the older
# RPMs that are included in the default CentOS repository.
remi-rep:
  pkgrepo.managed:
    - humanname: Remi Repository
    - baseurl: http://rpms.famillecollet.com/enterprise/6/remi/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: mysql
      - pkg: php-fpm
      - pkg: memcached

# Git is useful to us in a few different places and should be one of the
# first things installed if it is not yet available.
git:
  pkg.installed:
    - name: git

# htop is a useful server resource monitoring tool
htop:
  pkg.installed:
    - name: htop

# iotop is useful for monitoring disk activity
iotop:
  pkg.installed:
    - name: iotop

telnet:
  pkg.installed:
    - name: telnet