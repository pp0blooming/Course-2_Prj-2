# # Creation of VM in AWS 
#  - Security group 

resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"

  #  - INBOUND

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  #  - OUTBOUND RULES

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#  - key pair

resource "aws_key_pair" "k_deployer" {
  key_name   = "deployer-key1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCihAunULgX4uVu4yQYIclQG3DKf9glPN9meAglipNRg7UGwRYM7P083Y07h+qzubVAqgztunKno3jMmKD8GFtLuH23nilCcFKIaTHx0XM26yk3nhnnBDBbB0pYcuC4v6pvmOH2Xyg42SlnWSP5hjdlDhMmyO6dZ4oPQ7EKFtg8C9Dl042X4h8kR5JA8VLfky7xCY/UjSJS3serWKPjdTwJ6/MnjrxED8tLwJVevYFtUP0dM9MJe5swWCRpd6t5mz8zkOsoaSEH5dHsdAMEzXAUKKrRs8fhTo89FBXewNF9CmXEBWHVP1CgyAk58eAMDnKhzEu37J5JWnWBWZNIU2NZDRtz4h59sGyVvsMKCe+1aB4b3ChUeNd5+jHLGQyvGRFCqYE8EOiw+t8OjezpXW2oNHHbSHXURTdLJz+tfPlwxWzrWGqDNL+WGaMl95YCptDHbW/oKOqgQYbFUqRiZkWyouhenWqtDCqCHR1oP6vuefTfApWGt0Y/MdOVriwae1E= ubuntu-node1@ubuntunode1-virtual-machine"
}

resource "aws_instance" "amzn-linux" {
  ami                    = "ami-090fa75af13c156b4"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.k_deployer.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "Linux-Node"
    "ENV"  = "Dev"
  }
  depends_on = [aws_key_pair.k_deployer]
}

####### Ubuntu VM #####

resource "aws_instance" "ubuntu" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.k_deployer.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "UBUNTU-Node"
    "ENV"  = "Dev"
  }

  # Remotely execute commands to install Java, Python, Jenkins
  provisioner "remote-exec" {
    # Type of connection to be established      
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./k_deployer")
      host        = self.public_ip
    }

    inline = [
      "sudo apt update && sudo apt upgrade ",
      "sudo apt install -y python2",
      "sudo apt install -y python3",
    ]

    # inline = [
    #   "sudo apt update && sudo apt upgrade ",
    #   "sudo apt install -y python2",
    #   "sudo apt install -y python3.8",
    #   "sudo apt-get install -y openjdk-8-jre",
    #   "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
    #   "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ >  /etc/apt/sources.list.d/jenkins.list'",
    #   "sudo apt-get update",
    #   "sudo apt-get install -y jenkins",
    #   "sudo systemctl enable jenkins",
    #   "sudo systemctl start jenkins",
    #   "sudo systemctl status jenkins",
    #   "sudo apt-get install -y docker docker.io",
    #   "sudo chmod 777 /var/run/docker.sock",
    #   "sudo cat  /var/lib/jenkins/secrets/initialAdminPassword",
    # ]

    # inline = [
    #   "sudo yum update -y",
    #   "python --version",
    #   "python3 --version",
    #   "sudo apt install -y python3.8",
    #   "sudo amazon-linux-extras install java-openjdk11 -y",
    #   "sudo yum install java-1.8.0-openjdk",
    #   "java -version",
    #   "sudo wget -O /etc/yum.repos.d/jenkins.repo   https://pkg.jenkins.io/redhat-stable/jenkins.repo",
    #   "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
    #   "sudo yum upgrade",
    #   "sudo yum install jenkins -y",
    #   "sudo systemctl enable jenkins",
    #   "sudo systemctl start jenkins",
    #   "sudo systemctl status jenkins",
    #   "sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc",
    #   "sudo yum install -y yum-utils",
    #   "sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo",
    #   "sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin",
    #   "yum list docker-ce --showduplicates | sort -r",
    #   "",
    #   "sudo apt-get install -y docker docker.io",
    #   "sudo chmod 777 /var/run/docker.sock",
    #   "sudo cat  /var/lib/jenkins/secrets/initialAdminPassword",
    # ]

  }
  depends_on = [aws_key_pair.k_deployer]
}