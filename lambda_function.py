import awswrangler as wr
import pandas as pd
import urllib.parse
import os

s3_cleansed_data_bucket = os.environ['s3_cleansed_data_bucket']
s3_key = os.environ['s3_key']
glue_catalog_db_name = os.environ['glue_catalog_db_name']
glue_catalog_table_name = os.environ['glue_catalog_table_name']
write_data_operation = os.environ['write_data_operation']

file_path = f's3://{s3_cleansed_data_bucket}/{s3_key}'

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    try:
        raw_df = wr.s3.read_json(f's3://{bucket}/{key}')
        print("read the json file")
        # Extract items column
        df_items = pd.json_normalize(raw_df['items'])
        print("after json normalize")
        wr_response = wr.s3.to_parquet( df=df_items,
                                        path=f"s3://{s3_cleansed_data_bucket}/{s3_key}",
                                        dataset=True,
                                        database=glue_catalog_db_name,
                                        table=glue_catalog_table_name,
                                        mode=write_data_operation
                                    )
        return wr_response
    
    except Exception as e:
        print(e)
        raise e
    



