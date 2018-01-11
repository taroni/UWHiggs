import ROOT
import os

ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)

fileFastname='ggM200ETau.root'
fileFullname='GluGlu_LFV_HToETau_M200_13TeV_powheg_pythia8_v6-v1.root'

resultpath = 'results/LFV_HighMass/ETauAnalyzer/'

fileFast = ROOT.TFile.Open(resultpath+fileFastname)
fileFull = ROOT.TFile.Open(resultpath+fileFullname)

outputdir = 'plots/LFV_HighMass/ETauAnalyzer/FastFullSim/et/'
if not os.path.exists(outputdir):
    os.makedirs(outputdir)


foldernames=['os/le1', 'os/0', 'os/1', 'os/LowMass/le1', 'os/LowMass/0', 'os/LowMass/1']
histoname = [('ePt', 'e p_{T} (GeV)', 1), ('ePhi','e #phi',1) ,('eEta','e #eta',1),('eComesFromHiggs', 'eComesFromHiggs', 1), 
             ('tPt','#tau p_{T} (GeV)',1) ,('tPhi','#tau #phi',1), ('tEta','#tau #eta',1),('tDecayMode', '#tau decayMode', 1),('tGenDecayMode', '#tau Gen decayMode', 1), ('tComesFromHiggs', 'tComesFromHiggs',1), 
             ('e_t_DPhi','#Delta#phi(e,#tau)',1), ('e_t_DR','#DeltaR(e,#tau)',1), ('e_t_Mass', 'e-#tau Visible Mass (GeV)',1),
             ('type1_pfMetEt', 'type1PF MET (GeV)', 1) , ('type1_pfMetPhi', 'type1PFMET Phi (GeV)', 1) , 
             ('ePFMET_DeltaPhi','#Delta#phi(e, MET)', 1),  ('eMtToPfMet_type1','M_{T}(e,MET) (GeV) ',1),
             ('tPFMET_DeltaPhi','#Delta#phi(#tau, MET)',2),('tMtToPfMet_type1','M_{T}(#tau, MET) (GeV)',1),
             ('e_t_PZeta', 'e_t_PZeta', 1), ('e_t_PZetaLess0p85PZetaVis', 'e_t_PZetaLess0p85PZetaVis', 1), ('e_t_PZetaVis', 'e_t_PZetaVis', 1),
             ("jetVeto30", "Number of jets, p_{T}>30", 1),
             ("h_collmass_pfmet", "M_{coll} [GeV]", 1), ("nvtx", "number of vertices", 1),
             ('eGenPt', 'e [gen] p_{T} (GeV)', 1), ('eGenPhi','e [gen] #phi',1) ,('eGenEta','e [gen] #eta',1),
             ('tGenPt','#tau [gen] p_{T} (GeV)',1) ,('tGenPhi','#tau [gen] #phi',1), ('tGenEta','#tau [gen] #eta',1)
]

leg=ROOT.TLegend(0.65, 0.85, 0.8, 0.75)
canvas = ROOT.TCanvas()
for foldername in foldernames:
    for n,h in enumerate(histoname) :

        hfast = fileFast.Get(foldername+'/'+h[0]).Clone()
        hfast.SetName(h[0]+'_fast')
        #hfast.Scale(10./6.1)
        hfast.Scale(1./hfast.Integral())
        hfast.Rebin(h[2])
        hfast.Draw('HIST')
        hfast.SetLineColor(2)
        hfast.SetLineWidth(2)
        hfast.GetXaxis().SetTitle(h[1])
        if 'Pt' in h[0] or h[0] == 'type1_pfMetEt': hfast.GetXaxis().SetRangeUser(0,300)
        leg.AddEntry(hfast, 'FastSim', "l")
        hmax=hfast.GetBinContent(hfast.GetMaximumBin())
    

        hfull = fileFull.Get(foldername+'/'+h[0])
        hfull.Scale(1./hfull.Integral())
        hfull.Rebin(h[2])

        bincontentmax = hfull.GetBinContent(hfull.GetMaximumBin())
        if hmax < bincontentmax : hmax = bincontentmax

        hfast.GetYaxis().SetRangeUser(0, hmax*1.2)
        
        hfull.Draw("SAMEHIST")
        hfull.SetLineWidth(2)
        hfull.SetLineStyle(2)
        if not os.path.exists(outputdir+foldername):
            os.makedirs(outputdir+foldername)
        leg.AddEntry(hfull, 'FullSim', "l")
        leg.Draw()

        
        canvas.SaveAs(outputdir+foldername+'/'+h[0]+'.png')
        canvas.SaveAs(outputdir+foldername+'/'+h[0]+'.pdf')
        if 'Decay' in h[0]: canvas.SaveAs(outputdir+foldername+'/'+h[0]+'.root')

        canvas.Clear()
        leg.Clear()
        
