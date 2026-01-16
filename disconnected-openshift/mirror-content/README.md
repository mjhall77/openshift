# Mirror OpenShift container content for a disconnected installation

- A disconnected environment is an environment that does not have full access to the internet.

- OpenShift Container Platform is designed to perform many automatic functions that depend on an internet connection, such as retrieving release images from a registry or retrieving update paths and recommendations for the cluster. Without a direct internet connection, you must perform additional setup and configuration for your cluster to maintain full functionality in the disconnected environment.

- You can use oc-mirror plugin v2 to mirror images to a mirror registry in your fully or partially disconnected environments. To download the required images from the official Red Hat registries, you must run oc-mirror plugin v2 from a system with internet connectivity.

  - mirrorToDisk - pulls the container images from the source specified in the image set configuration and packs them into a tar archive on disk (local directory).
  - diskToMirror - copy the containers images from the tar archive to a container registry (--from flag is required on this workflow).
  - mirrorToMirror - copy the container images from the source specified in the image set configuration to the destination (container registry).

# Downloads needed for mirror process

- All can be obtained from https://console.redhat.com/openshift/downloads
  - **NOTE:** You will need your Red Hat credentials to log in

- **Openshift command-line interface (oc) for RHEL 9**
  <img src="Screenshot from 2026-01-15 12-58-13.png" width="2000" height="800" alt="oc cli">
 
- **mirror registry for Red Hat OpenShift**
- **OpenShift Client (oc) mirror plugin for RHEL 9**
  <img src="Screenshot from 2026-01-15 12-59-09.png" width="2000" height="800" alt="mirror">

- **pull secret**
  <img src="Screenshot from 2026-01-15 12-59-36.png" width="2000" height="800" alt="pull secret">

# Configure internet connected machine
- RHEL 9 server with 500GB or larger data volume recommended 

- **NOTE** If your system has fapolicyd enabled, do the following 
```console
sudo systemctl stop fapolicyd.service

sudo fapolicyd-cli --file add /usr/loca/bin/oc-mirror
sudo fapolicyd-cli --update

sudo systemctl start fapolicyd.service
```

- Extract binary
```console
tar -xvf oc-mirror.tar.gz

sudo mv oc-mirror /usr/local/bin

sudo chown -R root:root /usr/local/bin/oc-mirror

sudo chmod +x /usr/local/bin/oc-mirror

#If SELinux is in enforcing mode
sudo restorecon -v /usr/local/bin/oc-mirror    

oc-mirror --v2 --help
```

- Copy Pull Secret

```
mkdir -p $XDG_RUNTIME_DIR/containers

cp pull-secret.txt $XDG_RUNTIME_DIR/containers/auth.json
```

- Mirror to disk process
```console
oc-mirror -c ./path/to/imageset-config.yaml --cache-dir=/path/to/data-drive file:///path/to/data-drive/mirror1 --v2
```

