
. ../common.sh

# delete the pod if it exist
oc delete pod testpod

#export internal=$(oc registry info --internal=true)

#msg "--- Deploying image ibmpython to openshift internal registry at $internal/$PROJECT/ibmpython ---"

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
      image : quay.io/bkdevara/ibmpython
EOF

sleep 10

oc get pod testpod 


oc logs testpod

oc describe pod testpod
