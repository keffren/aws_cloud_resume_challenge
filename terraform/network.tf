# Network for CodeBuild

resource "aws_vpc" "main_vpc" {
    cidr_block       = "10.2.0.0/24"

    # instance_tenancy -  A tenancy option for instances launched into the VPC.
    instance_tenancy = "default"

    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "resume-challenge-net"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "resume-challenge-igw"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }

    tags = {
        Name = "resume-challenge-public-rt"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.2.0.128/25"
    availability_zone = "eu-west-1a"

    tags = {
        Name = "resume-challenge-public"
        Project = "aws-cloud-resume-challenge"
        Terraform = "true"
    }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}