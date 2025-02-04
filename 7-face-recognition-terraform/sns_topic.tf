resource "aws_sns_topic" "face_detection_topic" {
  name = "face-detection-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.face_detection_topic.arn
  protocol  = "email"
  endpoint  = "mr.hdavoodi@gmail.com"  # Replace with your email
}