resource "aws_instance" "spot_ec2" {
  region            = var.region
  availability_zone = var.availability_zone
  ami               = var.ami_id
  # subnet_id              = data.aws_subnet.this.id
  subnet_id = var.subnet_id
  vpc_security_group_ids = [
    var.sg_id
  ]
  key_name = var.ssh_key
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = var.spot_type
      instance_interruption_behavior = var.persistent_spot_settings.enabled ? "stop" : "terminate"
    }
  }
  root_block_device {
    volume_size = 20
  }
  instance_type = var.instance_type
  tags = merge(
    var.tags, {
      Name = var.instance_name
  })
}


output "ec2_data" {
  value = aws_instance.spot_ec2
}
