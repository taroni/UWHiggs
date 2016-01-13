import ROOT

_file0 = ROOT.TFile.Open("~/Downloads/t_os_tLoose_tTigh_tDecayMode.corrected_inputs.root")
numerator = _file0.Get("numerator")
denominator = _file0.Get("denominator") 
canvas=ROOT.TCanvas()
pEff = ROOT.TEfficiency (numerator, denominator)
pEff.Draw()
graph =  pEff.CreateGraph()
graph.Draw('AP')
graph.GetXaxis().SetRangeUser(30, 200)
graph.GetYaxis().SetRangeUser(0, 1.2)
graph.GetXaxis().SetTitle("#tau DM")
graph.GetYaxis().SetTitle("fakerate")

canvas.SaveAs("fakerate_noFit.pdf")
canvas.SaveAs("fakerate_noFit.png")
