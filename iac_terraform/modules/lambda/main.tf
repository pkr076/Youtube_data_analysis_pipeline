resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  role          = var.lambda_iam_role_arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size
  filename = var.lambda_filename
  source_code_hash = filebase64sha256(var.lambda_filename)

  layers = var.lambda_layers

  environment {
    variables = {
      s3_cleansed_data_bucket = var.s3_cleansed_data_bucket_name
      s3_key = var.s3_key
      glue_catalog_db_name = var.glue_catalog_db_name
      glue_catalog_table_name = var.glue_catalog_table_name
      write_data_operation = var.write_operation_type
    }
  }
}

# resource "aws_lambda_function" "large_lambda" {
#   function_name = var.lambda_function_name
#   handler       = var.lambda_handler
#   runtime       = var.lambda_runtime
#   role          = var.lambda_iam_role_arn
#   timeout = var.lambda_timeout
#   memory_size = var.lambda_memory_size

#   environment {
#     variables = {
#       s3_cleansed_data_bucket = var.s3_cleansed_data_bucket_name
#       s3_key = var.s3_key
#       glue_catalog_db_name = var.glue_catalog_db_name
#       glue_catalog_table_name = var.glue_catalog_table_name
#       write_data_operation = var.write_operation_type
#     }
#   }

#   s3_bucket     = var.lambda_bucket_name
#   s3_key        = var.lambda_bucket_key
# }

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "category_ref/"
  } 
  depends_on = [aws_lambda_permission.allow_s3_to_invoke_lambda]
}
