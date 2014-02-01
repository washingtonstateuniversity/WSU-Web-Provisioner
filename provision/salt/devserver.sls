php-pecl-xdebug:
  pkg.installed:
    - pkgs:
      - php-pecl-xdebug
    - require:
      - pkg: php-fpm

# Configure xdebug with a jinja template
/etc/php.d/xdebug.ini:
  file.managed:
    - template: jinja
    - source: salt://config/php-fpm/xdebug.ini.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-pecl-xdebug
    - context:
      network: {{ pillar['network'] }}
