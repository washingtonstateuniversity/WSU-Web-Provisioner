group-www-data:
  group.present:
    - name: www-data

user-www-data:
  user.present:
    - name: www-data
    - groups:
      - www-data

/var/www/wsuwp-platform:
    file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 755
    - file_mode: 644
    - recurse:
        - user
        - group
        - mode

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
    - watch:
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/sites-enabled/default

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

/etc/nginx/sites-enabled/default:
  file.managed:
    - source: salt://config/nginx/default
    - user: root
    - group: root
    - mode: 644

/etc/php-fpm.d/www.conf:
  file.managed:
    - source: salt://config/php-fpm/www.conf
    - user: root
    - group: root
    - mode: 644

/etc/sysconfig/iptables:
  file.managed:
    - source: salt://config/iptables/iptables
    - user: root
    - group: root
    - mode: 600
