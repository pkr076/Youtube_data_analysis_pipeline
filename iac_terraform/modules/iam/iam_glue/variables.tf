variable "glue_role_name" {
    type = string
    description = "Glue role name for accessing s3 bucket for youtube data analysis"
}

# variable "raw_bucket_name" {
#   type = string
#   description = "s3 bucket with raw youtube data"
# }

variable "glue_custom_policy_name" {
    type = string
    description = "custom policy for accessing s3 bucket"
}
