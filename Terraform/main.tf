provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true  # Enable auto-assign public IP

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "main-route-table"
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# Attach Policies to EKS Cluster IAM Role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_service_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Create EKS Cluster
resource "aws_eks_cluster" "wisecow_demo" {
  name     = "wisecow-demo"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy_attachment,
    aws_iam_role_policy_attachment.eks_cluster_service_policy_attachment,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller_attachment
  ]
}

# Create EKS Node Group IAM Role
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks_node_group_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attach Policies to EKS Node Group IAM Role
resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment_1" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment_2" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment_3" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment_4" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Create EKS Node Group
resource "aws_eks_node_group" "wisecow_demo_nodes" {
  cluster_name    = aws_eks_cluster.wisecow_demo.name
  node_group_name = "wisecow-demo-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = aws_subnet.public.*.id

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = aws_key_pair.deployer.key_name
  }

  tags = {
    Name = "wisecow-demo-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_role_attachment_1,
    aws_iam_role_policy_attachment.eks_node_group_role_attachment_2,
    aws_iam_role_policy_attachment.eks_node_group_role_attachment_3,
    aws_iam_role_policy_attachment.eks_node_group_role_attachment_4
  ]
}

# Create SSH Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/deployer-key.pub")
}

# Output EKS Cluster Endpoint and ARN
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.wisecow_demo.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.wisecow_demo.arn
}
