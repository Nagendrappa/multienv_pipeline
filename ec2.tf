data "aws_security_group" "mydefault_sg" {
  id = "sg-022b27ac114e9ef90"
}

variable "env" {
  type = string
}

resource "aws_instance" "test_instance" {
  ami           = "ami-052064a798f08f0d3"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids =[data.aws_security_group.mydefault_sg.id]  
  key_name      = "myawskey"

  tags = {
   Name = "Test-instance-${var.env}"
  } 
}

