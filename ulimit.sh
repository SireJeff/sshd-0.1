#! /bin/bash

while /bin/true; do
    usernames=$(awk -F: 'NR > 24 && $1 != "root"  && $1 != "mysql" && $1 != "postfix" && $1 != "username" {print $1}' /etc/passwd)
    for username in $usernames; do
            limit=1
            c=$(pgrep -xcu $username sshd)
            if [[ $c > "$limit" ]]; then
                    #usermod -L $username
                    pkill -u $username
                    echo "Max $limit ssh connections allowed $username , but you have $c."
            fi
    done
done &