# Reference taken from https://github.com/trussworks/terraform-aws-cloudtrail/
# Work in progress

data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket" "test-cloudtrail-s3-bucket" {
  bucket = "${var.name}-s3-bucket"
  acl    = "private"
  force_destroy = true
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.name}-s3-bucket"
    },
    {
      "Sid": "AWSCloudTrailWrite20150319",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.name}-s3-bucket/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_cloudtrail" "CLoudTrail" {
  name = var.name
  s3_bucket_name = aws_s3_bucket.test-cloudtrail-s3-bucket.id
  enable_log_file_validation = var.enable_log_file_validation //true
  is_multi_region_trail = var.is_multi_region_trail //true
  include_global_service_events = var.include_global_service_events //true
  enable_logging = var.enable_logging // true
  is_organization_trail = var.is_organization_trail //false
  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch_role.arn
  kms_key_id = aws_kms_key.cloudtrail_kms_key.arn

  dynamic "event_selector" {
    // use this selector with proper care as it will incur heavy charges
    for_each = var.event_selector
    content {
      include_management_events = lookup(event_selector.value, "include_management_events", null) // Optional therefore "lookup" function
      read_write_type = lookup(event_selector.value, "read_write_type", null) // // Optional therefore "lookup" function

      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resource", [])
        content {
          type = data_resource.value.type // "AWS::S3::Object" // Required therefore "direct value"
          values = data_resource.value.values // ["arn:aws:s3:::cloudtrail_kms_key-s3-bucket/",] // Required therefore "direct value"
            // Edit this to add individual Buckets
            // "arn:aws:s3:::", // This value affects "Insights events" on Cloudtrail Dashboard
        }
      }
    }
  }
  tags = {
    Name       = var.name
  }

  depends_on = [
    aws_kms_key.cloudtrail_kms_key,
  ]
}
