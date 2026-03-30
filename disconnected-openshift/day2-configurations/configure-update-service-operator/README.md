# Openshift Update Service (Cincinnati)
- The OpenShift Update Service is the on-premise release of Red Hat’s hosted update service. It performs the task of providing upgrade graph information to OpenShift clusters showing the recommended versions that can be safely updated to. This provides administrators with a seamless user experience for applying updates to OpenShift clusters in a restricted network.

- Use oc-mirror to import updated content to disconnected registry and apply the .yamls in working-dir/cluster-resource directory. 

- Deploy the update service operator from the gui and keep the defaults

# Configuring access to a secured registry for the update service
```console
oc create configmap update-service-ca \
  --from-file=my-registry.example.com..8443=/path/to/registry-ca.crt \
  --from-file=updateservice-registry=/path/to/registry-ca.crt \
  -n openshift-config
```

- Update the image.config cluster to include the CA for the update service
```console
oc patch image.config.openshift.io/cluster --type='merge' -p '{"spec":{"additionalTrustedCA":{"name":"update-service-ca"}}}'
```

# Create the update service via the gui and provide the required content
. name: cluster-update-service
. graph-image is typically in openshift/graph-image, be sure to include the :latest tag
. releases is typically openshift/release-images

# Configure the Cluster Version Operator
```console
POLICY_ENGINE_GRAPH_URI="$(oc -n openshift-update-service get -o jsonpath='{.status.policyEngineURI}/api/upgrades_info/v1/graph{"\n"}' updateservice cluster-update-service)"
PATCH="{\"spec\":{\"upstream\":\"${POLICY_ENGINE_GRAPH_URI}\"}}"

oc patch clusterversion version -p $PATCH --type merge
```
