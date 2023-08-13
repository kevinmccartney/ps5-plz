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
  region  = var.ps5_plz_aws_region
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

resource "aws_s3_bucket" "ps5-plz-dist" {
  bucket = "ps5-plz-dist"
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
    "project"    = "ps5-plz",
    "managed_by" = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.purchase_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "test_lambda" {
  image_uri = "291118487001.dkr.ecr.us-east-1.amazonaws.com/ps5-plz:latest"
  function_name = "ps5_plz_purchase"
  role          = aws_iam_role.purchase_lambda.arn
  package_type = "Image"
  memory_size = 512
  timeout = 60

  image_config {
    entry_point = ["/var/task/entry_script.sh"]
    command = ["purchase.lambda_handler"]
  }

  tags = {
    "project"    = "ps5-plz",
    "managed_by" = "terraform"
  }

  environment {
    variables = {
      "PATH"       = "var/task/bin"
      "PYTHONPATH" = "/var/task/src:/var/task/lib"
    }

  }
}

resource "aws_ecr_repository" "image-repository" {
  name = "ps5-plz"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "project"    = "ps5-plz",
    "managed_by" = "terraform"
  }
}
