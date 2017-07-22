# WSU Web Provisioner

This repository contains provisioning for the Linux servers maintained by [WSU Web Communication](http://web.wsu.edu).

* [Ansible](https://www.ansible.com/) is used to manage configuration and provisioning.
* [Vagrant](http://vagrantup.com) is used to provide development environments.

## Current Projects

These projects are currently using WSU Web Provisioner for provisioning.

* [WSUWP Platform](https://github.com/washingtonstateuniversity/WSUWP-Platform)
* [WSUWP Indie Development](https://github.com/washingtonstateuniversity/WSUWP-Indie-Development)
* [WSU Search](https://github.com/washingtonstateuniversity/wsu-search)
* [WSU Lists](https://github.com/washingtonstateuniversity/wsu-lists)
* [WSU Proxy](https://github.com/washingtonstateuniversity/wsu-proxy)

## Setup

To interact with and provision WSU servers, [install Ansible](https://docs.ansible.com/ansible/latest/intro_installation.html) on your local machine. If you are using OSX, Ansible can be installed with [Homebrew](https://brew.sh/): `brew install ansible`.

To run commands on a remote server, you'll need to have the matching SSH configuration for that server on your local machine. These remote servers must also be configured as Ansible hosts in `/usr/local/etc/ansible/hosts` or `/etc/ansible/hosts` depending on your OS and configuration.

Any remote servers must have at least Python 2.5 installed to be compatible with commands issued by Ansible over SSH.

## Organization

### Ansible Playbooks

### Package Configuration

Configuration files specific to various packages that are being installed throughout provisioning are located in `provision/salt/config/`.

The organization of this area currently leaves quite a bit to be desired. Over time, we should find better ways of organizing this for both general and specific project needs.

## Provisioning

### In Vagrant

While Vagrant has direct support for using Salt as a provisioner, there are a few manual steps that we take with an initial server setup that make an alternative method more approachable.

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
  rm /etc/salt/minion_id
  echo "wsuwp-dev" > /etc/salt/minion_id
  cp /srv/wsu-web/provision/salt/minions/wsuwp-vagrant.conf /etc/salt/minion.d/
  salt-call --local --log-level=info --config-dir=/etc/salt state.highstate
SCRIPT

config.vm.provision "shell", inline: $script
```

This starts by using [cURL](http://curl.haxx.se/) to download the most recent version of the WSU Web Provisioner. Over time we'll likely specify a specific version in this URL. After staging things in a `wsu-web` directory, we copy over a custom configuration for [yum](http://yum.baseurl.org/). This allows us to specify a few things about our use of yum, primarily that we don't try to do any automatic Linux kernel upgrades. Once this is set, we check for the Salt installation on the virtual machine through `bootstrap_salt.sh`, copy over the specific minion configuration included with the WSU Web Provisioner package, and then use `salt-call` to process the provisioning configuration.

This very much mimics a workflow that may exist on a production server and will be useful in ensuring that things are working as expected before going live.

Note: The EPEL repositories for the CentOS 6.4 image we are using are served with SSL 3.0. For this reason, `yum` has issues when updating the available packages. Two lines have been added to the script example above to replace `https` with `http` in the repository config file.

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
