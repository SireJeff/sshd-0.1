#!/bin/bash
# Run the start.sh script
FILE="/etc/rc.local"

if [[ -f "$FILE" && -s "$FILE" ]]
then
    echo "$FILE exists and is not empty."
    echo "Starting listening..."
    nohup /etc/listen.sh &
    nohup /etc/rc.local &
else
   #echo "Starting start.sh..."
    #/usr/local/bin/start.sh &  
    successful_start=false
    echo "Starting start.sh..."
    while [ "$successful_start" = false ]
    do
        /usr/local/bin/start.sh
        if [ $? -eq 0 ]; then
            echo "start.sh script finished successfully"
            successful_start=true
            #comment "exit 1" out for akash
            exit 1
        else
            echo "start.sh script failed, re-running"
            sleep 5 # wait for 5 seconds before running again
        fi
    done
fi
echo "Starting sshd..."
/usr/sbin/sshd -D &
echo "Starting bash..."
/bin/bash &
echo "Starting userlimit..."
nohup /etc/ulimit.sh &


#lsof -i -P -n | grep LISTEN &
# Keep the container alive
tail -f /dev/null