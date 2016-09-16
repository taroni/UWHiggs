#!/bin/bash
export OVERRIDE_META_TREE_data_ET='et/metaInfo'

export IGNORE_LUMI_ERRORS=1

source jobid.sh

#./make_proxies.sh
export datasrc=/hdfs/store/user/taroni/
export MEGAPATH=/hdfs/store/user/taroni
#export datasrc=/hdfs/store/user/$USER/  #$(ls -d /scratch/*/data/$jobid | awk -F
#export MEGAPATH=/hdfs/store/user/$USER

echo $jobid
export jobid=$jobid13
#rake "meta:getinputs[$jobid, $datasrc,eet/metaInfo, eet/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, eet/metaInfo, 13, eet/summedWeights]"

rake "meta:getinputs[$jobid, $datasrc,mmt/metaInfo, mmt/summedWeights]"
rake "meta:getmeta[inputs/$jobid, mmt/metaInfo, 13, mmt/summedWeights]"

#export jobid='LFV_808v1'
#rake "meta:getinputs[$jobid, $datasrc,em/metaInfo, em/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, em/metaInfo, 13, em/summedWeights]"

unset OVERRIDE_META_TREE_data_ET
unset IGNORE_LUMI_ERRORS
