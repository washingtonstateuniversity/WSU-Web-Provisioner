# WSUWP: WordPress @ Washington State University

## Overview

## Getting Started

1. Download and install the latest version of [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
1. Download and install the latest version of [Vagrant](http://downloads.vagrantup.com/)
1. Clone or extract this repository into a local directory on your machine into a directory of your choosing (e.g. `{wsuwp-dir}`)
	* `git clone https://bbuser@bitbucket.org/jeremyfelt/wsuwp.git wsuwp-dir`
1. Navigate to `{wsuwp-dir}`
1. Type `git submodule init` to initialize the WordPress submodule
1. Type `git submodule update` to bring the WordPress submodule up to date with the latest tracking commit.
1. Copy one of the staging `.sql` files from `/database/stages/` to the `/database/backups/` directory and rename it to `wsuwp.sql`.
 	* This will preload the database with information about the WordPress installation.
1. Type `vagrant plugin install vagrant-hostsupdater`
	* This installs the [Vagrant hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin to easily manage domains
1. Type `vagrant up`
	* On a Linux or OSX machine, you may need to enter your password so that the hosts file can be edited by the plugin.
	* On a Windows machine, either run the command prompt as an administrator or modify the permissions of your hosts file so that no password is required.

## To update the repository

In the `{wsuwp-dir}` directory:

1. Type `git pull origin master` to bring down the latest changes to the repo
1. Type `git submodule update` to update the WordPress submodule

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