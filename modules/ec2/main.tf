module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = var.ec2_instance_name
  instance_type = var.instance_type
  #key_name      = "user1"
  monitoring    = true
  subnet_id     = var.subnet_id
  ami           = var.ami_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}