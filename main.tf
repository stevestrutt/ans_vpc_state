resource "null_resource" "null01" {
  triggers = {
    always_run = "${timestamp()}"
  }

  connection {
    bastion_host = "52.116.140.31"
    host         = "172.22.192.8"
    user         = "root"
    private_key  = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    script = "list.sh"
  }

  provisioner "ansible" {
    plays {
      playbook = {
        file_path = "${path.module}/ansible-data/playbooks/install-tree.yml"

        roles_path = [
          "${path.module}/ansible-data/roles",
        ]
      }

      #inventory_file = "${path.module}/ansible-data/inventory"
    }

    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = "${var.insecure_no_strict_host_key_checking}"
    }
  }
}

variable "insecure_no_strict_host_key_checking" {
  default = false
}

variable "ssh_private_key" {
  description = "private ssh key"
}
