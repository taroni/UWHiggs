#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

export MEGAPATH=/hdfs/store/user/ndev/
source jobid.sh
export jobid=$jobid13

#rake genkin
#rake recoplots
#rake recoplotsMVA
#rake controlplots
#rake controlplotsMVA
#rake fakeeet
#rake fakeeetMVA
#rake  efits
#rake drawTauFakeRate
#export jobid=$jobidmt
rake recoplotsMVA2
#rake stitched
#rake inclus
#rake reco2
#rake  emuOptim2
##rake drawplots
#rake genkinEMu
#rake genkinMuTau
#rake fakemmmMVA
#rake fakeeemMVA
#rake fakeeeeMVA
#rake fakemmeMVA
#rake  fits
#rake efits
#rake zmm
#rake test