# Provisioning is split into roles. The '*' states will run on
# every environment. The other states specified will currently
# only run for the associated minion ID.
base:
  '*':
    - server
    - security
    - webserver
    - cacheserver
    - dbserver
  'wsuwp-dev':
    - devserver
    - wsuwp-dev
  'wsuwp-prod-01':
    - wsuwp-prod
  'wsuwp-indie-dev':
    - devserver
    - wsuwp-indie-dev
