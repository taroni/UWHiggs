#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

export MEGAPATH=/hdfs/store/user/taroni/
source jobid.sh
export jobid=$jobidMC
rake fakemme
export jobid=$jobidData
rake fakemmeData

