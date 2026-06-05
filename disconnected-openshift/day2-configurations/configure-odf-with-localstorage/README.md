# Configure ODF on bare metal with local-storage operator:  
- Red Hat OpenShift Data Foundation (ODF) is a software-defined storage solution designed specifically for hybrid cloud applications running on Red Hat OpenShift. It provides persistent file, block, and object storage, simplifying data management for containers through automation, encryption, and Rook-Ceph technology, ensuring consistent storage services across bare metal, virtualized, and cloud environments.

- RH Docs: https://docs.redhat.com/en/documentation/red_hat_openshift_data_foundation/4.21/html/deploying_openshift_data_foundation_using_bare_metal_infrastructure/deploy-using-local-storage-devices-bm#creating-openshift-data-foundation-cluster-on-bare-metal_local-bare-metal

- List the storage class
```console
oc get storageclass
```

- (Optional) Disable "storageclass.kubernetes.io/is-default-class" annotation for the default StorageClass first
```console
oc patch storageclass ocs-storagecluster-ceph-rbd -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'
```

- (Optional) Make another storage class the default (in this example, gp3-csi is configured as the default):
```console
oc patch storageclass ocs-storagecluster-cephfs -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'
```

# Use Non SSD/NVMe Drives (non-production only)
- ODF requires SSD / NVMe drives but can make use of "spinning disks", not recommended for production

- Create machine config
```console
butane 99-set-nonrotational-mc.bu -o 99-set-nonrotational-mc.yaml
```

- Apply machine config
```console
oc create -f 99-set-nonrotational-mc.yaml
```

# Wipe the ODF drives (only if needed)
- If you re-deploy an OpenShift cluster that had ODF deployed you may need to wipe the previously used disks to install a new ODF cluster

- Determine the drive(s) that you need to wipe
```console
oc debug node/<nodename>

chroot /host

lsblk  # identify the disks you want to use for ODF

wipefs -af /dev/<disk>   # disk you want to use for ODF
```

