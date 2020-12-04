# Adjust vars for the AWS settings and region
# These VPCs, subnets, and gateways will be created as part of the demo
#path_to_your_aws_credentials_file = "yourPath/.aws/credentials"
public_key_path            = "~/.aws/MYPUBKEY.pem"
aws_account_id             = "000000000000"
aws_access_key             = "AAAAAAAAAAAAAAAAAAAA"
aws_secret_key             = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
aws_region                 = "us-east-1"
ssh_key_name               = "MYPUBKEY"
aws_vpc_cidr               = "10.0.0.0/16"
aws_external_subnet_cidr   = "10.0.0.0/24"
aws_internal_subnet_cidr   = "10.0.1.0/24"
#chkp_instance_size = "c5.xlarge"
ws_size             = "t2.micro"
SICKey              = "SICpassword"
AllowUploadDownload = "true"
pwd_hash = "$1$.JO6aT3z$ZMeFq3xHObD/jFhyAB1dP/"
root_password = "CpR0ck$1!"
InfinityToken = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
gw_size_type = "c5.xlarge"
GatewayHostname = "TF-Infinity-GW"
EnableInstanceConnect = true
AllocatePublicAddress = true

my_user_data = <<-EOF
                    #!/bin/bash
                    sudo yum update –y 
                    sudo yum install -y docker 
                    sudo service docker start 
                    sudo usermod -a -G docker ec2-user
EOF

cg_size                        = "c5.large"

Open the IAM console at https://console.aws.amazon.com/iam/ .
On the navigation menu, choose Users.
Choose your IAM user name (not the check box).
Open the Security credentials tab, and then choose Create access key.
To see the new access key, choose Show. ...
To download the key pair, choose Download .