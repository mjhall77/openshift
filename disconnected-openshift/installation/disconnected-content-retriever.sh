#/bin/sh
# The purpose of this script is to gather the required bits to perform a disconnected
# openshift installation with the final output being a tarball that can be transferred
# to the disconnected environment

read -p "What release of Openshift: " ocp_version

if [ ! -d mirror-registry ]; then mkdir mirror-registry ; fi 
if [ ! -d agents_${ocp_version} ]; then mkdir agents_${ocp_version}; fi
if [ ! -d oc-mirror-image-content ]; then mkdir oc-mirror-image-content; fi 
if [ ! -d oc-mirror-configs ]; then mkdir oc-mirror-configs; fi
if [ ! -d openshift-installation-configs ]; then mkdir openshift-installation-configs; fi

printf "Getting ${ocp_version} agents required for disconnected installation \n"

printf "openshift-client-linux-${ocp_version}.tar.gz \n"
if [ ! -f agents_${ocp_version}/openshift-client-linux-${ocp_version}.tar.gz ]; then
	curl -L -o agents_${ocp_version}/openshift-client-linux-${ocp_version}.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-client-linux-${ocp_version}.tar.gz
else
	printf "Already pulled agents_${ocp_version}/openshift-client-linux-${ocp_version}.tar.gz \n"
fi

printf "oc-mirror.tar.gz \n"
if [ ! -f agents_${ocp_version}/oc-mirror.tar.gz ]; then
	curl -l -o agents_${ocp_version}/oc-mirror.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/oc-mirror.tar.gz
else
	printf "Already pulled agents_${ocp_version}/oc-mirror.tar.gz \n"
fi

printf "oc-mirror.rhel9.tar.gz\n"
if [ ! -f agents_${ocp_version}/oc-mirror.rhel9.tar.gz ]; then
	curl -l -o agents_${ocp_version}/oc-mirror.rhel9.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/oc-mirror.rhel9.tar.gz
else
	printf "Already pulled agents_${ocp_version}/oc-mirror.rhel9.tar.gz \n"
fi

printf "openshift-install-linux.tar.gz\n"
if [ ! -f agents_${ocp_version}/openshift-install-linux.${ocp_version}.tar.gz ]; then
	curl -l -o agents_${ocp_version}/openshift-install-linux.${ocp_version}.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-install-linux.tar.gz
else
	printf "Already pulled agents_${ocp_version}/openshift-install-linux.${ocp_version}.tar.gz \n"
fi

printf "mirror-registry.tar.gz\n"
if [ ! -f mirror-registry/mirror-registry.tar.gz ]; then
	curl -L -o mirror-registry/mirror-registry.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/1.3.9/mirror-registry.tar.gz
else
	printf "Already pulled mirror-registry/mirror-registry.tar.gz\n"
fi

################################################################################################################
# The following is documentation to include with the disconnected package to be transferred to the remote system
################################################################################################################

## Example agent-config.yaml 
cat > openshift-installation-configs/template-agent-config.yaml <<'_EOF'
apiVersion: v1beta1
kind: AgentConfig
metadata:
  name: 
rendezvousIP: 
additionalNTPSources:
  - 
  - 
hosts:
  - hostname: 
    role: master
    interfaces:
      - name: 
        macAddress: 
    rootDeviceHints:
      deviceName: 
  - hostname: 
    role: master
    interfaces:
      - name: 
        macAddress: 
    rootDeviceHints:
      deviceName: 
  - hostname: 
    role: master
    interfaces:
      - name: 
        macAddress: 
    rootDeviceHints:
      deviceName: 
_EOF

## Example install-config.yaml
cat > openshift-installation-configs/template-install-config.yaml <<'_EOF'
apiVersion: v1
baseDomain:
metadata:
  name:
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr:
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
compute:
- name: worker
  replicas: 0
controlPlane:
  name: master
  replicas: 3
platform:
  none: {}
  baremetal: # bare metal example
    hosts:
      - name: <Control plan 1>
        bootMACAddress:
      - name: <Control plan 2>
        bootMACAddress:
      - name: <Contorl plan 3>
        bootMACAddress:
    apiVIPs:
    -
    ingressVIPs:
    -
fips: false
pullSecret: ' <Pull secret for disconnected registry> '
sshKey: "ssh-rsa "
imageDigestSources:   # The following entries can be pulled from imageContentsourcepolicy.yaml produced by oc-mirror
- mirrors:
  - <FQDN of regsitry>:<PORT>/openshift/release
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
- mirrors:
  - <FQDN of registry>:<PORT>/openshift/release-images
  source: quay.io/openshift-release-dev/ocp-release
additionalTrustBundle: |
  -----BEGIN CERTIFICATE-----
  -----END CERTIFICATE-----
additionalTrustBundlePolicy: Always
_EOF

cat > mirror-registry/notes.txt <<'_EOF'
# set up temporary container registry
# Additional Doc on setting it up:  https://www.redhat.com/en/blog/introducing-mirror-registry-for-red-hat-openshift
curl -L -o mirror-registry.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/1.3.9/mirror-registry.tar.gz
tar -xzvf mirror-registry.tar.gz
./mirror-registry install --initPassword discopass   (The mirror-registry install options allow users to provide their own certificate, if they were issued one, using the --sslCert option.)

# trust the mirror-registry TLS certificate requried for openshift installation
sudo cp -v $HOME/quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/quayCA.pem
sudo update-ca-trust
sudo update-ca-trust extract

# log into the registry (default pull secret for podman: $XDG_RUNTIME_DIR/containers/auth.json where docker is .docker/config.json)
podman login -u init -p discopass $<hostname>:8443 --compat-auth-file ~/.docker/config.json

# publish openshift content to mirror registry:
oc-mirror --from /path/to/archieves docker://<hostname>:8443

# To validate operators in local registry
oc-mirror list operators --catalog=wk-laptop.mikeynet.com:8443/redhat/redhat-operator-index:v4.16

# View in web browser
https://localhost:8443
_EOF

cat > oc-mirror-configs/oc-mirror.txt <<'_EOF'
# Repos
oc-mirror github: https://github.com/openshift/oc-mirror
openshift clients:  https://mirror.openshift.com/pub/openshift-v4/clients/ocp/

----- instructions -------

# Add oc-mirror binary:
curl -L -o oc-mirror.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/oc-mirror.tar.gz
tar -xzf oc-mirror.tar.gz
rm -f oc-mirror.tar.gz
chmod +x oc-mirror
sudo mv oc-mirror /bin

# Add oc cli:
curl -L -o oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
tar -xzf oc.tar.gz oc
rm -f oc.tar.gz
sudo mv oc /bin

# create ~/.docker/config.json file with pull secret (get pull secret from https://console.redhat.com/openshift/install/pull-secret)
mkdir -v $HOME/.docker
cp -v $HOME/pull-secret $HOME/.docker/config.json

# Create imageset configuration file, see example in repo

# copy of running oc-mirror command
oc-mirror --config imageset-config.yaml file:///mnt/low-side-data

# extract contents
oc-mirror --from <directory> docker://<registry>:<port>

--------  extra commands  --------
# Extra oc-mirror examples
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.16
oc-mirror list operators --catalog=registry.redhat.io/redhat/certified-operator-index:v4.16
oc-mirror list operators --catalog=registry.redhat.io/redhat/community-operator-index:v4.16

oc-mirror list releases --channel=stable-4.16
_EOF

############################################################################################################################
# oc-mirror options
#
# Yes will prompt you for your imagesetconfiguration file and place a copy of it in oc-mirror-configs/imageset-conf.yaml
# additionally it will run the following command:  ./oc-mirror-configs/oc-mirror --config=./oc-mirror-configs/imageset-config.yaml file://oc-mirror-image-content
#
# No will create oc-mirror-configs/image-set-configuration-template.yaml
#
############################################################################################################################

while true; do
  read -p "Run oc-mirror (y/n): " answer
  case "$answer" in
	[Yy]* )
	     	read -p "full path to ImageSetConfiguration file: " isc_file
		if [ ! -f $isc_file ]; then
			printf "Could not find $isc_file, cannot run oc-mirror...  \n"
		fi
		printf "Copying $isc_file to oc-mirror-configs\n"
		cp $isc_file oc-mirror-configs
		tar -xvf  agents_${ocp_version}/oc-mirror.tar.gz -C oc-mirror-configs/
		chmod 775 oc-mirror-configs/oc-mirror
		./oc-mirror-configs/oc-mirror --config=./oc-mirror-configs/imageset-config.yaml file://oc-mirror-image-content
		printf "\nGenerating tarball of installattion artifacts"
		tar -cvf ${ocp_version}-disconnected-installation-components.tgz mirror-registry agents_${ocp_version} oc-mirror-image-content mkdir oc-mirror-configs openshift-installation-configs oc-mirror-image-content
		break;;
	[Nn]* )
		cat > oc-mirror-configs/image-set-configuration-template.yaml <<'_EOF'
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
archiveSize: 5
storageConfig:
  local:
    path: ./imageset-back-end
mirror:
  platform:
    architectures:
    - amd64
###############################################################
    channels:
    - name: stable-4.16 # Want to grab specific releases
      type: ocp
      minVersion: 4.16.1
      maxVersion: 4.16.16
      shortestPath: true
    channels:
    - name: stable-4.16 # grab latest
##############################################################
    graph: true
  operators:
  # if you want all operators
  # catalog: registry.redhat.io/redhat/redhat-operator-index:v4.16
  # full: True
  - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.16
    packages:
    - name: advanced-cluster-management
      channels:
      - name: release-2.11
    - name: cincinnati-operator
      channels:
      - name: v1 
    - name: cluster-logging                                    
      channels:
      - name: stable-5.9 
    - name: compliance-operator                                    
      channels:
      - name: stable 
    - name: kubevirt-hyperconverged
      channels:
      - name: stable
    - name: local-storage-operator
      channels:
      - name: stable
    - name: mcg-operator 
      channels:
      - name: stable-4.16
    - name: ocs-client-operator
      channels: 
      - name: stable-4.16
    - name: ocs-operator
      channels:
      - name: stable-4.16
    - name: odf-csi-addons-operator 
      channels:
      - name: stable-4.16
    - name: odf-operator 
      channels:
      - name: stable-4.16
    - name: rhacs-operator 
      channels:
      - name: stable 
    - name: serverless-operator                                     
      channels:
      - name: stable 

  additionalImages:
  - name: registry.redhat.io/ubi8/ubi:latest
  - name: registry.redhat.io/ubi9/ubi:latest
  - name: registry.redhat.io/rhel8/support-tools:latest
  - name: registry.redhat.io/ubi8/nodejs-18:latest
  - name: registry.redhat.io/ubi8/nodejs-18-minimal:latest
_EOF
		printf "\nGenerating tarball of installattion artifacts"
		tar -cvf ${ocp_version}-disconnected-installation-components.tgz mirror-registry agents_${ocp_version} oc-mirror-image-content mkdir oc-mirror-configs openshift-installation-configs 
		break;;
	*) printf "Invalid response.  Pleast enter (y/n)" ;;	
	esac
done
