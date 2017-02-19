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
      - mysql-community-libs
      - mysql-community-server
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

/etc/logrotate.d/mysql:
  file.managed:
    - source: salt://config/logrotate/mysql
    - user: root
    - group: root
    - mode: 664
    - require:
      - pkg: mysql

# Start MySQL manually rather than with Salt's service-running config.
#
# In a previous iteration, using the built in service-running config caused
# an issue where provisioning would hang indefinitely because Salt does not
# receive any kind of callback telling it to move on.
#
# See https://github.com/saltstack/salt/issues/33442
mysql-start:
  cmd.run:
    - name: service mysqld start | cat
    - cwd: /
    - require:
      - pkg: mysql
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
