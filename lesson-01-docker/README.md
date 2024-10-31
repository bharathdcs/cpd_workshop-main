
# Requirement 

- Redhat - yum install podman -y

# Docker image - Objectives

This session uses the same Python/Flask application from lession 01.  The web application will be deployed and run as a docker container.  Podman is another implemention of docker technology. 

- use Dockerfile to build a image ( think of it as VM iso with python and flask built in )
- copy the app.py into the image
- run this image in detach mode
- curl test on  '/' , '/api' , '/simerror'

## Dockerfile - used to build the image dbkpython

- the Dockerfile file 'inherit' a python image , and add the flask library
- create a /src folder, and set it as working folder
- copy program app.py to the /src folder.

After building 

```
REPOSITORY                TAG         IMAGE ID      CREATED        SIZE
localhost/dbkpython       latest      cfa3590a8f71  4 seconds ago  62.1 MB  * created image *
docker.io/library/python  3.8-alpine  b7514e346821  16 hours ago   49.9 MB  * base image * 
```

## Run image : 

> podman run --rm --name anyname dbkpython python3 app.py 

Fail with following image

```
 * Debugger PIN: 127-516-369
Exception in thread Thread-1:
Traceback (most recent call last):
  File "/usr/local/lib/python3.8/threading.py", line 932, in _bootstrap_inner
    self.run()
...
  File "/usr/local/lib/python3.8/site-packages/werkzeug/serving.py", line 602, in load_ssl_context
    ctx.load_cert_chain(cert_file, pkey_file)
FileNotFoundError: [Errno 2] No such file or directory
```

## Run image with certificate : 

> podman run --name anyname -v .:/src dbkpython python3 app.py

```
 * Running on all addresses.
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on https://10.88.0.46:7777/ (Press CTRL+C to quit)   <==============================
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 111-927-633
```

## Curl test

> curl -k https://10.88.0.46:7777/

```
hello world
```

> curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' https://10.88.0.46:7777/api

```
{
  "name": "john",
  "now": "Thu, 24 Mar 2022 11:10:39 GMT"
}
```

## Docker-compose.yaml - how a typical docker-compose.yaml would have looked like

```
version: '3.3'
services:

  cpd_flask :
    image: dbkpython
    container_name : anyname
    ports :
      - 7777:7777
    volumes:
    - .:/src
    command : python3.8 server.py
```

Run by using : docker-compose up -d

## IP addr resolution - optional

How does fyre machine know about address 10.88.0.46 ?   Podman creates a virtual network adapter on 10.88.0.1.  Podman will provide a IP to the running container.

> ip addr


```
4: cni-podman0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 3e:81:8d:d9:53:a8 brd ff:ff:ff:ff:ff:ff
    inet 10.88.0.1/16 brd 10.88.255.255 scope global cni-podman0
       valid_lft forever preferred_lft forever
```


## Downside

If the app.py changes , need to rebuild image since the file is 'built' into the image.
