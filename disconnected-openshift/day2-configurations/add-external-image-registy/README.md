# Add Additional Container Repo

- If you need to add an addional container repository to your openshift cluster.  
  - Additional References:
  - RH docs add additional image registry:  https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/images/image-configuration#images-configuration-allowed_image-configuration
  - RH KCS Article:  https://access.redhat.com/solutions/4654511

- Update the cluster image config

```console
oc edit image.config.openshift.io/cluster 
```

# To add an external registry update 

**EXTREMELY IMPORTANT** When the allowedRegistries parameter is defined, all registries, including the registry.redhat.io and quay.io registries and the default OpenShift image registry, are blocked unless explicitly listed. If you use this parameter, to prevent pod failure, add all registries including the registry.redhat.io and quay.io registries and the internalRegistryHostname to the allowedRegistries list, as they are required by payload images within your environment. For disconnected clusters, mirror registries should also be added.

- Update the spec.registrySources section in image.config.openshift.io/cluster, example blow. 

```console
oc edit mage.config.openshift.io/cluster
```

```yaml
apiVersion: config.openshift.io/v1
kind: Image
metadata:
  name: cluster
spec:
  registrySources: 
    allowedRegistries: 
    - example.com
    - quay.io
    - registry.redhat.io
    - reg1.io/myrepo/myapp:latest
    - image-registry.openshift-image-registry.svc:5000
```

# The Machine config operator has to update the nodes, wait for this process to complete:
oc get mcp -w   (looking for UPDATED: True,  UPDATING: False,  DEGRADED: False) NOTE: this could take several minutes, all nodes need to have configuration change applied 

# Validate the configs have been applied
oc debug node/<node_name>
chroot /host
cat /etc/containers/policy.json | jq '.'   # you should see the registries configured in image.config.openshift.io/cluster  spec.registrySources.allowedRegistries


# If the registry requires a certificate for accessing, add to the spec.additionalTrustedCA.name configmap if exists otherwise create one. 

## If the cm exists then update data portion for the new external registry
data:
  registry.example.com: |
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
  registry-with-port.example.com..5000: | 
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----

## If need to create use the following command:
oc create configmap registry-config --from-file=<external_registry_address>=ca.crt -n openshift-config
   example:   oc create configmap registry-config --from-file=new-external-registry.com..8443=/etc/pki/ca-trust/source/anchors/new-external-registry.pem -n openshift-config

## update image.config.openshift.io/cluster
spec:
  additionalTrustedCA:
    name: registry-config

## If the external registry is secure first log into the external registry
podman login -u <username> <external-image-registry>

## Create a pull secret for registry if not all namespaces need to pull from the repo
oc create secret docker-registry <registry-name>-pull-secret --docker-server=<registry:port> --docker-username=<username> --docker-password=<password> -n <namespace>
  - example:  oc create secret docker-registry dev-registry-pull-secret --docker-server=dev-registry.example.com:8443 --docker-username=init --docker-password=password 

    ## Link secret to builder service account
    oc secrets link builder <registry-name-pull-secret>
      - example:  oc secretes link builder dev-registry-pull-secret

## Add registry pull secret to the cluster pull secret if all namespaces are allowed to pull from repo
# Download the pull secret to your local file system. 
oc extract secret/pull-secret -n openshift-config --to=.

# Add pull secret for external regsitry to the .dockerconfigjson file created from previous command
oc login -u <username> <registry>

# Get pull secret for external registry
cat $XDG_RUNTIME_DIR/containers/auth.json

# Add external registry entry to .dockerconfigjson
## IMPORTANT verify updated .dockerconfigjson is valid using the following process
podman logout <external-registry>
podman login --authfile=.dockerconfigjson <external-registry>  # If .dockerconfigjson valid you should get return: Existing credentials are valid. Repeat process for all registries listed in .dockerconfigjson


# Update global pull secret 
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=.dockerconfigjson

# Note it may take a couple minutes to update cluster with new pull secret.  Run following command waiting for Updated to be true for master, infra and workers
oc get mcp -w


