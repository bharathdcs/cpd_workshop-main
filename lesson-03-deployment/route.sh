
. ../common.sh


msg "--- creating route ibmroute using the service ibm-service ---"

cat <<EOF | oc apply -f -
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: ibmroute
  namespace: $PROJECT
spec:
  to:
    kind: Service
    name: ibm-service
  port:
    targetPort: ibm-https-port
  tls:
    termination: passthrough
    insecureEdgeTerminationPolicy: Redirect
EOF

sleep 3

route=$(oc get route --no-headers  | grep ibm | awk '{print $2}')
msg "--- curl -k https://$route ---"
curl -k https://$route

msg "--- curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$route/api ---"
curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$route/api

cat <<EOF

Notice that it is no longer curling via the caller pod.  This URL is now accessible externally.

EOF

oc get pods
pods=$(oc get pods | grep -E "qdeploy.*Running" | awk '{print $1}')

for pod in $pods
do
	msg "--- showing logs for pod $pod ---"
	oc logs $pod
	echo
	echo
done

