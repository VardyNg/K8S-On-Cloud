## This template demostrate the use of AWS Batch with AWS EKS

## Deployment
Deploy like it should via terraform

### Notes:
As Access Entry doesn't support service-linked role, which is utilized by Batch to access the EKS cluster, you need to create the role manually. One way to do it is by eksctl:
```bash
eksctl create iamidentitymapping \
    --cluster my-cluster-name \
    --arn "arn:aws:iam::<your-account>:role/AWSServiceRoleForBatch" \
    --username aws-batch
```

## Test
Run the awscli command to submit a job to the batch, the command can be found in terraform output for example:
```bash
aws batch submit-job --job-name my-first-job --job-queue My-Eks-JQ1 --job-definition MyJobOnEks_Sleep --region us-east-1
```

AWS Batch will provision and attach EKS Worker Node(s) to the cluster, then the Batch Job will be deployed as Pod(s) on those Worker Node(s).  
As AWS Batch aggressively clean up those Pod upon finish, the Pods will disappear after the job is done fast. Use CloudWatch or something else to preserve the logs.


## Issue
- `AWSServiceRoleForBatch` does not exists
An AWS Account does not have this role by default, try to do some batch operation to create this role. [doc](https://docs.aws.amazon.com/batch/latest/userguide/using-service-linked-roles.html#create-slr)


## References:
https://docs.aws.amazon.com/batch/latest/userguide/eks.html