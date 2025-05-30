# Amazon EKS Model Context Protocol (MCP) Server Demo

This example demonstrates how to set up and use the Amazon EKS Model Context Protocol (MCP) server to enable AI systems to interact with Kubernetes clusters.

## What is the EKS Model Context Protocol (MCP) Server?

The Amazon EKS Model Context Protocol (MCP) server is a capability that enables AI models to interact with Kubernetes clusters. It provides a standardized interface for AI systems to:

1. **Obtain context** about the Kubernetes cluster's resources and state
2. **Perform operations** on the cluster in a controlled manner
3. **Make informed decisions** based on real-time cluster information

The MCP server acts as a secure intermediary between AI models and the Kubernetes API, allowing AI to help with cluster management, optimization, and automation tasks.

## Architecture

![MCP Architecture](https://raw.githubusercontent.com/VardyNg/K8S-On-Cloud/main/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/model-context-protocol/examples/mcp-architecture.png)

This example deploys:

1. An Amazon EKS cluster with necessary add-ons
2. The EKS Model Context Protocol (MCP) server deployed as a Helm chart
3. IAM roles and service accounts for secure AI operations
4. A sample application that can be managed by AI through MCP
5. Configuration for the MCP server to control access and permissions

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.3
- kubectl
- Python 3 (for the AI client example)

## Deployment

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Deploy the infrastructure

```bash
terraform apply
```

### 3. Configure kubectl

After deployment, configure kubectl to interact with your cluster using the command from the Terraform output:

```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
```

## Using the MCP Server

### AI Client Example

This example includes a Python client that demonstrates how an AI system might interact with the EKS cluster via the MCP server:

```bash
# Install required Python packages
pip install boto3 requests

# Get cluster context
python examples/ai_client.py \
  --cluster <cluster-name> \
  --region <region> \
  --action get-context

# Scale a deployment
python examples/ai_client.py \
  --cluster <cluster-name> \
  --region <region> \
  --action scale \
  --name sample-app \
  --replicas 3
```

### Key Features of the MCP Server

1. **Context-aware:** The MCP server provides AI models with rich context about the Kubernetes cluster, such as:
   - Current resource utilization
   - Node health and status
   - Deployment configurations
   - Service dependencies

2. **Security-focused:** Access is controlled through:
   - IAM roles and policies
   - Kubernetes service accounts
   - Configurable authorization modes

3. **Declarative operations:** AI systems can make declarative changes to the cluster state, just like human operators would through kubectl or the Kubernetes API.

## Use Cases

The MCP server enables AI systems to:

1. **Optimize resource allocation** by scaling applications based on real-time metrics
2. **Automate troubleshooting** by identifying and resolving common issues
3. **Enhance developer productivity** by providing AI assistants that understand cluster state
4. **Improve security posture** by detecting and responding to anomalies

## Clean Up

To avoid incurring unnecessary costs, clean up the resources created by this example:

```bash
terraform destroy
```

## References

- [AWS Blog: Accelerating Application Development with the Amazon EKS Model Context Protocol Server](https://aws.amazon.com/blogs/containers/accelerating-application-development-with-the-amazon-eks-model-context-protocol-server/)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Kubernetes API Documentation](https://kubernetes.io/docs/reference/kubernetes-api/)