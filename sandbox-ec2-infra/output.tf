
output "instance_public_dns" {
  value = module.spot_instances["node_bastion"].ec2_public_dns
}