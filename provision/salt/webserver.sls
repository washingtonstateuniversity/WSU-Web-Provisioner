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

php-fpm:
  pkg.installed:
    - pkgs:
      - php54-fpm
      - php54-cli
      - php54-common
      - php54-mysql
      - php54-pear
      - php54-pdo
      - php54-pecl-memcache
      - php54-pecl-xdebug
      - php54-pecl-imagick
  service.running:
    - require:
      - pkg: php-fpm