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

  # CentOS 6.4, 64 bit release
  config.vm.box = "centos64_64"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130731.box"

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

end
