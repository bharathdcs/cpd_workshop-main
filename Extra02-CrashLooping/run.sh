#!/bin/bash

. ../common.sh


function completed {

	msg "create a pod that will become Completed"
	cat <<EOF | oc apply -f -
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
EOF

	# Watch and exit when containter exit
	while :
	do
		oc get pod testpod-complete
		oc get pod testpod-complete | grep -E "testpod.*Complete" > /dev/null
		[ $? -eq 0 ] && break
		sleep 5
	done
}
	
completed ; exit ;

function running {

	msg "create a pod in running state = sleep forever"
	cat <<EOF | oc apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: testpod-run
spec:
  containers:
    - name: cont1
      image : quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "while true; do sleep 30; done;" ]
EOF

	# Watch and exit when containter is running
	while :
	do
		oc get pod testpod-run
		oc get pod testpod-run | grep -E "testpod.*Running" > /dev/null 
		[ $? -eq 0 ] && break
		sleep 5
	done
}

function crashloopback {

	msg "create a pod that will crashloopback"
	cat <<EOF | oc apply -f -
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
EOF

	# Watch and exit when containter exit
	while :
	do
		oc get pod testpod-crash
		oc get pod testpod-crash | grep -E "testpod.*Crash" > /dev/null
		[ $? -eq 0 ] && break
		sleep 5
	done
}


running
completed
crashloopback

msg "oc get pod | grep testpod"
oc get pod | grep testpod

echo
oc delete pod testpod-run testpod-complete testpod-crash
