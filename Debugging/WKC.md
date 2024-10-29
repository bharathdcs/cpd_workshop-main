

# making WKC consume less resources

> oc edit statefulset c-db2oltp-iis-db2u | c-db2oltp-wkc-db2u

spec.template.spec.containers[0].resources  - set the CPU to 1 and memory to 6Gi for limits and request.  anything lower , DB2WH may fail to start.

ensure not amending initContainers.

```markdown
        resources:
          limits:
            cpu: "4"
            ephemeral-storage: 4Gi
            memory: 12Gi
          requests:
            cpu: "4"
            ephemeral-storage
```

reduce limits/cpu and request/cpu from 4 to 1.  
reduce limits/memory and request/memory from 12Gi to 8Gi

# When DB2 instance is up and running

```markdown
c-db2oltp-iis-db2u-0                                      1/1     Running     0          90s
c-db2oltp-iis-instdb-x67vx                                0/1     Completed   0          18h
c-db2oltp-wkc-db2u-0                                      1/1     Running     0          18h
c-db2oltp-wkc-instdb-l4bfl                                0/1     Completed   0          18h
```

# start / stop - oc rsh c-db2oltp-iis-db2u-0 , bash

This is NOT DPF.

> db2start db2stop 

# hostname resolution - oc rsh c-db2u-dv-db2u-0 , su - db2inst1

> cat /etc/resolv.conf
```markdown
search sandy.svc.cluster.local svc.cluster.local cluster.local np.ocp.adl
nameserver 136.32.0.10
options ndots:2
```

> cat sqllib/db2nodes.cfg

single node

```markdown
0 c-db2oltp-iis-db2u-0.c-db2oltp-iis-db2u-internal 0 c-db2oltp-iis-db2u-0.c-db2oltp-iis-db2u-internal
```

> nslookup c-db2oltp-iis-db2u-0.c-db2oltp-iis-db2u-internal

```markdown
Server:         136.32.0.10
Address:        136.32.0.10#53

Name:   c-db2oltp-iis-db2u-0.c-db2oltp-iis-db2u-internal.sandy.svc.cluster.local
Address: 121.157.2.226
```

> oc get svc -A | grep 136.32.0.10
```markdown
NAMESPACE       NAME          TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S) 
openshift-dns   dns-default   ClusterIP      136.32.0.10      <none>        53/UDP,53/TCP,9154/TCP

```


# certificate expiry

Do this after netstat -an shows that port 50001 is  listening but connectivity from other services like WKC still fails.

[Updating the Db2 SSL certificate after the Cloud Pak for Data self-signed certificate is updated](https://www.ibm.com/support/pages/node/6501339)

> gsk8capicmd_64 -cert -details -file /mnt/blumeta0/db2/ssl_keystore/bludb_ssl.kdb -stashed

```markdown
...
Issuer : CN=zen-ca-certificate
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


