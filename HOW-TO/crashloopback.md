
# How to debug a pod in crash loop back.

Problem :  If the pod is in crash loop back, it is not possible to get oc logs , or describe, since the pod does not stay alive for long.

The key is to have the pod stay alive, so one can rsh into the pod, examine the files , mount points, and manually run the start up script if any.

Taking c-db2oltp-1673922449505338-etcd-0 as an example.  This is a statefulset.  

- scale down to 0
- change the stateful set YAML as below
- scale up to 1
- start debugging

Before yaml
```
      - command:
        - /scripts/start.sh
        env:
```

After yaml
```
      - command: [ "/bin/sh", "-c", "sleep 30000000" ]
        env:
```

The pod container will start as 0/1.  At this point, rsh and debug why it is failing.

###### Hint : member_id

Rename - /persistence/etcd/c-db2oltp-1673922449505338-etcd-0/member_id
