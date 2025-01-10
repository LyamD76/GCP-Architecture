
# variables.tf
variable "project_id" {
  description = "ID du projet Google Cloud"
  default     = "devops-ops-447407"
}

variable "region" {
  description = "Région pour les ressources GCP"
  default     = "europe-west9"
}
