resource "google_secret_manager_secret" "line_channel_access_tokens" {
  replication {
    automatic = true
  }
  depends_on = [
    google_project_service.secretmanager_api
  ]
  project      = var.project_id
  secret_id = "line_channel_access_tokens"
}

resource "google_secret_manager_secret_version" "line_channel_access_tokens_latest_version" {
  secret = google_secret_manager_secret.line_channel_access_tokens.id
  
  secret_data = var.line_channel_access_tokens
}

resource "google_secret_manager_secret" "open_ai_api_key" {
  project      = var.project_id
  replication {
    automatic = true
  }
  depends_on = [
    google_project_service.secretmanager_api
  ]
  secret_id = "open_ai_api_key"
}

resource "google_secret_manager_secret_version" "open_ai_api_key_latest_version" {
  secret = google_secret_manager_secret.open_ai_api_key.id

  secret_data = var.open_ai_api_key
}