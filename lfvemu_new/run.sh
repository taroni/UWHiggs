#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

export MEGAPATH=/hdfs/store/user/caillol/
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
#rake recoplotsMVA
#rake stitched
#rake reco2
rake runnup
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
