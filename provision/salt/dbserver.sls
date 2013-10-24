mysql-server:
  pkg.installed

mysql:
  service.running:
    - name: mysql
    - require:
      - pkg: mysql-server