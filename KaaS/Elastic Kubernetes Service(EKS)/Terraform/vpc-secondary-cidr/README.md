# This template demonstrate the use of VPC Seoncdary CIDR with EKS.

### Why Secondary CIDR?
It is often required to expand the IP address space for an existing VPC, it happens when you give a tight CIDR block to the VPC at the time of creation. In such cases, you can add a secondary CIDR block to the VPC.  

EKS can adopt the secondary CIDR block without affecting the existing resources. This is useful when you want to add more subnets to the VPC or when you want to create new EKS clusters in the same VPC.

### What is required?
1. Create a secondary CIDR block for the VPC.
2. Create a new subnet in the secondary CIDR block, associate them with the existing route table.
3. Adjust the EKS Worker Node Group / Karpenter / ... to use the new subnet.
4. Add `ENIConfig` for VPC CNI to use the new subnet.


