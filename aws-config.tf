# Template for aws compute cloud
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.58.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "homework14key" {
  key_name = "homework14key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGp0nXCGiHDN6MourDP3LOc3wU0dSTTIWYLRJuMAW69U root@study14"
}

resource "aws_security_group" "homework14" {
  name = "homework14"
  description = "open 22 ssh, 8080 ports for tomcat"
  vpc_id = "vpc-06522b293159a2cd7"

  ingress {
    description = "only for tomcat pages"
    protocol  = "tcp"
    from_port = 8080
    to_port   = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow ssh only for me"
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["158.160.59.98/32"]
  }

  egress {
    description = "allow all to outside"
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "homework14-build" {
  ami = "ami-09cd747c78a9add63"
  instance_type = "t2.micro"
  key_name = "homework14key"
  vpc_security_group_ids = ["${aws_security_group.homework14.id}"]
  subnet_id = "subnet-0414e6106afcc7dec"
  tags = {
    Name = "homework14-build"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y git maven awscli
git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
cd boxfuse-sample-java-war-hello && mvn package
export AWS_ACCESS_KEY_ID=********
export AWS_SECRET_ACCESS_KEY=********
export AWS_DEFAULT_REGION=us-east-1
aws s3 mb s3://homework14volume.ru
aws s3 cp target/hello-1.0.war s3://homework14volume.ru
EOF
}

resource "aws_instance" "homework14-prod" {
  ami = "ami-09cd747c78a9add63"
  instance_type = "t2.micro"
  key_name = "homework14key"
  vpc_security_group_ids = ["${aws_security_group.homework14.id}"]
  subnet_id = "subnet-0414e6106afcc7dec"
  tags = {
    Name = "homework14-prod"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y default-jdk tomcat9 awscli
export AWS_ACCESS_KEY_ID=********
export AWS_SECRET_ACCESS_KEY=********
export AWS_DEFAULT_REGION=us-east-1
aws s3 cp s3://homework14volume.ru/hello-1.0.war /tmp/hello-1.0.war
sudo cp /tmp/hello-1.0.war /var/lib/tomcat9/webapps/
EOF
}