terraform {
  source = "../../modules/lambda_function"
}

inputs = {
  function_name = "asistente-gastos"
  image_uri     = "<AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/asistente-gastos:v1.0.0"
}
