Copy code
# YouTube Trending Video Statistics Analysis

In this project, I developed an end-to-end pipeline for analyzing trending YouTube video statistics data. The dataset used is available on Kaggle: [YouTube Trending Video Statistics](https://www.kaggle.com/datasets/datasnaek/youtube-new). The dataset contains trending YouTube video statistics for different regions (countries), with each region having two files: a JSON file containing references for different categories and a CSV file containing raw statistics of the YouTube videos in that region with `category_id` as one of its columns.

## Project Overview

To analyze the data, the following tasks were performed:

1. **Create Data Layers (S3 Buckets):**
   - **Landing Data Layer:** Raw data storage.
   - **Cleaned Data Layer:** Processed and cleaned data storage.
   - **Analytical Data Layer:** Ready-to-query data storage.

2. **AWS Lambda Function:**
   - Developed a Lambda function to process (clean) the reference category JSON files.
   - Deployed the Lambda function with an S3 trigger on the `create object` event in the Landing Data Layer with the `ref_category` prefix (`landing_data_layer/ref_category/`).
   - The Lambda function cleans the JSON files, creates a data catalog, and saves the cleaned JSON data in Parquet format in `cleaned_data_layer/ref_category/`.

3. **Glue ETL Script:**
   - Developed a Glue ETL script to process the `raw_statistics` CSV files, perform schema changes, and save the data in Parquet format in `cleaned_data_layer/raw_statistics`, partitioned by region for effective querying.
   - Built a data catalog for the processed data using a Glue Crawler.

4. **Data Querying:**
   - By utilizing the two catalog tables, queries related to any region can be executed by joining them on `category_id`.

5. **Optimized Analytical Data Layer:**
   - Recognizing that joining the two datasets for each query is inefficient, another ETL process was created to join the datasets beforehand and store the results in the Analytical Data Layer.
   - This allows data analysts to run queries more efficiently without writing complex joins, enabling them to retrieve the required data by simply filtering on column values such as `category_id` or `region`.

## Technologies Used

- **Python:** As the programming language.

- **AWS IAM:** For access management across different services of AWS.

- **AWS S3:** For data storage across different data layers.

- **AWS Lambda:** For data preprocessing and triggering on S3 events.

- **AWS Glue:** For ETL processes and data catalog creation.

- **AWS Athena:** For querying the data from S3.

- **Terraform:** For provisioning the required AWS infrastructure using Infrastructure as code (IaC)
