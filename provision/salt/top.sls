# The current * base is a placeholder until we are prepared
# to provision more than one environment. At that point this
# will be split so that `vagrant` runs a specific series of
# states.
#
# As an example, the 'wsuwp-dev' state will not be run on
# production. Likely, another 'wsuwp-prod' will be available
# at that time.
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
