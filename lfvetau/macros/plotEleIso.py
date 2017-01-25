import ROOT
from array import array


ROOT.gROOT.SetBatch(1)
ROOT.gStyle.SetOptStat(0)


file0 = ROOT.TFile.Open("../results/LFVtrilepton_oct31/MMEAnalyzer/data.root")

h_SL = file0.Get("os/eSuperLoose/eIsoDB03_vs_ePt")
h_VT = file0.Get("os/eVTight/eIsoDB03_vs_ePt")

xbins=[0, 10, 20, 30, 40, 50, 70, 100, 200]
xArray = array('d',xbins)

ybins=[]
for i in range (0, 26):
    ybins.append(i*0.04)
yArray = array('d',ybins)

hh_SL =  ROOT.TH2F("superLoose", "e RelIso<1", 8, xArray, 25, yArray )
hh_VT =  ROOT.TH2F("VTight", "e RelIso<0.1", 8, xArray, 25, yArray )

hh_SL.Reset()
hh_VT.Reset()
#for xbin in range (1, 9):
#    for ybin in range(1, 26):
#        print 'new SL histo', hh_SL.GetBinContent(xbin, ybin)
        

for xbin in range(1, h_SL.GetXaxis().GetNbins()+1):
    for ybin in range(1, 26):
        ibin = h_SL.GetBin(xbin, ybin)
        x=h_SL.GetXaxis().GetBinCenter(xbin)
        y=h_SL.GetYaxis().GetBinCenter(ybin)
        w=h_SL.GetBinContent(xbin, ybin)

        xbinnew = hh_SL.GetXaxis().FindBin(x)
        ybinnew = hh_SL.GetYaxis().FindBin(y)
        fixbinnew = hh_SL.FindFixBin(x,y)

        if xbinnew==8 and ybinnew==1: print x, y, xbin, ybin, xbinnew, ybinnew,  w, hh_SL.GetBinContent(fixbinnew)
        hh_SL.Fill(x, y, w)

        ibin = h_VT.GetBin(xbin, ybin)
        x=h_VT.GetXaxis().GetBinCenter(xbin)
        y=h_VT.GetYaxis().GetBinCenter(ybin)
        w=h_VT.GetBinContent(xbin, ybin)
        hh_VT.Fill(x, y, w)

c=ROOT.TCanvas()
c.Draw()
ratio=hh_SL.Clone()
ratio1=hh_VT.Clone()

ratio.Divide(hh_VT)
ratio1.Divide(hh_SL)


h_VT.Draw("COLZ")
h_VT.GetZaxis().SetRangeUser(0, 20)
h_VT.GetXaxis().SetTitle("e p_{T} GeV")
h_VT.GetYaxis().SetTitle("e RelIso")
c.Update()
c.SaveAs("eRelIso_lt0p1.pdf")

c.Clear()
h_SL.Draw("COLZ")
h_SL.GetZaxis().SetRangeUser(0, 20)
h_SL.GetXaxis().SetTitle("e p_{T} GeV")
h_SL.GetYaxis().SetTitle("e RelIso")
c.Update()
c.SaveAs("eRelIso_lt1.pdf")

c.Clear()
hh_SL.Draw("COLZ")
hh_SL.GetZaxis().SetRangeUser(0,100)
hh_SL.GetXaxis().SetTitle("e p_{T} GeV")
hh_SL.GetYaxis().SetTitle("e RelIso")

c.Update()
c.SaveAs("eRelIso_lt1_rebinned.pdf")

c.Clear()
hh_VT.Draw("COLZ")
hh_VT.GetZaxis().SetRangeUser(0,100)
hh_VT.GetXaxis().SetTitle("e p_{T} GeV")
hh_VT.GetYaxis().SetTitle("e RelIso")
c.Update()
c.SaveAs("eRelIso_lt0p1_rebinned.pdf")

        

c.Clear()
ratio.Draw("COLZ")
ratio.GetZaxis().SetRangeUser(0,5)
ratio.GetXaxis().SetTitle("e p_{T} GeV")
ratio.GetYaxis().SetTitle("e RelIso")
c.Update()

c.SaveAs("SLoose_over_VTight.pdf")

c.Clear()
ratio1.Draw("COLZ")
ratio1.GetZaxis().SetRangeUser(0.,1.2)
ratio1.GetXaxis().SetTitle("e p_{T} GeV")
ratio1.GetYaxis().SetTitle("e RelIso")
c.Update()

c.SaveAs("VTight_over_SLoose.pdf")

c.Clear()
SLpt=hh_SL.ProjectionX("SL_pt", 0, -1, "e")
SLpt.Draw("E")
c.SetLogy(1)
SLpt.GetXaxis().SetTitle("e p_{T} GeV")
c.Update()

VTpt=hh_VT.ProjectionX("VT_pt", 0, -1, "e")
VTpt.Draw("ESAME")
VTpt.SetLineColor(2)
VTpt.SetMarkerColor(2)
VTpt.SetMarkerStyle(20)
c.Update()
c.SaveAs("SL_VT_pt_comparison.pdf")


for ibin in range(1, VTpt.GetXaxis().GetNbins()+1):
    print '%.1f & %.1f &%.1f\\\\\hline' %(VTpt.GetXaxis().GetBinCenter(ibin), SLpt.GetBinContent(ibin), VTpt.GetBinContent(ibin))
