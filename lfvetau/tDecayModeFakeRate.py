import ROOT
import os

ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(False)
dirpath = 'results/%s/fakerate_fits/' %(os.environ['jobid'])
files=[]
for name in os.listdir(dirpath):
    if 'tDecayMode' not in name: continue
    if '.root' not in name: continue
    if os.path.isfile(os.path.join(dirpath, name)):
        files.append(os.path.join(dirpath, name))

canvas=ROOT.TCanvas()
canvas.Draw()
for name in files:
    myfile = ROOT.TFile.Open(name, "READ")
    num=myfile.Get("numerator")
    den=myfile.Get("denominator")

    fakerate=num.Clone()
    fakerate.Divide(den)

    fit_configuration = name[name.rindex('/'):].split("_")
    sign = fit_configuration[1]
    denom = fit_configuration[2]
    num = fit_configuration[3]
    var = fit_configuration[4]

    titlename="%s/%s" %(num, denom)
    
    canvas.Clear()
    canvas.cd()
    fakerate.SetTitle(titlename)
    
    fakerate.Draw()
    fakerate.GetYaxis().SetRangeUser(0, 1)
    pt = ROOT.TPaveText(7,.98,11.,.7);
    for ibin in range(0, fakerate.GetXaxis().GetNbins()):
        if fakerate.GetBinContent(ibin+1) == 0 : continue
        #print ibin, fakerate.GetBinContent(ibin+1)
        pt.AddText("DM %s: %.3f #pm %.3f" %(ibin,  fakerate.GetBinContent(ibin+1), fakerate.GetBinError(ibin+1)))

    pt.SetFillColor(0)
    pt.Draw()
        
    canvas.SaveAs(name.replace("corrected_inputs.root", "png"))
    canvas.SaveAs(name.replace("corrected_inputs.root", "pdf"))

    myfile.Close()
    
