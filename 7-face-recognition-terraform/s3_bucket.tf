resource "aws_s3_bucket" "image_bucket" {
  bucket = "face-detection-image-bucket"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.image_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.face_detection_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}