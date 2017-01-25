import os
import ROOT
import array

import pdb

ROOT.gROOT.SetBatch(1)
ROOT.gStyle.SetOptStat(0)
#ROOT.gStyle.SetOptTitle(0)

canvas=ROOT.TCanvas()
leg = ROOT.TLegend (0.7,0.32,0.85, 0.12)
leg.SetFillColor(0)
leg = ROOT.TLegend (0.7,0.32,0.85, 0.12)
leg.SetFillColor(0)
leg2 = ROOT.TLegend (0.7,0.52,0.85, 0.12)
leg2.SetFillColor(0)

#pdb.set_trace()
for file in os.listdir("results/LFVtrilepton_oct31/mmefakerate_fits/"):
    if file.endswith("_canvas.root"):
        if '_vs_' in file:
            if not ( 'eVLoose_eVTight' in file or  'eSuperLoose_eVTight' in file): continue
            filepath='results/LFVtrilepton_oct31/mmefakerate_fits/'+file
            myFF = ROOT.TFile.Open(filepath)

            leg.Clear()
            
            testE=myFF.Get("testE")
            testE.SetMarkerColor(2)
            testE.SetLineColor(2)
            testE.SetFillColor(2)
            testE.SetFillStyle(3001)
            testE.SetMarkerStyle(20)
            testE.SetMarkerSize(0.3)
            testE.Draw("E2")


            funEUp0=myFF.Get("funEUp0")
            funEUp1=myFF.Get("funEUp1")
            funEDw0=myFF.Get("funEDw0")
            funEDw1=myFF.Get("funEDw1")

            funEUp0.Draw("SAME")
            leg.AddEntry(funEUp0,"P0+errP0", "l")
            funEDw0.Draw("SAME")
            leg.AddEntry(funEDw0,"P0-errP0", "l")
            testE.SetTitle("par0")
            if funEUp1 :
                testE.SetTitle("par0+par1*x")
                funEUp1.Draw("SAME")
                leg.AddEntry(funEUp1,"P1+errP1", "l")

            if funEDw1 :
                funEDw1.Draw("SAME")
                leg.AddEntry(funEDw1,"P1-errP1", "l")

            graph=myFF.Get("den_endcap2_clone")

            graph.Draw("P")
            testE.GetXaxis().SetRangeUser(10,200)
            testE.GetYaxis().SetRangeUser(0,1.1)

            leg.Draw()
            canvas.Update()
            canvas.SaveAs(filepath.replace("_canvas.root","endcap_parVariation.png"))
            canvas.SaveAs(filepath.replace("_canvas.root","endcap_parVariation.pdf"))

            canvas.Clear()
            leg2.Clear()
            
            testB=myFF.Get("testB")
            testB.SetMarkerColor(2)
            testB.SetLineColor(2)
            testB.SetFillColor(2)
            testB.SetFillStyle(3001)
            testB.SetMarkerStyle(20)
            testB.SetMarkerSize(0.3)
            testB.Draw("E2")
            testB.GetXaxis().SetRangeUser(10,200)
            testB.GetYaxis().SetRangeUser(0,1.1)
            testB.SetTitle("par0+par1*TMath::Erf(par2*x-par3)")

            funUp0=myFF.Get("funUp0")
            funUp1=myFF.Get("funUp1")
            funUp2=myFF.Get("funUp2")
            funUp3=myFF.Get("funUp3")
            funDw0=myFF.Get("funDw0")
            funDw1=myFF.Get("funDw1")
            funDw2=myFF.Get("funDw2")
            funDw3=myFF.Get("funDw3")

            funUp0.Draw("SAME")
            leg2.AddEntry(funUp0,"P0+errP0", "l")
            funDw0.Draw("SAME")
            leg2.AddEntry(funDw0,"P0-errP0", "l")
            funUp1.Draw("SAME")
            leg2.AddEntry(funUp1,"P1+errP1", "l")
            funDw1.Draw("SAME")
            leg2.AddEntry(funDw1,"P1-errP1", "l")
            funUp2.Draw("SAME")
            leg2.AddEntry(funUp2,"P2+errP2", "l")
            funDw2.Draw("SAME")
            leg2.AddEntry(funDw2,"P2-errP2", "l")
            funUp3.Draw("SAME")
            leg2.AddEntry(funUp3,"P3+errP3", "l")
            funDw3.Draw("SAME")
            leg2.AddEntry(funDw3,"P3-errP3", "l")

            graph=myFF.Get("den_barrel1_clone")
            graph.Draw("P")

            leg2.Draw()
            canvas.Update()
            canvas.SaveAs(filepath.replace("_canvas.root","barrel_parVariation.png"))
            canvas.SaveAs(filepath.replace("_canvas.root","barrel_parVariation.pdf"))
