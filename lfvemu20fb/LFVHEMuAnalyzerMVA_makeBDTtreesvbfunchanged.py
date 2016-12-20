# check in https://twiki.cern.ch/twiki/bin/view/CMS/HiggsToTauTauWorking2015#MET when the mva met receipe is available.
from EMTree import EMTree
import os
import ROOT
import math
import glob
import array
#import mcCorrections
import baseSelections2 as selections
import FinalStateAnalysis.PlotTools.pytree as pytree
from FinalStateAnalysis.PlotTools.decorators import  memo_last
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from cutflowtracker import cut_flow_tracker
from math import sqrt, pi, cos
#from fakerate_functions import fakerate_central_histogram, fakerate_p1s_histogram, fakerate_m1s_histogram
import FinalStateAnalysis.TagAndProbe.PileupWeight as PileupWeight
import FinalStateAnalysis.TagAndProbe.MuonPOGCorrections as MuonPOGCorrections
import FinalStateAnalysis.TagAndProbe.EGammaPOGCorrections as EGammaPOGCorrections
import FinalStateAnalysis.TagAndProbe.FakeRate2D as FakeRate2D
import bTagSF as bTagSF
from inspect import currentframe




cut_flow_step=['allEvents','HLTIsoPasstrg','esel','eiso','musel','muiso','bjetveto','DR_e_mu','surplus_mu_veto','surplus_e_veto','jet0sel','jet1sel','jet2loosesel','jet2tightsel']

def collmass(row, met, metPhi):
    ptnu =abs(met*cos(deltaPhi(metPhi, row.ePhi)))
    visfrac = row.ePt/(row.ePt+ptnu)
    #print met, cos(deltaPhi(metPhi, row.tPhi)), ptnu, visfrac
    return (row.e_m_Mass / sqrt(visfrac))

def deltaPhi(phi1, phi2):
    PHI = abs(phi1-phi2)
    if PHI<=pi:
        return PHI
    else:
        return 2*pi-PHI

def deltaR(phi1, phi2, eta1, eta2):
    deta = eta1 - eta2
    dphi = abs(phi1-phi2)
    if (dphi>pi) : dphi = 2*pi-dphi
    return sqrt(deta*deta + dphi*dphi);

pu_distributions = glob.glob(os.path.join('inputs', os.environ['jobid'], 'data_SingleMu*pu.root'))


pu_corrector = PileupWeight.PileupWeight('MC_Spring16', *pu_distributions)
id_corrector  = MuonPOGCorrections.make_muon_pog_PFMedium_2016BCD()
iso_corrector = MuonPOGCorrections.make_muon_pog_TightIso_2016BCD()
tr_corrector  = MuonPOGCorrections.make_muon_pog_IsoMu22oIsoTkMu22_2016BCD()
trk_corrector = MuonPOGCorrections.mu_trackingEta_2016
eId_corrector = EGammaPOGCorrections.make_egamma_pog_electronID_ICHEP2016( 'nontrigWP80')

fakerateWeight =FakeRate2D.make_fakerate2D()
class LFVHEMuAnalyzerMVA_makeBDTtreesvbfunchanged(MegaBase):
    tree = 'em/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        self.channel='EMu'
        target = os.path.basename(os.environ['megatarget'])
        self.target=target
        self.output=outfile
        self.is_WJet=('WJetsToLNu' in target or 'W1JetsToLNu' in target or 'W2JetsToLNu' in target or 'W3JetsToLNu' in target or 'W4JetsToLNu' in target)
        self.is_DYJet= ('DYJetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM' in target or  'DY1JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM' in target or 'DY2JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM' in target or 'DY3JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM' in target or 'DY4JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM' in target) 
        self.isData=('data' in target)
        self.isWGToLNuG=( 'WGToLNuG' in target)
        self.isWGstarToLNuEE=('WGstarToLNuEE' in target)
        self.isWGstarToLNuMuMu=('WGstarToLNuMuMu' in target)
        self.isST_tW_antitop=('ST_tW_antitop' in target)
        self.isST_tW_top=('ST_tW_top' in target)
        self.isWW=('WW_Tune' in target)
        self.isWZ=('WZ_Tune' in target)
        self.isZZ=('ZZ_Tune' in target)
        self.isTT=('TT_Tune' in target)
        self.isGluGluHTo=('GluGluHTo' in target)
        self.isGluGlu_LFV=('GluGlu_LFV' in target)
        self.isVBFHTo=('VBFHTo' in target)
        self.isVBF_LFV=('VBF_LFV' in target)

        self.WGToLNuG_weight=0.00011736233
        self.WGstarToLNuEE_weight=0.00000564158
        self.WGstarToLNuMuMu_weight=0.00000180887
        self.ST_tW_antitop_weight=0.0000526974897638
        self.ST_tW_top_weight=0.000040713632205
        self.WW_weight=0.000132802570574
        self.WZ_weight=4.713e-05
        self.ZZ_weight=1.67015056929e-05
        self.TT_weight=8.71008159645e-06
        self.GluGluHTo_weight= 2.04805444356e-06
        self.GluGlu_LFV_weight=5.12622957741e-06
        self.VBFHTo_weight=4.67869114625e-08
        self.VBF_LFV_weight=7.57282991971e-08  
        self.tree = EMTree(tree)
        self.out=outfile
        self.histograms = {}
        self.mym1='m'
        self.mye1='e'
        if self.is_WJet:
            self.binned_weight=[0.672454854,0.20530173,0.10758429,0.08283444,0.090256696]
        elif self.is_DYJet:
            self.binned_weight=[0.063407117,0.014028728,0.015010691,0.01553876,0.012480257]
        else:
            self.binned_weight=[1,1,1,1,1]


        """need to think about this"""
    @staticmethod 
    def tau_veto(row):
        if not row.tAntiMuonLoose2 or not row.tAntiElectronMVA3Tight or not row.tDecayFinding :
            return False

    @staticmethod
    def obj1_matches_gen(row):
        return row.eGenPdgId == -1*row.eCharge*11
    @staticmethod 
    def obj3_matches_gen(row):
        return t.genDecayMode != -2 

    def mc_corrector_2015(self, row):
        
        pu = pu_corrector(row.nTruePU)

        muidcorr = id_corrector(getattr(row, self.mym1+'Pt'), abs(getattr(row, self.mym1+'Eta')))
        muisocorr = iso_corrector('Tight', getattr(row, self.mym1+'Pt'), abs(getattr(row, self.mym1+'Eta')))
        mutrcorr = tr_corrector(getattr(row, self.mym1+'Pt'), abs(getattr(row, self.mym1+'Eta'))) 
        eidcorr = eId_corrector(getattr(row,self.mye1+'Eta'),getattr(row, self.mye1+'Pt'))
        mutrkcorr=trk_corrector(getattr(row,self.mym1+'Eta'))[0]
        if pu*muidcorr*muisocorr*mutrcorr*eidcorr*mutrkcorr<0:
            print "mc weight negative:   ",pu*muidcorr*muisocorr*mutrcorr*eidcorr*mutrkcorr
            print "individual weights are :   pu*muidcorr*muisocorr*mutrcorr*eidcorr*mutrkcorr ",pu,"  ",muidcorr,"  ",muisocorr,"  ",mutrcorr,"  ",eidcorr,"  ",mutrkcorr
            print "           "
        return pu*muidcorr*muisocorr*mutrcorr*eidcorr*mutrkcorr



    def correction(self,row):
	return self.mc_corrector_2015(row)
        
    def event_weight(self, row):
 
        if row.run > 2: 
            return 1.
#        if row.GenWeight<0:
#        print "Gen weight negative:  ",row.GenWeight
 #       print "            "
        return row.GenWeight*self.correction(row) 





    def begin(self):
        self.weight_=array.array( 'f', [ 0 ] )
        self.mPt_=array.array( 'f', [ 0 ] )
        self.ePt_=array.array( 'f', [ 0 ] )
        self.deltaPhimue_=array.array( 'f', [ 0 ] )
        self.mEta_=array.array( 'f', [ 0 ] )
        self.eEta_=array.array( 'f', [ 0 ] )
        self.mTmuMet_=array.array( 'f', [ 0 ] )
        self.mTeMet_=array.array( 'f', [ 0 ] )
        self.eDphiPFMet_=array.array( 'f', [ 0 ] )
        self.mDphiPFMet_=array.array( 'f', [ 0 ] )
        self.metEt_=array.array( 'f', [ 0 ] )
        self.metPhi_=array.array( 'f', [ 0 ] )
        self.vbfMass_=array.array( 'f', [ 0 ] )
        self.vbfDeltaEta_=array.array( 'f', [ 0 ] )
        self.numjets_=array.array( 'f', [ 0 ] )
        self.mColl_=array.array( 'f', [ 0 ] )
        

        if self.isGluGlu_LFV or self.isVBF_LFV:
            self.treeS=ROOT.TTree("treeS","treeS")
            self.treeS.Branch("weight_",self.weight_,"weight_/F")
            self.treeS.Branch("mPt_",self.mPt_,"mPt_/F")
            self.treeS.Branch("ePt_",self.ePt_,"ePt_/F")            
            self.treeS.Branch("deltaPhimue_",self.deltaPhimue_,"deltaPhimue_/F")
            self.treeS.Branch("mEta_",self.mEta_,"mEta_/F")
            self.treeS.Branch("eEta_",self.eEta_,"eEta_/F")
            self.treeS.Branch("mTmuMet_",self.mTmuMet_,"mTmuMet_/F")
            self.treeS.Branch("mTeMet_",self.mTeMet_,"mTeMet_/F")
            self.treeS.Branch("eDphiPFMet_",self.eDphiPFMet_,"eDphiPFMet_/F")
            self.treeS.Branch("mDphiPFMet_",self.mDphiPFMet_,"mDphiPFMet_/F")
            self.treeS.Branch("metEt_",self.metEt_,"metEt_/F")
            self.treeS.Branch("metPhi_",self.metPhi_,"metPhi_/F")
            self.treeS.Branch("vbfMass_",self.vbfMass_,"vbfMass_/F")
            self.treeS.Branch("vbfDeltaEta_",self.vbfDeltaEta_,"vbfDeltaEta_/F")
            self.treeS.Branch("numjets_",self.numjets_,"numjets_/F")
            self.treeS.Branch("mColl_",self.mColl_,"mColl_/F")
        else:
            self.treeB=ROOT.TTree("treeB","treeB")
            self.treeB.Branch("weight_",self.weight_,"weight_/F")
            self.treeB.Branch("mPt_",self.mPt_,"mPt_/F")
            self.treeB.Branch("ePt_",self.ePt_,"ePt_/F")            
            self.treeB.Branch("deltaPhimue_",self.deltaPhimue_,"deltaPhimue_/F")
            self.treeB.Branch("mEta_",self.mEta_,"mEta_/F")
            self.treeB.Branch("eEta_",self.eEta_,"eEta_/F")
            self.treeB.Branch("mTmuMet_",self.mTmuMet_,"mTmuMet_/F")
            self.treeB.Branch("mTeMet_",self.mTeMet_,"mTeMet_/F")
            self.treeB.Branch("eDphiPFMet_",self.eDphiPFMet_,"eDphiPFMet_/F")
            self.treeB.Branch("mDphiPFMet_",self.mDphiPFMet_,"mDphiPFMet_/F")
            self.treeB.Branch("metEt_",self.metEt_,"metEt_/F")
            self.treeB.Branch("metPhi_",self.metPhi_,"metPhi_/F")
            self.treeB.Branch("vbfMass_",self.vbfMass_,"vbfMass_/F")
            self.treeB.Branch("vbfDeltaEta_",self.vbfDeltaEta_,"vbfDeltaEta_/F")
            self.treeB.Branch("numjets_",self.numjets_,"numjets_/F")
            self.treeB.Branch("mColl_",self.mColl_,"mColl_/F")


        


    def fill_tree(self, row,btagweight=1):
        if self.is_WJet or self.is_DYJet:
            weight = self.event_weight(row)*self.binned_weight[int(row.numGenJets)]*0.001
        elif self.isWGToLNuG:
            weight=self.WGToLNuG_weight*self.event_weight(row)
        elif self.isWGstarToLNuEE:
            weight=self.WGstarToLNuEE_weight*self.event_weight(row)
        elif self.isWGstarToLNuMuMu:
            weight=self.WGstarToLNuMuMu_weight*self.event_weight(row)
        elif self.isST_tW_top:
            weight=self.ST_tW_top_weight*self.event_weight(row)
        elif self.isST_tW_antitop:
            weight=self.ST_tW_antitop_weight*self.event_weight(row)
        elif self.isWW:
            weight=self.WW_weight*self.event_weight(row)
        elif self.isWZ:
            weight=self.WZ_weight*self.event_weight(row)
        elif self.isZZ:
            weight=self.ZZ_weight*self.event_weight(row)
        elif self.isTT:
            weight=self.TT_weight*self.event_weight(row)
        elif self.isGluGluHTo:
            weight=self.GluGluHTo_weight*self.event_weight(row)
        elif self.isGluGlu_LFV:
            weight=self.GluGlu_LFV_weight*self.event_weight(row)
        elif self.isVBFHTo:
            weight=self.VBFHTo_weight*self.event_weight(row)
        elif self.isVBF_LFV:
            weight=self.VBF_LFV_weight*self.event_weight(row)
        else:
            weight = self.event_weight(row)
        
#        if btagweight<0:
 #           print "btagweight is negative:  ",btagweight
        weight=btagweight*weight

        self.weight_[0]=weight
        self.mPt_[0]=row.mPt
        self.ePt_[0]=row.ePt
        self.deltaPhimue_[0]=row.e_m_DPhi
        self.mEta_[0]=row.mEta
        self.eEta_[0]=row.eEta
        self.mTmuMet_[0]=row.mMtToPfMet_type1  
        self.mTeMet_[0]=row.eMtToPfMet_type1 
        self.eDphiPFMet_[0]=row.eDPhiToPfMet_type1 
        self.mDphiPFMet_[0]=row.mDPhiToPfMet_type1 
        self.metEt_[0]=row.type1_pfMetEt  
        self.metPhi_[0]=row.type1_pfMetPhi
        self.numjets_[0]=row.jetVeto30
        self.mColl_[0]=collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)
        self.vbfMass_[0]=row.vbfMass if (row.vbfMass>0 and row.vbfMass<10000) else 0
        self.vbfDeltaEta_[0]=row.vbfDeta 

        
        if self.isGluGlu_LFV or self.isVBF_LFV:
            self.treeS.Fill()
        else:
            self.treeB.Fill()

    def process(self):
        myevent=()
        frw = []
        for row in self.tree:
            sign = 'ss' if row.e_m_SS else 'os'

            processtype ='gg'##changed from 20
            
            if sign=='ss':continue

            #trigger
            if (not bool(row.singleIsoMu22Pass or row.singleIsoTkMu22Pass)) and self.isData: 
                continue   #notrigger in new MC; add later

            #vetoes and cleaning
#            if row.bjetCISVVeto30Loose : continue
            
            #nbtagged=row.bjetCISVVeto30Medium
            nbtagged=row.bjetCISVVeto20MediumZTT
            if nbtagged>2:
                nbtagged=2
            btagweight=1
            if (self.isData and nbtagged>0):
                continue
            if nbtagged>0:
                if nbtagged==1:
                    btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1flavor,row.jb2pt,row.jb2flavor,1,0,0) if (row.jb1pt>-990 and row.jb1flavor>-990) else 0
                if nbtagged==2:
                    btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1flavor,row.jb2pt,row.jb2flavor,1,0,0) if (row.jb1pt>-990 and row.jb1flavor>-990 and row.jb2pt>-990 and row.jb2flavor>-990) else 0
            if btagweight<0:btagweight=0

            if btagweight==0: continue

            if deltaR(row.ePhi,row.mPhi,row.eEta,row.mEta)<0.1:continue
            
            if row.muVetoPt5IsoIdVtx :continue

            if row.eVetoMVAIso :continue


            #E Preselection
            if not selections.eSelection(row, 'e'): continue

           

            #take care of ecal gap
            if row.eEta > 1.4442 and row.eEta < 1.566 : continue             

            #mu preselection
            if not selections.muSelection(row, 'm'): continue

            #id isolation
            if not selections.lepton_id_iso(row, 'm', 'MuIDTight_mutauiso015'):continue

 
            if not selections.lepton_id_iso(row, 'e', 'eid15Loose_etauiso01'): continue
            ## All preselection passed 

            self.fill_tree(row,btagweight)

            
    def finish(self):
        self.output.Write()


