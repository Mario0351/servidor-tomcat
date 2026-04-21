resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat_security_group_restricted"
  description = "Permitir SSH y 8080 para Tomcat"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [ aws_security_group.apache_sg.id ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "TomcatServer" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  key_name               = "vockey"

  user_data = file("${path.module}/scripts/install_tomcat.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "Tomcat-Server-HTTP"
  }
}