variable "instanceTenancy" {
    default = "default"
}
variable "clusterType" {
    default = "t2.medium"
}
variable "workersNumber" {
  default = 3
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "availabilityZoneA" {
     default = "us-east-1a"
}
variable "availabilityZoneB" {
     default = "us-east-1b"
}
variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}
variable "subnetCIDRblock1" {
    default = "10.0.1.0/24"
}
variable "subnetCIDRblock2" {
    default = "10.0.2.0/24"
}
variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "mapPublicIP" {
    default = true
}
variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "clusterVersion" {
  default = "1.21"
}

variable "clusterName" {
  default = "trustd"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}