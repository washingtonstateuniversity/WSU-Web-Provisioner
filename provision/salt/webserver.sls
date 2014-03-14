group-www-data:
  group.present:
    - name: www-data
    - gid: 510

user-www-data:
  user.present:
    - name: www-data
    - uid: 510
    - gid: 510
    - groups:
      - www-data
    - require:
      - group: www-data

user-www-deploy:
  user.present:
    - name: www-deploy
    - groups:
      - www-data
    - require:
      - group: www-data

# Manage a custom compile script for Nginx.
/root/nginx-compile.sh:
  file.managed:
    - source: salt://config/nginx/compile-nginx.sh
    - owner: root
    - group: root
    - mode: 755

# Manage the service init script for Nginx.
/etc/init.d/nginx:
  file.managed:
    - name: /etc/init.d/nginx
    - source: salt://config/nginx/init-nginx
    - user: root
    - group: root
    - mode: 755
    - require_in:
      - cmd: nginx

# Compile and install Nginx.
nginx:
  cmd.run:
    - name: sh nginx-compile.sh
    - cwd: /root/
    - unless: nginx -v 2>&1 | grep "1.5.11"
    - require:
      - file: /root/nginx-compile.sh
      - user: www-data
      - group: www-data
  service.running:
    - require:
      - cmd: nginx
      - file: /etc/init.d/nginx
      - user: www-data
      - group: www-data
    - watch:
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/sites-enabled/*

# Set Nginx to run in levels 2345.
nginx-init:
  cmd.run:
    - name: chkconfig --level 2345 nginx on
    - cwd: /
    - require:
      - cmd: nginx
      - file: /etc/init.d/nginx

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

# Configure Nginx with a jinja template.
/etc/nginx/nginx.conf:
  file.managed:
    - template: jinja
    - source:   salt://config/nginx/nginx.conf.jinja
    - user:     root
    - group:    root
    - mode:     644
    - require:
      - cmd:    nginx
    - context:
      network: {{ pillar['network'] }}

/etc/nginx/sites-enabled/default:
  file.managed:
    - source: salt://config/nginx/default
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: nginx

/etc/php-fpm.d/www.conf:
  file.managed:
    - source: salt://config/php-fpm/www.conf
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

/etc/php.ini:
  file.managed:
    - source: salt://config/php-fpm/php.ini
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-fpm

{% if pillar['network']['location'] == 'local' %}
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
{% endif %}