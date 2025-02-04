
# How to create a face detection service on AWS using S3, Lambda functions, AWS Rekognition and SNS


## **🏗️ Architecture Overview**

1.  **S3 Bucket (`face-detection-images`)** → Stores uploaded images.
2.  **EventBridge Rule** → Triggers a Step Functions state machine when a new image is uploaded.
3.  **Step Functions Workflow**:
    -   **Step 1**: Call Rekognition to detect faces.
    -   **Step 2**: Store results in **DynamoDB**.
    -   **Step 3**: Send an SNS notification.
4.  **Lambda Functions** → Handle image processing logic.
5.  **DynamoDB Table** → Stores metadata about detected faces.
6.  **SNS Notification** → Sends alerts on face detection results.

## **🛠️ Implementation Steps**

### **1️⃣ Create an S3 Bucket for Image Uploads**

	aws s3api create-bucket --bucket face-detection-images --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1

### **2️⃣ Create a DynamoDB Table to Store Face Metadata**

	aws dynamodb create-table --table-name FaceMetadataTable \
    --attribute-definitions AttributeName=ImageKey,AttributeType=S \
    --key-schema AttributeName=ImageKey,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region eu-central-1

### **3️⃣ Create an SNS Topic for Notifications**

	aws sns create-topic --name FaceDetectionResults --region eu-central-1

Subscribe your email:

	aws sns subscribe --topic-arn arn:aws:sns:eu-central-1:890742597184:FaceDetectionResults \
    --protocol email --notification-endpoint mr.hdavoodi@gmail.com \
    --region eu-central-1

### **4️⃣ Create IAM Role for Step Functions**

Modify the **IAM policy JSON** file to ensure the correct region (`eu-central-1`) name it **stepfunction-iam-policy**:

	{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["lambda:InvokeFunction"],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": ["dynamodb:PutItem"],
            "Resource": "arn:aws:dynamodb:eu-central-1:890742597184:table/FaceMetadataTable"
        },
        {
            "Effect": "Allow",
            "Action": ["sns:Publish"],
            "Resource": "arn:aws:sns:eu-central-1:890742597184:FaceDetectionResults"
        }
    ]
}

### **5️⃣ Deploy the Lambda Functions**

#### **Lambda 1: Detect Faces using Rekognition**

	aws lambda create-function --function-name DetectFacesLambda \
    --runtime python3.8 \
    --role arn:aws:iam::890742597184:role/LambdaExecutionRole \
    --handler face_detection.lambda_handler \
    --zip-file fileb://detect_faces.zip \
    --region eu-central-1


#### **Lambda 2: Store Face Metadata in DynamoDB**

	aws lambda create-function --function-name StoreMetadataLambda \
    --runtime python3.8 \
    --role arn:aws:iam::890742597184:role/LambdaExecutionRole \
    --handler store_metadata.lambda_handler \
    --zip-file fileb://store_metadata.zip \
    --region eu-central-1

#### **Lambda 3: Send SNS Notification**

	aws lambda create-function --function-name SendNotificationLambda \
	    --runtime python3.8 \
	    --role arn:aws:iam::890742597184:role/LambdaExecutionRole \
	    --handler send_notification.lambda_handler \
	    --zip-file fileb://send_notification.zip \
	    --region eu-central-1


### **6️⃣ Create the Step Functions State Machine**

Update the **State Machine JSON** file to ensure the correct region (`eu-central-1`):
	

	{
	  "Comment": "Face Recognition State Machine",
	  "StartAt": "Detect Faces",
	  "States": {
	    "Detect Faces": {
	      "Type": "Task",
	      "Resource": "arn:aws:lambda:eu-central-1:890742597184:function:DetectFacesLambda",
	      "Next": "Store Metadata"
	    },
	    "Store Metadata": {
	      "Type": "Task",
	      "Resource": "arn:aws:lambda:eu-central-1:890742597184:function:StoreMetadataLambda",
	      "Next": "Send Notification"
	    },
	    "Send Notification": {
	      "Type": "Task",
	      "Resource": "arn:aws:lambda:eu-central-1:890742597184:function:SendNotificationLambda",
	      "End": true
	    }
	  }
	}

Create the **Step Functions State Machine**:

	aws stepfunctions create-state-machine --name FaceRecognitionWorkflow \
	    --definition file://state-machine.json \
	    --role-arn arn:aws:iam::890742597184:role/StepFunctionExecutionRole \
	    --region eu-central-1


### **7️⃣ Create an EventBridge Rule to Trigger Step Functions**

Update the **Event Rule JSON** file to ensure the correct region (`eu-central-1`):

	{
			"source": ["aws.s3"],
			"detail-type": ["AWS API Call via CloudTrail"],
			"detail": {
			"eventSource": ["s3.amazonaws.com"],
			"eventName": ["PutObject"],
			"requestParameters": {
				"bucketName": ["face-detection-images-890742597184"]
			}
		}
	}

Apply the rule:

	aws events put-rule --name FaceDetectionTrigger --event-pattern file://event-rule.json --region eu-central-1

Attach the Step Function:

	aws events put-targets --rule FaceDetectionTrigger  --targets '[
	  {
	    "Arn": "arn:aws:states:eu-central-1:890742597184:stateMachine:ImageProcessingWorkflow",
	    "Id": "StepFunctionTarget",
	    "RoleArn": "arn:aws:iam::890742597184:role/EventBridgeExecutionRole"
	  }
	]'


if the role does not exist for creating the lambda functions try creating it:

### **✅ Step 1: Create an IAM Role for Lambda**

Run this command to create a new **Lambda execution role**:

	aws iam create-role --role-name LambdaExecutionRole \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }' \
    --region eu-central-1

### **✅ Step 2: Attach Necessary Policies**

Now, attach **basic execution permissions** to the role:

	aws iam attach-role-policy --role-name LambdaExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole



### To **clean up all AWS resources** that you created for this service, follow these steps:

	aws stepfunctions delete-state-machine --state-machine-arn arn:aws:states:eu-central-1:890742597184:stateMachine:ImageProcessingWorkflow
	aws lambda list-functions --query "Functions[*].FunctionName"
	aws lambda delete-function --function-name DetectFacesLambda
	aws lambda delete-function --function-name StoreMetadataLambda
	aws lambda delete-function --function-name SendNotificationLambda
	aws lambda delete-function --function-name CheckFaceDuplicateLambda
	aws lambda delete-function --function-name AddFaceToIndexLambda
	aws lambda delete-function --function-name CreateThumbnailLambda
	aws iam detach-role-policy --role-name LambdaExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
	aws iam delete-role-policy --role-name LambdaExecutionRole --policy-name LambdaPolicy
	aws iam delete-role --role-name LambdaExecutionRole
	aws s3 ls s3://face-detection-images-890742597184 --recursive
	aws s3 rm s3://face-detection-images-890742597184 --recursive
	aws s3 rb s3://face-detection-images-890742597184
	aws dynamodb delete-table --table-name FaceMetadataTable
	aws rekognition delete-collection --collection-id rider-photos
	aws sns delete-topic --topic-arn arn:aws:sns:eu-central-1:<your-account-id>:ImageProcessingFailures