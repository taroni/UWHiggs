#!/bin/bash
export OVERRIDE_META_TREE_data_EEE='eee/metaInfo'

export IGNORE_LUMI_ERRORS=1

source jobid.sh
export jobid=$jobid13

echo $jobid
#export datasrc=/hdfs/store/user/$USER/  #$(ls -d /scratch/*/data/$jobid | awk -F$jobid '{print $1}')
#export MEGAPATH=/hdfs/store/user/$USER
export datasrc=/hdfs/store/user/ndev  #$(ls -d /scratch/*/data/$jobid | awk -F$jobid '{print $1}')
export MEGAPATH=/hdfs/store/user/ndev

./make_proxies.sh
rake "meta:getinputs[$jobid, $datasrc,eee/metaInfo,eee/summedWeights]"
rake "meta:getmeta[inputs/$jobid,eee/metaInfo, 13,eee/summedWeights]"
#RakeOA "meta:getinputs[$jobid, $datasrc,ee/metaInfo]"
#rake "meta:getmeta[inputs/$jobid, ee/metaInfo, 13]"

unset OVERRIDE_META_TREE_data_EEE
unset IGNORE_LUMI_ERRORS
