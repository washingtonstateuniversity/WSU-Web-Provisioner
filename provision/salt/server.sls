webtatic-repo:
  pkgrepo.managed:
    - humanname: Webtatic Repo
    - baseurl: http://repo.webtatic.com/yum/el6/x86_64/
    - gpgcheck: 0
    - require_in:
      - pkg: mysql55-server