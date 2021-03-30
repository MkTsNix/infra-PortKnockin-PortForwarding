#!/bin/bash
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --add-forward-port=port=8080:proto=tcp:toport=80:toaddr=192.168.0.2
firewall-cmd --reload