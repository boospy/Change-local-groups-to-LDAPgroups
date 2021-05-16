#!/usr/bin/env bash
shopt -s lastpipe
[[ -z "${1}" ]] && { echo 'Path not set' ; exit 1; }
FINDPATH="${1}"

# ##########################
# get user id from ldap directory 
# (directory needs to be configured 
# with higher priority than local)
# 
# @param String username
# @return int userId
# ##########################
get_directoryUid () {
  userName="${1}"
  getent passwd | egrep "^${userName}" | cut -f 3 -d ':' | read user
  echo $user
}

# ##########################
# get group id from ldap directory 
# (directory needs to be configured 
# with higher priority than local)
# 
# @param String groupname
# @return int groupId
# ##########################
get_directoryGid () {
  groupName="${1}"
  getent group | egrep "^${groupName}" | cut -f 3 -d ':' | read group
  echo $group
}

while read line; do
  user="${line%%:*}"
  localUid="${line##*:}"
  get_directoryUid "${user}" | read directoryUid

  # save some time
[[ -z "${directoryUid}"
|| -z "${localUid}"
|| -z "${user}"
]] && continue;
  if [[ "${localUid}" -ne "${directoryUid}" ]] ; then
    find "${FINDPATH}" -user "${localUid}" -exec chown "${directoryUid}" "{}" \;
  fi
done < <(awk -F ':' '{ print $1 ":" $3  }' < /etc/passwd)

while read line; do
  group="${line%%:*}"
  localGid="${line##*:}"
  get_directoryGid "${group}" | read directoryGid

  # save some time
[[ -z "${directoryGid}"
|| -z "${localGid}"
|| -z "${group}"
]] && continue;
  if [[ "${localGid}" -ne "${directoryGid}" ]] ; then
    find "${FINDPATH}" -group "${localGid}" -exec chgrp "${directoryGid}" "{}" \;
  fi
done < <(awk -F ':' '{ print $1 ":" $3  }' < /etc/group)