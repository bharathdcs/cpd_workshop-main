
[ -f domain.crt ] && rm domain.crt
[ -f domain.key ] && rm domain.key

podman stop anyname
podman rm anyname
podman rm `podman ps --noheading -a | awk '{print $1}'`
podman rmi dbkpython
oc delete pod testpod
oc delete secret dbkcert
oc delete service dbk-service
