resource "google_service_account" "voice_drama_workflow_service_account" {
  project      = var.project_id
  account_id   = "voice-drama-workflow"
  display_name = "CloudWorkflows/voice-drama-workflow"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_project_iam_member" "voice_drama_workflow_service_account_cloud_functions_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.voice_drama_workflow_service_account.email}"
}

resource "google_project_iam_member" "voice_drama_workflow_service_account_secretmanager_secretAccessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.voice_drama_workflow_service_account.email}"
}

resource "google_project_iam_member" "voice_drama_workflow_service_account_serviceusage_serviceUsageConsumer" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.voice_drama_workflow_service_account.email}"
}

resource "google_project_iam_member" "voice_drama_workflow_service_account_logging_logWriter" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.voice_drama_workflow_service_account.email}"
}

resource "google_workflows_workflow" "voice_drama_workflow" {
  project         = var.project_id
  name            = "voice-drama-workflow"
  region          = var.region
  description     = "ボイスドラマ自動生成システムのワークフロー"
  service_account = google_service_account.voice_drama_workflow_service_account.id
  source_contents = file("${path.module}/src/cloud_workflows/voice-drama-workflow.yaml")
  depends_on = [
    google_project_service.workflows_api
  ]
}