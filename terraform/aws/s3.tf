resource "aws_s3_bucket" "data" {
  # bucket is public
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  bucket        = "${local.resource_prefix.value}-data"
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-data"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "4d57f83ca4d3a78a44fb36d1dcf0d23983fa44f5"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2022-05-18 07:08:06"
    git_modifiers        = "34870196+LironElbaz/nimrod/prowlerworkshop"
    git_org              = "workshop"
    git_repo             = "terragoat"
    yor_trace            = "0874007d-903a-4b4c-945f-c9c233e13243"
  })
}

resource "aws_s3_bucket_object" "data_object" {
  bucket = aws_s3_bucket.data.id
  key    = "customer-master.xlsx"
  source = "resources/customer-master.xlsx"
  tags = merge({
    Name        = "${local.resource_prefix.value}-customer-master"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2020-06-16 14:46:24"
    git_org              = "workshop"
    git_repo             = "terragoat"
    yor_trace            = "a7f01cc7-63c2-41a8-8555-6665e5e39a64"
  })
}

resource "aws_s3_bucket" "financials" {
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  bucket        = "${local.resource_prefix.value}-financials"
  acl           = "private"
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-financials"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2020-06-16 14:46:24"
    git_org              = "workshop"
    git_repo             = "terragoat"
    yor_trace            = "0e012640-b597-4e5d-9378-d4b584aea913"
  })

}

resource "aws_s3_bucket" "operations" {
  # bucket is not encrypted
  # bucket does not have access logs
  bucket = "${local.resource_prefix.value}-operations"
  acl    = "private"
  versioning {
    enabled = true
  }
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-operations"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2020-06-16 14:46:24"
    git_org              = "workshop"
    git_repo             = "terragoat"
    yor_trace            = "29efcf7b-22a8-4bd6-8e14-1f55b3a2d743"
  })
}

# Generate a random, globally unique suffix
resource "random_pet" "suffix" {
  length = 2
}

# Compose a unique bucket name
locals {
  bucket_name = "public-bucket-${random_pet.suffix.id}"
}

# Create the bucket
resource "aws_s3_bucket" "public" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = {
    Name = local.bucket_name
    Env  = var.environment
  }
}

# Ownership controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.public.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.public.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.public.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public access settings
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.public.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.public.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.public.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# Optional example object
resource "aws_s3_object" "example" {
  bucket       = aws_s3_bucket.public.id
  key          = "hello.txt"
  content      = "Hello, world!"
  content_type = "text/plain"

  depends_on = [aws_s3_bucket_policy.public_read]
}

# Outputs
output "bucket_name" {
  value = local.bucket_name
}

output "example_object_url" {
  value = "https://s3.${var.region}.amazonaws.com/${local.bucket_name}/${aws_s3_object.example.key}"
}
