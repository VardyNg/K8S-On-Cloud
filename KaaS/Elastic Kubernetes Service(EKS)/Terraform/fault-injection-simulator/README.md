# This template demonstrate the use of AWS Resillence Hub - Fault Injection Service (FIS) to test the resiliency of an EKS cluster

### How it works?
FIS allows you to simulate a chaos event in the EKS cluster, it supports a wide range of AWS services. In EKS, it supports the following actions:
- `aws:eks:inject-kubernetes-custom-resource`
- `aws:eks:pod-cpu-stress`
- `aws:eks:pod-delete`
- `aws:eks:pod-io-stress`
- `aws:eks:pod-memory-stress`
- `aws:eks:pod-network-blackhole-port`
- `aws:eks:pod-network-latency`
- `aws:eks:pod-network-packet-loss`
- `aws:eks:terminate-nodegroup-instances`

### Testing
- Experiment templates: 50% of nodes terminations in the node group
  1. Use the output `eks_node_termination_command` to start the experiment
      ```bash
      aws fis start-experiment --experiment-template-id XXXXX --region xxxx
      ```
      
  1. 50% of the EC2 instance in the node group will be terminated, i.e. 50% of 4 nodes = 2 nodes
  1. The worker node will become `NotReady` and the pod will be rescheduled to other nodes.
  1. The node group will launch new EC2 instances to replace the terminated nodes.
  
- Experiment templates: Pod terminations
  1. Use the output `eks_pod_termination_command` to start the experiment
      ```bash
      aws fis start-experiment --experiment-template-id XXXXX --region xxxx
      ```

  1. A `fis-pod` will be deployed in the EKS cluster, and it will terminate ALL of of the pods in the `fault-injection-simulator-xxx-namespace` namespace. The deployment should bring them back after that.
  1. The `fis-pod` will be terminated after the experiment is completed.

### References:
- https://aws.amazon.com/blogs/devops/chaos-engineering-on-amazon-eks-using-aws-fault-injection-simulator/