#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

#export MEGAPATH=/hdfs/store/user/cepeda
export MEGAPATH=/hdfs/store/user/$USER
source jobid.sh
export jobid=$jobid13

#rake genkin
rake recoplotsMVA
#rake controlplotsMVA
#rake fakemmeMVA
#rake fakemmtMVA
#rake fits
