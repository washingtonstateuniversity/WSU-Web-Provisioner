remi-rep:
  pkgrepo.managed:
    - humanname: Remi Repository
    - baseurl: http://rpms.famillecollet.com/enterprise/6/remi/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: mysql
      - pkg: php-fpm
      - pkg: memcached

git:
  pkg.installed:
    - name: git