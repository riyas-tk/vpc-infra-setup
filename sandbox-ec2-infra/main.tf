module "my_vpc_infra" {
  source             = "../modules/vpc"
  subnet_cidr_config = local.subnet_cidr_config
  vpc_cidr           = local.vpc_cidr
}

module "spot_instances" {
  source   = "../modules/spot-ec2"
  for_each = local.instances

  instance_name     = each.key
  region            = local.region
  availability_zone = local.subnet_cidr_config[each.value.subnet].az

  ami_id          = each.value.ami_id
  instance_type   = each.value.type
  subnet_id       = module.my_vpc_infra.subnet_ids[each.value.subnet].id
  sg_id           = each.value.public_sg ? module.my_vpc_infra.public_sg_id : module.my_vpc_infra.private_sg_id
  ssh_key         = aws_key_pair.ssh_key.id
  valid_until_hrs = var.valid_until_hrs
  depends_on = [ aws_key_pair.ssh_key 
  ]
}
