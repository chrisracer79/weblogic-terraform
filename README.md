# WebLogic Terraform Example

This project provides sample Terraform code for building out AWS infrastructure to support a 3-tier Oracle WebLogic deployment. 

## Getting Started

These instructions will allow you to create infrastructure in Amazon from your local machine. 

### Prerequisites

- AWS account
- AWS API user with administrative access
    VPC, EC2
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
aws_access_key_id=<YOUR ACCESS KEY>
aws_secret_access_key=<YOUR SECRET KEY> 
region=us-east-1
```

### Run Terraform


### SSH Access via Bastion

insert ssh config file

## Authors

* **Christopher Parent** - *Initial work* - [ChrisRacer79](https://github.com/chrisracer79)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


