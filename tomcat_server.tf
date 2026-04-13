resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat_security_group_http"
  description = "Permitir SSH y HTTP para Tomcat"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  key_name               = "DAWEB_Key"

  user_data = file("${path.module}/scripts/install_tomcat.sh")

  tags = {
    Name = "Tomcat-Server-HTTP"
  }
}