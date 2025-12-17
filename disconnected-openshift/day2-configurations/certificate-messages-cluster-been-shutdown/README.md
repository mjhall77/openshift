# Pending Certificate Signing Request (CSR)

- Sometimes when a cluster is offline (shutdown) for a multiple days / weeks the cluster fails to come up do to pending Certificate Signing Request (CSRs).  To troubleshoot the issue you will need to
- SSH to a control plane node and run journalctl -f, you would see error messages simliar to "No valid client certificate is found but the server is not responsive."

- To resolve the issue, on the same control plan node run the following commands:

```console
sudo bash

export KUBECONFIG=/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/lb-int.kubeconfig

oc get csr | grep -i pending
```

- The command above lists pending CSR that must be approved for the cluster to trust them

```console
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve

```

- You may have to wait a couple minutes and run the get csr and certificate approve commands a couple of times..

- To get the status of the cluster run the following commands, you may require more steps depending on the results

```console
oc get nodes  

oc get co    

```

