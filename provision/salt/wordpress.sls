# wordpress.sls
#
# States related to setting up WordPress environments for one or multiple
# projects. This state file relies heavily on pillar data from sites.sls,
# though has some allowance with default database settings.

# Download an initial installation of WordPress to be available to any
# new sites that we configure.
wp-initial-download:
  cmd.run:
    - name: curl -o wordpress.zip -L http://wordpress.org/wordpress-3.8.1.zip
    - cwd: /tmp/
    - user: root
    - unless: test -f /tmp/wordpress.zip
    - require:
      - cmd: nginx

# Loop through all of the sites defined in the local sites.sls pillar data
# and configure MySQL, our directory structure, and Nginx for each.
{% for site, site_args in pillar.get('wsuwp-indie-sites',{}).items() %}

{% if site_args['database'] is defined %}
# Set defaults for database information so that it doesn't need to be set
# in a local environment's sites.sls
{% if site_args['db_user'] is defined %}
{% else %}
{% do site_args.update({'db_user':'wp'}) %}
{% endif %}

{% if site_args['db_pass'] is defined %}
{% else %}
{% do site_args.update({'db_pass':'wp'}) %}
{% endif %}

{% if site_args['db_host'] is defined %}
{% else %}
{% do site_args.update({'db_host':'127.0.0.1'}) %}
{% endif %}

{% if site_args['nginx']['config'] is defined %}
{% else %}
{% do site_args['nginx'].update({'config':'auto'}) %}
{% endif %}

{% if site_args['wordpress'] is defined %}
{% else %}
{% do site_args.update({'wordpress':'enabled'}) %}
{% endif %}

# Setup the MySQL users, databases, and privileges required for
# each site.
wsuwp-indie-db-{{ site }}:
  mysql_user.present:
    - name: {{ site_args['db_user'] }}
    - password: {{ site_args['db_pass'] }}
    - host: {{ site_args['db_host'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_database.present:
    - name: {{ site_args['database'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_grants.present:
    - grant: select, insert, create, update, delete, alter, drop
    - database: {{ site_args['database'] }}.*
    - user: {{ site_args['db_user'] }}
    - host: {{ site_args['db_host'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
# End of check for database setting
{% endif %}

# Make sure the root path exists for Nginx to point to.
site-dir-setup-{{ site_args['directory'] }}:
  cmd.run:
    - name: mkdir -p /var/www/{{ site_args['directory'] }}
    - require:
      - cmd: nginx
    - require_in:
      - cmd: wsuwp-indie-flush

/etc/nginx/sites-enabled/{{ site_args['directory'] }}.conf:
  cmd.run:
    {% if pillar['network']['location'] == 'local' %}
    - name: cp /var/www/{{ site_args['directory'] }}/config/dev.{{ site_args['directory'] }}.conf /etc/nginx/sites-enabled/{{ site_args['directory'] }}.conf
    {% else %}
    - name: cp /var/www/{{ site_args['directory'] }}/config/{{ site_args['directory'] }}.conf /etc/nginx/sites-enabled/{{ site_args['directory'] }}.conf
    {% endif %}
    - require:
      - cmd: nginx
      - cmd: site-dir-setup-{{ site_args['directory'] }}

{% if site_args['wordpress'] == 'disabled' %}
{% else %}
# Setup the directories required for a WordPress project inside the
# site's root path.
wp-dir-setup-{{ site_args['directory'] }}:
  cmd.run:
    - name: mkdir -p wordpress && mkdir -p wp-content/plugins && mkdir -p wp-content/themes && mkdir -p wp-content/mu-plugins && mkdir -p wp-content/uploads
    - cwd: /var/www/{{ site_args['directory'] }}
    - user: root
    - require:
      - cmd: nginx
      - cmd: site-dir-setup-{{ site_args['directory'] }}
    - require_in:
      - cmd: wsuwp-indie-flush

# If WordPress has not yet been setup, copy over the initial stable zip
# and extract accordingly.
wp-initial-wordpress-{{ site_args['directory'] }}:
  cmd.run:
    - name: cp /tmp/wordpress.zip ./wordpress.zip && chown www-data:www-data wordpress.zip && unzip wordpress.zip && rm wordpress.zip
    - cwd: /var/www/{{ site_args['directory'] }}/
    - unless: test -f wordpress/index.php
    - user: root
    - require:
      - cmd: wp-initial-download
      - cmd: wp-dir-setup-{{ site_args['directory'] }}
    - require_in:
      - cmd: wsuwp-indie-flush

# Setup a wp-config.php file for the site and temporarily store it
# in /var/wsuwp-config with other configs.
/var/wsuwp-config/{{ site_args['directory'] }}-wp-config.php:
  file.managed:
    - template: jinja
    - source:   salt://config/wordpress/wp-config.php.jinja
    - user:     www-data
    - group:    www-data
    - mode:     644
    - require:
      - cmd: nginx
      - cmd: site-dir-setup-{{ site_args['directory'] }}
    - require_in:
      - cmd: wp-copy-config-{{ site_args['directory'] }}
    - context:
      site_data: {{ site_args }}

# Copy over the stored wp-config.php to the site's root path. This
# allows us to avoid some permissions issues in a local environment.
wp-copy-config-{{ site_args['directory'] }}:
  cmd.run:
    - name: cp /var/wsuwp-config/{{ site_args['directory'] }}-wp-config.php /var/www/{{ site_args['directory'] }}/wp-config.php
{% endif %}

# If we're in a remote environment, change all files in each site
# root to be owned by the www-data user.
{% if pillar['network']['location'] == 'remote' %}
wp-set-permissions-{{ site_args['directory'] }}:
  cmd.run:
    - name: chown -R www-data:www-data /var/www/{{ site_args['directory'] }} && chmod -R g+w /var/www/{{ site_args['directory'] }}
    - require:
      - cmd: site-dir-setup-{{ site_args['directory'] }}
{% endif %}
{% endfor %}

# Install wp-cli to provide a way to manage WordPress at the command line.
wp-cli:
  cmd.run:
    - name: curl -L https://github.com/wp-cli/wp-cli/releases/download/v0.14.1/wp-cli-0.14.1.phar > wp-cli.phar && mv wp-cli.phar /usr/bin/wp && chmod +x /usr/bin/wp
    - cwd: /home/vagrant/
    - unless: wp --allow-root --version | grep "0.14.1"
    - require:
      - pkg: php-fpm

# Flush the web services to ensure object and opcode cache are clear.
wsuwp-indie-flush:
  cmd.run:
    - name: sudo service memcached restart && sudo service nginx restart && sudo service php-fpm restart
    - require:
      - sls: cacheserver
      - sls: webserver

