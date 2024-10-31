
cleanup.sh

. ../common.sh

clear

msg "---  Building Python / Flask image and tagging it as dbkpython --------"
podman build -t dbkpython .

msg "--- Checking podman images after the build ---"
podman images

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
