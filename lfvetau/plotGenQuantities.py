#from lfvmutau plotter
from sys import argv, stdout, stderr
import ROOT
import sys

ROOT.gROOT.SetStyle("Plain")
ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(0)

shape_norm = True
if shape_norm == False:
	ynormlabel = "Normalized to Data "
else:
	ynormlabel = "Normalized to 1 "

canvas = ROOT.TCanvas("canvas","canvas",800,800)
LFVStack = ROOT.THStack("stack","")

ggETaufile = ROOT.TFile('results/MCntuples21Feb/LFVHAnalyzeGEN/ggHiggsToETau.root')
ggSMHTauTaufile = ROOT.TFile('results/MCntuples21Feb/LFVHAnalyzeGEN/GluGluToHToTauTau_M-125_8TeV-powheg-pythia6.root')

gendir = ggETaufile.Get('gen')

hlist = gendir.GetListOfKeys()

iter = ROOT.TIter(hlist)

for i in iter:
    lfv_histo = ggETaufile.Get('gen/'+i.GetName())
    sm_histo = ggSMHTauTaufile.Get('gen/'+i.GetName())
    
    if lfv_histo.Integral() != 0 and sm_histo.Integral() != 0  : 
        lfv_histo.Scale(1./lfv_histo.Integral())
        sm_histo.Scale(1./sm_histo.Integral())
        lfv_histo.Draw()
        sm_histo.Draw("SAME") 
    
        lfv_histo.SetLineWidth(2)
        sm_histo.SetLineColor(2)
        sm_histo.SetLineWidth(2)
        
        canvas.Update()
        canvas.SaveAs('plots/gen_'+i.GetName()+'.png')


