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

site-dir-setup-{{ site_args['name'] }}:
  cmd.run:
    - name: mkdir -p /var/www/{{ site_args['name'] }}
    - require:
      - pkg: nginx

{% if pillar['network']['location'] == 'remote' %}
wp-set-site-permissions-{{ site_args['name'] }}:
  cmd.run:
    - name: chown -R www-data:www-data /var/www/{{ site_args['name'] }}
    - require:
      - cmd: site-dir-setup-{{ site_args['name'] }}
{% endif %}

/etc/nginx/sites-enabled/{{ site_args['name'] }}.conf:
  file.managed:
    - template: jinja
    - source:   salt://config/nginx/wsuwp-indie-site.conf.jinja
    - user:     root
    - group:    root
    - mode:     644
    - require:
      - pkg:    nginx
      - cmd:    site-dir-setup-{{ site_args['name'] }}
    - context:
      site_data: {{ site_args['nginx'] }}

wp-dir-setup-{{ site_args['name'] }}:
  cmd.run:
    - name: mkdir -p wordpress && mkdir -p wp-content/plugins && mkdir -p wp-content/themes && mkdir -p wp-content/mu-plugins && mkdir -p wp-content/uploads
    - cwd: /var/www/{{ site_args['name'] }}
    - user: www-data
    - require:
      - pkg: nginx
      - cmd: site-dir-setup-{{ site_args['name'] }}

wp-initial-wordpress-{{ site_args['name'] }}:
  cmd.run:
    - name: cp /tmp/wordpress.zip ./wordpress.zip && chown www-data:www-data wordpress.zip && unzip wordpress.zip && rm wordpress.zip
    - cwd: /var/www/{{ site_args['name'] }}/
    - unless: test -f wordpress/index.php
    - user: root
    - require:
      - cmd: wp-initial-download
      - cmd: wp-dir-setup-{{ site_args['name'] }}

{% if site_args['db_user'] %}
/var/www/{{ site_args['name'] }}/wp-config.php:
  file.managed:
    - template: jinja
    - source:   salt://config/wordpress/wp-config.php.jinja
    - user:     www-data
    - group:    www-data
    - require:
      - pkg: nginx
      - cmd: site-dir-setup-{{ site_args['name'] }}
    - context:
      site_data: {{ site_args }}
{% endif %}

{% if pillar['network']['location'] == 'remote' %}
wp-set-permissions-{{ site_args['name'] }}:
  cmd.run:
    - name: chown -R www-data:www-data /var/www/{{ site_args['name'] }}
    - require:
      - cmd: site-dir-setup-{{ site_args['name'] }}
      - cmd: wp-initial-wordpress-{{site_args['name'] }}
      - cmd: wp-dir-setup-{{ site_args['name'] }}
{% endif %}
{% endfor %}