import os
import ROOT
dirname=['gg0etau', 'boostetau', 'vbfetau']
name_map={
'zjetsother' : 'DY',
'SMGG126' :'gg_HTauTau',
'SMVBF126' : 'vbf_HTauTau',
'LFVGG126': 'vbf_H_LFV125',
'LFVVBF126':'gg_H_LFV125'
}
for lumi in range (1, 21):
    fileout= ROOT.TFile.Open('DatacardHistograms_had_'+str(lumi)+'fb.root', "RECREATE")
    print 'doing lumi = ' , lumi , 'fb'
    for jet in range (0, 3):
        filein = ROOT.TFile.Open('limits_'+str(lumi)+'/shapesETau'+str(jet)+'Jet.root', "READ")
        
        dirin = filein.Get(dirname[jet])
        fileout.cd()
        dirout= fileout.mkdir('gg'+str(jet)+'etau_h')
        print '-------------'
        for histoname in dirin.GetListOfKeys():
            print histoname.GetName()
            histo=dirin.Get(histoname.GetName()).Clone()
            histo.SetName(name_map.get(histoname.GetName(), histoname.GetName()))
            dirout.cd()
            histo.Write()

        
            

    fileout.Close()
        
