
rm domain.crt  domain.key
podman stop anyname
podman rm anyname
podman rm `podman ps --noheading -a | awk '{print $1}'`
podman rmi qchpython
