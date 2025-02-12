## This template demo the use of Vertical Pod Autoscaler in EKS

## Deploy the template
1. Deploy it using Terraform as you would normally do
1. Clone the VPA repository which is a submodule
    ```sh
    git submodule update --init --recursive
    ```
1. Deploy the VPA
    ```sh
    cd vpa/vertical-pod-autoscaler

    ./hack/vpa-up.sh
    ```
    


