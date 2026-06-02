# custom-machinesets-with-taints
- A MachineSet in OpenShift is a resource that defines a group of identical worker nodes. Acting as a template, it ensures a specified number of machines are running at all times. It is the fundamental component used to scale compute resources up or down dynamically in cloud environments.

- To create a machineset update the vgpu-machineset.yaml template or update an existing machineset using the command **oc get machineset.machine.openshift.io <machineset-name> -oyaml -n openshift-machine-api >> machineset-name.yaml

- Once machineset is updated apply machineset to the cluster
```console
oc apply -f machineset-name.yaml
```

## Create machineset Role and Rolebindings if you want to limit who can scale the machineset (optional)
- Create the roles for node-viewer
```console
oc create -f node-view-cluster-role.yaml
```

- Update the resourceNames section of machineset-admin-cluster-role.yaml and list exact machinesets user/group would be allowed to scale/modify
```console
vim machineset-admin-cluster-role-binding.yaml

  resourceNames:
  - <exact-name-of-machineset>
  - <exact-name-of-machineset>
  - <exact-name-of-machineset>
  - <exact-name-of-machineset>
```

- Apply the updated machineset-admin-cluster-role.yaml
```console
oc apply -f machineset-admin-cluster-role.yaml
```

- Update the machine-admin-clsuter-role-binding config for the group or user your granting permissions to
```console
oc create -f machineset-admin-cluster-role-binding.yaml
subjects:
- kind: User
  name: name-of-user
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: name-of-group
  apiGroup: rbac.authorization.k8s.io
```

- Apply the updated machineset-admin-cluster-role-binding.yaml
```console
oc create -f machineset-admin-cluster-role-binding.yaml
```

## Configure Taints and Tolerations on nodes (Optional)
- Taints and tolerations in OpenShift (and Kubernetes) are a scheduling mechanism used to repel specific workloads from certain nodes.

- Taints are applied to nodes to mark them as "repelling" certain pods.

- Tolerations are applied to pods to allow the Kubernetes scheduler to place them on tainted nodes

- To configure taints on a node you can use oc adm taint command or configure via machineset 

- Option 1: use the oc adm taint command
```console
oc adm taint nodes <node_name> <key>=<value>:<effect>
```

- Option 2: Update the machineset
```console
    spec:
      taints:
      - effect: NoSchedule
        key: <nameofkey>
        value: <value>
```

- Configure Tolerations at a project level, this will allow all pods within the project to deploy to the tainted node
```console
oc patch namespace <namesapce> --type=merge -p '{"metadata":{"annotations":{"scheduler.alpha.kubernetes.io/defaultTolerations":"[{\"key\": \"<keyname>\", \"value\": \"<value>\", \"operator\": \"Equal\", \"effect\": \"NoSchedule\"}]"}}}'
```

# Taints and tolerations example
```console

oc adm taint nodes worker01 dedicated=developers:NoSchedule

oc patch namespace developer-project --type=merge -p '{"metadata":{"annotations":{"scheduler.alpha.kubernetes.io/defaultTolerations":"[{\"key\": \"dedicated\", \"value\": \"developers\", \"operator\": \"Equal\", \"effect\": \"NoSchedule\"}]"}}}'
```

