# WSU Web Provisioner

This repository contains provisioning for the Linux servers maintained by [WSU Web Communication](http://web.wsu.edu).

* [Salt](http://www.saltstack.com/community/) is used to manage configuration and provisioning.
* [Vagrant](http://vagrantup.com) is used to provide development environments.

## Current Projects

These projects are currently using WSU Web Provisioner for provisioning.

* [WSUWP Platform](https://github.com/washingtonstateuniversity/WSUWP-Platform)
* [WSUWP Indie Development](https://github.com/washingtonstateuniversity/WSUWP-Indie-Development)
* [WSU Search](https://github.com/washingtonstateuniversity/wsu-search)
* [WSU Lists](https://github.com/washingtonstateuniversity/wsu-lists)
* [WSU Proxy](https://github.com/washingtonstateuniversity/wsu-proxy)

## Organization

### Salt Bootstrap

A copy of `bootstrap_salt.sh` is maintained in the `provision/` directory to perform initial installation of Salt on a server. This file is provided through the [Salt Bootstrap](https://github.com/saltstack/salt-bootstrap) project and included in this repository.

As new versions of this script are certified to work, this bootstrap file will be updated.

### Salt State Files

All `.sls` files defining various server roles are located in `provision/salt/`. These files explain the various states that should be provided when provisioning runs.

Naming of state files should be as specific to the provisioned role as possible. If no conflicts exist between projects, `webserver.sls` should provide things that make a web server. Similarly, `dbserver.sls` should provide things that make a database server.

If conflicts arise, care will be taken to name these state files in a descriptive fashion that indicates role and varying factor.

### Package Configuration

Configuration files specific to various packages that are being installed throughout provisioning are located in `provision/salt/config/`.

The organization of this area currently leaves quite a bit to be desired. Over time, we should find better ways of organizing this for both general and specific project needs.

### Pillar Data

Pillar data is specific to the minion. Its location is specified in each minion configuration with this syntax:

```
# The location for pillar data on this server.
pillar_roots:
  base:
    - /srv/pillar
```

With the above configuration, pillar data should be provided in `/srv/pillar/` on the server being provisioned.

Depending on the type of minion being provisioned, different data is required in the pillar directory. By default, a `top.sls` file should be provided that always loads a `network.sls`:

````
base:
  '*':
    - network
```

`network.sls` should contain settings specific to the network.

```
network:
  location: local
  gateway_ip: 10.10.40.1
  nameservers: |
    nameserver 8.8.8.8
    nameserver 8.8.4.4
```

* `location` should be local or remote depending on where the environment exists.
* `gateway_ip` should be defined if you want to use remote debug with xdebug.

There are current projects that support `mysql.sls` and `sites.sls` pillar data. Over time these will be grouped into both common and specific areas. As this happens, documentation will be built out in this repository for support.

### Minion Config

Minions exist in `provision/salt/minions/` and are used to specify a configuration specific to a server during provisioning.

Naming of the minions should follow the format of `project.conf`. In some cases a project will need more than one minion configuration for development and production or for other server roles that are part of that project. These should be explictly named as `project` `-` `environment.conf`.

Current minions include:

* `wsuwp.conf` for both the production and development environments providing the WSUWP Platform.
* `wsuwp-indie.conf` for both the production and development environment for the server containing individual WordPress sites.
* `wsu-search.conf` for both the production and development environments for WSU Search.
* `wsu-list.conf` for both the production and development environments for WSU Lists.

## Provisioning

### In Vagrant

There are two different ways that Salt can be used to provision a virtual machine in Vagrant.

#### Managed through Scripting

As you'll see below, Vagrant has direct support for using Salt as a provisioner. While this could be extremely useful, there are a few manual steps that we take with an initial server setup that make an alternative method more approachable.

Shell scripting can be used during the provisioning of a virtual machine to setup a few environment basics before downloading the most recent provisioning setup (this repository) and calling Salt to process it.

Example:

```
$script =<<SCRIPT
  cd /srv && rm -fr wsu-web
  cd /srv && curl -o wsu-web.zip -L https://github.com/washingtonstateuniversity/wsu-web-provisioner/archive/master.zip
  cd /srv && unzip wsu-web.zip
  cd /srv && mv WSU-Web-Provisioner-master wsu-web
  cp /srv/wsu-web/provision/salt/config/yum.conf /etc/yum.conf
  rpm -Uvh --force http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  sed -i 's/mirrorlist=https/mirrorlist=http/' /etc/yum.repos.d/epel.repo
  sh /srv/wsu-web/provision/bootstrap_salt.sh -k stable
  rm /etc/salt/minion.d/*.conf
  cp /srv/wsu-web/provision/salt/minions/wsuwp-vagrant.conf /etc/salt/minion.d/
  salt-call --local --log-level=info --config-dir=/etc/salt state.highstate
SCRIPT

config.vm.provision "shell", inline: $script
```

This starts by using [cURL](http://curl.haxx.se/) to download the most recent version of the WSU Web Provisioner. Over time we'll likely specify a specific version in this URL. After staging things in a `wsu-web` directory, we copy over a custom configuration for [yum](http://yum.baseurl.org/). This allows us to specify a few things about our use of yum, primarily that we don't try to do any automatic Linux kernel upgrades. Once this is set, we check for the Salt installation on the virtual machine through `bootstrap_salt.sh`, copy over the specific minion configuration included with the WSU Web Provisioner package, and then use `salt-call` to process the provisioning configuration.

This very much mimics a workflow that may exist on a production server and will be useful in ensuring that things are working as expected before going live.

Note: The EPEL repositories for the CentOS 6.4 image we are using are served with SSL 3.0. For this reason, `yum` has issues when updating the available packages. Two lines have been added to the script example above to replace `https` with `http` in the repository config file.

#### Managed by Vagrant

Vagrant has [support for Salt as a provisioner](http://docs.vagrantup.com/v2/provisioning/salt.html) by default. This allows you to specify a portion of `Vagrantfile` that grabs the proper minion and passes proper highstate information to Salt inside the virtual machine.

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

When Vagrant boots the virtual machine with this configuration, Salt will be bootstrapped automatically, and the provisioning settings included in the mapped minion will be followed. This also requires that the provisioning be made available to the virtual machine by mapped directory ahead of time.

### In Production

Production provisioning will follow a process very similar to that of managing Salt in Vagrant through scripting.

The files contained in the WSU Web Provisioner repository will need to be deployed to a directory on production, likely `/srv/salt/` or something similar. The minion file for the specific production server will need to be copied to `/etc/salt/minion.d/`. The pillar data required by the minion's provisioning configuration should be added in a location such as `/srv/pillar/`.

Salt will need to be bootstrapped on the first attempt to make sure that utilities like `salt-call` are available to us. We'll then need to issue a `salt-call` command to apply `salt.highstate` to the server.

From here, things get pretty automatic. Salt will process all of the various state files and ensure that pieces of the server are configured to match.

#### Scripts

Three scripts are included with this repository for use in production:

* `scripts/bootstrap.sh` will run the current bootstrap for Salt and then copy over the latest minion file.
* `scripts/prep.sh` will retrieve the latest WSU Web Provisioner archive and extract to the proper location.
* `scripts/salt.sh` will run the `salt-call` command necessary for provisioning the server.