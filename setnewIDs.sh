#!/usr/bin/env bash
cp /etc/passwd{,.bak}
cp /etc/group{,.bak}
while read line ; do
group="${line%%:*}"
dirId="${line##*:}"
[[ -z "${group}"
&& -z "${dirId}"
]] && continue;
# luckily username is the same as groupname
sed \
-ie "/${group}/{s/:[[:digit:]]*:/:${dirId}:/}" \
/etc/group
sed \
-rie "/${group}/{s/:([[:digit:]]*):[[:digit:]]*:/:\1:${dirId}:/}" \
/etc/passwd
done < <(getent group | awk -F ':' '{ print $1 ":" $3 }')
#wenn du sie scharf machen willst muste nur vor jeweils die sed instructionen vor jeweils das e ein i setzen
#also bei der nächsten zeile
