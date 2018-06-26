import ROOT
import os
import sys

samplelist=[
    'tmpeLzUutSimpleEMAnalyzer-GluGlu_LFV_HToETau_M300_13TeV_powheg_pythia8_v6-v1',
    'tmp1ZuyY3SimpleEMAnalyzer-GluGlu_LFV_HToETau_M600_13TeV_powheg_pythia8_v6-v1',
    'tmpisLY4_SimpleEMAnalyzer-GluGlu_LFV_HToETau_M200_13TeV_powheg_pythia8_v6-v1',
    'tmp402QmmSimpleEMAnalyzer-GluGlu_LFV_HToETau_M450_13TeV_powheg_pythia8_v6-v1',
    'tmpZUeSA7SimpleEMAnalyzer-GluGlu_LFV_HToETau_M750_13TeV_powheg_pythia8_v6-v1',
    'tmp3wM7ZRSimpleEMAnalyzer-GluGlu_LFV_HToETau_M900_13TeV_powheg_pythia8_v6-v1',
    'tmp0Txj1FSimpleEMAnalyzer450-GluGlu_LFV_HToETau_M450_13TeV_powheg_pythia8_v6-v1',
    'tmpRGoj8XSimpleEMAnalyzer450-GluGlu_LFV_HToETau_M900_13TeV_powheg_pythia8_v6-v1',
    'tmpjIcQQ7SimpleEMAnalyzer450-GluGlu_LFV_HToETau_M600_13TeV_powheg_pythia8_v6-v1',
    'tmp2xOteVSimpleEMAnalyzer450-GluGlu_LFV_HToETau_M750_13TeV_powheg_pythia8_v6-v1']

hdfspath='/hdfs/store/user/taroni/MegaJob_'
fanbopath='/hdfs/store/user/fmeng/LFV_HighMass/'

for sample in samplelist:
    samplename=sample[sample.find('GluGlu'):]
    #files = [x[x.find('make_ntuples'):] for x in os.listdir(hdfspath+sample) if x.startswith('mega-batch-make_ntuples_cfg')]
    files=[x for x in os.listdir(fanbopath+samplename)]
    evtCount=0.
    for f in files:
        infile=ROOT.TFile.Open(fanbopath+samplename+'/'+f, "READ")
        h=infile.Get("em/eventCount")
        evtCount+=h.Integral()
        infile.Close()

    print '%s, %s, totEvt: %s, weight: %s' %( samplename, sample,  str(evtCount), str(1./evtCount))
        

for sample in samplelist:
    samplename=sample[sample.find('GluGlu'):]
    files = [x for x in os.listdir(hdfspath+sample) if x.startswith('mega-batch-make_ntuples_cfg')]
    cmd = 'hadd -f /nfs_scratch/taroni/'+samplename+'.root '+hdfspath+sample+'/mega-batch-make_ntuples_cfg*'
    os.system(cmd)
    if 'SimpleEMAnalyzer450' in sample:
        cmd2 = 'mv /nfs_scratch/taroni/'+samplename+'.root  results/LFV_HighMass/SimpleEMAnalyzer450/.'
        os.system(cmd2)
    else:
        cmd2 = 'mv /nfs_scratch/taroni/'+samplename+'.root  results/LFV_HighMass/SimpleEMAnalyzer/.'
        os.system(cmd2)
       
        
