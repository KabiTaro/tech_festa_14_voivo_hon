###########################################################
# parse_openai_script 
###########################################################
variable "function_parse_openai_script_version" {
  description = "parse_openai_script関数のバージョン"
  default     = "01"
}

data "archive_file" "parse_openai_script_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/cloud_functions/parse_openai_script"
  output_path = "${path.module}/output/cloud_functions/parse_openai_script/parse_openai_script_${var.function_parse_openai_script_version}.zip"
}

resource "google_service_account" "parse_openai_script_service_account" {
  project      = var.project_id
  account_id   = "parse-openai-script"
  display_name = "CloudFunctions/parse_openai_script"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_cloudfunctions_function" "parse_openai_script" {
  name                         = "parse_openai_script"
  description                  = "Open AIのテキストをプログラムで扱えるように構造体に変換する"
  runtime                      = "python39"
  project                      = var.project_id
  source_archive_bucket        = google_storage_bucket.cloud_function_script_zip_bucket.name
  source_archive_object        = google_storage_bucket_object.parse_openai_script_zip.name
  min_instances                = 0
  max_instances                = 10
  https_trigger_security_level = "SECURE_ALWAYS"
  available_memory_mb          = 256
  entry_point                  = "main"
  trigger_http                 = true
  service_account_email        = google_service_account.parse_openai_script_service_account.email
  depends_on = [
    google_project_service.cloudfunctions_api
  ]
}


###########################################################
# get_audio_query  
###########################################################
variable "function_get_audio_query_version" {
  description = "get_audio_query関数のバージョン"
  default     = "01"
}

data "archive_file" "get_audio_query_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/cloud_functions/get_audio_query"
  output_path = "${path.module}/output/cloud_functions/get_audio_query/get_audio_query_${var.function_get_audio_query_version}.zip"
}

resource "google_service_account" "get_audio_query_service_account" {
  project      = var.project_id
  account_id   = "get-audio-query"
  display_name = "CloudFunctions/get_audio_query"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_project_iam_member" "get_audio_query_service_account_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.get_audio_query_service_account.email}"
}

resource "google_cloudfunctions_function" "get_audio_query" {
  name                         = "get_audio_query"
  description                  = "リクエストパラメータのテキストを基にCloud RunにデプロイしたVOICEVOX ENGINEから音声ファイルを取得する"
  runtime                      = "python39"
  project                      = var.project_id
  source_archive_bucket        = google_storage_bucket.cloud_function_script_zip_bucket.name
  source_archive_object        = google_storage_bucket_object.get_audio_query_zip.name
  min_instances                = 0
  max_instances                = 10
  https_trigger_security_level = "SECURE_ALWAYS"
  available_memory_mb          = 256
  entry_point                  = "main"
  trigger_http                 = true
  service_account_email        = google_service_account.get_audio_query_service_account.email
  environment_variables = {
    CLOUD_RUN_URL = google_cloud_run_service.voicevox_engine.status[0].url
  }
  depends_on = [
    google_project_service.cloudfunctions_api
  ]
}

###########################################################
# generate_audio_upload_tmp 
###########################################################
variable "function_generate_audio_upload_tmp_version" {
  description = "generate_audio_upload_tmp関数のバージョン"
  default     = "01"
}

data "archive_file" "generate_audio_upload_tmp_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/cloud_functions/generate_audio_upload_tmp"
  output_path = "${path.module}/output/cloud_functions/generate_audio_upload_tmp/generate_audio_upload_tmp_${var.function_generate_audio_upload_tmp_version}.zip"
}

resource "google_service_account" "generate_audio_upload_tmp_service_account" {
  project = var.project_id
  depends_on = [
    google_project_service.iam_api
  ]
  account_id   = "generate-audio-upload-tmp"
  display_name = "CloudFunctions/generate_audio_upload_tmp"
}

resource "google_project_iam_member" "generate_audio_upload_tmp_service_account_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.generate_audio_upload_tmp_service_account.email}"
}

resource "google_project_iam_member" "generate_audio_upload_tmp_service_account_storage_objectCreator" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.generate_audio_upload_tmp_service_account.email}"
}

resource "google_cloudfunctions_function" "generate_audio_upload_tmp" {
  name                         = "generate_audio_upload_tmp"
  description                  = "クエリを基にVOICEVOX ENGINEで音声合成を実行し、Tmpバケットに投下する"
  runtime                      = "python39"
  project                      = var.project_id
  source_archive_bucket        = google_storage_bucket.cloud_function_script_zip_bucket.name
  source_archive_object        = google_storage_bucket_object.generate_audio_upload_tmp_zip.name
  min_instances                = 0
  max_instances                = 10
  https_trigger_security_level = "SECURE_ALWAYS"
  available_memory_mb          = 256
  entry_point                  = "main"
  trigger_http                 = true
  service_account_email        = google_service_account.generate_audio_upload_tmp_service_account.email
  environment_variables = {
    CLOUD_RUN_URL       = google_cloud_run_service.voicevox_engine.status[0].url
    TEMP_STORAGE_BUCKET = google_storage_bucket.tmp_audio_voice_drama_bucket.name
  }
  depends_on = [
    google_project_service.cloudfunctions_api
  ]
}

###########################################################
# concatenate_wav_translate_m4a
###########################################################
variable "function_concatenate_wav_translate_m4a_version" {
  description = "concatenate_wav_translate_m4a関数のバージョン"
  default     = "01"
}

data "archive_file" "concatenate_wav_translate_m4a_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/cloud_functions/concatenate_wav_translate_m4a"
  output_path = "${path.module}/output/cloud_functions/concatenate_wav_translate_m4a/concatenate_wav_translate_m4a_${var.function_concatenate_wav_translate_m4a_version}.zip"
}

resource "google_service_account" "concatenate_wav_translate_m4a_service_account" {
  project = var.project_id
  depends_on = [
    google_project_service.iam_api
  ]
  account_id   = "concatenate-wav-translate-m4a"
  display_name = "CloudFunctions/concatenate_wav_translate_m4a"
}

resource "google_project_iam_member" "concatenate_wav_translate_m4a_service_account_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.concatenate_wav_translate_m4a_service_account.email}"
}

resource "google_project_iam_member" "concatenate_wav_translate_m4a_service_account_storage_objectCreator" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.concatenate_wav_translate_m4a_service_account.email}"
}

resource "google_project_iam_member" "concatenate_wav_translate_m4a_service_account_storage_objectViewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.concatenate_wav_translate_m4a_service_account.email}"
}

resource "google_cloudfunctions_function" "concatenate_wav_translate_m4a" {
  name                         = "concatenate_wav_translate_m4a"
  description                  = "Tmpバケットに投下したwavファイルをVOICEVOX ENGINEで結合し、FFmpegでwavデータをm4aデータに変換して公開バケットに投下してそのオブジェクトの公開URLを取得する"
  runtime                      = "python39"
  project                      = var.project_id
  source_archive_bucket        = google_storage_bucket.cloud_function_script_zip_bucket.name
  source_archive_object        = google_storage_bucket_object.concatenate_wav_translate_m4a_zip.name
  min_instances                = 0
  max_instances                = 10
  https_trigger_security_level = "SECURE_ALWAYS"
  available_memory_mb          = 256
  entry_point                  = "main"
  trigger_http                 = true
  service_account_email        = google_service_account.concatenate_wav_translate_m4a_service_account.email
  environment_variables = {
    CLOUD_RUN_URL         = google_cloud_run_service.voicevox_engine.status[0].url
    UPLOAD_STORAGE_BUCKET = google_storage_bucket.upload_audio_voice_drama_bucket.name
    TEMP_STORAGE_BUCKET   = google_storage_bucket.tmp_audio_voice_drama_bucket.name
  }
  depends_on = [
    google_project_service.cloudfunctions_api
  ]
}
