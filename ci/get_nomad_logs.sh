#!/bin/bash

# Usage : ./get_nomad_logs.sh job-name
# Get ID of last allocation

alloc_id=`nomad job status -evals $1 | grep Allocations -A 2 | tail -n 1 | grep -oE "^[[:alnum:]]{8}"`
nomad alloc status $alloc_id
