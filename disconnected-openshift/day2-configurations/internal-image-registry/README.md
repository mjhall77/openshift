# Internal Image Registry
- In OpenShift, the Internal Image Registry is more than just a storage folder for containers; it is a deeply integrated service that acts as the "connective tissue" between your source code and your running applications.  While you can use external registries (like Docker Hub, Quay.io, or JFrog), the internal registry provides several automated advantages that make life easier for developers and platform engineers.

# Configure Image Registry with persistent storage
- By default, the pods are configured emptyDir storage, which lives only as long as the pod.

- Update the storage and storageclass in the internal-image-registry-pvc.yaml then create it
```console
oc apply -f internal-image-registry-pvc.yaml -n openshift-image-registry
```

- Configure the image registry to use the CephFS file system storage 
```console
oc patch config.image/cluster -p '{"spec":{"managementState":"Managed","replicas":2,"storage":{"managementState":"Unmanaged","pvc":{"claim":"registry-storage-pvc"}}}}' --type=merge
```

# Remove persistent storage from internal image registry
- For a production cluster you typically would not remove persistent storage, typically remove only if issues with bonding to storage
```console
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Removed","storage":{}}}'
```

- Remove PVC claim for registry
oc delete pvc registry-storage-pvc -n openshift-image-registry

# Expose the Internal Image registry externally
- This external access enables you to log in to the registry from outside the cluster using the route address and to tag and push images to an existing project by using the route host
```console
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
```

- Add certificate of ingress operator to local trust
```console
oc get secret -n openshift-ingress  router-certs-default -o go-template='{{index .data "tls.crt"}}' | base64 -d | sudo tee /etc/pki/ca-trust/source/anchors/${HOST}.crt  > /dev/null

sudo update-ca-trust enable

sudo update-ca-trust extract
```

- Log into registry
```console
HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')  # get default registry route

podman login -u <username> -p $(oc whoami -t) $HOST
```

# To manually edit the image registry
```console
oc edit configs.imageregistry.operator.openshift.io
```

# To move the registry to an Infra node
```console
oc patch configs.imageregistry.operator.openshift.io/cluster -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra": ""}}}' --type=merge
```
