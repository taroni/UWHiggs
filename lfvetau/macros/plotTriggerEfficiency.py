import ROOT
import os

from yellowhiggs import xs, br, xsbr

c = ROOT.TCanvas()
c.Draw()
ROOT.gROOT.SetBatch(True)

selstr=''
#selstr='mutausel/'
numdir='./'

lepton='t'
trigger='mu19Tau20'
leg = ROOT.TLegend(0.6, 0.3, 0.85, 0.15)
#leg = ROOT.TLegend(0.6, 0.85, 0.85, 0.7)


jobid = os.environ['jobid']
filepath = 'results/'+ jobid+'/TriggerAnalyzer/'
outpath="plots/"+jobid+"/TriggerAnalyzer/"

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

ggxstt =43.92*br(125, 'tautau')[0]
vbfxstt=3.748*br(125, 'tautau')[0]

ggmpt = ggHmt.Get(numdir+'mPt')
ggtpt = ggHmt.Get(numdir+'%sPt' %lepton)
gghpt = ggHmt.Get(numdir+'genpT')

mu22_ggmpt= ggHmt.Get('mu22/'+selstr+'mPt')
mu22_ggtpt= ggHmt.Get('mu22/'+selstr+'%sPt' %lepton)
mu22_gghpt= ggHmt.Get('mu22/'+selstr+'genpT')

mu22er_ggmpt= ggHmt.Get('mu22er/'+selstr+'mPt')
mu22er_ggtpt= ggHmt.Get('mu22er/'+selstr+'%sPt' %lepton)
mu22er_gghpt= ggHmt.Get('mu22er/'+selstr+'genpT')

mu19tau20_ggmpt= ggHmt.Get(trigger+'/'+selstr+'mPt' )
mu19tau20_ggtpt= ggHmt.Get(trigger+'/'+selstr+'%sPt' %lepton )
mu19tau20_gghpt= ggHmt.Get(trigger+'/'+selstr+'genpT' )


vbfmpt= vbfHmt.Get(numdir+'mPt')
vbftpt= vbfHmt.Get(numdir+'%sPt' %lepton)
vbfhpt= vbfHmt.Get(numdir+'genpT')

mu22_vbfmpt= vbfHmt.Get('mu22/'+selstr+'mPt')
mu22_vbftpt= vbfHmt.Get('mu22/'+selstr+'%sPt' %lepton)
mu22_vbfhpt= vbfHmt.Get('mu22/'+selstr+'genpT')

mu22er_vbfmpt= vbfHmt.Get('mu22er/'+selstr+'mPt')
mu22er_vbftpt= vbfHmt.Get('mu22er/'+selstr+'%sPt' %lepton)
mu22er_vbfhpt= vbfHmt.Get('mu22er/'+selstr+'genpT')

mu19tau20_vbfmpt= vbfHmt.Get(trigger+'/'+selstr+'mPt')
mu19tau20_vbftpt= vbfHmt.Get(trigger+'/'+selstr+'%sPt' %lepton)
mu19tau20_vbfhpt= vbfHmt.Get(trigger+'/'+selstr+'genpT')



vbfmpt.Scale(512662.137122/24681914.331)
vbftpt.Scale(512662.137122/24681914.331)
vbfhpt.Scale(512662.137122/24681914.331)

mu22_vbfmpt.Scale(512662.137122/24681914.331)
mu22_vbftpt.Scale(512662.137122/24681914.331)
mu22_vbfhpt.Scale(512662.137122/24681914.331)

mu22er_vbfmpt.Scale(512662.137122/24681914.331)
mu22er_vbftpt.Scale(512662.137122/24681914.331)
mu22er_vbfhpt.Scale(512662.137122/24681914.331)

mu19tau20_vbfmpt.Scale(512662.137122/24681914.331)
mu19tau20_vbftpt.Scale(512662.137122/24681914.331)
mu19tau20_vbfhpt.Scale(512662.137122/24681914.331)


ggmpt.Add(vbfmpt)
ggtpt.Add(vbftpt)
gghpt.Add(vbfhpt)

mu22_ggmpt.Add(mu22_vbfmpt)
mu22_ggtpt.Add(mu22_vbftpt)
mu22_gghpt.Add(mu22_vbfhpt)

mu22er_ggmpt.Add(mu22er_vbfmpt)
mu22er_ggtpt.Add(mu22er_vbftpt)
mu22er_gghpt.Add(mu22er_vbfhpt)

mu19tau20_ggmpt.Add(mu19tau20_vbfmpt)
mu19tau20_ggtpt.Add(mu19tau20_vbftpt)
mu19tau20_gghpt.Add(mu19tau20_vbfhpt)

eff22mpt=ROOT.TEfficiency(mu22_ggmpt, ggmpt)
eff22mpt.SetName("eff22mPt")
eff22tpt=ROOT.TEfficiency(mu22_ggtpt, ggtpt)
eff22tpt.SetName("eff22tPt")
eff22hpt=ROOT.TEfficiency(mu22_gghpt, gghpt)
eff22hpt.SetName("eff22hPt")

eff22ermpt=ROOT.TEfficiency(mu22er_ggmpt, ggmpt)
eff22ermpt.SetName("eff22ermPt")
eff22ertpt=ROOT.TEfficiency(mu22er_ggtpt, ggtpt)
eff22ertpt.SetName("eff22ertPt")
eff22erhpt=ROOT.TEfficiency(mu22er_gghpt, gghpt)
eff22erhpt.SetName("eff22erhPt")


eff19tau20mpt=ROOT.TEfficiency(mu19tau20_ggmpt, ggmpt)
eff19tau20mpt.SetName("eff%smPt" %trigger)
eff19tau20tpt=ROOT.TEfficiency(mu19tau20_ggtpt, ggtpt)
eff19tau20tpt.SetName("eff%s%sPt" %(trigger,lepton))
eff19tau20hpt=ROOT.TEfficiency(mu19tau20_gghpt, gghpt)
eff19tau20hpt.SetName("eff%shPt"%(trigger))



c.cd()
c.Clear()
eff22mpt.Paint("P")
eff22ermpt.Paint("P")
eff19tau20mpt.Paint("P")
h = eff22mpt.GetPaintedGraph().Clone()
h.Draw("APE")
h.SetMarkerStyle(20)
h.GetXaxis().SetTitle("#mu p_{T}")
h.GetYaxis().SetRangeUser(0.,1.)
h1=eff22ermpt.GetPaintedGraph().Clone()
h1.Draw("PESAME")
h1.SetMarkerStyle(20)
h1.SetMarkerColor(2)
h1.SetLineColor(2)
h2=eff19tau20mpt.GetPaintedGraph().Clone()
h2.Draw("PESAME")
h2.SetMarkerStyle(20)
h2.SetMarkerColor(4)
h2.SetLineColor(4)


leg.AddEntry(h, "HLT_Iso(Tk)Mu22", "lp")
leg.AddEntry(h1, "HLT_Iso(Tk)Mu22eta2p1", "lp")
leg.AddEntry(h2, "HLT_Mu19Tau20(SingleL1)", "lp")
leg.Draw()

selstr=selstr[:len(selstr)-1] if selstr.endswith('/') else selstr

c.Update()
c.SaveAs(outpath+selstr+'effmpt.png')
c.SaveAs(outpath+selstr+'effmpt.pdf')

c.Clear()
eff22tpt.Paint("AP")
eff22ertpt.Paint("AP")
eff19tau20tpt.Paint("AP")

th = eff22tpt.GetPaintedGraph().Clone()
th.Draw("APE")

th.SetMarkerStyle(20)
th.GetXaxis().SetTitle("#tau p_{T}")

th.GetYaxis().SetRangeUser(0.,1.)
th1=eff22ertpt.GetPaintedGraph().Clone()
th1.Draw("PE")
th1.SetMarkerStyle(20)
th1.SetMarkerColor(2)
th1.SetLineColor(2)
th2=eff19tau20tpt.GetPaintedGraph().Clone()
th2.Draw("PE")
th2.SetMarkerStyle(20)
th2.SetMarkerColor(4)
th2.SetLineColor(4)

leg.Draw()

c.Update()
c.SaveAs(outpath+selstr+'eff%spt.png' %lepton)
c.SaveAs(outpath+selstr+'eff%spt.pdf' %lepton)


c.Clear()
eff22hpt.Paint("AP")
eff22erhpt.Paint("AP")
eff19tau20hpt.Paint("AP")

hh = eff22hpt.GetPaintedGraph().Clone()
hh.Draw("APE")
hh.GetYaxis().SetRangeUser(0.,1.)

hh.SetMarkerStyle(20)
hh.GetXaxis().SetTitle("Higgs p_{T}")
hh1=eff22erhpt.GetPaintedGraph().Clone()
hh1.Draw("PE")
hh1.SetMarkerStyle(20)
hh1.SetMarkerColor(2)
hh1.SetLineColor(2)
hh2=eff19tau20hpt.GetPaintedGraph().Clone()
hh2.Draw("PE")
hh2.SetMarkerStyle(20)
hh2.SetMarkerColor(4)
hh2.SetLineColor(4)

leg.Draw()

c.Update()
c.SaveAs(outpath+selstr+'effhpt.png')
c.SaveAs(outpath+selstr+'effhpt.pdf')




