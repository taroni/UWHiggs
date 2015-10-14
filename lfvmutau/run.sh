#!/bin/bash

set -o nounset
set -o errexit

#export jobid=MiniAODSIM-Spring15
export jobid=MiniAODSIM-Spring15-25ns_LFV_V1_October10
rake analyzeSpring2015
