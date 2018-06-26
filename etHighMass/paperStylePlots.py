import ROOT
import pdb
import gc
from argparse import ArgumentParser

parser = ArgumentParser(description=__doc__)
parser.add_argument('-var','--variable', dest='var', type=str, action='append', help='variable', required=True)
args = parser.parse_args()
hname=args.var[0]

ROOT.gStyle.SetOptTitle(0)
ROOT.gStyle.SetOptStat(0)
ROOT.gROOT.SetBatch(1)

def add_CMS():
    lowX=0.15
    lowY=0.79
    lumi  = ROOT.TPaveText(lowX, lowY+0.06, lowX+0.15, lowY+0.16, "NDC")
    lumi.SetTextFont(61)
    lumi.SetTextSize(0.05)
    lumi.SetBorderSize(   0 )
    lumi.SetFillStyle(    0 )
    lumi.SetTextAlign(   12 )
    lumi.SetTextColor(    1 )
    lumi.AddText("CMS")
    return lumi

def add_Preliminary():
    lowX=0.15
    lowY=0.76
    lumi  = ROOT.TPaveText(lowX, lowY+0.05, lowX+0.15, lowY+0.15, "NDC")
    lumi.SetTextFont(52)
    lumi.SetTextSize(0.03)
    lumi.SetBorderSize(   0 )
    lumi.SetFillStyle(    0 )
    lumi.SetTextAlign(   12 )
    lumi.SetTextColor(    1 )
    lumi.AddText("Preliminary")
    return lumi

def make_legend():
    output = ROOT.TLegend(0.42, 0.5, 0.92, 0.85, "", "brNDC")
    output.SetNColumns(2)
    #output = ROOT.TLegend(0.2, 0.1, 0.47, 0.65, "", "brNDC")
    output.SetLineWidth(0)
    output.SetLineStyle(0)
    output.SetFillStyle(0)
    #output.SetFillColor(0)
    output.SetBorderSize(0)
    output.SetTextFont(62)
    return output

def add_lumi():
    Lumi=35900
    lowX=0.7
    lowY=0.86
    lumi  = ROOT.TPaveText(lowX,lowY, lowX+0.30, lowY+0.2, "NDC")
    lumi.SetBorderSize(   0 )
    lumi.SetFillStyle(    0 )
    lumi.SetTextAlign(   12 )
    lumi.SetTextColor(    1 )
    lumi.SetTextSize(0.04)
    lumi.SetTextFont (   42 )
    lumi.AddText(str(round(float(Lumi)/1000,1)) +"fb^{-1} (13 TeV)")
    return lumi

#histos = ['ePt', 'tPt', 'eEta', 'tEta', 'e_t_Mass', 'eMtToPfMet_type1', 'tMtToPfMet_type1', 'e_t_DPhi']
titles = {
    'ePt':'e p_{T} [GeV]',
    'tPt':'#tau p_{T} [GeV]',
    'eEta': 'e #eta',
    'tEta':'#tau #eta',
    'e_t_Mass':'M_{vis} [GeV]',
    'eMtToPfMet_type1':'M_{T}(e, MET) [GeV]',
    'tMtToPfMet_type1':'M_{T}(#tau, MET) [GeV]',
    'e_t_DPhi':'#Delta#phi(e,#tau)',
    'h_collmass_pfmet': 'M_{col} [GeV]'

}
ranges = {
    'ePt':(0, 500),
    'tPt':(0,500),
    'eEta':(-2.5, 2.5),
    'tEta':(-2.5, 2.5),
    'e_t_Mass':(0, 1400),
    'eMtToPfMet_type1': (0, 1000),
    'tMtToPfMet_type1':(0,1000),
    'e_t_DPhi':(0, 3.14),
    'h_collmass_pfmet': (0., 1300.)

}


title=titles[hname]
range=ranges[hname]
#path = 'plots/LFV_Mar15_mc/ETauAnalyzer/et/os/le1/'
path = 'plots/LFV_Mar15_mc/ETauAnalyzer/et/os/LowMass/1/'
file = ROOT.TFile.Open(path+hname+'.root', 'READ')
canvas = file.Get('adsf')
canvas.Draw()
canvas.SetCanvasSize(canvas.GetWw(), canvas.GetWw())
canvas.ls()
#primitives=canvas.GetPrimitives()
#pdb.set_trace()
pad1=canvas.FindObject("HigherPad")
pad1.SetPad(0, 0.3, 1, 1.)
    
if 'Pt' in hname:
    pad1.SetLogy(1)
pad1.SetTopMargin(0.07)
pad1.SetBottomMargin(0.0)
#pdb.set_trace()
mc_stack=pad1.FindObject("mc_stack").Clone()
mc_stack.SetName(hname)


lfv200 = pad1.FindObject("GluGlu_LFV_HToETau_M200").Clone()
lfv300 = pad1.FindObject("GluGlu_LFV_HToETau_M300").Clone()
lfv450 = pad1.FindObject("GluGlu_LFV_HToETau_M450").Clone()
lfv600 = pad1.FindObject("GluGlu_LFV_HToETau_M600").Clone()
lfv750 = pad1.FindObject("GluGlu_LFV_HToETau_M750").Clone()
lfv900 = pad1.FindObject("GluGlu_LFV_HToETau_M900").Clone()

pad1.cd()
new_legend=ROOT.TLegend(0.42, 0.5, 0.9, 0.92, "", "brNDC")
old_legend=pad1.FindObject('legend')
old_legend.Delete()
new_legend.SetNColumns(2)
if 'Eta' in hname or 'Phi' in hname:
    new_legend.SetNColumns(3)
    new_legend.SetX1(0.3)
    new_legend.SetY1(0.6)
new_legend.SetLineWidth(0)
new_legend.SetLineStyle(0)
new_legend.SetFillStyle(0)
new_legend.SetBorderSize(0)
new_legend.SetTextFont(62)
new_legend.SetTextSize(0.05)

labelmap={
    'DY#rightarrow#tau#tau + jets' : 'Z#rightarrow#tau#tau',
    'Dibosons' : 'Diboson',
    'SM Higgs' : 'SM H(125)',
    'DY#rightarrowll + jets' : 'Z#rightarrowee/#mu#mu',
    'mis-id #tau':'Misid. #tau',
    'single top': 't#bar{t},t+jets',
    'error': 'Bkg. unc.',
    'GluGlu_LFV_HToETau_M200' : 'LFV200',
    'GluGlu_LFV_HToETau_M300' : 'LFV300',
    'GluGlu_LFV_HToETau_M450' : 'LFV450',
    'GluGlu_LFV_HToETau_M600' : 'LFV600',
    'GluGlu_LFV_HToETau_M750' : 'LFV750',
    'GluGlu_LFV_HToETau_M900' : 'LFV900',
}
error=pad1.FindObject('error').Clone()
data=pad1.FindObject("data").Clone()

for h in mc_stack.GetHists():
    print h.GetName(), h.GetTitle()
    new_legend.AddEntry(h, labelmap[h.GetTitle()], 'f' )

if 'LowMass' in path:
    new_legend.AddEntry(lfv200, labelmap[lfv200.GetName()], 'l')
    new_legend.AddEntry(lfv300, labelmap[lfv300.GetName()], 'l')
new_legend.AddEntry(lfv450, labelmap[lfv450.GetName()], 'l')
if 'HighMass' in path:
    new_legend.AddEntry(lfv600, labelmap[lfv600.GetName()], 'l')
    new_legend.AddEntry(lfv750, labelmap[lfv750.GetName()], 'l')
    new_legend.AddEntry(lfv900, labelmap[lfv900.GetName()], 'l')

new_legend.AddEntry(error, labelmap['error'], 'f')
new_legend.AddEntry(data, 'data_obs', 'p')

new_legend.Draw()


print error.GetBinContent(error.GetMaximumBin())
mc_stack.GetYaxis().SetRangeUser(0.1, 100.*error.GetBinContent(error.GetMaximumBin()))
mc_stack.GetXaxis().SetRangeUser(range[0], range[1])

pad2=canvas.FindObject("LowerPad")
pad2.SetPad(0, 0, 1, 0.3)
pad2.SetTopMargin(0.05)
pad2.SetBottomMargin(.25)

hratio=pad2.FindObject("dataratio").Clone()
hratio.GetXaxis().SetLabelSize(0.07)
hratio.GetYaxis().SetLabelSize(0.08)
hratio.GetYaxis().SetLabelOffset(0.008)
hratio.GetXaxis().SetTitle(title)
hratio.GetXaxis().SetTitleSize(0.09)
hratio.GetYaxis().SetNdivisions(505)
hband=pad2.FindObject("bandplot").Clone()
func= pad2.FindObject("f").Clone()
hratio.GetXaxis().SetRangeUser(range[0], range[1])


myh=error.Clone()
canvas.Clear()
canv2=ROOT.TCanvas("canv2", "canv2", 600, 600)
canv2.Draw()

newpad2=ROOT.TPad('newpad2','newpad2', 0., 0., 1., 0.3)
newpad2.Draw()
newpad1=ROOT.TPad('newpad1','newpad1', 0., 0.31, 1., 1.)
newpad1.Draw()
canv2.cd()
newpad1.SetTopMargin(0.07)
newpad1.SetBottomMargin(0.02)
newpad2.SetTopMargin(0.05)
newpad2.SetBottomMargin(.25)

newpad1.cd()
newpad1.SetLogy(1)

myh.GetYaxis().SetRangeUser(0.1, 5.*error.GetBinContent(error.GetMaximumBin()))
if 'ToPfMet' in hname :
    myh.GetYaxis().SetRangeUser(0.1, 10.*error.GetBinContent(error.GetMaximumBin()))
if 'Eta' in hname:
    myh.GetYaxis().SetRangeUser(0.1, 10000.*error.GetBinContent(error.GetMaximumBin()))
if 'Phi' in hname:
    myh.GetYaxis().SetRangeUser(0.1, 200.*error.GetBinContent(error.GetMaximumBin()))
if 'collmass' in hname:
    myh.GetYaxis().SetRangeUser(0.1, 60.*error.GetBinContent(error.GetMaximumBin()))
myh.GetXaxis().SetRangeUser(range[0], range[1])
myh.Draw()
myh.SetLineColor(0)
myh.SetMarkerColor(0)
myh.GetXaxis().SetLabelOffset(0.1)
mc_stack.Draw("SAMES")
error.Draw("SAMEE2")

data.Draw("SAMEPE")
new_legend.Draw()

if 'LowMass' in path:
    lfv200.Draw("SAMEHIST")
    lfv300.Draw("SAMEHIST")
lfv450.Draw("SAMEHIST")
if 'HighMass' in path:
    lfv600.Draw("SAMEHIST")
    lfv750.Draw("SAMEHIST")
    lfv900.Draw("SAMEHIST")


newpad2.cd()
hratio.Draw()
hratio.GetXaxis().SetRangeUser(range[0], range[1])

hband.Draw("SAMEE2")

func.Draw("SAMES")




newpad1.cd()

l1=add_CMS()
l2=add_Preliminary()
l3=add_lumi()
l1.Draw()
l2.Draw()
l3.Draw()


canv2.Update()
canv2.SaveAs(path+hname+'_note.pdf')
#pdb.set_trace()
print 'figure saved', file
#file.Close()
print 'file closed'
new_legend.Delete()
gc.collect()
#mc_stack.Delete()
#new_legend.Delete()




