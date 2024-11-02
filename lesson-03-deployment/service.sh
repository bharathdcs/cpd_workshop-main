

. ../common.sh

msg "-----  create a service ibm-service to expose it as port 443 instead of raw port 7777  -------------------"

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: ibm-service
  namespace : $PROJECT
spec:
  selector:
    app: testpod
  ports:
    - protocol: TCP
      name : ibm-https-port
      port: 443
      targetPort: 7777
EOF

svc="ibm-service"

msg "--- oc rsh curl -k https://$svc ---"
oc rsh caller curl -k https://$svc

msg "-- oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$svc/api"
oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$svc/api
