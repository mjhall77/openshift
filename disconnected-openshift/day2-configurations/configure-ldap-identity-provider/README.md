# LDAP Group Sync 

- OCP works with many authentication providers such as Github, Gitlab, HTPASSWD, Google, OpenID, as well as LDAP. Active Directory is based on LDAP so it will be used to allow users to login to the OCP cluster.
- This configuration in an example of adding LDAP as an Oauth provider, syncing AD groups and assiging roles (permissions) that each of these groups will have.

- For referece see the following blog: https://myopenshiftblog.com/adding-active-directory-oauth-provider/

- You will need the following data for configuration

   - URL to Domain Controller:
       - **example not using tls:** ldap://mydomaincontroller.openshift.example.com:389/DC=openshift,DC=example,DC=come,?sAMAccountName
       - **example using tls:** ldaps://mydomaincontroller.openshift.example.com:636/DC=openshift,DC=example,DC=come,?sAMAccountName

   - Bind DN which is typically a service account that has permission to query domain:
       - example:  ldap_svc@openshift.example.com

   - Bind DN password

   - Certificates for DC if using tls:
     - example:  openssl s_client -connect mydomaincontroller.openshift.example.com:636 -showcerts

- Recommend configuration via GUI form: **Administration -> Cluster Settings -> Configuration -> Oauth -> Add under Identity Providers**

```console
sudo bash

export KUBECONFIG=/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/lb-int.kubeconfig

oc get csr | grep -i pending
```

- The command above lists pending CSR that must be approved for the cluster to trust them

```console
oc get csr -o name | xargs oc adm certificate approve

```

- You may have to wait a couple minutes and run the get csr and certificate approve commands a couple of times..

- To get the status of the cluster run the following commands, you may require more steps depending on the results

```console

  - You should be able to log in once configurations have been completed
    - oc get co
    - oc get po -n openshift-authentication  <should have short age>

# Troubleshooting steps
  - Test using the search strings below, you should get results if configuration is correct
   LDAPTLS_REQCERT=never ldapsearch -x -D ldap_svc@openshift.example.com -W -H ldap://mydomaincontroller.openshift.example.com:389 -b "OU=users,DC=openshift,DC=example,DC=come,?sAMAccountName"
   LDAPTLS_REQCERT=never ldapsearch -x -D ldap_svc@openshift.example.com -W -H ldaps://mydomaincontroller.openshift.example.com:636 -b "OU=users,DC=openshift,DC=example,DC=come,?sAMAccountName"

  -  Review logs of Oauth pods
     oc logs -l app=auth-openshift


# Next steps you will want to configure groups in Openshift and bind the AD groups to them
  - grant role:  oc policy add-role-to-group cluster-admin administrators   <namespace level access>
  - grant cluster role:  oc adm policy add-cluster-role-to-group cluster-admin administrators   <cluster wide access>

# Create ldap sync configuration file
  - examples in repo

# Run ldap sync file from bastion server
  oc adm groups sync -sync-config=secure-ldap-groupsync.yaml "CN=OpenshiftAdmins,OU=Groups,DC=openshift,DC=example,DC=com" --confirm

# Verify users in group have access as configured


------------------ Disable self-provisioner ---------------------------
# OpenShift, by default, allows authenticated users to create Projects to logically house their applications.
# By default all users belong to group system:authenticated:oauth
# View self-provisioners role
oc describe clusterrolebinding.rbac self-provisioners

# To remove system:authenticated:oauth from the role binding
oc patch clusterrolebinding.rbac self-provisioners -p '{"subjects": null}'

# Automatic updates reset the cluster roles to a default state. In order to disable this, you need to set the annotation
oc patch clusterrolebinding.rbac self-provisioners -p '{ "metadata": { "annotations": { "rbac.authorization.kuberetes.io/autoupdate": "false" } } }'
```
