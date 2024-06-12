#!/bin/bash

# Downloads the Fedora Workstation ISO file from the specified URL and saves it to the Downloads folder.
curl -L https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-40-1.14.iso -o $HOME/Downloads/Fedora-Workstation-Live-x86_64-40-1.14.iso

# Update your package list
sudo apt update

# Install KVM and related packages
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Install virt-manager (GUI for managing virtual machines)
sudo apt install -y virt-manager

# Add your user to the libvirt and kvm groups
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)

# Creates a new qcow2 disk image using the qemu-img command.
# The disk image will be named "fedora40.qcow2" and will have a size of 20GB.
mkdir $HOME/qemu
qemu-img create -f qcow2 $HOME/qemu/fedora40.qcow2 20G

# This script is used to create a virtual machine using the 'virt-install' command.
# It installs Fedora 40 with the specified configuration parameters.
virt-install \
    --name fedora-desktop-40 \
    --ram 8096 \
    --vcpus 2 \
    --disk path=$HOME/qemu/fedora40.qcow2,format=qcow2 \
    --os-variant fedora38 \
    --graphics spice \
    --cdrom $HOME/Downloads/Fedora-Workstation-Live-x86_64-40-1.14.iso \
    --network network=default \
    --boot menu=on

# Grant read and execute permissions to the user 'libvirt-qemu' for the current user's home directory and all its contents.
sudo setfacl -R -m u:libvirt-qemu:rx $HOME/qemu
sudo setfacl -R -m u:libvirt-qemu:rx $HOME/Downloads

# Open a virtual viewer to connect to the Fedora Desktop 40 virtual machine
virt-viewer --connect qemu:///system --wait fedora-desktop-40

# Prepare VM for SSH (execute in guest VM)
# 1. Updates the system packages using `dnf update` command.
# 2. Installs the OpenSSH server using `dnf install -y openssh-server` command.
# 3. Enables and starts the SSH service using `systemctl enable --now sshd` command.
# 4. Configures the firewall to allow SSH connections using `firewall-cmd` commands.
sudo dnf update
sudo dnf install -y openssh-server
sudo systemctl enable --now sshd
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload


# This script retrieves the IP address of a KVM virtual machine named "fedora-desktop-40"
# Copies the SSH public key to the virtual machine
KVM_IP=$(virsh domifaddr fedora-desktop-40|awk 'NR>2 {sub(/\/.*$/, "", $4); print 
$4}')
# Change the username
ssh-copy-id YOUR_USERNAME@$KVM_IP

# This script uses the Ansible tool to automate the configuration of the Fedora Desktop 40 virtual machine. Change username and private SSH key location
ansible-playbook main.yml -i $KVM_IP -e 'ansible_user=YOUR_USERNAME' -e 'ansible_ssh_private_key_file=~/.ssh/id_ecdsa'