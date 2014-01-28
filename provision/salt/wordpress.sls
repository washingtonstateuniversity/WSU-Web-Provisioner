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

/var/www/{{ site_args['name'] }}:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 644
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/var/www/{{ site_args['name'] }}/wp-content:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 644
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/var/www/{{ site_args['name'] }}/wp-content/plugins:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 644
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/var/www/{{ site_args['name'] }}/wp-content/mu-plugins:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 644
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/var/www/{{ site_args['name'] }}/wp-content/themes:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 644
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/var/www/{{ site_args['name'] }}/wp-content/uploads:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 644
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/var/www/{{ site_args['name'] }}/wordpress:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 444
    - dir_mode: 555
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
{% endfor %}