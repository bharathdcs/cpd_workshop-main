
#

- scale deployment usermgmt to 0
- mess up
- scale deployment usermgmt to 1
- debug /startup.sh



### setup up

oc adm policy add-scc-to-user anyuid -z zen-norbac-sa
oc adm policy remove-scc-from-user anyuid -z zen-norbac-sa
