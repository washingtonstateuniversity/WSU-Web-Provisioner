# top.sls
#
# The current '*' state is intended to run for every server that
# uses WSU Web Provisioner for provisioning. This includes general
# server, security, web, cache, and database. Over time these may
# be split further as the roles may separate between projects.
base:
  '*':
    - server
    - security
    - webserver
  'wsuwp-indie*':
    - application-php
    - cacheserver
    - dbserver
    - wordpress
  'wsuwp-dev*':
    - application-php
    - cacheserver
    - dbserver
    - wsuwp
  'wsuwp-prod*':
    - application-php
    - cacheserver
    - dbserver
    - wsuwp
  'uc-proxy*':
    - application-php
    - cacheserver
    - dbserver
    - wsuwp
  'wsusearch*':
    - search
    - dbserver
  'wsu-lists*':
    - application-php
    - dbserver
    - phplist
# Below servers only run base state files.
#  'uc-proxy*':
