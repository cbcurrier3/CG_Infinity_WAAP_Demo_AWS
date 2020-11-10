
# find latest Chkp Infinity GW iamge in this region
data "aws_ami" "ami_GW_inf" {
    most_recent = true
    owners = ["679593333241"] # Chkp

 filter {
    name   = "name"
    values = ["Check Point CloudGuard Infinity GW BYOL-GAIA R80.40*"]
 }

 filter {
    name   = "virtualization-type"
    values = ["hvm"]
 }  
}

resource "aws_security_group_rule" "httpRule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.permissive_sg_waap_vpc.id
}

resource "aws_security_group_rule" "httpsRule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.permissive_sg_waap_vpc.id
}
resource "aws_security_group_rule" "chkprule" {
  type              = "ingress"
  from_port         = 30443
  to_port           = 30443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.permissive_sg_waap_vpc.id
}

resource "aws_network_interface" "externalGW_nic" {
  description       = "eth0"
  subnet_id         = aws_subnet.ext_subnet_waap_vpc.id
  private_ips       = ["10.0.0.11"]
  security_groups   = [aws_security_group.permissive_sg_waap_vpc.id]
  tags = {
    Name            = "ExternalNetworkInterface"
  }
}

resource "aws_network_interface" "internalGW_nic" {
  description       = "eth1"
  subnet_id         = aws_subnet.int_subnet_waap_vpc.id
  private_ips       = ["10.0.1.11"]
  security_groups   = [aws_default_security_group.default.id]
  tags = {
    Name            = "InternalNetworkInterface"
  }
}

# EIP for GW
resource "aws_eip" "eip_gw" {
  vpc= true
  network_interface           = aws_network_interface.externalGW_nic.id
  associate_with_private_ip   = "10.0.0.11"
  tags = {
    Name                      = "EIP for ${var.GatewayHostname}, Terraform"
  }
  depends_on                  = [aws_internet_gateway.gw]
}

# Internal route Table
resource "aws_route_table" "rt_internal_vpc" {
  vpc_id                       = aws_vpc.waap_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        network_interface_id   = aws_network_interface.internalGW_nic.id
    }
}

resource "aws_instance" "gw" {
  ami                = data.aws_ami.ami_GW_inf.id
  instance_type      = var.gw_size_type
  key_name           = var.ssh_key_name
  user_data          = <<-EOF
                    #!/bin/bash
                    pwd_hash=''${var.pwd_hash}'' ;
                    hostname=${var.GatewayHostname} ;
                    eic=${var.EnableInstanceConnect} ;
                    eip=${var.AllocatePublicAddress} ;
                    token=${var.InfinityToken} ;
                    instance_id="$(curl_cli -s -S 169.254.169.254/latest/meta-data/instance-id)"
                    template="waap"
                    echo "template_name: $template" >> /etc/cloud-version
                    echo "template_version: 20200921" >> /etc/cloud-version
                    if [[ -z $pwd_hash ]]; then
                        pwd_hash="$(dd if=/dev/urandom count=1 2>/dev/null | sha1sum | cut -c -28)"
                    fi
                    clish -c "set user admin shell /bin/bash" -s
                    clish -c "set ntp server primary 169.254.169.123 version 4" -s
                    clish -c "set ntp server secondary 0.pool.ntp.org version 4" -s
                    clish -c "set hostname $hostname" -s
                    sic=""
                    blink_config -s "gateway_cluster_member=false&ftw_sic_key=$sic&upload_info=false&download_info=false&admin_hash=$pwd_hash"
                    /opt/CPWAAP/init_waap.sh
                    /opt/CPWAAP/agent/install-cp-nano-agent.sh --install --token "$token"
                    clish -c "set user admin password-hash $pwd_hash" -s
                    if $eic; then
                        echo "Enabling ec2 instance connect"
                        if [[ -d "/etc/ec2-instance-connect" ]]; then
                          ec2-instance-connect-config on
                        else
                          echo "Could not enable eic, /etc/ec2-instance-connect was not found"
                        fi
                    fi
                    if [[ -n $bootstrap ]]; then
                      echo "Invoking bootstrap script"
                      eval $bootstrap
                    fi
                    EOF
  
  network_interface {
    network_interface_id      = aws_network_interface.externalGW_nic.id
    device_index              = 0
  }

  network_interface {
    network_interface_id      = aws_network_interface.internalGW_nic.id
    device_index              = 1
  }

  tags = {
    Name                      = var.GatewayHostname
  }
}

#Output the GW public IP
output "GW_PublicIP" {
  value = aws_eip.eip_gw.public_ip
}