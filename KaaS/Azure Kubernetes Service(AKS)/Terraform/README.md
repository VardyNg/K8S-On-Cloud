# Terraform code to provision AKS cluster

## Prerequisites
- Azure CLI
- Terraform

## Steps to provision AKS cluster
- Login to Azure CLI
  ```sh
  az login
  ```

## Deploy Terraform
- Initialize Terraform
  ```sh
  terraform init
  ```
- Create Terraform plan
  ```sh
  terraform plan -out "aks.plan"
  ```

- Apply Terraform plan
  ```sh
  terraform apply "aks.plan"
  ```

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Name of the application | `string` | n/a | yes |
| location | Location of the AKS cluster | `string` | n/a | yes |
| node_vm_size | Size of the node VMs | `string` | n/a | yes |
| node_count | Number of nodes in the cluster | `number` | n/a | yes |

## Utilize the AKS cluster
- Connect to the cluster  
  Add the credentials to your local kubeconfig file
  ```sh
  az account set --subscription <subscription_id>
  az aks get-credentials --resource-group <resource_group> --name <cluster_name>
  ```
  
- Verify the connection
  ```sh
  $ kubectl get nodes
  
  NAME                              STATUS   ROLES   AGE   VERSION
  aks-default-19374358-vmss000000   Ready    agent   11m   v1.26.6
  aks-default-19374358-vmss000001   Ready    agent   11m   v1.26.6
  aks-default-19374358-vmss000002   Ready    agent   11m   v1.26.6
  ```

- Deploy a sample application
  ```sh
  $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml
  ```

  Verify the deployment
  ```sh
  $ kubectl get pods
  NAME                        READY   STATUS    RESTARTS   AGE
  my-nginx-85996f8dbd-pvwxh   1/1     Running   0          3m16s
  my-nginx-85996f8dbd-r6nk9   1/1     Running   0          3m16s
  my-nginx-85996f8dbd-rhzz4   1/1     Running   0          3m16s
  ```

- Access the application
  ```sh
  $ kubectl get svc
  NAME           TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
  kubernetes     ClusterIP      10.0.0.1      <none>          443/TCP        16m
  my-nginx-svc   LoadBalancer   10.0.10.133   <External IP>   80:31663/TCP   3m45
  ```

  Access the <External IP> to view the sample application

## Destroy the AKS cluster
- Destroy the Terraform resources
  ```sh
  terraform destroy
  ```