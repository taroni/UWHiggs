#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

export MEGAPATH=/hdfs/store/user/ndev
source jobid.sh
export jobid=$jobid13

#rake genkin
#rake recoplots
#rake recoplotsMVA
#rake controlplots
#rake controlplotsMVA
rake fakemmeMVA
#rake fakemmtMVA
#rake fits
#rake drawTauFakeRate
#export jobid=$jobidmt
#rake recoplotsMuTau
#rake drawplots
#rake genkinEMu
#rake genkinMuTau