resource "aws_sfn_state_machine" "face_detection_state_machine" {
  name     = "FaceDetectionStateMachine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
{
  "Comment": "Face Detection Workflow",
  "StartAt": "DetectFaces",
  "States": {
    "DetectFaces": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.face_detection_lambda.arn}",
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "step_function_role" {
  name = "step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_function_policy" {
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}