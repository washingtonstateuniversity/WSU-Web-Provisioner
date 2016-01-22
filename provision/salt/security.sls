policycoreutils-python:
  pkg.latest:
    - name: policycoreutils-python

iptables:
  pkg.installed:
    - name: iptables
  service.running:
    - watch:
      - file: /etc/sysconfig/iptables

/etc/sysconfig/iptables:
  file.managed:
    - source: salt://config/iptables/iptables
    - user: root
    - group: root
    - mode: 600

# Fail2ban scans log files for IPs showing signs of malicious
# behavior and bans them from further access.
fail2ban:
  pkg.latest:
    - name: fail2ban

# When an IP is banned by Fail2ban, it is put in "jail". The jailing
# of an IP can be configured with files in this directory.
/etc/fail2ban/jail.d/:
  file.directory:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
    - require_in:
      - file: /etc/fail2ban/jail.d/wordpress.conf

# We manage a jail configuration specific to handling failed WordPress
# authentication attempts.
/etc/fail2ban/jail.d/wordpress.conf:
  file.managed:
    - source: salt://config/fail2ban/jail.wordpress.conf

# To determine which IPs should be bailed, Fail2ban runs logs through
# filters. The filtering of a log file can be configured with files
# in this directory.
/etc/fail2ban/filter.d/:
  file.directory:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
    - require_in:
      - file: /etc/fail2ban/filter.d/wordpress.conf

# We manage a filter configuration specific to handling logs created by
# authentication in WordPRess.
/etc/fail2ban/filter.d/wordpress.conf:
  file.managed:
    - source: salt://config/fail2ban/filter.wordpress.conf

# A jail.local file is used for custom configuration to extend the default
# jail.conf file, which may be overwritten by an update to fail2ban.
/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://config/fail2ban/jail.local

# Use fail2ban-client to start fail2ban-server as a proper user.
fail2ban-init:
  cmd.run:
    - name: fail2ban-client start
    - cwd: /
    - unless: fail2ban-client status | grep "Status"
    - require:
      - pkg: fail2ban

# Configure Nginx with a jinja template.
/etc/ssh/notify.sh:
  file.managed:
    - template: jinja
    - source:   salt://config/notify.sh.jinja
    - user:     root
    - group:    root
    - mode:     666