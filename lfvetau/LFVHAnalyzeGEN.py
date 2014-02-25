from ETauTree import ETauTree
import os
import ROOT
import math
import glob
import array
from FinalStateAnalysis.PlotTools.decorators import  memo_last
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from math import sqrt, pi

def deltaPhi(phi1, phi2):
    PHI = abs(phi1-phi2)
    if PHI<=pi:
        return PHI
    else:
        return 2*pi-PHI
    
class LFVHAnalyzeGEN(MegaBase):
    tree = 'et/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        self.channel='ET'
        super(LFVHAnalyzeGEN, self).__init__(tree, outfile, **kwargs)
        self.out=outfile
        self.histograms = {}


    def begin(self):

        #GenQuantities 
        self.book('gen',"eGenMotherPdgId", "gen Mother pdgId", 200, 0, 200)
        self.book('gen',"eGenEta", "gen Eta, electron", 50, -2.5, 2.5)
        self.book('gen',"eGenPhi", "gen Phi, electron", 100, -3.2, 3.2)
        self.book('gen',"eGenEnergy", "gen Energy, electron", 40, 0, 200)
        self.book('gen',"eGenPt", "gen p_{T}, electron", 40, 0, 200)
        
        self.book('gen',"tGenEta", "gen Eta, tau", 50, -2.5, 2.5)
        self.book('gen',"tGenPhi", "gen Phi, tau",  100, -3.2, 3.2)
        self.book('gen',"tGenEnergy", "gen Energy, tau", 40, 0, 200)
        self.book('gen',"tGenPt", "gen p_{T}, tau", 40 , 0, 200)
        self.book('gen',"tGenDecayMode", "gen Tau, decay mode", 20, 0, 20)
        self.book('gen',"etGenDeltaPhi", "gen e tau, delta phi",  50, 0, 3.2)

        
        self.book('gen',"eGenMotherPdgId_all", "gen Mother pdfId, all electrons", 200, 0, 200)
        self.book('gen',"eGenEta_all", "gen Eta, all electrons", 50, -2.5, 2.5)
        self.book('gen',"eGenPhi_all", "gen Phi, all electrons",  100, -3.2, 3.2)
        self.book('gen',"eGenPt_all", "gen p_{T}, all electrons", 40, 0, 200)
        self.book('gen',"eGenEnergy_all", "gen Energy, all electrons", 40, 0, 200)
    
        self.book('gen',"tGenEta_all", "gen Eta, all taus", 50, -2.5, 2.5)
        self.book('gen',"tGenPhi_all", "gen Phi, all taus",  100, -3.2, 3.2)
        self.book('gen',"tGenEnergy_all", "gen Energy, all taus", 40, 0, 200)
        self.book('gen',"tGenPt_all", "gen p_{T}, all taus",  40, 0, 200)
        self.book('gen',"tGenDecayMode_all", "all gen Taus decay mode", 20, 0, 20)
        self.book('gen',"etGenDeltaPhi_all", "all gen e tau delta phi",  50, 0, 3.2)
            
    def fill_histos(self, row, folder='gen', fakeRate = False):
        histos = self.histograms

        histos[folder+'/eGenMotherPdgId_all'].Fill(row.eGenMotherPdgId) 
        histos[folder+'/eGenEta_all'].Fill(row.eGenEta) 
        histos[folder+'/eGenPhi_all'].Fill(row.eGenPhi)
        histos[folder+'/eGenPt_all'].Fill(row.eGenPt)
        histos[folder+'/eGenEnergy_all'].Fill(row.eGenEnergy)
        
        histos[folder+'/tGenEta_all'].Fill(row.tGenEta)
        histos[folder+'/tGenPhi_all'].Fill(row.tGenPhi)
        histos[folder+'/tGenPt_all'].Fill(row.tGenPt)
        histos[folder+'/tGenEnergy_all'].Fill(row.tGenEnergy)
        histos[folder+'/tGenDecayMode_all'].Fill(row.tGenDecayMode)
 
        histos[folder+'/etGenDeltaPhi_all'].Fill(deltaPhi(row.eGenPhi, row.tGenPhi))

 
#        if row.eGenMotherPdgId == 25: 
        if row.eComesFromHiggs == True:
            histos[folder+'/eGenMotherPdgId'].Fill(row.eGenMotherPdgId) 
            histos[folder+'/eGenEta'].Fill(row.eGenEta) 
            histos[folder+'/eGenPhi'].Fill(row.eGenPhi)
            histos[folder+'/eGenPt'].Fill(row.eGenPt)
            histos[folder+'/eGenEnergy'].Fill(row.eGenEnergy)
        if row.tComesFromHiggs  == True:            
            histos[folder+'/tGenEta'].Fill(row.tGenEta)
            histos[folder+'/tGenPhi'].Fill(row.tGenPhi)
            histos[folder+'/tGenPt'].Fill(row.tGenPt)
            histos[folder+'/tGenEnergy'].Fill(row.tGenEnergy)
            histos[folder+'/tGenDecayMode'].Fill(row.tGenDecayMode)
            
        if row.eComesFromHiggs == True and row.tComesFromHiggs == True: 
            #print row.eGenMotherPdgId, " ", row.tGenMotherPdgId
            histos[folder+'/etGenDeltaPhi'].Fill(deltaPhi(row.eGenPhi, row.tGenPhi))
            
 
    
 
    def process(self):
        for row in self.tree:
        #os.environ['megatarget'] ## to get the sample name
        #for i, row in enumerate(self.tree):
         #   if  i >= 1000:
          #      return
            self.fill_histos(row, 'gen')
    def finish(self):
        self.write_histos()
