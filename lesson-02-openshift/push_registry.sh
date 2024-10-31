
. ../common.sh

# If route not expose 
oc get route default-route -n openshift-image-registry
if [ $? -ne 0 ] ; then
	oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
fi

HOST=$(oc get route default-route -n openshift-image-registry --template='{{.spec.host}}')
export USERNAME=kubeadmin
export PASSWORD=$(oc whoami -t)

#--------------------------------------------------------------------------------
#
#	login to OC registry to ensure that it is usable
#
#--------------------------------------------------------------------------------
podman login -u $USERNAME -p $PASSWORD $HOST --tls-verify=false
if [ $? -ne 0 ] ; then
	echo podman login failed
	echo podman login -u $USERNAME -p $PASSWORD $HOST --tls-verify=false
	exit
fi
echo
msg "Login to $HOST using $USERNAME/$PASSWORD - successful. OC registry operational."


msg "-----  Pushing image dbkpyton to openshift registry $HOST/$PROJECT/dbkpython using podman push  ----------------------"
podman push --creds "$USERNAME:$PASSWORD" dbkpython $HOST/$PROJECT/dbkpython --tls-verify=false
[ $? -ne 0 ] && echo "Push to internal registry failed" && exit 1
