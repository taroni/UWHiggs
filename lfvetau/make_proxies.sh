#!/bin/bash

# Generate the cython proxies used in the analyses

source jobid.sh

export jobid=$jobid
export datasrc=/hdfs/store/user/$USER/$jobid 
#export datasrc=`ls -d /nfs_scratch/taroni/$jobid | head -n 1`

if [ -z $1 ]; then
    export afile=`find $datasrc/ | grep root | head -n 1`
else
    export afile=$1
fi

echo "Building cython wrappers from file: $afile"

rake "make_wrapper[$afile, et/final/Ntuple, ETauTree]"

ls *pyx | sed "s|pyx|so|" | xargs -n 1 -P 10 rake 
