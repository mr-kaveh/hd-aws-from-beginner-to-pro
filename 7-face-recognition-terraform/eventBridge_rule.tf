resource "aws_cloudwatch_event_rule" "s3_upload_rule" {
  name        = "s3-upload-rule"
  description = "Trigger Step Function on S3 upload"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail_type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["PutObject"]
      requestParameters = {
        bucketName = [aws_s3_bucket.image_bucket.bucket]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "step_function_target" {
  rule      = aws_cloudwatch_event_rule.s3_upload_rule.name
  target_id = "StepFunctionTarget"
  arn       = aws_sfn_state_machine.face_detection_state_machine.arn
  role_arn  = aws_iam_role.event_bridge_role.arn
}

resource "aws_iam_role" "event_bridge_role" {
  name = "event-bridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "event_bridge_policy" {
  role = aws_iam_role.event_bridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "states:StartExecution"
        ]
        Effect   = "Allow"
        Resource = aws_sfn_state_machine.face_detection_state_machine.arn
      }
    ]
  })
}