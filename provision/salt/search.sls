# Manage a custom compile script for the Java SDK
/root/java-compile.sh:
  file.managed:
    - source: salt://config/java/compile-java.sh
    - user: root
    - group: root
    - mode: 755

# Compile and install the Java SDK.
java-sdk:
  cmd.run:
    - name: sh java-compile.sh
    - cwd: /root/
    - unless: java -version 2>&1 | grep "1.8.0_101"
    - require:
      - file: /root/java-compile.sh

# Install the Elasticsearch package and make it run.
elasticsearch:
  pkg.latest:
    - pkgs:
      - elasticsearch
    - require:
      - cmd: java-sdk
  service.running:
    - require:
      - pkg: elasticsearch
    - watch:
      - file: /etc/elasticsearch/elasticsearch.yml

# Elasticsearch should always be on.
elasticsearch-init:
  cmd.run:
    - name: chkconfig --level 2345 elasticsearch on
    - cwd: /
    - require:
      - pkg: elasticsearch

# Provide a config file for Elasticsearch.
/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source:   salt://config/elasticsearch/elasticsearch.yml
    - user:     root
    - group:    root
    - mode:     644
    - require:
      - pkg: elasticsearch
