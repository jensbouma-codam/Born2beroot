**Born2BeRoot the Hardway**

This project is a guide to use terraform (and maybe Ansible) to install the complete Born2beroot subject form code without a helpertool like VirualBox or UTM to run the VM. Offcourse the created qcow2 file can run in UTM as well or (be converted to vdi to) run in VirtualBox.

- Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

- Install quemu & libvirt
  brew install qemu gcc libvirt

- Disable QEMU security features
echo 'security_driver = "none"' >> /opt/homebrew/etc/libvirt/qemu.conf
echo "dynamic_ownership = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
echo "remember_owner = 0" >> /opt/homebrew/etc/libvirt/qemu.conf

- Install Hasicorp Terraform
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform





<!-- - Create folder
mkdir ~/vms && cd ~/vms
- Create disk for VM
qemu-img create -f qcow2 ubuntu.qcow2 50g
- Run debiancloud.xml > virsh define debiancloud.xml
- Start VM > virsh start 'Debian Cloud' -->
