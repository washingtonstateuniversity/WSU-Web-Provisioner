# WSUWP-Environment

* **Version:** 0.1-working

## Overview

TBD.

## Getting Started

1. Download and install the latest version of [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
1. Download and install the latest version of [Vagrant](http://downloads.vagrantup.com/)
1. Clone or extract this repository into a local directory on your machine into a directory of your choosing (e.g. `{wsuwp-dir}`)
	* `git clone https://bbuser@bitbucket.org/jeremyfelt/wsuwp.git wsuwp-dir`
1. Navigate to `{wsuwp-dir}`
1. Type `git submodule init` to initialize submodules
1. Type `git submodule update` to bring the submodules up to date with the latest tracking commits.
1. Type `vagrant plugin install vagrant-hostsupdater`
	* This installs the [Vagrant hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin to easily manage domains
1. Type `vagrant up`
	* On a Linux or OSX machine, you may need to enter your password so that the hosts file can be edited by the plugin.
	* On a Windows machine, either run the command prompt as an administrator or modify the permissions of your hosts file so that no password is required.

## To update the repository

In the `{wsuwp-dir}` directory:

1. Type `git pull origin master` to bring down the latest changes to the repository.
1. Type `git submodule update` to update the submodules.
