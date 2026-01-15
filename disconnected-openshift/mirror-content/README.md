# Mirror OpenShift container content for a disconnected installation

- A disconnected environment is an environment that does not have full access to the internet.

- OpenShift Container Platform is designed to perform many automatic functions that depend on an internet connection, such as retrieving release images from a registry or retrieving update paths and recommendations for the cluster. Without a direct internet connection, you must perform additional setup and configuration for your cluster to maintain full functionality in the disconnected environment.

# Download binaries needed for mirror process

- Binaries can be obtained from https://console.redhat.com/openshift/downloads
  - **NOTE:** You will need your Red Hat credentials to log in

- **Openshift command-line interface (oc) for RHEL 9**
  <img src="Screenshot from 2026-01-15 12-58-13.png" width="2000" height="800" alt="oc cli">
 


**EXTREMELY IMPORTANT** When the allowedRegistries parameter is defined, all registries, including the registry.redhat.io and quay.io registries and the default OpenShift image registry, are blocked unless explicitly listed. If you use this parameter, to prevent pod failure, add all registries including the registry.redhat.io and quay.io registries and the internalRegistryHostname to the allowedRegistries list, as they are required by payload images within your environment. For disconnected clusters, mirror registries should also be added.

- If a cert is needed update/create the registy-config configmap in openshift-config namespace

- Update registry-config cm in openshift-config namespace:
    ```console
    oc edit cm registry-config -n openshift-config
   ```
- Append the registry certificate, example below
```yaml
 data:
  registry.example.com: |
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
  registry-with-port.example.com..5000: |
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
 ```

- To create registry-config if it does not exist
  - example: oc create configmap registry-config --from-file=new-external-registry.com..8443=/etc/pki/ca-trust/source/anchors/new-external-registry.pem -n openshift-config
 ```console
 oc create configmap registry-config --from-file=<external_registry_address>=ca.crt -n openshift-config
 ```

- Update the spec.registrySources section in image.config.openshift.io/cluster, if a cert is needed specify configmap in spec.additionalTrustCA.
```console
oc edit image.config.openshift.io/cluster
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
  additionalTrustedCA:
    name: registry-config
```

- Next, the Machine config operator updates nodes has to update the nodes, wait for this process to complete.  After running the command below wait for status UPDATED: True,  UPDATING: False,  DEGRADED: False, this may take several minutes due to each node requiring the configuration change to be applied

```console
oc get mcp -w   (looking for UPDATED: True,  UPDATING: False,  DEGRADED: False) NOTE: this could take several minutes, all nodes need to have configuration change applied 
```

- To validate the configs have been applied, the registries should appear in /etc/containers/policy.json under spec.registrySources.allowedRegistries

```console
oc debug node/<node_name>
chroot /host
cat /etc/containers/policy.json | jq '.'
```

- If the external registry is secure first log into the external registry
podman login -u <username> <external-image-registry>

# Create a pull secret for a namespace only,not cluster wide access

- Create a pull secret for registry if not all namespaces need to pull from the repo
  - example: oc create secret docker-registry dev-registry-pull-secret --docker-server=dev-registry.example.com:8443 --docker-username=init --docker-password=password
```console
oc create secret docker-registry <registry-name>-pull-secret --docker-server=<registry:port> --docker-username=<username> --docker-password=<password> -n <namespace>
```

- Link secret to builder service account
  - example: oc secretes link builder dev-registry-pull-secret
```config
oc secrets link builder <registry-name-pull-secret>
```

# Add registry pull secret to the cluster pull secret if all namespaces are allowed to pull from repo

- Download the pull secret to your local file system. 
```console
oc extract secret/pull-secret -n openshift-config --to=.
```

- Add pull secret for external regsitry to the .dockerconfigjson file created from previous command
```console
oc login -u <username> <registry>
```

- Get pull secret for external registry
```console
cat $XDG_RUNTIME_DIR/containers/auth.json
```

- Add external registry entry to .dockerconfigjson
  - **IMPORTANT** verify updated .dockerconfigjson is valid using the following process
```console
podman logout <external-registry>
podman login --authfile=.dockerconfigjson <external-registry>  # If .dockerconfigjson valid you should get return: Existing credentials are valid. Repeat process for all registries listed in .dockerconfigjson
```

- Update global pull secret 
```console
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=.dockerconfigjson
```

- It may take a couple minutes to update cluster with new pull secret.  Run following command waiting for Updated to be true for master, infra and workers
```console
oc get mcp -w
```

