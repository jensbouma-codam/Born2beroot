variable "username_42" {
  type = string
  description = "42 username"
}

variable "hostname_postfix" {
  type = string
  default = "4"
  description = "The postfix of the hostname"
}

variable "hostname_increment" {
  type = string
  default = 2
  description = "The postfix increment defaults on 2 because we have to print the number 42 in the beginning"
}

variable "image_name" {
  type = string
  description = "URL of the cloud image to run"
}

variable "system_username" {
  type = string
  description = "system username"
}

variable "TERRAFORM_LIBVIRT_TEST_DOMAIN_TYPE" {
  type = string
  default = "qemu"
  description = "set qemu as default emulator"
}