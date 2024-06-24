variable "bucket_name" {
  type = string
}

variable "bucket_key" {
    type = string
}

variable "glue_script_local_path" {
    type = string
}

variable "glue_job_name" {
    type = string
}

# variable "glue_job_script_location" {
#     type = string
# }

variable "role_arn" {
  type = string
}

variable "max_retries" {
    type = number
}

variable "timeout" {
    type = number
}

variable "max_capacity" {
  type = number
}