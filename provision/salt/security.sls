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

fail2ban:
  pkg.latest:
    - name: fail2ban
  service.running:
    - watch:
      - file: /etc/fail2ban/filter.d/wordpress.conf

/etc/fail2ban/jail.d/:
  file.directory:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
    - require_in:
      - file: /etc/fail2ban/jail.d/wordpress.conf

/etc/fail2ban/filter.d/:
  file.directory:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
    - require_in:
      - file: /etc/fail2ban/filter.d/wordpress.conf

/etc/fail2ban/filter.d/wordpress.conf:
  file.managed:
    - source: salt://config/fail2ban/wordpress.conf

/etc/fail2ban/jail.d/wordpress.conf:
  file.managed:
    - source: salt://config/fail2ban/jail.wordpress.conf