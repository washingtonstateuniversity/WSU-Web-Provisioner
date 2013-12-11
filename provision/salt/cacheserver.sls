group-memcached:
  group.present:
    - name: memcached

user-memcached:
  user.present:
    - name: memcached
    - groups:
      - memcached
    - require_in:
      - pkg: memcached

memcached:
  pkg.installed:
    - name: memcached
  service.running:
    - require:
      - pkg: memcached
