resource "google_cloud_run_service" "voicevox_engine" {
  name     = "voicevox-engine-run"
  location = var.region
  project  = var.project_id

  metadata {
    annotations = {
      "run.googleapis.com/ingress" : "all"
      "run.googleapis.com/ingress-status" : "all"
    }
  }

  template {
    spec {
      container_concurrency = 80
      timeout_seconds       = 3600
      service_account_name  = google_service_account.voicevox_engine_service_account.email
      containers {
        image = "docker.io/voicevox/voicevox_engine@sha256:88415e1c4e9dfece31b3080a301718f70ef7808ba1626c22a3db3d32234bb35e"

        resources {
          limits = {
            cpu    = "1000m"
            memory = "4Gi"
          }
        }

        ports {
          container_port = 50021
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  
  depends_on = [
    google_project_service.cloud_run_api
  ]
}

resource "google_service_account" "voicevox_engine_service_account" {
  project      = var.project_id
  account_id   = "voicevox-engine"
  display_name = "CloudRun/voicevox_engine"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_project_iam_member" "voicevox_engine_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.voicevox_engine_service_account.email}"
}
