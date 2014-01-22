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

### Managed through Scripting

As you'll see below, Vagrant has direct support for using Salt as a provisioner. While this could be extremely useful, there are a few manual steps that we take with an initial server setup that make an alternative method more approachable.

Shell scripting can be used during the provisioning of a virtual machine to setup a few environment basics before downloading the most recent provisioning setup (this repository) and calling Salt to process it.

Example:

```
$script =<<SCRIPT
  cd /srv && rm -fr serverbase
  cd /srv && curl -o serverbase.zip -L https://github.com/washingtonstateuniversity/wsu-web-provisioner/archive/master.zip
  cd /srv && unzip serverbase.zip
  cd /srv && mv WSU-Web-Provisioner-master wsu-web
  cp /srv/wsu-web/provision/salt/config/yum.conf /etc/yum.conf
  sh /srv/wsu-web/provision/bootstrap_salt.sh
  cp /srv/wsu-web/provision/salt/minions/wsuwp-vagrant.conf /etc/salt/minion.d/
  salt-call --local --log-level=debug --config-dir=/etc/salt state.highstate
SCRIPT

config.vm.provision "shell", inline: $script
```

This starts by using [cURL](http://curl.haxx.se/) to download the most recent version of the WSU Web Provisioner. Over time we'll likely specify a specific version in this URL. After staging things in a `wsu-web` directory, we copy over a custom configuration for [yum](http://yum.baseurl.org/). This allows us to specify a few things about our use of yum, primarily that we don't try to do any automatic Linux kernel upgrades. Once this is set, we check for the Salt installation on the virtual machine through `bootstrap_salt.sh` and then use `salt-call` to process the provisioning configuration.

This very much mimics a workflow that may exist on a production server and will be useful in ensuring that things are working as expected before going live.

### Managed by Vagrant

Vagrant has [support for Salt as a provisioner](http://docs.vagrantup.com/v2/provisioning/salt.html) by default. This allows you to specify a portion of `Vagrantfile` that grabs the proper minion and passes proper highstate information to Salt inside the VM.

Example:

```
config.vm.provision :salt do |salt|
  salt.install_type = 'testing'
  salt.verbose = true
  salt.minion_config = 'provision/salt/minions/vagrant.conf'
  salt.run_highstate = true
end
```

This requires that at least the minion config is available to the virtual machine ahead of time. In the example above, a local directory `provision/salt/minions/` would exist containing the minion file `vagrant.conf`. An example of how we used to do this in the WSUWP Platform project can be found [in this version](https://github.com/washingtonstateuniversity/WSUWP-Platform/blob/1ece16674191a4692b30240a11dae754efa775fc/Vagrantfile#L91).
