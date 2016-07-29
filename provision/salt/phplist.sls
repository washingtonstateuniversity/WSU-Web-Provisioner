# phplist.sls
############################################################

# Setup the MySQL requirements for WSU Lists by pulling from
# pillar data located in network.sls.
wsuwp-db:
  mysql_user.present:
    - name: {{ pillar['wsu-lists-config']['db_user'] }}
    - password: {{ pillar['wsu-lists-config']['db_pass'] }}
    - host: {{ pillar['wsu-lists-config']['db_host'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_database.present:
    - name: {{ pillar['wsu-lists-config']['database'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_grants.present:
    - grant: select, insert, update, delete, create, alter, drop
    - database: {{ pillar['wsu-lists-config']['database'] }}.*
    - user: {{ pillar['wsu-lists-config']['db_user'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver

# Setup a config.php file for phplists and temporarily store it
# in /tmp/
/tmp/wsu-lists-config.php:
  file.managed:
    - template: jinja
    - source:   salt://config/phplist/config.php.jinja
    - user:     www-data
    - group:    www-data
    - mode:     644
    - require:
      - cmd: nginx
      - user: www-data
      - group: www-data
    - require_in:
      - cmd: wsu-lists-copy-config

# Copy over the stored wp-config.php to the site's root path. This
# allows us to avoid some permissions issues in a local environment.
wsu-lists-copy-config:
  cmd.run:
    - name: cp /tmp/wsu-lists-config.php {{ pillar['wsu-lists-config']['web_dir'] }}config/config-custom.php && rm /tmp/wsu-lists-config.php

{% if 'local' == salt['pillar.get']('network:location', 'local') %}
# Use the included Nginx config if this is a local development environment.
# In production, we manage the nginx configuration manually.
wsu-lists-nginx-conf:
  cmd.run:
    - name: cp /srv/pillar/config/nginx/{{ pillar['wsu-lists-config']['server_name'] }}.conf /etc/nginx/sites-enabled/01_primary_server.conf
    - require:
      - cmd: nginx
{% endif %}

# Flush the web services to ensure object and opcode cache are clear and that nginx configs are processed.
wsu-lists-flush:
  cmd.run:
    - name: sudo service nginx restart && sudo service php-fpm restart
