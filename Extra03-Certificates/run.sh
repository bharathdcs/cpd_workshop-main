#/usr/bin/bash

. ../common.sh



msg "==> Generating a public / private key using openssl.   This will create file domain.crt ( public ) and domain.key ( private )"


HOST=hostname

echo "AU
New South Wales
St Leonard
IBM
CP4D
$HOST
not-used" | openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 3650 -out domain.crt

msg "==> Showing first 3 lines and last 3 lines of public key aka certificate"

head -3 domain.crt
echo ; echo 
tail -3 domain.crt


msg "==> Going to display the cert using the file domain.crt"

openssl x509 -in domain.crt -noout -text


msg "==> Going to display cert when talking to www.google.com:443"

echo | openssl s_client -showcerts -servername www.google.com -connect www.google.com:443 2>/dev/null | openssl x509 -inform pem -noout -text


oc project sandy


msg "===>  Getting service usrmgmt to demo secure is on port 3443"

oc get service -A | grep -E "NAME|user"

msg "==> Getting deployment for usermgmt, note the volume and secret"

oc get deployment usermgmt -o yaml | tail -40

msg "===> Getting secret internal-tls.  Open console and view secret internal-tls"

pod=caller

msg "===> Running curl to service usermgmt-svc:3443 via pod $pod to see the 'handshake'"

oc rsh $pod curl -k -vvv https://usermgmt-svc:3443

msg "===> Running openssl to service usermgmt-svc:3443 via pod $pod to see the certificate in the handsake.  Note the last few bytes of the certificate."

echo | oc rsh $pod openssl s_client -showcerts -servername usermgmt-svc -connect usermgmt-svc:3443 


exit
