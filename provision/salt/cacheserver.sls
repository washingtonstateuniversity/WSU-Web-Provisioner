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

# Set memcached to run in levels 2345.
memcached-init:
  cmd.run:
    - name: chkconfig --level 2345 memcached on
    - cwd: /
    - require:
      - pkg: memcached
