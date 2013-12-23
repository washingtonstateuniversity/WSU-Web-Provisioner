php-pecl-xdebug:
  pkg.installed:
    - pkgs:
      - php-pecl-xdebug
    - require:
      - pkg: php-fpm
