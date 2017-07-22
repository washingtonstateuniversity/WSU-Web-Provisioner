

/etc/php-fpm.d/www.conf:
  file.managed:
    - template: jinja
    - source: salt://config/php-fpm/www.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-fpm

# Configure PHP with a jinja template.
/etc/php.ini:
  file.managed:
    - template: jinja
    - source: salt://config/php-fpm/php.ini.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-fpm

/etc/logrotate.d/php-fpm:
  file.managed:
    - source: salt://config/logrotate/php-fpm
    - user: root
    - group: root
    - mode: 664
    - require:
      - pkg: php-fpm

{% if 'local' == salt['pillar.get']('network:location', 'local') %}
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
{% endif %}
