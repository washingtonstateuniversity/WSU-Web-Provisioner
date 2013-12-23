php-pecl-xdebug:
  pkg.installed:
    - pkgs:
      - php-pecl-xdebug

/etc/dhcp/dhclient-enter-hooks:
  file.managed:
    - source: salt://config/dhclient-enter-hooks
    - user: root
    - group: root
    - mode: 755
