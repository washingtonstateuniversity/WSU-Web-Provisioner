# -*- mode: ruby -*-
# vi: set ft=ruby :

dir = Dir.pwd

Vagrant.configure("2") do |config|

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
  end

  # Forward Agent
  #
  # Enable agent forwarding on vagrant ssh commands. This allows you to use identities
  # established on the host machine inside the guest. See the manual for ssh-add
  config.ssh.forward_agent = true
  
  # Ubuntu 12.0.4 LTS Precise, 32 bit release
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.hostname = "wp.wsu.edu"
  config.vm.network :private_network, ip: "10.10.30.30"

  # Local Machine Hosts
  #
  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may be
  # required to enter a password for Vagrant to access your hosts file.
  if defined? VagrantPlugins::HostsUpdater
    config.hostsupdater.aliases = [
    	       "invalid.wp.wsu.edu",
    	       "content.wp.wsu.edu",
    	      "network1.wp.wsu.edu",
      "invalid.network1.wp.wsu.edu",
    	"site1.network1.wp.wsu.edu",
    	"site2.network1.wp.wsu.edu",
    	      "network2.wp.wsu.edu",
      "invalid.network2.wp.wsu.edu",
    	          "school1.wsu.edu",
    	    "site1.school1.wsu.edu",
    	    "site2.school1.wsu.edu",
    	  "invalid.school1.wsu.edu",
    	          "school2.wsu.edu",
    	  "invalid.school2.wsu.edu",
    	          "invalid.wsu.edu"
    ]
  end

  # Drive mapping
  #
  # The following config.vm.share_folder settings will map directories in your Vagrant
  # virtual machine to directories on your local machine. Once these are mapped, any
  # changes made to the files in these directories will affect both the local and virtual
  # machine versions. Think of it as two different ways to access the same file. When the
  # virtual machine is destroyed with `vagrant destroy`, your files will remain in your local
  # environment.

  # /srv/database/
  #
  # If a database directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is used to maintain default database scripts as well as backed
  # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
  config.vm.synced_folder "database/", "/srv/database"
  config.vm.synced_folder "database/data/", "/var/lib/mysql", :mount_options => [ "dmode=777", "fmode=777" ]

  # /srv/www/
  #
  # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
  # inside the VM will be created that acts as the default location for nginx sites. Put all
  # of your project files here that you want to access through the web server
  config.vm.synced_folder "www/", "/srv/www/", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]

  config.vm.synced_folder "config/nginx-config/sites/", "/etc/nginx/sites-enabled/"

  # Provisioning
  config.vm.provision :shell, :path => File.join( "provision", "provision.sh" )
end
