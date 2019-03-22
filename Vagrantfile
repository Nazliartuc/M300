Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "forwarded_port", guest:80, host:8888, auto_correct: true  
config.vm.provider "virtualbox" do |vb|
  vb.memory = "2048"  
end
config.vm.provision :shell, path: "config.sh"
end