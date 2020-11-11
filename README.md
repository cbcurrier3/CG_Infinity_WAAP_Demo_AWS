# CG_Infinity_WAAP_Demo_AWS

Based on the attached lab (pdf) by Amit Schnitzer
DevSecOps
30/10/2020

Prerequisites
* AWS account
 - aws_account_id
 - aws_access_key
 - aws_secret_key
 - choose aws region
 - availabiity zone
 - AWS Private .pem file - specified in terraform.tfvars
* Check Point Infinity Portal Account
* follow step 7 in the WAAP Labe Guide to generate a token
* update variables.tf file and update any other variables there. 

Perform terraform init, terraform plan, terraform apply.

This will deploy a webserver and CG Infinity GW and get you in the LAB to Configuring WAAP protection.
Perform steps 6. (c), 6. (d) and 6.(e) in the guide.
Then move on to Configuring WAAP protection.

terraform destroy will remove the web server and the Gateway from AWS
