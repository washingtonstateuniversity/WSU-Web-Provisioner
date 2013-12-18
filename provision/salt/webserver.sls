group-www-data:
  group.present:
    - name: www-data

user-www-data:
  user.present:
    - name: www-data
    - groups:
      - www-data
    - require:
      - group: www-data

/etc/hosts:
  file.managed:
    - source: salt://config/hosts
    - user: root
    - group: root
    - mode: 644

/etc/resolv.conf:
  file.managed:
    - source: salt://config/resolv.conf
    - user: root
    - group: root
    - mode: 644

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
      - file: /etc/nginx/sites-enabled/default
      - file: /etc/nginx/sites-enabled/wp.wsu.edu.conf

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
      - php-pecl-xdebug
      - php-pecl-memcached
  service.running:
    - require:
      - pkg: php-fpm
    - watch:
      - file: /etc/php-fpm.d/www.conf

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

iptables:
  pkg.installed:
    - name: iptables
  service.running:
    - watch:
      - file: /etc/sysconfig/iptables

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://config/nginx/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/default:
  file.managed:
    - source: salt://config/nginx/default
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/wp.wsu.edu.conf:
  file.managed:
    - source: salt://config/nginx/wp.wsu.edu.conf
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

/etc/php.ini:
  file.managed:
    - source: salt://config/php-fpm/php.ini
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: php-fpm

/etc/sysconfig/iptables:
  file.managed:
    - source: salt://config/iptables/iptables
    - user: root
    - group: root
    - mode: 600
