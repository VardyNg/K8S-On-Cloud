### This template demonstrate the use of Fluent Bit to send log to CloudWatch

### Content
- VPC, Subnet, Security Group ... for the EKS cluster
- an EKS cluster (v1.29) and a Managed Node Group (with CloudWatch log permission attachment)
- Kubernetes namespace and sample pod that will send logs to CloudWatch Log Group (see [k8s.tf](k8s.tf))

### Verify the Set up
- EKS Add-on: Amazon Cloudwatch Observability  
  A controller manager will be deployed. Two deamonSets will be created to deploy CloudWatch Agents and Fluent Bit
  ```sh
  kubectl get all -n amazon-cloudwatch
  ```  
- Testing Pod
  A deployment will be created to deploy Pods and write log to CloudWatch
  ```sh
  kubectl get all -n cloudwatch-log-fluent-bit-namespace
  ```  
- The log
  1. Go to CloudWatch Console
  2. Find the log group, it will be in the format of 
     /aws/containerinsights/cloudwatch-log-fluent-bit/application
  3. View the log

### Deploy
```sh
terraform apply
```


### Clean up

```sh
terraform destroy
```