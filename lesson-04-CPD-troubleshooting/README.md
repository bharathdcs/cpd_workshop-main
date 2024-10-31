

# OC and CPD - Routing

This section deals with diagnosing errors on OC/CPD.  In this section 

- learn how a request on a URL get routed to a pod.   
- can use oc logs / describe investigate the reason for failure.

## Revision

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


## Outline

- Simulate HTML status code 500 using app.py
- Debug URL https://cpdurl/api/v1/usermgmt/v1/user/currentUserInfo
- Trace the route of openshift console
- Trace the route of CPD console
- Load balancing


## error.sh and HAR files

Simulate a status code 500 by /api/simerror and using oc logs to debug.  Open browser and become familiar with inspect -> network.

Export the error by exporting the HAR file.

## debugging a GET url 

E.g. https://sandy-cpd-sandy.apps.kay.cp.fyre.ibm.com/api/v1/usermgmt/v1/user/currentUserInfo

Route = sandy-cpd-sandy.apps.kay.cp.fyre.ibm.com
Path = /api/v1/usermgmt/v1/user/currentUserInfo

Objective is to determine which pod handle this path.

On CPD instance https://sandy-cpd-sandy.apps.kay.cp.fyre.ibm.com

- open inspect -> network on brower 
- login to CPD


> oc get route | grep -E "sandy|NAME"

```
NAME        HOST/PORT                                     PATH   SERVICES        PORT                   TERMINATION
sandy-cpd   sandy-cpd-sandy.apps.kay.cp.fyre.ibm.com             ibm-nginx-svc   ibm-nginx-https-port   passthrough/Redirect
```

This GET is handled by the service 'ibm-nginx-svc'.

> oc get svc | grep -E "nginx|NAME"

```
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                AGE
ibm-nginx-svc         ClusterIP   172.30.17.101    <none>        443/TCP                26d
```

> oc get deployment | grep -E "nginx|NAME"

```
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
ibm-nginx     2/2     2            2           26d
```

This deployment ibm-nginx with the service ibm-nginx-svc.


> oc get rs | grep -E "nginx|NAME"

```
NAME                   DESIRED   CURRENT   READY   AGE
ibm-nginx-65d76dd848   0         0         0       26d
ibm-nginx-9b9997db7    2         2         2       26d   <===== this
```

The replica set ensures that 2 pods are up and running.

> oc get pod | grep -E "nginx|NAME"

```
NAME                          READY   STATUS             RESTARTS   AGE
ibm-nginx-9b9997db7-gqvgn     1/1     Running            1          26d
ibm-nginx-9b9997db7-vmw58     1/1     Running            2          26d
```

One of these pods will handle the request.


## IBM-NGINX


Ibm-nginx is a router.  It is the main 'controller' for CPD request.  It will examine the path and route ( aka port forward ) the request to the various pods - such as WKC, DB2 , Watson Studio, etc.  
To achieve that , Ibm-nginx will have a map of paths vs service.

In this example, I will demonstrate how nginx resolve /api/v1/usermgmt/v1/user/currentUserInfo

To dump out the map 

> nginx=$(oc get pods -A | grep ibm-nginx | tail -1 | awk '{print $2}')
> 
> oc rsh $nginx nginx -T > filename

To find which service is handling /api/v1/usermgmt/v1/user/currentUserInfo

> grep -n location filename | grep api

```
260:                location /api/v1/usermgmt/v1/usermgmt/users {                     <==== does not match this , why ?
270:                location ~* /api/v1/usermgmt/v1/(.*) {	                          <==== possible match , requires knowledge of regular expressions
482:location ~ "^/analytics/notebooks/v2/api/(.*)" {
529:location ~* "/data/jupyter(2)?/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12}?)/api/shutdown" {
626:location = /icp4d-api/v1/authorize {
631:location ~* /icp4d-api/(.*) {
976:location /catalog/api/omrs {
993:location /data-api {
1200:location ~ ^/api/(?!(v.*)) {
1448:location /icp4data/api/v1/databases/ {
1488:location /api/v1/secrets {
1507:location /zen-api-wrapper/ {
1577:location ~* /zen-data/v3/service_instances/(.*)/api_key {
1584:location ~* /zen-data-ui/v3/service_instances/(.*)/api_key {
```


vi filename and examine line 270

```
 270                 location ~* /api/v1/usermgmt/v1/(.*) {
 271                         proxy_set_header Host $host;
 272                         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 273                         access_by_lua_file /nginx_data/checkjwt.lua;
 274                         rewrite ^ $request_uri;
 275                         rewrite ^/api/v1/usermgmt/v1/(.*) /v1/$1 break;
 276                         proxy_pass https://usermgmt-svc:3443$uri;     <====================  pass to usermgmt-svc:3443 - this is a service !!
 277                 }
```

So the request is passed to service usermgmt-svc port 3443.

> oc get svc -A | grep -E "usermgmt|NAME"

```
NAMESPACE     NAME             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
sandy         usermgmt-svc     ClusterIP      172.30.93.145    <none>        8080/TCP,3443/TCP   27d
```

Tracing down the deployment , replicaset , pod , eventually

> oc get pod -A | grep -E "usermgmt|NAME"

```
NAMESPACE                                          NAME                                                          READY   STATUS             RESTARTS   AGE
sandy                                              usermgmt-767b9d5c77-b8g94                                     1/1     Running            1          27d
sandy                                              usermgmt-767b9d5c77-dftzb                                     1/1     Running            1          27d
```

Assuming there are errors ,one can use oc logs / describe to find out more.