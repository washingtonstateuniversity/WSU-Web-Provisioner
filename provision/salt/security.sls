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