#!/bin/bash

oc proxy --port 8080 &

sleep 3

curl http://localhost:8080/openapi/v2 

sleep 3

fg

