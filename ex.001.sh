#!/bin/bash

oldip=$(< /var/run/host1no-ip.org)
ip=$(curl -Ls http://tnx.nl/ip)

if (( $oldip != $ip )); then
    killall noip2
    /usr/bin/noip2
    echo "$ip" > /var/run/host1.no-ip.org
fi


$("$iptables" -I "$chain" -s "$ip"/32 -j ACCEPT)

-A IF_KNOCK -p tcp -m tcp --dport XXXXX -m recent --set --name IF_KNK_LIST --rsource -j LOG --log-prefix "seq1: " --log-level 6 --log-ip-options --log-uid
-A IF_KNOCK -p tcp -m tcp --dport YYYYY -m recent --rcheck --seconds TC --name IF_KNK_LIST --rsource -j KNOCK_ACCEPT
-A IF_KNOCK -j DROP
-A KNOCK_ACCEPT -j LOG --log-prefix "kseq2: " --log-level 6 --log-ip-options --log-uid
-A KNOCK_ACCEPT -m recent --set --name ACCPT_KNK_LIST --rsource
-A KNOCK_ACCEPT -m recent --remove --name IF_KNK_LIST --rsource
-A KNOCK_ACCEPT -j DROP
...
-A INPUT -p tcp -m tcp --dport XXXXX -m state --state NEW -j IF_KNOCK
-A INPUT -p tcp -m tcp --dport YYYYY -m state --state NEW -j IF_KNOCK
-A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --rcheck --seconds TTTTT --name ACCPT_KNK_LIST --rsource -j SSH_ACCEPT

-A SSH_ACCEPT -m recent --set --name NEW_SSH --rsource
-A SSH_ACCEPT -m recent --update --seconds TTT --hitcount N --name NEW_SSH --rsource -j DROP
-A SSH_ACCEPT -j ACCEPT
