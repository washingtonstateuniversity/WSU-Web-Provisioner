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
    - name: git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform-vcs; cd wsuwp-platform-vcs; git submodule init
    - cwd: /var/local/
    - unless: cd /var/local/wsuwp-platform-vcs
    - require:
      - pkg: git

wsuwp-update:
  cmd.run:
    - name: git pull origin master; git submodule update
    - cwd: /var/local/wsuwp-platform-vcs/
    - require:
      - pkg: git

wsuwp-sync:
  cmd.run:
    - name: rsync -rvzh --delete --exclude='.git' --exclude='local-config.php' --exclude='remote-config.php' /var/local/wsuwp-platform-vcs/ /var/www/wsuwp-platform; chown -R www-data:www-data /var/www/wsuwp-platform
    - cwd: /
    - require:
      - file: /var/www/wsuwp-platform

# Need to determine how to use provide production database user/pass
wsuwp-db:
  mysql_database.present:
    - name: wsuwp
    - require:
      - service: mysql
      - pkg: mysql
