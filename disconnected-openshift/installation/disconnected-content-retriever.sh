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

cp openshift-helper-tools.tar ${base_dir}/${project_name}/agents_${ocp_version};

printf "Getting ${ocp_version} agents required for disconnected installation \n"

printf "openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz \n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz ]; then
	curl -L -o ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-amd64-rhel9-${ocp_version}.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-client-linux-amd64-rhel9-${ocp_version}.tar.gz
else
	printf "Already pulled ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel9-${ocp_version}.tar.gz \n"
fi

printf "openshift-client-linux-adm64-rhel8-${ocp_version}.tar.gz \n"
if [ ! -f ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-adm64-rhel8-${ocp_version}.tar.gz ]; then
	curl -L -o ${base_dir}/${project_name}/agents_${ocp_version}/openshift-client-linux-amd64-rhel8-${ocp_version}.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${ocp_version}/openshift-client-linux-amd64-rhel8-${ocp_version}.tar.gz
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

## Copy configuration files
cp installation-config-files/*.yaml ${base_dir}/${project_name}/openshift-installation-configs/

## Copy openshift installation documentation
mkdir -p ${base_dir}/${project_name}/disconnected-docs && cp disconnected-docs/* ${base_dir}/${project_name}/disconnected-docs/

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
		cp ${base_dir}${project_name}/imageset-config.yaml ${base_dir}${project_name}/oc-mirror-configs/
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
tar -cvf ${ocp_version}-disconnected-installation-components.tgz mirror-registry agents_${ocp_version} oc-mirror-configs openshift-installation-configs disconnected-docs 
rm -rf mirror-registry agents_${ocp_version} oc-mirror-configs openshift-installation-configs disconnected-docs 
