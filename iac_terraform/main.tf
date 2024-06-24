module "landing_data_bucket" {
  source = "./modules/s3"
  bucket_name = "pkr-youtube-landing-data-bucket"
  force_destroy = true
}

module "cleaned_data_bucket" {
  source = "./modules/s3"
  bucket_name = "pkr-youtube-cleaned-data-bucket"
  force_destroy = true
}

module "iam_lambda" {
    source = "./modules/iam/iam_lambda"
    lambda_function_name = "preprocess-landing-ref-statistics-youtube-data"   # Utilized just for deriving the role name
    lambda_glue_policy_name = "pkr-youtube-lambda-custom-policy"
}

module "iam_glue" {
    source = "./modules/iam/iam_glue"
    glue_role_name = "pkr-youtube-glue-role"
    glue_custom_policy_name = "pkr-youtube-glue-custom-policy"
    # raw_bucket_name = module.landing_data_bucket.created_bucket_name
}

module "glue_catalog_landing_db" {
    source = "./modules/glue/glue_catalog_db"
    catalog_db_name = "pkr_youtube_landing_db"
}

module "glue_catalog_cleaned_db" {
    source = "./modules/glue/glue_catalog_db"
    catalog_db_name = "pkr_youtube_cleaned_db"
}

# module "lambda_function_bucket" {
#   source = "./modules/s3"
#   bucket_name = "pkr-youtube-analytics-lambda-bucket"
#   force_destroy = true
# }

module "lambda_function_to_process_raw_ref" {
  source = "./modules/lambda"
  lambda_function_name = "preprocess-raw-ref-youtube-data"
  lambda_iam_role_arn = module.iam_lambda.lambda_role_arn
  lambda_handler = "lambda_function.lambda_handler"
  lambda_runtime = "python3.9"
  lambda_memory_size = 256
  lambda_timeout = 210
  lambda_filename = "../lambda_code_only.zip"

  s3_cleansed_data_bucket_name = module.cleaned_data_bucket.created_bucket_name
  s3_key = "category_ref/"
  glue_catalog_db_name = module.glue_catalog_cleaned_db.catalog_db_name
  glue_catalog_table_name = "ref_category"
  write_operation_type = "append"
  s3_bucket_arn = module.landing_data_bucket.s3_bucket_arn
  s3_bucket_id = module.landing_data_bucket.s3_bucket_id
  lambda_layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSDataWrangler-Python39:1"]
  # lambda_bucket_name = module.lambda_function_bucket.created_bucket_name
  # lambda_bucket_key = "preprocess_ref_stats.zip"

}

# crawler for raw_statistics and run crawler
module "raw_statistic_crawler" {
  source = "./modules/glue/glue_crawler"
  crawler_name = "youtube_raw_statistics_landing_crawler"
  crawler_role_arn = module.iam_glue.glue_role_arn
  catalog_db_name =  module.glue_catalog_landing_db.catalog_db_name
  s3_bucket_path = "s3://${module.landing_data_bucket.created_bucket_name}/raw_statistics/"
  # table_prefix = "raw_statistics_"
  # crawler_schedule = "cron(0 12 * * ? *)"

}

# create s3 bucket for the glue scripts
module "glue_scripts_s3_bucket" {
  source = "./modules/s3"
  bucket_name = "glue-scripts-bucket-youtube-data"
  force_destroy = true
}

# write etl for schema change and write it to cleaned bucket in parquet format
module "schema_change_etl_raw_statistics" {
  source = "./modules/glue/glue_scripts"
  bucket_name = module.glue_scripts_s3_bucket.created_bucket_name
  bucket_key = "scripts/youtube_raw_stats_csv_to_parquet.py"
  role_arn = module.iam_glue.glue_role_arn
  glue_job_name = "youtube_raw_stats_csv_to_parquet_job"
  glue_script_local_path = "../glue_scripts/youtube_raw_stats_csv_to_parquet.py"
  max_capacity = 2
  max_retries = 0
  timeout = 3
}

# crawler for the new parquet format
module "cleaned_statistic_crawler" {
  source = "./modules/glue/glue_crawler"
  crawler_name = "youtube_cleaned_raw_statistics_crawler"
  crawler_role_arn = module.iam_glue.glue_role_arn
  catalog_db_name =  module.glue_catalog_cleaned_db.catalog_db_name
  s3_bucket_path = "s3://${module.cleaned_data_bucket.created_bucket_name}/raw_statistics/"
  # crawler_schedule = "cron(0 12 * * ? *)"

}

# create bucket for analytical layer
module "anlytical_bucket" {
  source = "./modules/s3"
  bucket_name = "pkr-youtube-analytical-bucket"
  force_destroy = true
}

module "glue_catalog_analylical_db" {
    source = "./modules/glue/glue_catalog_db"
    catalog_db_name = "pkr_youtube_analytics_db"
}

# etl script for analytical bucket
module "analytical_layer_etl" {
  source = "./modules/glue/glue_scripts"
  bucket_name = module.glue_scripts_s3_bucket.created_bucket_name
  role_arn = module.iam_glue.glue_role_arn
  bucket_key = "scripts/youtube_analytical_layer_etl.py"
  glue_job_name = "youtube_analytical_layer_job"
  glue_script_local_path = "../glue_scripts/youtube_analytical_layer_etl.py"
  max_capacity = 2
  max_retries = 0
  timeout = 3
}


