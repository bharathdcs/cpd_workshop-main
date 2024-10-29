#!/bin/bash

. ../common.sh

oc project sandy

msg "Create a sample testpod to mount PVC datadir-zen-metastoredb-0 to /mnt"

oc delete pod testpod

cat <<EOF | oc apply -f -
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

EOF

while :
do
	oc get pod testpod
	oc get pod testpod | grep -E "testpod.*Running" > /dev/null 
	[ $? -eq 0 ] && break
	sleep 5
done

msg "Pod running.  Doing ls -lR /mnt"
oc rsh testpod ls -lR /mnt
