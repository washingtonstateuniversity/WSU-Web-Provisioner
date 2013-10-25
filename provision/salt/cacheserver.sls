memcached:
  pkg.installed:
    - name: memcached
  service.running:
    - require:
      - pkg: memcached
