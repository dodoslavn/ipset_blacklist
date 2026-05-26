# Tool for blacklisting of IPs marked for scam/spam activities
Script which will update and apply latest list of IP marked for bad activities to you system. 
## Supported lists:
- Spamhaus
- Blocklist.de
- ipdeny.com (to support block of all traffic from specified countries)
## Requirements:
- iptables
- ipset
## Installation
Switch to "root" user (or use "sudo" in next steps)
> su - root

Move to some permanent folder, here is example  
> cd /opt/git/

Clone this git repository
> git clone https://github.com/dodoslavn/ipset_blacklist.git

Create config file from example
> cp ./conf/main.conf.example ./conf/main.conf

Modify systemd service name which will run this script if you want  
> editor ./conf/config.sh

Run the installation script  
> ./scripts/initial_setup.sh

## Verification

Check state of the systemd service
> systemctl status custom-ipset_blacklist

Check the output of the systemd service
> journalctl -u custom-ipset_blacklist

Check if rules with ipsets are in iptables
> ipset list

Check if the ipsets are applied to some iptable rule
> iptables -L -n | grep match-set
