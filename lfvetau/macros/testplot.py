import ROOT
import os

c = ROOT.TCanvas()
c.Draw()
ROOT.gROOT.SetBatch(True)

#selstr=''
selstr='muesel'
numdir='./'


lepton = 'e'
trigger='mu23ele12'

#leg = ROOT.TLegend(0.6, 0.3, 0.85, 0.15)
leg = ROOT.TLegend(0.6, 0.85, 0.85, 0.7)

jobid = os.environ['jobid']
filepath = 'results/'+ jobid+'/TriggerAnalyzerME/'
outpath="plots/"+jobid+"/TriggerAnalyzerME/"

#ggHtt = ROOT.TFile.Open(filepath+'GluGluHToTauTau_M125_13TeV_powheg_pythia8.root')
#vbfHtt = ROOT.TFile.Open(filepath+'VBFHToTauTau_M125_13TeV_powheg_pythia8.root')

ggHmt = ROOT.TFile.Open(filepath+'GluGlu_LFV_HToMuTau_M125_13TeV_powheg_pythia8.root')
vbfHmt = ROOT.TFile.Open(filepath+'VBF_LFV_HToMuTau_M125_13TeV_powheg_pythia8.root')

ggttLumi=488268.26999
vbfttLumi=23396920.1213

ggmtLumi =512662.137122
vbfmtLumi=24681914.331

ggxsLFV =43.92*0.01
vbfxsLFV=3.748*0.01


ggmpt = ggHmt.Get(numdir+'mPt')
ggtpt = ggHmt.Get(numdir+'%sPt' %lepton)
gghpt = ggHmt.Get(numdir+'genpT')
ggmpt.SetName("den_mPt")
ggtpt.SetName("den_ePt")
gghpt.SetName("den_hPt")

print 'mu23ele8/%s/mPt' %selstr
mu23e8_ggmpt = ggHmt.Get('mu23ele8/%s/mPt' %selstr)
mu23e8_ggept = ggHmt.Get('mu23ele8/%s/ePt' %selstr)
mu23e8_gghpt = ggHmt.Get('mu23ele8/%s/genpT' %selstr)
mu23e8_ggmpt.SetName('mu23ele8'+selstr+'mPt' )
mu23e8_ggept.SetName('mu23ele8'+selstr+'ePt' )
mu23e8_gghpt.SetName('mu23ele8'+selstr+'genpT' )

vbfmpt= vbfHmt.Get(numdir+'mPt')
vbftpt= vbfHmt.Get(numdir+'%sPt' %lepton)
vbfhpt= vbfHmt.Get(numdir+'genpT')
vbfmpt.SetName('vbf_denmPt')
vbftpt.SetName('vbf_den%sPt' %lepton)
vbfhpt.SetName('vbf_dengenpT')

mu23e8_vbfmpt = vbfHmt.Get('mu23ele8/%s/mPt' %selstr )
mu23e8_vbfept = vbfHmt.Get('mu23ele8/%s/ePt' %selstr)
mu23e8_vbfhpt = vbfHmt.Get('mu23ele8/%s/genpT' %selstr)
mu23e8_vbfmpt.SetName('vbfmu23ele8'+selstr+'mPt' )
mu23e8_vbfept.SetName('vbfmu23ele8'+selstr+'ePt' )
mu23e8_vbfhpt.SetName('vbfmu23ele8'+selstr+'genpT' )


vbfmpt.Scale(512662.137122/24681914.331)
vbftpt.Scale(512662.137122/24681914.331)
vbfhpt.Scale(512662.137122/24681914.331)

mu23e8_vbfmpt.Scale(512662.137122/24681914.331)
mu23e8_vbfept.Scale(512662.137122/24681914.331)
mu23e8_vbfhpt.Scale(512662.137122/24681914.331)

ggmpt.Add(vbfmpt)
ggtpt.Add(vbftpt)
gghpt.Add(vbfhpt)

mu23e8_ggmpt.Add(mu23e8_vbfmpt)
mu23e8_ggept.Add(mu23e8_vbfept)
mu23e8_gghpt.Add(mu23e8_vbfhpt)


ggmpt.Draw()
c.SaveAs(outpath+selstr+'den.png')
mu23e8_ggmpt.Draw()
c.SaveAs(outpath+selstr+'num.png')


eff23e8mpt=ROOT.TEfficiency(mu23e8_ggmpt, ggmpt)
eff23e8mpt.SetName("eff23e8mPt")
eff23e8ept=ROOT.TEfficiency(mu23e8_ggept, ggtpt)
eff23e8ept.SetName("eff23e8%sPt" %(lepton))
eff23e8hpt=ROOT.TEfficiency(mu23e8_gghpt, gghpt)
eff23e8hpt.SetName("eff23e8hPt")


c.cd()
c.Clear()
eff23e8mpt.Draw("AP")
#h3=eff23e8mpt.CreateGraph().Clone()
#h3=eff23e8mpt.GetPaintedGraph().Clone()
c.Clear()

h3=eff23e8mpt.Clone()
h3.Draw("APE")
h3.SetMarkerStyle(20)
h3.SetMarkerColor(6)
h3.SetLineColor(6)


leg.AddEntry(h3, "HLT_Mu23Ele8", "lp")

leg.Draw()


c.Update()
c.SaveAs(outpath+selstr+'effmpt.png')
c.SaveAs(outpath+selstr+'effmpt.pdf')
