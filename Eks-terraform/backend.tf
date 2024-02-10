terraform {
  backend "s3" {
    bucket = "spisey-tetris-project" # Replace with your actual S3 bucket name
    key    = "eks-terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
