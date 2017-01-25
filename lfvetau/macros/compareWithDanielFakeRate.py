import ROOT
import math
import numpy as np
from array import array

danielFF = ROOT.TFile.Open("fakerate2D_Ele_Daniel.root")
myFF = ROOT.TFile.Open("results/LFVtrilepton_oct31/mmefakerate_fits/e_os_eSSuperLoose_eVTight_Met30_eAbsEta_vs_ePt.corrected_inputs.root")

h_effDaniel=danielFF.Get("Ele_fakerate")


num = myFF.Get("numerator")
den = myFF.Get("denominator")

eff = ROOT.TEfficiency(num, den)
eff.SetName('effSilvia')

outfile=ROOT.TFile("results/LFVtrilepton_oct31/mmefakerate_fits/e_os_eSSuperLoose_eVTight_Met30_eAbsEta_vs_ePt_canvas.root", "RECREATE")
outfile.cd()
eff.Write()
oufile.Close()


#c1=ROOT.TCanvas()
#eff.Draw('COLZ')
#effDaniel.Draw('COLZ')

effSilvia =[]
effSilviaErrUp=[]
effSilviaErrDw=[]


effDaniel = []
effDanielErrUp=[]
effDanielErrDw=[]

print num.GetXaxis().GetNbins()+1, num.GetYaxis().GetNbins()+1

for y in range(1, num.GetYaxis().GetNbins()+1):
    for x in range(1, num.GetXaxis().GetNbins()+1):
        effSilvia.append(eff.GetEfficiency(num.GetBin(x,y)))
        print num.GetXaxis().GetBinCenter(x), num.GetYaxis().GetBinCenter(y), eff.GetEfficiency(num.GetBin(x,y))
        effSilviaErrUp.append(eff.GetEfficiencyErrorUp(num.GetBin(x,y)))
        effSilviaErrDw.append(eff.GetEfficiencyErrorLow(num.GetBin(x,y)))
        #errSilvia = math.sqrt(effSilviaErrUp*effSilviaErrUp+effSilviaErrDw*effSilviaErrDw)

for y in range(1, h_effDaniel.GetYaxis().GetNbins()+1):
    for x in range(1, h_effDaniel.GetXaxis().GetNbins()+1):
        if h_effDaniel.GetBinContent(h_effDaniel.GetBin(x,y))>=0:
            effDaniel.append(h_effDaniel.GetBinContent(h_effDaniel.GetBin(x,y)))
        else:
            effDaniel.append(h_effDaniel.GetBinContent(0))
        print h_effDaniel.GetXaxis().GetBinCenter(x), h_effDaniel.GetYaxis().GetBinCenter(y), h_effDaniel.GetBinContent(h_effDaniel.GetBin(x,y))
        #print x,y, effDaniel
        
        effDanielErrUp.append(h_effDaniel.GetBinErrorUp(x,y))
        effDanielErrDw.append(h_effDaniel.GetBinErrorLow(x,y))

print h_effDaniel.GetXaxis().GetNbins()+1,h_effDaniel.GetYaxis().GetNbins()+1
print len(effSilvia), len(effDaniel)

for n, eff in enumerate(effSilvia):

    errSilvia = math.sqrt(effSilviaErrUp[n]*effSilviaErrUp[n]+effSilviaErrDw[n]*effSilviaErrDw[n])
    errDaniel = math.sqrt(effDanielErrUp[n]*effDanielErrUp[n]+effDanielErrDw[n]*effDanielErrDw[n])

    reldiff = (effSilvia[n]-effDaniel[n])/math.sqrt(errDaniel*errDaniel+errSilvia*errSilvia)


    #print 'Silvia:', effSilvia[n], '+', effSilviaErrUp[n], '/ -',effSilviaErrDw[n], ', Daniel:', effDaniel[n], '+', effDanielErrUp[n], '/ -', effDanielErrDw[n]
    #print n, reldiff




effSilviaX = [5,12.5,17.5,22.5,27.5,35,45, 60, 85, 150 ]
errSilviaX = [5, 2.5, 2.5, 2.5, 2.5, 5, 5, 10, 15, 50]

for n, eff in enumerate(effSilvia):
    if n==0: continue
    if n  > 9 : continue
    effSilvia_array = np.asarray(effSilvia[n])
    effDaniel_array = np.asarray(effDaniel[n])
    errSilviaUp_array = np.asarray(effSilviaErrUp[n])

    errSilviaDw_array = np.asarray(effSilviaErrDw[n])
    errDanielUp_array = np.asarray(effDanielErrUp[n])
    errDanielDw_array = np.asarray(effDanielErrDw[n])



grSilvia = ROOT.TGraphAsymmErrors(len(effSilvia[1:10]), array('d', effSilviaX[1:10]), array('d', effSilvia[1:10]), array('d', errSilviaX[1:10]), array('d', errSilviaX[1:10]), array('d', effSilviaErrDw[1:10]), array('d', effSilviaErrUp[1:10]))
grDaniel = ROOT.TGraphAsymmErrors(len(effDaniel[1:10]), array('d', effSilviaX[1:10]), array('d', effDaniel[1:10]), array('d', errSilviaX[1:10]), array('d', errSilviaX[1:10]), array('d', effDanielErrDw[1:10]), array('d', effDanielErrUp[1:10]))

print effSilvia[1:10]
print effDaniel[1:10]
print effSilviaX[1:10]
c=ROOT.TCanvas()

leg = ROOT.TLegend(0.2, 0.7, 0.35, 0.85)
leg.AddEntry(grSilvia, "Silvia", "pl")
leg.AddEntry(grDaniel, "Daniel", "pl")

grSilvia.SetTitle("Barrel")

grSilvia.SetMarkerStyle(20)
grSilvia.SetMarkerSize(1)
grSilvia.Draw("AP")
grSilvia.SetMaximum(1.1)
grSilvia.SetMinimum(0.)


grDaniel.SetMarkerStyle(20)
grDaniel.SetMarkerColor(2)
grDaniel.SetLineColor(2)

grDaniel.Draw("P")

leg.Draw()

c.SaveAs("fakerate_EB_comparisonDaniel.png")

c.SaveAs("fakerate_EB_comparisonDaniel.pdf")

c.Clear()

grSilviaEE = ROOT.TGraphAsymmErrors(len(effSilvia[11:20]), array('d', effSilviaX[1:10]), array('d', effSilvia[11:20]), array('d', errSilviaX[1:10]), array('d', errSilviaX[1:10]), array('d', effSilviaErrDw[11:20]), array('d', effSilviaErrUp[11:20]))
grDanielEE = ROOT.TGraphAsymmErrors(len(effDaniel[11:20]), array('d', effSilviaX[1:10]), array('d', effDaniel[11:20]), array('d', errSilviaX[1:10]), array('d', errSilviaX[1:10]), array('d', effDanielErrDw[11:20]), array('d', effDanielErrUp[11:20]))

grSilviaEE.SetTitle("Endcap")
grSilviaEE.SetMarkerStyle(20)
grSilviaEE.SetMarkerSize(1)
grSilviaEE.Draw("AP")
grSilviaEE.SetMaximum(1.1)
grSilviaEE.SetMinimum(0.)
        
        
grDanielEE.SetMarkerStyle(20)
grDanielEE.SetMarkerColor(2)
grDanielEE.SetLineColor(2)

grDanielEE.Draw("P")

leg.Draw()

c.SaveAs("fakerate_EE_comparisonDaniel.png")

c.SaveAs("fakerate_EE_comparisonDaniel.pdf")

