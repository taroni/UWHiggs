import os
import itertools
import ROOT
import glob
import math
import logging
import pdb
import array
from fnmatch import fnmatch
from yellowhiggs import xs, br, xsbr


ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)
jobid = os.environ['jobid']
files = []
lumifiles = []
channel = 'eee'
period = '13TeV'
sqrts = 13

mc_samples = [
    'WW_*', 'ZZ_*','WZ_*', 
    'DYJetsToLL_M-50*','DY1JetsToLL_M-50*','DY2JetsToLL_M-50*','DY3JetsToLL_M-50*','DY4JetsToLL_M-50*', 'DYJetsToLL_M-10to50*', 'TT_*' ,'data_SingleElectron*'
]
samples = []
for x in mc_samples:
    files.extend(glob.glob('results/%s/EEEAnalyzer/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))

lumi=[]
datalumi=0.
for myfile in lumifiles:
    samples.append(myfile.replace('inputs/%s/' %(jobid), '' ).replace('.lumicalc.sum', ''))
    print myfile
    mylumi=[line.rstrip('\n') for line in open(myfile)]
    lumi.append(float(mylumi[0]))
    if 'data_' in myfile:
        datalumi+=float(mylumi[0])
        print mylumi
    print myfile, mylumi, datalumi

for n,sample in enumerate(samples):
    print lumi[n], sample 

outputdir = 'plots/%s/EEEAnalyzer/%s/' % (jobid, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)

col_vis_mass_binning=array.array('d',(range(0,200,20)+range(200,480,30)+range(500,1000,50)))
met_vars_binning=array.array('d',(range(0,200,20)+range(200,580,40)+range(600,1000,100)))
pt_vars_binning=array.array('d',(range(0,200,20)+range(200,500,40)+range(500,1000,100)))


histoname = [('e1Pt', 'e1 p_{T} (GeV)', pt_vars_binning, False ),
             ('e2Pt', 'e2 p_{T} (GeV)', pt_vars_binning, False ),
             ('e3Pt', 'e3 p_{T} (GeV)', pt_vars_binning, False ),
             ('e1Phi','e1 #phi',1, False ) ,('e1Eta','e1 #eta',1, False),
             ('e2Phi','e2 #phi',1, False ) ,('e2Eta','e2 #eta',1, False),
             ('e3Phi','e3 #phi',1, False ) ,('e3Eta','e3 #eta',1, False),
             ('e1_e2_Mass', 'e1 - e2 Mass (GeV)', 1, False), 
             ('e1_e3_Mass', 'e1 - e3 Mass (GeV)', 1, False), 
             ('e2_e3_Mass', 'e2 - e3 Mass (GeV)', 1, False),
             ('jetVeto30', "jetVeto30", 1, False)

             
]

##8804559.85359 WWTo1L1Nu2Q_13TeV_amcatnloFXFX_madspin_pythia8
##158021.678437 WWTo2L2Nu_13TeV-powheg
##23252131.3609 ZZTo2L2Q_13TeV_amcatnloFXFX_madspin_pythia8
##30906275.5474 WZTo1L1Nu2Q_13TeV_amcatnloFXFX_madspin_pythia8
##2050864.78555 WZTo1L3Nu_13TeV_amcatnloFXFX_madspin_pythia8
##30621968.8406 WZTo2L2Q_13TeV_amcatnloFXFX_madspin_pythia8
##1000.0 DYJetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8
##1000.0 DY1JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8
##1000.0 DY2JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8
##1000.0 DY3JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8
##1000.0 DY4JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8
##1000.0 DYJetsToLL_M-10to50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8
##5885.25433755 data_SingleElectron_Run2016B
##2867.64957474 data_SingleElectron_Run2016C
##4377.81234985 data_SingleElectron_Run2016D
##4187.94327535 data_SingleElectron_Run2016E
##7611.95942309 data_SingleElectron_Run2016G_v1
##8693.06373725 data_SingleElectron_Run2016H


data0 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016B_v1.root' %jobid, "READ")
data1 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016B_v2.root' %jobid, "READ")
data2 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016C.root' %jobid, "READ")
data3 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016D.root' %jobid, "READ")
data4 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016E.root' %jobid, "READ")
data5 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016G.root' %jobid, "READ")
data6 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016H_v2.root' %jobid, "READ")
data7 = ROOT.TFile('results/%s/EEEAnalyzer/data_SingleElectron_Run2016H_v3.root' %jobid, "READ")

Diboson0=ROOT.TFile('results/%s/EEEAnalyzer/WW_TuneCUETP8M1_13TeV-pythia8_v6-v1.root' %jobid, "READ")
Diboson1=ROOT.TFile('results/%s/EEEAnalyzer/ZZ_TuneCUETP8M1_13TeV-pythia8_v6-v1.root' %jobid, "READ")
Diboson2=ROOT.TFile('results/%s/EEEAnalyzer/WZ_TuneCUETP8M1_13TeV-pythia8_v6-v1.root' %jobid, "READ")

DY0=ROOT.TFile('results/%s/EEEAnalyzer/DYJetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8_v6_ext1-v2.root' %jobid, "READ")
DY1=ROOT.TFile('results/%s/EEEAnalyzer/DY1JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8_v6-v1.root' %jobid, "READ")
DY2=ROOT.TFile('results/%s/EEEAnalyzer/DY2JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8_v6-v1.root' %jobid, "READ")
DY3=ROOT.TFile('results/%s/EEEAnalyzer/DY3JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8_v6-v1.root' %jobid, "READ")
DY4=ROOT.TFile('results/%s/EEEAnalyzer/DY4JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8_v6-v1.root' %jobid, "READ")


TT=ROOT.TFile('results/%s/EEEAnalyzer/TT_TuneCUETP8M2T4_13TeV-powheg-pythia8_v6-v1.root' %jobid, "READ")
#plotter.mc_samples = new_mc_samples
foldernames=[]
sign=['os']

massRanges=[ '','eLoose', 'eTight']
for tuple_path in itertools.product(sign,  massRanges):
    name=os.path.join(*tuple_path)
    foldernames.append(name)
    path = list(tuple_path)

canvas=ROOT.TCanvas("c", "c", 600, 600)
canvas.Draw()
pad0=ROOT.TPad("pad0", "pad0", 0., 0.33, 1., 1.)
pad1=ROOT.TPad("pad1", "pad1", 0., 0., 1., 0.33)
pad0.Draw()
pad1.Draw()
for foldername in foldernames:
        if not os.path.exists(outputdir+foldername):
            os.makedirs(outputdir+foldername)

        for n,h in enumerate(histoname) :
            hdata0=data0.Get(os.path.join(foldername,h[0])).Clone()
            hdata1=data1.Get(os.path.join(foldername,h[0])).Clone()
            hdata2=data2.Get(os.path.join(foldername,h[0])).Clone()
            hdata3=data3.Get(os.path.join(foldername,h[0])).Clone()
            hdata4=data4.Get(os.path.join(foldername,h[0])).Clone()
            hdata5=data5.Get(os.path.join(foldername,h[0])).Clone()
            hdata6=data6.Get(os.path.join(foldername,h[0])).Clone()
            hdata7=data7.Get(os.path.join(foldername,h[0])).Clone()

            hdata0.Add(hdata1)
            hdata0.Add(hdata2)
            hdata0.Add(hdata3)
            hdata0.Add(hdata4)
            hdata0.Add(hdata5)
            hdata0.Add(hdata6)
            hdata0.Add(hdata7)

            hdata0.SetMarkerStyle(20)
            hdata0.SetMarkerColor(1)
            hdata0.SetLineColor(1)
            
            #hdata.Rebin(23, hdata.GetName(), h[2])
            #hdata0.Draw("EP")
            #hdata0.GetXaxis().SetTitle(h[1])
            
            hstack=ROOT.THStack("hs", "hs")

            hDiboson0=Diboson0.Get(os.path.join(foldername,h[0])).Clone()
            hDiboson1=Diboson1.Get(os.path.join(foldername,h[0])).Clone()
            hDiboson2=Diboson2.Get(os.path.join(foldername,h[0])).Clone()

            

            hDiboson0.Scale(datalumi/124123.468118)
            hDiboson1.Scale(datalumi/195678.937008)
            hDiboson2.Scale(datalumi/145915.279556)

            hDiboson0.Add(hDiboson1)
            hDiboson0.Add(hDiboson2)
            print hDiboson0.Integral()            
            hDiboson0.SetFillColor(38)
            hDiboson0.SetLineColor(38)
            hDiboson0.SetMarkerColor(38)
            hDiboson0.SetFillStyle(1001)

            hstack.Add(hDiboson0)

            
            hDY0=DY0.Get(os.path.join(foldername,h[0])).Clone()
            hDY1=DY1.Get(os.path.join(foldername,h[0])).Clone()
            hDY2=DY2.Get(os.path.join(foldername,h[0])).Clone()
            hDY3=DY3.Get(os.path.join(foldername,h[0])).Clone()
            hDY4=DY4.Get(os.path.join(foldername,h[0])).Clone()
            
            hDY0.Scale(datalumi/1000.)
            hDY1.Scale(datalumi/1000.)
            hDY2.Scale(datalumi/1000.)
            hDY3.Scale(datalumi/1000.)
            hDY4.Scale(datalumi/1000.)

            hDY0.Add(hDY1)
            hDY0.Add(hDY2)
            hDY0.Add(hDY3)
            hDY0.Add(hDY4)

            hDY0.SetFillColor(ROOT.kOrange - 2)
            hDY0.SetLineColor(ROOT.kOrange - 2)
            hDY0.SetMarkerColor(ROOT.kOrange - 2)
            hDY0.SetFillStyle(1001)
            
            hstack.Add(hDY0)


            hTT=TT.Get(os.path.join(foldername,h[0])).Clone()
            hTT.Scale(datalumi/95462.7206428)
            hTT.SetFillColor(9)
            hTT.SetLineColor(9)
            hTT.SetMarkerColor(9)
            hTT.SetFillStyle(1001)
            hstack.Add(hTT)

            pad0.cd()
            hstack.Draw("HIST")
            hdata0.Draw("SAMEEP")
            hstack.GetXaxis().SetTitle(h[1])

            
            pad1.cd()
            myhist=hDiboson0.Clone()
            myhist.Add(hDY0)
            myhist.Add(hTT)
            ratio=hdata0.Clone()
            ratio.Divide(myhist)
            ratio.Draw("EP")
            ratio.GetYaxis().SetRangeUser(0, 2)
            
            ref_function = ROOT.TF1('f', "1.", ratio.GetXaxis().GetXmin(), ratio.GetXaxis().GetXmax())
            ref_function.SetLineColor(2)
            ref_function.Draw("SAME")
            


            
            canvas.SaveAs(outputdir+foldername+'/'+h[0]+'.png')
            canvas.SaveAs(outputdir+foldername+'/'+h[0]+'.pdf')
    
