output "vpc_id" {
  value = aws_vpc.main.id
}

output "main_igw_id" {
  value = aws_internet_gateway.igw.id
}

output "subnet_ids" {
  value = aws_subnet.subnets
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat_gw.id
}

output "public_sg_id" {
  value = aws_security_group.public_ssh_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_ssh_sg.id
}
