# Red Hat Devspaces Disconnected 
- Red Hat OpenShift Dev Spaces is a web-based, collaborative integrated development environment (IDE) that is specifically optimized for OpenShift. It provides consistent, pre-configured, and secure container-based developer workspaces, eliminating "it works on my machine" issues by standardizing environments. 

- To improve developer experience recommend deploying the kubernetes imagepuller operator from the community index.  The operator essentially automates the proces of "pre-pulling" images identified to all worker nodes thus reducing the time to start a devspaces workspace. 


- To provide an internet connected feel for devspaces there are a couple of things that need to be created / pulled from an internet facing system
  - Build plugin repo  Doc: https://docs.redhat.com/en/documentation/red_hat_openshift_dev_spaces/3.27/html/administration_guide/assembly_managing-ide-extensions_administration_guide#proc_running-open-vsx-using-cli_administration_guide
  - Build sample devfile repo (Optional, recommended for inital setup) - You can get the devfile and associated image from https://github.com/devfile/registry.git opposed to building registry
  - devspaces and devworkspace-operator

## Build the plugin repo 
- requirements is to have podman, git and yarn installed and login into registry.redhat.io
```console
sudo dnf install podman yarn git -y

podman login registry.redhat.io
```

- Clone repo and update openvsx-sync.json file and build, depending on the number of plugins it could take several minutes to build
```console
git clone https://github.com/redhat-developer/che-plugin-registry.git

cd che-plugin-registry 

vim openvsx-sync.json  #optional if you want to add / remove plugins

./build.sh -r localhost -t custom
```

- Image localhost/devspaces/pluginregistry-rhel9:custom will be created
```console
podman images localhost/devspaces/pluginregistry-rhel9:custom
```

- Save index image to tarball for export to disconnected environment
```console
podman save localhost/devspaces/pluginregistry-rhel9:custom > pluginregistry-rhel9.tar
```

## Build sample devfile registry (optional)
- Clone repo, update stack directory and build, depending on the number of sample templates in stack directory it could take a couple minutes to build
NOTE: We will need to add the image from each devfile.yaml to additionalImages in the imageset-config so the workspace can launch.  Recommendation for the platform and developers to sync on workspaces requried. 
```console
git clone https://github.com/devfile/registry.git

export USE_PODMAN=true

# Add/Remove sample templates from stack directory.  

bash .ci/build.sh linux/amd64 offline
```

- Save index image to tarball for export to disconnected environment
```console
podman save localhost/devfile-index:latest > devfile-index-latest.tar
```

- Copy repo needed to deploy devfile registry
``` console
git clone https://github.com/devfile/registry-support.git

tar -cvf registry-support-repo.tgz registry-support/*
```

- Need to pull the following content from an internet connected machine
- Add the following to the redhat-registry-index section in imageset-config.yaml
```yaml
  additionalImages:
    - name: <image in devfile for stack>  
    - name: <image in devfile for stack>
    - name: <image in devfile for stack>
  operators:
    # Red Hat Operator Index Catalog
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.20
      packages:
        - name: devspaces
          channels:
            - name: stable
        - name: devworkspace-operator
          channels:
            - name: fast
```

## Checklist to transfer to disconnected network
  - imageset-config.yaml
  - d2m mirror_seq_XXXXX.tar
  - pluginregistry-rhel9.tar
  - registry-support-repo.tgz 
  - devfile-index-latest.tar

## Disconnected Openshift Cluster Actions
- Disk-2-Mirror the images using oc-mirror

- Install Devspaces Operator via Gui Ecosystem -> Software Catalog -> Red Hat OpenShift Dev Spaces -> Install (keep defaults).  You should notice that the DevWorkspace Operator gets installed at the sametime Dev Spaces operator is installed

- Create OpenShift project devspaces
```console
oc new-project devspaces
```

- Create CheCluster via GUI, Ecosystem -> Installed Operators -> DevSpaces -> Create instance.   NOTE: Ensure project is set to devspaces namesapce and keep defaults

- Wait for all pods in the devspaces project to be running before continuing

## Deploy Plugin Registry
- Push the plugin registry image to local repo
```console
podman load --input pluginregistry-rhel9.tar

podman tag localhost/devspaces/pluginregistry-rhel9:custom <internal-registry-fqdn>:8443/pluginregistry-rhel9:custom

podman push <internal-registry-fqdn>:8443/pluginregistry-rhel9:custom
```

- Configure cheCluster with plugin registry image.  It will deploy a new pod and update the pluginregistry URL for you, plugins will be available when you launch devspace
```console
oc patch checluster devspaces --type='merge' -p '{"spec": {"components": {"pluginRegistry": {"deployment": {"containers": [{"image": "<registry-fqdn:port>/devspaces/pluginregistry-rhel9:custom"}]}}}}}'
```

- NOTE:  The available plugins for installation appear under popular.  Installing plugins causes an extension marketplace lifecycle refresh. Because the environment is disconnected from the public internet, this refresh causes a caching or routing conflict that completely zeroes out the "Popular" section in the UI.  To ge the list of plugins under popluar type @popular in the extenisions marketplace. 

## Deploy the devfile registry (optional)
- Push the devfile image to local repo 
```console
podman load --input devfile-index-latest.tar 

podman tag localhost/devfile-index:latest <internal-registry-fqdn>:8443/devfile-index:latest

podman push <internal-registry-fqdn>:8443/devfile-index:latest
```

- Extract the registry-support-repo for helm and run the helm chart
```console
tar -xvf registry-support-repo.tgz

cd registry-support-repo

helm install devfile-registry ./deploy/chart/devfile-registry --set devfileIndex.image=<registry-fqdn:port>/devspaces/devfile-index --set devfileIndex.tag=latest
```

- Once helm deployment completes update the cheCluster devspaces CR with the route
```console
oc get po   # wait for devfile-regsitry to become ready

oc expose svc devfile-regsitry

oc get route 

oc patch checluster devspaces --type='merge' -p '{"spec": {"components": {"devfileRegistry": {"externalDevfileRegistries": [{"url": "http://<devfile-registry route>"}]}}}}'
```

## Configure the number of devspaces instances for a user
- By default a devuser can have an unlimited number of workspaces but only 1 workspace running at a time.  The following section will help you configure the number of workpsaces and running workspaces allowed per user.

- Get the number of workspaces a user can have.  A -1 indicates unlimited
```console
oc get checluster/devspaces -n devspaces -o jsonpath='{.spec.devEnvironments.maxNumberOfWorkspacesPerUser}'
```

- Get the number of workspaces a user can have, defualt is 1.  If there no value is returned then 1 running devsapce per user
```console
oc get checluster/devspaces -n devspaces -o jsonpath='{.spec.devEnvironments.maxNumberOfRunningWorkspacesPerUser}'
```

- Set the number of workspaces a user can have.
```console
oc patch checluster/devspaces -n devspaces --type='merge' -p '{"spec":{"devEnvironments":{"maxNumberOfWorkspacesPerUser": 3}}}'
```

- Set the number of running workspaces a user can have.
```console
oc patch checluster/devspaces -n devspaces --type='merge' -p '{"spec":{"devEnvironments":{"maxNumberOfRunningWorkspacesPerUser": 3}}}'
```
