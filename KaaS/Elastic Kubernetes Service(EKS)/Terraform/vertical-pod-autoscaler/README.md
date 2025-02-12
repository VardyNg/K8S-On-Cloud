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
1. Install Metric Server
    ``` sh
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    ```    

At this stage, we should have something similar
```
NAME                                        READY   STATUS    RESTARTS   AGE
[...]
metrics-server-8459fc497-kfj8w              1/1     Running   0          83m
vpa-admission-controller-68c748777d-ppspd   1/1     Running   0          7s
vpa-recommender-6fc8c67d85-gljpl            1/1     Running   0          8s
vpa-updater-786b96955c-bgp9d                1/1     Running   0          8s
```

## Test the VPA
The step above will deploy a `Deployment`, and a `Vertical Pod Autoscaler` that selected the `Deployment` as its target. The `Vertical Pod Autoscaler` will adjust the resource requests of the `Deployment` based on the observed utilization of the pods.

In the example, the Pods in the `Deployment` are configured to with 100m CPU requests and 50Mi Memory requests, while the Pod actually use ~ 500m CPU. 

After a while (in a few minutes), VPA will adjust the resource requests and launch new pods.

Run the following command to see the VPA status
```sh
kubectl get vpa/hamster-vpa -n <namespace>
```


## Reference
- https://docs.aws.amazon.com/eks/latest/userguide/vertical-pod-autoscaler.html