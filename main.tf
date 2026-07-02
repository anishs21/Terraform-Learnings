resource "aws_instance" "Test-instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  provider      = aws.region-2

  tags = {
    Name = "Test-instance-1"
  }
}
resource "aws_instance" "Test-instance-2" {
  ami           = var.ami_id_1
  instance_type = var.instance_type_1
  provider      = aws.region-1

  tags = {
    Name = "Test-instance-2"
  }
}

module "s3_bucket" {
  source = "./modules/s3"
}

resource "aws_s3_bucket" "state-file-store-0123" {
  bucket = "state-file-store-0123dhbvhj"
}


