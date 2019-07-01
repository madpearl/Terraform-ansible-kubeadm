#Terraform main config file

	#Defining AWS region
provider "aws" {
  region = "${var.aws_region_name}"
}

	#SSH key name
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${file(var.pub_key)}"
}

	#Selecting Ubuntu AMI image
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] #Canonical
}

data "aws_security_group" "default" {
  name = "default"
}

	#Kubernetes instance
resource "aws_instance" "main" {
  key_name      = "${aws_key_pair.ssh_key.key_name}"
  ami           = "${data.aws_ami.ami.id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"

	#Install python on the instance
  provisioner "remote-exec" {
    inline = ["sudo apt install -y python"]

    connection {
      host	  = "${self.public_ip}"
      type        = "ssh"
      user        = "ubuntu"
    }
  }

	#Ansible related playbook
provisioner "local-exec" {
  command = "ansible-playbook -u ubuntu --private-key ${var.ssh_key_name} -i ${self.public_ip}, site.yml"
}

  tags = {
  Name = "Kubernetes"
 }
}

	#Getting local machine puplic IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

	#Adding rule to security group
resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = "${data.aws_security_group.default.id}"
}

	#Adding rule to security group
resource "aws_security_group_rule" "kube_access" {
  type        = "ingress"
  from_port   = 6443
  to_port     = 6443
  protocol    = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = "${data.aws_security_group.default.id}"
}


