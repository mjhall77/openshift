# MetalLB
- MetalLB is a network load-balancer implementation for clustered environments that don't run on a public cloud. It provides two main functions:

  - Address Management: It maintains a pool of IP addresses that you provide and assigns them to Services as they are created.

  - External Announcement: It tells the rest of your network that a specific IP "lives" on your OpenShift cluster so that external traffic knows where to go.

- RH Docs: https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/networking_operators/metallb-operator

- Following installation of metallb operator we need to deploy an instance of metallb
```console
oc create -f metallb.yaml
```

- Create IP address pool, update zone and addresses 
```console
oc create -f ipaddresspool.yaml
```

- Create bgp advertisement, set the ipAddressPools to the name of the ipaddresspool created in previous step
```console
oc apply -f gbpadvertisement.yaml
```

- Create l2 advertisment set the ipAddressPools to the name of the ipaddresspool created in second step
```conole
oc apply -f l2advertisement.yaml
```

Create service for Pod:
oc expose pod/virt-launcher-test-vm-j6gkx --type=LoadBalancer --selector kubevirt.io/domain=test-vm --name=test-vm --port=22,80 -o yaml --dry-run | tee service.yaml
