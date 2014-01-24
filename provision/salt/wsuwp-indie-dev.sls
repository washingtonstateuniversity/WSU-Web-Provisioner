# wsuwp-dev.sls
#
# Setup the WSUWP Indie environment for local development in Vagrant.
######################################################################

# Install wp-cli to provide a way to manage WordPress at the command line.
wp-cli:
  cmd.run:
    - name: curl -L https://github.com/wp-cli/wp-cli/releases/download/v0.13.0/wp-cli.phar > wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp
    - unless: which wp
    - require:
      - pkg: php-fpm

wsuwp-indie-db:
  mysql_user.present:
    - name: wp
    - password: wp
    - host: localhost
    - require:
      - sls: dbserver
      - service: mysqld
      - pkg: mysql

{% for project, project_args in pillar.get('wp-single-projects',{}).items() %}
wsuwp-indie-db-{{ project }}:
  mysql_database.present:
    - name: {{ project_args['database'] }}
    - require:
      - sls: dbserver
      - service: mysqld
      - pkg: mysql
  mysql_grants.present:
    - grant: select, insert, update, delete
    - database: {{ project_args['database'] }}.*
    - user: wp
    - require:
      - sls: dbserver
      - service: mysqld
      - pkg: mysql

wsuwp-indie-nginx-{{ project }}:
  cmd.run:
    - name: cp /var/www/{{ project_args['name'] }}/wsuwp-single-nginx.conf /etc/nginx/sites-enabled/{{ project_args['name'] }}.conf
    - require:
      - sls: webserver
{% endfor %}

wsuwp-indie-flush:
  cmd.run:
    - name: sudo service memcached restart && sudo service nginx restart && sudo service php-fpm restart
    - require:
      - sls: cacheserver
      - sls: webserver
