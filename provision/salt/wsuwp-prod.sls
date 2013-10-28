wsuwp-prod:
  cmd.run:
    - name: cd /var/www/; curl -LOk https://github.com/washingtonstateuniversity/WSUWP-Platform/archive/master.zip; unzip master.zip; mv WSUWP-Platform-master wsuwp-platform; rm /var/www/master.zip
    - unless: -d /var/www/wsuwp-platform
