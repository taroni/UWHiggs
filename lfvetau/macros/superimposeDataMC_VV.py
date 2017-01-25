import ROOT


import os

ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(False)

ROOT.gStyle.SetOptTitle(1)


dirpath = 'results/%s/mmefakerate_fits/' %(os.environ['jobid'])
dirpathMC = 'results/%s/mmefakerate_fits_MC/' %(os.environ['jobid'])
dirpathNoVV = 'results/%s/mmefakerate_fitsVV/' %(os.environ['jobid'])



files=[]
filesMC=[]
filesNoVV=[]
for name in os.listdir(dirpath):
    if 'canvas.root' not in name: continue
    if os.path.isfile(os.path.join(dirpath, name)):
        files.append(os.path.join(dirpath, name))
        filesMC.append(os.path.join(dirpathMC, name))
        filesNoVV.append(os.path.join(dirpathNoVV, name))
        print name
    
        
canvas=ROOT.TCanvas()
canvas.Draw()

histolist=[]

for n,name in enumerate(files):
    
    title = name[name.find('os'):].split("_")[2]+'/'+name[name.find('os'):].split("_")[1]
       
    myfile0 = ROOT.TFile.Open(name, "READ")
    c_fakeref = myfile0.Get("asdf")
    fakeref=c_fakeref.GetPrimitive("hxy_xy_data")
    canvas.cd()
    h0=fakeref.Clone()
    
    h0.SetName("ErrorGraph")
    xval = fakeref.GetX()
    yval = fakeref.GetY()
    h0.Set(fakeref.GetN())

    #if 'Pt' in name: h0.RemovePoint(0)
    if 'Pt' in name:
        print title
        for  i in range(0, fakeref.GetN()):
            print  '%.0f - %.0f &  %.4f & +%.4f & -%.4f \\\\\hline' %(xval[i]-fakeref.GetErrorX(i),xval[i]+fakeref.GetErrorX(i), yval[i], fakeref.GetErrorYhigh(i),fakeref.GetErrorYlow(i))
            
    h0.SetFillColor(16)
    h0.SetTitle(title)   
    h0.Draw("APE")
    h0.SetMinimum(0)
    h0.SetMaximum(1.1)


    myfileMC = ROOT.TFile.Open(filesMC[n], "READ")
    c_fakerefMC = myfileMC.Get("asdf")
    fakerefMC=c_fakerefMC.GetPrimitive("hxy_xy_data")
    hMC=fakerefMC.Clone()
    hMC.SetName("ErrorGraphMC")
    xval = fakerefMC.GetX()
    yval = fakerefMC.GetY()
    hMC.Set(fakerefMC.GetN())
    canvas.cd()
    hMC.Draw("PE")
    hMC.SetMarkerColor(2)
    hMC.SetLineColor(2)

    myfileNoVV = ROOT.TFile.Open(filesNoVV[n], "READ")
    c_fakerefNoVV = myfileNoVV.Get("asdf")
    fakerefNoVV=c_fakerefNoVV.GetPrimitive("hxy_xy_data")
    hNoVV=fakerefNoVV.Clone()
    hNoVV.SetName("ErrorGraphNoVV")
    xval = fakerefNoVV.GetX()
    yval = fakerefNoVV.GetY()
    hNoVV.Set(fakerefNoVV.GetN())
    canvas.cd()
    hNoVV.Draw("PE")
    hNoVV.SetMarkerColor(4)
    hNoVV.SetLineColor(4)
    hMC.Draw("PE")

    leg=ROOT.TLegend(0.55, 0.6, 0.85, 0.5)
    leg.AddEntry(h0, "Data", "lp")
    leg.AddEntry(hMC, "MC", "lp")
    leg.AddEntry(hNoVV, "Data uncorrected", "lp")
    leg.Draw("SAME")

    canvas.SaveAs(name.replace(".root", "_unc.pdf"))
                  
