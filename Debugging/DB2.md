

# making DB2 consume less resources

> oc edit statefulset c-db2wh-1663219591423829-db2u

spec.template.spec.containers[0].resources  - set the CPU to 1 and memory to 6Gi for limits and request.  anything lower , DB2WH may fail to start.

ensure not amending initContainers.

```markdown
        resources:
          limits:
            cpu: "1"
            memory: 6Gi
          requests:
            cpu: "1"
            memory: 6Gi
```

# When DB2WH instance is up and running

```markdown
sandy                                              c-db2wh-1663219591423829-db2u-0                                   1/1     Running             0          11m
sandy                                              c-db2wh-1663219591423829-etcd-0                                   1/1     Running             0          11m
sandy                                              c-db2wh-1663219591423829-instdb-5fxw2                             0/1     Completed           0          11m
sandy                                              c-db2wh-1663219591423829-restore-morph-h2vtw                      0/1     Completed           0          7m50s
```

# start / stop - oc rsh c-db2wh-1663219591423829-db2u-0 , su - db2inst1

This is NOT DPF.

> db2start db2stop 

# hostname resolution - oc rsh c-db2u-dv-db2u-0 , su - db2inst1

> cat /etc/resolv.conf
```markdown
search sandy.svc.cluster.local svc.cluster.local cluster.local br.ocp.adl
nameserver 136.32.0.10
options ndots:2
```

> cat sqllib/db2nodes.cfg

single node

```markdown
0 c-db2wh-1663219591423829-db2u-0.c-db2wh-1663219591423829-db2u-internal 0
```

> nslookup c-db2wh-1663219591423829-db2u-0.c-db2wh-1663219591423829-db2u-internal

```markdown
Server:         136.32.0.10
Address:        136.32.0.10#53

Name:   c-db2wh-1663219591423829-db2u-0.c-db2wh-1663219591423829-db2u-internal.sandy.svc.cluster.local
Address: 121.159.0.57
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

# patch DV to use less resources

