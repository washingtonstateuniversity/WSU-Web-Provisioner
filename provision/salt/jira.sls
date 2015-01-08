# Setup the MySQL requirements for JIRA by pulling from pillar data
# in network.sls
jira-db:
  mysql_user.present:
    - name: {{ pillar['jira-config']['db_user'] }}
    - password: {{ pillar['jira-config']['db_pass'] }}
    - host: {{ pillar['jira-config']['db_host'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_database.present:
    - name: {{ pillar['jira-config']['database'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver
  mysql_grants.present:
    - grant: select, insert, update, delete, create, alter, drop
    - database: {{ pillar['jira-config']['database'] }}.*
    - user: {{ pillar['jira-config']['db_user'] }}
    - host: {{ pillar['jira-config']['db_host'] }}
    - require:
      - service: mysqld
      - pkg: mysql
      - sls: dbserver