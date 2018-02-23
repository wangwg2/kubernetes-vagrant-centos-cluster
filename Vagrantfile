# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  $num_instances = 3

  # curl https://discovery.etcd.io/new?size=3
  $etcd_cluster = "node1=http://192.168.99.91:2380"

  (1..$num_instances).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "centos/7"
      node.vm.hostname = "node#{i}"
      ip = "192.168.99.#{i+90}"
      node.vm.network "private_network", ip: ip
      node.vm.network "public_network"
      # node.vm.network "public_network", bridge: "Killer Wireless-n/a/ac 1535 Wireless Network Adapter"
      # node.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 7265"  
      # node.vm.network "public_network", bridge: "en0: Wi-Fi (AirPort)", auto_config: true
      #node.vm.synced_folder "/Users/DuffQiu/share", "/home/vagrant/share"

      config.ssh.insert_key = false
      config.ssh.forward_agent = true

      node.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 1
        vb.name = "node#{i}"
      end

      node.vm.provision :shell, :path => "provision.sh", :args => [i, ip, $etcd_cluster]
    end  
  end
end