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
      - php54w-fpm
      - php54w-cli
      - php54w-mysql
  service.running:
    - require:
      - pkg: php-fpm