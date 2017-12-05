#!/bin/bash

source ../../FinalStateAnalysis/environment.sh

export MEGAPATH=/hdfs/store/user/taroni/
source jobid.sh
export jobid=$jobidSignal
echo $jobid
python plotSignalHighMass.py

