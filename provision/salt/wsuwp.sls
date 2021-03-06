# wsuwp-dev.sls
#
# Setup the WSUWP Platform for local development in Vagrant.
############################################################

# Install wp-cli to provide a way to manage WordPress at the command line.
wp-cli:
  cmd.run:
    - name: curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > wp-cli.phar > wp-cli.phar && mv wp-cli.phar /usr/bin/wp && chmod +x /usr/bin/wp
    - cwd: /tmp
    - unless: wp --allow-root --version | grep "WP-CLI "
    - require:
      - pkg: php-fpm

# Always update to the latest nightly version of WP-CLI
wp-cli-update:
  cmd.run:
    - name: wp --allow-root cli update --nightly --yes
    - cwd: /tmp
    - require:
      - cmd: wp-cli

# Setup the MySQL requirements for WSUWP Platform by pulling from
# pillar data located in network.sls.
wsuwp-db:
  mysql_user.present:
    - name: {{ pillar['wsuwp-config']['db_user'] }}
    - password: {{ pillar['wsuwp-config']['db_pass'] }}
    - host: {{ pillar['wsuwp-config']['db_host'] }}
    - require_in:
      - cmd: wsuwp-install-network
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_database.present:
    - name: {{ pillar['wsuwp-config']['database'] }}
    - require_in:
      - cmd: wsuwp-install-network
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_grants.present:
    - grant: ALL
    - database: {{ pillar['wsuwp-config']['database'] }}.*
    - user: {{ pillar['wsuwp-config']['db_user'] }}
    - host: {{ pillar['wsuwp-config']['db_host'] }}
    - require_in:
      - cmd: wsuwp-install-network
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver

# As object cache will be available to WordPress throughout provisioning at the plugin
# level, stop memcached before applying any related commands to avoid possible cache
# and database pollution or crossing.
wsuwp-prep-install:
  cmd.run:
    - name: service memcached stop
    - cwd: /
    - require:
      - service: memcached
    - require_in:
      - cmd: wsuwp-install-network

# Setup a wp-config.php file for the site and temporarily store it
# in /tmp/
/tmp/wsuwp-temp-wp-config.php:
  file.managed:
    - template: jinja
    - source:   salt://config/wordpress/wsuwp-temp-wp-config.php.jinja
    - user:     www-data
    - group:    www-data
    - mode:     644
    - unless: test -f /var/www/wp-config.php
    - require:
      - user: www-data
      - group: www-data

# Copy over a temporary wp-config.php to use during installation of WordPress.
wsuwp-copy-temp:
  cmd.run:
    - name: cp /tmp/wsuwp-temp-wp-config.php /var/www/wp-config.php && rm /tmp/wsuwp-temp-wp-config.php
    - unless: test -f /var/www/wp-config.php
    - require:
      - /tmp/wsuwp-temp-wp-config.php

# Install our primary WordPress network with a default admin and password for the
# development environment.
wsuwp-install-network:
  cmd.run:
    - name: wp --allow-root core multisite-install --path=wordpress/ --url={{ pillar['wsuwp-config']['primary_host'] }} --title="WSUWP Platform" --admin_user={{ pillar['wsuwp-config']['primary_user'] }} --admin_password={{ pillar['wsuwp-config']['primary_pass'] }} --admin_email={{ pillar['wsuwp-config']['primary_email'] }}
    - cwd: /var/www/
    - require:
      - cmd: wp-cli
      - service: mysqld
      - service: php-fpm
      - wsuwp-copy-temp

# Setup a wp-config.php file for the site and temporarily store it
# in /tmp/
/tmp/wsuwp-wp-config.php:
  file.managed:
    - template: jinja
    - source:   salt://config/wordpress/wsuwp-wp-config.php.jinja
    - user:     www-data
    - group:    www-data
    - mode:     644

# Manage a script to checkout the Spine.
/root/clone-spine.sh:
  file.managed:
    - source: salt://config/wordpress/clone-spine.sh
    - user: root
    - group: root
    - mode: 755

# Ensure Spine parent theme is available
spine:
  cmd.run:
    - name: sh clone-spine.sh
    - cwd: /root/
    - unless: test -d /var/www/wp-content/themes/spine
    - require:
      - file: /root/clone-spine.sh
      - cmd: wsuwp-install-network
      - user: www-data
      - group: www-data

{% if 'local' == salt['pillar.get']('network:location', 'local') %}
# Ensure Spine local development is available
/root/clone-spine-local.sh:
  file.managed:
    - source: salt://config/wordpress/clone-spine-local.sh
    - user: root
    - group: root
    - mode: 755

spine-local-dev:
  cmd.run:
    - name: sh clone-spine-local.sh
    - cwd: /root/
    - unless: test -d /var/www/wsu-spine
    - require:
      - file: /root/clone-spine-local.sh
      - user: www-data
      - group: www-data
    - require_in:
      - cmd: wsuwp-nginx-conf
{% endif %}

# Copy over the stored wp-config.php to the site's root path. This
# allows us to avoid some permissions issues in a local environment.
wsuwp-copy-config:
  cmd.run:
    - name: cp /tmp/wsuwp-wp-config.php /var/www/wp-config.php && rm /tmp/wsuwp-wp-config.php
    - require:
      - /tmp/wsuwp-wp-config.php
      - wsuwp-install-network

# Enable the parent theme on all network sites.
enable-wsu-spine-theme:
  cmd.run:
    - name: wp --allow-root theme enable spine --network --activate
    - cwd: /var/www/wordpress/
    - onlyif: cd /var/www/wp-content/themes/spine
    - require:
      - cmd: wsuwp-copy-config

# Activate the spine parent theme on the primary site if a theme is not active.
activate-wsu-spine-theme:
  cmd.run:
    - name: wp --allow-root theme activate spine --url={{ pillar['wsuwp-config']['primary_host'] }}
    - unless: wp --allow-root theme status --url={{ pillar['wsuwp-config']['primary_host'] }} | grep " A "
    - cwd: /var/www/wordpress/
    - require:
      - cmd: enable-wsu-spine-theme

# Add a common header for nginx to be used in all generated nginx
# configurations that load common HTTPS directives. This header
# allows us to change the listen and root directives for many sites
# at a time.
/etc/nginx/wsuwp-common-header.conf:
  file.managed:
    - source: salt://config/nginx/wsuwp-common-header.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: nginx
    - require_in:
      - service: nginx-service

# Add a common cache configuration for nginx to be used in specific
# cases. In the future this may be a common configuration for use as
# a microcache that avoids firing up PHP processes.
/etc/nginx/wsuwp-common-cache-server.conf:
  file.managed:
    - source: salt://config/nginx/wsuwp-common-cache-server.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: nginx
    - require_in:
      - service: nginx-service

/etc/nginx/sites-enabled/default-wsuwp:
  file.managed:
    - source: salt://config/nginx/default-wsuwp
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: nginx
    - require_in:
      - service: nginx-service

# Configure Nginx with a jinja template.
wsuwp-nginx-conf:
  cmd.run:
    - name: cp /srv/pillar/config/nginx/{{ pillar['wsuwp-config']['primary_host'] }}.conf /etc/nginx/sites-enabled/05_wp.wsu.edu.conf
    - require:
      - cmd: nginx
      - cmd: wsuwp-install-network
    - require_in:
      - service: nginx-service

# Flush the web services to ensure object and opcode cache are clear and that nginx configs are processed.
wsuwp-indie-flush:
  cmd.run:
    - name: sudo service memcached start && sudo service nginx restart && sudo service php-fpm restart && fail2ban-client reload
    - require:
      - cmd: wsuwp-nginx-conf
