. ../common.sh

msg "--- creating new project test-ingress ---"
echo
oc new-project test-ingress

oc label namespace test-ingress app=test-ingress

msg "--- Deploy application in test-ingress project ---"
cat <<EOF | oc create -f -
kind: Pod
apiVersion: v1
metadata:
  name: caller 
  namespace: test-ingress
spec:
  containers:
    - name: cont1
      image : quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "while true; do sleep 30; done;" ]
EOF

msg "--- Wait for application to be in running state ---"
echo 
while :
do
  oc get pod -n test-ingress
	oc get pod caller -n test-ingress| grep -E "caller.*Running" > /dev/null 2>&1
	if [ $? -eq 0 ] ; then
		break 
	fi
	sleep 10
done

svc="ibm-service.workshop.svc.cluster.local:7777"

oc project test-ingress

msg " Try connecting to application running in workshop project"
echo 
oc rsh caller curl -k http://$svc
echo

oc logs caller -n test-ingress
