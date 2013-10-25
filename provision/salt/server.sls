ius-repo:
  pkgrepo.managed:
    - humanname: IUS Repository
    - baseurl: http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: mysql55-server
      - pkg: php-fpm
