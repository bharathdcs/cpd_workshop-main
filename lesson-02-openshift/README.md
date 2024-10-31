
# Requirement 

- Openshift cluster on fyre

# Objectives 

Deploy application docker image to Openshift.  This session demonstrates the following :

- use the image dbkpython created in lesson 2 and deploy to openshift
- create a testpod using this image
- curl test on '/' , '/api' , '/simerror'


## build.sh :  build image and create testpod

- Dockerfile  - build image dbkpython and generate certificates/pte key


## deploy_pod_01.sh : delete and recreate the testpod.


Creates a testpod using this image dbkpython. The create testpod will fail with ImagePullErr.

This is expected because it does not know how to get the dbkpython.  The image is in podman registry.  But it is *not* in openshift registry.

To be able to create testpod , need to take the image from podman , and push it to openshift registry ( e.g of a registry ,  https://hub.docker.com/ )


## push_registry.sh : push dbkpython to OC registry

OC comes with an internal registry which is not expose by default.  This script expose the registry if it is not already expose,  and attempt to login for sanity check.

Expected output of a successful push 

```
Getting image source signatures
Copying blob a9dd45901971 skipped: already exists
Copying blob c0d5762f96ad skipped: already exists
Copying blob d6cf9dabd86a skipped: already exists
Copying blob 8a4215d1cceb skipped: already exists
Copying blob ff768a1413ba skipped: already exists
Copying blob fef170950a52 done
Copying blob 211bb091b6bb done
Copying blob d468f1a40976 done
Copying blob 5db50b4f8273 done
Copying config 70313846b6 done
Writing manifest to image destination
Storing signatures
```

## deploy_pod_02.sh : delete and recreate the testpod.

Notice the image path , it is associated with a project :  image-registry.openshift-image-registry.svc:5000/sandy/dbkpython

> oc get pod testpod

```
NAME      READY   STATUS   RESTARTS   AGE
testpod   0/1     Error    3          62s
```

The image can be downloaded but starting the pod gets error.   Error occurs when the image can load, but fail to start up.  Crashloopback occurs when the pod starts up but exit with non-0 status.

> oc logs testpod

```
ceback (most recent call last):
  File "app.py", line 18, in <module>
    app.run ( "0.0.0.0" , 7777 , ssl_context=('/mnt/tls.crt', '/mnt/tls.key') )
  File "/usr/local/lib/python3.8/site-packages/flask/app.py", line 920, in run
    run_simple(t.cast(str, host), port, self, **options)
  File "/usr/local/lib/python3.8/site-packages/werkzeug/serving.py", line 1017, in run_simple
    inner()
	....
FileNotFoundError: [Errno 2] No such file or directory
```

It is complaining that it cannot find the certificates in '/mnt/tls.crt', '/mnt/tls.key'.  Will need to create a secret using the certs in step1 , and then mounted it to /mnt on the pod.

## makesecret.sh : make secret dbkcert using the file domain.crt  domain.key

It is possible to embed / copy the certificat files into the image using specifying it in the Dockerfile.  This would require image rebuild when cert renew.  Hence need to externalised the cert from the image.  This is done by creating a 'secret' using the certificates, and advise the pod to use this secret.

What else can one externalise ?

- secret : tsl certificates ,  literal key/value pairs  , file containing key/value pairs
- configmap :  e.g. tomcat / mysql has config file such mysql.cnf , server.xml create a config map of these files, and specify in the yaml

Environment variables can be specified directly in YAML , so there is no need to externalise them.

## deploy_pod_03.sh : delete and create testpod again, but this time mount the secret to /mnt

Expected to be successful now since OC knows where to pull the image , and where to get the TLS certs.

## Test using curl with IP address

The pod now exists within the openshift cluster and has an IP address.   This IP is only valid *inside* the cluster.  Any pod inside this cluster should be able to curl it.

For this example, use the 'caller' pod.

> oc rsh caller curl -k https://10.254.22.17:7777

```
hello world
```

> oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }'  -k https://10.254.22.17:7777/api

```
{"name":"john","now":"Thu, 24 Mar 2022 12:23:54 GMT"}
```

Even though the hostname for the testpod is the podname , https://testpod:7777 does not work.  For that, it would need to create a service.

## Test using curl with service name - service.sh

Most services are accessed via service names instead of IP address.  To make that association , run the service.sh to create dbk-service against this testpod.

> oc rsh caller curl -k https://dbk-service

```
hello world
```

> oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }'  -k https://dbk-service/api

```
{"name":"john","now":"Thu, 24 Mar 2022 12:23:54 GMT"}
```

Notice that the port number 7777 is no longer used.  The service has map 7777 to default https port 443.  The testpod is still accessible only from within the cluster.

## Test using curl with route - route.sh

This step expose the testpod to be accessible outside of the cluster.  In this case, it creates a route myroute associated with the service dbk-service.


>  oc get route

```
NAME        HOST/PORT                                      PATH   SERVICES        PORT                   TERMINATION            WILDCARD
myroute     myroute-sandy.apps.bearing.cp.fyre.ibm.com            dbk-service     dbk-https-port         passthrough/Redirect   None
```

> curl -k https://myroute-sandy.apps.bearing.cp.fyre.ibm.com
```
hello world
```

> curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://myroute-sandy.apps.bearing.cp.fyre.ibm.com

```
{"name":"john","now":"Thu, 24 Mar 2022 12:23:54 GMT"}
```

Note that I am no longer curling via the caller pod.  This curl can be done on any host that can resolve myroute-sandy.apps.bearing.cp.fyre.ibm.com.

