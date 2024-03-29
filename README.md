# Gluster CSI Driver for Kubernetes

## Overview

This repository hosts the GlusterFS CSI driver, identified by the CSI plugin name "gluster.csi.k8s.io." The development of this driver was inspired by the csi-driver-nfs project available at https://github.com/kubernetes-csi/csi-driver-nfs. Its purpose is to restore fundamental GlusterFS client support on OpenShift/OKD versions 4.12 and above. The Gluster CSI driver facilitates both dynamic and static provisioning, allowing users to either create on demand PVC with dynamic provisioning or use pre-existing volumes/subdirectories through static provisioning. When utilizing a storage class, PVs are presented as subdirectories within the Gluster volume.


## Build

```
git clone https://github.com/levindecaro/csi-driver-glusterfs.git
cd csi-driver-glusterfs
podman build -t  csi-driver-glusterfs:latest  .
```

## Installation

```
kubectl create -f deploy/.

```

### Create Service Endpoints

Modify the external endpoints that match your gluster pool

```
kubectl create -f deploy/example/service.yaml
```

### Create storage class for dynamic provisioning

Modify the following parameters
```
parameters:
  server: <your primary glsuter endpoint>
  share: <gluster shared volume>
```
```
mountOptions:
  - backup-volfile-servers=<additonal gluster endpoints>
```

#### Optionally specify default uid/gid on the PV for the storageclass

```
parameters:
  uid: '1000'
  gid: '1000'
```


```
kubectl create -f deploy/example/storageclass.yaml
```


Remark: Dynamic Provisioning using storageclass are not support quota features, you have to run gluster volume quota cmd out of band 

```
gluster volume quota <vol> limit-usage /pvc-<uuid> 10GB
```


## Create Static provisioning

Mount your brick root directory
```
mount -t glusterfs glsuter-0:/data /mnt
cd /mnt
mkdir static-0
chmod <uid>:<gid> static-pv #match your pod runtime uid/gid
```
### Create PV/PVC

modify example/static-pv.yaml with the paramters and options, such as

```
  mountOptions:
    - rw
    - backup-volfile-servers=gluster-1.okd.local:gluster-2.okd.local
```
```
parameters:
  uid: '1000'
  gid: '1000'
```

and 
```
   volumeAttributes:
      server: gluster-0.okd.local #Primary gluster endpoint
      share: /data/static-0 #volumes/subdirectory
```

finally
generate a unique uuid for the volumeHandle using "uuidgen" util on OS

```
    volumeHandle: 8dd8cb13-dd16-419e-b89c-b6536c0c35d6 # Run uuidgen to generate a unique id
```

```
kubectl create -f example/static-pv.yaml
```

## Quota Setup for static provisioning

```
gluster volume quota <vol> enable
```

```
gluster volume quota <vol> limit-usage /<dir> 10GB
```


## Known Limitation
- CSI Snapshot/SnapshotClass/SnapshotContent not supported
- Resizer modify PV/PVC attributes only, you need to adjust quota from gluster volume/subdir seperately. 

