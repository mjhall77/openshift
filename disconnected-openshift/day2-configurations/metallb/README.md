# MetalLB
- MetalLB is a network load-balancer implementation for clustered environments that don't run on a public cloud. It provides two main functions:

  - Address Management: It maintains a pool of IP addresses that you provide and assigns them to Services as they are created.

  - External Announcement: It tells the rest of your network that a specific IP "lives" on your OpenShift cluster so that external traffic knows where to go.

- RH Docs: https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/networking_operators/metallb-operator

steps:

 - Install Metallb operator
 - Deploy metallb instance: oc apply -f metallb.yaml
 - Create IP address pool:  oc apply -f ipaddresspool.yaml
 - Create bgp advertisment: oc apply -f gbpadvertisement.yaml
 - Create l2 advertisment: oc apply -f l2advertisement.yaml

Create service for Pod:
oc expose pod/virt-launcher-test-vm-j6gkx --type=LoadBalancer --selector kubevirt.io/domain=test-vm --name=test-vm --port=22,80 -o yaml --dry-run | tee service.yaml
