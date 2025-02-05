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
        logger.info("Received event: " + json.dumps(event['Records'][0]['s3']['bucket']['name']))
        logger.info("Type of Event is:" + str(type(event)))
        
        # Extract bucket name from the EventBridge event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        logger.info(f"Processing bucket: {bucket_name}")

        object_key = event['Records'][0]['s3']['object']['key']

        logger.info(f"Processing image: s3://{bucket_name}/{object_key}")

        # Detect faces using Rekognition
        rekognition_response = rekognition.detect_faces(
            Image={
                'S3Object': {
                    'Bucket': bucket_name,
                    'Name': object_key
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
