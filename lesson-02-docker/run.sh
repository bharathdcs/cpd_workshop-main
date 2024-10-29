
. ../common.sh

. ./cleanup.sh
clear

msg "---  Building Python / Flask image and tagging it as qchpython --------"
set -x
podman build -t qchpython .
set +x

msg "--- Checking podman images after the build ---"
set -x
podman images
set +x

msg "--- Generate certificate and private key for https ---"
HOST=$(hostname)
echo "AU
New South Wales
St Leonard
IBM
CP4D
$HOST
not-used" | openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 3650 -out domain.crt


msg "--- Starting image qchpython and run the app ---"
set -x
podman run --rm --name anyname qchpython python3 app.py 
set +x


msg "--- Starting image qchpython and run the app sharing the certs with the /src folder ---"
set -x
podman run --rm -d --name anyname -v .:/src:Z qchpython python3 app.py
set +x

sleep 3
podman logs anyname
echo


echo -n "ENTER the url : " ; read url

msg "--- curl -k $url ---"
curl -k $url

echo

msg "--- curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' $url/api ---"
curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' $url/api

echo 

msg "--- curl  -k $url/simerror ---"
curl  -k $url/simerror

