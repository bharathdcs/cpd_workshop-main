
# Session 4 - Deployment - Objectives

This requires lesson 3 to be completed : service / routes / TLS cert created , and ibmpython image pushed to OC registry.

Session 3 deploy a single testpod to OC.  In this session we create a deployment that will ensure that 4 pods are running all the time.  Curl request will be balanced among the pods.

After this session, you will 

- by look at a pod name , you can identify then deployment and replica
- understand what you can 'delete' and what you cannot.
- understand how scaling works
- understand load balancing and resiliency


## deploy.sh

This creates the deploment qdeploy.  It specifies the following :

- use image ibmpython
- run 4 copies 

The deployment will create a replica set to manage the pods.

> oc get rs

```
NAME                 DESIRED   CURRENT   READY   AGE
qdeploy-675dcd49b7   4         4         4       81s
```

> oc get pods -o wide | grep -E "qdeploy|NAME"

```
NAME                       READY   STATUS    RESTARTS   AGE    IP              NODE                          NOMINATED NODE   READINESS GATES
qdeploy-675dcd49b7-cgdgr   1/1     Running   0          30s    10.254.23.181   worker1.kay.cp.fyre.ibm.com   <none>           <none>
qdeploy-675dcd49b7-kf8pl   1/1     Running   0          30s    10.254.14.102   worker2.kay.cp.fyre.ibm.com   <none>           <none>
qdeploy-675dcd49b7-m94qh   1/1     Running   0          30s    10.254.14.101   worker2.kay.cp.fyre.ibm.com   <none>           <none>
qdeploy-675dcd49b7-w9vll   1/1     Running   0          30s    10.254.23.182   worker1.kay.cp.fyre.ibm.com   <none>           <none>
```

Notice that the pod name now takes the name of the deployment / replicaset.

## Curl test with IP

Using the caller pod

> oc rsh caller curl -k https://10.254.14.101:7777

```
hello world
```

## service.sh Create a service ibm-service for this deployment ( replica set )

> oc rsh caller curl -k https://ibm-service

```
hello world
```

We get a response, it could be from any of the 3 pods.  To determine use oc logs <pod>

## route.sh : Create a route so this deployment can be access externally

> oc get route

```
NAME        HOST/PORT                                      PATH   SERVICES        PORT                   TERMINATION            WILDCARD
myroute     ibmroute-sandy.apps.raisers.cp.fyre.ibm.com           ibm-service     ibm-https-port         passthrough/Redirect   None
```

> curl -k https://myroute-sandy.apps.raisers.cp.fyre.ibm.com
```
hello world
```

> curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://myroute-sandy.apps.raisers.cp.fyre.ibm.com/api
```
{"name":"john","now":"Fri, 25 Mar 2022 00:36:45 GMT"}
```

## scaling.sh : scale down to only 1 pod to simulate node/pod failure 

- oc edit deployment qdeploy and set spec.replicas to 1 
- oc get pod | grep qdeploy should show only 1 pod
- run the curl test and expected to be successful

## The most important lesson from this section is

```
      produces                creates                    expose as           expose externally as 

        |                       |                           |                   |
        V                       V                           V                   V

pods  <<======   replica set  <<=========  deployment    ======>  service    =========>  route

pods  <<======   replica set  <<=========  deployment    ======>  service    =========>  route

pods  <<======   replica set  <<=========  deployment    ======>  service    =========>  route

pods  <<======   replica set  <<=========  deployment    ======>  service    =========>  route

pods  <<======   replica set  <<=========  deployment    ======>  service    =========>  route

pods  <<======   replica set  <<=========  deployment    ======>  service    =========>  route

```
