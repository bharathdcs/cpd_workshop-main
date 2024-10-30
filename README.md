# cpd_workshop

yum install -y git
git config --global credential.helper 'cache --timeout=360000'

git clone https://github.ibm.com/bharathdcs/cpd_workshop.git


## Objective 

By the end of these sessions , you should be able to :

- sound like 'you know what you are doing' when customer ask for webex
- know what information to collect for errors
- understand the concepts of pod , replica set , deployment , service , route and how it is all related
- identify which pod you should focus on for error conditions

CPD certificate expires after 3 years.  The last challenge exercises all the concepts and replace it with my own 10-year expiry certificate.

## Outline 

- 01 - create a simple Python/Flask secure web application ( https ) with REST  endpoint
- 02 - containerise this web application using docker / podman
- 03 - deploy this application to openshift
- 04i - create an openshift deployment to demonstrate scaling , high availability
- 04ii - demo of openshift source to image ( S2I )
- 05 - Apply above understanding to diagnosing OC/CPD status code 500 ( internal server error ), e.g. trace how a URL request get fulfilled by a pod.

## Some terms

- Load balancing and HA Proxy = same meaning - take a request and forward to whoever is available
- Bastion node , Infra node - same thing - the node which runs the load balancer
- Control Plane - master nodes
- OC = OCP = Openshift , K8 = Kubernetes
- HTTPS = Port 443 , HTTP = Port 80

## Summary

CPD leverages on Openshift , which runs on K8 ( Kubernetes ), which runs on top of docker.  For all intent and purpose, CPD is just another 'application' to OC.  So is DB2 / WKC / DS.

Think of it this way :  In the OC cluster , you have many VMs ( aka pods ).  One of the VM is CPD.  The other VMs are DB2 / WKC / DS.  They are all part of same cluster and has connectivity.  
CPD provides a UI to all these other VMs via REST APIs.

## Benefits

- docker - containerised applications.  Think of it as VMs with software preconfigured.
- k8 - provides scalability , load balancing , self healing , security and pod management for docker images
- openshift - automate the process of application development with git / webhooks
- cpd - an application that sits on top of openshift as a single UI to manage all the IBM services ( DB2 , WKC , DS )

Using DB2 as an example ( over simplifying of course ) , think back to the days of 

- DB2 fault monitor - a process to watch DB2 engine and restart if it crash  ( crashloopback )
- HACMP ( High Availability ) - Duplicate env in same buiilding ready to take over if host crash ( multiple pods in a worker node )
- HADR ( Disaster Recovery ) - Duplicate host in another location ready to take over if primary location fails ( worker nodes are geographically dispersed )

All these come free with K8.  In K8 , cluster nodes can be designed to be geographically dispersed.
