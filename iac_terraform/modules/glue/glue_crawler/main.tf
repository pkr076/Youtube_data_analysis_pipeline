resource "aws_glue_crawler" "crawler" {
  name         = var.crawler_name
  role         = var.crawler_role_arn
  database_name = var.catalog_db_name

  s3_target {
    path = var.s3_bucket_path
  }

  # table_prefix = var.table_prefix

  # schedule = var.crawler_schedule

}