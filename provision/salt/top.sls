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
  'wsuwp-indie*':
    - webserver
    - cacheserver
    - dbserver
    - wordpress
  'wsuwp':
    - webserver
    - cacheserver
    - dbserver
    - wsuwp
  'wsuwp-prod*':
    - webserver
    - cacheserver
    - dbserver
    - wsuwp
  'wsusearch*':
    - search
  'wsu-lists*':
    - webserver
    - dbserver
    - phplist