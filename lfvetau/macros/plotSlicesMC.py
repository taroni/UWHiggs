import ROOT

ROOT.gROOT.SetBatch(True)

file0 = ROOT.TFile.Open("results/LFVtrilepton_oct31/mmefakerate_fits_MC/e_os_eSuperLoose_eTight_eAbsEta_vs_ePt.corrected_inputs.root", "READ")


num = file0.Get("numerator")
den = file0.Get("denominator")

eff = ROOT.TEfficiency(num, den)

c=ROOT.TCanvas("c", "c")

c.cd()
eff.Draw("COLZ")
##c.SaveAs("2DEff.pdf")
##c.SaveAs("2DEff.png")
c.SaveAs("2DEffMC.pdf")
c.SaveAs("2DEffMC.png")


# slice in pt

for ix in range (2, den.GetXaxis().GetNbins()+1):
    pass_histo = num.ProjectionY("num_px%s" %(str(ix)), ix,ix, " ")
    all_histo  = den.ProjectionY("den_px%s" %(str(ix)), ix,ix, " ")
    
    eff_py = ROOT.TEfficiency(pass_histo, all_histo)
    eff_py.SetName("eff_eta_%s" %(str(ix)))
    
    eff_py.Draw("AP")
    
    gr=eff_py.CreateGraph()
    gr.SetMarkerStyle(20)
    gr.Draw("AP")
    gr.SetMinimum(0)
    gr.SetMaximum(1.05)

    c.SaveAs(eff_py.GetName()+'.pdf')
    c.SaveAs(eff_py.GetName()+'.png')

grlist=[]
for iy in range (1, den.GetYaxis().GetNbins()+1):
    pass_histo = num.ProjectionX("num_py%s" %(str(iy)), iy,iy, " ")
    all_histo  = den.ProjectionX("den_py%s" %(str(iy)), iy,iy, " ")
    
    eff_px = ROOT.TEfficiency(pass_histo, all_histo)
    eff_px.SetName("eff_pt_%s" %(str(iy)))
    
    eff_px.Draw("AP")
    gr=eff_px.CreateGraph().Clone()
    gr.SetName("efficiency_"+str(iy))
    grlist.append(gr)
    gr.SetMarkerStyle(20)
    gr.Draw("AP")
    gr.SetMinimum(0)
    gr.SetMaximum(1.05)
    c.SaveAs(eff_px.GetName()+'.pdf')
    
for i,gr in enumerate(grlist):
    gr.SetMarkerStyle(20)
    if i == 0 or i==3:
        gr.Draw("AP")
        gr.SetMinimum(0)
        gr.SetMaximum(1.05)

    else:
        gr.Draw("P")
        gr.SetMarkerColor(i+1)
        gr.SetLineColor(i+1)

    if i == 2 : c.SaveAs('effMC_slicept_barrel.pdf')
    if i == 4 : c.SaveAs('effMC_slicept_endcap.pdf')
    if i == 2 : c.SaveAs('effMC_slicept_barrel.png')
    if i == 4 : c.SaveAs('effMC_slicept_endcap.png')
##    if i == 2 : c.SaveAs('eff_slicept_barrel.pdf')
##    if i == 4 : c.SaveAs('eff_slicept_endcap.pdf')
##    if i == 2 : c.SaveAs('eff_slicept_barrel.png')
##    if i == 4 : c.SaveAs('eff_slicept_endcap.png')
