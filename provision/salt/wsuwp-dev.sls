# wsuwp-dev.sls
#
# Setup the WSUWP Platform for local development in Vagrant.
############################################################

# Install wp-cli to provide a way to manage WordPress at the command line.
wp-cli:
  cmd.run:
    - name: curl https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | bash
    - cwd: /home/vagrant/
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
    - name: git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform; cd wsuwp-platform; git submodule init; git submodule update
    - cwd: /var/www/
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

# As object cache will be available to WordPress throughout provisioning at the plugin
# level, stop memcached before applying any related commands to avoid possible cache
# and database pollution or crossing.
wsuwp-prep-install:
  cmd.run:
    - name: service memcached stop
    - cwd: /
    - require_in:
      - cmd: wsuwp-install-network

# Install our primary WordPress network with a default admin and password for the
# development environment.
wsuwp-install-network:
  cmd.run:
    - name: wp core multisite-install --path=wordpress/ --url=wp.wsu.edu --subdomains --title="WSUWP Platform" --admin_user=admin --admin_password=password --admin_email=admin@wp.wsu.edu
    - cwd: /var/www/wsuwp-platform/
    - require:
      - cmd: wp-cli
      - cmd: wsuwp-dev-initial

# Add a default set of users to the WordPress environment via wp-cli. These can be
# configured in the users.sls pillar.
{% for user, user_arg in pillar.get('wp-users',{}).items() %}
wp-add-user-{{ user }}:
  cmd.run:
    - name: wp user get {{ user_arg['login'] }} || wp user create {{ user_arg['login'] }} {{ user_arg['email'] }} --role={{ user_arg['role'] }} --user_pass={{ user_arg['pass'] }} --display_name="{{ user_arg['name'] }}"
    - cwd: /var/www/wsuwp-platform/wordpress/
    - require:
      - cmd: wsuwp-install-network
{% endfor %}

# Add a default set of development plugins from the WordPress.org repository via wp-cli.
# These can be configured through the plugins.sls pillar data.
{% for plugin, install_arg in pillar.get('wp-plugins',{}).items() %}
install-dev-{{ plugin }}:
  cmd.run:
    - name: wp plugin install {{ install_arg['name'] }}; wp plugin activate {{ install_arg['name'] }} --network;
    - cwd: /var/www/wsuwp-platform/wordpress/
    - require:
      - cmd: wsuwp-install-network
    - require_in:
      - cmd: wsuwp-www-umount-initial
{% endfor %}

# Add a default set of development plugins from GitHub and update them when necessary.
# These can be configured through the plugins.sls pillar data.
{% for plugin, install_arg in pillar.get('git-wp-plugins',{}).items() %}
install-dev-git-initial-{{ plugin }}:
  cmd.run:
    - name: git clone {{ install_arg['git'] }} {{ install_arg['name'] }}
    - cwd: /var/www/wsuwp-platform/wp-content/plugins
    - unless: cd /var/www/wsuwp-platform/wp-content/plugins/{{install_arg['name'] }}
    - require:
      - pkg: git
      - cmd: wsuwp-install-network

update-dev-git-{{ plugin }}:
  cmd.run:
    - name: git pull origin master
    - cwd: /var/www/wsuwp-platform/wp-content/plugins/{{ install_arg['name'] }}
    - onlyif: cd /var/www/wsuwp-platform/wp-content/plugins/{{ install_arg['name'] }}
    - require:
      - pkg: git
      - cmd: wsuwp-install-network
{% endfor %}

# Install the WSU Spine Parent theme available on GitHub.
install-wsu-spine-theme:
  cmd.run:
    - name: git clone https://github.com/washingtonstateuniversity/WSUWP-spine-parent-theme.git wsuwp-spine-parent
    - cwd: /var/www/wsuwp-platform/wp-content/themes/
    - unless: cd /var/www/wsuwp-platform/wp-content/themes/wsuwp-spine-parent
    - require:
      - pkg: git
      - cmd: wsuwp-install-network

# Update the WSU Spine Parent theme to the latest version.
update-wsu-spine-theme:
  cmd.run:
    - name: git pull origin master
    - cwd: /var/www/wsuwp-platform/wp-content/themes/wsuwp-spine-parent/
    - onlyif: cd /var/www/wsuwp-platform/wp-content/themes/wsuwp-spine-parent
    - require:
      - pkg: git
      - cmd: wsuwp-install-network

# After the operations in /var/www/ are complete, the mapped directory needs to be
# unmounted and then mounted again with www-data:www-data ownership.
wsuwp-www-umount-initial:
  cmd.run:
    - name: sudo umount /var/www/
    - cwd: /
    - require:
      - sls: webserver
      - cmd: wsuwp-dev-initial
    - require_in:
      - cmd: wsuwp-www-mount-initial

wsuwp-www-mount-initial:
  cmd.run:
    - name: sudo mount -t vboxsf -o dmode=775,fmode=664,uid=`id -u www-data`,gid=`id -g www-data` /var/www/ /var/www/
    - cwd: /

# Whenever provisioning runs, it doesn't hurt to flush our object cache.
wsuwp-flush-cache:
  cmd.run:
    - name: sudo service memcached restart
    - cwd: /
    - require:
      - sls: cacheserver

# Whenever provisioning runs, it doesn't hurt to restart php-fpm, flushing the opcode cache.
wsuwp-flush-php-fpm:
  cmd.run:
    - name: sudo service php-fpm restart
    - cwd: /
    - require:
      - sls: webserver

