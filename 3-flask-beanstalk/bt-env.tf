resource "aws_elastic_beanstalk_environment" "env" {
  name                = "hd-python-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.2 running Python 3.12"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "Application Source Bundle"
    value = "/var/app/current" #"${aws_s3_bucket.bucket.id}/${aws_s3_object.app_zip.key}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "vpc-04f0f64309fce9f5a" # hardcoded VPC ID
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "subnet-0d0d7765838dbc540" # Hardcoded Subnet ID
  }
  setting {
    namespace = "aws:ec2:instances"
    name = "InstanceTypes"
    value = "t2.micro" # Hardcoded Instance ID
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
}

output "environment_url" {
  value = aws_elastic_beanstalk_environment.env.endpoint_url
}

