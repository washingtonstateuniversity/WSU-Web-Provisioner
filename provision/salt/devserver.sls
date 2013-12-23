php-pecl-xdebug:
  pkg.installed:
    - pkgs:
      - php-pecl-xdebug
    - require:
      - pkg: php-fpm

/etc/php.d/xdebug.ini:
  file.managed:
    - source: salt://config/php-fpm/xdebug.ini
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-pecl-xdebug
