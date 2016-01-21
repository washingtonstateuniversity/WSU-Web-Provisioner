php-fpm:
  pkg.latest:
    - pkgs:
      - php-fpm
      - php-cli
      - php-common
      - php-pear
      - php-pdo
      - php-mcrypt
      - php-mysqlnd
      - php-imap
      - php-pecl-memcached
      - php-opcache
      - php-ldap
      - php-mbstring
      - php-soap
    - require:
      - pkgrepo: remi-php56-repo
  service.running:
    - require:
      - pkg: php-fpm
      - user: www-data
      - group: www-data
    - watch:
      - file: /etc/php-fpm.d/www.conf
      - file: /etc/php.ini
      - file: /etc/php.d/opcache.ini

ImageMagick:
  pkg.latest:
    - pkgs:
      - php-pecl-imagick
      - ImageMagick
    - require:
      - pkg: php-fpm

# Set php-fpm to run in levels 2345.
php-fpm-init:
  cmd.run:
    - name: chkconfig --level 2345 php-fpm on
    - cwd: /
    - require:
      - pkg: php-fpm
      - pkg: ImageMagickphp-fpm:
  pkg.latest:
    - pkgs:
      - php-fpm
      - php-cli
      - php-common
      - php-pear
      - php-pdo
      - php-mcrypt
      - php-mysqlnd
      - php-imap
      - php-pecl-memcached
      - php-opcache
      - php-ldap
      - php-mbstring
      - php-soap
    - require:
      - pkgrepo: remi-php56-repo
  service.running:
    - require:
      - pkg: php-fpm
      - user: www-data
      - group: www-data
    - watch:
      - file: /etc/php-fpm.d/www.conf
      - file: /etc/php.ini
      - file: /etc/php.d/opcache.ini

ImageMagick:
  pkg.latest:
    - pkgs:
      - php-pecl-imagick
      - ImageMagick
    - require:
      - pkg: php-fpm

# Set php-fpm to run in levels 2345.
php-fpm-init:
  cmd.run:
    - name: chkconfig --level 2345 php-fpm on
    - cwd: /
    - require:
      - pkg: php-fpm
      - pkg: ImageMagick


/etc/php-fpm.conf:
  file.managed:
    - source: salt://config/php-fpm/php-fpm.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-fpm

/etc/php-fpm.d/www.conf:
  file.managed:
    - template: jinja
    - source: salt://config/php-fpm/www.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-fpm

/etc/php.d/opcache.ini:
  file.managed:
    - source: salt://config/php-fpm/opcache.ini
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

# Start the php-fpm service
php-fpm-service:
  service.running:
    - name: php-fpm
    - require:
      - file: /etc/php.ini
      - file: /etc/php-fpm.d/www.conf
      - cmd: php-fpm-init

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