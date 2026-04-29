# Red Hat Devspaces Disconnected 
- Red Hat OpenShift Dev Spaces is a web-based, collaborative integrated development environment (IDE) that is specifically optimized for OpenShift. It provides consistent, pre-configured, and secure container-based developer workspaces, eliminating "it works on my machine" issues by standardizing environments. 


## Need to pull the following content from an internet connected machine
- Add the following to the redhat-registry-index section in imageset-config
```yaml
packages:
        - name: devspaces
          channels:
            - name: stable
        - name: devworkspace-operator
          channels:
            - name: fast
```

- Add the plugin image to additional images section of image-config.yaml..   Get latest release:  https://catalog.redhat.com/en/search?q=devspaces
  NOTE: if you require additional plugins you will need to create a custom plugin regsitry:  https://github.com/eclipse-che/che-plugin-registry
```yaml
mirror:
  additionalImages:
    - name: registry.redhat.io/devspaces/trava-plugin-registry-rhel8:3.15 # Use your specific version
```

- Build Getting started template devfiles image requires podman to be installed
```console
mkdir plugin-registry-repo

git clone https://github.com/devfile/registry.git

cd plugin-registry-repo

export USE_PODMAN=true

bash .ci/build.sh linux/arm64
```

- Save index image to tarball for export to disconnected environment
```console
podman save localhost/devfile-index:latest > defile-index-latest.tar
```

## Disconnected Oenshift Cluster Actions
- Deploy the devspaces and devworkspaces-operators via gui

- Create a CheCluster object in the openshift-devspaces namespace
```yaml
apiVersion: org.eclipse.che/v1alpha1
kind: CheCluster
metadata:
  name: devspaces
  namespace: openshift-devspaces
spec:
  components:
    cheServer:
      extraProperties:
        # Redirect the "Getting Started" samples to your internal Git server
        CHE_SAMPLES_CONFIG_JSON_URL: "http://internal-git.com/samples/samples.json"
    devfileRegistry:
      externalDevfileRegistries:
        - url: "https://devfile-registry.apps.your-cluster.com"
    pluginRegistry:
      openVsxRegistryUrl: "https://your-internal-open-vsx.com"
  networking:
    tlsSupport: true
  # Ensure workspaces use your internal registry for stack images
  devEnvironments:
    defaultComponents:
      - name: universal-developer-image
        container:
          image: "your-internal-registry.com/devspaces/udi-rhel8:latest"
```


- Get the lates 
## Create the offline devfile and plugin registry


