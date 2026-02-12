locals {
  region   = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  subnet_cidr_config = {
    "subnet-pub"   = { cidr = "10.0.0.0/24", public = true, az = "us-east-1a" }
    "subnet-priv1" = { cidr = "10.0.1.0/24", public = false, az = "us-east-1b" }
    "subnet-priv2" = { cidr = "10.0.2.0/24", public = false, az = "us-east-1c" }
    "subnet-priv3" = { cidr = "10.0.3.0/24", public = false, az = "us-east-1d" }
  }

  amz_lnx = "ami-024ee5112d03921e2" #amz linux
  instances = {
    node_bastion = {
      ami_id    = local.amz_lnx
      type      = "t2.micro"
      subnet    = "subnet-pub"
      public_sg = true
    }
    node_master-1 = {
      ami_id    = local.amz_lnx
      type      = "t2.micro"
      subnet    = "subnet-priv1"
      sg_name   = "private-ssh-sg"
      public_sg = false
    }
  }
}
