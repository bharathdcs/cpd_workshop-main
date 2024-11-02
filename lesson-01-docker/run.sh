
. ../common.sh

. ./cleanup.sh
clear


msg "---  Building Python / Flask image and tagging it as ibmpython --------"
set -x
podman build -t ibmpython .
set +x

msg "--- Checking podman images after the build ---"
set -x
podman images
set +x


msg "--- Starting image ibmpython and run the app ---"
set -x
podman run -p 7777:7777 -d --name noname --rm ibmpython
set +x


sleep 3
podman logs noname
echo



msg "--- curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' http://localhost:7777/api ---"
curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' http://localhost:7777/api

echo 

msg "--- curl  -k http://localhost:7777/simerror ---"
curl  -k http://localhost:7777/simerror

