
. ../common.sh

oc delete route dbkroute

msg "--- creating route dbkroute using service dbk-service ---"

cat <<EOF | oc apply -f -
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: dbkroute
  namespace: $PROJECT
spec:
  to:
    kind: Service
    name: dbk-service
  port:
    targetPort: dbk-https-port
  tls:
    termination: passthrough
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
