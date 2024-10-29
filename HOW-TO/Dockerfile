
FROM icr.io/cpopen/cpfs/icp4data-nginx-repo@sha256:ddf46c600c11c231bc843cc4714473c544666cfd4309d895ccfc42ec551bb4c9

USER root

# RUN yum install git -y
# RUN subscription-manager attach --auto
RUN dnf install iputils -y
RUN dnf install net-tools -y
# RUN apt-get update -y
# RUN apt-get install -y iputils-ping
# RUN apt-get install net-tools
