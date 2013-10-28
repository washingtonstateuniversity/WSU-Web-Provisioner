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
    - watch:
      - file: /etc/my.cnf

/etc/my.cnf:
  file.managed:
    - source: salt://config/mysql/my.cnf
    - user: root
    - group: root
    - mode: 644