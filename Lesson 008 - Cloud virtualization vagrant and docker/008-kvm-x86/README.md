# Libvirt and Vagrant

We have already seen that not every Linux is the same. Package names differ per distribution, as do configuration files and even commands. 

For the bigger brand names like Fedora, AlmaLinux, Rocky, Ubuntu and Debian the instructions from the slides should work. But in some cases, things work slightly differently. 

## Mint Linux

With one student we noticed that Virtualbox *really* does not want to run easily on a Mint system, because KVM is in the kernel and some settings prevent VBox from working. To get it to work, VBox tells you to actually disable and remove KVM. They even tell you to recompile the whole kernel!

Better to just use KVM then! :)

On Mint Linux:

0. Download and install Vagrant from their repo. It's not in Mint's own repo -> https://developer.hashicorp.com/vagrant/install

1. sudo apt install libvirt-dev virt-manager && sudo systemctl enable libvirtd && sudo systemctl start libvirtd

2. vagrant plugin install vagrant-libvirt

3. sudo usermod -aG libvirt ${USER}

After that last command, you need to either SU or SSH to a new session for your account, or you need to restart the whole laptop because of credential caching in the desktop environment's login process

After that you should be able to run: vagrant up --provider=libvirt

