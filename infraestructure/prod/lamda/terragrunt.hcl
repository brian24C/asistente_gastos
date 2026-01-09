terraform {
  source = "../../modules/lambda_function"
}

inputs = {
  function_name = "asistente-gastos"
  image_uri     = "<AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/asistente-gastos:v1.0.0"
  
  # Variables de entorno requeridas por el módulo
  # Obtén estos valores de tu archivo .env o de AWS Secrets Manager
  telegram_bot_token      = get_env("TELEGRAM_BOT_TOKEN", "")
  gemini_api_key          = get_env("GEMINI_API_KEY", "")
  google_sheet_id         = get_env("GOOGLE_SHEET_ID", "")
  google_credentials_json = get_env("GOOGLE_CREDENTIALS_JSON", "")
}
