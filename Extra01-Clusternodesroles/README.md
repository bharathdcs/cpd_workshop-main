
# Bastion node, Master node.  Worker node.  How they are all related.

Take a URL for example

E.g. https://sandy-cpd-sandy.apps.kay.cp.fyre.ibm.com/api/v1/usermgmt/v1/user/currentUserInfo

The sandy-cpd-sandy.apps.kay.cp.fyre.ibm.com resolve to IP of the bastion node.

So how does this get executed ?

See http://bastion:9000 , it will show that all traffic going to ingress-https will be routed to worker0/worker1.

This can be demonstrated as follows :

On bastion

> netstat -an | grep 443 | grep LISTEN

```
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN
```

On a worker node

> ssh core@worker0.kay.cp.fyre.ibm.com netstat -an | grep 443 | grep LISTEN

```
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN
```

The bastion node 'port forward' any traffic on 443 to one of the workers listening on 443.

> less /etc/haproxy/haproxy.cfg

```
frontend ingress-https
        bind *:443
        default_backend ingress-https
        mode tcp
        option tcplog

backend ingress-https
        balance source
        mode tcp
        server master0 10.17.108.16:443 check
        server master1 10.17.112.107:443 check
        server master2 10.17.113.124:443 check
        server worker0 10.17.114.250:443 check
        server worker1 10.17.119.7:443 check
        server worker2 10.17.120.106:443 check
```

## Listener on port 443 at worker

> oc get route -A | grep -E "sandy|NAME"

```
NAMESPACE   NAME         HOST/PORT                                   PATH   SERVICES        PORT                   TERMINATION            WILDCARD
sandy       sandy-cpd    sandy-cpd-sandy.apps.kay.cp.fyre.ibm.com           ibm-nginx-svc   ibm-nginx-https-port   passthrough/Redirect   None
```

So from last session, the pod is ibm-nginx-X-Y,  and looking at the nginx map, it proxy pass to the URL

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

How does nginx know the IP address of usermgmt-svc ?

##  IP address of a service

> oc rsh ibm-nginx-578cff7d7b-vkk8k cat /etc/resolv.conf

```
search sandy.svc.cluster.local svc.cluster.local cluster.local cp.fyre.ibm.com kay.cp.fyre.ibm.com
nameserver 172.30.0.10   <=======   this is the name server.
options ndots:5
```

So who does this IP belong to ?

> oc get svc -A | grep -E "172.30.0.10|NAME"

```
NAMESPACE       NAME          TYPE           CLUSTER-IP       EXTERNAL-IP  PORT(S)                        AGE
openshift-dns   dns-default   ClusterIP      172.30.0.10      <none>       53/UDP,53/TCP,9154/TCP         56d
```

> oc rsh caller nslookup usermgmt-svc

```
Server:         172.30.0.10
Address:        172.30.0.10#53

Name:   usermgmt-svc.sandy.svc.cluster.local
Address: 172.30.119.122
```

Nginx will forward this uri to 172.30.119.122  to execute via the  usermgmt deployment.

## Create a caller pod.  All pods would be quite similar.  It has nslookup which nginx does not

```
kind: Pod
apiVersion: v1
metadata:
  name: caller 
spec:
  containers:
    - name: cont1
      image : quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "while true; do sleep 30; done;" ]
```

It has curl , openssl , nslookup.