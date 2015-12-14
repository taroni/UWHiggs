#!/bin/bash

set -o nounset
set -o errexit

#export jobid=MiniAODv2_2fb_v3
#export isData=false
#export checkZtt=false
#rake analyzeSpring2015Misc
#rake analyzeSpring2015WJets
#export isData=false
#export checkZtt=true
#rake analyzeSpring2015ZJets
#export isData=true
#export checkZtt=false
#rake analyzeLFVMuTauData
#export jobid=MiniAODv2_2fb_v3
#export isData=true
#export checkZtt=false
#rake analyzeLFVMuTauData


export jobid=MiniAODv2_2fb_v3
export isData=false
export checkZtt=false
rake analyzeSpring2015MiscSignal
rake analyzeSpring2015WJetsSignal
#export isData=false
#export checkZtt=true
rake analyzeSpring2015ZJetsSignal
export isData=true
export checkZtt=false
#rake analyzeLFVMuTauDataSignal
#export jobid=MiniAODv2_2fb_v3
export isData=true
export checkZtt=false
rake analyzeLFVMuTauDataSignal

export jobid=MiniAODSIM-Spring15-25ns_LFV_MiniAODV2_Dec2_LFV_NoHF_JetEta25
export isData=false
export checkZtt=false
#rake analyzeSpring2015MiscSignal
#rake analyzeSpring2015WJetsSignal
#export isData=false
#export checkZtt=true
#rake analyzeSpring2015ZJetsSignal
export isData=true
export checkZtt=false
#rake analyzeLFVMuTauDataSignal
#export jobid=MiniAODv2_2fb_v3
export isData=true
export checkZtt=false
#rake analyzeLFVMuTauDataSignal

#export jobid=MiniAODv2_2fb_v3
#export isData=false
#export checkZtt=false
##rake analyzeSpring2015MiscSignal
##rake analyzeSpring2015WJetsSignal
#export isData=false
#export checkZtt=true
#rake analyzeSpring2015ZJetsSignal
#export jobid=MiniAODSIM-Spring15-25ns_LFV_MiniAODV2_Data
#export isData=true
#export checkZtt=false
#rake analyzeLFVMuTauDataSignal
