Content-Type: multipart/mixed; boundary="BOUNDARY"
MIME-Version: 1.0

--BOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: application/node.eks.aws
Mime-Version: 1.0

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${cluster_endpoint}
    certificateAuthority: ${cluster_ca}
    cidr: ${cluster_service_cidr}
  kubelet:
    config:
      registerWithLabels:
        fast-disk-node: "pv-raid"
--BOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: text/x-shellscript; charset="us-ascii"
Mime-Version: 1.0

${setup_script}

--BOUNDARY--
