# wsuwp-dev.sls
#
# Setup the WSUWP Platform for local development in Vagrant.
############################################################

# Install wp-cli to provide a way to manage WordPress at the command line.
wp-cli:
  cmd.run:
    - name: curl https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | bash
    - unless: which wp
    - user: vagrant
    - require:
      - pkg: php-fpm
      - pkg: git
  file.symlink:
    - name: /usr/bin/wp
    - target: /home/vagrant/.wp-cli/bin/wp

# If the WSUWP Platform project is not yet available in the virtual machine,
# clone the repository from GitHub and initialize the submodules so that WordPress
# is available to us.
wsuwp-dev-initial:
  cmd.run:
    - name: cd /var/www/; git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform; cd wsuwp-platform; git submodule init; git submodule update
    - unless: cd /var/www/wsuwp-platform
    - require:
      - pkg: git

# Setup the MySQL requirements for WSUWP Platform
#
# user: wp
# pass: wp
# db:   wsuwp
wsuwp-db:
  mysql_user.present:
    - name: wp
    - password: wp
    - host: localhost
    - require_in:
      - cmd: wsuwp-install-network
    - require:
      - service: mysqld
      - pkg: mysql
  mysql_database.present:
    - name: wsuwp
    - require_in:
      - cmd: wsuwp-install-network
    - require:
      - service: mysqld
      - pkg: mysql
  mysql_grants.present:
    - grant: all privileges
    - database: wsuwp.*
    - user: wp
    - require_in:
      - cmd: wsuwp-install-network
    - require:
      - service: mysqld
      - pkg: mysql

# Install WordPress
wsuwp-install-network:
  cmd.run:
    - name: wp core multisite-install --path=wordpress/ --url=wp.wsu.edu --subdomains --title="WSUWP Platform" --admin_user=admin --admin_password=password --admin_email=admin@wp.wsu.edu
    - cwd: /var/www/wsuwp-platform/

# After the operations in /var/www/ are complete, the mapped directory needs to be
# unmounted and then mounted again with www-data:www-data ownership.
wsuwp-www-umount-initial:
  cmd.run:
    - name: sudo umount /var/www/
    - require:
      - sls: webserver
      - cmd: wsuwp-dev-initial
    - require_in:
      - cmd: wsuwp-www-mount-initial

wsuwp-www-mount-initial:
  cmd.run:
    - name: sudo mount -t vboxsf -o dmode=775,fmode=664,uid=`id -u www-data`,gid=`id -g www-data` /var/www/ /var/www/

wsuwp-flush-cache:
  cmd.run:
    - name: sudo service memcached restart
    - require:
      - sls: cacheserver
