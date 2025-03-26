# This template demostrate the use of AWS CodeBuild with AWS EKS cluster

## How it works?
The AWS CodeBuild is basically a regular Linux system, it interacts with AWS EKS cluster via `kubectl` command.  
The authentication is done by using EKS Access Entry associated with the CodeBuild project service-role.  

## How to test?
Trigger the pipeline to start the CodeBuild project, look at the logs and see if the `kubectl` command is able to interact with the EKS cluster.


