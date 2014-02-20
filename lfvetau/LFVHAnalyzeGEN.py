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
    
class LFVHAnalyzeGenET(MegaBase):
    tree = 'New_Tree'
    def __init__(self, tree, outfile, **kwargs):
        self.channel='ET'
        super(LFVAnalyzeGenET, self).__init__(tree, outfile, ETauTree, **kwargs)
        #self.hfunc["e_pt"] = 
        self.out=outfile
        self.tree= ETauTree.ETauTree(tree)
        self.histograms = {}


    def begin(self):
        names= ["gg", "vbf"]

        namesize = len(names)
        for x in range(0,namesize):

        #GenQuantities 
            self.book(names[x], "eGenEta", "gen Eta electron", 200, 0, 200)
            self.book(names[x], "eGenPhi", "gen Phi electron", 200, 0, 200)
            self.book(names[x], "eGenEnergy", "gen Energy electron", 200, 0, 200)
        
            self.book(names[x], "tGenEta", "gen Eta tau", 200, 0, 200)
            self.book(names[x], "tGenPhi", "gen Phi tau", 200, 0, 200)
            self.book(names[x], "tGenEnergy", "gen Energy tau", 200, 0, 200)
            self.book(names[x], "tGenDecayMode", "gen Tau decay mode", 200, 0, 200)
            
            
            self.book(names[x], "eGenEta_all", "gen Eta all electrons", 200, 0, 200)
            self.book(names[x], "eGenPhi_all", "gen Phi all electrons", 200, 0, 200)
            self.book(names[x], "eGenEnergy_all", "gen Energy all electrons", 200, 0, 200)
            
            self.book(names[x], "tGenEta_all", "gen Eta all taus", 200, 0, 200)
            self.book(names[x], "tGenPhi_all", "gen Phi all taus", 200, 0, 200)
            self.book(names[x], "tGenEnergy_all", "gen Energy all taus", 200, 0, 200)
            self.book(names[x], "tGenDecayMode_all", "all gen Taus decay mode", 200, 0, 200)


    def fill_histos(self, row, name='gg', fakeRate = False):
        histos = self.histograms

        histos[name+'/eGenEta_all'].Fill(row.eGenEta) 
        histos[name+'/eGenPhi_all'].Fill(row.eGenPhi)
        histos[name+'/eGenEnergy_all'].Fill(row.eGenEnergy)
        
#         histos[name+'/tGenEta_all'].Fill(row.tGenEta)
#         histos[name+'/tGenPhi_all'].Fill(row.tGenPhi)
#         histos[name+'/tGenEnergy_all'].Fill(row.tGenEnergy)
        histos[name+'/tGenDecayMode_all'].Fill(row.tGenDecayMode)
 

        if row.eGenMotherPdgId == 25:
            histos[name+'/eGenEta'].Fill(row.eGenEta) 
            histos[name+'/eGenPhi'].Fill(row.eGenPhi)
            histos[name+'/eGenEnergy'].Fill(row.eGenEnergy)
            #        if row.tGenMotherPdgId == 25:
#         histos[name+'/tGenEta_all'].Fill(row.tGenEta)
#         histos[name+'/tGenPhi_all'].Fill(row.tGenPhi)
#         histos[name+'/tGenEnergy_all'].Fill(row.tGenEnergy)
#         histos[name+'/tGenDecayMode_all'].Fill(row.tGenDecayMode)
        

    def process(self):
        for row in self.tree:
            self.fill_histos(row, 'gg')
    def finish(self):
        self.write_histos()
