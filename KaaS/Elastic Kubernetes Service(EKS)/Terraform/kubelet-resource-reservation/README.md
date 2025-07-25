## Kubelet and System OS Resource Reservation

This example demonstrates how to configure kubelet and system OS resource reservation in Amazon EKS. Resource reservation is essential for maintaining cluster stability by ensuring that system processes and kubelet have dedicated resources.

### What is Resource Reservation?

Resource reservation in Kubernetes involves setting aside CPU and memory resources for:

1. **System Reserved**: Resources reserved for OS system processes (kernel, OS services, etc.)
2. **Kube Reserved**: Resources reserved for Kubernetes system processes (kubelet, kube-proxy, etc.)  
3. **Eviction Thresholds**: Resource thresholds that trigger pod eviction to maintain node stability

### Key Configuration Parameters

This example configures the following kubelet parameters:

- `systemReserved`: Reserves resources for system processes
  - `cpu`: CPU reserved for OS processes (in millicores)
  - `memory`: Memory reserved for OS processes (in bytes)
  - `ephemeral-storage`: Storage reserved for OS processes

- `kubeReserved`: Reserves resources for Kubernetes processes
  - `cpu`: CPU reserved for kubelet and other Kubernetes components
  - `memory`: Memory reserved for kubelet and other Kubernetes components
  - `ephemeral-storage`: Storage reserved for Kubernetes components

- `evictionHard`: Hard eviction thresholds (immediate pod eviction)
  - `memory.available`: Minimum available memory threshold
  - `nodefs.available`: Minimum available disk space threshold
  - `imagefs.available`: Minimum available space for container images

- `evictionSoft`: Soft eviction thresholds (graceful pod eviction)
  - Same parameters as hard eviction but with grace periods

### Example Resource Calculations

For a node with 4 CPU cores and 8GB memory:
- System Reserved: 100m CPU, 256Mi memory
- Kube Reserved: 100m CPU, 256Mi memory  
- Available for pods: 3.8 CPU cores, ~7.5GB memory

### Benefits

- **Stability**: Prevents resource starvation of system processes
- **Predictability**: More predictable resource allocation for workloads
- **Performance**: Better performance by avoiding system resource contention
- **Reliability**: Reduces node instability and unexpected pod evictions

### Usage

```bash
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

### Verification

After deployment, you can verify the configuration by checking the kubelet configuration on the nodes:

```bash
# Connect to a node and check kubelet config
kubectl get nodes
kubectl describe node <node-name>

# Check allocated resources
kubectl top nodes
```

### Cleanup

```bash
terraform destroy
```

### References

- [Kubernetes: Reserve Compute Resources for System Daemons](https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/)
- [EKS Node Configuration](https://awslabs.github.io/amazon-eks-ami/nodeadm/)