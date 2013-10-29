# Setup the WSUWP Platform for local development in Vagrant.
wsuwp-dev-initial:
  cmd.run:
    - name: cd /var/www/; git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform; cd wsuwp-platform; git submodule init
    - unless: cd /var/www/wsuwp-platform
    - require:
      - pkg: git

wsuwp-dev-update:
  cmd.run:
    - name: cd /var/www/wsuwp-platform; git pull origin master; git submodule update
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
