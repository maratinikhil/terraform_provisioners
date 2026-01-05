data "aws_vpc" "My_exist_vpc" {
    filter {
        name = "tag:Name"
      values = [ "MyTerraVpc2" ]
    }
}


data "aws_security_group" "My_exist_SG" {
    filter {
      name = "Name"
      values = [ "mysg" ]
    }
}


data "aws_ami" "My_exist_ami" {
    filter {
      name = "AMI name"
      values = [ "ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-20250625" ]

    }
}

resource "aws_key_pair" "Mykey" {
    public_key = file("~/id_ed25519.pub")
    key_name = "Mykeynew"
}

resource "aws_instance" "myownec2" {
    ami = data.aws_ami.My_exist_ami.id
    key_name = aws_key_pair.Mykey.key_name
    instance_type = "t3.micro"
    vpc_security_group_ids = [ data.aws_security_group.My_exist_SG.id ]
    associate_public_ip_address = true
    tags = {
        Name = "MyEc2"

    }

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("~/id_ed25519.pub")
        host = aws_instance.myownec2.public_ip
    }

    provisioner "remote-exec" {
        inline = [ "sudo apt update",
                   "sudo apt install nginx -y" 
        ]
    }
}
