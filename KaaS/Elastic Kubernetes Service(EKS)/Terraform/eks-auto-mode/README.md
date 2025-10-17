## Deploy EKS with Auto Mode
### Features provided with EKS Auto Mode
#### Automatic node management

#### EBS Volume Management [ebs.tf](ebs.tf)  
- Auto Mode requires `AmazonEKSBlockStoragePolicy` in the cluster role (https://docs.aws.amazon.com/eks/latest/userguide/auto-enable-existing.html)
- A storage class must be created (https://docs.aws.amazon.com/eks/latest/userguide/create-storage-class.html):
  ```yaml
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: auto-ebs-sc
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
  provisioner: ebs.csi.eks.amazonaws.com
  volumeBindingMode: WaitForFirstConsumer
  parameters:
    type: gp3
    encrypted: "true"
  ```

#### Application Load Balancer (ALB) with EKS Auto Mode [alb.tf](alb.tf)
EKS Auto Mode includes a built-in load balancer controller that automatically provisions ALBs using the new Kubernetes-native approach with IngressClass and IngressClassParams.

**Reference:** [AWS EKS Auto Mode ALB Configuration](https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-alb.html)

**Features:**
- ✅ Built-in load balancer controller (no manual installation required)
- ✅ Uses new EKS Auto Mode API: `eks.amazonaws.com/alb`
- ✅ IngressClass and IngressClassParams for AWS-specific configuration
- ✅ Nginx deployment with custom content showcasing ALB functionality

**Components deployed:**
1. **Nginx Deployment**: 3 replicas of nginx with custom HTML content
2. **ConfigMap**: Custom index.html showcasing EKS Auto Mode features  
3. **Service**: ClusterIP service exposing nginx on port 80
4. **IngressClassParams**: AWS-specific ALB configuration (scheme, tags)
5. **IngressClass**: Links to EKS Auto Mode controller (`eks.amazonaws.com/alb`)
6. **Ingress**: Creates internet-facing ALB using the IngressClass

**ALB Configuration (via IngressClassParams):**
- Scheme: `internet-facing`
- Controller: `eks.amazonaws.com/alb` (EKS Auto Mode)
- Path Type: `ImplementationSpecific` with `/*` pattern
- Tags: Automatic tagging for resource management

**Access the application:**
After deployment, get the ALB URL:
```bash
# Configure kubectl
aws eks --region <region> update-kubeconfig --name <cluster-name>

# Check ingress status
kubectl get ingress nginx-alb-ingress -n default

# Get ALB hostname
kubectl get ingress nginx-alb-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Key Advantages of EKS Auto Mode ALB:**
- No need to manually install AWS Load Balancer Controller
- Uses modern IngressClass/IngressClassParams approach (no legacy annotations)
- Automatic IAM permissions management
- Built-in integration with EKS compute and networking
- Simplified configuration with clear separation of concerns

**Migration Notes:**
- No longer uses `alb.ingress.kubernetes.io/*` annotations
- Uses `IngressClassParams` for AWS-specific configuration
- Controller is `eks.amazonaws.com/alb` instead of `ingress.k8s.aws/alb`
- Path type is `ImplementationSpecific` with `/*` pattern



