#from lfvmutau plotter
import os
from sys import argv, stdout, stderr
import ROOT
import sys
from FinalStateAnalysis.PlotTools.MegaBase import make_dirs

jobid = os.environ['jobid']

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

mydir = 'results/'+jobid+'/LFVHAnalyzeGEN/'

vbffile = ROOT.TFile(mydir+'VBF_LFV_HToETau_M125_13TeV_powheg_pythia8.root')
ggfile =  ROOT.TFile(mydir+'GluGlu_LFV_HToETau_M125_13TeV_powheg_pythia8.root')

vbflumifile=open('inputs/'+jobid+'/VBF_LFV_HToETau_M125_13TeV_powheg_pythia8.lumicalc.sum', 'r')
gglumifile = open('inputs/'+jobid+'/VBF_LFV_HToETau_M125_13TeV_powheg_pythia8.lumicalc.sum', 'r')

vbflumi = float(vbflumifile.readline())
gglumi = float(gglumifile.readline())

gendir = vbffile.Get('gen')
hlist = gendir.GetListOfKeys()

iter = ROOT.TIter(hlist)

filepath = 'plots/'+vbffile.GetName()[8 : len(vbffile.GetName()) -5]
print filepath
startingdir = os.getcwd()
print startingdir
dirs = filepath.split('/')
del dirs[-1]
print dirs
thechannel = 'e #tau_{h}'
for d in dirs:
        currentdir = os.getcwd()
        dirlist = os.listdir(currentdir)
        
        if d in dirlist:
                os.chdir(d)
        else: 
                os.makedirs(d)
                os.chdir(d)
		
                
os.chdir(startingdir)
        
for i in iter:
        gg_histo = ggfile.Get('gen/'+i.GetName())
        vbf_histo = vbffile.Get('gen/'+i.GetName())
        
        if gg_histo.Integral() != 0 and vbf_histo.Integral() != 0  : 
                gg_histo.Scale(1./gglumi)
                vbf_histo.Scale(1./vbflumi)
                
                p = gg_histo.GetName()[0:1]
                if p == 't' : p = '#tau'
                if p == 'e' : p = 'e'
                gg_histo.Draw("E")
                vbf_histo.Draw("ESAME") 
                
                gg_histo.SetLineWidth(2)
                vbf_histo.SetLineColor(2)
                vbf_histo.SetLineWidth(2)
                
                
                canvas.SetLogy(0)
                variable=''
                if gg_histo.GetName()[4:7] == "Phi" : variable = "#phi"
                if gg_histo.GetName()[4:7] == "Eta" : variable = "#eta"
                if gg_histo.GetName()[4:10] == "Energy" : 
                        variable = "energy (GeV)"
                        canvas.SetLogy(1)
                if gg_histo.GetName()[4:6] == "Pt" : 
                        variable = "p_{T} (GeV)"
                        canvas.SetLogy(1)
                if gg_histo.GetName()[9:17] == "DeltaPhi" : 
                        variable = "#Delta#phi"
                        p = 'e#tau'
                        canvas.SetLogy(1)
                if gg_histo.GetName() == "higgsPt" : 
                        variable = "p_{T} (GeV)"
                        canvas.SetLogy(1)
                axislabel = p+" "+variable
                if variable != '' : gg_histo.GetXaxis().SetTitle(axislabel)

                maxgg = gg_histo.GetBinContent(gg_histo.GetMaximumBin())
                maxvbf  = vbf_histo.GetBinContent(vbf_histo.GetMaximumBin())
                if canvas.GetLogy()==0 :
                        if maxvbf > maxgg :
                                gg_histo.GetYaxis().SetRangeUser(0, maxvbf*1.3)
                        else :
                                gg_histo.GetYaxis().SetRangeUser(0, maxgg*1.3)
                                
                if gg_histo.GetName()[4:13] == 'DecayMode': 
                        legend = ROOT.TLegend(0.6,0.75,0.8,0.85)
                else :
                        legend = ROOT.TLegend(0.6,0.8,0.9,0.9)
                        
                legend.SetFillColor(0)
                if  thechannel == 'e #tau_{h}' :
                        legend.AddEntry(gg_histo, "gf H#rightarrow e#tau_{h}")
                        legend.AddEntry(vbf_histo, "vbf H#rightarrow e#tau_{h}")
                else:
                        legend.AddEntry(gg_histo, "gf H #rightarrow " +thesmchannel)
                        legend.AddEntry(vbf_histo, "vbf H #rightarrow "+ thechannel)
                        
                if p != 'h' :
                        legend.Draw()
                        
                canvas.Update()
                canvas.SaveAs('/'.join(dirs)+'/gen_'+i.GetName()+'.png')
 
