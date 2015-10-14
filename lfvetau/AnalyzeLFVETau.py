'''

Run LFV H->ETau analysis in the e+tau channel.

Authors: Maria Cepeda, Aaron Levine, Evan K. Friis, UW

'''

import ETauTree
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
import glob
import os
#import FinalStateAnalysis.TagAndProbe.MuonPOGCorrections as MuonPOGCorrections
#import FinalStateAnalysis.TagAndProbe.H2TauCorrections as H2TauCorrections
import FinalStateAnalysis.TagAndProbe.PileupWeight as PileupWeight
import ROOT
import math

from math import sqrt, pi

def deltaPhi(phi1, phi2):
  PHI = abs(phi1-phi2)
  if PHI<=pi:
      return PHI
  else:
      return 2*pi-PHI

def fullMT(met,ept,taupt, metphi, ephi, tauphi):
	ex=ept*math.cos(ephi)
	ey=ept*math.sin(ephi)
        metx=met*math.cos(metphi)
        mety=met*math.sin(metphi)
        taux=taupt*math.cos(tauphi)
        tauy=taupt*math.sin(tauphi)
	full_et=met+ept+taupt # for e and tau I am approximating pt~et (M<<P)
	full_x=metx+ex+taux
        full_y=mety+ey+tauy
	full_mt_2 = full_et*full_et-full_x*full_x-full_y*full_y
	full_mt=0
	if (full_mt_2>0):
		full_mt= math.sqrt(full_mt_2)
	return full_mt

def fullPT(met,ept,taupt, metphi, ephi, tauphi):
        ex=ept*math.cos(ephi)
        ey=ept*math.sin(ephi)
        metx=met*math.cos(metphi)
        mety=met*math.sin(metphi)
        taux=taupt*math.cos(tauphi)
        tauy=taupt*math.sin(tauphi)
        full_x=metx+ex+taux
        full_y=mety+ey+tauy
        full_pt_2 = full_x*full_x+full_y*full_y
        full_pt=0
        if (full_pt_2>0):
                full_pt= math.sqrt(full_pt_2)
        return full_pt

def collMass_type1(row):
        taupx=row.tPt*math.cos(row.tPhi)
        taupy=row.tPt*math.sin(row.tPhi)
        metpx = row.type1_pfMetEt*math.cos(row.type1_pfMetPhi)
        metpy = row.type1_pfMetEt*math.sin(row.type1_pfMetPhi)
        met = sqrt(metpx*metpx+metpy*metpy)

        METproj= abs(metpx*taupx+metpy*taupy)/row.tPt

        xth=row.tPt/(row.tPt+METproj)
        den=math.sqrt(xth)

        mass=row.e_t_Mass/den

        #print '%4.2f, %4.2f, %4.2f, %4.2f, %4.2f' %(scaleMass(row), den, xth, METproj,mass)


        return mass


################################################################################
#### MC-DATA and PU corrections ################################################
################################################################################

class AnalyzeLFVETau(MegaBase):
    tree = 'et/final/Ntuple'
    #tree = 'New_Tree'

    def __init__(self, tree, outfile, **kwargs):
        super(AnalyzeLFVETau, self).__init__(tree, outfile, **kwargs)
        # Use the cython wrapper
        self.tree = ETauTree.ETauTree(tree)
        self.out = outfile
        self.histograms = {}

    def begin(self):

        #names=["oldisotight","oldisoloose","oldisogg","oldisoboost","oldisovbf", "oldisoloosegg","oldisolooseboost","oldisoloosevbf",
         #     "newisotight","newisoloose","newisogg","newisoboost","newisovbf",  "newisoloosegg","newisolooseboost","newisoloosevbf",
          #    "noisogg","noisoboost","noisovbf",
          #    "noTauID","noiso"]
        names=["preselection"]
        namesize = len(names)
	for x in range(0,namesize):

            self.book(names[x], "weight", "Event weight", 100, 0, 5)
            self.book(names[x], "GenWeight", "Gen level weight", 200000 ,-1000000, 1000000)
    
            self.book(names[x], "rho", "Fastjet #rho", 100, 0, 25)
            self.book(names[x], "nvtx", "Number of vertices", 100, -0.5, 100.5)
            self.book(names[x], "prescale", "HLT prescale", 21, -0.5, 20.5)
   
            self.book(names[x], "ePt", "Electron  Pt", 300,0,300)
            self.book(names[x], "eEta", "Electron  eta", 100, -2.5, 2.5)
            self.book(names[x], "eMtToPfMet_Ty1", "Electron MT (PF Ty1)", 200, 0, 200)
            self.book(names[x], "eCharge", "Electron Charge", 5, -2, 2)

            self.book(names[x], "tPt", "Tau  Pt", 300,0,300)
            self.book(names[x], "tEta", "Tau  eta", 100, -2.5, 2.5)
            self.book(names[x], "tMtToPfMet_Ty1", "Tau MT (PF Ty1)", 200, 0, 200)
            self.book(names[x], "tCharge", "Tau  Charge", 5, -2, 2)
	    self.book(names[x], "tJetPt", "Tau Jet Pt" , 500, 0 ,500)	    
            self.book(names[x], "tMass", "Tau  Mass", 1000, 0, 10)
            self.book(names[x], "tLeadTrackPt", "Tau  LeadTrackPt", 300,0,300)

		       
            #self.book(names[x], "tAgainstElectronLoose", "tAgainstElectronLoose", 2,-0.5,1.5)
            self.book(names[x], "tAgainstElectronLooseMVA5", "tAgainstElectronLooseMVA5", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstElectronMedium", "tAgainstElectronMedium", 2,-0.5,1.5)
            self.book(names[x], "tAgainstElectronMediumMVA5", "tAgainstElectronMediumMVA5", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstElectronTight", "tAgainstElectronTight", 2,-0.5,1.5)
            self.book(names[x], "tAgainstElectronTightMVA5", "tAgainstElectronTightMVA5", 2,-0.5,1.5)
            self.book(names[x], "tAgainstElectronVTightMVA5", "tAgainstElectronVTightMVA5", 2,-0.5,1.5)


            #self.book(names[x], "tAgainstElectronLoose", "tAgainstMuonLoose", 2,-0.5,1.5)
            self.book(names[x], "tAgainstElectronLoose3", "tAgainstMuonLoose3", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstElectronMedium", "tAgainstMuonMedium", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstElectronTight", "tAgainstMuonTight", 2,-0.5,1.5)
            self.book(names[x], "tAgainstElectronTight3", "tAgainstMuonTight3", 2,-0.5,1.5)

            #self.book(names[x], "tAgainstElectronLooseMVA", "tAgainstMuonLooseMVA", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstElectronMediumMVA", "tAgainstMuonMediumMVA", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstElectronTightMVA", "tAgainstMuonTightMVA", 2,-0.5,1.5)

            self.book(names[x], "tDecayModeFinding", "tDecayModeFinding", 2,-0.5,1.5)
            self.book(names[x], "tDecayModeFindingNewDMs", "tDecayModeFindingNewDMs", 2,-0.5,1.5)
            self.book(names[x], "tDecayMode", "tDecayMode", 21,-0.5,20.5)


            self.book(names[x], "tByLooseCombinedIsolationDeltaBetaCorr3Hits", "tByLooseCombinedIsolationDeltaBetaCorr3Hits", 2,-0.5,1.5)
            self.book(names[x], "tByMediumCombinedIsolationDeltaBetaCorr3Hits", "tByMediumCombinedIsolationDeltaBetaCorr3Hits", 2,-0.5,1.5)
            self.book(names[x], "tByTightCombinedIsolationDeltaBetaCorr3Hits", "tByTightCombinedIsolationDeltaBetaCorr3Hits", 2,-0.5,1.5)

            self.book(names[x], "tByLooseIsolationMVA3newDMwLT", "tByLooseIsolationMVA3newDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByMediumIsolationMVA3newDMwLT", "tByMediumIsolationMVA3newDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByTightIsolationMVA3newDMwLT", "tByTightIsolationMVA3newDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByVTightIsolationMVA3newDMwLT", "tByVTightIsolationMVA3newDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByVVTightIsolationMVA3newDMwLT", "tByVVTightIsolationMVA3newDMwLT", 2,-0.5,1.5)

            self.book(names[x], "tByLooseIsolationMVA3oldDMwLT", "tByLooseIsolationMVA3oldDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByMediumIsolationMVA3oldDMwLT", "tByMediumIsolationMVA3oldDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByTightIsolationMVA3oldDMwLT", "tByTightIsolationMVA3oldDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByVTightIsolationMVA3oldDMwLT", "tByVTightIsolationMVA3oldDMwLT", 2,-0.5,1.5)
            self.book(names[x], "tByVVTightIsolationMVA3oldDMwLT", "tByVVTightIsolationMVA3oldDMwLT", 2,-0.5,1.5)

            #self.book(names[x], "tByLooseIsolationMVA3newDMwoLT", "tByLooseIsolationMVA3newDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByMediumIsolationMVA3newDMwoLT", "tByMediumIsolationMVA3newDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByTightIsolationMVA3newDMwoLT", "tByTightIsolationMVA3newDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByVTightIsolationMVA3newDMwoLT", "tByVTightIsolationMVA3newDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByVVTightIsolationMVA3newDMwoLT", "tByVVTightIsolationMVA3newDMwoLT", 2,-0.5,1.5)
   
            #self.book(names[x], "tByLooseIsolationMVA3oldDMwoLT", "tByLooseIsolationMVA3oldDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByMediumIsolationMVA3oldDMwoLT", "tByMediumIsolationMVA3oldDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByTightIsolationMVA3oldDMwoLT", "tByTightIsolationMVA3oldDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByVTightIsolationMVA3oldDMwoLT", "tByVTightIsolationMVA3oldDMwoLT", 2,-0.5,1.5)
            #self.book(names[x], "tByVVTightIsolationMVA3oldDMwoLT", "tByVVTightIsolationMVA3oldDMwoLT", 2,-0.5,1.5)

            self.book(names[x], 'eJetBtag', 'E 1 JetBtag', 100, -5.5, 9.5)
    	   
            self.book(names[x],"collMass_type1","collMass_type1",500,0,500);
            self.book(names[x],"fullMT_type1","fullMT_type1",500,0,500);
            self.book(names[x],"fullPT_type1","fullPT_type1",500,0,500);	    
    	    self.book(names[x], "LT", "ht", 400, 0, 400)
            self.book(names[x], "type1_pfMetEt", "Type1 MET", 200, 0, 200)
    
            self.book(names[x], "e_t_Mass", "Electron + Tau Mass", 200, 0, 200)
            self.book(names[x], "e_t_Pt", "Electron + Tau Pt", 200, 0, 200)
            self.book(names[x], "e_t_DR", "Electron + Tau DR", 100, 0, 10)
            self.book(names[x], "e_t_DPhi", "Electron + Tau DPhi", 100, 0, 4)
            self.book(names[x], "e_t_SS", "Electron + Tau SS", 5, -2, 2)
            self.book(names[x], "e_t_ToMETDPhi_Ty1", "Electron Tau DPhi to MET", 100, 0, 4)
    
            # Vetoes
            self.book(names[x], 'muVetoPt5IsoIdVtx', 'Number of extra muons', 5, -0.5, 4.5)
	    self.book(names[x], 'muVetoPt15IsoIdVtx', 'Number of extra muons', 5, -0.5, 4.5)
            self.book(names[x], 'tauVetoPt20Loose3HitsVtx', 'Number of extra taus', 5, -0.5, 4.5)
            self.book(names[x], 'eVetoMVAIso', 'Number of extra CiC tight electrons', 5, -0.5, 4.5)
   
            #self.book(names[x], 'jetVeto30PUCleanedTight', 'Number of extra jets', 5, -0.5, 4.5)
            #self.book(names[x], 'jetVeto30PUCleanedLoose', 'Number of extra jets', 5, -0.5, 4.5)
            self.book(names[x], 'jetVeto30', 'Number of extra jets', 5, -0.5, 4.5)	
	    #Isolation
	    self.book(names[x], 'eRelPFIsoDB' ,'Electron Isolation', 100, 0.0,1.0)
   
 
            self.book(names[x], "ePhiMtPhi", "", 100, 0,4)
            self.book(names[x], "ePhiMETPhiType1", "", 100, 0,4)
            self.book(names[x], "tPhiMETPhiType1", "", 100, 0,4)

### vbf ###
            self.book(names[x], "vbfJetVeto30", "central jet veto for vbf", 5, -0.5, 4.5)
	    self.book(names[x], "vbfJetVeto20", "", 5, -0.5, 4.5)
	    self.book(names[x], "vbfMVA", "", 100, 0,0.5)
	    self.book(names[x], "vbfMass", "", 500,0,5000.0)
	    self.book(names[x], "vbfDeta", "", 100, -0.5,10.0)
            self.book(names[x], "vbfj1eta","",100,-2.5,2.5)
	    self.book(names[x], "vbfj2eta","",100,-2.5,2.5)
	    self.book(names[x], "vbfVispt","",100,0,200)
	    self.book(names[x], "vbfHrap","",100,0,5.0)
	    self.book(names[x], "vbfDijetrap","",100,0,5.0)
	    self.book(names[x], "vbfDphihj","",100,0,4)
            self.book(names[x], "vbfDphihjnomet","",100,0,4)
            self.book(names[x], "vbfNJets", "g", 5, -0.5, 4.5)
            #self.book(names[x], "vbfNJetsPULoose", "g", 5, -0.5, 4.5)
            #self.book(names[x], "vbfNJetsPUTight", "g", 5, -0.5, 4.5)

	     

    def fill_histos(self, row,name='gg'):
        histos = self.histograms
        weight=1
        if (row.GenWeight>=0):
          weight=1
        else:
          weight=-1
        histos[name+'/weight'].Fill(weight)
        histos[name+'/GenWeight'].Fill(row.GenWeight)
        histos[name+'/rho'].Fill(row.rho, weight)
        histos[name+'/nvtx'].Fill(row.nvtx, weight)
        histos[name+'/prescale'].Fill(row.doubleEPrescale, weight)
        #histos[name+'/jet1Pt'].Fill(row.jet1Pt, weight)
        #histos[name+'/jet2Pt'].Fill(row.jet2Pt, weight)
        #histos[name+'/jet2Eta'].Fill(row.jet2Eta, weight)
        #histos[name+'/jet1Eta'].Fill(row.jet1Eta, weight)
        #histos[name+'/jet1PULoose '].Fill(row.jet1PULoose , weight)
        #histos[name+'/jet2PULoose '].Fill(row.jet2PULoose , weight)
        #histos[name+'/jet1PUTight '].Fill(row.jet1PUTight , weight)
        #histos[name+'/jet2PUTight '].Fill(row.jet2PUTight , weight)
        #histos[name+'/jet1PUMVA '].Fill(row.jet1PUMVA , weight)
        #histos[name+'/jet2PUMVA '].Fill(row.jet2PUMVA , weight)

        histos[name+'/ePt'].Fill(row.ePt, weight)
        histos[name+'/eEta'].Fill(row.eEta, weight)
        histos[name+'/eMtToPfMet_Ty1'].Fill(row.eMtToPfMet_Ty1,weight)
        histos[name+'/eCharge'].Fill(row.eCharge, weight)
        histos[name+'/tPt'].Fill(row.tPt, weight)
        histos[name+'/tEta'].Fill(row.tEta, weight)
        histos[name+'/tMtToPfMet_Ty1'].Fill(row.tMtToPfMet_Ty1,weight)
        histos[name+'/tCharge'].Fill(row.tCharge, weight)
	histos[name+'/tJetPt'].Fill(row.tJetPt, weight)

        histos[name+'/tMass'].Fill(row.tMass,weight)
        histos[name+'/tLeadTrackPt'].Fill(row.tLeadTrackPt,weight)
		       
        #histos[name+'/tAgainstElectronLoose'].Fill(row.tAgainstElectronLoose,weight)
        histos[name+'/tAgainstElectronLooseMVA5'].Fill(row.tAgainstElectronLooseMVA5,weight)  
        #histos[name+'/tAgainstElectronMedium'].Fill(row.tAgainstElectronMedium,weight)     
        histos[name+'/tAgainstElectronMediumMVA5'].Fill(row.tAgainstElectronMediumMVA5,weight) 
        #histos[name+'/tAgainstElectronTight'].Fill(row.tAgainstElectronTight,weight)      
        histos[name+'/tAgainstElectronTightMVA5'].Fill(row.tAgainstElectronTightMVA5,weight)  
        histos[name+'/tAgainstElectronVTightMVA5'].Fill(row.tAgainstElectronVTightMVA5,weight) 


        #histos[name+'/tAgainstElectronLoose'].Fill(row.tAgainstMuonLoose,weight)
        histos[name+'/tAgainstElectronLoose3'].Fill(row.tAgainstMuonLoose3,weight)
        #histos[name+'/tAgainstElectronMedium'].Fill(row.tAgainstMuonMedium,weight)
        #histos[name+'/tAgainstElectronTight'].Fill(row.tAgainstMuonTight,weight)
        histos[name+'/tAgainstElectronTight3'].Fill(row.tAgainstMuonTight3,weight)

        #histos[name+'/tAgainstElectronLooseMVA'].Fill(row.tAgainstMuonLooseMVA,weight)
        #histos[name+'/tAgainstElectronMediumMVA'].Fill(row.tAgainstMuonMediumMVA,weight)
        #histos[name+'/tAgainstElectronTightMVA'].Fill(row.tAgainstMuonTightMVA,weight)

        histos[name+'/tDecayModeFinding'].Fill(row.tDecayModeFinding,weight)
        histos[name+'/tDecayModeFindingNewDMs'].Fill(row.tDecayModeFindingNewDMs,weight)
        histos[name+'/tDecayMode'].Fill(row.tDecayMode,weight)

        histos[name+'/tByLooseCombinedIsolationDeltaBetaCorr3Hits'].Fill(row.tByLooseCombinedIsolationDeltaBetaCorr3Hits,weight)
        histos[name+'/tByMediumCombinedIsolationDeltaBetaCorr3Hits'].Fill(row.tByMediumCombinedIsolationDeltaBetaCorr3Hits,weight)
        histos[name+'/tByTightCombinedIsolationDeltaBetaCorr3Hits'].Fill(row.tByTightCombinedIsolationDeltaBetaCorr3Hits,weight)

        histos[name+'/tByLooseIsolationMVA3newDMwLT'].Fill(row.tByLooseIsolationMVA3newDMwLT,weight)
        histos[name+'/tByMediumIsolationMVA3newDMwLT'].Fill(row.tByMediumIsolationMVA3newDMwLT,weight)
        histos[name+'/tByTightIsolationMVA3newDMwLT'].Fill(row.tByTightIsolationMVA3newDMwLT,weight)
        histos[name+'/tByVTightIsolationMVA3oldDMwLT'].Fill(row.tByVTightIsolationMVA3oldDMwLT,weight)
        histos[name+'/tByVVTightIsolationMVA3oldDMwLT'].Fill(row.tByVVTightIsolationMVA3oldDMwLT,weight)

        histos[name+'/tByLooseIsolationMVA3oldDMwLT'].Fill(row.tByLooseIsolationMVA3oldDMwLT,weight)
        histos[name+'/tByMediumIsolationMVA3oldDMwLT'].Fill(row.tByMediumIsolationMVA3oldDMwLT,weight)
        histos[name+'/tByTightIsolationMVA3oldDMwLT'].Fill(row.tByTightIsolationMVA3oldDMwLT,weight)
        histos[name+'/tByVTightIsolationMVA3oldDMwLT'].Fill(row.tByVTightIsolationMVA3oldDMwLT,weight)
        histos[name+'/tByVVTightIsolationMVA3oldDMwLT'].Fill(row.tByVVTightIsolationMVA3oldDMwLT,weight)

        #histos[name+'/tByLooseIsolationMVA3newDMwoLT'].Fill(row.tByLooseIsolationMVA3newDMwoLT,weight)
        #histos[name+'/tByMediumIsolationMVA3newDMwoLT'].Fill(row.tByMediumIsolationMVA3newDMwoLT,weight)
        #histos[name+'/tByTightIsolationMVA3newDMwoLT'].Fill(row.tByTightIsolationMVA3newDMwoLT,weight)
        #histos[name+'/tByVTightIsolationMVA3newDMwoLT'].Fill(row.tByVTightIsolationMVA3newDMwoLT,weight)
        #histos[name+'/tByVVTightIsolationMVA3newDMwoLT'].Fill(row.tByVVTightIsolationMVA3newDMwoLT,weight)
   
        #histos[name+'/tByLooseIsolationMVA3oldDMwoLT'].Fill(row.tByLooseIsolationMVA3oldDMwoLT,weight)
        #histos[name+'/tByMediumIsolationMVA3oldDMwoLT'].Fill(row.tByMediumIsolationMVA3oldDMwoLT,weight)
        #histos[name+'/tByTightIsolationMVA3oldDMwoLT'].Fill(row.tByTightIsolationMVA3oldDMwoLT,weight)
        #histos[name+'/tByVTightIsolationMVA3oldDMwoLT'].Fill(row.tByVTightIsolationMVA3oldDMwoLT,weight)
        #histos[name+'/tByVVTightIsolationMVA3oldDMwoLT'].Fill(row.tByVVTightIsolationMVA3oldDMwoLT,weight)

	histos[name+'/LT'].Fill(row.LT,weight)

        histos[name+'/collMass_type1'].Fill(collMass_type1(row),weight)
        histos[name+'/fullMT_type1'].Fill(fullMT(row.type1_pfMetEt,row.ePt,row.tPt,row.type1_pfMetPhi, row.ePhi, row.tPhi),weight)
        histos[name+'/fullPT_type1'].Fill(fullPT(row.type1_pfMetEt,row.ePt,row.tPt,row.type1_pfMetPhi, row.ePhi, row.tPhi),weight) 

	histos[name+'/type1_pfMetEt'].Fill(row.type1_pfMetEt,weight)

        histos[name+'/e_t_Mass'].Fill(row.e_t_Mass,weight)
        histos[name+'/e_t_Pt'].Fill(row.e_t_Pt,weight)
        histos[name+'/e_t_DR'].Fill(row.e_t_DR,weight)
        histos[name+'/e_t_DPhi'].Fill(row.e_t_DPhi,weight)
        histos[name+'/e_t_SS'].Fill(row.e_t_SS,weight)
	histos[name+'/e_t_ToMETDPhi_Ty1'].Fill(row.e_t_ToMETDPhi_Ty1,weight)

        histos[name+'/eJetBtag'].Fill(row.eJetBtag, weight)

        histos[name+'/muVetoPt5IsoIdVtx'].Fill(row.muVetoPt5IsoIdVtx, weight)
        histos[name+'/muVetoPt15IsoIdVtx'].Fill(row.muVetoPt15IsoIdVtx, weight)
        histos[name+'/tauVetoPt20Loose3HitsVtx'].Fill(row.tauVetoPt20Loose3HitsVtx, weight)
        histos[name+'/eVetoMVAIso'].Fill(row.eVetoMVAIso, weight)
        histos[name+'/jetVeto30'].Fill(row.jetVeto30, weight)
        #histos[name+'/jetVeto30PUCleanedLoose'].Fill(row.jetVeto30PUCleanedLoose, weight)
        #histos[name+'/jetVeto30PUCleanedTight'].Fill(row.jetVeto30PUCleanedTight, weight)

	histos[name+'/eRelPFIsoDB'].Fill(row.eRelPFIsoDB, weight)
        
	histos[name+'/ePhiMtPhi'].Fill(deltaPhi(row.ePhi,row.tPhi),weight)
        histos[name+'/ePhiMETPhiType1'].Fill(deltaPhi(row.ePhi,row.type1_pfMetPhi),weight)
        histos[name+'/tPhiMETPhiType1'].Fill(deltaPhi(row.tPhi,row.type1_pfMetPhi),weight)
	histos[name+'/tDecayMode'].Fill(row.tDecayMode, weight)
	histos[name+'/vbfJetVeto30'].Fill(row.vbfJetVeto30, weight)
     	histos[name+'/vbfJetVeto20'].Fill(row.vbfJetVeto20, weight)
        histos[name+'/vbfMVA'].Fill(row.vbfMVA, weight)
        histos[name+'/vbfMass'].Fill(row.vbfMass, weight)
        histos[name+'/vbfDeta'].Fill(row.vbfDeta, weight)
        histos[name+'/vbfj1eta'].Fill(row.vbfj1eta, weight)
        histos[name+'/vbfj2eta'].Fill(row.vbfj2eta, weight)
        histos[name+'/vbfVispt'].Fill(row.vbfVispt, weight)
        histos[name+'/vbfHrap'].Fill(row.vbfHrap, weight)
        histos[name+'/vbfDijetrap'].Fill(row.vbfDijetrap, weight)
        histos[name+'/vbfDphihj'].Fill(row.vbfDphihj, weight)
        histos[name+'/vbfDphihjnomet'].Fill(row.vbfDphihjnomet, weight)
        histos[name+'/vbfNJets'].Fill(row.vbfNJets, weight)
        #histos[name+'/vbfNJetsPULoose'].Fill(row.vbfNJetsPULoose, weight)
        #histos[name+'/vbfNJetsPUTight'].Fill(row.vbfNJetsPUTight, weight)





    def presel(self, row):
        if not row.isoMu24eta2p1Pass:
            return False
        return True

    def kinematics(self, row):
        #if row.mPt < 30:
        #    return False
        if row.ePt < 10:
             return False
        if abs(row.eEta) >= 2.3:
            return False
        if row.tPt<20 :
            return False
        if abs(row.tEta)>=2.5 :
            return False
        return True


    def oppositesign(self,row):
	if row.eCharge*row.tCharge!=-1:
            return False
	return True

    #def obj1_id(self, row):
    #    return bool(row.mPFIDTight)  
 
    def obj1_id(self,row):
    	 return (row.eMVANonTrigWP90>0) and (row.ePVDXY < 0.02) and (row.ePVDZ < 0.5)

    def obj2_id(self, row):
	return  row.tAgainstElectronMediumMVA5 and row.tAgainstElectronTight3 and row.tDecayModeFinding

    def vetos(self,row):
		return  (bool (row.muVetoPt5IsoIdVtx<1) and bool (row.eVetoMVAIso<1) and bool (row.tauVetoPt20Loose3HitsVtx<1) )

    #def obj1_iso(self, row):
    #    return bool(row.mRelPFIsoDBDefault <0.12)
   
    def obj1_iso(self,row):
         return bool(row.eRelPFIsoDB <0.1)

    def obj2_iso(self, row):
        return  row.tByTightCombinedIsolationDeltaBetaCorr3Hits

    def obj2_mediso(self, row):
	 return row.tByMediumCombinedIsolationDeltaBetaCorr3Hits

    def obj1_antiiso(self, row):
        return bool(row.eRelPFIsoDB >0.2) 

    def obj2_looseiso(self, row):
        return row.tByLooseCombinedIsolationDeltaBetaCorr3Hits


    def obj2_newiso(self, row):
        return row.tByVVTightIsolationMVA3oldDMwoLT 

    #def obj2_newlooseiso(self, row):
    #    return  row.tByLooseIsolationMVA3oldDMwoLT


    def process(self):
        event =0
        sel=False
        for row in self.tree:
            if event!=row.evt:   # This is just to ensure we get the (E,Tau) with the highest Pt
                event=row.evt    # In principle the code saves all the E+Tau posibilities, if an event has several combinations
                sel = False      # it will save them all.
            if sel==True:
                continue

            if not self.oppositesign(row):
                continue   

            if not self.kinematics(row): 
                continue
 
            if not self.obj1_iso(row):
                continue

            if not self.obj1_id(row):
                continue

            if not self.vetos (row):
                continue

            #self.fill_histos(row,'noTauID')

            #if not self.obj2_id (row):
            #    continue

            #self.fill_histos(row,'noiso')

            if self.obj2_iso(row):
              self.fill_histos(row,'preselection')
#              self.fill_histos(row,'oldisotight')
#
#              if self.gg(row):
#                  self.fill_histos(row,'oldisogg')
#
#              if self.boost(row):
#                  self.fill_histos(row,'oldisoboost')
#
#              if self.vbf(row):
#                  self.fill_histos(row,'oldisovbf')
# 
#            elif self.obj2_looseiso(row):
#
#              self.fill_histos(row,'oldisoloose')
#
#              if self.gg(row):
#                  self.fill_histos(row,'oldisoloosegg')
#
#              if self.boost(row):
#                  self.fill_histos(row,'oldisolooseboost')
#
#              if self.vbf(row):
#                  self.fill_histos(row,'oldisoloosevbf')
#
#
#            if self.obj2_newiso(row):
#
#              self.fill_histos(row,'newisotight')
#
#              if self.gg(row):
#                  self.fill_histos(row,'newisogg')
#
#              if self.boost(row):
#                  self.fill_histos(row,'newisoboost')
#
#              if self.vbf(row):
#                  self.fill_histos(row,'newisovbf')
#
#            elif self.obj2_newlooseiso(row):
#              
#              self.fill_histos(row,'newisoloose')
#
#              if self.gg(row):
#                  self.fill_histos(row,'newisoloosegg')
#
#              if self.boost(row):
#                  self.fill_histos(row,'newisolooseboost')
#
#              if self.vbf(row):
#                  self.fill_histos(row,'newisoloosevbf')
#
#
#            if self.gg(row):
#                self.fill_histos(row,'noisogg')
#
#            if self.boost(row):
#                self.fill_histos(row,'noisoboost')
#
#            if self.vbf(row):
#                self.fill_histos(row,'noisovbf')
#
            

            sel=True

    def finish(self):
        self.write_histos()
