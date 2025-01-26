resource "aws_elastic_beanstalk_application_version" "app_version" {
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.app_bucket.id
  key         = aws_s3_object.app_zip.key
  name        = "v1.0"
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = "hd-simple-flask-app"
  description = "Simple Python Flask Application"
}

# resource "aws_elastic_beanstalk_application_version" "default" {
#   name        = "tf-test-version-label"
#   application = "hd-simple-flask-app"
#   description = "application version created by terraform"
#   bucket      = aws_s3_bucket.app_bucket.id
#   key         = aws_s3_object.app_zip.id
# }