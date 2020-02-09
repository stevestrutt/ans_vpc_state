resource "null_resource" "null01" {
  connection {
    bastion_host = "52.116.140.31"

    #host = "52.116.140.31"

    host = "172.22.192.6"
    user = "root"

    #private_key = "${file("~/.ssh/ansible")}"

    private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    script = "list.sh"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "ansible" {
    plays {
      playbook = {
        file_path = "${path.module}/ansible-data/playbooks/install-tree.yml"

        roles_path = [
          "${path.module}/ansible-data/roles",
        ]
      }

      verbose = true

      #inventory_file = "${path.module}/ansible-data/inventory"
    }

    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = "${var.insecure_no_strict_host_key_checking}"
      connect_timeout_seconds              = 30

      #ssh_args                             = "-o ControlPersist=30m -o ControlMaster=auto"
    }
  }
}

variable "insecure_no_strict_host_key_checking" {
  default = false
}

# variable "ssh_private_key" {
#   description = "private ssh key"
# }

