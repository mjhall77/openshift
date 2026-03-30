# NMSTATE Operator
- The nmstate operator in OpenShift (specifically within OpenShift Virtualization and bare-metal deployments) is a Kubernetes-native way to manage the network configuration of your cluster nodes.

- Think of it as "Declarative Networking." Instead of logging into every single server to manually edit configuration files or run nmcli commands, you describe the desired state of your network in a YAML file, and the operator ensures the nodes match that description.

- Kubernetes nmstate documentation:  https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/kubernetes_nmstate/index

- Deploy NMSTATE operator via the gui and accept defaults

# Provided CRDs 
- NodeNetworkState -> Current configuration
- NodeNetworkconfigurationPolicy -> add network interfaces to bridges -> OVS and mappings
- Configure NetworkAttachmentDefinition (NAD) provided by multus to connect pod / vm to network

# Configuration Examples
- In configuration-files there are multiple examples of how to configure networking in OpenShift. Reference the configuration file that aligns with usecase and update fields with site-specific configs  
