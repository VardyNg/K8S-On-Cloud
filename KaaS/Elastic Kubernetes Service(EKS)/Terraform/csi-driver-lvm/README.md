## Deploy an EKS Cluster with the use of CSI-Driver-LVM

### What is LVM (Logical Volume Manager)?
LVM (Logical Volume Manager) is a device mapper framework that provides logical volume management for the Linux kernel. It allows you to create, resize, and delete logical volumes (partitions) on physical storage devices. LVM provides flexibility in managing storage, allowing you to easily adjust the size of volumes and manage multiple disks as a single logical unit.

### What is CSI-Driver-LVM?
[CSI-Driver-LVM](https://github.com/metal-stack/csi-driver-lvm) is a Container Storage Interface (CSI) driver, it allows you to set a volume selector terms and use host's disks to create LVM, and make it available to the pods. 

### Contents
- An EKS Cluster with everything needed to run CSI-Driver-LVM and a sample application
- A Node Group will deploy an EC2 instance with im4gn.16xlarge:
  - expensive machine! $5.82067/hour in us-east-1!
  - 64 vCPUs, 256 GiB memory, 4 x 7500 GB NVMe SSD
  - has built-in NVMe storage: nvme0n1, nvme1n1, nvme2n1, nvme3n1, and nvme4n1
- A Helm deploying the CSI-Driver-LVM, with `lvm.devicePattern` set to `/dev/nvme[1-9]n[0-9]`, to select the NVMe disks
- A sample application using the CSI-Driver-LVM, with a PersistentVolumeClaim (PVC) of `1200Gi`, and a Pod using that PVC