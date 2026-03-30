# Add node to cluster using agent-based installer
- Adding or replacing node via the Agent-based Installer is a streamlined way to expand your OpenShift or Kubernetes cluster, especially in disconnected or edge environments. The Agent-based approach uses a bootable ISO that contains everything the node needs to configure itself.

# Remove node from cluster if needed
- If there is a node that has hardware issues and must be removed from the cluster perform the following steps
  - RH docs: https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/nodes/working-with-nodes#nodes-nodes-working-deleting-bare-metal_nodes-nodes-working
```console
oc adm cordon <node_name>

oc adm drain <node_name> --force=true --delete-emptydir-data=true --ignore-daemonsets=true --disable-eviction

oc delete node <node_name>
```

# Update nodes.yaml or copy node entry from agent-config.yaml and update 

# Create node iso
- Create a working directory
```console
mkdir add-node && cd add-node

cp /path/to/nodes-config.yaml .

oc adm node-image create
```

# Track the progress of the node
```console
oc adm node-image monitor --ip-addresses 192.168.111.83,192.168.111.84  #Change to the IP or IPs of the node to be added to the cluster
```
