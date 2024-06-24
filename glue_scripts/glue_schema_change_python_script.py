import boto3
import json

# Initialize a session using Amazon Glue
client = boto3.client('glue')

# Parameters
database_name = 'pkr_youtube_cleaned_db'
table_name = 'ref_category'

# Retrieve the current table definition
def get_table_definition(client, database_name, table_name):
    response = client.get_table(DatabaseName=database_name, Name=table_name)
    return response['Table']

# Update the table schema
def update_table_schema(client, database_name, table_name, table_definition):
    # Modify the schema (example: changing column1 type from string to bigint)
    for column in table_definition['StorageDescriptor']['Columns']:
        if column['Name'] == 'id':
            column['Type'] = 'bigint'
    
    # Remove fields not needed for update_table call
    table_input = {
        'Name': table_definition['Name'],
        'StorageDescriptor': table_definition['StorageDescriptor'],
        'TableType': table_definition.get('TableType', 'EXTERNAL_TABLE'),
        'Parameters': table_definition.get('Parameters', {})
    }
    
    # Update the table
    client.update_table(
        DatabaseName=database_name,
        TableInput=table_input
    )


try:
    table_definition = get_table_definition(client, database_name, table_name)
    print("Current Schema: ", json.dumps(table_definition['StorageDescriptor']['Columns'], indent=4))

    update_table_schema(client, database_name, table_name, table_definition)
    updated_table_definition = get_table_definition(client, database_name, table_name)
    print("Updated Schema: ", json.dumps(updated_table_definition['StorageDescriptor']['Columns'], indent=4))

except Exception as e:
    print(f"Error: {e}")
