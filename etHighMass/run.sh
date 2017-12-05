#!/bin/bash
# Run all of the analysis

set -o nounset
set -o errexit

source ../../FinalStateAnalysis/environment.sh

export CutFlow=1


export MEGAPATH=/hdfs/store/user/taroni/
source jobid.sh
export jobid=$jobidSignal
echo $jobid
rake recoplots

export MEGAPATH=/hdfs/store/user/ndev/
export jobid=$jobidMC
echo $jobid
rake recoplots

export jobid=$jobidData
echo $jobid
rake recoplots


