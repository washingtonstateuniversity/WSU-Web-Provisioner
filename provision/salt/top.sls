# top.sls
#
# The current '*' state is intended to run for every server that
# uses WSU Web Provisioner for provisioning. This includes general
# server, security, web, cache, and database. Over time these may
# be split further as the roles may separate between projects.
#
# If a minion specifies that it is part of a 'wordpress' project,
# an additional state file is loaded that applies the opinionated
# configurations around those states.
#
# Environments for wsuwp-vagrant and wsuwp-production are also
# allowed for, though these will be refactored shortly.
base:
  '*':
    - server
    - security
    - webserver
    - cacheserver
    - dbserver
  'project:wordpress':
    - match: grain
    - wordpress
  'wsuwp':
    - wsuwp