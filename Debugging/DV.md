
# making DV consume less resources

> oc edit statefulset c-db2u-dv-db2u

spec.template.spec.containers[0].resources  - set the CPU to 2 and memory to 8Gi for limits and request

```markdown
        resources:
          limits:
            cpu: "2"
            memory: 4Gi
          requests:
            cpu: "2"
            memory: 4Gi
```

Too difficult to automate,  this is an attempt but failed

```markdown
oc get statefulset c-db2u-dv-db2u -o jsonpath='{.spec.template.spec.containers[0].name}'
oc get statefulset c-db2u-dv-db2u -o jsonpath='{.spec.template.spec.containers[0].resources}'
echo

# {"limits":{"cpu":"2","ephemeral-storage":"8Gi","memory":"8Gi"},"requests":{"cpu":"2","ephemeral-storage":"2Gi","memory":"8Gi"}}\

oc patch statefulset/c-db2u-dv-db2u --type=merge --patch '{ "spec" : { "template" : { "spec" : {  "containers" : [ { "name" : "db2u" , "resources" : { "limits" : { "cpu" : "2" , "memory" : "8Gi
" } } } ] } } } }'


```


# When DV instance is up and running

```markdown
sandy                                              c-db2u-dv-db2u-0                                                  1/1     Running     0          4h10m
sandy                                              c-db2u-dv-db2u-1                                                  1/1     Running     0          22h
sandy                                              c-db2u-dv-dvapi-5bc7546f94-mxkqd                                  1/1     Running     1          22h
sandy                                              c-db2u-dv-dvcaching-577c589cfb-w66qr                              1/1     Running     0          22h
sandy                                              c-db2u-dv-dvutils-0                                               1/1     Running     8          22h
sandy                                              c-db2u-dv-hurricane-dv-5b5975f4c-mdttz                            2/2     Running     0          22h
```

# start / stop

> bigsql start|stop 

# hostname resolution - oc rsh c-db2u-dv-db2u-0 , su - db2inst1

> cat /etc/resolv.conf
```markdown
search sandy.svc.cluster.local svc.cluster.local cluster.local br.ocp.adl
nameserver 136.32.0.10
options ndots:2
```

> cat sqllib/db2nodes.cfg

```markdown
0 c-db2u-dv-db2u-0.c-db2u-dv-db2u-internal 0 c-db2u-dv-db2u-0.c-db2u-dv-db2u-internal
1 c-db2u-dv-db2u-1.c-db2u-dv-db2u-internal 0 c-db2u-dv-db2u-1.c-db2u-dv-db2u-internal
```

> nslookup c-db2u-dv-db2u-0.c-db2u-dv-db2u-internal

```markdown
Server:         136.32.0.10
Address:        136.32.0.10#53

Name:   c-db2u-dv-db2u-0.c-db2u-dv-db2u-internal.sandy.svc.cluster.local
Address: 121.157.2.98
```

# certificate expiry

Do this after netstat -an shows that port 50001 is not listening.

[Updating the Db2 SSL certificate after the Cloud Pak for Data self-signed certificate is updated](https://www.ibm.com/support/pages/node/6501339)

> gsk8capicmd_64 -cert -details -file /mnt/blumeta0/db2/ssl_keystore/bludb_ssl.kdb -stashed

```markdown
...
Subject : CN=zen-ca-certificate
Not Before : July 17, 2022 12:34:56 AM GMT+00:00
Not After : July 16, 2025 12:39:56 AM GMT+00:00 
...
```

Follow instructions if expired.

# snapshot monitoring

```markdown
for i in DFT_MON_BUFPOOL DFT_MON_LOCK DFT_MON_SORT DFT_MON_STMT DFT_MON_TABLE DFT_MON_UOW DFT_MON_TIMESTAMP; do db2 update dbm cfg using $i ON; done
```

Any subsequent sessions will be monitored.  This is persistent.  Restarting pod will retain this DBM cfg setting.

# patch DV to use less resources

