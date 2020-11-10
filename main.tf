
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  profile    = "terraform"
}

data "aws_ami" "linuxserver" {
    most_recent = true
    owners = ["137112412989"] # AWS

 filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2*-x86_64-gp2"]
 }

 filter {
    name   = "virtualization-type"
    values = ["hvm"]
 }  
}

resource "aws_vpc" "waap_vpc" {
  cidr_block = var.aws_vpc_cidr
  tags = {
    Name = "WAAP VPC Terraform"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.waap_vpc.id
}

# Default route to Internet
resource "aws_route" "rt_main_vpc" {
  route_table_id         = aws_vpc.waap_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  #instance_id            = aws_instance.server1.id
  gateway_id              = aws_internet_gateway.gw.id
}

# Define an external subnet for the security layer facing internet in the primary availability zone
resource "aws_subnet" "ext_subnet_waap_vpc" {
  vpc_id                  = aws_vpc.waap_vpc.id
  cidr_block              = var.aws_external_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.primary_az
  tags = {
    Name = "External, Transit VPC, Terraform"
  }
  depends_on = [aws_internet_gateway.gw]
}
#
# # Define an external subnet for the security layer facing internet in the secondary availability zone
resource "aws_subnet" "int_subnet_waap_vpc" {
  vpc_id                  = aws_vpc.waap_vpc.id
  cidr_block              = var.aws_internal_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.primary_az
  tags = {
    Name = "Internal, Transit VPC, Terraform"
  }
}
resource "aws_default_security_group" "default" {
  vpc_id                  = aws_vpc.waap_vpc.id

  ingress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

  egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]  
  }
}
# # Permissive security group
resource "aws_security_group" "permissive_sg_waap_vpc" {
  name                   = "permissive_sg_waap_vpc"
  description            = "Permissive sg, Transit VPC, Terraform"
  vpc_id                 = aws_vpc.waap_vpc.id

  ingress {
		from_port   = 7070
		to_port     = 7070
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

  ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

  egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_network_interface" "server1_nic" {
  subnet_id         = aws_subnet.ext_subnet_waap_vpc.id
  private_ips       = ["10.0.0.10"]
  security_groups   = [aws_security_group.permissive_sg_waap_vpc.id]
  tags = {
    Name            = "Server1_primary_nic"
  }
}
# EIP for Server1
resource "aws_eip" "eip_server1" {
  vpc= true
  network_interface = aws_network_interface.server1_nic.id
  associate_with_private_ip = "10.0.0.10"
  tags = {
    Name   = "EIP for Server1, Terraform"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_instance" "server1" {
  ami                         = data.aws_ami.linuxserver.id
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key_name
  user_data                   = var.my_user_data
  
  network_interface {
    network_interface_id      = aws_network_interface.server1_nic.id
    device_index              = 0
  }

  tags = {
    Name                      = "Server Terraform"
  }
}

resource "null_resource" "previous" {}

resource "time_sleep" "server_resource_provision" {
  depends_on = [null_resource.previous]

  create_duration = "120s"
}

resource "null_resource" "provisioner" {
  connection {
    type                      = "ssh"
    user                      = "ec2-user"
    private_key               = file(var.public_key_path)
    host                      = aws_eip.eip_server1.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "docker run -d -p 7070:80 raesene/bwapp",
    ]
  }
  depends_on = [
    aws_instance.server1,
    aws_internet_gateway.gw,
    aws_eip.eip_server1,
    time_sleep.server_resource_provision,
  ]
}

#Output the servers public IP
output "Server_PublicIP" {
  value = aws_eip.eip_server1.public_ip
}
