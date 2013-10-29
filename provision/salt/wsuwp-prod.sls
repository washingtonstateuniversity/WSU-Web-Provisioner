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
    - name: rsync -rvzh --delete --exclude='.git' /var/local/wsuwp-platform-vcs/ /var/www/wsuwp-platform; chown -R www-data:www-data /var/www/wsuwp-platform
    - require:
      - pkg: git

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
