variable "project_id" {
  description = "プロジェクトID"
}

variable "line_channel_access_tokens" {
  description = "(SecretManager)LINE チャネルアクセストークン"
}

variable "open_ai_api_key" {
  description = "(SecretManager)OpenAI APIキー"
}

variable "region" {
  description = "デフォルトのリージョン"
  default     = "asia-northeast1"
}
