import json
import boto3
import uuid

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("FaceMetadataTable")

def lambda_handler(event, context):
    print("Event received:", json.dumps(event))
    
    try:
        body = json.loads(event["body"])
        bucket = body["bucket"]
        image_key = body["image_key"]
        faces = body["faces"]

        # Store face details in DynamoDB
        for face in faces:
            table.put_item(Item={
                "ImageKey": image_key,
                "FaceId": str(uuid.uuid4()),
                "Confidence": face["Confidence"],
                "BoundingBox": json.dumps(face["BoundingBox"]),
                "Emotions": json.dumps(face["Emotions"])
            })

        return {
            "statusCode": 200,
            "body": json.dumps("Metadata stored successfully!")
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps("Failed to store metadata!")
        }
