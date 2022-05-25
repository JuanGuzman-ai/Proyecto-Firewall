# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "base"
    config.vm.define :serverFirewall do |serverFirewall|
    serverFirewall.vm.box = "bento/centos-7"
    serverFirewall.vm.hostname = "firewall"
    serverFirewall.vm.network :private_network, ip: "192.168.50.3"
    serverFirewall.vm.network :public_network, ip: "192.168.10.1"
    serverFirewall.vm.network "forwarded_port", guest: 80, host: 8080
  end
  config.vm.define :serverStreama do |serverStreama|
    serverStreama.vm.box = "bento/centos-7"
    serverStreama.vm.hostname = "streama"
    serverStreama.vm.network :private_network, ip: "192.168.50.4"
  end
end
