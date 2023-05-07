resource "google_cloud_scheduler_job" "voicevox_audio_scheduler" {
  project          = var.project_id
  name             = "voicevox_audio_scheduler"
  description      = "毎日12時にボイスドラマ自動生成システムのワークフローを実行する"
  schedule         = "0 12 * * *"
  time_zone        = "Asia/Tokyo"
  attempt_deadline = "1800s"

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.voice_drama_workflow.id}/executions"
    body        = base64encode("{\"argument\":\"{\\\"is_post_messages_line_bot\\\": 1}\"}")

    oauth_token {
      service_account_email = google_service_account.voicevox_audio_scheduler_service_account.email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
  depends_on = [
    google_project_service.cloudscheduler_api
  ]
}

resource "google_service_account" "voicevox_audio_scheduler_service_account" {
  project      = var.project_id
  account_id   = "voicevox-audio-scheduler"
  display_name = "CloudScheduler/voicevox_audio_scheduler"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_project_iam_member" "voicevox_audio_scheduler_service_account_cloud_functions_invoker" {
  project = var.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.voicevox_audio_scheduler_service_account.email}"
}
