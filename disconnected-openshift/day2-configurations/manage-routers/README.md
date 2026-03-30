# Ingress Router Placement
- By default, OpenShift schedules these pods on worker nodes. However, their exact placement depends on your cluster configuration:

  - Standard Installation: They are treated like other system workloads and usually land on available worker nodes.

  - If you deployed infra nodes to host OpenShift components such as (registry, logging, storage) you can move these pods to dedicated "infra" nodes. This isolates external traffic handling from application workloads to ensure better performance and security.  ** If you change routers from worker nodes to infra noeds you may need to update external LB configs to point to infra nodes opposed to worker nodes **

# View current configuration for ingress
```console
oc get ingresscontrollers.operator.openshift.io -o yaml -n openshift-ingress-operator
```

# Move router pods from worker to infra nodes
```console
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}},"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/infra","operator":"Exists"}]}}}'
```

# For most deployments 2 router pods are sufficent which are generally spread across different nodes using anti-affinity rules.  The command below increases the number of router pods.
```console
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch '{"spec":{"replicas": 3}}'
```
