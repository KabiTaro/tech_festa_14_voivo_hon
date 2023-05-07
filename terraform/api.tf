resource "google_project_service" "cloudresourcemanager_api" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "cloud_run_api" {
  project = var.project_id
  service = "run.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "secretmanager_api" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "cloudfunctions_api" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "cloudscheduler_api" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "language_api" {
  project = var.project_id
  service = "language.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "workflowexecutions_api" {
  project = var.project_id
  service = "workflowexecutions.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "workflows_api" {
  project = var.project_id
  service = "workflows.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}


resource "google_project_service" "cloudbuild_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
  disable_on_destroy         = true
}
