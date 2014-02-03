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

nginx-repo:
  pkgrepo.managed:
    - humanname: Nginx Repo
    - baseurl: http://nginx.org/packages/centos/6/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: nginx

nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - require:
      - pkg: nginx
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
      - pkg: nginx

php-fpm:
  pkg.installed:
    - pkgs:
      - php-fpm
      - php-cli
      - php-common
      - php-mysql
      - php-pear
      - php-pdo
      - php-mcrypt
      - php-imap
      - php-pecl-zendopcache
      - php-pecl-memcached
  service.running:
    - require:
      - pkg: php-fpm
    - watch:
      - file: /etc/php-fpm.d/www.conf
      - file: /etc/php.ini
      - file: /etc/php.d/opcache.ini

# Set php-fpm to run in levels 2345.
php-fpm-init:
  cmd.run:
    - name: chkconfig --level 2345 php-fpm on
    - cwd: /
    - require:
      - pkg: php-fpm

ImageMagick:
  pkg.installed:
    - pkgs:
      - php-pecl-imagick
      - ImageMagick

# Configure Nginx with a jinja template.
/etc/nginx/nginx.conf:
  file.managed:
    - template: jinja
    - source:   salt://config/nginx/nginx.conf.jinja
    - user:     root
    - group:    root
    - mode:     644
    - require:
      - pkg:    nginx
    - context:
      network: {{ pillar['network'] }}

/etc/nginx/sites-enabled/default:
  file.managed:
    - source: salt://config/nginx/default
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx

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