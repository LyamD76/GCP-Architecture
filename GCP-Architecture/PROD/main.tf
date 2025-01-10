provider "google" {
  project = "devops-prod"
  region  = "europe-west9"
}

# VPC
resource "google_compute_network" "main_vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks  = false
}

# Sous-réseau standard dans Paris
resource "google_compute_subnetwork" "main_subnet" {
  name          = "main-subnet"
  network       = google_compute_network.main_vpc.id
  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-west9"
}

# Sous-réseau Load Balancer Only
resource "google_compute_subnetwork" "lb_subnet" {
  name          = "lb-subnet"
  network       = google_compute_network.main_vpc.id
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west9"
}

# Bucket GCS public
resource "google_storage_bucket" "static_files" {
  name          = "my-static-bucket"
  location      = "EU"
  website       = {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  uniform_bucket_level_access = true
}

# Instance Template pour le MIG
resource "google_compute_instance_template" "app_instance_template" {
  name         = "app-instance-template"
  machine_type = "n1-standard-1"
  region       = "europe-west9"

  disk {
    source_image = "projects/devops-prod/global/images/imgpck"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.main_vpc.name
    subnetwork = google_compute_subnetwork.main_subnet.name
    access_config {
      // Pour permettre l'accès externe
    }
  }
}

# Managed Instance Group (MIG)
resource "google_compute_instance_group_manager" "app_mig" {
  name                    = "app-mig"
  base_instance_name       = "app-instance"
  instance_template        = google_compute_instance_template.app_instance_template.id
  zone                    = "europe-west9-b"
  target_pools            = []
  distribution_policy {
    zones = ["europe-west9-b"]
  }
  named_port {
    name = "http"
    port = 80
  }
}

# Load Balancer régional
resource "google_compute_forwarding_rule" "lb_forwarding_rule" {
  name        = "app-forwarding-rule"
  region      = "europe-west9"
  ip_address  = google_compute_address.lb_ip.address
  target      = google_compute_backend_service.lb_backend_service.id
  port_range  = "80"
}

resource "google_compute_address" "lb_ip" {
  name   = "lb-ip"
  region = "europe-west9"
}

resource "google_compute_backend_service" "lb_backend_service" {
  name        = "lb-backend-service"
  region      = "europe-west9"
  protocol    = "HTTP"
  backends {
    group = google_compute_instance_group_manager.app_mig.instance_group
  }
}

resource "google_compute_url_map" "lb_url_map" {
  name            = "lb-url-map"
  default_service = google_compute_backend_service.lb_backend_service.id
}

# Zone DNS (Cloud DNS)
resource "google_dns_managed_zone" "main_dns_zone" {
  name        = "my-dns-zone"
  dns_name    = "example.com."
  description = "Managed DNS Zone for example.com"
}

resource "google_dns_record_set" "main_dns_record" {
  name            = "www.example.com."
  type            = "A"
  ttl             = 300
  managed_zone    = google_dns_managed_zone.main_dns_zone.name
  rrdatas         = [google_compute_address.lb_ip.address]
}

# Dashboard Cloud Monitoring
resource "google_monitoring_dashboard" "app_dashboard" {
  dashboard {
    display_name = "App Monitoring Dashboard"
    widgets {
      title = "Traffic from Load Balancer"
      xy_chart {
        data_sets {
          time_series_query {
            time_series_filter {
              filter = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\""
              aggregation {
                alignment_period {
                  seconds = "60"
                }
                per_series_aligner = "ALIGN_RATE"
              }
            }
          }
        }
      }
      title = "MIG CPU/RAM Metrics"
      xy_chart {
        data_sets {
          time_series_query {
            time_series_filter {
              filter = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\""
              aggregation {
                alignment_period {
                  seconds = "60"
                }
                per_series_aligner = "ALIGN_RATE"
              }
            }
          }
        }
      }
    }
  }
}
