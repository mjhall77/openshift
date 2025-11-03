# htpasswd authentication

- Using htpasswd authentication in OpenShift Container Platform allows you to identify users based on an htpasswd file. An htpasswd file is a flat file that contains the user name and hashed password for each user.  You can use the htpasswd utility to create this file which is provided by httpd-tools rpm.

- To create an htpasswd run the following command.  **Note: adding the -c flag will create the file, if a file already exists it will overwrite it**

```console
htpasswd -c -B </path/to/file> <username>
```

- Create an openshift secret in the openshift-config namespace for the htpasswd file

```console
oc create secret generic htpass-secret --from-file=htpasswd=/path/to/htpasswd -n openshift-config
```

- Add indentity provider to the cluster by applying htpasswd-config.yaml 

```console
oc apply set-last-applied -f htpasswd-config.yaml 
```

- Once the pods in openshift-authentication have been refreshed, users in the htpasswd file would be able to authenticate.  The AGE field should be releatively short

```console
oc get po -n openshift-authentication -o wide
```

# Add, Remove, Update password for users

- To extract current htpasswd secret

```console 
oc extract secret/htpass-secret --to - -n openshift-config > htpasswd
```

- To add users or change password for user in the htpasswd file

```console
htpasswd -B </path/to/file> <username>
```

- To remove a user, simply remove the entry from the file and save

- To update secret with updated htpasswd file
oc create secret generic htpass-secret --from-file=htpasswd --dry-run -o yaml -n openshift-config | oc replace -f -

- To create groups for users in an htpasswd file
  - oc adm groups new <groupname> user1 user2
    - example: oc adm groups new developers developer1 developer2

- Grant persmission to user or group
  - oc policy add-role-to-user view <role > <username> -n <project>    # add cluster role to user in namespace - not cluster wide

  - oc adm policy add-cluster-role-to-user <cluster role> <user>       # add cluster role to user - cluster wide

  - oc adm policy add-cluster-role-to-group <cluster role> <group>       # add cluster role to group - cluster wide
