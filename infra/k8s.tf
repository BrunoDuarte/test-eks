resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy 
  enable_dns_support   = var.dnsSupport 
  enable_dns_hostnames = var.dnsHostNames

  tags = {
    Name = "k8s-VPC"
  }
}

resource "aws_subnet" "k8s_subnet1" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.subnetCIDRblock1
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZoneA

  tags = {
    Name = "k8s-Subnet1"
  }
}
resource "aws_subnet" "k8s_subnet2" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.subnetCIDRblock2
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZoneB

  tags = {
    Name = "k8s-Subnet2"
  }
}

resource "aws_security_group" "kubernets" {
  name        = "allow_node_com"
  description = "Allow Master Nodes communications"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description      = "Allow Master Node communications"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = var.ingressCIDRblock
  }
  
  ingress {
    description      = "NFS"
    from_port        = 111
    to_port          = 111
    protocol         = "tcp"
    cidr_blocks      = var.ingressCIDRblock
  }

  ingress {
    description      = "NFS"
    from_port        = 111
    to_port          = 111
    protocol         = "udp"
    cidr_blocks      = var.ingressCIDRblock
  }

  ingress {
    description      = "NFS"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = var.ingressCIDRblock
  }

  ingress {
    description      = "NFS"
    from_port        = 2049
    to_port          = 2049
    protocol         = "udp"
    cidr_blocks      = var.ingressCIDRblock
  }

  ingress {
    description      = "NFS"
    from_port        = 1110
    to_port          = 1110
    protocol         = "tcp"
    cidr_blocks      = var.ingressCIDRblock
  }

  ingress {
    description      = "NFS"
    from_port        = 1110
    to_port          = 1110
    protocol         = "udp"
    cidr_blocks      = var.ingressCIDRblock
  }
  
  ingress {
    description      = "NFS"
    from_port        = 4045
    to_port          = 4045
    protocol         = "tcp"
    cidr_blocks      = var.ingressCIDRblock
  }

  ingress {
    description      = "NFS"
    from_port        = 4045
    to_port          = 4045
    protocol         = "udp"
    cidr_blocks      = var.ingressCIDRblock
  }

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 10250
    to_port     = 10252
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 6783
    to_port     = 6784
    protocol    = "tcp"
  }

  ingress {
    self = true
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.ingressCIDRblock
  }

  tags = {
    Name = "k8s-Security_Group"
  }
}

# create VPC Network access control list
resource "aws_network_acl" "My_VPC_Security_ACL" {
  vpc_id = aws_vpc.k8s_vpc.id
  subnet_ids = [ aws_subnet.k8s_subnet1.id, aws_subnet.k8s_subnet2.id ]
# allow ingress port 22
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 0
    to_port    = 0
  }

  # allow egress port 22 
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 0 
    to_port    = 0
  }

  tags = {
      Name = "k8s-ACL"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW" {
 vpc_id = aws_vpc.k8s_vpc.id
 tags = {
        Name = "k8s-IG"
  }
}

# Create the Route Table
resource "aws_route_table" "My_VPC_route_table" {
 vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = var.destinationCIDRblock
    gateway_id = aws_internet_gateway.My_VPC_GW.id
  }

 tags = {
        Name = "k8s-RT"
  }
}

# Create the Internet Access
resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_VPC_association1" {
  subnet_id      = aws_subnet.k8s_subnet1.id
  route_table_id = aws_route_table.My_VPC_route_table.id
}

resource "aws_route_table_association" "My_VPC_association2" {
  subnet_id      = aws_subnet.k8s_subnet2.id
  route_table_id = aws_route_table.My_VPC_route_table.id
}
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"

  cluster_version = var.clusterVersion
  cluster_name    = var.clusterName
  vpc_id          = aws_vpc.k8s_vpc.id
  subnets         = [aws_subnet.k8s_subnet1.id, aws_subnet.k8s_subnet2.id ]

  worker_groups = [
    {
      instance_type = var.clusterType
      asg_max_size  = var.workersNumber
    }
  ]
}