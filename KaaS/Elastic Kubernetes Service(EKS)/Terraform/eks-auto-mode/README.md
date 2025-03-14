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



