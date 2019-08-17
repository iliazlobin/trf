resource "aws_eks_cluster" "this" {
  name     = var.tags.Name
  role_arn = "${module.eks_cluster_role.iam_role_arn}"
  version  = var.aws_eks_cluster.version

  vpc_config {
    security_group_ids      = ["${var.eks_cluster-sg}"]
    subnet_ids              = ["${var.network-private_subnet_ids}"]
    endpoint_private_access = true
    endpoint_public_access  = "${var.eks_cluster-endpoint_public_access}"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = "${aws_eks_cluster.this.name}"
}
