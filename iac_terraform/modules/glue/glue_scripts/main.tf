resource "aws_s3_object" "glue_etl_script_location" {
  bucket = var.bucket_name
  key    = var.bucket_key
  source = var.glue_script_local_path
  etag = filebase64sha256(var.glue_script_local_path) # This line ensures that the S3 object is updated whenever the content of the local script file changes.
}

resource "aws_glue_job" "my_etl_job" {
  name     = var.glue_job_name
  role_arn = var.role_arn

  command {
    script_location = "s3://${var.bucket_name}/${var.bucket_key}"            #var.glue_job_script_location
    name            = "glueetl"
    python_version = "3"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "glue_version" = "4.0"
  }

  max_retries = var.max_retries
  timeout     = var.timeout  # Timeout in minutes
  max_capacity = var.max_capacity  # Number of DPUs allocated to this job
}