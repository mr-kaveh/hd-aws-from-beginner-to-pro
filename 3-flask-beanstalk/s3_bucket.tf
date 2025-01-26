resource "aws_s3_bucket" "app_bucket" {
  bucket = "hd-flask-app-bucket"
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "hd-flask-app.zip"
  source = "./hd-flask-app.zip" # Path to your Flask app zip file
}
