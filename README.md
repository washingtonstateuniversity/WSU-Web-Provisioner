# WSU Web Provisioner

This repository contains provisioning for the Linux servers maintained by WSU Web Communication.

* [Salt](http://www.saltstack.com/community/) is used to manage configuration and provisioning.

## Minion Config

Minions exist in `provision/salt/minions/` and are used to specify a configuration specific to a server during provisioning.

Naming of the minions should follow a `project` `-` `location` format.

Current minions include:

* `wsuwp-production.conf` for the production environment of the WSUWP Platform.
* `wsuwp-vagrant.conf` for the development environment of the WSUWP Platform.
* `wsuwp-indie-production.conf` for the production environment for the server containing individual WordPress sites.
* `wsuwp-indie-vagrant.conf` for the development environment containing individual WordPress sites.
