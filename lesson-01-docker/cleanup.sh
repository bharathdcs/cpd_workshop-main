podman stop noname
podman rm noname
podman rm `podman ps --noheading -a | awk '{print $1}'`
podman rmi dbkpython
