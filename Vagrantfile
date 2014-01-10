# WSUWP Environment Vagrant Configuration
#
# This is the development Vagrantfile for the WSUWP Environment project. This
# Vagrant setup helps to describe an environment for local development that
# matches the WSUWP Environment production setup as closely as possible.
#
# We recommend Vagrant 1.3.5 and Virtualbox 4.3.
#
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Look for the machine ID file. This should indicate if the VM state is suspended, halted, or up.
machines_file = File.expand_path(File.dirname(__FILE__) + '/.vagrant/machines/default/virtualbox/id')
machine_exists = File.file?(machines_file)

Vagrant.configure("2") do |config|
  # Virtualbox specific setting to allocate 512MB of memory to the virtual machine.
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
  end

  # CentOS 6.4, 64 bit release
  #
  # Provides a fairly bare-bones CentOS box created by Puppet Labs.
  config.vm.box     = "centos-64-x64-puppetlabs"
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box"

  # Set the default hostname and IP address for the virtual machine. If you have any other
  # Vagrant environments on the 10.10.30.x subnet, you may want to consider modifying this.
  config.vm.hostname = "wsuwp"
  config.vm.network :private_network, ip: "10.10.30.30"

  # Mount the local project's www/ directory as /var/www inside the virtual machine. This will
  # be mounted as the 'vagrant' user at first, then unmounted and mounted again as 'www-data'
  # during provisioning.
  if machine_exists
    config.vm.synced_folder "www", "/var/www", :mount_options => [ "uid=510,gid=510", "dmode=775", "fmode=774" ]
  else
    config.vm.synced_folder "www", "/var/www", :mount_options => [ "uid=510,gid=510", "dmode=775", "fmode=774" ]
  end

  # Local Machine Hosts
  #
  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may be
  # required to enter a password for Vagrant to access your hosts file.
  #
  # The domains provided in this setup are intended to act as a good representation of possible
  # scenarios with the WSUWP Platform setup.
  if defined? VagrantPlugins::HostsUpdater
    config.hostsupdater.aliases = [
                     "wp.wsu.edu",
               "test1.wp.wsu.edu",
    	       "invalid.wp.wsu.edu",
    	       "content.wp.wsu.edu",
    	      "network1.wp.wsu.edu",
      "test1.network1.wp.wsu.edu",
    "invalid.network1.wp.wsu.edu",
    	"site1.network1.wp.wsu.edu",
    	"site2.network1.wp.wsu.edu",
    	      "network2.wp.wsu.edu",
      "test1.network2.wp.wsu.edu",
    "invalid.network2.wp.wsu.edu",
    	          "school1.wsu.edu",
          "test1.school1.wsu.edu",
    	    "site1.school1.wsu.edu",
    	    "site2.school1.wsu.edu",
    	  "invalid.school1.wsu.edu",
    	          "school2.wsu.edu",
          "test1.school2.wsu.edu",
    	  "invalid.school2.wsu.edu",
    	          "invalid.wsu.edu"
    ]
  end

  # Salt Provisioning
  #
  # Map the provisioning directory to the guest machine and initiate the provisioning process
  # with salt. On the first build of a virtual machine, if Salt has not yet been installed, it
  # will be bootstrapped automatically. We have provided a modified local bootstrap script to
  # avoid network connectivity issues and to specify that a newer version of Salt be installed.
  config.vm.synced_folder "provision/salt", "/srv/salt"

  config.vm.provision "shell",
    inline: "cp /srv/salt/config/yum.conf /etc/yum.conf"

  config.vm.provision :salt do |salt|
    salt.bootstrap_script = 'provision/bootstrap_salt.sh'
    salt.install_type = 'testing'
    salt.verbose = true
    salt.minion_config = 'provision/salt/minions/vagrant.conf'
    salt.run_highstate = true
  end
end
