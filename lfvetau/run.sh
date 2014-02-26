#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit
export MEGAPATH=/nfs_scratch/taroni/data
source jobid.sh

export jobid=$jobid8

rake genkin


