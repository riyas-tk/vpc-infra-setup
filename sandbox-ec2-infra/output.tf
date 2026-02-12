
output "instance_public_dns" {
  value = module.spot_instances["node_bastion"].ec2_public_dns
}

output "node1_ip" {
  value = module.spot_instances["subnet-priv1"].ec2_private_dns
}