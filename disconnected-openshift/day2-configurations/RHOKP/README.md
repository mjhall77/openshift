# Red Hat Offline Knowledge Portal
- Red Hat Offline Knowledge Portal provides access to content from the Red Hat Customer Portal including the entire product documentation library in environments with limited or no internet connectivity

- An access key is required to for RHOKP to unlock the content inside of the RHOKP container.  Navigate to https://access.redhat.com/offline/access/ and authenticate using RHN account with subscriptions.  Click Generate key and copy the key to a file. After you generate your access key, the key is stored in your Red Hat Account


## Deploying the container with podman

- Deploy the container using the podman command below.  Change the regsitry image to local registry if operating in an air-gapped environment

```console
export RHOKP_KEY="key from RHN"

podman run --rm -p 8080:8080 -p 8443:8443 --name rhokp --env "ACCESS_KEY=${RHOKP_KEY}" -d registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest
```

## Deploying the container on OpenShift

- Update the image to local registry if operating in an air-gapped environment
- Update the access key

```console
oc create -f rhokp-deployment.yaml
```
