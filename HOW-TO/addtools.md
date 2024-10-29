
## Add ping , netstat and traceroute , and other tools to ibm-nginx

Current : oc rsh ibm-nginx 

```
sh-4.4$ netstat
sh: netstat: command not found

sh-4.4$ ping
sh: ping: command not found
```

Desired state : 

```
sh-4.4$ ping
Usage: ping [-aAbBdDfhLnOqrRUvV64] [-c count] [-i interval] [-I interface]
            [-m mark] [-M pmtudisc_option] [-l preload] [-p pattern] [-Q tos]
            [-s packetsize] [-S sndbuf] [-t ttl] [-T timestamp_option]

sh-4.4$ netstat -an | grep LISTEN
tcp        0      0 0.0.0.0:12080           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:12443           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:8443            0.0.0.0:*               LISTEN 
```

## Theory

Use the ibm-nginx image, and add in ping and netstat packages.

- save the ibm-nginx deployment :  oc get deployment ibm-nginx -o yaml > out

- get the image : icr.io/cpopen/cpfs/icp4data-nginx-repo@sha256:ddf46c600c11c231bc843cc4714473c544666cfd4309d895ccfc42ec551bb4c9

- scale down to 0

- create a Dockerfile 

- oc edit deployment ibm-nginx to use my image

- scale to 1 and test


### Sample Dockerfile to build new image


```

FROM icr.io/cpopen/cpfs/icp4data-nginx-repo@sha256:ddf46c600c11c231bc843cc4714473c544666cfd4309d895ccfc42ec551bb4c9

USER root

RUN dnf install iputils -y
RUN dnf install net-tools -y

```

> podman build -t mynginx .


Push image : mynginx to OC registry , my OCP id/pw = admin:passwd, and my project is sandy

```
img=mynginx

pw=$(oc whoami -t to get password)

HOST=$(oc get route default-route -n openshift-image-registry --template='{{.spec.host}}')

podman push --creds "admin:$pw" $img $HOST/sandy/$img --tls-verify=false
```


### Deploy using ibm-nginx using my  image

- oc edit deployment ibm-nginx , easier via OCP console
- internal=$(oc registry info --internal=true)

```
        image: image-registry.openshift-image-registry.svc:5000/sandy/mynginx
```


## Cleanup

Remove image from OCP console - Builds -> ImageStream
