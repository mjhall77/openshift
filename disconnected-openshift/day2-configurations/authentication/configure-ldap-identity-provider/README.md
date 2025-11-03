# LDAP authentication

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

- It will take a couple of minutes for the authentication cluster operator to update, to track status run the following and wait for the *Authentication* operator Available True and Progressing False

```console
oc get co
```

- Once complete log out of the console, then go back to the console and you should see ldap provider as an option for authentication


# Troubleshooting

- If AD users are not able to authenticate to the cluster, here are a couple of troubleshooting steps to try:

- Test using the search strings below, you should get results if configuration is correct

```console
LDAP_REQ=never ldapsearch -x -D ldap_svc@openshift.example.com -W -H ldap://mydomaincontroller.openshift.example.com:389 -b "OU=users,DC=openshift,DC=example,DC=come,?sAMAccountName"

LDAPTLS_REQ=never ldapsearch -x -D ldap_svc@openshift.example.com -W -H ldaps://mydomaincontroller.openshift.example.com:636 -b "OU=users,DC=openshift,DC=example,DC=come,?sAMAccountName"
```

- Additional troubleshooting might be required, look at the logs for the oauth pods for errors

```console
oc logs -l app=oauth-openshift -n openshift-authentication
```

# LDAP Group Sync - Configure Cronjob

- Once users can successfully authenticate via LDAP, next step is to configure LDAP group sync. It synchronizes user groups from an external LDAP directory into OpenShift, allowing administrators to manage permissions and access for groups defined in a central location

- You will need to create the following CRs: Namespace, Service Account, Cluster Role, Cluster Role Binding, Sync Config Map, Whitelist Config Map of Groups, CronJob

- Samples of these are located the repo

- Update the ldap-sync-service-account.yaml then apply it

```console
oc new-project ldap-sync

oc apply -f ldap-sync-service-account.yaml
```

- Create the Ldap Group Sync role

```console
oc apply -f ldap-sync-cluster-role.yaml
```

- Create the Cluster Role Binding **Note if you change the serivce account name you will need to update the ldap-sync-cluster-role-binding.yaml config**

```console
oc apply -f ldap-sync-cluster-role-binding.yaml
```

- Create the config map for either secure or unsecure connection. To sync specific groups you will need to update the groupUIDNameMapping section of the cm

```console
oc apply -f cm-secure-ldap-groupsync.yaml
```

- Create a group-list cm for mapping groups

```console
oc apply -f ldap-sync-grouplist.yaml
```

- Create the cronjob that will sync LDAP groups with Openshift Groups

```console
oc apply -f ldap-sync-cron-job.yaml
```

- Once groups are populated with users you will need to configure permissions 
  - **grant role to group at a namspace level:**  oc policy add-role-to-group <cluster-role> <group> -n <namespace>
     - exmaple: oc policy add-role-to-group cluster-admin project1-admin -n project1
  - **grant cluster role to group cluster wide:**  oc adm policy add-cluster-role-to-group <cluster-role> <group>
     - example: oc policy add-cluster-role-to-group cluster-admin administrators
     - example: oc policy add-cluster-role-to-group view security-team

- **Optionally** you can remove self-provisioner.  OpenShift, by default, allows authenticated users to create Projects to logically house their applications. By default all users belong to group system:authenticated:oauth
- In order to disable this, you need to set the annotation

```console
oc patch clusterrolebinding.rbac self-provisioners -p '{ "metadata": { "annotations": { "rbac.authorization.kuberetes.io/autoupdate": "false" } } }'
```
