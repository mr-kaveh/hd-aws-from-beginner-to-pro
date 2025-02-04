import json
import boto3

sns = boto3.client("sns")
SNS_TOPIC_ARN = "arn:aws:sns:eu-central-1:123456789012:FaceDetectionResults"

def lambda_handler(event, context):
    print("Event received:", json.dumps(event))
    
    try:
        body = json.loads(event["body"])
        image_key = body["image_key"]
        faces_detected = body["faces_detected"]

        # Send SNS notification
        message = f"Face detection completed for image '{image_key}'. Faces detected: {faces_detected}"
        
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message,
            Subject="Face Detection Results"
        )

        return {
            "statusCode": 200,
            "body": json.dumps("Notification sent successfully!")
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps("Failed to send notification!")
        }
