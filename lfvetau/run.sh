#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

export MEGAPATH=/hdfs/store/user/taroni/
source jobid.sh
#export jobid=$jobid8
#export jobid='MCntuples_25March'
export jobid='MCntuples_13May'

#rake genkin
#rake recoplots
rake controlplots
#export jobid=$jobidmt
#rake recoplotsMuTau
#rake drawplots
#rake genkinEMu
#rake genkinMuTau
