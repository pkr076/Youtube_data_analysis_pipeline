import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# glue_df_cleaned_raw_statistics , pkr_youtube_cleaned_db.raw_statistics

glue_df_cleaned_raw_statistics = glueContext.create_dynamic_frame.from_catalog(database="pkr_youtube_cleaned_db", table_name="raw_statistics", transformation_ctx="glue_df_cleaned_raw_statistics")

# glue_df_cleaned_ref_category , pkr_youtube_cleaned_db.ref_category
glue_df_cleaned_ref_category = glueContext.create_dynamic_frame.from_catalog(database="pkr_youtube_cleaned_db", table_name="ref_category", transformation_ctx="glue_df_cleaned_ref_category")

# Script generated for node Join
glue_joined_df = Join.apply(frame1=glue_df_cleaned_raw_statistics, frame2=glue_df_cleaned_ref_category, keys1=["category_id"], keys2=["id"], transformation_ctx="glue_joined_df")

# Script generated for node Amazon S3  aws_s3_sink
aws_s3_sink = glueContext.getSink(path="s3://pkr-youtube-analytical-bucket", connection_type="s3", updateBehavior="UPDATE_IN_DATABASE", partitionKeys=["region", "category_id"], enableUpdateCatalog=True, transformation_ctx="aws_s3_sink")
aws_s3_sink.setCatalogInfo(catalogDatabase="pkr_youtube_analytics_db",catalogTableName="final_analytics")
aws_s3_sink.setFormat("glueparquet", compression="snappy")
aws_s3_sink.writeFrame(glue_joined_df)
job.commit()