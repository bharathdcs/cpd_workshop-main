
. ../common.sh

oc delete service ibm-service 

msg "-----  create a service ibm-service to expose the port 7777  -------------------"

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
      name : ibm-http-port
      port: 7777
      targetPort: 7777
EOF

svc="ibm-service:7777"
msg "--- oc rsh caller curl -k http://$svc ---"

oc rsh caller curl -k http://$svc

msg "--- oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k http://$svc/api ---"
oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k http://$svc/api

