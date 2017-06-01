Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant"
  config.vm.provision "shell", path: "setup.sh"
  config.vm.define "ubuntu-64" do |ubu|
    ubu.vm.box = "ubuntu/xenial64"
    ubu.vm.network "forwarded_port", guest: 80, host: 8080
    ubu.vm.network "forwarded_port", guest: 8090, host: 8090
    ubu.vm.network "forwarded_port", guest: 443, host: 4444
    ubu.vm.provider "virtualbox" do |v|
     v.memory = 2048
     v.cpus = 2
   end
  end
end
