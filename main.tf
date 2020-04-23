


locals {
  inventory_file = <<-EOT

    [frontend]
    %{for ip in var.frontend_hosts~}
    ${ip[0]} ansible_host=${ip[1]}
    %{endfor}

    [backend]
    %{for ip in var.backend_hosts~}
    ${ip[0]} ansible_host=${ip[1]} 
    %{endfor}
  EOT
}


resource "local_file" "ips" {
  filename = "${path.module}/ansible-data/inventory"
  content  = local.inventory_file
}



resource "null_resource" "ansible" {
  connection {
    bastion_host = var.bastion_host

    host = "172.16.2.11"
    #user = "root"

    #bastion_host_key = "${file("~/.ssh/ansible")}"

    #private_key = "${file("~/.ssh/ansible")}"
    private_key = var.ssh_private_key
  }

  triggers = {
    always_run = timestamp()
  }
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.module}/ansible-data/playbooks/site.yml"

        roles_path = [
          "${path.module}/ansible-data/roles",
        ]
      }
      verbose        = true
      inventory_file = "${path.module}/ansible-data/inventory"
    }

    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = var.insecure_no_strict_host_key_checking
      connect_timeout_seconds              = 60
    }
  }
}

variable "ssh_private_key" {
}

variable "insecure_no_strict_host_key_checking" {
  default = true
}

variable "bastion_host" {
  description = "Bastion host public IP address"
  default     = "52.116.128.158"
}

variable "frontend_hosts" {
  description = "List of private IP addresses of target hosts"
  default     = [["host0", "172.16.2.12"], ["host1", "172.16.0.10"]]
}

variable "backend_hosts" {
  description = "List of private IP addresses of target hosts"
  default     = [["host3", "172.17.0.10"]]
}
