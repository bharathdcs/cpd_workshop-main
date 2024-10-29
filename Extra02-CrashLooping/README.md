
# Crashlooping , Running , Completed

This section aims to provide an understand what the pod state means.


## Running

A pod that does not exit and remains runs in the background forever.   E.g.

```
kind: Pod
apiVersion: v1
metadata:
  name: testpod
spec:
  containers:
    - name: cont1
      image : quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "while true; do sleep 30; done;" ]
```

## Completed

A pod will go into Completed  -> CrashLoopback -> Completed forever if the pod exit with status 0.  It is not a desired state. 

```
kind: Pod
apiVersion: v1
metadata:
  name: testpod-complete
spec:
  containers:
    - name: cont1
      image : quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "date ; exit 0" ]
```

## Crash Loopback

A pod will go into crash loopback if the program exits with non-zero status.  Nature of K8s is to restart this pod aka self-healing.


```
kind: Pod
apiVersion: v1
metadata:
  name: testpod-crash
spec:
  containers:
    - name: cont1
      image : quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "exit 1" ]
```

## Debugging a crash loopback pod  - debug.sh

Challenge : the pod keeps crashing.  Describe shows it exit with non-zero status.  Describe also shows the command that it ran.  But it is impossible to rsh into the pod since it never remain alive for long.  So how do you debug such a pod ?

Ans : Mount the same resources using a test pod, and then rsh into the testpod to poke around.

E.g.

> oc get pod zen-metastoredb-0 -o yaml | less

```
  containers:
  - command:
    - /bin/bash
    - -ecx
    - exec /cockroach/cockroach start --max-offset=1000ms --temp-dir=/tmp --max-disk-temp-storage    <=== ran this command
      8GiB --logtostderr --certs-dir=/certs --advertise-host $(hostname).${STATEFULSET_FQDN}
      .....

    volumeMounts:
    - mountPath: /cockroach/cockroach-data    <====  /cockroach is mounted from volumne datadir
      name: datadir

   ...
  volumes:
  - name: datadir
    persistentVolumeClaim:
      claimName: datadir-zen-metastoredb-0    <=== datadir is PVC datadir-zen-metastoredb-0

```

We can create a simple testpod to mount datadir-zen-metastoredb-0 to /mnt and examine the folder.

```
kind: Pod
apiVersion: v1
metadata:
  name: testpod
spec:
  containers:
  - name: testpod
    image: quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
    volumeMounts:
      - name: giveitanyname
        mountPath: "/mnt"
  volumes:
    - name: giveitanyname
      persistentVolumeClaim:
        claimName: datadir-zen-metastoredb-0
```

The testpod needs to be in the same project as the PVC.  The image does not matter unless the interested folder is part of the image and not mounted by the PVC.
