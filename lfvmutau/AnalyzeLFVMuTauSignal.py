'''

Run LFV H->MuTau analysis in the mu+tau channel.

Authors: Maria Cepeda, Aaron Levine, Evan K. Friis, UW

'''

import MuTauTree
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
import glob
import os
#import FinalStateAnalysis.TagAndProbe.MuonPOGCorrections as MuonPOGCorrections
#import FinalStateAnalysis.TagAndProbe.H2TauCorrections as H2TauCorrections
import FinalStateAnalysis.TagAndProbe.PileupWeight as PileupWeight
import ROOT
import math

from math import sqrt, pi

isData = bool('true' in os.environ['isData'])
#checkZtt = bool('true' in os.environ['checkZtt'])


def deltaPhi(phi1, phi2):
  PHI = abs(phi1-phi2)
  if PHI<=pi:
      return PHI
  else:
      return 2*pi-PHI

def fullMT(met,mupt,taupt, metphi, muphi, tauphi):
	mux=mupt*math.cos(muphi)
	muy=mupt*math.sin(muphi)
        metx=met*math.cos(metphi)
        mety=met*math.sin(metphi)
        taux=taupt*math.cos(tauphi)
        tauy=taupt*math.sin(tauphi)
	full_et=met+mupt+taupt # for muon and tau I am approximating pt~et (M<<P)
	full_x=metx+mux+taux
        full_y=mety+muy+tauy
	full_mt_2 = full_et*full_et-full_x*full_x-full_y*full_y
	full_mt=0
	if (full_mt_2>0):
		full_mt= math.sqrt(full_mt_2)
	return full_mt

def fullPT(met,mupt,taupt, metphi, muphi, tauphi):
        mux=mupt*math.cos(muphi)
        muy=mupt*math.sin(muphi)
        metx=met*math.cos(metphi)
        mety=met*math.sin(metphi)
        taux=taupt*math.cos(tauphi)
        tauy=taupt*math.sin(tauphi)
        full_x=metx+mux+taux
        full_y=mety+muy+tauy
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

        mass=row.m_t_Mass/den

        #print '%4.2f, %4.2f, %4.2f, %4.2f, %4.2f' %(scaleMass(row), den, xth, METproj,mass)

        return mass


def NJ(ptThresh,j1,j2,j3,j4,j5,j6):
        if (j1 < ptThresh):
                return 0
        if (j2 < ptThresh):
                return 1
        if (j3 < ptThresh):
                return 2
        if (j4 < ptThresh):
                return 3
        if (j5 < ptThresh):
                return 4
        if (j6 < ptThresh):
                return 5
        return 6

def getFakeRateFactor(row, isoName):
  if (isoName == "old"):
    if (row.tDecayMode==0):
      fTauIso = 0.380
    elif (row.tDecayMode==1):
      fTauIso = 0.431
    elif (row.tDecayMode==10):
      fTauIso = 0.304
#    if (row.tEta <= 1.479):
#      if (row.tDecayMode==0):
#        fTauIso = 0.47
#      elif (row.tDecayMode==1):
#        fTauIso = 0.44
#      elif (row.tDecayMode==10):
#        fTauIso = 0.28
#    else:
#      if (row.tDecayMode==0):
#        fTauIso = 0.50
#      elif (row.tDecayMode==1):
#        fTauIso = 0.52
#      elif (row.tDecayMode==10):
#        fTauIso = 0.33
  if (isoName == "med"):
    if (row.tEta <= 1.479):
      if (row.tDecayMode==0):
        fTauIso = 0.70
      elif (row.tDecayMode==1):
        fTauIso = 0.68
      elif (row.tDecayMode==10):
        fTauIso = 0.51
    else:
      if (row.tDecayMode==0):
        fTauIso = 0.71
      elif (row.tDecayMode==1):
        fTauIso = 0.74
      elif (row.tDecayMode==10):
        fTauIso = 0.56
  if (isoName == "newTightLoose"):
    if (row.tEta <= 1.479):
      if (row.tDecayMode==0):
        fTauIso = 0.64
      elif (row.tDecayMode==1):
        fTauIso = 0.54
      elif (row.tDecayMode==10):
        fTauIso = 0.30
    else:
      if (row.tDecayMode==0):
        fTauIso = 0.60
      elif (row.tDecayMode==1):
        fTauIso = 0.49
      elif (row.tDecayMode==10):
        fTauIso = 0.36
  if (isoName == "newVTightLoose"):
    if (row.tEta <= 1.479):
      if (row.tDecayMode==0):
        fTauIso = 0.50
      elif (row.tDecayMode==1):
        fTauIso = 0.43
      elif (row.tDecayMode==10):
        fTauIso = 0.17
    else:
      if (row.tDecayMode==0):
        fTauIso = 0.48
      elif (row.tDecayMode==1):
        fTauIso = 0.25
      elif (row.tDecayMode==10):
        fTauIso = 0.23
  if (isoName == "newVVTightLoose"):
    if (row.tEta <= 1.479):
      if (row.tDecayMode==0):
        fTauIso = 0.41
      elif (row.tDecayMode==1):
        fTauIso = 0.29
      elif (row.tDecayMode==10):
        fTauIso = 0.10
    else:
      if (row.tDecayMode==0):
        fTauIso = 0.30
      elif (row.tDecayMode==1):
        fTauIso = 0.15
      elif (row.tDecayMode==10):
        fTauIso = 0.16
  if (isoName == "newTightVLoose"):
    if (row.tEta <= 1.479):
      if (row.tDecayMode==0):
        fTauIso = 0.47
      elif (row.tDecayMode==1):
        fTauIso = 0.38
      elif (row.tDecayMode==10):
        fTauIso = 0.13
    else:
      if (row.tDecayMode==0):
        fTauIso = 0.44
      elif (row.tDecayMode==1):
        fTauIso = 0.32
      elif (row.tDecayMode==10):
        fTauIso = 0.14
  if (isoName == "newVTightVLoose"):
    if (row.tEta <= 1.479):
      if (row.tDecayMode==0):
        fTauIso = 0.36
      elif (row.tDecayMode==1):
        fTauIso = 0.31
      elif (row.tDecayMode==10):
        fTauIso = 0.08
    else:
      if (row.tDecayMode==0):
        fTauIso = 0.35
      elif (row.tDecayMode==1):
        fTauIso = 0.17
      elif (row.tDecayMode==10):
        fTauIso = 0.09
  if (isoName == "newVVTightVLoose"):
    if (row.tEta <= 1.479):
      if (row.tDecayMode==0):
        fTauIso = 0.30
      elif (row.tDecayMode==1):
        fTauIso = 0.21
      elif (row.tDecayMode==10):
        fTauIso = 0.05
    else:
      if (row.tDecayMode==0):
        fTauIso = 0.22
      elif (row.tDecayMode==1):
        fTauIso = 0.10
      elif (row.tDecayMode==10):
        fTauIso = 0.06
  '''
  if (isoName == "old"):
    if (row.tDecayMode==0):
      fTauIso = 0.48
    elif (row.tDecayMode==1):
      fTauIso = 0.46
    elif (row.tDecayMode==10):
      fTauIso = 0.30
  elif (isoName == "newTightLoose"):
    if (row.tDecayMode==0):
      fTauIso =0.63
    elif (row.tDecayMode==1):
      fTauIso = 0.53
    elif (row.tDecayMode==10):
      fTauIso = 0.31
  elif (isoName == "newVTightLoose"):
    if (row.tDecayMode==0):
      fTauIso =0.50
    elif (row.tDecayMode==1):
      fTauIso = 0.40
    elif (row.tDecayMode==10):
      fTauIso = 0.19
  elif (isoName == "newVVTightLoose"):
    if (row.tDecayMode==0):
      fTauIso =0.39
    elif (row.tDecayMode==1):
      fTauIso = 0.26
    elif (row.tDecayMode==10):
      fTauIso = 0.12
  elif (isoName == "newTightVLoose"):
    if (row.tDecayMode==0):
      fTauIso =0.46
    elif (row.tDecayMode==1):
      fTauIso = 0.37
    elif (row.tDecayMode==10):
      fTauIso = 0.13
  elif (isoName == "newVTightVLoose"):
    if (row.tDecayMode==0):
      fTauIso =0.36
    elif (row.tDecayMode==1):
      fTauIso = 0.28
    elif (row.tDecayMode==10):
      fTauIso = 0.08
  elif (isoName == "newVVTightVLoose"):
    if (row.tDecayMode==0):
      fTauIso =0.28
    elif (row.tDecayMode==1):
      fTauIso = 0.19
    elif (row.tDecayMode==10):
      fTauIso = 0.05
  elif (isoName =="newDM"):
    if (row.tDecayMode==0):
      fTauIso =0.26
    elif (row.tDecayMode==1):
      fTauIso =0.16
    elif (row.tDecayMode==10):
      fTauIso = 0.03
    '''
  fakeRateFactor = fTauIso/(1.0-fTauIso)
  return fakeRateFactor
################################################################################
#### MC-DATA and PU corrections ################################################
################################################################################

pu_distributions = glob.glob(os.path.join(
        'inputs', os.environ['jobid'], 'data_SingleMu*pu.root'))

pu_corrector = PileupWeight.PileupWeight(
	'Asympt25ns', *pu_distributions)

def mc_corrector_2015(row):
	pu = pu_corrector(row.nTruePU)
        
        return pu

mc_corrector = mc_corrector_2015

class AnalyzeLFVMuTauSignal(MegaBase):
    tree = 'mt/final/Ntuple'
    #tree = 'New_Tree'

    def __init__(self, tree, outfile, **kwargs):
        super(AnalyzeLFVMuTauSignal, self).__init__(tree, outfile, **kwargs)
        # Use the cython wrapper
        self.tree = MuTauTree.MuTauTree(tree)
        self.out = outfile
        self.histograms = {}

    def begin(self):

#        names=["oldisotight","oldisoloose","oldisogg","oldisoboost","oldisovbf", "oldisoloosegg","oldisolooseboost","oldisoloosevbf",
#              "newisotight","newisoloose","newisogg","newisoboost","newisovbf",  "newisoloosegg","newisolooseboost","newisoloosevbf",
#              "noisogg","noisoboost","noisovbf",
#              "noTauID","noiso"]
        #names=["gg","boost","vbf","gg_mediso","boost_mediso","vbf_mediso","gg_newVVTightiso","boost_newVVTightiso","vbf_newVVTightiso","gg_newVTightiso","boost_newVTightiso","vbf_newVTightiso","gg_newTightiso","boost_newTightiso","vbf_newTightiso","antiiso_gg","antiiso_boost","antiiso_vbf","antiiso_gg_mediso","antiiso_boost_mediso","antiiso_vbf_mediso","antiiso_gg_newVVTightVLooseiso","antiiso_boost_newVVTightVLooseiso","antiiso_vbf_newVVTightVLooseiso","antiiso_gg_newVTightVLooseiso","antiiso_boost_newVTightVLooseiso","antiiso_vbf_newVTightVLooseiso","antiiso_gg_newTightVLooseiso","antiiso_boost_newTightVLooseiso","antiiso_vbf_newTightVLooseiso","antiiso_gg_newVVTightLooseiso","antiiso_boost_newVVTightLooseiso","antiiso_vbf_newVVTightLooseiso","antiiso_gg_newVTightLooseiso","antiiso_boost_newVTightLooseiso","antiiso_vbf_newVTightLooseiso","antiiso_gg_newTightLooseiso","antiiso_boost_newTightLooseiso","antiiso_vbf_newTightLooseiso","ssgg","ssboost","ssvbf","ssgg_mediso","ssboost_mediso","ssvbf_mediso","ssgg_newVVTightiso","ssboost_newVVTightiso","ssvbf_newVVTightiso","ssgg_newVTightiso","ssboost_newVTightiso","ssvbf_newVTightiso","ssgg_newTightiso","ssboost_newTightiso","ssvbf_newTightiso","antiiso_ssgg","antiiso_ssboost","antiiso_ssvbf","antiiso_ssgg_mediso","antiiso_ssboost_mediso","antiiso_ssvbf_mediso","antiiso_ssgg_newVVTightVLooseiso","antiiso_ssboost_newVVTightVLooseiso","antiiso_ssvbf_newVVTightVLooseiso","antiiso_ssgg_newVTightVLooseiso","antiiso_ssboost_newVTightVLooseiso","antiiso_ssvbf_newVTightVLooseiso","antiiso_ssgg_newTightVLooseiso","antiiso_ssboost_newTightVLooseiso","antiiso_ssvbf_newTightVLooseiso","antiiso_ssgg_newVVTightLooseiso","antiiso_ssboost_newVVTightLooseiso","antiiso_ssvbf_newVVTightLooseiso","antiiso_ssgg_newVTightLooseiso","antiiso_ssboost_newVTightLooseiso","antiiso_ssvbf_newVTightLooseiso","antiiso_ssgg_newTightLooseiso","antiiso_ssboost_newTightLooseiso","antiiso_ssvbf_newTightLooseiso"]
        names=["preselection","gg","boost","vbf","sspreselection","ssgg","ssboost","ssvbf","antiiso_preselection","antiiso_gg","antiiso_boost","antiiso_vbf","antiiso_sspreselection","antiiso_ssgg","antiiso_ssboost","antiiso_ssvbf"]
        namesize = len(names)
	for x in range(0,namesize):

            self.book(names[x], "weight", "Event weight", 100, 0, 5)
            self.book(names[x], "GenWeight", "Gen level weight", 200000 ,-1000000, 1000000)
            
            #self.book(names[x], "Event", "Event", 100000001,-0.5,100000000.5)
            self.book(names[x], "rho", "Fastjet #rho", 100, 0, 25)
            self.book(names[x], "nvtx", "Number of vertices", 101, -0.5, 100.5)
            self.book(names[x], "prescale", "HLT prescale", 21, -0.5, 20.5)
   
            #self.book(names[x], "jet1Pt", "Muon  Pt", 300,0,300)
            #self.book(names[x], "jet2Pt", "Muon  Pt", 300,0,300)
            #self.book(names[x], "jet2Eta", "Muon  Pt", 200,-5,5)
            #self.book(names[x], "jet1Eta", "Muon  Pt", 200,-5,5)
            #self.book(names[x], "jet1PULoose ", "Muon  Pt", 3,-1,2)
            #self.book(names[x], "jet2PULoose ", "Muon  Pt", 3,-1,2)
            #self.book(names[x], "jet1PUMVA ", "Muon  Pt", 100,-1,1)
            #self.book(names[x], "jet2PUMVA ", "Muon  Pt", 100,-1,1)
            #self.book(names[x], "jet1PUTight ", "Muon  Pt", 3,-1,2)
            #self.book(names[x], "jet2PUTight ", "Muon  Pt", 3,-1,2)
            self.book(names[x], "jet1Pt", "", 300,0,300)
            self.book(names[x], "jet2Pt", "", 300,0,300)
            self.book(names[x], "jet3Pt", "", 300,0,300)
            self.book(names[x], "jet4Pt", "", 300,0,300)
            self.book(names[x], "jet5Pt", "", 300,0,300)


            self.book(names[x], "jet1Eta", "", 200,-5,5)
            self.book(names[x], "jet2Eta", "", 200,-5,5)
            self.book(names[x], "jet3Eta", "", 200,-5,5)
            self.book(names[x], "jet4Eta", "", 200,-5,5)
            self.book(names[x], "jet5Eta", "", 200,-5,5)

            self.book(names[x], "jet1Phi", "", 280,-7,7)
            self.book(names[x], "jet2Phi", "", 280,-7,7)
            self.book(names[x], "jet3Phi", "", 280,-7,7)
            self.book(names[x], "jet4Phi", "", 280,-7,7)
            self.book(names[x], "jet5Phi", "", 280,-7,7)
 
            self.book(names[x], "mPt", "Muon  Pt", 300,0,300)
            self.book(names[x], "mEta", "Muon  eta", 100, -2.5, 2.5)
            self.book(names[x], "mMtToPfMet_Ty1", "Muon MT (PF Ty1)", 200, 0, 200)
            self.book(names[x], "mCharge", "Muon Charge", 5, -2, 2)

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


            #self.book(names[x], "tAgainstMuonLoose", "tAgainstMuonLoose", 2,-0.5,1.5)
            self.book(names[x], "tAgainstMuonLoose3", "tAgainstMuonLoose3", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstMuonMedium", "tAgainstMuonMedium", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstMuonTight", "tAgainstMuonTight", 2,-0.5,1.5)
            self.book(names[x], "tAgainstMuonTight3", "tAgainstMuonTight3", 2,-0.5,1.5)

            #self.book(names[x], "tAgainstMuonLooseMVA", "tAgainstMuonLooseMVA", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstMuonMediumMVA", "tAgainstMuonMediumMVA", 2,-0.5,1.5)
            #self.book(names[x], "tAgainstMuonTightMVA", "tAgainstMuonTightMVA", 2,-0.5,1.5)

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

            self.book(names[x], 'mPixHits', 'Mu 1 pix hits', 10, -0.5, 9.5)
            self.book(names[x], 'mJetBtag', 'Mu 1 JetBtag', 100, -5.5, 9.5)
    	   
            self.book(names[x],"collMass_type1","collMass_type1",500,0,500);
            self.book(names[x],"fullMT_type1","fullMT_type1",500,0,500);
            self.book(names[x],"fullPT_type1","fullPT_type1",500,0,500);	    
    	    self.book(names[x], "LT", "ht", 400, 0, 400)
            self.book(names[x], "type1_pfMetEt", "Type1 MET", 200, 0, 200)
    
            self.book(names[x], "m_t_Mass", "Muon + Tau Mass", 200, 0, 200)
            self.book(names[x], "m_t_Pt", "Muon + Tau Pt", 200, 0, 200)
            self.book(names[x], "m_t_DR", "Muon + Tau DR", 100, 0, 10)
            self.book(names[x], "m_t_DPhi", "Muon + Tau DPhi", 100, 0, 4)
            self.book(names[x], "m_t_SS", "Muon + Tau SS", 5, -2, 2)
            #self.book(names[x], "m_t_ToMETDPhi_Ty1", "Muon Tau DPhi to MET", 100, 0, 4)
    
            # Vetoes
            self.book(names[x], 'muVetoPt5IsoIdVtx', 'Number of extra muons', 5, -0.5, 4.5)
	    self.book(names[x], 'muVetoPt15IsoIdVtx', 'Number of extra muons', 5, -0.5, 4.5)
            self.book(names[x], 'tauVetoPt20Loose3HitsVtx', 'Number of extra taus', 5, -0.5, 4.5)
            self.book(names[x], 'eVetoMVAIso', 'Number of extra CiC tight electrons', 5, -0.5, 4.5)
   
            #self.book(names[x], 'jetVeto30PUCleanedTight', 'Number of extra jets', 5, -0.5, 4.5)
            #self.book(names[x], 'jetVeto30PUCleanedLoose', 'Number of extra jets', 5, -0.5, 4.5)
            self.book(names[x], 'jetVeto30', 'Number of extra jets', 5, -0.5, 4.5)
            self.book(names[x], 'NumJets30', 'Number of extra jets pT > 30 (cleaned & id)',7,-0.5,6.5)
	    #Isolation
	    self.book(names[x], 'mRelPFIsoDBDefault' ,'Muon Isolation', 100, 0.0,1.0)
   
 
            self.book(names[x], "mPhiMtPhi", "", 100, 0,4)
            self.book(names[x], "mPhiMETPhiType1", "", 100, 0,4)
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

    def correction(self,row):
	return mc_corrector(row)
	     
    def fakeRateMethod(self,row,isoName):
        return getFakeRateFactor(row,isoName)
     
    def fill_histos(self, row,name='gg',fakeRate = False, isoName="old"):
        histos = self.histograms
        weight=1
        if (not(isData)):
		weight = row.GenWeight * self.correction(row)
#          if (row.GenWeight>=0):
#            weight=1
#          else:
#            weight=-1
        if (fakeRate == True):
          weight=weight*self.fakeRateMethod(row,isoName)
        histos[name+'/weight'].Fill(weight)
        histos[name+'/GenWeight'].Fill(row.GenWeight)
        #histos[name+'/Event'].Fill(row.evt,weight)
        histos[name+'/rho'].Fill(row.rho, weight)
        histos[name+'/nvtx'].Fill(row.nvtx, weight)
        histos[name+'/prescale'].Fill(row.doubleMuPrescale, weight)
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
        histos[name+'/jet1Pt'].Fill(row.jet1Pt, weight)
        histos[name+'/jet2Pt'].Fill(row.jet2Pt, weight)
        histos[name+'/jet3Pt'].Fill(row.jet3Pt, weight)
        histos[name+'/jet4Pt'].Fill(row.jet4Pt, weight)
        histos[name+'/jet5Pt'].Fill(row.jet5Pt, weight)
        histos[name+'/jet1Eta'].Fill(row.jet1Eta, weight)
        histos[name+'/jet2Eta'].Fill(row.jet2Eta, weight)
        histos[name+'/jet3Eta'].Fill(row.jet3Eta, weight)
        histos[name+'/jet4Eta'].Fill(row.jet4Eta, weight)
        histos[name+'/jet5Eta'].Fill(row.jet5Eta, weight)
        histos[name+'/jet1Phi'].Fill(row.jet1Phi, weight)
        histos[name+'/jet2Phi'].Fill(row.jet2Phi, weight)
        histos[name+'/jet3Phi'].Fill(row.jet3Phi, weight)
        histos[name+'/jet4Phi'].Fill(row.jet4Phi, weight)
        histos[name+'/jet5Phi'].Fill(row.jet5Phi, weight)

        histos[name+'/mPt'].Fill(row.mPt, weight)
        histos[name+'/mEta'].Fill(row.mEta, weight)
        histos[name+'/mMtToPfMet_Ty1'].Fill(row.mMtToPfMet_type1,weight)
        histos[name+'/mCharge'].Fill(row.mCharge, weight)
        histos[name+'/tPt'].Fill(row.tPt, weight)
        histos[name+'/tEta'].Fill(row.tEta, weight)
        histos[name+'/tMtToPfMet_Ty1'].Fill(row.tMtToPfMet_type1,weight)
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


        #histos[name+'/tAgainstMuonLoose'].Fill(row.tAgainstMuonLoose,weight)
        histos[name+'/tAgainstMuonLoose3'].Fill(row.tAgainstMuonLoose3,weight)
        #histos[name+'/tAgainstMuonMedium'].Fill(row.tAgainstMuonMedium,weight)
        #histos[name+'/tAgainstMuonTight'].Fill(row.tAgainstMuonTight,weight)
        histos[name+'/tAgainstMuonTight3'].Fill(row.tAgainstMuonTight3,weight)

        #histos[name+'/tAgainstMuonLooseMVA'].Fill(row.tAgainstMuonLooseMVA,weight)
        #histos[name+'/tAgainstMuonMediumMVA'].Fill(row.tAgainstMuonMediumMVA,weight)
        #histos[name+'/tAgainstMuonTightMVA'].Fill(row.tAgainstMuonTightMVA,weight)

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
        histos[name+'/fullMT_type1'].Fill(fullMT(row.type1_pfMetEt,row.mPt,row.tPt,row.type1_pfMetPhi, row.mPhi, row.tPhi),weight)
        histos[name+'/fullPT_type1'].Fill(fullPT(row.type1_pfMetEt,row.mPt,row.tPt,row.type1_pfMetPhi, row.mPhi, row.tPhi),weight) 

	histos[name+'/type1_pfMetEt'].Fill(row.type1_pfMetEt,weight)

        histos[name+'/m_t_Mass'].Fill(row.m_t_Mass,weight)
        histos[name+'/m_t_Pt'].Fill(row.m_t_Pt,weight)
        histos[name+'/m_t_DR'].Fill(row.m_t_DR,weight)
        histos[name+'/m_t_DPhi'].Fill(row.m_t_DPhi,weight)
        histos[name+'/m_t_SS'].Fill(row.m_t_SS,weight)
	#histos[name+'/m_t_ToMETDPhi_Ty1'].Fill(row.m_t_ToMETDPhi_type1,weight)

        histos[name+'/mPixHits'].Fill(row.mPixHits, weight)
        histos[name+'/mJetBtag'].Fill(row.mJetBtag, weight)

        histos[name+'/muVetoPt5IsoIdVtx'].Fill(row.muVetoPt5IsoIdVtx, weight)
        histos[name+'/muVetoPt15IsoIdVtx'].Fill(row.muVetoPt15IsoIdVtx, weight)
        histos[name+'/tauVetoPt20Loose3HitsVtx'].Fill(row.tauVetoPt20Loose3HitsVtx, weight)
        histos[name+'/eVetoMVAIso'].Fill(row.eVetoMVAIso, weight)
        histos[name+'/jetVeto30'].Fill(row.jetVeto30, weight)
        histos[name+'/NumJets30'].Fill(NJ(30,row.jet1Pt,row.jet2Pt,row.jet3Pt,row.jet4Pt,row.jet5Pt,row.jet6Pt),weight)

        #histos[name+'/jetVeto30PUCleanedLoose'].Fill(row.jetVeto30PUCleanedLoose, weight)
        #histos[name+'/jetVeto30PUCleanedTight'].Fill(row.jetVeto30PUCleanedTight, weight)

	histos[name+'/mRelPFIsoDBDefault'].Fill(row.mRelPFIsoDBDefault, weight)
        
	histos[name+'/mPhiMtPhi'].Fill(deltaPhi(row.mPhi,row.tPhi),weight)
        histos[name+'/mPhiMETPhiType1'].Fill(deltaPhi(row.mPhi,row.type1_pfMetPhi),weight)
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
        if not row.singleIsoMu20Pass:
            return False
        return True

    def isZtt(self,row):
        if (checkZtt and not row.isZtautau):
            return False
        return True

    def kinematics(self, row):
        #if row.mPt < 30:
        #    return False
        if row.mPt < 25:
             return False
        if abs(row.mEta) >= 2.1:
            return False
        if row.tPt<30 :
            return False
        if abs(row.tEta)>=2.3 :
            return False
        return True

    def noHF(self,row):
	if abs(row.jet1Eta) >= 2.0
 		return False
        if abs(row.jet2Eta) >= 2.0
                return False
        if abs(row.jet3Eta) >= 2.0
                return False
        if abs(row.jet4Eta) >= 2.0
                return False
        if abs(row.jet5Eta) >= 2.0
                return False
        if abs(row.jet6Eta) >= 2.0
                return False

    def gg(self,row):
       if deltaPhi(row.mPhi, row.tPhi) <2.7:
           return False
       if row.mPt < 45:
           return False
       if row.tPt < 35:
           return False
       if row.tMtToPfMet_type1 > 50:
           return False
       if row.jetVeto30!=0:
           return False
       return True

    def boost(self,row):
          if row.jetVeto30!=1:
            return False
          if row.mPt < 35:
                return False
          if row.tPt < 40:
                return False
          if row.tMtToPfMet_type1 > 50:
                return False
          return True

    def vbf(self,row):
        if row.mPt < 30:
		return False
        if row.tPt < 40:
		return False
	if row.tMtToPfMet_type1 > 50:
		return False
        #if row.jetVeto30<2:
        #    return False
        if NJ(30,row.jet1Pt,row.jet2Pt,row.jet3Pt,row.jet4Pt,row.jet5Pt,row.jet6Pt) < 2:
	     return False
	if(row.vbfNJets<2):
	    return False
	if(abs(row.vbfDeta)<3.5):
	    return False
        if row.vbfMass < 600:
	    return False
        if row.vbfJetVeto30 > 0:
            return False
        return True

    def oppositesign(self,row):
	if row.mCharge*row.tCharge!=-1:
            return False
	return True

    #def obj1_id(self, row):
    #    return bool(row.mPFIDTight)  
 
    def obj1_id(self,row):
    	 return row.mIsGlobal and row.mIsPFMuon and (row.mNormTrkChi2<10) and (row.mMuonHits > 0) and (row.mMatchedStations > 1) and (row.mPVDXY < 0.02) and (row.mPVDZ < 0.5) and (row.mPixHits > 0) and (row.mTkLayersWithMeasurement > 5)

    def obj2_id(self, row):
	return  row.tAgainstElectronMediumMVA5 and row.tAgainstMuonTight3 and row.tDecayModeFinding

    def vetos(self,row):
		return  (bool (row.muVetoPt5IsoIdVtx<1) and bool (row.eVetoMVAIso<1) and bool (row.tauVetoPt20Loose3HitsVtx<1) )

    #def obj1_iso(self, row):
    #    return bool(row.mRelPFIsoDBDefault <0.12)
   
    def obj1_iso(self,row):
         return bool(row.mRelPFIsoDBDefault <0.1)

    def obj2_iso(self, row):
        return  row.tByTightCombinedIsolationDeltaBetaCorr3Hits

    def obj2_mediso(self, row):
	 return row.tByMediumCombinedIsolationDeltaBetaCorr3Hits

    def obj1_antiiso(self, row):
        return bool(row.mRelPFIsoDBDefault >0.2) 


    def obj2_antiiso(self,row):
        return ( not(row.tByTightCombinedIsolationDeltaBetaCorr3Hits) and row.tByLooseCombinedIsolationDeltaBetaCorr3Hits)
    def obj2_antimediso(self,row):
        return ( not(row.tByMediumCombinedIsolationDeltaBetaCorr3Hits) and row.tByLooseCombinedIsolationDeltaBetaCorr3Hits)
    def obj2_antinewVVTightVLooseiso(self,row):
        return ( not(row.tByVVTightIsolationMVA3oldDMwLT) and row.tByVLooseIsolationMVA3oldDMwLT)
    def obj2_antinewVTightVLooseiso(self,row):
        return ( not(row.tByVTightIsolationMVA3oldDMwLT) and row.tByVLooseIsolationMVA3oldDMwLT)
    def obj2_antinewTightVLooseiso(self,row):
        return ( not(row.tByTightIsolationMVA3oldDMwLT) and row.tByVLooseIsolationMVA3oldDMwLT)
    def obj2_antinewVVTightLooseiso(self,row):
        return ( not(row.tByVVTightIsolationMVA3oldDMwLT) and row.tByLooseIsolationMVA3oldDMwLT)
    def obj2_antinewVTightLooseiso(self,row):
        return ( not(row.tByVTightIsolationMVA3oldDMwLT) and row.tByLooseIsolationMVA3oldDMwLT)
    def obj2_antinewTightLooseiso(self,row):
        return ( not(row.tByTightIsolationMVA3oldDMwLT) and row.tByLooseIsolationMVA3oldDMwLT)
    def obj2_antinewisonewdm(self,row):
        return ( not(row.tByVVTightIsolationMVA3newDMwLT) and row.tByVLooseIsolationMVA3newDMwLT)
    

    def obj2_looseiso(self, row):
        return row.tByLooseCombinedIsolationDeltaBetaCorr3Hits

    def obj2_newTightiso(self, row):
        return row.tByTightIsolationMVA3oldDMwLT
    def obj2_newVTightiso(self, row):
        return row.tByVTightIsolationMVA3oldDMwLT
    def obj2_newVVTightiso(self, row):
        return row.tByVVTightIsolationMVA3oldDMwLT
    def obj2_newlooseiso(self,row):
        return row.tByLooseIsolationMVA3oldDMwLT
    def obj2_newVlooseiso(self,row):
        return row.tByVLooseIsolationMVA3oldDMwLT
    def obj2_newisonewdm(self, row):
        return row.tByVVTightIsolationMVA3newDMwLT
    def obj2_newlooseisonewdm(self,row):
        return row.tByVLooseIsolationMVA3newDMwLT

    #def obj2_newlooseiso(self, row):
    #    return  row.tByLooseIsolationMVA3oldDMwoLT


    def process(self):
        event =0
        sel=False
        for row in self.tree:
            #print "event: " + str(row.evt)
            if event!=row.evt:   # This is just to ensure we get the (Mu,Tau) with the highest Pt
                event=row.evt    # In principle the code saves all the MU+Tau posibilities, if an event has several combinations
                sel = False      # it will save them all.
            #    print "setting sel to false"
            if sel==True:
                #print "sel equals true"
                continue

            if not self.presel(row):
                continue
            #if not self.isZtt(row):
            #    continue
            if not self.kinematics(row): 
                continue
 
            if not self.obj1_iso(row):
                continue

            if not self.obj1_id(row):
                continue

            if not self.vetos (row):
                continue

            #self.fill_histos(row,'noTauID')

            if not self.obj2_id (row):
                continue

            #self.fill_histos(row,'noiso')

            #if not self.obj2_iso(row):
            #    continue
#              self.fill_histos(row,'oldisotight')a
            if self.oppositesign(row):
              if self.obj2_iso(row):
                self.fill_histos(row,'preselection')
                if self.gg(row):
                    self.fill_histos(row,'gg')
  
                elif self.boost(row):
                    self.fill_histos(row,'boost')
  
                elif self.vbf(row):
                    self.fill_histos(row,'vbf')
		if self.NoHF(row):
		    self.fill_histos(row,'noHFpreselection')
                    if self.gg(row):
                        self.fill_histos(row,'noHFgg')

                    elif self.boost(row):
                        self.fill_histos(row,'noHFboost')

                    elif self.vbf(row):
                        self.fill_histos(row,'noHFvbf')
            if self.oppositesign(row):
              '''
              if self.obj2_mediso(row):
                if self.gg(row):
                    self.fill_histos(row,'gg_mediso')

                elif self.boost(row):
                    self.fill_histos(row,'boost_mediso')

                elif self.vbf(row):
                    self.fill_histos(row,'vbf_mediso')
              if self.obj2_newTightiso(row):
                if self.gg(row):
                    self.fill_histos(row,'gg_newTightiso')
                elif self.boost(row):
                    self.fill_histos(row,'boost_newTightiso')
                elif self.vbf(row):
                    self.fill_histos(row,'vbf_newTightiso')
              if self.obj2_newVTightiso(row):
                if self.gg(row):
                    self.fill_histos(row,'gg_newVTightiso')
                elif self.boost(row):
                    self.fill_histos(row,'boost_newVTightiso')
                elif self.vbf(row):
                    self.fill_histos(row,'vbf_newVTightiso')
              if self.obj2_newVVTightiso(row):
                if self.gg(row):
                    self.fill_histos(row,'gg_newVVTightiso')
                elif self.boost(row):
                    self.fill_histos(row,'boost_newVVTightiso')
                elif self.vbf(row):
                    self.fill_histos(row,'vbf_newVVTightiso')
#              if self.obj2_newisonewdm(row):
#                if self.gg(row):
#                    self.fill_histos(row,'gg_newiso_newdm')
# 
#                elif self.boost(row):
#                    self.fill_histos(row,'boost_newiso_newdm')
# 
#                elif self.vbf(row):
#                    self.fill_histos(row,'vbf_newiso_newdm')
            '''
              if self.obj2_antiiso(row):
                self.fill_histos(row,'antiiso_preselection',True,'old')
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg', True,'old')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost', True,'old')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf', True,'old')
              '''
              if self.obj2_antimediso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg_mediso', True,'med')

                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost_mediso', True,'med')

                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf_mediso', True,'med')

              if self.obj2_antinewVVTightVLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg_newVVTightVLooseiso', True,'newVVTightVLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost_newVVTightVLooseiso', True,'newVVTightVLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf_newVVTightVLooseiso', True,'newVVTightVLoose')
              if self.obj2_antinewVTightVLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg_newVTightVLooseiso', True,'newVTightVLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost_newVTightVLooseiso', True,'newVTightVLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf_newVTightVLooseiso', True,'newVTightVLoose')
              if self.obj2_antinewTightVLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg_newTightVLooseiso', True,'newTightVLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost_newTightVLooseiso', True,'newTightVLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf_newTightVLooseiso', True,'newTightVLoose')
              if self.obj2_antinewVVTightLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg_newVVTightLooseiso', True,'newVVTightLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost_newVVTightLooseiso', True,'newVVTightLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf_newVVTightLooseiso', True,'newVVTightLoose')
              if self.obj2_antinewVTightLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg_newVTightLooseiso', True,'newVTightLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost_newVTightLooseiso', True,'newVTightLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf_newVTightLooseiso', True,'newVTightLoose')
              if self.obj2_antinewTightLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_gg_newTightLooseiso', True,'newTightLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_boost_newTightLooseiso', True,'newTightLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_vbf_newTightLooseiso', True,'newTightLoose')
#              if self.obj2_antinewisonewdm(row):
#                if self.gg(row):
#                    self.fill_histos(row,'antiiso_gg_newiso_newdm', True,'newDM')
# 
#                elif self.boost(row):
#                    self.fill_histos(row,'antiiso_boost_newiso_newdm', True,'newDM')
# 
#                elif self.vbf(row):
#                    self.fill_histos(row,'antiiso_vbf_newiso_newdm', True,'newDM')
               '''
            elif not self.oppositesign(row):
              if self.obj2_iso(row):
                self.fill_histos(row,'sspreselection')
                if self.gg(row):
                    self.fill_histos(row,'ssgg')
  
                elif self.boost(row):
                    self.fill_histos(row,'ssboost')
  
                elif self.vbf(row):
                    self.fill_histos(row,'ssvbf')
              '''
              if self.obj2_mediso(row):
                if self.gg(row):
                    self.fill_histos(row,'ssgg_mediso')

                elif self.boost(row):
                    self.fill_histos(row,'ssboost_mediso')

                elif self.vbf(row):
                    self.fill_histos(row,'ssvbf_mediso')
              if self.obj2_newTightiso(row):
                if self.gg(row):
                    self.fill_histos(row,'ssgg_newTightiso')
                elif self.boost(row):
                    self.fill_histos(row,'ssboost_newTightiso')
                elif self.vbf(row):
                    self.fill_histos(row,'ssvbf_newTightiso')
              if self.obj2_newVTightiso(row):
                if self.gg(row):
                    self.fill_histos(row,'ssgg_newVTightiso')
                elif self.boost(row):
                    self.fill_histos(row,'ssboost_newVTightiso')
                elif self.vbf(row):
                    self.fill_histos(row,'ssvbf_newVTightiso')
              if self.obj2_newVVTightiso(row):
                if self.gg(row):
                    self.fill_histos(row,'ssgg_newVVTightiso')
                elif self.boost(row):
                    self.fill_histos(row,'ssboost_newVVTightiso')
                elif self.vbf(row):
                    self.fill_histos(row,'ssvbf_newVVTightiso')
#              if self.obj2_newisonewdm(row):
#                if self.gg(row):
#                    self.fill_histos(row,'ssgg_newiso_newdm')
# 
#                elif self.boost(row):
#                    self.fill_histos(row,'ssboost_newiso_newdm')
# 
#                elif self.vbf(row):
#                    self.fill_histos(row,'ssvbf_newiso_newdm')
              '''
              if self.obj2_antiiso(row):
                self.fill_histos(row,'antiiso_sspreselection',True,'old')
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg', True,'old')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost', True,'old')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf', True,'old')
              '''
              if self.obj2_antimediso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg_mediso', True,'med')

                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost_mediso', True,'med')

                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf_mediso', True,'med')
              if self.obj2_antinewVVTightVLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg_newVVTightVLooseiso', True,'newVVTightVLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost_newVVTightVLooseiso', True,'newVVTightVLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf_newVVTightVLooseiso', True,'newVVTightVLoose')
              if self.obj2_antinewVTightVLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg_newVTightVLooseiso', True,'newVTightVLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost_newVTightVLooseiso', True,'newVTightVLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf_newVTightVLooseiso', True,'newVTightVLoose')
              if self.obj2_antinewTightVLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg_newTightVLooseiso', True,'newTightVLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost_newTightVLooseiso', True,'newTightVLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf_newTightVLooseiso', True,'newTightVLoose')
              if self.obj2_antinewVVTightLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg_newVVTightLooseiso', True,'newVVTightLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost_newVVTightLooseiso', True,'newVVTightLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf_newVVTightLooseiso', True,'newVVTightLoose')
              if self.obj2_antinewVTightLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg_newVTightLooseiso', True,'newVTightLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost_newVTightLooseiso', True,'newVTightLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf_newVTightLooseiso', True,'newVTightLoose')
              if self.obj2_antinewTightLooseiso(row):
                if self.gg(row):
                    self.fill_histos(row,'antiiso_ssgg_newTightLooseiso', True,'newTightLoose')
 
                elif self.boost(row):
                    self.fill_histos(row,'antiiso_ssboost_newTightLooseiso', True,'newTightLoose')
 
                elif self.vbf(row):
                    self.fill_histos(row,'antiiso_ssvbf_newTightLooseiso', True,'newTightLoose')
#              if self.obj2_antinewisonewdm(row):
#                if self.gg(row):
#                    self.fill_histos(row,'antiiso_ssgg_newiso_newdm', True,'newDM')
# 
#                elif self.boost(row):
#                    self.fill_histos(row,'antiiso_ssboost_newiso_newdm', True,'newDM')
# 
#                elif self.vbf(row):
#                    self.fill_histos(row,'antiiso_ssvbf_newiso_newdm', True,'newDM')
               '''
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
