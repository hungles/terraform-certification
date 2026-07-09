module "instance_1" {
  source            = "../../modules/ec2"
  ec2_instance_name = "instancia-1"
  instance_type     = var.instance_type
  subnet_id         = data.aws_subnets.private_with_tag.ids[0]
  ami_id            = data.aws_ami.ubuntu.id
}

module "instance_2" {
  source            = "../../modules/ec2"
  ec2_instance_name = "instancia-2"
  instance_type     = var.instance_type
  subnet_id         = data.aws_subnets.private_with_tag.ids[1]
  ami_id            = data.aws_ami.ubuntu.id
}

module "instance_3" {
  source            = "../../modules/ec2"
  ec2_instance_name = "instancia-3"
  instance_type     = var.instance_type
  subnet_id         = data.aws_subnets.private_with_tag.ids[0]
  ami_id            = data.aws_ami.ubuntu.id
}