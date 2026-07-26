#!/usr/bin/bash

nmcli device wifi list

nmcli device wifi connect "CMCC-H6Rf" password "XUAan4Um"

sudo nmcli connection modify "CMCC-H6Rf" \
        ipv4.method manual \
        ipv4.addresses 192.168.100.166/24 \
        ipv4.gateway 192.168.100.1

sudo nmcli connection down "CMCC-H6Rf" &&
        sudo nmcli connection up "CMCC-H6Rf"
