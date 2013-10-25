# Our CentOS image comes with MySQL 5.1.6 preinstalled. We should
# remove these packages before replacing with MySQL 5.5
mysql:
  pkg.installed:
    - pkgs:
      - mysql
      - mysql-libs
      - mysql-server
  service.running:
    - name: mysqld
