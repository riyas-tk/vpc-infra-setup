locals {
  region   = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  subnet_cidr_config = {
    "subnet-pub"   = { cidr = "10.0.0.0/24", public = true, az = "us-east-1a" }
    "subnet-priv1" = { cidr = "10.0.1.0/24", public = false, az = "us-east-1b" }
   # "subnet-priv2" = { cidr = "10.0.2.0/24", public = false, az = "us-east-1c" }
   # "subnet-priv3" = { cidr = "10.0.3.0/24", public = false, az = "us-east-1d" }
  }
  images = {
    amz_lnx = "ami-024ee5112d03921e2" #amz linux
    rhel10 = "ami-0ad50334604831820" #rhel 10
    rhel9 = "ami-09e973f123c32cf86" #rhel 9
  }

  instances = {
    node_control_plane = {
      ami_id    = local.images.rhel9
      type      = "t3.small" #2G,2vcpu 
      # type    = "t2.micro" #1G,1vcpu
      #

      subnet    = "subnet-pub"
      public_sg = true
      role      = "control_plane"
      userdata_base64 = base64encode(file("${path.module}/scripts/userdata.txt")) 
   }
    node_master_1 = {
      ami_id    = local.images.rhel9
      type      = "t2.micro"
      subnet    = "subnet-priv1"
      sg_name   = "private-ssh-sg"
      public_sg = false
      role      = "worker"
    }
  }
}
