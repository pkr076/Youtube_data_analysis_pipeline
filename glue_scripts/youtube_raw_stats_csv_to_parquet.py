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

glue_df_landing_raw_statistics = glueContext.create_dynamic_frame.from_catalog(database="pkr_youtube_landing_db", table_name="raw_statistics", transformation_ctx="glue_df_landing_raw_statistics")
ChangeSchema_landing_raw_statistics = ApplyMapping.apply(frame=glue_df_landing_raw_statistics, mappings=[("video_id", "string", "video_id", "string"), ("trending_date", "string", "trending_date", "string"), ("title", "string", "title", "string"), ("channel_title", "string", "channel_title", "string"), ("category_id", "long", "category_id", "bigint"), ("publish_time", "string", "publish_time", "string"), ("tags", "string", "tags", "string"), ("views", "long", "views", "bigint"), ("likes", "long", "likes", "bigint"), ("dislikes", "long", "dislikes", "bigint"), ("comment_count", "long", "comment_count", "bigint"), ("thumbnail_link", "string", "thumbnail_link", "string"), ("comments_disabled", "boolean", "comments_disabled", "boolean"), ("ratings_disabled", "boolean", "ratings_disabled", "boolean"), ("video_error_or_removed", "boolean", "video_error_or_removed", "boolean"), ("description", "string", "description", "string"), ("region", "string", "region", "string")], transformation_ctx="ChangeSchema_landing_raw_statistics")
write_parquet_to_s3 = glueContext.write_dynamic_frame.from_options(frame=ChangeSchema_landing_raw_statistics, connection_type="s3", format="glueparquet", connection_options={"path": "s3://pkr-youtube-cleaned-data-bucket/raw_statistics/", "partitionKeys": ["region"]}, format_options={"compression": "snappy"}, transformation_ctx="write_parquet_to_s3")
job.commit()