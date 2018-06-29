#!/bin/bash
export OVERRIDE_META_TREE_data_ET='et/metaInfo'

export IGNORE_LUMI_ERRORS=1

source jobid.sh

#./make_proxies.sh

export datasrc=/hdfs/store/user/taroni/
export MEGAPATH=/hdfs/store/user/taroni/
export jobid=$jobidSignal
echo $jobid

#rake "meta:getinputs[$jobid, $datasrc,et/metaInfo, et/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, et/metaInfo, 13, et/summedWeights]"


export datasrc=/hdfs/store/user/fmeng/
export MEGAPATH=/hdfs/store/user/fmeng/

export jobid=$jobidFanbo
echo $jobid
#rake "meta:getinputs[$jobid, $datasrc,em/metaInfo, em/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, em/metaInfo, 13, em/summedWeights]"
#rake "meta:getinputs[$jobid, $datasrc,mm/metaInfo, mm/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, mm/metaInfo, 13, mm/summedWeights]"
#rake "meta:getinputs[$jobid, $datasrc,emm/metaInfo, emm/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, emm/metaInfo, 13, emm/summedWeights]"
rake "meta:getinputs[$jobid, $datasrc,et/metaInfo, et/summedWeights]"
rake "meta:getmeta[inputs/$jobid, et/metaInfo, 13, et/summedWeights]"

#export jobid=$jobidMC
#echo $jobid
#rake "meta:getinputs[$jobid, $datasrc,et/metaInfo, et/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, em/metaInfo, 13, em/summedWeights]"



unset OVERRIDE_META_TREE_data_ET
unset IGNORE_LUMI_ERRORS