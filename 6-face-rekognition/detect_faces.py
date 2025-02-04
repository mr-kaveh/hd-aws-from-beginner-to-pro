import json
import boto3

rekognition = boto3.client("rekognition")
s3 = boto3.client("s3")

def lambda_handler(event, context):
    print("Event received:", json.dumps(event))
    
    # Extract bucket name and image key from event
    record = event["Records"][0]
    bucket = record["s3"]["bucket"]["name"]
    image_key = record["s3"]["object"]["key"]

    try:
        # Call Rekognition to detect faces
        response = rekognition.detect_faces(
            Image={"S3Object": {"Bucket": bucket, "Name": image_key}},
            Attributes=["ALL"]
        )

        faces = response["FaceDetails"]

        return {
            "statusCode": 200,
            "body": json.dumps({
                "bucket": bucket,
                "image_key": image_key,
                "faces_detected": len(faces),
                "faces": faces
            })
        }
    
    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps("Face detection failed!")
        }
