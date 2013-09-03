# WSUWP: WordPress @ Washington State University

## Overview

## Getting Started

1. Download and install the latest version of [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
1. Download and install the latest version of [Vagrant](http://downloads.vagrantup.com/)
1. Clone or extract this repository into a local directory on your machine `{wsuwp-dir}`
1. Navigate to `{wsuwp-dir}`
1. Type `vagrant plugin install vagrant-hostsupdater`
	* This installs the [Vagrant hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin to easily manage domains
1. Type `vagrant up`
	* On a Linux or OSX machine, you may need to enter your password so that the hosts file can be edited by the plugin.
	* On a Windows machine, either run the command prompt as an administrator or modify the permissions of your hosts file so that no password is required.

## ToDoc

* Document how to setup a database stage before vagrant up

## WordPress filters

* wsu_my_network_title
	* Used in WordPress admin bar to display 'My WSU Networks' by default.

## WordPress Admin Bar Structure

* WP Logo
	* About WSU WP
* WSU Networks
	* Network 1
	* Network 2
		* (Network Admin)
			* Dashboard
			* Theme
			* Plugins
			* Users
			* Sites
		* Site 1
		* Site 2
	* Network 3
* Current Site
	* Dashboard
	* Themes
	* etc...
* Comment Logo
* New
	* Post
	* Page
* -----
* Howdy, User []