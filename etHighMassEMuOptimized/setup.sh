#!/bin/bash
export OVERRIDE_META_TREE_data_ET='eee/metaInfo'
#export OVERRIDE_META_TREE_data_ET='emm/metaInfo'

export IGNORE_LUMI_ERRORS=1

source jobid.sh

#./make_proxies.sh

#export datasrc=/hdfs/store/user/ndev/
#export MEGAPATH=/hdfs/store/user/ndev/
#export jobid='fromNab'
##echo $jobid

#rake "meta:getinputs[$jobid, $datasrc,et/metaInfo, et/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, et/metaInfo, 13, et/summedWeights]"


export datasrc=/hdfs/store/user/fmeng/
export MEGAPATH=/hdfs/store/user/fmeng/

#export jobid=$jobidFanbo
#export jobid=$jobid3Ldata
export jobid=LFV_HighMass
echo $jobid
rake "meta:getinputs[$jobid, $datasrc,em/metaInfo, em/summedWeights]"
rake "meta:getmeta[inputs/$jobid, em/metaInfo, 13, em/summedWeights]"
#rake "meta:getinputs[$jobid, $datasrc,mm/metaInfo, mm/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, mm/metaInfo, 13, mm/summedWeights]"
#rake "meta:getinputs[$jobid, $datasrc,emm/metaInfo, emm/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, emm/metaInfo, 13, emm/summedWeights]"
#rake "meta:getinputs[$jobid, $datasrc,eee/metaInfo, eee/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, eee/metaInfo, 13, eee/summedWeights]"
#rake "meta:getinputs[$jobid, $datasrc,et/metaInfo, et/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, et/metaInfo, 13, et/summedWeights]"

#export jobid=$jobid3Lmc
#rake "meta:getinputs[$jobid, $datasrc,eee/metaInfo, eee/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, eee/metaInfo, 13, eee/summedWeights]"


#export jobid=$jobidMC
#echo $jobid
#rake "meta:getinputs[$jobid, $datasrc,et/metaInfo, et/summedWeights]"
#rake "meta:getmeta[inputs/$jobid, em/metaInfo, 13, em/summedWeights]"



unset OVERRIDE_META_TREE_data_ET
unset IGNORE_LUMI_ERRORS
