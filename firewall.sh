export SERVER="37.16.26.17"
export REDIRPORT=8671
export HTTPPORT=80

ipset destroy ALLOW 
ipset destroy ADS

ipset create ALLOW iphash timeout 120
ipset create ADS iphash timeout 30

iptables -t mangle -A fwmark -m set ! --match-set ALLOW src -p tcp --dport 80         -s 192.168.0.0/16 -j SET --add-set ADS src
iptables -t mangle -A POSTROUTING -m set   --match-set ADS   src -p tcp -d $SERVER --dport $REDIRPORT -s 192.168.0.0/16 -j SET --add-set ALLOW src

iptables -A forwarding_lan_rule -p tcp --dport 53 -j ACCEPT
iptables -A forwarding_lan_rule -p udp --dport 53 -j ACCEPT

iptables -A forwarding_lan_rule -p tcp -d $SERVER --dport $REDIRPORT -j ACCEPT
iptables -A forwarding_lan_rule -p tcp -d $SERVER --dport $HTTPPORT -j ACCEPT

iptables -A forwarding_lan_rule -m set ! --match-set ADS src -j ACCEPT

iptables -t nat -A prerouting_lan_rule -m set --match-set ADS src -p tcp --dport 80 ! -d $SERVER -j DNAT --to-destination $SERVER:$REDIRPORT
