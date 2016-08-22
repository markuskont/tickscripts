$GO = <<SCRIPT
  sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable -y
  sudo apt-get update && sudo apt-get install golang -y
SCRIPT

boxes = [
  {
    :name => "udf",
    :mem  => "2048",
    :cpu  => "4",
    :ip   => "192.168.56.197"
  },
]

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network 'private_network', ip: opts[:ip]

      config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
      config.vm.provision "shell", inline: $GO
      config.vm.provision "shell", path: "./scripts/install_influx.sh", args: opts[:ip]
      config.vm.provision "shell", path: "./scripts/install_telegraf.sh", args: opts[:ip]
      config.vm.provision "shell", path: "./scripts/install_grafana.sh", args: opts[:ip]
      config.vm.provision "shell", path: "./scripts/install_kapacitor.sh", args: opts[:ip]
      #config.vm.synced_folder ".", "/home/vagrant/src/github.com/influxdata/telegraf"
    end
  end
end
