#!/bin/bash

set -o nounset
set -o errexit

export jobid=MiniAodV2For25ns_ExtraJets_LFV
export isRealData=false
export isZTauTau=false
rake analyzeSpring2015Misc
rake analyzeSpring2015WJets
rake analyzeSpring2015ZJets
export isZTauTau=true
rake analyzeSpring2015ZTauTauJets
export isZTauTau=false
export isRealData=true
rake analyzeLFVMuTauData

