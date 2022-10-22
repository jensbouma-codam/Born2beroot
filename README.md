**Born2BeRoot the Hardway**

- Install Homebrew
- brew install qemu gcc libvirt
- Disable QEMU security features
echo 'security_driver = "none"' >> /opt/homebrew/etc/libvirt/qemu.conf
echo "dynamic_ownership = 0" >> /opt/homebrew/etc/libvirt/qemu.conf
echo "remember_owner = 0" >> /opt/homebrew/etc/libvirt/qemu.conf

- Create folder
mkdir ~/vms && cd ~/vms
- Create disk for VM
qemu-img create -f qcow2 ubuntu.qcow2 50g
- Run debiancloud.xml > virsh define debiancloud.xml
- Start VM > virsh start 'Debian Cloud'
