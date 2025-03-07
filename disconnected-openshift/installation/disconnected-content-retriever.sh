#/bin/sh
# The purpose of this script is to gather the required bits to perform a disconnected
# openshift installation with the final output being a tarball that can be transferred
# to the disconnected environment

base_dir=/home/mikhall/CLIENTS/

read -p "What is the project name: " project_name
read -p "What release of Openshift: " ocp_version

if [ ! -d ${base_dir}/${project_name}/mirror-registry ]; then mkdir -p ${base_dir}/${project_name}/mirror-registry ; fi 
if [ ! -d ${base_dir}/${project_name}/agents_${ocp_version} ]; then mkdir -p ${base_dir}/${project_name}/agents_${ocp_version}; fi
if [ ! -d ${base_dir}/${project_name}/oc-mirror-configs ]; then mkdir -p ${base_dir}/${project_name}/oc-mirror-configs; fi
if [ ! -d ${base_dir}/${project_name}/openshift-installation-configs ]; then mkdir -p ${base_dir}/${project_name}/openshift-installation-configs; fi

####### should I include pulling the .iso from the depenedices directory for non agent installations ################

cp openshift-helper-tools.tar ${base_dir}/${project_name}/openshift-installation-configs/

printf "Getting ${ocp_version} agents required for disconnected installation \n"

printf "openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz \n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz ]; then
	curl -L -o ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz \n"
fi

printf "openshift-client-linux-adm64-rhel8-${ocp_version}.tar.gz \n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel8-${ocp_version}.tar.gz ]; then
	curl -L -o ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel8-${ocp_version}.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-client-linux-adm64-rhel8-${ocp_version}.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel8-${ocp_version}.tar.gz \n"
fi

printf "oc-mirror.tar.gz \n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/oc-mirror.tar.gz ]; then
	curl -l -o ${base_dir}/${project_name}/agents_${ocp_version}/oc-mirror.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/oc-mirror.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/oc-mirror.tar.gz \n"
fi

printf "oc-mirror.rhel9.tar.gz\n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/oc-mirror.rhel9.tar.gz ]; then
	curl -l -o ${base_dir}/${project_name}/agents_${ocp_version}/oc-mirror.rhel9.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/oc-mirror.rhel9.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/oc-mirror.rhel9.tar.gz \n"
fi

printf "openshift-install-linux.tar.gz\n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/openshift-install-linux.${ocp_version}.tar.gz ]; then
	curl -l -o ${base_dir}/${project_name}/agents_${ocp_version}/openshift-install-linux.${ocp_version}.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-install-linux.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/openshift-install-linux.${ocp_version}.tar.gz \n"
fi

printf "openshift-install-rhel9-amd64.tar.gz\n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/openshift-install-rhel9-amd64.tar.gz ]; then
	curl -l -o ${base_dir}/${project_name}/agents_${ocp_version}/openshift-install-rhel9-amd64.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-install-rhel9-amd64.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/openshift-install-rhel9-amd64.tar.gz \n"
fi

printf "butane-adm64\n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/butane-amd64 ]; then
        curl -L -o ${base_dir}/${project_name}/agents_${ocp_version}/butane-amd64 https://mirror.openshift.com/pub/openshift-v4/clients/butane/latest/butane-amd64
else
        printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/butane-amd64\n"
fi

printf "helm-linux-amd64.tar.gz\n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/helm-linux-amd64.tar.gz ]; then
        curl -L -o ${base_dir}/${project_name}/agents_${ocp_version}/helm-linux-amd64.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64.tar.gz
else
        printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/helm-linux-amd64.tar.gz\n"
fi

printf "virtctl\n"
virtctl_version=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
curl -L -o ${base_dir}/${project_name}/agents_${ocp_version}/virtctl-${virtctl_version}-linux-amd64 https://github.com/kubevirt/kubevirt/releases/download/${virtctl_version}/virtctl-${virtctl_version}-linux-amd64
printf "Virtctl pulled\n"

printf "mirror-registry.tar.gz\n"
if [ ! -f ${base_dir}/${project_name}/mirror-registry/mirror-registry.tar.gz ]; then
	curl -L -o ${base_dir}/${project_name}/mirror-registry/mirror-registry.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/mirror-registry/1.3.9/mirror-registry.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/mirror-registry/mirror-registry.tar.gz\n"
fi


################################################################################################################
# The following is documentation to include with the disconnected package to be transferred to the remote system
################################################################################################################

## Example agent-config.yaml 
cat > ${base_dir}/${project_name}/openshift-installation-configs/template-agent-config.yaml <<'_EOF'
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
cat > ${base_dir}/${project_name}/openshift-installation-configs/template-install-config.yaml <<'_EOF'
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

------------------ bonded with vlan example  ---------------------------------
  - hostname: master0
    role: master
    interfaces:
     - name: enp0s4
       macAddress: 00:21:50:90:c0:10
     - name: enp0s5
       macAddress: 00:21:50:90:c0:20
    networkConfig:
      interfaces:
        - name: bond0.300
          type: vlan
          state: up
          vlan:
            base-iface: bond0
            id: 300
          ipv4:
            enabled: true
            address:
              - ip: 10.10.10.14
                prefix-length: 24
            dhcp: false
        - name: bond0
          type: bond
          state: up
          mac-address: 00:21:50:90:c0:10
          ipv4:
            enabled: false
          ipv6:
            enabled: false
          link-aggregation:
            mode: active-backup
            options:
              miimon: "150"
            port:
             - enp0s4
             - enp0s5
      dns-resolver:
        config:
          server:
            - 10.10.10.11
            - 10.10.10.12
      routes:
        config:
          - destination: 0.0.0.0/0
            next-hop-address: 10.10.10.10
            next-hop-interface: bond0.300
            table-id: 254

------------------- static SNO example ---------------------------------

apiVersion: v1beta1
kind: AgentConfig
metadata:
  name: << name oc cluster example: sno-cluster >>
rendezvousIP: << ip of SNO server example: 192.168.111.80 >>
additionalNTPSources:
  - 0.north-america.pool.ntp.org
  - 1.north-america.pool.ntp.org
hosts:
  - hostname: << server name short/fqdn exmaple: master-0 >>
    interfaces:
      - name: << interface name example: eno1 >>
        macAddress: << interface mac example: 00:ef:44:21:e6:a5 >>
    rootDeviceHints:
      deviceName: << install drive exmaple: /dev/sdb >>
    networkConfig:
      interfaces:
        - name: << interface name example: eno1 >>
          type: ethernet
          state: up
          mac-address: << interface mac example: 00:ef:44:21:e6:a5 >>
          ipv4:
            enabled: true
            address:
              - ip: << ip address example: 192.168.111.80 >>
                prefix-length: << subnet example: 24 >>
            dhcp: false
      dns-resolver:
        config:
          server:
            - << dns server example: 192.168.111.1 >>
            - << dns server2 example: 192.168.111.2 >>
      routes:
        config:
          - destination: 0.0.0.0/0
            next-hop-address: << default gw example: 192.168.111.2 >>
            next-hop-interface: << interface name example: eno1 >>
            table-id: 254


_EOF

cat > ${base_dir}/${project_name}/mirror-registry/notes.txt <<'_EOF'
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

cat > ${base_dir}/${project_name}/oc-mirror-configs/oc-mirror.txt <<'_EOF'
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

# For disconnected registry
podman login -u << username >> --auth-file=./local_pull_secret.json << registry_name:port >>

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
		if [ ! -f ${base_dir}${project_name}/imageset-config.yaml ]; then
			printf "Could not find ${base_dir}${project_name}/imageset-config.yaml, cannot run oc-mirror...  \n"
		fi
		cp installation-config-files/imageset-config.yaml-template ${base_dir}${project_name}/oc-mirror-configs/
		cd ${base_dir}${project_name}
		oc-mirror --config=imageset-config.yaml file://oc-mirror-image-content
		break;;
	[Nn]* )
		cp installation-config-files/imageset-config.yaml-template ${base_dir}${project_name}/oc-mirror-configs/
		break;;
	*) printf "Invalid response.  Pleast enter (y/n)" ;;	
	esac
done

printf "\nGenerating tarball of installattion artifacts"
cd ${base_dir}${project_name}
tar -cvf ${ocp_version}-disconnected-installation-components.tgz mirror-registry agents_${ocp_version} oc-mirror-configs openshift-installation-configs 
rm -rf mirror-registry agents_${ocp_version} oc-mirror-configs openshift-installation-configs 
