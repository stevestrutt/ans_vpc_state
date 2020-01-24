resource "ibm_compute_ssh_key" "ssh_key" {
  label      = "${var.ssh_label}"
  notes      = "${var.ssh_notes}"
  public_key = "${var.ssh_key}"
}


resource "null_resource" "null01" {
  
  connection {
    user = "root"
    host = "host"
  }
  provisioner "ansible" {
    plays {
      playbook = {
        file_path = "${path.module}/ansible-data/playbooks/install-tree.yml"
        roles_path = [
            "${path.module}/ansible-data/roles"
        ]
      }
      groups = ["webserver"]
      inventory_file = "${path.module}/ansible-data/inventory"
    }
    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = "${var.insecure_no_strict_host_key_checking}"
    }
  }    



}



variable "insecure_no_strict_host_key_checking" {
  default = false
}


      
