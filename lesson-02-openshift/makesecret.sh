

. ../common.sh

msg "---- creating secret dbkcert using the certificates in domain.key and domain.crt ----" 

oc create secret tls dbkcert --cert=domain.crt --key=domain.key -n $PROJECT

sleep 5

oc get secret dbkcert -o yaml
