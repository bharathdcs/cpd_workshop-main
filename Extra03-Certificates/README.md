
# Certificates - disclaimer - as I understand it

CPD uses self-sign keys all over the place.  So an understanding of certificate is useful for CPD diagnosis.

# Keys - Symmetric and Asymmetric

- Asymmetric encryption -   encrypt with key1 ( aka public key ) , decrypt with key2 ( aka private key )
- Symmetric encryption - encrypt and decrypt using same key

# Handshake - secure

 Client | Man in middle | Server                                              | Encryption 
--- |--- |-----------------------------------------------------| --- 
 Hello |               | 
|  |               | Let 's talk securely.  Here is my cert / public key 
Check who signed cert. if CA continue , otherwise prompt | |                                                     |
 encrypt key ABCD1234 using public key | sniff1        | 
|  |               | decrypt using private key and get ABCD1234          | asymetric
|  |               | OK, let's use key ABCD1234                          | symmetric - ABCD1234
Lunch at 1 pm | sniff2        | where ?                                             | symmetric - ABCD1234
Cafeteria at level 1 | sniff2 |                                                     | symmetric - ABCD1234


- sniff1 - sees the encrypted exchange of keys but cannot dicpher it since he does not have the private key
- sniff2 - sees encrypted message but does not have the symmetric key

# How does a public / private key look like ?

Public 

```
-----BEGIN CERTIFICATE-----
MIIGATCCA+mgAwIBAgIUCxtCEwHh0m0qn7Iy/NhR+zPFJhMwDQYJKoZIhvcNAQEL
...
lBMa/16lQ2mohUgCfTvDh/OPAQTyYVfGmkAbjnAdGDhBsi5ruSYI6ElnqR2Hhyy9
LAl4JfQ=
-----END CERTIFICATE-----
```

Private

```
-----BEGIN PRIVATE KEY-----
MIIJRAIBADANBgkqhkiG9w0BAQEFAASCCS4wggkqAgEAAoICAQDg5aBzjMRHK3ms
...
IBxjfgs+aMKyQofGvt9V5PvDMVSrfgXR
-----END PRIVATE KEY-----
```

# What is a certificate ?

A certificate = public + information about certifying authority.

```commandline
In cryptography, a certificate authority or certification authority (CA) is an entity that stores, signs, and issues digital certificates. A digital certificate certifies the ownership of a public key by the named subject of the certificate. 
This allows others (relying parties) to rely upon signatures or on assertions made about the private key that corresponds to the certified public key. 
A CA acts as a trusted third partytrusted both by the subject (owner) of the certificate and by the party relying upon the certificate. The format of these certificates is specified by the X.509 or EMV standard.
```

In short, a CA site means 'someone' has authenticated the sitename/IP address and issue it with a public/private key.  Because 
it is 'chain' of certifying bodies, it becomes extremely hard to hack.  Has to renew yearly and cost $$.

There are free CA https://letsencrypt.org/ - but renew every 3 months.

# Dicpher a certificate

From a file x.cert

> openssl x509 -in x.cert -noout -text

Of interest is the following

```
 Issuer: C = AU, ST = New South Wales, L = St Leonard, O = IBM, OU = CP4D, CN = hostname, emailAddress = not-used
        Validity
            Not Before: May  9 00:57:05 2022 GMT
            Not After : May  6 00:57:05 2032 GMT
```
The issuer is not a CA ( certificate authority ) , hence traffic is encrypted, but deem insecure.

From a secure site, e.g. www.google.com

> echo | openssl s_client -showcerts -servername www.google.com -connect www.google.com:443 2>/dev/null | openssl x509 -inform pem -noout -text

Of interest is the following
```
Issuer: C = US, O = Google Trust Services LLC, CN = GTS CA 1C3
        Validity
            Not Before: Apr 18 09:47:36 2022 GMT
            Not After : Jul 11 09:47:35 2022 GMT
        Subject: CN = www.google.com
        CT Precertificate SCTs:
                Signed Certificate Timestamp:
                    Version   : v1 (0x0)
                    Log ID    : 46:A5:55:EB:75:FA:91:20:30:B5:A2:89:69:F4:F3:7D:
                                blah
                Signed Certificate Timestamp:
                    Version   : v1 (0x0)
                    Log ID    : 51:A3:B0:F5:FD:01:79:9C:56:6D:B8:37:78:8F:0C:A4:
                                blah
```

This certificate is issue by a chain of CA - hence encrypted and secure.

# Applying to CPD - service usermgmt-svc

Most CPD services offer http and https.  Applying the concepts above to the service usermgmt-svc

> oc get service -A | grep -E "NAME|user"

```
NAMESPACE   NAME            TYPE         CLUSTER-IP       EXTERNAL-IP  PORT(S)             AGE
sandy       usermgmt-svc    ClusterIP    172.30.119.122   <none>       8080/TCP,3443/TCP   12d
```

http at port 8080 , and https at port 3443.

## What is the certificate use by this service ?

> oc get deployment usermgmt -o yaml

```
    volumes:
      - name: internal-tls
        secret:
          defaultMode: 420
          secretName: internal-tls   <=== ?
      - name: metastore-secret
        secret:
          defaultMode: 420
          secretName: metastore-secret  <=== ?
```

> oc get secret internal-tls -o yaml -

```
data:
  certificate.pem: LS0tLS1CR... 
  private.pem: LS0tLS1C...
  public.pem: LS0tLS1CR...
  tls.crt: LS0tLS1C...
  tls.key: Ci0tLS0tQkVH...
```

You won't know , only the person who develop this services knows.  But you can find out ...

Not every pod has ssl.

> oc rsh caller

## To see the 'handshake' process.

> curl -vvv -k https://usermgmt-svc:3443

```
* Rebuilt URL to: https://usermgmt-svc:3443/
*   Trying 172.30.119.122...
* TCP_NODELAY set
* Connected to usermgmt-svc (172.30.119.122) port 3443 (#0)
...
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
...
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server accepted to use http/1.1
* Server certificate:
*  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
```
If no -k, the comm will abort.

## To see the certificate presented by the service at start of conversation.

> openssl s_client -showcerts -servername usermgmt-svc -connect usermgmt-svc:3443  

```
-----BEGIN CERTIFICATE-----
MIIDzzCCAregAwIBAgIRAMs/d/FZICQsN++ioNjXRlYwDQYJKoZIhvcNAQELBQAw
....
sQMHhnwaH9rUP+7ZGqvaFfWCJQ==
-----END CERTIFICATE-----
```
To get more information about the certificate such as expiry date.

> openssl s_client -showcerts -servername usermgmt-svc -connect usermgmt-svc:3443  | openssl x509 -inform pem -noout -text

```
        Issuer: CN = zen-ca
        Validity
            Not Before: Apr 26 03:05:00 2022 GMT
            Not After : Apr  2 03:05:00 2122 GMT
```
Use console and navigate to Secrets -> internal-tls and reveal the value.  The tls.crt is the public key.

