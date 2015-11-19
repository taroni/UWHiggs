#!/bin/bash

# Generate the cython proxies used in the analyses

source jobid.sh


export jobid=$jobid13
export datasrc=/hdfs/store/user/cepeda/$jobid
#export datasrc=/hdfs/store/user/ndev/$jobid

if [ -z $1 ]; then
    export afile=`find $datasrc/ | grep root | head -n 1`
else
    export afile=$1
fi

echo "Building cython wrappers from file: $afile"

rake "make_wrapper[$afile, et/final/Ntuple, ETauTree]"

if [ -z $1 ]; then
    export afile=`find $datasrc/ | grep root | grep data |  head -n 1`
else
    export afile=$1
fi

rake "make_wrapper[$afile, et/final/Ntuple, ETauDataTree]"
#rake "make_wrapper[$afile, mmt/final/Ntuple, MMTTree]"
#rake "make_wrapper[$afile, emm/final/Ntuple, MMETree]"

#rake "make_wrapper[$afile, et/final/Ntuple, ETauTree]"
ls *pyx | sed "s|pyx|so|" | xargs -n 1 -P 10 rake 

#