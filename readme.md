# Terraform | AWS VPC with public and private subnets

**Terraform** is an Infrastructure as Code (IaC) tool by HashiCorp to build, change, and version infrastructure safely and efficiently with configuration files. HashiCorp Configuration Language (HCL) is the language used to write configurations in Terraform. Terraform can be used to provide infrastructure on different platforms  and services such as AWS, Docker, Kubernetes, Google Cloud Platform (GCP), Azure and more.

### Contents:

- **Prerequisites**
- **Installing Terraform and initializing working directory**
- **Creating Terraform configuration for this AWS VPC project**
- **Validating, creating and executing the plan**
- **Verifying the AWS VPC project**

###  Prerequisites

***

- Knowledge about AWS, Terraform
- An AWS account, IAM user or role
- A system to install Terraform

### Installing Terraform and initializing working directory

***

In this project I'm running Terraform on an EC2 Linux instance with IAM role attached.  

> *Steps*

- Download Terraform package from [here](https://www.terraform.io/downloads.html).

- Unzip the downloaded package file and move it to ```/usr/local/bin```.

- ```terraform version``` command will display the version of Terraform installed.

  ```
  wget https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip
  unzip terraform_1.0.9_linux_amd64.zip
  mv terraform /usr/local/bin/
  terraform version
  ```

  ![screenshot](/imgs/img1.png)

 

- Create a project directory for the Terraform configuration file.

- Create ```provider.tf``` file in that directory with below codes for interacting terraform with aws for creating resources.

  ```
  provider "aws" {
     region = "ap-south-1"
  }
  ```

  

- Initilize the project directory using command ```terraform init```

  ```
  mkdir vpc_project
  cd vpc_project
  vi provider.tf
  terraform init 
  ```

  ![screenshot](img/img1)

### Creating Terraform configuration for this AWS VPC project

***

*Note*: All the projects configuration files should be created in the initilized project directory. Also, file names, input variable names and its values can be modified as per your requirement. Other than variable definition file (.tfvars ), all other configuration file should have ( .tf ) extension

- #### Declare below input variables in ```variables.tf``` file

  ```
  variable "ami" {}
  variable "type" {}
  variable "project" {}
  variable "vpc_cidr" {}
  variable "vpc_subnets" {}
  ```

- #### Passing input variable values in a variable definitions (.tfvars) file ```variables.tfvars```

  ```
  ami			= "ami-041d6256ed0f2061c"
  type		= "t2.micro"
  project		= "mkduo"
  vpc_cidr 	= "172.14.0.0/16"
  vpc_subnets = "3"
  ```

- ### Creating main configuration for provisioning VPC infrastructure

  ***

  

  > **Fetching list of availability zones**

  Availability Zones data source allows access to the list of AWS Availability Zones which can be accessed by an AWS account within the region configured in the provider.

  ```
  data "aws_availability_zones" "az" {
    state = "available"
  }
  ```

  

  > **Create VPC**

  ```
  resource "aws_vpc" "vpc" {
    cidr_block                  = var.vpc_cidr
    instance_tenancy            = "default"
    enable_dns_support          = true
    enable_dns_hostnames        = true
    tags = {
      Name        = "vpc"
      project     = "${var.project}-vpc"
    }
    
    lifecycle {
      create_before_destroy = true
    }
  }
  ```

  

  > **Create a VPC Internet Gateway**

  Internet Gateway allows communication between your VPC and the internet. It supports IPv4 and IPv6 traffic.

  ```
  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
  
    tags = {
      Name        = "${var.project}-igw"
      project     = var.project
    }
    
    lifecycle {
      create_before_destroy = true
    }
  
  }
  ```

   

  > **Create Subnets**

  In this project I'm creating 3 public and 3 private subnets inside the new vpc. I'm creating VPC in Mumbai region so there are 3 AZ's available and in each AZ I'm adding a public and private subnet.

  ```cidrsubnet``` function is used in this project, Terraform itself calculates a sequence of consecutive IP address ranges within a particular CIDR prefix.

  ​														

  ​	                                                     **Public subnet1 **

  ```
  resource "aws_subnet" "public1" {
    vpc_id                    = aws_vpc.vpc.id
    cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,0)
    map_public_ip_on_launch   = true
    availability_zone         = data.aws_availability_zones.az.names[0]
    tags = {
      Name    = "${var.project}-public1"
      project = var.project
    }
  
   lifecycle {
      create_before_destroy = true
    }
    
  }
  ```

  ​                                                         **Public Subnet2**

  

  ```
  resource "aws_subnet" "public2" {
    vpc_id                    = aws_vpc.vpc.id
    cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,1)
    map_public_ip_on_launch   = true
    availability_zone         = data.aws_availability_zones.az.names[1]
    tags = {
      Name    = "${var.project}-public2"
      project = var.project
    }
  
    lifecycle {
      create_before_destroy = true
   }
    
  }
  ```

  ​                                                         **Public Subnet3**

  ```
  resource "aws_subnet" "public3" {
    vpc_id                    = aws_vpc.vpc.id
    cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,2)
    map_public_ip_on_launch   = true
    availability_zone         = data.aws_availability_zones.az.names[2]
    tags = {
      Name    = "${var.project}-public3"
      project = var.project
    }
  
    lifecycle {
      create_before_destroy = true
    }
    
  }
  ```

  

  ​                                                         **Private Subnet1**

  ```
  resource "aws_subnet" "private1" {
    vpc_id                    = aws_vpc.vpc.id
    cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,3)
    map_public_ip_on_launch   = false
    availability_zone         = data.aws_availability_zones.az.names[0]
    tags = {
      Name    = "${var.project}-private1"
      project = var.project
    }
  
    lifecycle {
      create_before_destroy = true
    }
    
  }
  ```

  ​                                                         **Private Subnet2**

  ```
  resource "aws_subnet" "private2" {
    vpc_id                    = aws_vpc.vpc.id
    cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,4)
    map_public_ip_on_launch   = false
    availability_zone         = data.aws_availability_zones.az.names[1]
    tags = {
      Name    = "${var.project}-private2"
      project = var.project
    }
  
    lifecycle {
      create_before_destroy = true
    }
    
  }
  ```

  ​                                                         **Private Subnet3**

  ```
  resource "aws_subnet" "private3" {
    vpc_id                    = aws_vpc.vpc.id
    cidr_block                = cidrsubnet(var.vpc_cidr,var.vpc_subnets,5)
    map_public_ip_on_launch   = false
    availability_zone         = data.aws_availability_zones.az.names[2]
    tags = {
      Name    = "${var.project}-private3"
      project = var.project
    }
  
    lifecycle {
      create_before_destroy = true
    }
    
  }
  ```

  > **Creating Elastic Ip for NatGateWay**

  ```
  resource "aws_eip" "eip" {
    vpc      = true
    tags = {
      Name = "${var.project}-eip"
      Project = var.project
    }
  }
  ```

  

  > **Create  NAT Gateway**

  A NAT gateway is a Network Address Translation (NAT) service. You can use a NAT gateway so that instances in a private subnet can connect to services outside your VPC but external services cannot initiate a connection with those instances.

  ```
  resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.public1.id
  
    tags = {
      Name    = "${var.project}-nat"
      project = var.project
    }
  }
  ```

  

  > **Create Route Tables for Public and Private subnets**

  ##### *Route Table for Public  subnet*

  ```
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
  
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
      }
   
  
    tags = {
      Name    = "${var.project}-public-rtb"
      project = var.project
    }
  }
  ```

  ##### *Route Table for Private subnet*

  ```
  resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id
  
    route {
            cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat.id
      }
   
    tags = {
      Name    = "${var.project}-private-rtb"
      project = var.project
    }
  }
  ```

  > **Creating an association between public route table and public subnets**

  ```
  resource "aws_route_table_association" "public1" {
    subnet_id      = aws_subnet.public1.id
    route_table_id = aws_route_table.public.id
  }
  
  resource "aws_route_table_association" "public2" {
    subnet_id      = aws_subnet.public2.id
    route_table_id = aws_route_table.public.id
  }
  
  resource "aws_route_table_association" "public3" {
    subnet_id      = aws_subnet.public3.id
    route_table_id = aws_route_table.public.id
  }
  ```

  > **Creating an association between private route table and private subnets**

  ```
  resource "aws_route_table_association" "private1" {
    subnet_id      = aws_subnet.private1.id
    route_table_id = aws_route_table.private.id
  }
  
  resource "aws_route_table_association" "private2" {
    subnet_id      = aws_subnet.private2.id
    route_table_id = aws_route_table.private.id
  }
  
  resource "aws_route_table_association" "private3" {
    subnet_id      = aws_subnet.private3.id
    route_table_id = aws_route_table.private.id
  }
  ```

  > Project directory will have following list of configurations

  ```
  [root@kamal-workbox vpc_project]# ls -l
  total 20
  -rw-r--r-- 1 root root 7203 Oct 26 05:12 main.tf
  -rw-r--r-- 1 root root   44 Oct 26 05:12 provider.tf
  -rw-r--r-- 1 root root  108 Oct 26 05:12 variables.tf
  -rw-r--r-- 1 root root  133 Oct 26 05:12 variables.tfvars
  [root@kamal-workbox vpc_project]# 
  ```

### **Validating, creating and executing the plan**

- *Validate*

  ```terraform validate``` command validates the configuration files in a directory, Validate runs checks that verify whether a configuration is syntactically valid and internally consistent, regardless of any provided variables or existing state. It is thus primarily useful for general verification of reusable modules, including correctness of attribute names and value types.

- *Plan*

  *terraform plan* command creates an execution plan. Gives an overview of which resources will be provisioned.

- *Apply*

  ```terraform apply``` command executes the actions proposed in a Terraform plan. 

  *Note*: As variable definitions file (.tfvars) is used, this file needs to specified on terraform plan and  apply.

  ```
  terraform validate
  terraform plan -var-file=variables.tfvars
  terraform apply -var-file=variables.tfvars 
  ```

  ​	-auto-approve can be used in with apply to override the prompt to approve.

  ![screenshot](/home/kamal/Desktop/img3.png)

   

  ![screenshot](/home/kamal/Desktop/img4.png)

  ![screenshot](/home/kamal/Desktop/img5.png)

  

- >  **list resources**

  ```terraform state list``` command gives the list of resources from terrafrom state about the created infrastructure and configuration.

  ```
  [root@kamal-workbox vpc_project]# terraform state list
  data.aws_availability_zones.az
  aws_eip.eip
  aws_internet_gateway.igw
  aws_nat_gateway.nat
  aws_route_table.private
  aws_route_table.public
  aws_route_table_association.private1
  aws_route_table_association.private2
  aws_route_table_association.private3
  aws_route_table_association.public1
  aws_route_table_association.public2
  aws_route_table_association.public3
  aws_subnet.private1
  aws_subnet.private2
  aws_subnet.private3
  aws_subnet.public1
  aws_subnet.public2
  aws_subnet.public3
  aws_vpc.vpc
  [root@kamal-workbox vpc_project]#
  ```

  
