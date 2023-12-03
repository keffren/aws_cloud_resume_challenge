resource "aws_dynamodb_table" "terraform_state" {
  name           = "resume-challenge-tf-state"

  //By default the billing_mode is PROVISIONED
  //If the billing_mode is PROVISIONED, read_capacity and write_capacity are required
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5

  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "resume-challenge-tf-state"
    Project = "aws-cloud-resume-challenge"
    Terraform = "true"
  }
}

resource "aws_dynamodb_table" "visitor_counter" {
  name           = "resume-challenge-counter"

  //By default the billing_mode is PROVISIONED
  //If the billing_mode is PROVISIONED, read_capacity and write_capacity are required
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5

  hash_key       = "CounterId"

  attribute {
    name = "CounterId"
    type = "S"
  }

  tags = {
    Name = "resume-challenge-DB"
    Project = "aws-cloud-resume-challenge"
    Terraform = "true"
  }
}

resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.visitor_counter.name
  hash_key   = aws_dynamodb_table.visitor_counter.hash_key

  item = <<-ITEM
  {
    "CounterId": {"S": "mainCounter"},
    "visitorsNumber": {"N": "0"}
  }
  ITEM
  
  lifecycle {
    ignore_changes = all
  }
}