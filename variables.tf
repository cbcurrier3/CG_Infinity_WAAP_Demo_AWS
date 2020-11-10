variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "aws_account_id" {
  default = "000000000000"
}

variable "aws_access_key" {
  default = "AAAAAAAAAAAAAAAAAAAA"
}

variable "aws_secret_key" {
  default = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

###variable "path_to_your_aws_credentials_file" {
###}

variable "ssh_key_name" {
  description = "Desired name of AWS key pair"
}
variable "aws_vpc_cidr" {
}
variable "aws_external_subnet_cidr" {
}
variable "aws_internal_subnet_cidr" {
}
variable "my_user_data" {
}

variable "GatewayHostname"{
   default = "TF-Infinity-GW"
}

variable "EnableInstanceConnect" {
    default = true
}
variable "AllocatePublicAddress" {
    default = true
}


### Gateway
variable "SICKey" {
}
variable "AllowUploadDownload" {
}
variable "pwd_hash" {
}
variable "gw_size_type" {
   default = "c5.large"
}

variable "InfinityToken" {
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1
}
variable "primary_az" {
  description = "primary AZ"
  default     = "us-east-1"
}
variable "secondary_az" {
  description = "secondary AZ"
  default     = "us-east-1"
}

variable "ws_size" {
}
variable "cg_size" {
}
