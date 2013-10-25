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
      - php-fpm
      - php-cli
      - php-common
      - php-mysql
      - php-pear
      - php-pdo
      - php-pecl-xdebug
  service.running:
    - require:
      - pkg: php-fpm

ImageMagick:
  pkg.installed:
    - pkgs:
      - php-pecl-imagick
      - ImageMagick