variable "lambda_function_name" {
  type = string
}

variable "lambda_iam_role_arn" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_runtime" {
  type = string
}

variable "lambda_timeout" {
  type = number
}

variable "lambda_memory_size" {
  type = number
}

variable "lambda_filename" {
  type = string
}

variable "s3_cleansed_data_bucket_name" {
  type = string
}

variable "s3_key" {
  type = string
}

variable "glue_catalog_db_name" {
  type = string
}

variable "glue_catalog_table_name" {
  type = string
}

variable "write_operation_type" {
  type = string
}

variable "lambda_layers" {
  type = list(string)
}

variable "s3_bucket_arn" {
  type = string
}

variable "s3_bucket_id" {
  type = string
}

# variable "lambda_bucket_key" {
#   type = string
# }

# variable "lambda_bucket_name" {
#   type = string
# }