# -*- mode: ruby -*-
# vim: set ft=ruby :
# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :inetRouter => {
        :box_name => "centos/7",
        #:public => {:ip => '10.10.10.1', :adapter => 1},
        :net => [
                   {ip: '192.168.255.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
                ]
  },
  :inetRouter2 => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.11.50', adapter: 2, netmask: "255.255.255.0"},
                   {ip: '192.168.250.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router2-net"},
                ]

  },

  :centralRouter => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
                   {ip: '192.168.250.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router2-net"},
                   {ip: '192.168.0.1', adapter: 4, netmask: "255.255.255.240", virtualbox__intnet: "central-network"},
                 ]
  },

  :centralServer => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "central-network"},
                ]
  },


}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        box.vm.provision "shell", inline: <<-SHELL
          mkdir -p ~root/.ssh
          cp ~vagrant/.ssh/auth* ~root/.ssh
          sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
          systemctl restart sshd
        SHELL
        
        case boxname.to_s

        when "inetRouter"
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
            sysctl -p
            iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
            iptables -A INPUT -p tcp -i eth1 --dport 22 -j DROP
            ip r add 192.168.0.0/16 via 192.168.255.2
            SHELL

        when "inetRouter2"
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
            sysctl -p
            ip r add 192.168.0.0/16 via 192.168.250.2
            SHELL

        when "centralRouter"
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
            sysctl -p
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
            echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
            ip r del default
            ip r add default via 192.168.255.1
            systemctl restart network
            SHELL

        when "centralServer"
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
            echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
            ip r del default
            ip r add default via 192.168.0.1
            systemctl restart network
            SHELL

        end

        box.vm.provision "ansible" do |ansible|
            ansible.verbose = "vv"
            ansible.playbook = "playbooks/knock-server.yml"
            ansible.become = "true"
	    end

	    box.vm.provision "ansible" do |ansible|
            ansible.verbose = "vv"
            ansible.playbook = "playbooks/prep_servers.yml"
            ansible.become = "true"
        end
    end

  end

end