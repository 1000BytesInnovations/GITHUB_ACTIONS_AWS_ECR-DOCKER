import boto3
import snowflake.connector
import json
import os


# Snowflake connection details
SNOWFLAKE_ACCOUNT = os.environ.get('SNOWFLAKE_ACCOUNT')
SNOWFLAKE_USER = os.environ.get('SNOWFLAKE_USER')
SNOWFLAKE_PASSWORD = os.environ.get('SNOWFLAKE_PASSWORD')



# ECS task details
ECS_CLUSTER = 'ecs-cluster-name'
ECS_TASK_DEFINITION = 'your-task-definition-arn'

# S3 bucket and key to store the previous timestamps
S3_BUCKET = 'sandbox-learning-01'
S3_KEY = 'vk/previous_timestamps.json'

ecs_client = boto3.client('ecs')
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        # Connect to Snowflake
        ctx = snowflake.connector.connect(
            user=SNOWFLAKE_USER,
            password=SNOWFLAKE_PASSWORD,
            account=SNOWFLAKE_ACCOUNT
        )
        cs = ctx.cursor()

        # Get the pipe status
        cs.execute("use role DBT_ROLE")
        cs.execute("USE DATABASE DBT_DB")
        cs.execute("USE SCHEMA RAW")

        pipes = ['s3pipe_monthly_passenger', 's3pipe_cargo', 's3pipe_landing_data']
        last_ingested_timestamps = {}

        for pipe in pipes:
            cs.execute(f"SELECT SYSTEM$PIPE_STATUS('{pipe}')")
            pipe_status = cs.fetchone()[0]
            pipe_status = json.loads(pipe_status)
            last_ingested_timestamps[pipe] = pipe_status['lastIngestedTimestamp']

        # Get the previous timestamps from S3
        try:
            previous_timestamps = json.loads(s3_client.get_object(Bucket=S3_BUCKET, Key=S3_KEY)['Body'].read().decode('utf-8'))
        except s3_client.exceptions.NoSuchKey:
            previous_timestamps = {}

        # Check if any of the timestamps have changed
        if any(last_ingested_timestamps[pipe] != previous_timestamps.get(pipe, '') for pipe in pipes):
            # Trigger the Amazon ECS task
            ecs_client.run_task(
                cluster=ECS_CLUSTER,
                taskDefinition=ECS_TASK_DEFINITION,
                launchType='FARGATE',
                networkConfiguration={
                    'awsvpcConfiguration': {
                        'subnets': ['subnet-0a875fe50860b517b', 'subnet-064dd5f684dc34a7d'],  # replace with your actual subnet IDs
                        'assignPublicIp': 'ENABLED'
                    }
                }
            )

            # Update the previous timestamps in S3
            s3_client.put_object(Bucket=S3_BUCKET, Key=S3_KEY, Body=json.dumps(last_ingested_timestamps).encode('utf-8'))

        return {
            'statusCode': 200,
            'body': json.dumps('Lambda execution completed successfully.')
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }