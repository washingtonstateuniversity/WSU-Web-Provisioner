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

{% for site, site_args in pillar.get('wsuwp-indie-sites',{}).items() %}
wsuwp-indie-nginx-{{ site }}:
  cmd.run:
    - name: cp /var/www/{{ site_args['name'] }}/wsuwp-single-nginx.conf /etc/nginx/sites-enabled/{{ site_args['name'] }}.conf
    - require:
      - sls: webserver
{% endfor %}

wsuwp-indie-flush:
  cmd.run:
    - name: sudo service memcached restart && sudo service nginx restart && sudo service php-fpm restart
    - require:
      - sls: cacheserver
      - sls: webserver
