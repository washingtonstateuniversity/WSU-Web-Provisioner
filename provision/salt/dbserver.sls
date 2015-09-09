group-mysql:
  group.present:
    - name: mysql

user-mysql:
  user.present:
    - name: mysql
    - groups:
      - mysql
    - require:
      - group: mysql
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
    - require_in:
      - pkg: mysql

mysql:
  pkg.latest:
    - pkgs:
      - mysql
      - mysql-libs
      - mysql-server
      - MySQL-python
    - require:
      - pkgrepo: mysql-community-repo

# Set MySQL to run in levels 2345.
mysqld-init:
  cmd.run:
    - name: chkconfig --level 2345 mysqld on
    - cwd: /
    - require:
      - pkg: mysql

# Configure MySQL with a jinja template.
/etc/my.cnf:
  file.managed:
    - template: jinja
    - source: salt://config/mysql/my.cnf.jinja
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
    - require:
      - service: mysqld

# Replicate the functionality of mysql_secure_installation.
mysql-secure-installation:
  mysql_database.absent:
    - name: test
    - require:
      - service: mysqld
  mysql_user.absent:
    - name: ""
    - require:
      - service: mysqld