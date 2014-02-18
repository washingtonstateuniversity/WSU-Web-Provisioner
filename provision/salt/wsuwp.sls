# wsuwp-dev.sls
#
# Setup the WSUWP Platform for local development in Vagrant.
############################################################

# Install wp-cli to provide a way to manage WordPress at the command line.
wp-cli:
  cmd.run:
    - name: curl -L https://github.com/wp-cli/wp-cli/releases/download/v0.14.0/wp-cli-0.14.0.phar > wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp
    - cwd: /home/vagrant/
    - unless: which wp
    - require:
      - pkg: php-fpm

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
    - grant: select, insert, update, delete, create
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

# Copy over a temporary wp-config.php to use during installation of WordPress.
wsuwp-copy-temp:
  cmd.run:
    - name: cp /var/www/temp-config.php /var/www/wp-config.php
    - unless: test -f /var/www/wp-config.php
    - require_in: wsuwp-install-network

# Install our primary WordPress network with a default admin and password for the
# development environment.
wsuwp-install-network:
  cmd.run:
    - name: wp core multisite-install --path=wordpress/ --url=wp.wsu.edu --subdomains --title="WSUWP Platform" --admin_user=admin --admin_password=password --admin_email=admin@wp.wsu.edu
    - cwd: /var/www/
    - require:
      - cmd: wp-cli

# Setup a wp-config.php file for the site and temporarily store it
# in /tmp/
/tmp/wsuwp-wp-config.php:
  file.managed:
    - template: jinja
    - source:   salt://config/wordpress/wsuwp-wp-config.php.jinja
    - user:     www-data
    - group:    www-data
    - mode:     644
    - require:
      - pkg: nginx
      - cmd: wsuwp-install-network
    - require_in:
      - cmd: wsuwp-copy-config

# Copy over the stored wp-config.php to the site's root path. This
# allows us to avoid some permissions issues in a local environment.
wsuwp-copy-config:
  cmd.run:
    - name: cp /tmp/wsuwp-wp-config.php /var/www/wp-config.php

# Add a default set of users to the WordPress environment via wp-cli. These can be
# configured in the users.sls pillar.
{% for user, user_arg in pillar.get('wp-users',{}).items() %}
wp-add-user-{{ user }}:
  cmd.run:
    - name: wp user get {{ user_arg['login'] }} --field=ID || wp user create {{ user_arg['login'] }} {{ user_arg['email'] }} --role={{ user_arg['role'] }} --user_pass={{ user_arg['pass'] }} --display_name="{{ user_arg['name'] }}" --porcelain
    - cwd: /var/www/wordpress/
    - require:
      - cmd: wsuwp-install-network
{% endfor %}

# Add a default set of development plugins from the WordPress.org repository via wp-cli.
# These can be configured through the plugins.sls pillar data.
{% for plugin, install_arg in pillar.get('wp-plugins',{}).items() %}
install-dev-{{ plugin }}:
  cmd.run:
    - name: wp plugin install {{ install_arg['name'] }}; wp plugin activate {{ install_arg['name'] }} --network;
    - cwd: /var/www/wordpress/
    - require:
      - cmd: wsuwp-install-network
{% endfor %}

# Add a default set of development plugins from GitHub and update them when necessary.
# These can be configured through the plugins.sls pillar data.
{% for plugin, install_arg in pillar.get('git-wp-plugins',{}).items() %}
install-dev-git-initial-{{ plugin }}:
  cmd.run:
    - name: git clone {{ install_arg['git'] }} {{ install_arg['name'] }}
    - cwd: /var/www/wp-content/plugins
    - unless: cd /var/www/wp-content/plugins/{{install_arg['name'] }}
    - require:
      - pkg: git
      - cmd: wsuwp-install-network

update-dev-git-{{ plugin }}:
  cmd.run:
    - name: git pull origin master
    - cwd: /var/www/wp-content/plugins/{{ install_arg['name'] }}
    - onlyif: cd /var/www/wp-content/plugins/{{ install_arg['name'] }}
    - require:
      - pkg: git
      - cmd: wsuwp-install-network
{% endfor %}

# Install the WSU Spine Parent theme available on GitHub.
install-wsu-spine-theme:
  cmd.run:
    - name: git clone https://github.com/washingtonstateuniversity/WSUWP-spine-parent-theme.git wsuwp-spine-parent
    - cwd: /var/www/wp-content/themes/
    - unless: cd /var/www/wp-content/themes/wsuwp-spine-parent
    - require:
      - pkg: git
      - cmd: wsuwp-install-network

# Update the WSU Spine Parent theme to the latest version.
update-wsu-spine-theme:
  cmd.run:
    - name: git pull origin master
    - cwd: /var/www/wp-content/themes/wsuwp-spine-parent/
    - onlyif: cd /var/www/wp-content/themes/wsuwp-spine-parent
    - require:
      - pkg: git
      - cmd: wsuwp-install-network

# Configure Nginx with a jinja template.
wsuwp-nginx-conf:
  cmd.run:
    {% if pillar['network']['location'] == 'local' %}
    - name: cp /srv/pillar/config/nginx/dev.wp.wsu.edu.conf /etc/nginx/sites-enabled/wp.wsu.edu.conf
    {% else %}
    - name: cp /srv/pillar/config/nginx/wp.wsu.edu.conf /etc/nginx/sites-enabled/wp.wsu.edu.conf
    {% endif %}
    - require:
      - pkg: nginx

# Flush the web services to ensure object and opcode cache are clear and that nginx configs are processed.
wsuwp-indie-flush:
  cmd.run:
    - name: sudo service memcached restart && sudo service nginx restart && sudo service php-fpm restart
    - require:
      - sls: cacheserver
      - sls: webserver
      - cmd: wsuwp-nginx-conf
