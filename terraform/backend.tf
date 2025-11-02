terraform {
  backend "s3" {
    bucket         = "ecs-deployment-pratik"    # 🔹 Create this S3 bucket in your account
    key            = "hello-ecs/terraform.tfstate"
    region         = "ap-south-1"
    #dynamodb_table = "terraform-lock"             # 🔹 Optional but recommended
    encrypt        = true
  }
}
