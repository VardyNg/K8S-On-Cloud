## This template demostrates the use of Cluster Proportional Autoscaler (CPA) in EKS

### What is expected?
- An EKS Cluster
- Two set of resources that demostrates CPA Linear and CPA Ladder 
  - `cpa-ladder.tf`: 
    - `kubernetes_config_map.nginx-ladder-autoscaler`: `ConfigMap` for CPA Ladder
    - `kubernetes_deployment.nginx-ladder-autoscaler`: `Deployment` for CPA
    - `kubernetes_deployment.nginx-ladder`: `Deployment` for the application
  - `cpa-linear.tf`: 
    - `kubernetes_config_map.nginx-linear-autoscaler`: `ConfigMap` for CPA Linear
    - `kubernetes_deployment.nginx-linear-autoscaler`: `Deployment` for CPA
    - `kubernetes_deployment.nginx-linear`: `Deployment` for the application
  
### Test the autoscaling
The EKS Node Group will deploy 2 Worker Nodes with `m5.large` (2 vCPU and 8GB Memory) instance type, there are total 2 x 2 = 4 cores available.

#### Ladder
```json
{
  "coresToReplicas":
  [
    [ 1,1 ],
    [ 3,3 ],
    [ 5,5 ],
    [ 7,7 ]
  ],
  "nodesToReplicas":
  [
    [ 1,1 ],
    [ 2,2 ]
  ]
}

```
| Available Nodes |  Available Cores | Deployment Replicas | Reason |
|-----------------|------------------|---------------------| -------|
| 2               | 4                | 3                   | [3,3] < 4 < [5,5] -> choose [3,3] = 3 replicas |
| 3               | 6                | 5                   | [5,5] < 6 < [7,7] -> choose [5,5] = 5 replicas |
| 4               | 8                | 7                   | [7,7] < 8 < [7,7] -> choose [7,7] = 7 replicas |

#### Linear
```json
{
  "coresPerReplica": 2,
  "nodesPerReplica": 1,
  "preventSinglePointFailure": true
}
```

Formula
```
replicas = max( ceil( cores * 1/coresPerReplica ) , ceil( nodes * 1/nodesPerReplica ) )
replicas = min(replicas, max)
replicas = max(replicas, min)

```
| Available Nodes |  Available Cores | Deployment Replicas | Reason |
|-----------------|------------------|---------------------| -------| 
| 2               | 4                | 2                   | `max ( ceil( 4 * 1/2 ) , ceil( 2 * 1/1 ) )` = `max(2,2)` = `2` | 
| 3               | 6                | 3                   | `max ( ceil( 6 * 1/2 ) , ceil( 3 * 1/1 ) )` = `max(3,3)` = `3` |
| 4               | 8                | 4                   | `max ( ceil( 8 * 1/2 ) , ceil( 4 * 1/1 ) )` = `max(4,4)` = `4` |

### Reference
https://github.com/kubernetes-sigs/cluster-proportional-autoscaler