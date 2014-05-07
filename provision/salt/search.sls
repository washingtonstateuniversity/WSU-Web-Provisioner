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

# Provide the search server directory
/var/search:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require_in:
      - cmd: elasticsearch-download

# Download and prep Elasticsearch
elasticsearch-download:
  cmd.run:
    - name: curl -L -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.tar.gz && tar -xvf elasticsearch-1.1.1.tar.gz
    - cwd: /var/search/
    - require:
      - cmd: java-sdk

# Start Elasticsearch
elasticsearch-init:
  cmd.run:
    - name: ./elasticsearch -d
    - cwd: /var/search/elasticsearch-1.1.1/bin/
    - require:
      - cmd: elasticsearch-download
