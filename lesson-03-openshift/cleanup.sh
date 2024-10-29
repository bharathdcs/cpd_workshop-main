
[ -f domain.crt ] && rm domain.crt
[ -f domain.key ] && rm domain.key

podman stop anyname
podman rm anyname
podman rm `podman ps --noheading -a | awk '{print $1}'`
podman rmi qchpython
oc delete pod testpod
oc delete secret qchcert
oc delete service qch-service
