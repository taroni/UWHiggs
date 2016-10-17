import ROOT
import os

ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(False)

ROOT.gStyle.SetOptTitle(1)


dirpath = 'results/%s/fakerate_fits/' %(os.environ['jobid'])
files=[]
for name in os.listdir(dirpath):
    if 'tDecayMode' in name: continue
    if '_tDM0' not in name: continue
    if '_canvas.root' not in name: continue
    if os.path.isfile(os.path.join(dirpath, name)):
        files.append(os.path.join(dirpath, name))
        print name
        
canvas=ROOT.TCanvas()
canvas.Draw()



histolist=[]

leg=ROOT.TLegend(0.15,0.7,0.5,0.9)

for name in files:
    
    title = name[name.find('os'):].split("_")[2]+'/'+name[name.find('os'):].split("_")[1]
    
    leg.Clear()
    myfile0 = ROOT.TFile.Open(name, "READ")
    myfile1 = ROOT.TFile.Open(name.replace("_tDM0", "_tDM1"), "READ")
    myfile2 = ROOT.TFile.Open(name.replace("_tDM0", "_tDM10"), "READ")
    myfile = ROOT.TFile.Open(name.replace("_tDM0", ""), "READ")

    canvasref=myfile.Get("asdf")
    canvas0=myfile0.Get("asdf")
    canvas1=myfile1.Get("asdf")
    canvas2=myfile2.Get("asdf")

    
    #h0=canvas0.GetPrimitive("hxy_xy_data")

    fakeref = canvasref.GetPrimitive('hxy_xy_data')
    canvas.cd()

    h0=fakeref.Clone()
    h0.SetName("ErrorGraph")
    xval = fakeref.GetX()
    yval = fakeref.GetY()
    h0.Set(fakeref.GetN()+2)
    for i in range(0, fakeref.GetN()+2):
        #print i,  fakeref.GetN()+2
        if i == 0:
            h0.SetPoint(i, xval[i]-fakeref.GetErrorX(i), yval[i])
            #print i, xval[i]-fakeref.GetErrorX(i), yval[i]
            h0.SetPointError(i, fakeref.GetErrorX(i),fakeref.GetErrorX(i), 0.3*yval[i+1],0.3*yval[i])
        if i > 0 and i< fakeref.GetN()+1:
            h0.SetPoint(i, xval[i-1], yval[i-1])
            #print i, xval[i-1], yval[i-1]
            h0.SetPointError(i, fakeref.GetErrorXlow(i-1),fakeref.GetErrorXhigh(i-1), 0.3*yval[i-1],0.3*yval[i-1]) # prendere i numeri dal graph
        if i == fakeref.GetN()+1:
            #print i , xval[i-2]+fakeref.GetErrorX(i-2), yval[i-2]
            h0.SetPoint(i, xval[i-2]+fakeref.GetErrorX(i-2), yval[i-2])
            h0.SetPointError(i, fakeref.GetErrorXlow(i-2),fakeref.GetErrorXhigh(i-2), 0.3*yval[i-2],0.3*yval[i-2]) # prendere i numeri d
            
        

        
    h0.SetFillColor(16)
    h0.SetTitle(title)   
    h0.Draw("AE3")

    h0.GetYaxis().SetTitle("fakerate")
    h0.SetMinimum(0)
    h0.SetMaximum(1)
    if 'Eta' in name:
        h0.GetXaxis().SetTitle("#tau #eta")
        h0.GetXaxis().SetRangeUser(-5,5)
    if 'Pt' in name:
        h0.GetXaxis().SetTitle("#tau p_{T}")
        h0.GetXaxis().SetRangeUser(0, 500)

    fakeref.SetMarkerStyle(20)
    fakeref.SetMarkerColor(1)
    fakeref.SetLineColor(1)
    fakeref.SetMinimum(0)
    fakeref.SetMaximum(1)
    #fakeref.GetYaxis().SetTitle("fakerate")
    #if 'Eta' in name: fakeref.GetXaxis().SetTitle("#tau #eta")
    #if 'Pt' in name: fakeref.GetXaxis().SetTitle("#tau p_{T}")
    fakeref.Draw('SAMEP')
 
    leg.AddEntry(fakeref, "average fakerate", "lp")
    leg.AddEntry(h0, "30% uncertainty", "f")
    
    ##h0.Draw()
    ##h0.GetYaxis().SetRangeUser(0, 1)
    ##h0.GetYaxis().SetTitle("fakerate")
    ##if 'Eta' in name: h0.GetXaxis().SetTitle("#tau#eta")
    ##if 'Pt' in name: h0.GetXaxis().SetTitle("#tau p_{T}")
    
    fake0 = canvas0.GetPrimitive('hxy_xy_data')
    fake0.Draw('SAMEP')
    fake0.SetMarkerStyle(20)
    fake0.SetMarkerColor(2)
    fake0.SetLineColor(2)
    fake1 = canvas1.GetPrimitive('hxy_xy_data')
    fake1.Draw('SAMEP')
    fake1.SetMarkerStyle(20)
    fake1.SetMarkerColor(4)
    fake1.SetLineColor(4)
    
    fake2 = canvas2.GetPrimitive('hxy_xy_data')
    fake2.Draw('SAMEP')
    fake2.SetMarkerStyle(20)
    fake2.SetMarkerColor(6)
    fake2.SetLineColor(6)

    leg.AddEntry(fake0, "DM0 fakerate", "lp")
    leg.AddEntry(fake1, "DM1 fakerate", "lp")
    leg.AddEntry(fake2, "DM10 fakerate", "lp")

    leg.SetFillColor(0)
    leg.Draw()
    
    canvas.SaveAs(name.replace("_tDM0_canvas.root", "_comparisonDM.png"))
    canvas.SaveAs(name.replace("_tDM0_canvas.root", "_comparisonDM.pdf"))
    canvas.SaveAs(name.replace("_tDM0_canvas.root", "_comparisonDM.root"))
    

    myfile0.Close()
    myfile1.Close()
    myfile2.Close()
    
