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

## Provisioning in Production

## Provisioning in Vagrant

There are two different ways that Salt can be used to provision a virtual machine in Vagrant.

### Managed by Vagrant

Vagrant has [support for Salt as a provisioner](http://docs.vagrantup.com/v2/provisioning/salt.html) by default. This allows you to specify a portion of `Vagrantfile` that grabs the proper minion and passes proper highstate information to Salt inside the VM.

Example:

{{{
config.vm.provision :salt do |salt|
  salt.install_type = 'testing'
  salt.verbose = true
  salt.minion_config = 'provision/salt/minions/vagrant.conf'
  salt.run_highstate = true
end
}}}

This requires that at least the minion config is available to the virtual machine ahead of time. In the example above, a local directory `provision/salt/minions/` would exist containing the minion file `vagrant.conf`. An example of how we used to do this in the WSUWP Platform project can be found [in this version](https://github.com/washingtonstateuniversity/WSUWP-Platform/blob/1ece16674191a4692b30240a11dae754efa775fc/Vagrantfile#L91).
