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
      - pkgrepo: remi-php55-repo
      - pkgrepo: centos-plus-repo
      - pkgrepo: nginx-repo

# Use packages from the Remi Repository rather than some of the older
# RPMs that are included in the default CentOS repository.
remi-repo:
  pkgrepo.managed:
    - humanname: Remi Repository
    - baseurl: http://rpms.famillecollet.com/enterprise/6/remi/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: mysql
      - pkg: memcached
      - pkgrepo: remi-php55-repo

# Remi has a repository specifically setup for PHP 5.5. This continues
# to reply on the standard Remi repository for some packages.
remi-php55-repo:
  pkgrepo.managed:
    - humanname: Remi PHP 5.5 Repository
    - baseurl: http://rpms.famillecollet.com/enterprise/6/php55/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: php-fpm

# Use packages from the CentOS plus repository when applicable.
centos-plus-repo:
  pkgrepo.managed:
    - humanname: CentOS Plus
    - baseurl: http://mirror.centos.org/centos/6/centosplus/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: postfix

# Provide some packages that the Nginx build relies on.
src-build-prereq:
  pkg.installed:
    - pkgs:
      - gcc-c++
      - pcre-dev
      - pcre-devel
      - zlib-devel
      - make

# Ensure that postfix is at the latest revision.
postfix:
  pkg.latest:
    - name: postfix

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