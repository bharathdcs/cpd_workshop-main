
### How to run a CPD pod as root

At the end of this exercise : oc rsh usermgmt-7f8b4cb8f6-gfmzl

From 

```
sh-4.4$ id
uid=1000630000(1000630000) gid=0(root) groups=0(root),1000630000
```

To

```
sh-4.4#
```

Using deployment usermgmt as example

- save the deployment yaml  : oc get deployment usermgmt -o yaml > usermgmt_save.yaml

- identify the service account used :  oc get deployment usermgmt -o yaml | grep -i serviceaccount => zen-norbac-sa

- remember and save this value

- create a service account : oc create sa mysa

- allow this SA to run as anyuid ( including 0 ) : oc adm policy add-scc-to-user anyuid -z mysa

- scale deployment down to 0

- amend YAML

```
      securityContext:
        capabilities:
          drop:
            - ALL
            - MKNOD
        runAsNonRoot: false   <==== change from true to false

      securityContext:
        fsGroupChangePolicy: OnRootMismatch
        runAsNonRoot: false   <=== change from true to false
        runAsUser: 0  <=== add this
      serviceAccount: mysa  <=== change from zen-norbac-sa to mysa
      serviceAccountName: mysa  <=== change from zen-norbac-sa to mysa

```

- scale deployment to 1 and test

## Revert

The reason we want to use a different SA is because there are other pods using zen-norbac-sa.  Changing this permission may cause other pods to fail if they restart.

Revert : 

- oc adm policy remove-scc-from-user anyuid -z mysq
- oc delete sa mysa
