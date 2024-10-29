# Final Challenge - Extend CPD certificate to 10 years.

When CPD is installed - the certificate expires after 3 years.  The challenge is to replace CPD certificate with my own that last for 10 years. 

This challenge will exercise everything that has been covered in the workshop.  This is the typical CPD login URL : 

https://cpd-sandy.apps.iis.ocp.adl/zen/#/homepage

## How do I check the certificate from the server ?

### Get the public key

Since there is no port number and it is https, it has to be port 443.

> cpd=cpd-sandy.apps.iis.ocp.adl
> 
> echo | openssl s_client -showcerts -servername $cpd -connect :443

```
-----BEGIN CERTIFICATE-----
MIIEnzCCA4egAwIBAgIRAJopnmB1R7B5U/73kYIhjXUwDQYJKoZIhvcNAQELBQAw
gb0xCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEbMBkGA1UEBxMSU2lsaWNvbiBW
...
...
ofcLuZNF/ODkPHx453TMHlo2apsV09nITriXF+mxZn0zokA=
-----END CERTIFICATE-----
```

### Get the expiry date

> echo | openssl s_client -showcerts -servername $cpd -connect $X:443 | openssl x509 -inform pem -noout -text

```
    Validity
        Not Before: Apr 12 18:55:50 2022 GMT
        Not After : Apr 12 18:55:50 2025 GMT
```

## How do I know which certificate CPD is using ?

### Get route

Since this is accessible externally, it has to be a route.

> oc get route 

``` 
NAME   HOST/PORT                    PATH   SERVICES        PORT                   TERMINATION            WILDCARD
cpd    cpd-sandy.apps.iis.ocp.adl          ibm-nginx-svc   ibm-nginx-https-port   passthrough/Redirect   None
```

### Get service

The route is built on top of a service ibm-nginx-svc / port ibm-nginx-https-port.

> oc get svc ibm-nginx-svc -o yaml

```
metadata:
  labels:
    component: ibm-nginx  <== matches deployment label
...
spec:
  clusterIP: 136.32.244.161
  ports:
  - name: ibm-nginx-https-port
    port: 443
    protocol: TCP
    targetPort: 8443  <============  
```

This service uses ibm-nginx deployment.  The deployment is listening on port 8443 for SSL but is exposed as 443.

### Is it true that ibm-nginx is using port 8443 for SSL ?

Can only tell if we dump out the nginx map.  

> oc rsh ibm-nginx-6455cd9467-47pg5 nginx -T 

```
server {
        listen 8443 ssl default_server;   <=============================
        # listen 80; ## for easier diag , ruling out ssl problems
        server_name localhost;
        ...
        ssl_certificate /etc/nginx/config/ssl/cert.crt;
        ssl_certificate_key /etc/nginx/config/ssl/cert.key;
```

The nginx config specifies to listen on port 8443 for ssl and use the cert.crt and cert.key.

### Get the deployment

A service rides on a deployment.   The certificate ( aka secret )  is defined in a deployment.  

> oc get deployment ibm-nginx -o yaml

This is to try to find which secret ( which has the cert ) that ibm-nginx is using.

``` 
metadata:
  labels:
    component: ibm-nginx   <======= deployment label
...
volumes:
- name: user-home-mount
persistentVolumeClaim:
  claimName: user-home-pvc
- name: internal-nginx-svc-tls
secret:
  defaultMode: 420
  secretName: internal-tls
- name: default-ssl
secret:
  defaultMode: 420
  secretName: default-ssl
- name: external-tls-secret
secret:
  defaultMode: 420
  optional: true
  secretName: external-tls-secret
```

There are 4 'secrets' that could match the certificate.  Have to use OC console to check each one.   

Answer = default-ssl, which has 2 values : cert.crt and cert.key.

> oc get secret default-ssl -o jsonpath='{.data.cert\.crt}' | base64 -d

``` 
-----BEGIN CERTIFICATE-----
MIIEnzCCA4egAwIBAgIRAJopnmB1R7B5U/73kYIhjXUwDQYJKoZIhvcNAQELBQAw
gb0xCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEbMBkGA1UEBxMSU2lsaWNvbiBW
...
ofcLuZNF/ODkPHx453TMHlo2apsV09nITriXF+mxZn0zokA=
-----END CERTIFICATE-----
```

This last part 'mxZn0zokA=' matches the certificate provided by the server during the handshake, so this confirm that default-ssl is the secret I want to replace.

> oc get secret default-ssl -o jsonpath='{.data.cert\.key}' | base64 -d

```
-----BEGIN PRIVATE KEY-----
MIIJQQIBADANBgkqhkiG9w0BAQEFAASCCSswggknAgEAAoICAQDv1hHaQCbJLOJ7
HkVIqVhBAsnAzgxZGzQBAAMNv1yL2z+9G5/59ii8H1KYwwPjrEKbVBSrcG76KMdy
...
kIJtcxZVGDXwxQQhhJw5R1dqZgr4
-----END PRIVATE KEY-----
```

## How do I replace the default-ssl secret ?

### Generate a new certificate that has 10 years expiry 

``` 
echo "AU
New South Wales
St Leonard
IBM
CP4D
anyhostname
not-used" | openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 3650 -out domain.crt
```

This will generate 2 files : domain.crt ( certificate with public key ) , and domain.key ( private key ).

My domain.crt will replace secret / default-ssl / cert.crt.
My domain.key will replace secret / default-ssl / cert.key.

The easier way to do this is copy/paste via OCP console.  After which 

- delete both ibm-nginx pods.  they will restart and mount the correct secret
- wait until both nginx pods are 1/1 Running
- run then openssl to verify

> echo | openssl s_client -showcerts -servername $cpd -connect :443 | openssl x509 -inform pem -noout -text

``` 
depth=0 C = AU, ST = New South Wales, L = St Leonard, O = IBM, OU = CP4D, CN = anyhostname, emailAddress = not-used
    Validity
        Not Before: May 10 12:42:38 2022 GMT
        Not After : May  7 12:42:38 2032 GMT
```

The certificate expiry is now 10 years later !
