#!/bin/bash
docker run --cap-add=NET_ADMIN \
-it -p 1194:1194/udp -p 80:8080/tcp \
-e HOST_ADDR=$(curl -s https://api.ipify.org) \
alekslitvinenk/openvpn
