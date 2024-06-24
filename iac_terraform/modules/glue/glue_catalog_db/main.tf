resource "aws_glue_catalog_database" "catalog_db" {
  name = var.catalog_db_name
  description = "Example Glue Catalog Database"
}
