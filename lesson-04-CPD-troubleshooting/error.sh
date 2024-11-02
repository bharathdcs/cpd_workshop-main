
# This script simulates error 500 by calling /simerror.  The app.py tries to open a non existent file

. ../common.sh

route=$(oc get route | grep ibm-service | awk '{print $2}')


msg "--- curl -k https://$route/simerror ---"
curl -k https://$route/simerror

echo

msg "--- logs from the testpod ---"
oc logs testpod

cat <<EOF




open https://$route/simerror to diagnose error message.


Right click on inspector, and click on the Network tab.  This should show the url that is returning 500.

EOF

