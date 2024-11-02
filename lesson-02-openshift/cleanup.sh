podman stop noname
podman rm noname
podman rm `podman ps --noheading -a | awk '{print $1}'`
podman rmi ibmpython
oc delete pod testpod
oc delete secret ibmcert
oc delete service ibm-service
