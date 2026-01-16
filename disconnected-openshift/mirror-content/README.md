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

- Install the follwoing packages: podman, nmstate

- If your system has fapolicyd enabled, update policy
```console
sudo systemctl stop fapolicyd.service

sudo fapolicyd-cli --file add /usr/local/bin/oc-mirror
sudo fapolicyd-cli --update

sudo systemctl start fapolicyd.service
```

- Extract binary
```console
tar -xvf oc-mirror.tar.gz

sudo mv oc-mirror /usr/local/bin

sudo chown root:root /usr/local/bin/oc-mirror

sudo chmod +x /usr/local/bin/oc-mirror

#If SELinux is in enforcing mode
sudo restorecon -v /usr/local/bin/oc-mirror    

oc-mirror --v2 --help
```

- Set UMASK to 0022 if set to 0077
```console
umask 0022
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

# Build disconnected bastion server

- RHEL 9 server with 500GB or larger data volume recommended 
  
- Untar the required binaries
```console
tar -xvf mirror-registry.tar.gz    

tar -xvf oc-mirror-tar.gz

tar -xvf openshift-client-linux.tar.gz

tar -xvf openshift-install-linux.tar.gz
```

- Place binaries
```console
sudo mv {mirror-registry, oc, oc-mirror, openshift-install} /usr/local/bin

sudo chown root:root /usr/local/bin/{mirror-registry, oc, oc-mirror, openshift-install}

sudo chmod +x /usr/local/bin/{mirror-registry, oc, oc-mirror, openshift-install}

sudo restorecon -v /usr/local/bin/{mirror-registry, oc, oc-mirror, openshift-install}
```

- If your system has fapolicyd enabled, update policy
```console
sudo systemctl stop fapolicyd.service

sudo fapolicyd-cli --file add /usr/local/bin/oc-mirror
sudo fapolicyd-cli --file add /usr/local/bin/oc
sudo fapolicyd-cli --file add /usr/local/bin/mirror-registry
sudo fapolicyd-cli --file add /usr/local/bin/openshift-install

sudo fapolicyd-cli --update

sudo systemctl start fapolicyd.service; sudo systemctl status fapolicyd.service
```

- Set namespaces to 62372 or greater value
```console
sysctl -a | grep max_user_namespaces
user.max_user_namespaces = 62372

# If value less than 62372 set it
vi /etc/sysctl.d/99-sysctl.conf

sysctl -p /etc/sysctl.d/99-sysctl.conf
```

- Set umask to 0022
```console
sed :%s/077/022/gc /etc/bashrc
sed :%s/077/022/gc /etc/profile
```

- Open port 8443 for mirror registry
```console
sudo firewall-cmd --add-port 8443/tcp --permanent
sudo firewall-cmd --reload
```

```console
mkdir -p /data/mirror-registry

mirror-registry install quayHostname $(hostname -f) --quayRoot /data/mirror-registry --quayStorage --/data/mirror-registry --initUser admin --initPassword redhat123
```

- Add self-signed certifate created during mirror-registry install
```console
sudo cp -v /data/mirror-regsitry/quay-rootCA/rootCA.pim /etc/pki/ca-trust/source/anchors/

sudo update-ca-trust

# test login
podman login $(hostname -f):8443 
```


