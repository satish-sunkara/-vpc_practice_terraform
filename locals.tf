locals {
  name = "${var.projectname}-${var.environment}"
  azs = slice(data.aws_availability_zones.available.names,0,2)
}