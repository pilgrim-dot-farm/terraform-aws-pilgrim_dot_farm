resource "aws_s3_bucket" "pilgrim" {
  for_each = toset(["public", "private"])
  bucket   = "pilgrim-dot-farm-${each.key}-2"
}

# Public content is served through CloudFront; neither bucket allows direct public access.
resource "aws_s3_bucket_public_access_block" "pilgrim" {
  for_each = aws_s3_bucket.pilgrim
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "pilgrim" {
  for_each = aws_s3_bucket.pilgrim
  bucket   = each.value.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pilgrim" {
  for_each = aws_s3_bucket.pilgrim
  bucket   = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "public" {
  name                              = "pilgrim-dot-farm-public"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "public" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_function" "media_cors" {
  name  = "pilgrim-media-cors"
  stage = "LIVE"
}

resource "aws_cloudfront_distribution" "public" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Public pilgrim.farm assets"

  origin {
    domain_name              = aws_s3_bucket.pilgrim["public"].bucket_regional_domain_name
    origin_id                = "public-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.public.id
  }

  default_cache_behavior {
    target_origin_id       = "public-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.public.id

    function_association {
      event_type   = "viewer-response"
      function_arn = data.aws_cloudfront_function.media_cors.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "bucket" {
  for_each = aws_s3_bucket.pilgrim

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [each.value.arn, "${each.value.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = each.key == "public" ? [true] : []
    content {
      sid       = "AllowCloudFrontRead"
      actions   = ["s3:GetObject"]
      resources = ["${each.value.arn}/*"]
      principals {
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "AWS:SourceArn"
        values   = [aws_cloudfront_distribution.public.arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "pilgrim" {
  for_each = aws_s3_bucket.pilgrim
  bucket   = each.value.id
  policy   = data.aws_iam_policy_document.bucket[each.key].json
}
