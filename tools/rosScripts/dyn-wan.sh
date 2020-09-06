#!/bin/bash
source ./config

#用法：把本脚本输出的内容保存到ros里成为一个script，然后新建scheduler来调度它
cat<<EOF
:global newIP [/ip address get [/ip address find interface=$wan] address]
:set newIP [:pick \$newIP 0 ([:len \$newIP]-3)]

:foreach item in=[/ip firewall nat find comment~"$dynWanTag"] do={ \\
:local oldIP [/ip firewall nat get \$item dst-address]
:if (\$newIP!=\$oldIP) do={\\
:log info message="dyn-wan: update DNAT's dst-address to \$newIP"
/ip firewall nat set \$item dst-address \$newIP
} else={\\
:log info message="dyn-wan: ip not change"
}
}

EOF
