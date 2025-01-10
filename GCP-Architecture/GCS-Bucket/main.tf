# main.tf
# Terraform pour le bucket GCS des Terraform States
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "terraform_states" {
  name          = "${var.project_id}-terraform-states"
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }

  versioning {
    enabled = true
  }
}
