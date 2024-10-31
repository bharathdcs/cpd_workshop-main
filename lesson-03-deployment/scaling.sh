
. ../common.sh

msg "--- This script will scale the deployment to 1 pod simulating all other nodes down ---"

oc patch deployments qdeploy -p '{"spec": {"replicas": 1 } }'

while :
do
	clear
	oc get pods -o wide 
	cnt=$(oc get pods | grep qdeploy | wc -l)
	if [ $cnt -eq 1 ] ; then
		break
	fi
	sleep 10
done


route=$(oc get route --no-headers  | awk '{print $2}')
msg "--- curl -k https://$route ---"
curl -k https://$route

msg "--- curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$route/api ---"
curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' -k https://$route/api
