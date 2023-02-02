#!/bin/bash

# Call with : trigger_ci.sh gitea_token.secret drone_token.secret branch

# Sync mirror
echo "-- Sync mirror --"
curl -X 'POST' \
  'http://git.donk.lan:3000/api/v1/repos/donkesport/donk-lan/mirror-sync' \
  -H 'accept: application/json' \
  -H "authorization: Basic `cat $1`" \
  -d ''

# launch CI
# get parameters
echo "-- CI parameters --"
read -p 'nomad_server_ip: ' nomad_server_ip 
read -p 'job_tested / terraform to apply: ' job_tested
read -p 'ansible playbook: ' playbook
read -p 'extra_vars: ' extra_vars

echo "-- Running CI --"
curl -X 'POST' \
    "http://drone.donk.lan/api/repos/donkesport/donk-lan/builds?branch=$3&nomad_server_ip=$nomad_server_ip&job_tested=$job_tested&playbook=$playbook&extra_vars=$extra_vars" \
    -H "Authorization: Bearer `cat $2`"

