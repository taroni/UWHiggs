#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

export MEGAPATH=/hdfs/store/user/taroni/
source jobid.sh
export jobid=$jobid8


#rake genkin
rake recoplots
#rake drawplots
#rake genkinEMu
#rake genkinMuTau
