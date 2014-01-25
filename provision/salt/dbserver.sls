group-mysql:
  group.present:
    - name: mysql

user-mysql:
  user.present:
    - name: mysql
    - groups:
      - mysql
    - require_in:
      - pkg: mysql

/var/log/mysql:
  file.directory:
    - user: mysql
    - group: mysql
    - dir_mode: 775
    - file_mode: 664
    - recurse:
        - user
        - group
        - mode

mysql:
  pkg.installed:
    - pkgs:
      - mysql
      - mysql-libs
      - mysql-server
      - MySQL-python

# Set MySQL to run in levels 2345.
mysqld-init:
  cmd.run:
    - name: chkconfig --level 2345 mysqld on
    - cwd: /
    - require:
      - pkg: mysql

/etc/my.cnf:
  file.managed:
    - source: salt://config/mysql/my.cnf
    - user: root
    - group: root
    - mode: 664
    - require:
      - pkg: mysql

mysql-start:
  service.running:
    - name: mysqld
    - watch:
      - file: /etc/my.cnf
    - require:
      - file: /etc/my.cnf

set_localhost_root_password:
    mysql_user.present:
        - name: root
        - host: localhost
        - password: {{ pillar['mysql.pass'] }}
        - connection_pass: ""
        - watch:
            - pkg: mysql
            - service: mysqld

{% for site, site_args in pillar.get('wsuwp-indie-sites',{}).items() %}
wsuwp-indie-db-{{ site }}:
  mysql_user.present:
    - name: {{ site_args['db_user'] }}
    - password: {{ site_args['db_pass'] }}
    - host: {{ site_args['db_host'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - mysql_user: root
  mysql_database.present:
    - name: {{ site_args['database'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - mysql_user: root
  mysql_grants.present:
    - grant: select, insert, update, delete
    - database: {{ site_args['database'] }}.*
    - user: {{ site_args['db_user'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - mysql_user: root
{% endfor %}