# GitHub Actions Runner Controller (ARC) on EKS

This template demonstrates the deployment of GitHub Actions Runner Controller (ARC) on an Amazon EKS cluster with Karpenter for autoscaling.

## Features

- EKS cluster with AWS VPC and relevant security groups
- Managed Node Group with minimum instance size to run Karpenter and ARC controllers
- Karpenter for cluster autoscaling
- GitHub Actions Runner Controller (ARC) for self-hosted GitHub Actions runners

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform version >= 1.3
3. kubectl installed
4. GitHub App configured for ARC

## Setup GitHub App for ARC

Follow [GitHub's documentation](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/authenticating-to-the-github-api#deploying-using-personal-access-token-classic-authentication) to set up a GitHub App with the necessary permissions.

You will need:
- GitHub App ID
- GitHub App Installation ID
- GitHub App Private Key

## Post-deployment Steps

After deployment, follow these steps to configure your ARC runner:

1. Create the namespace for runner (if not automatically created):
```sh
kubectl create namespace arc-runners
```

2. Create a secret with GitHub App credentials:
```sh
NAMESPACE="arc-runners"
kubectl create secret generic pre-defined-secret \
   --namespace="${NAMESPACE}" \
   --from-literal=github_app_id=YOUR_GITHUB_APP_ID \
   --from-literal=github_app_installation_id=YOUR_INSTALLATION_ID \
   --from-literal=github_app_private_key='YOUR_PRIVATE_KEY'
```

3. Configure the runner scale set values:
```sh
# Create a values.yaml file with your specific configuration
cat > values.yaml <<EOF
githubConfigUrl: "https://github.com/YOUR_ORG/YOUR_REPO"
githubConfigSecret: "pre-defined-secret"
# Add any additional configuration as needed
EOF
```

4. Update runner scale set or make required changes.

## Troubleshooting

- Check pod status: `kubectl get pods -n arc-systems`
- View logs: `kubectl logs -n arc-systems deployment/arc-gha-rs-controller`