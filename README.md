


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

