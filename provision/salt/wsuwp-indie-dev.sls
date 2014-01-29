# wsuwp-dev.sls
#
# Setup the WSUWP Indie environment for local development in Vagrant.
######################################################################



wsuwp-indie-flush:
  cmd.run:
    - name: sudo service memcached restart && sudo service nginx restart && sudo service php-fpm restart
    - require:
      - sls: cacheserver
      - sls: webserver
