resource "aws_iam_role" "eks-node" {
  name = "eks-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy" "s3-backup" {
  name = "iota-solution-s3-backup-access"
  role = "${aws_iam_role.eks-node.name}"

  policy = <<POLICY
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": "s3:*",
     "Resource": [
      "${aws_s3_bucket.backup.arn}",
      "${aws_s3_bucket.backup.arn}/*"
     ]
   }
 ]
}
POLICY
}

resource "aws_iam_instance_profile" "eks-node" {
  name = "eks-node"
  role = "${aws_iam_role.eks-node.name}"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.13-v*"]
  }

  most_recent = true

  # Owner ID of AWS EKS team
  owners = ["602401143452"]
}

locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' 'eks'
USERDATA
}

resource "aws_key_pair" "jbujny" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6Wehner9f9SsMRf5hVXEcZSV4bY0ry4797QEaoLuJxILsFGdwGX81xLTfppSmIrwzIw2VaSR02IDBEb6gApmIHWZREy4NkQxtyJdEVkYGCVCLaA+S5+mOYfiMR/4M96MWwiMb65ZS2Hx67Zqt+l9MZ90+PH41epwvtJTqSOKGwhQNRXHdAfotpZgojzvBYWp44OytChlntvtRTBPe22Be+KGTIrRzC4q9qMZhxtIWtJyuLWsrowvRMK7Xst8A5tnkxs/QXXCs5DcxHHvrHwhKQ0afdajo8L/vdItL9iDM1E8XRiUSyjajvKYsJfjnFQyqIh+zOdnWC2ewKqEQN5xJ jbujny@jbujny-Precision-3520"
}

resource "aws_launch_configuration" "node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.medium"
  name_prefix                 = "terraform-eks"
  security_groups             = ["${aws_security_group.eks-node.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"
  key_name                    = "${aws_key_pair.jbujny.key_name}"

  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    volume_type           = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "placement" {
  name     = "eks-spread"
  strategy = "spread"
}

resource "aws_autoscaling_group" "node" {
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.node.id}"
  max_size             = 1
  min_size             = 1
  name                 = "eks"
  vpc_zone_identifier  = ["${aws_subnet.eks_a.id}", "${aws_subnet.eks_b.id}", "${aws_subnet.eks_c.id}"]
  placement_group      = "${aws_placement_group.placement.name}"

  tag {
    key                 = "Name"
    value               = "eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/eks"
    value               = "owned"
    propagate_at_launch = true
  }
}

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::172806112519:user/jbujny
      username: jbujny
      groups:
        - system:masters
CONFIGMAPAWSAUTH
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}
