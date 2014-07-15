group-memcached:
  group.present:
    - name: memcached

user-memcached:
  user.present:
    - name: memcached
    - groups:
      - memcached
    - require:
      - group: memcached
    - require_in:
      - pkg: memcached

memcached:
  pkg.latest:
    - name: memcached
    - require:
      - pkgrepo: remi-repo
  service.running:
    - require:
      - pkg: memcached
      - user: memcached

# Set memcached to run in levels 2345.
memcached-init:
  cmd.run:
    - name: chkconfig --level 2345 memcached on
    - cwd: /
    - require:
      - pkg: memcached
