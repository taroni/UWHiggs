#!/bin/bash

# Get the data
export datasrc=/hdfs/store/user/aglevine/
export jobid=MiniAODSIM-Spring15-25ns_LFV_V1_October10
export afile=`find $datasrc/$jobid | grep root | head -n 1`

## Build the cython wrappers
rake "make_wrapper[$afile, mt/final/Ntuple, MuTauTree]"

ls *pyx | sed "s|pyx|so|" | xargs rake 
echo "finishing compilation" 
bash compileTree.txt

rake "meta:getinputs[$jobid, $datasrc,mt/metaInfo, mt/eventCount]"
rake "meta:getmeta[inputs/$jobid, mt/metaInfo, 0]"


