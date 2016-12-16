import os
import ROOT

c = ROOT.TCanvas()
c.Draw()
ROOT.gROOT.SetBatch(True)

for file in os.listdir("results/LFVtrilepton_oct31/mmefakerate_fits/"):
    if file.endswith("_canvas.root"):
        if '_vs_' in file:
            filepath='results/LFVtrilepton_oct31/mmefakerate_fits/'+file

            myFF = ROOT.TFile.Open(filepath)

            c.Clear()
            c.cd()

            eff = myFF.Get("efficiency")

            eff.Paint("COLZ")
            c.Update()
            h=eff.GetPaintedHistogram().Clone()
            
            h.Draw("COLZ")
            #h.GetZaxis().SetRangeUser(0., 1.)
            
            h.GetXaxis().SetTitle("p_{T} [GeV]")
            h.GetYaxis().SetTitle("|#eta|")
            c.Update()
            c.SaveAs(filepath.replace(".root", ".png"))
            c.SaveAs(filepath.replace(".root", ".pdf"))

            
