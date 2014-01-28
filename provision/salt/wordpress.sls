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
  mysql_database.present:
    - name: {{ site_args['database'] }}
    - require:
      - service: mysqld
      - pkg: mysql
  mysql_grants.present:
    - grant: select, insert, create, update, delete
    - database: {{ site_args['database'] }}.*
    - user: {{ site_args['db_user'] }}
    - require:
      - service: mysqld
      - pkg: mysql
{% endif %}
{% endfor %}

{% for site, site_args in pillar.get('wsuwp-indie-sites',{}).items() %}

/etc/nginx/sites-enabled/{{ site_args['name'] }}.conf:
  file.managed:
    - template: jinja
    - source:   salt://config/nginx/wsuwp-indie-site.conf.jinja
    - user:     root
    - group:    root
    - mode:     644
    - require:
      - pkg:    nginx
    - context:
      site_data: {{ site_args['nginx'] }}

wp-dir-setup-{{ site_args['name'] }}:
  cmd.run:
    - name: mkdir -p wordpress && mkdir -p wp-content && mkdir -p wp-content/plugins && mkdir -p wp-content/themes && mkdir -p wp-content/mu-plugins && mkdir -p wp-content/uploads
    - cwd: /var/www/{{ site_args['name'] }}
    - user: www-data
    - require:
      - pkg: nginx

wp-initial-zip-{{ site_args['name'] }}:
  cmd.run:
    - name: curl -o wordpress.zip -L http://wordpress.org/wordpress-3.8.1.zip && unzip wordpress.zip && rm wordpress.zip
    - cwd: /var/www/{{ site_args['name'] }}/
    - unless: test -f wordpress/index.php
    - user: www-data
    - group: www-data

{% endfor %}