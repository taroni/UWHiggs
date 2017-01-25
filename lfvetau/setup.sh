#!/bin/bash
export OVERRIDE_META_TREE_data_ET='et/metaInfo'

export IGNORE_LUMI_ERRORS=1

source jobid.sh

./make_proxies.sh

#export datasrc=/hdfs/store/user/caillol/
#export MEGAPATH=/hdfs/store/user/caillol/

export datasrc=/hdfs/store/user/$USER/  #$(ls -d /scratch/*/data/$jobid | awk -F
export MEGAPATH=/hdfs/store/user/$USER

export jobid=$jobidData
echo $jobid
rake "meta:getinputs[$jobid, $datasrc,emm/metaInfo, emm/summedWeights]"
rake "meta:getmeta[inputs/$jobid, emm/metaInfo, 13, emm/summedWeights]"
#rake "meta:getinputs[$jobid, $datasrc,et/metaInfo, et/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, et/metaInfo, 13, et/summedWeights]"

export jobid=$jobidMC
echo $jobid
rake "meta:getinputs[$jobid, $datasrc,emm/metaInfo, emm/summedWeights]"
rake "meta:getmeta[inputs/$jobid, emm/metaInfo, 13, emm/summedWeights]"



unset OVERRIDE_META_TREE_data_ET
unset IGNORE_LUMI_ERRORS
