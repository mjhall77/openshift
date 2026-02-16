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

# Build a Scan 

- The ScanSetting defines the operational parameters of the scan. It doesn't tell the operator which security rules to check; instead, it defines how the infrastructure should behave during the process; schedule, storage, retention, roles.  A sample stig-scansetting.yaml is provided in the repo, you can use as is or modify then apply
```console
oc create -f stig-scansetting.yaml
```

- The ScanSettingBinding is the object that actually triggers the work. It acts as a bridge that links your desired security policies to the operational settings defined in the ScanSetting.  A sample stig-scansettingibingd.yaml is provided in the repo, you may need to update the profile to a version available in your environment.
```console
oc create -f stig-scansettingbinding.yaml
```

- When a ScanSettingBinding is created, the Compliance Operator looks at the referenced ScanSetting. It then generates a ComplianceSuite (and subsequently ComplianceScan objects) for every profile listed in the binding, using the schedule and storage rules you defined.

- View progress of scans - depending on number of profiles and nodes it could take some time for the scans to complete
```console
oc get compliancesuites.compliance.openshift.io -n openshift-compliance

oc get compliancescans.compliance.openshift.io -n openshift-compliance
```

- View the checks that did not pass the compliance rule
```console
oc get compliancecheckresults.compliance.openshift.io -n openshift-compliance | grep -i failed
```

- View the remediations for the rules that did not pass the check
```console
oc get complianceremediations.compliance.openshift.io -n openshift-compliance
```

- Apply remediations -> This will cause the MachineConfig operoatr to create an object and do a rolling reboot all imapacted nodes
```console
$ oc patch complianceremediations rhcos4-e8-worker-sysctl-kernel-dmesg-restrict -p '{"spec":{"apply":true}}' --type=merge
```

- To apply multiple remediaitons you will need to pause the MachineConfigPool -> Do not forget to unpause
```console
$ oc patch machineconfigpools worker -p '{"spec":{"paused":true}}' --type=merge
```

- To rescan the cluster run the following
```console
oc annotate -n openshift-compliance compliancescans/ocp4-stig-v2r1 compliance.openshift.io/rescan=
```

# Pull the reports
- To retrieve the scan results.  Define and spawn a pod that mounts the PVC and sleeps, then copy the files out of the PVC to a local filesystem.
```console
oc apply -f pv-extract.yaml -n openshift-compliance
```

- Extract the scan results
```console
oc cp pv-extract:/master-scan-results ./extract_results_dir -n openshift-compliance
```

- Delete the pv-extract pod due it mounting the pv
```console
oc delete pod pv-extract
```
