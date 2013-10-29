# WSUWP-Environment

* **Version:** 0.1-working

## Overview

TBD.

## Getting Started

1. Download and install the latest version of [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
1. Download and install the latest version of [Vagrant](http://downloads.vagrantup.com/)
	* `vagrant` is now available to you as a command in your terminal
1. Type `vagrant plugin install vagrant-hostsupdater`
	* This installs the [Vagrant hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin to easily manage domains
1. Clone or extract this repository into a local directory on your machine into a directory of your choosing
	* `git clone https://github.com/washingtonstateuniversity/WSUWP-Environment.git wsuwp-environment`
1. Navigate to `wsuwp-environment` in your terminal
1. Type `vagrant up`
	* On a Linux or OSX machine, you may need to enter your password so that the hosts file can be edited by the plugin.
	* On a Windows machine, either run the command prompt as an administrator or modify the permissions of your hosts file so that no password is required.

## To update the repository

In the `wsuwp-environment` directory:

1. Type `git pull origin master` to bring down the latest changes to the repository.

## Expectations

### Timing

* The first `vagrant up` from scratch, requiring a full box download, takes about X minutes on a 42Mbps university connection.
* `vagrant up` after `vagrant destroy` takes about 7 minutes on a 42Mbps university connection.
	* This assumes the persistent files for the WSUWP Platform are still in place.
* `vagrant up` after `vagrant destroy` without the persistent WSUWP Platform files takes about X minutes on a 42Mbps university connection.
* `vagrant up` after `vagrant halt` takes about X minutes on a 42Mbps university connection.