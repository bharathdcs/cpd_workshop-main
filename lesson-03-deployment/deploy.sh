
. ../common.sh

cleanup.sh


export internal=$(oc registry info --internal=true)

msg "--- creating deployment qdeploy ---"

cat <<EOF | oc create -f -
kind: Deployment
apiVersion: apps/v1
metadata:
  name: qdeploy
spec:
  replicas: 4
  selector:
    matchLabels:
      app: testpod
  template :
    metadata:
      labels:
        app: testpod
    spec:
      containers:
      - name: cont1
        image : $internal/$PROJECT/dbkpython
        volumeMounts:
          - name: tls
            mountPath: /mnt
      volumes:
        - name: tls
          secret:
            secretName: dbkcert
EOF

while :
do
	oc get pod -o wide | grep -E "NAME|qdeploy"
	echo
	cnt=$(oc get pod -o wide | grep qdeploy | grep Running | wc -l)
	if [ $cnt -eq 4 ] ; then
		break
	fi
	sleep 10
done

echo
oc get pod -o wide | grep -E "NAME|qdeploy" | grep -E "NAME|Running"

echo -n "Enter any of the 4 IP address : " ; read ip

echo Doing oc rsh caller curl -k https://$ip:7777
oc rsh caller curl -k https://$ip:7777
echo

echo -n "Try with another IP address : " ; read ip

echo Doing oc rsh caller curl -k https://$ip:7777
oc rsh caller curl -k https://$ip:7777
echo

while :
do
	echo
	oc get pod -o wide | grep -E "NAME|qdeploy" | grep -E "NAME|Running"
	
	echo -n "Enter a podnam to see logs , or ctrl-c to quit : " ; read podname

	echo
	oc logs $podname
	echo
done
