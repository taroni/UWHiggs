import rootpy.plotting.views as views
from optparse import OptionParser
import os
import ROOT
import glob
import math
import logging
import pdb
import array
from fnmatch import fnmatch
from yellowhiggs import xs, br, xsbr
import sys


ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)

jobid = os.environ['jobid']

mc_samples = ['ggM300ETau','ggM450ETau','ggM600ETau','ggM750ETau','ggM900ETau']
legsamples = ['M_{H} = 300 GeV', 'M_{H} = 450 GeV','M_{H} = 600 GeV','M_{H} = 750 GeV','M_{H} = 900 GeV']

files = []
lumifiles = []
channel = 'signalMC'

leptons = sys.argv[1]
print leptons
for x in mc_samples:
    files.extend(glob.glob('results/%s/%sAnalyzer/%s.root' % (jobid,leptons, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))

period = '13TeV'
sqrts = 13


sign = ['os']
jets = [0, 1]
outputdir = 'plots/%s/%sAnalyzer/%s/' % (jobid, leptons, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)

histoname = [('ePt', 'e p_{T} (GeV)', 1), ('ePhi','e #phi',1) ,('eEta','e #eta',1),
             ('type1_pfMetEt', 'type1PF MET (GeV)', 1) ,("h_collmass_pfmet", "M_{coll}", 1),
             ('ePFMET_DeltaPhi','#Delta#phi(e, MET)', 1),  ('eMtToPfMet_type1','M_{T}(e,MET) (GeV) ',1),
              ("jetVeto30", "Number of jets, p_{T}>30", 1)]
if leptons=='ETau':
    histoname.extend([
        ('tPt','#tau p_{T} (GeV)',1) ,('tPhi','#tau #phi',1), ('tEta','#tau #eta',1),
        ('e_t_DPhi','#Delta#phi(e,#tau)',1), ('e_t_DR','#DeltaR(e,#tau)',1), ('e_t_Mass', 'e-#tau Visible Mass (GeV)',1),
        ('tPFMET_DeltaPhi','#Delta#phi(#tau, MET)',2),('tMtToPfMet_type1','M_{T}(#tau, MET) (GeV)',1),
        ('e_t_PZeta', 'e_t_PZeta', 1), ('e_t_PZetaLess0p85PZetaVis', 'e_t_PZetaLess0p85PZetaVis', 1), ('e_t_PZetaVis', 'e_t_PZetaVis', 1),
    ])
else:
    histoname.extend([
        ('mPt','#mu p_{T} (GeV)',1) ,('mPhi','#mu #phi',1), ('mEta','#mu #eta',1),
        ('e_m_DPhi','#Delta#phi(e,#mu)',1), ('e_m_DR','#DeltaR(e,#mu)',1), ('e_m_Mass', 'e-#mu Visible Mass (GeV)',1),
        ('mDPhiToPfMet_type1','#Delta#phi(#mu, MET)',2),('mMtToPfMet_type1','M_{T}(#mu, MET) (GeV)',1),
        ('e_m_PZeta', 'e_m_PZeta', 1), ('e_m_PZetaLess0p85PZetaVis', 'e_m_PZetaLess0p85PZetaVis', 1), ('e_m_PZetaVis', 'e_m_PZetaVis', 1),
    ])
    

foldernames=['os/le1', 'os/0', 'os/1', 'os/le1/selected', 'os/0/selected', 'os/1/selected']
outfile = ROOT.TFile("outfile.root", "RECREATE")
osdir = outfile.mkdir("os")
ROOT.TH1.AddDirectory(1)
c=ROOT.TCanvas()
c.Draw()
leg=ROOT.TLegend(0.2, 0.65, 0.4, 0.85)

for foldername in foldernames:
    tdir = outfile.mkdir(foldername)
    ROOT.TH1.AddDirectory(1)
    tdir.cd()
    for n,h in enumerate(histoname) :
        
        c.Clear()
        mymax=0
        leg.Clear()
    	for n,sample in enumerate(mc_samples):
         
	    filename = 'results/%s/%sAnalyzer/%s.root' %(jobid,leptons, sample)
            #print filename
            myfile=ROOT.TFile.Open(filename, "READ")
            outfile.cd()
            tdir.cd()
            ROOT.TH1.AddDirectory(1)
            #print foldername+'/'+h[0]
            myhisto=myfile.Get(foldername+'/'+h[0]).Clone()
            myhisto.SetName(foldername.replace('/','_')+'_'+myhisto.GetName()+sample)
            myhisto.SetDirectory(tdir)
            myhisto.Scale(1./myhisto.Integral())
            myhisto.Rebin(h[2])
            myhisto.SetLineColor(n+1)
            myhisto.SetLineWidth(2)
            leg.AddEntry(myhisto, legsamples[n], 'l')
            
            if n==0:
                myhisto.Draw("HIST")
                myhisto.GetXaxis().SetTitle(h[1])
                myhisto.GetYaxis().SetRangeUser(0, myhisto.GetBinContent(myhisto.GetMaximumBin())*1.2)
                if 'DeltaPhi' in h[0] or 'DPhi' in h[0] or 'DR' in h[0]:
                    print h[0]
                    myhisto.GetYaxis().SetRangeUser(0, 0.7)
                    if h[0]=='ePFMET_DeltaPhi' :
                        myhisto.GetYaxis().SetRangeUser(0, 0.4)
                
            else:
                myhisto.Draw("SAMEHIST")
                
            if n == len(mc_samples)-1:
                leg.SetX1NDC(0.2)
                leg.SetX2NDC(0.4)
                leg.SetY1NDC(0.65)
                leg.SetY2NDC(0.85)
                leg.Draw()

                if 'Pt' in h[0] or 'Mass' in h[0] or 'jetVeto' in h[0]:
                    print 'legend',h[0]
                    leg.SetX1NDC(0.55)
                    leg.SetX2NDC(0.75)
                    leg.SetY1NDC(0.65)
                    leg.SetY2NDC(0.85)
                    leg.Draw()
                                   
        if not os.path.exists(outputdir+foldername+'/'):
            os.makedirs(outputdir+foldername+'/')
       
        c.SaveAs(outputdir+foldername+'/'+h[0]+'.png')
        c.SaveAs(outputdir+foldername+'/'+h[0]+'.pdf')

            
outfile.Write()
outfile.Close()
                
