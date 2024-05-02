provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "general_storage_bucket" {
  bucket = "general-storage-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

}
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_configuration" {
    bucket = aws_s3_bucket.general_storage_bucket.id

    rule {
        id      = "delete-objects-after-14-days"
        status  = "Enabled"

        expiration {
            days = 14
        }
    }
}

resource "aws_s3_bucket_ownership_controls" "ownership_control" {
  bucket = aws_s3_bucket.general_storage_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "general_storage_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership_control]

  bucket = aws_s3_bucket.general_storage_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.general_storage_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
    bucket = aws_s3_bucket.general_storage_bucket.id

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RestrictToIAMAdminUser",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::891377252563:user/iamadmin"
                ]
            },
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.general_storage_bucket.id}/*"
        }
    ]
}
EOF
}