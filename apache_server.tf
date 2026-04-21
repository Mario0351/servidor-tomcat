resource "aws_security_group" "apache_sg" {
  name = "apache_security_group"
  description = "permitir ssh(22) y http(80)"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]#trafico puerto 80 desde cualquier host
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]#trafico puerto 22 desde cualquier host
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "ApacheServer" {
  ami = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.apache_sg.id]
  key_name = "vockey"

  user_data = templatefile("${path.module}/scripts/install_apache.sh", {
    tomcat_ip = aws_instance.TomcatServer.private_ip
  })

  tags = {
    Name = "Apache_Proxy_Server"
  }
}