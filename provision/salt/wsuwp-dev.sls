# Setup the WSUWP Platform for local development in Vagrant.
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

wsuwp-dev-update:
  cmd.run:
    - name: cd /var/www/wsuwp-platform; git pull origin master; git submodule update
    - onlyif: cd /var/www/wsuwp-platform
    - require:
      - pkg: git

wsuwp-dev-initial:
  cmd.run:
    - name: cd /var/www/; git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform; cd wsuwp-platform; git submodule init; git submodule update
    - unless: cd /var/www/wsuwp-platform
    - require:
      - pkg: git

wsuwp-db:
  mysql_user.present:
    - name: wp
    - password: wp
    - host: localhost
    - require:
      - sls: dbserver
      - service: mysqld
      - pkg: mysql
    - require_in:
      - cmd: wsuwp-db-import
  mysql_database.present:
    - name: wsuwp
    - require:
      - sls: dbserver
      - service: mysqld
      - pkg: mysql
    - require_in:
      - cmd: wsuwp-db-import
  mysql_grants.present:
    - grant: all privileges
    - database: wsuwp.*
    - user: wp
    - require:
      - sls: dbserver
      - service: mysqld
      - pkg: mysql
    - require_in:
      - cmd: wsuwp-db-import

wsuwp-db-import:
  cmd.run:
    - name: mysql -u wp -pwp wsuwp < wsuwp-03-initial-multi-network-users.sql
    - cwd: /vagrant/database
    - unless: cat /var/lib/mvysql/wsuwp/wp_options.frm
    - require:
      - sls: dbserver
      - service: mysqld

{% for plugin, install_arg in pillar.get('wp-plugins',{}).items() %}
install-dev-{{ plugin }}:
  cmd.run:
    - name: wp plugin install {{ install_arg['name'] }} --network
    - cwd: /var/www/wsuwp-platform/wordpress/
    - require:
      - cmd: wp-cli
    - require_in:
      - cmd: activate-dev-plugins
{% endfor %}

activate-dev-plugins:
  cmd.run:
    - name: wp plugin activate user-switching --network; wp plugin activate debug-bar --network
    - cwd: /var/www/wsuwp-platform/wordpress/

# After the operations in /var/www/ are complete, the mapped directory needs to be
# unmounted and then mounted again with www-data:www-data ownership.
wsuwp-www-umount-initial:
  cmd.run:
    - name: sudo umount /var/www/
    - require:
      - sls: webserver
      - cmd: wsuwp-dev-initial
      - cmd: activate-dev-plugins
    - require_in:
      - cmd: wsuwp-www-mount-initial

wsuwp-www-mount-initial:
  cmd.run:
    - name: sudo mount -t vboxsf -o dmode=775,fmode=664,uid=`id -u www-data`,gid=`id -g www-data` /var/www/ /var/www/
