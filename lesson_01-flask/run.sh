
. ../common.sh

clear

msg "---  install python Flask library ---"
set -x
pip3 install Flask
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

echo
echo
echo
ls -l
msg "--- public and prtive key created ---"

msg "--- Starting flask application  ---"
set -x
python3 app.py &
set +x

sleep 3


msg "--- curl -k https://127.0.0.1:7777/ ---"
curl -k https://127.0.0.1:7777

echo

msg "--- curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' https://127.0.0.1:7777/api ---"
curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' https://127.0.0.1:7777/api

echo 

msg "--- curl  -k https://127.0.0.1:7777/simerror ---"
curl  -k https://127.0.0.1:7777/simerror

# Kill the app.py process
kill %1
