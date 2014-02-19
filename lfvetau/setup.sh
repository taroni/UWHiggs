#!/bin/bash
export OVERRIDE_META_TREE_data_ET='et/metaInfo'

export IGNORE_LUMI_ERRORS=1

source jobid.sh
export jobid=$jobid8
export datasrc=/hdfs/store/user/$USER/  #$(ls -d /scratch/*/data/$jobid | awk -F$jobid '{print $1}')

export MEGAPATH=/hdfs/store/user/$USER
./make_proxies.sh
rake "meta:getinputs[$jobid, $datasrc,et/metaInfo]"
rake "meta:getmeta[inputs/$jobid, et/metaInfo, 8]"


unset OVERRIDE_META_TREE_data_ET
unset IGNORE_LUMI_ERRORS
