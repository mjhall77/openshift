# OpenShift Logging with Loki
- An extremely important function of OpenShift is collecting and aggregating logs from the environments and the application pods it is running.

- The cluster logging components are based upon Vector and Loki. Vector is a high-performance observability data pipeline that allows users to configure "log forwarders" to direct Openshift logs to different log collectors. Loki is log storage built around the idea of only indexing metadata about your logs with labels (just like Prometheus labels). Log data itself is then compressed and stored in chunks in object stores, or even locally on the filesystem.

- The configuation below assumes access to S3 storage (Minio is sufficent)

- **Install the Loki, Red Hat OpenShift Logging, and Cluster Observability Operators in the cluster**

- The Red Hat OpenShift Logging operator needs to be installed in the openshift-logging namespace. Accept all other defaults and Install

- Loki select Enable Operator recommended cluster monitoring on this Namespace. Leave all other defaults and Install

- Observability operator, leave defaults and Install

- Create an S3 bucket to storage the logs, for the example we will use the bucket name loki-cluster-logs

# Create Secret for S3 bucket
- This secret will store the access credentials for the s3 bucket loki-cluster-logs. This will later be used by the LokiStack to store logging data
  **Update the lokistack-s3-secret.yaml file with your credentials**

```console
oc create -f lokistack-s3-secret.yaml
```

# Create the LokiStack CR
- Create the loki stack instance, it may take several minutes for the pods to deploy.  Do oc get po -n openshift-logging to get status
**Update the lokistack-cr.yaml file with your secret**

```console
oc create -f lokistatck-cr.yaml
```

# Create the collectors service account
- configure the 'collector' service account with these commands to enable log collection for applications, audits, and infrastructure within the OpenShift cluster

```console
oc create sa collector -n openshift-logging
oc adm policy add-cluster-role-to-user logging-collector-logs-writer -z collector -n openshift-logging
oc project openshift-logging
oc adm policy add-cluster-role-to-user collect-application-logs -z collector
oc adm policy add-cluster-role-to-user collect-audit-logs -z collector
oc adm policy add-cluster-role-to-user collect-infrastructure-logs -z collector
```

# Configure Cluster Log Forwarder
- Create a ClusterLogForwarder CR to configure log forwarding of OpenShift logs to Loki

```console
oc create -f clusterlogforwarder-cr.yaml
```

# Create the UIPlugin CR
- The UIPlugin will create a logs tab under Observe in the OpenShift Console to view logs.  It may take a minute to configure, you may see a message "Web console update is available", refresh the page and you should see logs under observe. 

```console
oc create -f loki-uiplugin.yaml
```

- You should now see all the logs for Infrastructure. The logs are split into 3 sections: application, infrastructure and audits
