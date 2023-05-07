
###########################################################
# upload_audio_voice_drama_bucket
###########################################################
variable "upload_audio_voice_drama_bucket_keeper_id" {
  description = "この値を変更しない場合はバケットの再生成はされません"
  default     = "01"
}

resource "random_string" "upload_audio_voice_drama_bucket_random" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
  keepers = {
    resource_trigger = var.upload_audio_voice_drama_bucket_keeper_id
  }
}

# m4a音声ファイルをアップロードする公開バケット
resource "google_storage_bucket" "upload_audio_voice_drama_bucket" {
  name                        = "upload_audio_voice_drama_bucket_${random_string.upload_audio_voice_drama_bucket_random.id}"
  project                     = var.project_id
  public_access_prevention    = "inherited"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  location                    = var.region
}

# m4a音声ファイルをアップロードするバケットに対して公開アクセス許可
resource "google_storage_bucket_iam_binding" "upload_audio_voice_drama_bucket_public_binding" {
  bucket = google_storage_bucket.upload_audio_voice_drama_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers"
  ]

  depends_on = [
    google_storage_bucket.upload_audio_voice_drama_bucket
  ]
}

###########################################################
# tmp_audio_voice_drama_bucket
###########################################################
variable "tmp_audio_voice_drama_bucket_keeper_id" {
  description = "この値を変更しない場合はバケットの再生成はされません"
  default     = "01"
}
resource "random_string" "tmp_audio_voice_drama_bucket_random" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
  keepers = {
    resource_trigger = var.tmp_audio_voice_drama_bucket_keeper_id
  }
}

# 一時的に台詞のwavデータをアップロードするバケット
resource "google_storage_bucket" "tmp_audio_voice_drama_bucket" {
  name                        = "tmp_audio_voice_drama_bucket_${random_string.tmp_audio_voice_drama_bucket_random.id}"
  force_destroy               = true
  project                     = var.project_id
  public_access_prevention    = "inherited"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  location                    = var.region

  # 一日経過後に削除
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}

###########################################################
# cloud_function_script_zip_bucket
###########################################################
variable "cloud_function_script_zip_bucket_keeper_id" {
  description = "この値を変更しない場合はバケットの再生成はされません"
  default     = "01"
}

resource "random_string" "cloud_function_script_zip_bucket_random" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
  keepers = {
    resource_trigger = var.cloud_function_script_zip_bucket_keeper_id
  }
}

#関数のソースコードを保持するバケット
resource "google_storage_bucket" "cloud_function_script_zip_bucket" {
  name                        = "cloud_function_script_zip_${random_string.cloud_function_script_zip_bucket_random.id}"
  project                     = var.project_id
  public_access_prevention    = "inherited"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  location                    = var.region
}

resource "google_storage_bucket_object" "parse_openai_script_zip" {
  name   = "parse_openai_script_${var.function_parse_openai_script_version}.zip"
  bucket = google_storage_bucket.cloud_function_script_zip_bucket.name
  source = data.archive_file.parse_openai_script_zip.output_path
}

resource "google_storage_bucket_object" "get_audio_query_zip" {
  name   = "get_audio_query_${var.function_get_audio_query_version}.zip"
  bucket = google_storage_bucket.cloud_function_script_zip_bucket.name
  source = data.archive_file.get_audio_query_zip.output_path
}

resource "google_storage_bucket_object" "generate_audio_upload_tmp_zip" {
  name   = "generate_audio_upload_tmp_${var.function_generate_audio_upload_tmp_version}.zip"
  bucket = google_storage_bucket.cloud_function_script_zip_bucket.name
  source = data.archive_file.generate_audio_upload_tmp_zip.output_path
}

resource "google_storage_bucket_object" "concatenate_wav_translate_m4a_zip" {
  name   = "concatenate_wav_translate_m4a_${var.function_concatenate_wav_translate_m4a_version}.zip"
  bucket = google_storage_bucket.cloud_function_script_zip_bucket.name
  source = data.archive_file.concatenate_wav_translate_m4a_zip.output_path
}
