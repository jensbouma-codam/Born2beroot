**Born2BeRoot the Hardway**

**WORK IN PROGRESSS!!!**

This project is a guide to use terraform (and maybe Ansible) to install the complete Born2beroot subject form code without a helpertool like VirualBox or UTM to run the VM. Offcourse the created qcow2 file can run in UTM as well or (be converted to vdi to) run in VirtualBox.

**Install Homebrew**
```
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
**Install quemu & libvirt & cdrtools**
```
  brew install qemu libvirt cdrtools 
```

<!-- **Install virtmanager**
```
brew tap arthurk/homebrew-virt-manager
brew install virt-manager virt-viewer
``` -->

**Disable QEMU security features (as macos doesn't support this**
```
echo 'security_driver = "none"' >> /opt/homebrew/etc/libvirt/qemu.conf
echo "dynamic_ownership = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
echo "remember_owner = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
```

**Install vde_vmnet**
https://github.com/lima-vm/socket_vmnet
```
git clibe https://github.com/lima-vm/socket_vmnet.git
cd socket_vmnet
sudo make PREFIX=/opt/socket_vmnet install
```

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
  m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```

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

**Create disk of 8225M**

apt update
sudo apt-get install cryptsetup
sudo apt-get install lvm2

<!-- sudo dd if=/dev/zero of=/dev/nvme2n1 bs=512k count=16450 -->

sudo sgdisk -og /dev/nvme2n1
sudo sgdisk -og /dev/nvme2n1 && sudo sgdisk -n 1:0:+487M -n 2:0:+1K -n 3:0:+7680M  /dev/nvme2n1

dd bs=512 count=4 if=/dev/random of=/home/debian/keyfile iflag=fullblock

sudo cryptsetup -c aes-xts-plain -y -s 512 -h sha512 luksFormat --key-file=/home/debian/keyfile /dev/nvme2n1p3

<!-- sudo cryptsetup --cipher=aes-xts-plain64 --offset=0 --key-file=/home/debian/keyfile --key-size=512 open --type=plain /dev/nvme2n1p3 crypt -->

<!-- sudo cryptsetup luksFormat --key-file=/home/debian/keyfile  /dev/nvme2n1p3 -->
sudo cryptsetup luksOpen --key-file=/home/debian/keyfile /dev/nvme2n1p3 crypt

sudo pvcreate /dev/mapper/crypt

sudo vgcreate jbouma-vg /dev/mapper/crypt 
sudo lvcreate -L 2.750G -n root jbouma-vg
sudo lvcreate -L 976M -n swap_1 jbouma-vg
sudo lvcreate -L 3.750G -n home jbouma-vg


sudo mkfs.ext4 -L root /dev/jbouma-vg/root 
sudo mkfs.ext4 -L root /dev/jbouma-vg/swap_1 
sudo mkfs.ext4 -L root /dev/jbouma-vg/home


<!-- sudo dd if=/dev/nvme1n1p1 of=/dev/jbouma-vg/root bs=512 -->
<!-- resize2fs /dev/sda1 -->

sudo mkswap /dev/jbouma-vg/swap_1 
swapon /dev/jbouma-vg/swap_1 

https://discourse.brew.sh/t/failed-to-connect-socket-to-var-run-libvirt-libvirt-sock-no-such-file-or-directory/1297/2


<!-- - Create folder
mkdir ~/vms && cd ~/vms
- Create disk for VM
qemu-img create -f qcow2 ubuntu.qcow2 50g
- Run debiancloud.xml > virsh define debiancloud.xml
- Start VM > virsh start 'Debian Cloud' -->
