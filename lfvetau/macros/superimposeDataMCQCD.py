import ROOT


import os

ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(False)

ROOT.gStyle.SetOptTitle(1)


dirpath = 'results/%s/mmefakerate_fits/' %(os.environ['jobid'])
dirpathMC = 'results/%s/mmefakerate_fits_MC/' %(os.environ['jobid'])
dirpathQCD = 'results/%s/mmeQCDfakerate_fits/' %(os.environ['jobid'])



files=[]
filesMC=[]
filesQCD=[]
for name in os.listdir(dirpath):
    if 'canvas.root' not in name: continue
    if os.path.isfile(os.path.join(dirpath, name)):
        files.append(os.path.join(dirpath, name))
        filesMC.append(os.path.join(dirpathMC, name))
        filesQCD.append(os.path.join(dirpathQCD, name))
        print name
    
        
canvas=ROOT.TCanvas()
canvas.Draw()

histolist=[]

for n,name in enumerate(files):
    print name
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
    h0.SetMarkerStyle(20)

    h0Err=h0.Clone()
    h0Err.SetName('errgraph')
    for point in range(0, fakeref.GetN()):
        erryh= 1.-yval[point]
        if (0.3*yval[point]+yval[point] <1.): erryh= 0.3*yval[point]
        h0Err.SetPointEYhigh(point, erryh)
        h0Err.SetPointEYlow(point, 0.3*yval[point])

    h0Err.SetFillColor(38)
    h0Err.Draw("AE2")
    h0.Draw("SAMEEP")
    h0Err.SetMinimum(0)
    h0Err.SetMaximum(1.1)
    
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

    myfileQCD = ROOT.TFile.Open(filesQCD[n], "READ")
    c_fakerefQCD = myfileQCD.Get("asdf")
    fakerefQCD=c_fakerefQCD.GetPrimitive("hxy_xy_data")
    
    hQCD=fakerefQCD.Clone()
    
    hQCD.SetName("ErrorGraphQCD")
    xval = fakerefQCD.GetX()
    yval = fakerefQCD.GetY()
    hMC.Set(fakerefQCD.GetN())
    canvas.cd()
    hQCD.Draw("PE")
    hQCD.SetMarkerColor(4)
    hQCD.SetLineColor(4)
    

    leg=ROOT.TLegend(0.6, 0.6, 0.8, 0.5)
    leg.AddEntry(h0, "Data", "lp")
    leg.AddEntry(hMC, "MC", "lp")
    leg.AddEntry(hQCD, "QCD", "lp")
    leg.Draw("SAME")

    canvas.SaveAs(name.replace(".root", "_DataMC.pdf").replace(dirpath, dirpathQCD))
    canvas.SaveAs(name.replace(".root", "_DataMC.png").replace(dirpath, dirpathQCD))
                  
