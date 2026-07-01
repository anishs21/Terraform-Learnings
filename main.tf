resource "aws_instance" "Test-instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  provider = aws.region-2

  tags = {
    Name = "Test-instance-1"
  }
}
resource "aws_instance" "Test-instance-2" {
  ami           = var.ami_id_1
  instance_type = var.instance_type_1
  provider = aws.region-1

  tags = {
    Name = "Test-instance-2"
  }
}