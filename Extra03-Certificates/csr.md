```
#!/bin/bash


# This script is about certificate signing request.  Here's the login flow
#
# Create a certificate CA .  This CA has a private key myCA.key and a public key in pem format myCA.pem
#
# A client does the following :
#   create a private key tls.key
#   create a certificate signing request to the CA using the private key
#   the CA signs the request and gives back the public key tls.crt
#   the tls.key and tls.crt is used by the https protocol
#

passphrase=abc123

function info {
    msg=$1

    echo
    echo -n $msg
    echo " : Hit <ENTER> to continue"
    read ans
}

info "Create private key for CA"
[ -f myCA.key ] && rm myCA.key
openssl genrsa -des3 -passout pass:$passphrase -out myCA.key 2048
cat myCA.key


info "Create public cert for CA which last for 10 years"
[ -f myCA.pem ] && rm myCA.pem
openssl req -x509 -passin pass:$passphrase -new -nodes -key myCA.key -sha256 -days 3650 -out myCA.pem -subj "/C=AU/ST=NSW/L=IBM/O=Ex0280/OU=IT/CN=superman.com"
cat myCA.pem


info "cert client creates a private key"
openssl genrsa -out tls.key 2048
cat tls.key

info "cert client creates a signing request call tls.csr.  this cert will be used by route https://api.br.ocp.adl"
openssl req -new -key tls.key -out  tls.csr -subj "/C=AU/ST=NSW/L=IBM/O=Ex0280/OU=IT/CN=api.br.ocp.adl"
cat tls.csr

info "CA signs the cert and gives the public certification which last for 1 year"
openssl x509 -req -in tls.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -days 365 -sha256 -passin pass:$passphrase -out tls.crt
cat tls.crt


echo "tls.key and tls.crt will be used by the https"

exit
```
