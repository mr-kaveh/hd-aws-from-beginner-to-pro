# #########################IAM_ROLE##################################
# resource "aws_iam_role" "eb_instance_role" {
#   name = "elastic_beanstalk_ec2_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = { Service = "ec2.amazonaws.com" }
#       },
#     ]
#   })
# }

# resource "aws_iam_instance_profile" "eb_instance_profile" {
#   name = "elastic_beanstalk_instance_profile"
#   role = aws_iam_role.eb_instance_role.name
# }

# resource "aws_iam_role_policy_attachment" "eb_instance_role_policy" {
#   role       = aws_iam_role.eb_instance_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
# }

resource "aws_s3_bucket" "bucket" {
  bucket = "3-beanstalk-application-bucket"
}

resource "aws_iam_role" "eb_role" {
  name               = "elasticbeanstalk-service-role"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["elasticbeanstalk.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "eb_instance_role" {
  name               = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_policy.json
}

data "aws_iam_policy_document" "ec2_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = aws_iam_role.eb_instance_role.name
  role = aws_iam_role.eb_instance_role.name
}

resource "aws_iam_role_policy_attachment" "eb_instance_role_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_role_policy" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}