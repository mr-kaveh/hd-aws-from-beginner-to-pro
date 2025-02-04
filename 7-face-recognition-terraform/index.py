import boto3
import os
import json
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')
sns = boto3.client('sns')

def handler(event, context):
    try:
        # Log the incoming event
        logger.info("Received event: " + json.dumps(event))
        
        # Extract bucket name from the EventBridge event
        bucket_name = event['detail']['requestParameters']['bucketName']
        logger.info(f"Processing bucket: {bucket_name}")

        # List objects in the bucket to find the most recent object
        response = s3.list_objects_v2(Bucket=bucket_name)
        if 'Contents' in response:
            # Assuming the latest object by 'LastModified' timestamp
            sorted_objects = sorted(response['Contents'], key=lambda obj: obj['LastModified'], reverse=True)
            latest_object_key = sorted_objects[0]['Key']
        else:
            raise ValueError("No objects found in the bucket.")

        logger.info(f"Processing image: s3://{bucket_name}/{latest_object_key}")

        # Detect faces using Rekognition
        rekognition_response = rekognition.detect_faces(
            Image={
                'S3Object': {
                    'Bucket': bucket_name,
                    'Name': latest_object_key
                }
            },
            Attributes=['ALL']
        )
        logger.info("Rekognition response: " + json.dumps(rekognition_response))

        # Publish results to SNS
        sns_topic_arn = os.environ['SNS_TOPIC_ARN']
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(rekognition_response),
            Subject="Face Detection Results"
        )
        logger.info("Published results to SNS")

        return {
            'statusCode': 200,
            'body': json.dumps('Face detection completed!')
        }

    except Exception as e:
        logger.error("Error in Lambda function: " + str(e))
        raise e

# No need to hardcode the event here; it will come from EventBridge
