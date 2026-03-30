# Ingress Router Configuration
- In the OpenShift ecosystem, the Ingress Controller (often called the Router) serves as the primary gateway for external traffic entering the cluster. While Kubernetes uses "Ingress" resources, OpenShift historically used "Routes," and the Ingress Controller is the engine that makes both work

# View current configuration for ingress
```console
oc get ingresscontrollers.operator.openshift.io -o yaml -n openshift-ingress-operator
```

# Ingress Router Placement 
- By default, OpenShift schedules these pods on worker nodes. However, their exact placement depends on your cluster configuration:

  - Standard Installation: They are treated like other system workloads and usually land on available worker nodes.

  - If you deployed infra nodes to host OpenShift components such as (registry, logging, storage) you can move these pods to dedicated "infra" nodes. This isolates external traffic handling from application workloads to ensure better performance and security.  ** If you change routers from worker nodes to infra noeds you may need to update external LB configs to point to infra nodes opposed to worker nodes **

- Move router pods from worker to infra nodes
```console
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}},"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/infra","operator":"Exists"}]}}}'
```

# Increase the number of router pods.
- Most deployments 2 router pods are sufficent which are generally spread across different nodes using anti-affinity rules.

```console
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch '{"spec":{"replicas": 3}}'
```

# Update Ingress Router Certs
- Updating the Ingress Controller certificates (often called the Default Ingress Certificate) is a two-step process: you first create a Kubernetes Secret containing your new certificate, and then you patch the Ingress Controller to use that Secret.

- Create the TLS Secret
```console
oc create secret tls custom-certs-default \
     --cert=fullchain.pem \
     --key=privkey.pem \
     -n openshift-ingress
```

- Patch the Ingress Controller with the secret
```console
oc patch ingresscontroller default \
    -n openshift-ingress-operator \
    --type=merge \
    --patch '{"spec":{"defaultCertificate":{"name":"custom-certs-default"}}}'
```
