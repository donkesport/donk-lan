#!/bin/bash

nomad job status $1 | grep -i "Latest Deployment" -A 3

timeout_count=0

while (nomad job status $1 | grep -i "Latest Deployment" -A 3 | grep --quiet "Deployment is running"); [[ $? -eq 0 && $timeout_count -lt 180 ]]
do
    # deployment running
    sleep 5
    ((timeout_count=timeout_count+5))
    echo "Deployment still running... $timeout_count s elapsed"
done

nomad job status $1 | grep -i "Latest Deployment" -A 3 | grep --quiet failed
if [ $? -eq 0 ]
then
    # failed
    >&2 echo "ERROR: Failed deployment"
    exit 1
fi


nomad job status $1 | grep -i "Latest Deployment" -A 3 | grep --quiet success
if [ $? -eq 0 ]
then
    # success
    echo "Successful deployment"
    exit 0
fi

