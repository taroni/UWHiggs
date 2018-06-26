import ROOT

infile=ROOT.TFile.Open("preprocessed_inputs/SimpleEMAnalyzer35862/selected_with_shapes/h_collmass_pfmet.root")

oldfile=ROOT.TFile.open("../etHighMassEMuNew/preprocessed_inputs/SimpleEMAnalyzer35862/selected_with_shapes/h_collmass_pfmet.root")

indir=infile.Get("0jet")
indir.cd()

thList=indir.GetListOfKeys()
for histo in thList:
    h=indir.Get(histo.GetName())
    print h.GetName(), h.Integral()
