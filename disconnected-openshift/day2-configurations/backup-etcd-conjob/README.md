# Backup etcd database cronjob

- As the primary datastore of Kubernetes, etcd stores and replicates all Kubernetes cluster states. Since it is a critical component of a Kubernetes cluster it is important that etcd has a reliable approach to its configuration and management.

- Additional reference:  https://access.redhat.com/solutions/5843611
Link:  https://access.redhat.com/solutions/5843611

- Create a new project where the backup pods will run

```console
oc new-project ocp-etcd-backup --description "Openshift Backup Automation Tool" --display-name "Backup ETCD Automation"
```
- Create a service account that will run the backup process

```console
oc apply -f sa-etcd-bkp.yml
```
- Create a cluster role for backing up etcd

```console
oc apply -f cluster-role-etcd-bkp.yml
```
- Create a role binding the service account to the cluster role

```console
oc apply -f cluster-role-binding-etcd-bkp.yml
```
- Add a SCC (Security Context Constraint) to the backup service account.  An scc is a cluster-level resource that controls permissions for pods, limiting their access to protected Linux functions like running as root or accessing shared file systems

```console
oc adm policy add-scc-to-user privileged -z openshift-backup
```

- Create the connjob for backing up etcd

```console
oc apply -f cronjob-etcd-bkp.yml
```
