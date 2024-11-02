
. ./cleanup.sh

. ../common.sh

clear

msg "---  Building Python / Flask image and tagging it as ibmpython --------"
podman build -t ibmpython .

msg "--- Checking podman images after the build ---"
podman images

echo
