output "aws_eip" {
value = aws_eip.eip.public_ip
}
output "aws_vpc" {
value = aws_vpc.vpc.id
}
output "aws_internet_gateway" {
value = aws_internet_gateway.igw.id
}
output "aws_nat_gateway" {
value = aws_nat_gateway.nat.id
}
output "aws_route_table_public" {
value = aws_route_table.public.id
}
output "aws_route_table_private" {
value = aws_route_table.private.id
}
output "webserver_public_ip" {
  value = aws_instance.webserver.public_ip
}
output "database_private_ip" {
  value = aws_instance.database.private_ip
}
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
