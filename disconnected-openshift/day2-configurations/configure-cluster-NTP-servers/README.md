# Configure NTP for OpenShift cluster post installation

- In an OpenShift environment, Network Time Protocol (NTP) isn't just a "nice-to-have" utility—it is a fundamental requirement for the cluster's health. Because OpenShift is a highly distributed system, it relies on all nodes (masters and workers) being perfectly in sync to maintain order

- If your bastion host is configured to sync time with your internal service you can skip this step, if not use the example below to create a sample chrony.conf
```yaml
# Example chrony.conf
server 10.0.0.1 iburst
server 10.0.0.2 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
``` 

- Encode the chrony.conf configuration into base64
```console
cat chrony.conf | base64 -w0
```

- If there is an existing NTP MachineConfig, it is recommended to update that configuration with the base64 string from previous step.

# Following steps if no NTP MachineConfig currently exists
- Create 99-ntp-configuration.yaml MachineConfig and update configuation with the base64 string on line 14
```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker # Change to 'master' for control plane
  name: 99-worker-ntp
spec:
  config:
    ignition:
      version: 3.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64, <YOUR_BASE64_STRING_HERE>
        mode: 420
        overwrite: true
        path: /etc/chrony.conf
```

- Apply the MachineConfig to the cluster for the Worker nodes
```console
oc apply -f 99-ntp-configuration.yaml
```

- Update 99-ntp-configuration.yaml MachineConfig and change line 5 "master" from "worker"
```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master # Change to 'worker' for control plane
  name: 99-worker-ntp
spec:
  config:
    ignition:
      version: 3.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64, <YOUR_BASE64_STRING_HERE>
        mode: 420
        overwrite: true
        path: /etc/chrony.conf
```

- Apply the MachineConfig to the cluster for the Control Plane (AKA Master) nodes
```console
oc apply -f 99-ntp-configuration.yaml
```

- Get status of the cluster
```
oc get mcp
```
