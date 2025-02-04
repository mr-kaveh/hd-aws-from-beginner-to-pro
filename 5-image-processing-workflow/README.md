### This Repo only include CloudFormation code for deploying the following Resources
  

 -  Two Amazon S3 buckets: 
	 - **RiderPhotoS3Bucket** stores the photos uploaded by the riders
	 -  **ThumbnailS3Bucket** stores the resized thumbnails of the rider photos 
 - One Amazon DynamoDB table **RiderPhotoDDBTable** that stores the metadata of the rider’s photo with rider’s profile
 -  **AWS Lambda** functions that perform the processing steps IAM role StateMachineRole that gives the Step Functions state machine to invoke Lambda functions 
 - **One AWS StepFunction** that contains the starting point for our workflow One Amazon SNS Topic that will be used to notify the user of failures