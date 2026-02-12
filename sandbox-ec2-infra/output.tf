
output "instance_public_dns" {
  value = module.spot_instances["node_bastion"].ec2_data.public_dns
}

output "node1_ip" {
  value = module.spot_instances["node_master-1"].ec2_data.private_dns
}
