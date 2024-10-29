
function msg {
    msg=$1
    echo
    echo
    echo -n $msg
    echo "    , Hit <ENTER> to continue" ; read ans
}

PROJECT=workshop

#------------------------------------------------------------------------------------------------------------------------------------
#	Create a new project for this workshop if it does not exists
#------------------------------------------------------------------------------------------------------------------------------------
oc project | grep $PROJECT
if [ $? -eq 1 ] ; then
	oc new-project $PROJECT --display-name="$PROJECT" --description="$PROJECT"
fi

sleep 2
oc project $PROJECT > /dev/null 2>&1


#------------------------------------------------------------------------------------------------------------------------------------
#	Create a pod named caller if it does not exist.  It sleeps forever.  The purpose of this pod is to use it to use it for curling.
#------------------------------------------------------------------------------------------------------------------------------------
oc get pod caller > /dev/null 2>&1
if [ $? -ne 0 ] ; then
	cat <<EOF | oc apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: caller 
spec:
  containers:
    - name: cont1
      image : quay.io/openshift-release-dev/ocp-release@sha256:63545e67cc2af126e289de269ad59940e072af68f4f0cb9c37734f5374afeb60
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "while true; do sleep 30; done;" ]
EOF

fi

