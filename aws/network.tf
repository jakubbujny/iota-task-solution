provider "aws" {
  region     = "${local.region}"
}


resource "aws_vpc" "main" {
  cidr_block = "${local.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    "kubernetes.io/cluster/eks" = "shared"
  }

}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

resource "aws_internet_gateway" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}


resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet.id}"
  }

  tags {
    Name = "internet"
  }
}


resource "aws_subnet" "eks_a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.eks_a}"
  availability_zone = "${local.region}a"

  tags {
    Name = "eks_a"
    "kubernetes.io/cluster/eks" = "shared"
  }
}


resource "aws_route_table_association" "eks_a" {
  subnet_id = "${aws_subnet.eks_a.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_subnet" "eks_b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.eks_b}"
  availability_zone = "${local.region}b"

  tags {
    Name = "eks_b"
    "kubernetes.io/cluster/eks" = "shared"
  }
}


resource "aws_route_table_association" "eks_b" {
  subnet_id = "${aws_subnet.eks_b.id}"
  route_table_id = "${aws_route_table.internet.id}"
}


resource "aws_subnet" "eks_c" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.eks_c}"
  availability_zone = "${local.region}c"

  tags {
    Name = "eks_c"
    "kubernetes.io/cluster/eks" = "shared"
  }
}


resource "aws_route_table_association" "eks_c" {
  subnet_id = "${aws_subnet.eks_c.id}"
  route_table_id = "${aws_route_table.internet.id}"
}


resource "aws_security_group" "eks-cluster" {
  name        = "eks-cluster"
  description = "eks communication"

  vpc_id = "${aws_vpc.main.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "eks"
  }
}



resource "aws_security_group" "eks-node" {
  name        = "eks-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.main.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name"="terraform-eks"
    "kubernetes.io/cluster/eks" = "owned"
  }
}

resource "aws_security_group_rule" "eks-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks-node.id}"
  source_security_group_id = "${aws_security_group.eks-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}


resource "aws_security_group_rule" "eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-node.id}"
  source_security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-node.id}"
  to_port                  = 443
  type                     = "ingress"
}