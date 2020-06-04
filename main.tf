# provider block required with Schematics to set VPC region
provider "ibm" {
  # ibmcloud_api_key = var.ibmcloud_api_key
  version = "~> 1.5.3"
}


data "ibm_schematics_workspace" "vpc" {
  workspace_id = var.workspace_id
}

data "ibm_schematics_output" "vpc" {
  workspace_id = var.workspace_id
  template_id  = "${data.ibm_schematics_workspace.vpc.template_id.0}"
}

data "ibm_schematics_state" "vpc" {
  workspace_id = var.workspace_id
  template_id  = "${data.ibm_schematics_workspace.vpc.template_id.0}"
}


resource "local_file" "terraform_source_state" {
  filename          = "${path.module}/ansible-data/schematics.tfstate"
  sensitive_content = data.ibm_schematics_state.vpc.state_store_json

}


# resource "null_resource" "ls" {
#   triggers = {
#     always_run = timestamp()
#   }
#   provisioner "local-exec" {
#     command = "cat ${path.module}/ansible-data/inventory.txt"
#   }
# }

# output "vpc_output" {
#   value = data.ibm_schematics_output.vpc
# }



output "vpc_bastions" {
  value = data.ibm_schematics_output.vpc.output_values["bastion_host_ip_address"]

}

# output "file_read" {
#   value = data.local_file.input
# }



# resource "local_file" "ips" {
#   filename = "${path.module}/ansible-data/inventory.txt"
#   content  = local.inventory_file
# }

# data "local_file" "input" {
#   filename   = "${path.module}/ansible-data/inventory.txt"
#   depends_on = [local_file.ips]
# }


# resource "null_resource" "ls1" {
#   triggers = {
#     always_run = timestamp()
#   }
#   provisioner "local-exec" {
#     command = "ls -al ${path.module}/ansible-data/inventory.txt"
#   }
#   depends_on = [local_file.ips]
# }




resource "null_resource" "ansible" {
  connection {
    bastion_host = var.bastion_host

    host = "0.0.0.0"
    #user = "root"

    #bastion_host_key = "${file("~/.ssh/ansible")}"

    private_key = "${file("~/.ssh/ansible")}"
    #private_key = var.ssh_private_key
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
      inventory_file = "${path.module}/terraform_inv.py"
    }

    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = true
      connect_timeout_seconds              = 60
    }
  }
  depends_on = [local_file.terraform_source_state]
}

# variable "ssh_private_key" {
# }


# variable "ibmcloud_api_key" {
#   description = "IBM Cloud API key when run standalone"
# }

variable "workspace_id" {
  description = "Id of the source Schematics Workspace for target VSIs"
  default     = "ssh_bastion-host-0353ce37-3748-4c"
}

variable "bastion_host" {
  description = "Bastion host public IP address"
  default     = "52.116.128.217"
}

# variable "frontend_hosts" {
#   type        = list(list(string))
#   description = "List of private IP addresses of target hosts"
#   default     = [["host1", "172.16.0.5"], ["host2", "172.16.2.5"]]
# }

# variable "backend_hosts" {
#   type        = list(list(string))
#   description = "List of private IP addresses of target hosts"
#   default     = [["host4", "172.17.0.4"]]
# }
