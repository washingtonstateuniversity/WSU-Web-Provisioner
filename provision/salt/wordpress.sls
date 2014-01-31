{% for site, site_args in pillar.get('wsuwp-indie-sites',{}).items() %}
{% if site_args['db_user'] %}
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
    - grant: select, insert, create, update, delete
    - database: {{ site_args['database'] }}.*
    - user: {{ site_args['db_user'] }}
    - host: {{ site_args['db_host'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
{% endif %}
{% endfor %}

wp-initial-download:
  cmd.run:
    - name: curl -o wordpress.zip -L http://wordpress.org/wordpress-3.8.1.zip
    - cwd: /tmp/
    - user: root
    - unless: test -f /tmp/wordpress.zip
    - require:
      - pkg: nginx

{% for site, site_args in pillar.get('wsuwp-indie-sites',{}).items() %}

site-dir-setup-{{ site_args['directory'] }}:
  cmd.run:
    - name: mkdir -p /var/www/{{ site_args['directory'] }}
    - require:
      - pkg: nginx

{% if pillar['network']['location'] == 'remote' %}
wp-set-site-permissions-{{ site_args['directory'] }}:
  cmd.run:
    - name: chown -R www-data:www-data /var/www/{{ site_args['directory'] }}
    - require:
      - cmd: site-dir-setup-{{ site_args['directory'] }}
{% endif %}

/etc/nginx/sites-enabled/{{ site_args['directory'] }}.conf:
  file.managed:
    - template: jinja
    - source:   salt://config/nginx/wsuwp-indie-site.conf.jinja
    - user:     root
    - group:    root
    - mode:     644
    - require:
      - pkg:    nginx
      - cmd:    site-dir-setup-{{ site_args['directory'] }}
    - context:
      site_data: {{ site_args }}

wp-dir-setup-{{ site_args['directory'] }}:
  cmd.run:
    - name: mkdir -p wordpress && mkdir -p wp-content/plugins && mkdir -p wp-content/themes && mkdir -p wp-content/mu-plugins && mkdir -p wp-content/uploads
    - cwd: /var/www/{{ site_args['directory'] }}
    - user: www-data
    - require:
      - pkg: nginx
      - cmd: site-dir-setup-{{ site_args['directory'] }}

wp-initial-wordpress-{{ site_args['directory'] }}:
  cmd.run:
    - name: cp /tmp/wordpress.zip ./wordpress.zip && chown www-data:www-data wordpress.zip && unzip wordpress.zip && rm wordpress.zip
    - cwd: /var/www/{{ site_args['directory'] }}/
    - unless: test -f wordpress/index.php
    - user: root
    - require:
      - cmd: wp-initial-download
      - cmd: wp-dir-setup-{{ site_args['directory'] }}

{% if site_args['db_user'] %}
/var/wsuwp-config/{{ site_args['directory'] }}-wp-config.php:
  file.managed:
    - template: jinja
    - source:   salt://config/wordpress/wp-config.php.jinja
    - user:     www-data
    - group:    www-data
    - mode:     644
    - require:
      - pkg: nginx
      - cmd: site-dir-setup-{{ site_args['directory'] }}
    - require_in:
      - cmd: wp-copy-config-{{ site_args['directory'] }}
    - context:
      site_data: {{ site_args }}

wp-copy-config-{{ site_args['directory'] }}:
  cmd.run:
    - name: cp /var/wsuwp-config/{{ site_args['directory'] }}-wp-config.php /var/www/{{ site_args['directory'] }}/wp-config.php
{% endif %}

{% if pillar['network']['location'] == 'remote' %}
wp-set-permissions-{{ site_args['name'] }}:
  cmd.run:
    - name: chown -R www-data:www-data /var/www/{{ site_args['directory'] }}
    - require:
      - cmd: site-dir-setup-{{ site_args['directory'] }}
      - cmd: wp-initial-wordpress-{{site_args['directory'] }}
      - cmd: wp-dir-setup-{{ site_args['directory'] }}
{% endif %}
{% endfor %}

# Install wp-cli to provide a way to manage WordPress at the command line.
wp-cli:
  cmd.run:
    - name: curl -L https://github.com/wp-cli/wp-cli/releases/download/v0.13.0/wp-cli.phar > wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp
    - cwd: /tmp
    - unless: which wp
    - require:
      - pkg: php-fpm

wsuwp-indie-flush:
  cmd.run:
    - name: sudo service memcached restart && sudo service nginx restart && sudo service php-fpm restart
    - require:
      - sls: cacheserver
      - sls: webserver

