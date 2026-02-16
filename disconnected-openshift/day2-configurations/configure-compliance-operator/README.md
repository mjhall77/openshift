# Openshift Compliance Operator
- The OpenShift Compliance Operator assists users by automating the inspection of numerous technical implementations and compares those against certain aspects of industry standards, benchmarks, and baselines.  The Compliance Operator lets OpenShift administrators describe the required compliance state of a cluster and provides them with an overview of gaps and ways to remediate them.

- A rule is a single compliance check. For example the rule rhcos4-service-auditd-enabled checks if the auditd daemon is running on RHCOS. To View the contents of a rule
```console
oc get rule.compliance rhcos4-accounts-no-uid-except-zero -n openshift-compliance -oyaml
```

- To view contents of a rule
```console
oc get rule.compliance rhcos4-accounts-no-uid-except-zero -nopenshift-compliance -oyaml
```

- A profile is a collection of rules that form a single compliance baseline for a product. For a list of profiles available in the deployed compliance operator version
```console
oc get profiles.compliance.openshift.io -n openshift-compliance
```

- View the profile and list of rules 
```console
oc describe profiles.compliance.openshift.io rhcos4-stig-v2r1 -n openshift-compliance
```

- A profilebundle is a collection of profiles for a single product where product might be ocp4 or rhcos4. To view the profile bundles
```console
oc get profilebundles.compliance.openshift.io -n openshift-compliance
```



```yaml
apiVersion: compliance.openshift.io/v1alpha1
debug: true
kind: ScanSetting
metadata:
  name: stig 
  namespace: openshift-compliance
spec:
  rawResultStorage:
    size: "5Gi"
    pvAccessModes:
      - ReadWriteMany
    storageClassName: nfs-manual
    volumeMode: Filesystem
    rotaion: 3
  roles:
    - worker
    - master
  schedule: '0 1 * * *'
```

# Create Scan settings by applying the yaml file.  There are two important pieces of a ScanSettingBinding object:
# profiles: Contains a list of (name,kind,apiGroup) tuples that make up a selection of the Profile (or a TailoredProfile that we will explain later) to scan your environment with.
# settingsRef: A reference to a ScanSetting object also using the (name,kind,apiGroup) tuple that references the operational constraints.
oc apply -f stig-scan-setting-binding.yaml -n openshift-compliance
oc apply -f stig-scan-setting.yaml -n openshift-compliance

# View progress of scans - depending on number of profiles and nodes it could take some time for the scans to complete
oc get compliancesuites.compliance.openshift.io -n openshift-compliance
oc get compliancescans.compliance.openshift.io -n openshift-compliance

# View the checks that are not compliance with the rule
oc get compliancecheckresults.compliance.openshift.io -n openshift-compliance

# View the remediations for the rules that did not pass the check
oc get complianceremediations.compliance.openshift.io -n openshift-compliance

# Apply remediations -> This will cause the MachineConfig operoatr to create an object and do a rolling reboot all imapacted nodes
$ oc patch complianceremediations rhcos4-e8-worker-sysctl-kernel-dmesg-restrict -p '{"spec":{"apply":true}}' --type=merge

# To apply multiple remediaitons you will need to pause the MachineConfigPool -> Do not forget to unpause
$ oc patch machineconfigpools worker -p '{"spec":{"paused":true}}' --type=merge

# To rescan the cluster run the following
oc annotate -n openshift-compliance compliancescans/ocp4-stig-v2r1 compliance.openshift.io/rescan=

------------------------ pull the reports -------------------------

# To retrieve the scan results.  Define and spawn a pod that mounts the PVC and sleeps, 
# then copy the files out of the PVC to a local filesystem.
oc apply -f pv-extract.yaml -n openshift-compliance

# Extract the scan results
oc cp pv-extract:/master-scan-results ./extract_results_dir -n openshift-compliance

# Delete the pv-extract pod due it mounting the pv
oc delete pod pv-extract

###NOTES Need to add content on what to do with the bzip2 files




