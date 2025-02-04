resource "aws_lambda_function" "face_detection_lambda" {
  function_name = "face-detection-lambda"
  handler       = "index.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.face_detection_topic.arn
    }
  }
}

resource "aws_lambda_permission" "s3_invoke_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.face_detection_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.image_bucket.arn
}