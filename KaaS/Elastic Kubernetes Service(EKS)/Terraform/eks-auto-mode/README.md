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

---

#### AWS Load Balancer Controller (Manual Installation) [lb-controller.tf](lb-controller.tf) & [alb-lbc.tf](alb-lbc.tf)

In addition to EKS Auto Mode's built-in load balancer controller, this cluster also demonstrates the manual installation and usage of the AWS Load Balancer Controller. This provides flexibility to choose between different ingress approaches based on specific requirements.

**Reference:** [AWS Load Balancer Controller Installation Guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/)

**Components deployed:**
1. **IAM Policy & Role**: Custom IAM permissions for Load Balancer Controller ([aws-load-balancer-controller-policy.json](aws-load-balancer-controller-policy.json))
2. **Service Account**: IRSA-enabled service account for the controller
3. **Helm Release**: AWS Load Balancer Controller deployment via Helm chart
4. **Ingress Example**: Alternative ALB creation using traditional annotations

**Key Features:**
- ✅ Manual control over controller version and configuration
- ✅ Uses standard `alb` IngressClass
- ✅ Traditional annotation-based configuration (`alb.ingress.kubernetes.io/*`)
- ✅ Advanced health check and routing configurations
- ✅ Full compatibility with existing ALB features

#### Ingress Class Configuration: Choosing Your Controller

The **IngressClass** setting is crucial as it determines which ingress controller will manage your Ingress resource. This cluster demonstrates both approaches:

| Approach | IngressClass | Controller | Configuration Method |
|----------|-------------|------------|---------------------|
| **EKS Auto Mode** | `alb-nginx` (custom) | `eks.amazonaws.com/alb` | IngressClassParams + minimal annotations |
| **AWS Load Balancer Controller** | `alb` (standard) | `ingress.k8s.aws/alb` | Traditional annotations |

**1. EKS Auto Mode ALB (alb-automode.tf):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-alb-ingress
spec:
  ingressClassName: alb-nginx  # Custom IngressClass for EKS Auto Mode
  rules:
  - http:
      paths:
      - path: /*
        pathType: ImplementationSpecific
```

**2. AWS Load Balancer Controller ALB (alb-lbc.tf):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-alb-lbc-ingress
  annotations:
    kubernetes.io/ingress.class: alb  # Can also use spec.ingressClassName
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb  # Standard ALB IngressClass
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
```

**Ingress Class Selection Rules:**
1. **Explicit IngressClass**: Use `spec.ingressClassName` field (recommended)
2. **Annotation-based**: Use `kubernetes.io/ingress.class` annotation (legacy but supported)
3. **Default IngressClass**: Falls back to cluster's default IngressClass if none specified

**Access both ALBs:**
```bash
# EKS Auto Mode ALB
kubectl get ingress nginx-alb-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# AWS Load Balancer Controller ALB  
kubectl get ingress nginx-alb-lbc-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# List all IngressClasses to see available controllers
kubectl get ingressclass
```

**When to Use Which Approach:**

**EKS Auto Mode ALB:**
- ✅ Simplified setup (no controller installation)
- ✅ Automatic IAM management
- ✅ Latest Kubernetes-native approach
- ✅ Reduced operational overhead
- ❌ Less control over controller configuration
- ❌ Limited to EKS Auto Mode clusters

**AWS Load Balancer Controller:**
- ✅ Full control over controller version and features
- ✅ Advanced configuration options
- ✅ Works on any EKS cluster (not just Auto Mode)
- ✅ Extensive annotation support
- ✅ Battle-tested in production environments
- ❌ Manual installation and IAM setup required
- ❌ Additional operational overhead
