# Manage a custom compile script for the Java SDK
/root/java-compile.sh:
  file.managed:
    - source: salt://config/java/compile-java.sh
    - user: root
    - group: root
    - mode: 755

# Compile and install Nginx.
java-sdk:
  cmd.run:
    - name: sh java-compile.sh
    - cwd: /root/
    - unless: java -version 2>&1 | grep "1.7.0_55"
    - require:
      - file: /root/java-compile.sh

# Install the Elasticsearch package and make it run.
elasticsearch:
  pkg.installed:
    - pkgs:
      - elasticsearch
    - require:
      - cmd: java-sdk
  service.running:
    - require:
      - pkg: elasticsearch

# Elasticsearch should always be on.
elasticsearch-init:
  cmd.run:
    - name: chkconfig --level 2345 elasticsearch on
    - cwd: /
    - require:
      - pkg: elasticsearch