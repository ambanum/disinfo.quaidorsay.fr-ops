# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "disinfo" do |disinfo|
    disinfo.vm.box = "debian/buster64"
    disinfo.vm.network :forwarded_port, guest: 22, host: 2222, id: 'ssh'
    disinfo.vm.network "private_network", ip: "192.168.33.10"
    disinfo.ssh.port = "2222"
    disinfo.vm.define "disinfo"
    disinfo.vm.hostname = "disinfo"
  end

  config.vm.define "ota" do |ota|
    ota.vm.box = "debian/buster64"
    ota.vm.network :forwarded_port, guest: 22, host: 2223, id: 'ssh'
    ota.vm.network "private_network", ip: "192.168.33.11"
    ota.ssh.port = "2223"
    ota.vm.define "ota"
    ota.vm.hostname = "ota"
  end
end
