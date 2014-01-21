# wsuwp-dev.sls
#
# Setup the WSUWP Indie environment for local development in Vagrant.
######################################################################

# Install wp-cli to provide a way to manage WordPress at the command line.
#wp-cli:
#  cmd.run:
#    - name: curl https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | bash
#    - unless: which wp
#    - user: vagrant
#    - require:
#      - pkg: php-fpm
#      - pkg: git
#  file.symlink:
#    - name: /usr/bin/wp
#    - target: /home/vagrant/.wp-cli/bin/wp

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
    - grant: all privileges
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
