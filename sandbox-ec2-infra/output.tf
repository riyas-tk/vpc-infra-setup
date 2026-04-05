output "instances" {
  value = [ for instance in keys(local.instances) : module.spot_instances[instance].ec2_data.private_dns ] 
}

output "control_plane_public_ip" {
  value = module.spot_instances["node_control_plane"].ec2_data.public_dns
}



