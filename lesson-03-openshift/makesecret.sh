

. ../common.sh

msg "---- creating secret qchcert using the certificates in domain.key and domain.crt ----" 

oc create secret tls qchcert --cert=domain.crt --key=domain.key -n $PROJECT

sleep 5

oc get secret qchcert -o yaml
