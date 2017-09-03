## Openvpn with shorewall
This sets up your box as a router and configures vpn on port 443. All config files are in here except Shorewall configs, which are not uploaded for security reasons.

Edit the company name and public ip at the beginning of `setup-vpn.sh` script.

To run, install git first, and clone this repo and simply run the setup script.
```
$ sudo apt install git -y
$ git clone https://github.com/awolde/vpnsetup.git
$ cd vpnsetup
$ ./setup-vpn.sh
```
and follow the prompts.
