
. ../common.sh

# delete the pod if it exist
oc delete pod testpod

export internal=$(oc registry info --internal=true)

msg "--- Deploying image qchpython to openshift internal registry at $internal/$PROJECT/qchpython ---"

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
      image : $internal/$PROJECT/qchpython
EOF

set -x
while :
do
	oc get pod testpod 
	sleep 10
done

oc logs testpod

oc describe pod testpod