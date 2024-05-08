# This template provision an EKS cluster with Access Entries

[Access Entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html) is a new method to access EKS cluster introduced in 2023 ([See announcement](https://aws.amazon.com/blogs/containers/a-deep-dive-into-simplified-amazon-eks-access-management-controls/)), as an alternative and replacement to the existing [aws-auth configmap](https://docs.aws.amazon.com/eks/latest/userguide/auth-configmap.html). 

### What will be deployed?
- [vpc.tf](vpc.tf): Base instrastructure for the EKS Cluster (VPC, Security Group, NAT Gateway...) 
- [eks.tf](eks.tf): EKS Cluster v1.29, managed node group, and Access Entries
- [iam.tf](iam.tf): IAM Role associated with the Access Entries

### How to verify the set up
1. In the EKS Console, go to "Access" -> "IAM access entries"    
  There should be an entry for the role "access-entries-admin-role" and attached with "AmazonEKSClusterAdminPolicy"

2. Use this Role to access the cluster locally  
    a. Assume Role in to the Access Entries' Role   
      (Find the `<Role ARN>` value from Terraform Output: `iam_role`)   
      ```sh
      aws sts assume-role --role-arn "<Role ARN>" --role-session-name AWSCLI-Session
      ```
      

      Output:
      ```sh
      {
        "Credentials": {
          "AccessKeyId": "...",
          "SecretAccessKey": "...",
          "SessionToken": "...",
          ...
        },
        ...
      }
      ```

    b. Use the AWS Credential above and set environemnt variables
      ```sh
        export AWS_ACCESS_KEY_ID=<AccessKeyId>
        export AWS_SECRET_ACCESS_KEY=<SecretAccessKey>
        export AWS_SESSION_TOKEN=<SessionToken>
      ```
      Verify the Assume-Role
      ```sh
        aws sts get-caller-identity
      ```

      The output should show similar to below, it indicate a successful assume role setting
      ```sh
      {
        "UserId": "...:AWSCLI-Session"
        "Account": "...",
        "Arn": "arn:...:sts::...:assumed-role/access-entries-admin-role/AWSCLI-Session"
      }
      ```

    c. Get the EKS kubeconfig
      ```sh
      aws eks --region <us-east-1> update-kubeconfig --name access-entries
      ``` 

    d. Try access the cluster
      ```sh
      kubectl get all -A
      ```
      Something should shows up!


### Deployment and clean up
Please refer to [Terraform.md](../../../../Terraform.md)

### Test
This sample is tested in the following region(s)
- us-east-1