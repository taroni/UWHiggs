import ROOT


import os

ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(False)

ROOT.gStyle.SetOptTitle(1)


dirpath = 'results/%s/mmefakerate_fits/' %(os.environ['jobid'])
files=[]
for name in os.listdir(dirpath):
    if 'canvas.root' not in name: continue
    if os.path.isfile(os.path.join(dirpath, name)):
        files.append(os.path.join(dirpath, name))
        print name
    
        
canvas=ROOT.TCanvas()
canvas.Draw()

histolist=[]

for name in files:
    
    title = name[name.find('os'):].split("_")[2]+'/'+name[name.find('os'):].split("_")[1]
    
    
    myfile0 = ROOT.TFile.Open(name, "READ")

    c_fakeref = myfile0.Get("asdf")
    fakeref=c_fakeref.GetPrimitive("hxy_xy_data")

    canvas.cd()

    h0=fakeref.Clone()
    h0.Clear()
    h0.SetName("ErrorGraph")
    
    xval = fakeref.GetX()
    yval = fakeref.GetY()
    h0.Set(fakeref.GetN())
    ##for i in range(0, fakeref.GetN()-1):
    ##    if 'Pt' in name and i == 0 : continue
    ##    if 'Pt' in name:
    ##        h0.SetPoint(i-1, xval[i], yval[i])
    ##
    ##        print name, xval[i], yval[i], fakeref.GetErrorX(i),  fakeref.GetErrorY(i)
    ##        #print i, xval[i]-fakeref.GetErrorX(i), yval[i]
    ##        h0.SetPointError(i-1, fakeref.GetErrorX(i),fakeref.GetErrorX(i), fakeref.GetErrorY(i),fakeref.GetErrorY(i))
    ##    else:
    ##
    ##        
    ##        print name, xval[i], yval[i], fakeref.GetErrorX(i),  fakeref.GetErrorY(i)
    ##        h0.SetPoint(i, xval[i], yval[i])
    ##        #print i, xval[i]-fakeref.GetErrorX(i), yval[i]
    ##        h0.SetPointError(i, fakeref.GetErrorX(i),fakeref.GetErrorX(i), fakeref.GetErrorY(i),fakeref.GetErrorY(i))

    if 'Pt' in name: h0.RemovePoint(0)
    h0.SetFillColor(16)
    h0.SetTitle(title)   
    h0.Draw("APE")
    h0.SetMinimum(0)
    h0.SetMaximum(1.1)

    canvas.SaveAs(name.replace(".root", ".pdf"))
                  
