#!/bin/bash
### Script to setup VPN box on Ubuntu 16 (xenial) ####
## By Aman G, Sept 2017 ####
## set company name and public ip below ###
#set -e
COMPANY="mycomp"
PUB_IP="127.0.0.1"

if ! which shorewall > /dev/null; then
# install packages
	sudo apt update
	sudo apt install shorewall bind9 bind9utils bind9-doc wget git -y

	# install docker for vpn
	git clone https://github.com/awolde/aws-wp.git
	aws-wp/bash-scripts/install-docker.sh 
	rm -rf aws-wp

	# setup caching dns server
	sudo cp named.conf.options /etc/bind/
	sudo systemctl enable bind9.service
	sudo systemctl start bind9.service

	# setup shorewall configs
	sudo cp -r shorewall/* /etc/shorewall/
	sudo systemctl enable shorewall.service
	sudo systemctl start shorewall.service

	# setup autostart for vpn docker instance
	sudo cp -p start-vpn.sh /usr/local/bin/
	sudo cp vpn.service /etc/systemd/system/
	sudo systemctl daemon-reload
	sudo systemctl enable vpn.service
	sudo systemctl start vpn.service
else
	echo -e "\n\n\e[1;34mShorewall and docker installed! Continuing ....\e[0m\n\n"
fi 

if docker ps > /dev/null; then
	# make sure docker starts after shorewall
	sudo cp docker.service  /etc/systemd/system/multi-user.target.wants/docker.service
	sudo systemctl daemon-reload

	# create openvpn docker instance, supply password when asked
	INET=$(ifconfig eth0 | grep 'inet addr' | cut -d':' -f2 | tr -d Bcast)
	export OVPN_DATA="ovpn-data-${COMPNAY}"
	echo 'export OVPN_DATA="ovpn-data-${COMPNAY}"' >> ~/.bashrc
	docker volume create --name $OVPN_DATA
	docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://${PUB_IP}:443
	docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
	docker run -v $OVPN_DATA:/etc/openvpn -d -p 443:1194/tcp --name ${COMPNAY}-vpn --cap-add=NET_ADMIN kylemanna/openvpn
	docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${COMPANY} nopass
	docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${COMPANY} > ${COMPANY}.ovpn
	echo -e "\e[1;34mVPN configurations saved as ${COMPANY}.ovpn\e[0m"
else
	echo -e "\n\n\e[1;34mLog off and log back in and re-run this script\e[0m\n\n\n"
	exit 1
fi
