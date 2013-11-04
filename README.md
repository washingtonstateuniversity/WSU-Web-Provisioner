# WSUWP-Environment

## Overview

Work is underway at Washington State University to build a central WordPress publishing platform for use by many groups within the University.

A major goal is to open source as much of the work as possible for use by other universities and organizations around the world.

The goal of the WSUWP Environment project is to provide provisioning for development and production environments that can be used to implement the [WSUWP Platform](https://github.com/washingtonstateuniversity/WSUWP-Platform) project.

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
	* On a Linux or OSX machine, you may need to enter your password so that the hosts file can be edited by the vagrant-hostsupdater plugin.
	* On a Windows machine, either run the command prompt as an administrator or modify the permissions of your hosts file so that no password is required.
1. Visit `http://wp.wsu.edu` in your browser.
	* See [WSUWP Platform](https://github.com/washingtonstateuniversity/WSUWP-Platform)

## What is Provided

The environment provided by WSUWP Environment is intended to match the production environment associated with the central WSUWP system at Washington State University. This allows developers to extend the platform locally and properly test themes, plugins, and the platform itself before these changes are deployed to production.

Over time, pieces of the environment will be extracted so that the domain `wp.wsu.edu` can be changed for ease of use with other systems.

## Keep Updated

WSUWP Environment is under active development. Until we establish a schedule of regular releases, it would be best to stay updated with this repository as much as possible.

In your local `wsuwp-environment` directory, the latest changes can be pulled down at any time with `git pull origin master`. Running `vagrant provision` will cause any state changes in the provisioning files to be applied to the local development environment, possibly updating parts of the [WSUWP Platform](https://github.com/washingtonstateuniversity/WSUWP-Platform) as well.

## Expectations

### Timing

* The first `vagrant up` from scratch, requiring a full box download, takes about X minutes on a 42Mbps university connection.
* `vagrant up` after `vagrant destroy` takes about 7 minutes on a 42Mbps university connection.
	* This assumes the persistent files for the WSUWP Platform are still in place.
* `vagrant up` after `vagrant destroy` without the persistent WSUWP Platform files takes about X minutes on a 42Mbps university connection.
* `vagrant up` after `vagrant halt` takes about 2 minutes on a 42Mbps university connection. Though connection speed should not matter much for this.