# setup the network
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name     = "${var.demo_prefix}-vpc"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id     = "${aws_vpc.main.id}"
  depends_on = ["aws_vpc.main"]

  tags = {
    Name     = "${var.demo_prefix}-gw"
  }
}
resource "aws_route" "default" {
  route_table_id            = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.gw.id}"
  depends_on                = ["aws_vpc.main", "aws_internet_gateway.gw"]
}
resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_availability_zone}"
  depends_on = ["aws_vpc.main"]

  tags = {
    Name     = "${var.demo_prefix}-subnet"
  }
}
resource "aws_network_acl" "main" {
  vpc_id        = "${aws_vpc.main.id}"
  subnet_ids    = ["${aws_subnet.main.id}"]
  depends_on    = ["aws_vpc.main", "aws_subnet.main"]

  # allow incoming pings
  ingress {
    rule_no     = 50
    action      = "allow"
    from_port   = 0
    to_port     = 0
    icmp_code   = -1
    icmp_type   = -1
    protocol    = "icmp"
    cidr_block  = "0.0.0.0/0"
  }
  # allow HTTPS
  ingress {
    rule_no     = 100
    action      = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
  }
  # allow HTTP
  ingress {
    rule_no     = 200
    action      = "allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
  }
  # allow SSH
  ingress {
    rule_no     = 300
    action      = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
  }
  # allow established/related
  ingress {
    rule_no     = 400
    action      = "allow"
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
  }

  egress {
    rule_no     = 100
    action      = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }

  tags = {
    Name       = "${var.demo_prefix}-acl"
  }
}
