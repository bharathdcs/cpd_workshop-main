#!/bin/bash

. ../common.sh

msg "Doing netstat -an | grep :443 | grep LISTEN  on bastion"
netstat -an | grep :443 | grep LISTEN


msg "Doing netstat -an | grep :443 | grep LISTEN on all masters and workers"
nodes=$(oc get nodes --no-headers | awk '{print $1}')
for n in $nodes
do
	echo Node = $n
	ssh core@$n "netstat -an | grep :443 | grep LISTEN"
done

