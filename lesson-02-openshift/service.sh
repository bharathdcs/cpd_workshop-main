
. ../common.sh

oc delete service qch-service 

msg "-----  create a service qch-service to expose it as port 443 instead of raw port 7777  -------------------"

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: qch-service
  namespace : $PROJECT
spec:
  selector:
    app: testpod
  ports:
    - protocol: TCP
      name : qch-https-port
      port: 443
      targetPort: 7777
EOF

svc="qch-service"
msg "--- oc rsh caller curl -k https://$svc ---"

oc rsh caller curl -k https://$svc

msg "--- oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$svc/api ---"
oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$svc/api

