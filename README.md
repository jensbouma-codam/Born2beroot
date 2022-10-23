**Born2BeRoot the Hardway**

**WORK IN PROGRESSS!!!**

This project is a guide to use terraform (and maybe Ansible) to install the complete Born2beroot subject form code without a helpertool like VirualBox or UTM to run the VM. Offcourse the created qcow2 file can run in UTM as well or (be converted to vdi to) run in VirtualBox.

**Install Homebrew**
```
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
**Install quemu & libvirt & cdrtools**
```
  brew install qemu libvirt cdrtools tuntap
```

**Disable QEMU security features**
```
echo 'security_driver = "none"' >> /opt/homebrew/etc/libvirt/qemu.conf
echo "dynamic_ownership = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
echo "remember_owner = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
```

**Edit config files and setup networking**

virsh net-define network-default.xml Not working as i cant make the bridge yet.
virsh net-start default

**Install Libvirt service**
```
brew services start libvirt
```

**Install Hasicorp Terraform**
```
  brew install kreuzwerker/taps/m1-terraform-provider-helper
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  m1-terraform-provider-helper activate
  m1-terraform-provider-helper install hashicorp/template -v `v2.2.0
```

**Get Debian qcow2 Cloud Image**
- Download image from: https://cloud.debian.org/images/cloud/bullseye/ to projectfolder 'images'
- For M1 processor you can use the ARM version to run it native but it would't run on a x86 processor.

**- Deploy Terraform code **
```
export TERRAFORM_LIBVIRT_TEST_DOMAIN_TYPE="qemu" 
terraform init
terraform plan
terraform apply
```

**Usefull Virsh commands**
```
virsh list
virsh start 'Debian Cloud'              // Run VM
virsh shutdown 'Debian Cloud'           // Shutdown VM
virsh reboot  'Debian Cloud'            // Reboot
virsh destroy 'Debian Cloud'            // Force Shutdown
virsh undefine --nvram 'Debian Cloud'   // Remove VM
virsh console 'Debian Cloud'            // Connect to serial console

ssh -p 2222 root@localhost  // Connect to VM with SSH
```




https://discourse.brew.sh/t/failed-to-connect-socket-to-var-run-libvirt-libvirt-sock-no-such-file-or-directory/1297/2


<!-- - Create folder
mkdir ~/vms && cd ~/vms
- Create disk for VM
qemu-img create -f qcow2 ubuntu.qcow2 50g
- Run debiancloud.xml > virsh define debiancloud.xml
- Start VM > virsh start 'Debian Cloud' -->
