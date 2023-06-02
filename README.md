<h1 align="center">Born2BeRoot the Hardway</h1>

<p align="center">
  <em>This project serves as a comprehensive guide to using Terraform for installing the complete Born2BeRoot subject, without relying on helper tools like VirtualBox or UTM to run the VM. The created qcow2 file can also run in UTM or be converted to vdi for running in VirtualBox.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-English-blue.svg" alt="Language">
  <img src="https://img.shields.io/github/license/your/repository" alt="License">
</p>

## Lessons Learned Before Adopting the Regular Approach
- Creating and debugging a cloud-init file can be time-consuming.
- Transferring or reinstalling the system from a cloud image to another drive can be challenging.
- The mandatory disk partition scheme for Born2BeRoot presents certain complexities when automating the process. Thus, a formatted base image was initially created to run the cloud-init on. (Please note that the image is not included in this repository.)
- Virsh works well, but networking configuration proved to be challenging, so I migrated my image to UTM to complete the setup.

## Prerequisites

**Install Homebrew**
```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Install QEMU, Libvirt, and cdrtools**
```shell
brew install qemu libvirt cdrtools
```

**Disable QEMU Security Features (as macOS doesn't support this)**
```shell
echo 'security_driver = "none"' >> /opt/homebrew/etc/libvirt/qemu.conf
echo "dynamic_ownership = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
echo "remember_owner = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
```

**Install VDE_VMNET**
For installation instructions, refer to: [socket_vmnet](https://github.com/lima-vm/socket_vmnet)
```shell
git clone https://github.com/lima-vm/socket_vmnet.git
cd socket_vmnet
sudo make PREFIX=/opt/socket_vmnet install
```

**Install Libvirt Service**
```shell
brew services start libvirt
```

**Install HashiCorp Terraform**
```shell
brew install kreuzwerker/taps/m1-terraform-provider-helper
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```

## Deployment

**Deploy Terraform Code**
```shell
export TERRAFORM_LIBVIRT_TEST_DOMAIN_TYPE="qemu"
terraform init
terraform plan
terraform apply
```

## Useful Virsh Commands

```shell
virsh list
virsh start 'Debian Cloud'            // Run VM
virsh shutdown 'Debian Cloud'         // Shutdown VM
virsh reboot  'Debian Cloud'          // Reboot
virsh destroy 'Debian Cloud'          // Force Shutdown
virsh undefine --nvram 'Debian Cloud' // Remove VM
virsh console 'Debian Cloud'          // Connect to serial console
```

## Additional Commands

```shell
ssh -p 2222 root@localhost  // Connect to VM with SSH
wget -O - https://github.com/jensbouma.keys >> ~/.ssh/authorized_keys
```

<p align="center">
  <em>Feel free to explore the repository and don't hesitate

 to reach out with any questions. Happy coding!</em>
</p>
