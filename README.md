# WebLogic Terraform Example

This project provides sample Terraform code for building out AWS infrastructure to support a 3-tier Oracle WebLogic deployment. 

## Getting Started

These instructions will allow you to create infrastructure in Amazon from your local machine. This Terraform can be used as a starting point for creating a 3-tier network deployment for hosting WebLogic applications that are fronted by load balancers and backed by an Oracle Database.

The Terraform code here can be modified to suit your needs. 

### Infrastructure created
The following resources are created

- VPC in us-east-1 region
- Public subnets for edge services across two availability zones
- Private subnets for WebLogic across two zones
- Private subnets for Database across two zones
- Network ACLs and Security Group rules to enable ssh, http/https and sqlnet traffic
- Internet and NAT gateway to facilitate traffic to/from Internet
- Bastion, application, and database servers

It is important to note that this Terraform example does not install any software on any of the servers, including WebLogic. This is left as an exercise for the user. 

## Learn More About Oracle WebLogic or Terraform on Udemy

If you wish to learn more about Oracle WebLogic or Hashicorp Terraform, I offer two popular courses on Udemy.

Please check out:

- [Oracle WebLogic 12c for Administrators](https://www.udemy.com/oracle-weblogic-12c-for-administrators/?couponCode=LEARNWLS49)
- [Building Cloud Infrastructure using Terraform](https://www.udemy.com/building-cloud-infrastructure-with-terraform/?couponCode=LEARNTF18)


### Prerequisites

- AWS API user with administrative access
    - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
- Terraform 0.11.8+
    - https://www.terraform.io/downloads.html
- AWS Terraform Provider
    - Will be downloaded via terraform init

## Usage
### Generate SSH keys

The SSH key generated is used to provide SSH access to EC2 instances.

This command will generate a public/private SSH keypair. The public key will be loaded onto any EC2 instances that are created, while the private key will be used to authenticate into those EC2 instances.

```sh
$ ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws_rsa
```

### Configure AWS Credentials
The AWS Terraform Provider is configured to load AWS access credentials from an AWS credentials file. 

#### Exmaple AWS Config (`~/.aws/credentials`)
```
[default]
aws_access_key_id=<YOUR AWS ACCESS KEY>
aws_secret_access_key=<YOUR AWS SECRET KEY> 
region=us-east-1
```

### Initialize Terraform

```sh
$ cd weblogic-terraform
$ terraform init
```

### Create Infrastructure

```sh
$ terraform plan
$ terraform apply
```

### Destroy Infrastructure

```sh
$ terraform destroy
```


### SSH Access via Bastion
All SSH access to EC2 instances is done through the bastion server. In order to SSH into any one of the servers in a private subnet, you must configure the bastion as a proxy in your SSH config file as follows.

#### SSH config example (`~/.ssh/config`)

Be sure to replace the IP addresses shown below with the actual IP addresses created for any EC2 instaces.

```
Host jumpbox
  HostName 34.239.123.252
  User ec2-user
  IdentityFile ~/.ssh/aws_rsa
  ProxyCommand none

Host weblogic1
  HostName 10.0.100.4
  User ec2-user
  IdentityFile ~/.ssh/aws_rsa
  ProxyCommand ssh jumpbox -W %h:%p
```

## Next Steps

## Authors

* **Christopher Parent** - *Initial work* - [ChrisRacer79](https://github.com/chrisracer79)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


