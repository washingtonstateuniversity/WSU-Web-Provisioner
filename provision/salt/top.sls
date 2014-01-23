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
    - webserver
    - cacheserver
    - dbserver
  'env:wsuwp-vagrant':
    - match: grain
    - devserver
    - wsuwp-dev
  'env:wsuwp-production':
    - match: grain
    - wsuwp-prod
  'wsuwp-indie-dev':
    - match: grain
    - wsuwp-indie-dev
