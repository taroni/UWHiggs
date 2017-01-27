import ROOT
import os

ROOT.gROOT.SetBatch(1)
ROOT.gStyle.SetOptStat(1111111)

dataperiod = ['2016B', '2016C', '2016D', '2016E', '2016F']

pathPrompt= '/afs/hep.wisc.edu/home/taroni/nobackup/13TeV/CMSSW_8_0_18/src/UWHiggs/lfvetau/results/LFVtrilepton_oct31/MMEControl/'
pathReReco= 'results/SMHTT_data_jan25/MMEControl/'

filesReReco=['data_SingleMuon_Run2016B_v3', 'data_SingleMuon_Run2016C', 'data_SingleMuon_Run2016D', 'data_SingleMuon_Run2016E', 'data_SingleMuon_Run2016F']
filesPrompt=['data_SingleMuon_Run2016B',    'data_SingleMuon_Run2016C', 'data_SingleMuon_Run2016D', 'data_SingleMuon_Run2016E', 'data_SingleMuon_Run2016F']


histos = ['ePt', 'eEta', 'ePhi', 'eAbsEta', 'm1Pt', 'm1Eta', 'm1Phi', 'm2Pt', 'm2Eta', 'm2Phi', 'm1_m2_Mass', 'm1_m2_DR', 'm1_m2_DPhi', 'jetVeto30', 'nvtx', 'type1_pfMetEt']

eleDirs=[ 'isduplicate','eSSuperLoose','eSuperLoose','eVLoose', 'eLoose','eTight','eVTight']

c=ROOT.TCanvas()
c.Draw()

leg = ROOT.TLegend(0.6,0.6, 0.5, 0.8)


for n,myfile in enumerate(filesReReco):
    myf= ROOT.TFile.Open(pathReReco+myfile+'.root', "READ")
    myfPrompt= ROOT.TFile.Open(pathPrompt+filesPrompt[n]+'.root', "READ")
    lumi = [line.rstrip('\n') for line in open('inputs/SMHTT_data_jan25/'+myfile+'.lumicalc.sum')]
    lumiPrompt = [line.rstrip('\n') for line in open('/afs/hep.wisc.edu/home/taroni/nobackup/13TeV/CMSSW_8_0_18/src/UWHiggs/lfvetau/inputs/LFVtrilepton_oct31/'+filesPrompt[n]+'.lumicalc.sum')]
    if lumi == []: continue
    if lumi[0]!=lumiPrompt[0]:
        print 'different lumi', lumi[0], lumiPrompt[0]


        
    
    
    for mydir in eleDirs:
        for histo in histos:
            
            print myfile, 'os/'+mydir+'/'+histo
            histoReReco=myf.Get('os/'+mydir+'/'+histo)
            histoPrompt=myfPrompt.Get('os/'+mydir+'/'+histo)

            leg.Clear()
            leg.AddEntry(histoReReco, "RERECO", "lp")
            leg.AddEntry(histoPrompt, "Prompt", "lp")
            
            histoReReco.Draw("E")
            histoReReco.SetMarkerStyle(20)
            histoReReco.GetXaxis().SetTitle(histoReReco.GetTitle())
            if 'Phi' in histo: histoReReco.Rebin(2)
            if 'Eta' in histo: histoReReco.Rebin(5)
            histoPrompt.Sumw2()
            print 'scaling factor', float(lumi[0])/float(lumiPrompt[0])
            histoPrompt.Scale(float(lumi[0])/float(lumiPrompt[0]))
            histoPrompt.Draw("ESAME")
            histoPrompt.SetMarkerStyle(20)
            histoPrompt.SetMarkerColor(2)
            histoPrompt.SetLineColor(2)
            if 'Phi' in histo: histoPrompt.Rebin(2)
            if 'Eta' in histo: histoPrompt.Rebin(5)


            leg.Draw()
            
            c.Update()
            outputfilename='/'.join(['plots','MMEControl', myfile,mydir,histo])
            if not os.path.exists('/'.join(['plots','MMEControl', myfile,mydir])):
                os.makedirs('/'.join(['plots','MMEControl', myfile,mydir]))

            c.SaveAs(outputfilename+'.pdf')
            c.SaveAs(outputfilename+'.png')
            
            
    print myfile, float(lumi[0])

    

    
