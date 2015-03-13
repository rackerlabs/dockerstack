# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = 2

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.box = "fedora-21"

  config.vm.network "forwarded_port", guest: 5000, host: 5000
  config.vm.network "forwarded_port", guest: 35357, host: 35357

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 2
  end

  config.vm.provision :chef_solo do |chef|
    chef.run_list = ["recipe[docker]"]
  end

end
