variable "project_id" {
  type    = string
  default = "cloud-devops-447407"
}

variable "region" {
  type    = string
  default = "europe-west9"
}


# Configure Packer builder for Google Cloud
source "googlecompute" "imgpck" {
  project_id        = var.project_id
  zone              = "europe-west9-b"
  machine_type      = "e2-medium"
  source_image_family = "ubuntu-2004-lts"
  image_name        = "imgpck"
  image_family      = "lamp-stack"
  ssh_username      = "root"
}

# Provisioner for using Ansible
build {
  sources = ["source.googlecompute.imgpck"]

  provisioner "ansible" {
    playbook_file = "ansible.yml"  # Chemin relatif vers le fichier Ansible
    extra_arguments = [
      "-vvvv",
      "-e", "project_id=${var.project_id}",
      "-e", "region=${var.region}"
    ]
  }
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}
