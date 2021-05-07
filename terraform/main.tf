terraform {
  backend "s3" {}
}

data "terraform_remote_state" "state" {
  backend = "s3"
  config = {
    bucket     = "ps5-plz-infra-state"
    lock_table = "ps5-plz-infra-state-locks"
    region     = var.ps5_plz_aws_region
    key        = "terraform.tfstate"
  }
}

provider "aws" {
  version = "~> 3.37.0"
  region = var.ps5_plz_aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "ps5-plz-infra-state"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "ps5-plz-infra-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_iam_role" "purchase_lambda" {
  name = "ps5_plz_purchase_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    "project" = "ps5-plz",
    "managed_by" = "terraform"
  }
}

resource "aws_lambda_function" "test_lambda" {
  filename = "../dist/ps5-plz-purchase.zip"
  function_name = "ps5_plz_purchase"
  role          = aws_iam_role.purchase_lambda.arn
  handler       = "purchase.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  source_code_hash = filebase64sha256("../dist/ps5-plz-purchase.zip")

  runtime = "python3.8"

  tags = {
    "project" = "ps5-plz",
    "managed_by" = "terraform"
  }

  environment {
    variables = {
      "PATH" = "var/task/bin"
      "PYTHONPATH" = "/var/task/src:/var/task/lib"
    }
    
  }
}