# Provide the WSUWP Platform to our production environment.
#
# @todo consider web files as part of a deployment process instead.
/var/www/wsuwp-platform:
    file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 775
    - file_mode: 664
    - recurse:
        - user
        - group

wsuwp-initial:
  cmd.run:
    - name: cd /var/local/; git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform-vcs; cd wsuwp-platform-vcs; git submodule init
    - unless: cd /var/local/wsuwp-platform-vcs
    - require:
      - pkg: git

wsuwp-update:
  cmd.run:
    - name: cd /var/local/wsuwp-platform-vcs; git pull origin master; git submodule update
    - require:
      - pkg: git

wsuwp-sync:
  cmd.run:
    - name: rsync -rvzh --delete --exclude='.git' --exclude='local-config.php' --exclude='remote-config.php' /var/local/wsuwp-platform-vcs/ /var/www/wsuwp-platform; chown -R www-data:www-data /var/www/wsuwp-platform
    - require:
      - file: /var/www/wsuwp-platform

wsuwp-db:
  mysql_user.present:
    - name: wp
    - password: wp
    - host: localhost
    - require:
      - service: mysql
      - pkg: mysql
  mysql_database.present:
    - name: wsuwp
    - require:
      - service: mysql
      - pkg: mysql
  mysql_grants.present:
    - grant: all privileges
    - database: wsuwp.*
    - user: wp
    - require:
      - service: mysql
      - pkg: mysql
