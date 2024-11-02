
. ../common.sh

# delete the pod if it exist
oc delete pod testpod

msg "--- Deploying image ibmpython to openshift ---"

#
#	The image is push to namespace openshift-marketplace.  The pod must be also in the same name space.
#	Otherwise additional config is required to allow a pod in ns1 to access image in ns2.
#
cat <<EOF | oc apply -f -

kind: Pod
apiVersion: v1
metadata:
  name : testpod
  namespace: $PROJECT
  labels:
    app: testpod
spec:
  containers:
    - name: cont1
      image : ibmpython
EOF

sleep 10

oc get pod testpod 

oc logs testpod

oc describe pod testpod
