
. ../common.sh

oc delete route ibmroute

msg "--- creating route ibmroute using service ibm-service ---"

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
    targetPort: ibm-http-port
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
EOF

sleep 3

route=$(oc get route --no-headers  | awk '{print $2}')

msg "--- curl -k https://$route/ ---"
curl -k https://$route

msg "--- curl -k https://$route/api ---"
curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$route/api

msg "--- curl -k https://$route/simerror ---"
curl -k https://$route/simerror
