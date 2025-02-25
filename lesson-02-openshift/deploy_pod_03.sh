
. ../common.sh

# delete the pod if it exist
oc delete pod testpod


export internal=$(oc registry info --internal=true)

msg "--- Deploying image ibmpython to openshift internal registry at $internal/$PROJECT/ibmpython ---"

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
      image : $internal/$PROJECT/ibmpython
EOF

while :
do
	oc get pod testpod 
	oc get pod testpod | grep -E "testpod.*Running" > /dev/null 2>&1
	if [ $? -eq 0 ] ; then
		break 
	fi
	sleep 10
done

msg "--- Display testpod logs ---"
clear
oc logs testpod

echo 
echo -n "Enter the url that is not 127.0.0.1 : " ; read url


msg "--- oc rsh caller curl -k $url ---"
oc rsh caller curl -k $url

echo

msg "--- oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' $url/api ---"
oc rsh caller curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' $url/api


msg "--- Describe testpod ---"
clear
oc describe pod testpod
