resource "random_password" "user_password" {
  length           = 16
  special          = false
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1  
  /* override_special = "!#$%&*()-_=+[]{}<>:?" */
}

resource "random_password" "root_password" {
  length           = 16
  special          = false
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1  
  /* override_special = "!#$%&*()-_=+[]{}<>:?" */
}

resource "random_string" "disk_encryptionkey" {
  length           = 16
  special          = false
  /* override_special = "/@£$" */
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

output "github_key" {
  value = tls_private_key.ssh.public_key_openssh
  sensitive = true
}

output "user_password" {
  value = random_password.user_password
  sensitive = true
}

output "root_password" {
  value = random_password.root_password
  sensitive = true
}

output "host_disk_encryptionkey" {
  value = random_string.disk_encryptionkey
  sensitive = true
}
