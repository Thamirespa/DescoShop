#Criação do bucket
resource "aws_s3_bucket" "descomplicafront" {
  bucket = "descomplicafront"
  tags =  {
    Name = "descomplicafront"
  }
}

#Controle de acesso ao bucket
resource "aws_s3_bucket_public_access_block" "static_site_bucket_public_access" {
  bucket = aws_s3_bucket.descomplicafront.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "static_site_bucket_descomplicafront" {
  bucket = aws_s3_bucket.descomplicafront.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


data "aws_s3_bucket" "selected_bucket" {
  bucket = aws_s3_bucket.descomplicafront.id
}

#Criação do Cloud Front
resource "aws_cloudfront_origin_access_control" "descomplica-cf" {
  name                              = "CloudFront descomplica "
  description                       = "CloudFront descomplica "
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cf-descomplica" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = data.aws_s3_bucket.selected_bucket.bucket_regional_domain_name
    origin_id                = "descomplicafront"
    origin_access_control_id = aws_cloudfront_origin_access_control.descomplica-cf.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "descomplicafront"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN", "US", "CA"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags =  {
    Name = "descomplicafront"
  }
}


#Política para permitir acesso do bucket pelo cloudfront
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.descomplicafront.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   =  ["${aws_cloudfront_distribution.cf-descomplica.arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "descomplica_bucket_acl" {
  bucket = aws_s3_bucket.descomplicafront.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}