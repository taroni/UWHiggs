#!/bin/bash

set -o nounset
set -o errexit

export jobid=MiniAodV2For25ns_ExtraJets_LFV
export isData=false
export checkZtt=false
export checkZmm=false
export checkZee=false
rake analyzeSpring2015MiscSignal
rake analyzeSpring2015WJetsSignal
export checkZtt=true
rake analyzeSpring2015ZJetsSignal
export checkZtt=false
export checkZmm=true
rake analyzeSpring2015ZJetsSignal
export checkZmm=false
export checkZee=true
rake analyzeSpring2015ZJetsSignal
export checkZee=false
export isData=true
rake analyzeLFVMuTauDataSignal

