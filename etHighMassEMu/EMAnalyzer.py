from EMTree import EMTree
import sys
import logging
logging.basicConfig(stream=sys.stderr, level=logging.INFO)
import os
from pdb import set_trace
import ROOT
import math
import glob
import array
import baseSelections as selections
import FinalStateAnalysis.PlotTools.pytree as pytree
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from math import sqrt, pi, cos
import itertools
import traceback
from FinalStateAnalysis.Utilities.struct import struct
from FinalStateAnalysis.PlotTools.decorators import memo
from FinalStateAnalysis.PlotTools.decorators import memo_last
import optimizer
import mcCorrections
from cutflowtracker import cut_flow_tracker
import bTagSF
import FinalStateAnalysis.TagAndProbe.muonTrigEff as muonTrigEff
import FinalStateAnalysis.TagAndProbe.eleTrigEff as eleTrigEff
import MuSF, EleSF

cut_flow_step = ['allEvents', 'jets','trigger', 'esel', 'msel', 'eiso', 'vetoes','sign']

em_collmass = 'e_m_collinearmass'

@memo
def getVar(name, var):
    return name+var
@memo
def split(string, separator='#'):
    return tuple(attr.split(separator))

met_et  = 'type1_pfMetEt'
met_phi = 'type1_pfMetPhi'
ty1met_et  = 'type1_pfMet_shiftedPt%s'
ty1met_phi = 'type1_pfMet_shiftedPhi%s'
m_pt  = 'mPt%s'
emMass = 'e_m_Mass%s'
jetVeto = 'jetVeto30%s'

@memo
def jetN(shift=''):
    if 'jes' in shift:
        return jetVeto %shift.replace('jes', '')
    return jetVeto %('')

@memo
def met(shift=''):
    if 'jes' in shift or 'UES' in shift:
        return ty1met_et %shift
    return met_et

@memo
def metphi(shift=''):
    if 'jes' in shift or 'UES' in shift:
        return ty1met_phi %shift
    return met_phi
 
 
@memo
def collinearmass(shift=''):
    return 

def attr_getter(attribute):
    '''return a function that gets an attribute'''
    def f(row, weight):
        return (getattr(row,attribute), weight)
    return f

def collmass(row, met, metPhi):
    ptnu =abs(met*cos(deltaPhi(metPhi, row.mPhi)))
    visfrac = row.mPt/(row.mPt+ptnu)
    #print met, cos(deltaPhi(metPhi, row.tPhi)), ptnu, visfrac
    return (row.e_m_Mass / sqrt(visfrac))

def syst_collmass(met, metPhi, my_ele, my_tau):
    ptnu =abs(met*cos(deltaPhi(metPhi,my_tau.Phi())))
    visfrac = my_tau.Pt()/(my_tau.Pt()+ptnu)
    return ((my_tau+my_ele).M()) / (sqrt(visfrac))

def make_visfrac_systematics(met, metPhi, my_tau):
    ptnu =abs(met*cos(deltaPhi(metPhi,my_tau.Phi())))
    visfrac = my_tau.Pt()/(my_tau.Pt()+ptnu)
    return visfrac

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

def merge_functions(fcn_1, fcn_2):
    '''merges two functions to become a TH2'''
    def f(row, weight):
        r1, w1 = fcn_1(row, weight)
        r2, w2 = fcn_2(row, weight)
        w = w1 if w1 and w2 else None
        return ((r1, r2), w)
    return f

def make_collmass_systematics(shift):
    
    if shift.startswith('tes'):
        ptnu =abs(met*cos(deltaPhi(metPhi, row.tPhi)))
        visfrac = tpt/(tpt+ptnu)
        vis_mass = vismass(shift)
        return (vis_mass / sqrt(visfrac))
    elif shift.startswith('ees'):
        ptnu =abs(met*cos(deltaPhi(metPhi, row.mPhi)))
        visfrac = tpt/(tpt+ptnu)
        vis_mass = vismass(shift)
        return (vis_mass / sqrt(visfrac))
     
    else:
        met_name = met(shift)
        phi_name = metphi(shift)
        def collmass_shifted(row, weight):
            met = getattr(row, met_name)
            phi = getattr(row, phi_name)
            return collmass(row, met, phi), weight
        return collmass_shifted
    
def topPtreweight(pt1,pt2):
    #pt1=pt of top quark
    #pt2=pt of antitop quark
    #13 Tev parameters: a=0.0615,b=-0.0005
    #for toPt >400, apply SF at 400
    if pt1>400:pt1=400
    if pt2>400:pt2=400
    a=0.0615
    b=-0.0005 
    
    wt1=math.exp(a+b*pt1)
    wt2=math.exp(a+b*pt2)
    
    wt=sqrt(wt1*wt2)
    
    return wt


def remove_element(list_,value_):
        clipboard = []
        for i in range(len(list_)):
            if list_[i] is not value_:
                clipboard.append(list_[i])
        return clipboard

pucorrector={'': mcCorrections.make_puCorrector('singlee', None),
             'puUp': mcCorrections.make_puCorrectorUp('singlee', None),
             'puDown': mcCorrections.make_puCorrectorDown('singlee', None)
}


eleLeg23_trigger_2016 = eleTrigEff.eleLeg23_trigger_2016 
eleLeg12_trigger_2016 = eleTrigEff.eleLeg12_trigger_2016 
mc_eleLeg23_trigger_2016 = eleTrigEff.mc_eleLeg23_trigger_2016
mc_eleLeg12_trigger_2016 = eleTrigEff.mc_eleLeg23_trigger_2016

muLeg23_trigger_2016 = muonTrigEff.muLeg23_trigger_2016
muLeg8_trigger_2016 = muonTrigEff.muLeg8_trigger_2016
mc_muLeg23_trigger_2016 = muonTrigEff.mc_muLeg23_trigger_2016
mc_muLeg8_trigger_2016 = muonTrigEff.mc_muLeg8_trigger_2016

eleIdIsoSF=EleSF.eleIdIso0p15
muIdIsoSF=MuSF.muIdIso0p2
mc_eleIdIsoSF=EleSF.mc_eleIdIso0p15
mc_muIdIsoSF=MuSF.mc_muIdIso0p2

eleTrackingSF=EleSF.eTrackingSF
muTrackingSF=MuSF.muTrackingSF

class EMAnalyzer(MegaBase):
    tree = 'em/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('EMAnalyzer constructor')
        self.channel='EM'
        super(EMAnalyzer, self).__init__(tree, outfile, **kwargs)
        self.tree = EMTree(tree)
        self.out=outfile
        self.histograms = {}

        #understand what we are running
        target = os.path.basename(os.environ['megatarget'])
        self.is_data = target.startswith('data_')
        self.is_embedded = ('Embedded' in target)
        self.is_mc = not (self.is_data or self.is_embedded)
        self.is_DY = bool('JetsToLL_M-50' in target)
        self.is_DYTT = bool('JetsToTT_M-50' in target)
        self.is_DYLowMass = bool('JetsToLL_M-10to50' in target)
        self.isTT= bool('TT_TuneCUETP8M2T4_13TeV-powheg-pythia8_v6-v1' in target)
        self.is_W = bool('JetsToLNu' in target)
        self.is_HighMass = bool('ggM' in target)
        self.is_bkg = not (self.is_data or self.is_embedded or self.is_HighMass)

        self.my_mu=ROOT.TLorentzVector()
        self.my_ele=ROOT.TLorentzVector()
        self.my_MET=ROOT.TLorentzVector()

        
        self.systematics = {
            'pu'   : (['','puUp', 'puDown'] if self.is_mc else []),
            'trig' : (['', 'trUp', 'trDown'] if not self.is_data else []),
            'mes'  : (['mesUp','meDown'] if not self.is_data else ['']),
            'ees'  : (["", 'eesUp','eesDown','eesresrhoUp','eesresrhoDown','eesresphiDown'] if not self.is_data else ['']),
            #'etfakeES': (['', 'etfakeESUp', 'etfakeESDown'] if self.is_DY or self.is_DYLowMass else ['']),
            'ues'  : (['', 'ues_CHARGEDUESUp', 'ues_CHARGEDUESDown', 'ues_ECALUESDown', 'ues_ECALUESUp', 'ues_HCALUESDown', 'ues_HCALUESUp', 'ues_HFUESDown', 'ues_HFUESUp'] if not self.is_data else ['']),
            'jes'  : (['','jes_JetAbsoluteFlavMapDown',  'jes_JetAbsoluteMPFBiasDown',  'jes_JetAbsoluteScaleDown',  'jes_JetAbsoluteStatDown',  'jes_JetFlavorQCDDown',  'jes_JetFragmentationDown',  'jes_JetPileUpDataMCDown',  'jes_JetPileUpPtBBDown',  'jes_JetPileUpPtEC1Down',  'jes_JetPileUpPtEC2Down',  'jes_JetPileUpPtHFDown',  'jes_JetPileUpPtRefDown',  'jes_JetRelativeBalDown',  'jes_JetRelativeFSRDown',  'jes_JetRelativeJEREC1Down', 'jes_JetRelativeJEREC2Down',  'jes_JetRelativeJERHFDown',  'jes_JetRelativePtBBDown',  'jes_JetRelativePtEC1Down',  'jes_JetRelativePtEC2Down',  'jes_JetRelativePtHFDown',  'jes_JetRelativeStatECDown',  'jes_JetRelativeStatFSRDown',  'jes_JetRelativeStatHFDown',  'jes_JetSinglePionECALDown',  'jes_JetSinglePionHCALDown',  'jes_JetTimePtEtaDown',  'jes_JetAbsoluteFlavMapUp', 'jes_JetAbsoluteMPFBiasUp',  'jes_JetAbsoluteScaleUp',  'jes_JetAbsoluteStatUp',  'jes_JetFlavorQCDUp',  'jes_JetFragmentationUp',  'jes_JetPileUpDataMCUp',  'jes_JetPileUpPtBBUp',  'jes_JetPileUpPtEC1Up', 'jes_JetPileUpPtEC2Up',  'jes_JetPileUpPtHFUp',  'jes_JetPileUpPtRefUp',  'jes_JetRelativeBalUp',  'jes_JetRelativeFSRUp',  'jes_JetRelativeJEREC1Up',  'jes_JetRelativeJEREC2Up',  'jes_JetRelativeJERHFUp',  'jes_JetRelativePtBBUp',  'jes_JetRelativePtEC1Up',  'jes_JetRelativePtEC2Up',  'jes_JetRelativePtHFUp',  'jes_JetRelativeStatECUp', 'jes_JetRelativeStatFSRUp',  'jes_JetRelativeStatHFUp',  'jes_JetSinglePionECALUp',  'jes_JetSinglePionHCALUp',  'jes_JetTimePtEtaUp'] if not self.is_data else [''])
        }
        
        self.histo_locations = {}

        self.hfunc   = {
            'nTruePU' : lambda row, weight: (row.nTruePU,None),
            'weight'  : lambda row, weight: (weight,None) if weight is not None else (1.,None),
            'Event_ID': lambda row, weight: (array.array("f", [row.run,row.lumi,int(row.evt)/10**5,int(row.evt)%10**5] ), None),
            'h_collmass_pfmet' : lambda row, weight: (syst_collmass(self.my_MET.Pt(), self.my_MET.Phi(), self.my_ele, self.my_mu), weight),
            'h_collmass_vs_dPhi_pfmet' : merge_functions(
                attr_getter('mDPhiToPfMet_type1'),
                lambda row, weight: (collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi),weight)
            ),
            'visfrac' : lambda row, weight: (make_visfrac_systematics(self.my_MET.Pt(), self.my_MET.Phi(), self.my_mu), weight), 
            'MetEt_vs_dPhi' : merge_functions(
                lambda row, weight: (deltaPhi(row.mPhi, getattr(row, metphi())), weight),
                attr_getter('type1_pfMetEt')
            ),
            'ePFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.ePhi, getattr(row, metphi())), weight),
            'mPFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.mPhi, getattr(row, metphi())), weight),
            'evtInfo' : lambda row, weight: (struct(run=row.run,lumi=row.lumi,evt=row.evt,weight=weight), None)
            }

        self.DYreweight = mcCorrections.DYreweight
        self.triggerEff  = mcCorrections.efficiency_trigger_2016 if not self.is_data else 1.

        self.ZTTLweight={ #updated 23/10/2017
            0 : 0.041324191,
            1 : 0.013323092,
            2 : 0.013599166,
            3 : 0.013983151,
            4 : 0.011464196
        }
        self.ZTTLowMassLweight={ #updated 23/10/2017
            0 : 0.641343812,
            1 : 0.025325281,
            2 : 0.002928175
        }
        
        self.Wweight={#updated 23/10/2017
            0 : 0.709390278,
            1 : 0.190063899,
            2 : 0.058529964,
            3 : 0.019206445,
            4 : 0.01923548
        }
        self.QCDweight=2.33*0.90
    
    def event_weight(self, row, sys_shifts):
        nbtagged=row.bjetCISVVeto30Medium
        if nbtagged>2:
            nbtagged=2
        if self.is_data:
            #return {'' : 1.}
            if nbtagged>0 :
                return {'' : 0.}
            else:
                return {'' : 1.}
            
        weights = {}
        mcweight=1.
        trweight=1.
        if not self.is_data : # applying directly the efficiency measured in data

            eff_data_e23=eleLeg23_trigger_2016(row.ePt, row.eAbsEta)
            eff_data_e12=eleLeg12_trigger_2016(row.ePt, row.eAbsEta)
            eff_mc_e23=mc_eleLeg23_trigger_2016(row.ePt, row.eAbsEta)
            eff_mc_e12=mc_eleLeg12_trigger_2016(row.ePt, row.eAbsEta)
            
            eff_data_mu23=muLeg23_trigger_2016(row.mPt, row.mAbsEta)
            eff_data_mu8=muLeg8_trigger_2016(row.mPt, row.mAbsEta)
            eff_mc_mu23=mc_muLeg23_trigger_2016(row.mPt, row.mAbsEta)
            eff_mc_mu8=mc_muLeg8_trigger_2016(row.mPt, row.mAbsEta)

            eff_data=eff_data_mu23*eff_data_e12+eff_data_mu8*eff_data_e23-eff_data_mu23*eff_data_e23
            eff_mc=eff_mc_mu23*eff_mc_e12+eff_mc_mu8*eff_mc_e23-eff_mc_mu23*eff_mc_e23
            if eff_mc==0 :
               #print 'trigger weight', row.ePt, row.eAbsEta,row.mPt, row.mAbsEta, eff_data, eff_mc
               trweight=0.
            else:
                trweight = 0.979*eff_data/eff_mc
                #print 'ele Pt, AbsEta, muon Pt, AbsEta, trigger weight', row.ePt, row.eAbsEta,row.mPt, row.mAbsEta, trweight

            eleSF=eleIdIsoSF(row.ePt, row.eAbsEta)/mc_eleIdIsoSF(row.ePt, row.eAbsEta)
            muSF=muIdIsoSF(row.mPt, row.mAbsEta)/mc_muIdIsoSF(row.mPt, row.mAbsEta)
            #print 'ele, mu id iso sf', eleSF, muSF
            eleTrkSF=eleTrackingSF(row.eEta)
            muTrkSF=muTrackingSF(row.mEta)
            #print 'ele, mu trk sf', eleTrkSF, muTrkSF
            
            
            dyweight = self.DYreweight(row.genMass, row.genpT)
            #print 'DY weight', dyweight
            btagweight = 1. 
            if nbtagged>0:
                btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1hadronflavor,row.jb2pt,row.jb2hadronflavor,1,0,0)
            #print 'btagweight', btagweight
            puweight = pucorrector[''](row.nTruePU)

            if self.is_DY or self.is_DYTT:
                if row.numGenJets < 5:
                    #print "DY reweight", self.ZTTLweight[row.numGenJets]
                    mcweight = mcweight*self.ZTTLweight[row.numGenJets]*dyweight
                else:
                    mcweight = mcweight*self.ZTTLweight[0]*dyweight
                    #print "DY reweight", self.ZTTLweight[row.numGenJets]

                    
            if self.is_DYLowMass:
                if row.numGenJets < 3:
                    mcweight = mcweight*self.ZTTLowMassLweight[row.numGenJets]*dyweight
                    #print "DY reweight", self.ZTTLweight[row.numGenJets]

                else:
                    mcweight = mcweight*self.ZTTLowMassLweight[0]*dyweight
                    #print "DY reweight", self.ZTTLweight[0]
                                        
                       
            if self.is_W:
                if row.numGenJets < 5:
                    mcweight = mcweight*self.Wweight[row.numGenJets]
                    #print "Wreweight", self.Wweight[row.numGenJets]
                else:
                    mcweight = mcweight*self.Wweight[0]
                    #print "Wreweight", self.Wweight[0]

            topptreweight=1.

            if self.isTT:
                topptreweight=topPtreweight(row.topQuarkPt1,row.topQuarkPt2)
                #print "top reweight", topreweight
                
            mcweight =  mcweight*puweight*btagweight*trweight*eleSF*muSF*eleTrkSF*muTrkSF
            #print 'final mcweight', mcweight
            mcweight_tight = mcweight*topptreweight


                ##print 'trigger SF', self.triggerEff(row.ePt, row.eAbsEta)
                #mcweight=self.triggerEff(row.ePt, row.eAbsEta)[0]
                ##print shift, 'trig eff ' , mcweight
            for shift in sys_shifts:

                if shift=='trUp':
                    if trweight==0.:
                        mcweight=0.
                    else:
                        newtrweight = trweight*1.02
                        mcweight=newtrweight*mcweight/trweight
                    ##    print 'trig eff up' , mcweight 
                elif shift=='trDown':
                    if trweight==0.:
                        mcweight=0.
                    else:
                        newtrweight = trweight*0.98
                        mcweight=newtrweight*mcweight/trweight
                    ##    print 'trig eff dw' , mcweight 

            
        
                if shift=='puUp' or shift=='puDown':
                    if puweight==0:
                        mcweight=0.
                    else:
                        newpuweight = pucorrector[shift](row.nTruePU)
                        mcweight=mcweight*newpuweight/puweight
            

                weights[shift] =  mcweight_tight
             


            
  
        return weights

    
    
    def begin(self):
        sys_shifts =  ['', 'QCD', 'QCDLoose'] + self.systematics['pu'] + self.systematics['trig'] \
                     +  self.systematics['ees'] + self.systematics['mes'] + self.systematics['ues'] + self.systematics['jes'] 
        #remove double dirs
        sys_shifts = list(set(sys_shifts))
        signs =['os', 'ss']
        jetN = ['le1','0', '1']
        massRange = ['','LowMass', 'HighMass']
        folder=[]

        for tuple_path in itertools.product(sys_shifts, signs,  massRange, jetN):
            #print tuple_path
            folder.append(os.path.join(*tuple_path))
            path = list(tuple_path)
            
            #path.append('selected')
            #folder.append(os.path.join(*path))
            #prefix_path = os.path.join(*tuple_path)
            #print path, prefix_path
            # if 'Mass' in prefix_path:
            #for region in optimizer.regions[tuple_path[-1]]:
            #    
            #    folder.append(
            #        os.path.join(os.path.join(*path), region)
            #    )
        
        self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  100, 0, 1000)
        self.book('os/', "e_m_Mass",  "h_vismass",  100, 0, 1000)
                
        for f in folder:
            self.book(f,"weight", "weight", 100, 0, 10)

            self.book(f,"mPt", "#mu p_{T}", 100, 0, 1000)             
            self.book(f,"mPhi", "#mu #phi", 26, -3.25, 3.25)
            self.book(f,"mEta", "#mu #eta",  10, -2.5, 2.5)
            
                        
            self.book(f,"ePt", "e p_{T}", 100, 0, 1000)
            self.book(f,"ePhi", "e #phi",  26, -3.2, 3.2)
            self.book(f,"eEta", "e #eta", 10, -2.5, 2.5)
             
            self.book(f, "e_m_DPhi", "e-#mu DeltaPhi" , 20, 0, 3.2)
            self.book(f, "e_m_DR", "e-#mu DeltaR" , 20, 0, 5.)
            
            self.book(f, "h_collmass_pfmet",  "h_collmass_pfmet",  100, 0, 1000)
            self.book(f, "visfrac",  "visfrac",  100, 0., 1.)
            self.book(f, "e_m_Mass",  "h_vismass",  100, 0, 1000)
            
            
            self.book(f, "mMtToPfMet_type1", "#mu-PFMET M_{T}" , 100, 0, 500)
            self.book(f, "eMtToPfMet_type1", "e-PFMET M_{T}" , 100, 0, 500)
            self.book(f, "type1_pfMetEt",  "type1_pfMet_Et",  100, 0, 1000)
            self.book(f, "type1_pfMetPhi",  "type1_pfMet_Phi", 26, -3.2, 3.2)
            self.book(f, "jetVeto20", "Number of jets, p_{T}>20", 5, -0.5, 4.5) 
            self.book(f, "jetVeto30", "Number of jets, p_{T}>30", 5, -0.5, 4.5)

            self.book(f, "e_m_PZeta", "e_m_PZeta", 200, -400, 400)
            self.book(f, "e_m_PZetaLess0p85PZetaVis", "e_m_PZetaLess0p85PZetaVis", 100, -200, 200)
            self.book(f, "e_m_PZetaVis", "e_m_PZetaVis", 100, 0, 300 )

            self.book(f, "nvtx", "number of vertices", 100, 0, 100)

            self.book(f, "eGenEta", "e #eta (gen)", 10, -2.5, 2.5)
            self.book(f, "eGenPt", "e p_{T} (gen)", 100, 0, 1000)
            self.book(f, "eGenPhi", "e #phi (gen)",  26, -3.2, 3.2)
            self.book(f, "mGenEta", "#mu #eta (gen)", 10, -2.5, 2.5)
            self.book(f, "mGenPt", "#mu p_{T} (gen)", 100, 0, 1000)
            self.book(f, "mGenPhi", "#mu #phi (gen)",  26, -3.2, 3.2)
            self.book(f, "eComesFromHiggs", "eComesFromHiggs", 2, -0.5, 1.5)
            self.book(f, "mComesFromHiggs", "mComesFromHiggs", 2, -0.5, 1.5)
            
           
            
            #index dirs and histograms
        for key, value in self.histograms.iteritems():
            location = os.path.dirname(key)
            name     = os.path.basename(key)
            if location not in self.histo_locations:
                self.histo_locations[location] = {name : value}
            else:
                #print 'location and name', location, name
                self.histo_locations[location][name] = value
      
        self.book('', "CUT_FLOW", "Cut Flow", len(cut_flow_step), 0, len(cut_flow_step))
            
        xaxis = self.histograms['CUT_FLOW'].GetXaxis()
        self.cut_flow_histo = self.histograms['CUT_FLOW']
        self.cut_flow_map   = {}
        for i, name in enumerate(cut_flow_step):
            xaxis.SetBinLabel(i+1, name)
            self.cut_flow_map[name] = i+0.5


    def fill_histos(self, folder_str, row, weight, filter_label = ''):
        '''fills histograms'''
        
        for attr, value in self.histo_locations[folder_str].iteritems():
            name = attr
            if filter_label:
                if not attr.startswith(filter_label+'$'):
                    continue
                attr = attr.replace(filter_label+'$', '')
            if 'Gen' in attr and self.is_data:
                continue 
            if value.InheritsFrom('TH2'):
                if attr in self.hfunc:
                    try:
                        result, out_weight = self.hfunc[attr](row, weight)
                    except Exception as e:
                        raise RuntimeError("Error running function %s. Error: \n\n %s" % (attr, str(e)))
                    r1, r2 = result
                    if out_weight is None:
                        value.Fill( r1, r2 ) #saves you when filling NTuples!
                    else:
                        value.Fill( r1, r2, out_weight )
                else:
                    attr1, attr2 = split(attr)
                    v1 = getattr(row,attr1)
                    v2 = getattr(row,attr2)
                    value.Fill( v1, v2, weight ) if weight is not None else value.Fill( v1, v2 )
            else:
                if attr in self.hfunc:
                    try:
                        result, out_weight = self.hfunc[attr](row, weight)
                    except Exception as e:
                        raise RuntimeError("Error running function %s. Error: \n\n %s" % (attr, str(e)))
                    if out_weight is None:
                        value.Fill( result ) #saves you when filling NTuples!
                    else:
                        value.Fill( result, out_weight )
                else:
                    value.Fill( getattr(row,attr), weight ) if weight is not None else value.Fill( getattr(row,attr) )
        return None

    def process(self):
        cut_flow_histo = self.cut_flow_histo
        cut_flow_trk   = cut_flow_tracker(cut_flow_histo)

        sys_shifts = self.systematics['pu'] + self.systematics['trig'] \
                     + self.systematics['ees'] + self.systematics['mes']  + self.systematics['ues'] + self.systematics['jes'] 
        logging.debug('Starting processing')
        


        lock =()
        ievt = 0
        logging.debug('Starting evt loop')
        
        for row in self.tree:
            #if ievt==999. : return
            #print 'new event', ievt
            if (ievt % 1000) == 0:
                #print 'new event', ievt
                logging.debug('New event')
            ievt += 1
            #avoid double counting events!
            evt_id = (row.run, row.lumi, row.evt)
            if evt_id == lock: continue
            if lock != () and evt_id == lock:
                logging.info('Removing duplicate of event: %d %d %d' % evt_id)

            cut_flow_trk.new_row(row.run,row.lumi,row.evt)
            #print row.run,row.lumi,row.evt
            if (self.is_DYTT and not bool(row.isZtautau or row.isGtautau)):
                continue
            if (self.is_DY and bool(row.isZtautau or row.isGtautau) ):
                continue
            cut_flow_trk.Fill('allEvents')
            
            cut_flow_trk.Fill('jets')
            selection_categories = []
            massRanges = ['','LowMass', 'HighMass']
            jetDir = ['le1', '0', '1']

            #if self.is_data:
            if  bool(row.singleE23SingleMu8Pass) or bool(row.singleMu23SingleE12Pass) : 
                cut_flow_trk.Fill('trigger')
                
                if  selections.eSelection(row, 'e'): 
                    cut_flow_trk.Fill('esel')
                    if selections.muSelection(row, 'm'):
                        cut_flow_trk.Fill('msel')
           
                        logging.debug('object selection passed')
                        #e ID/ISO
                        if  selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso025'):
                            logging.debug('Passed preselection')
                            cut_flow_trk.Fill('eiso')
            
                            sys_directories = sys_shifts
                            #remove duplicates
                            sys_directories = list(set(sys_directories))
                            
                            isEVTight = bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso015')) and  bool(selections.lepton_id_iso(row, 'm', 'mIDMedium_idiso02'))
                            isQCDLoose=False
                            if not bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso015')) and bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso05')) and  bool(selections.lepton_id_iso(row, 'm', 'mIDMedium_idiso05')) and not bool(selections.lepton_id_iso(row, 'm', 'mIDMedium_idiso02')):
                                print 'isQCDLoose', isQCDLoose
                                isQCDLoose=True
                                
                            sign = 'os'
                            if bool(row.e_m_SS)==True: sign='ss'
                            if deltaR(row.ePhi, row.mPhi, row.eEta, row.mEta) < 0.5: continue
                            if row.tauVetoPt20Loose3HitsVtx : continue
                            if row.muVetoPt5IsoIdVtx : continue
                            if row.eVetoMVAIso : continue
                            cut_flow_trk.Fill('vetoes')
                            logging.debug('Passed Vetoes')
                            
                            weight_sys_shifts=sys_shifts
                            weight_sys_shifts.append('')
                            weight_map = self.event_weight(row, weight_sys_shifts)

                            etau_category = ['']
                            if sign=='ss' and  isQCDLoose:
                                mc_weight = weight_map['']
                                qcdweight = mc_weight*self.QCDweight
                                weight_map.update({'QCDLoose' : qcdweight})
                                sys_directories.extend(['QCDLoose'])
                                sys_directories=remove_element(sys_directories, '')
                            
                            if sign=='ss':
                                mc_weight = weight_map['']
                                qcdweight = mc_weight*self.QCDweight
                                weight_map.update({'QCD' : qcdweight})
                                sys_directories.extend(['QCD'])
                           
                            #sys_directories=remove_element(sys_directories, '')
                
                            #print sys_directories
                            passes_full_selection = False

                            #starting to set up the optimizer
                            #tau pt cut
            
                            self.my_ele.SetPtEtaPhiM(row.ePt,row.eEta,row.ePhi,  0.000511)
                            self.my_mu.SetPtEtaPhiM(row.mPt, row.mEta, row.mPhi, 0.105658)
                            self.my_MET.SetPtEtaPhiM(row.type1_pfMetEt,0,row.type1_pfMetPhi,0)

                            myEle = {}
                            myMu = {}
                            myMET = {}
                            #print sys_directories
            
                            for sys in sys_directories :
                
                                if 'ees' in sys:
                                    if 'eesUp' in sys:
                                        self.my_ele.SetPtEtaPhiM(row.ePt_ElectronScaleUp,row.eEta,row.ePhi, 0.000511)
                                        myEle[sys] = self.my_ele
                                    if 'eesDown' in sys:
                                        self.my_ele.SetPtEtaPhiM(row.ePt_ElectronScaleDown,row.eEta,row.ePhi,  0.000511)
                                        myEle[sys] = self.my_ele
                                    if 'eresrhoUp' in sys:
                                        self.my_ele.SetPtEtaPhiM(row.ePt_ElectronResRhoUp, row.eEta,row.ePhi,  0.000511)
                                        myEle[sys] = self.my_ele
                                    if 'eresrhoDown' in sys:
                                        self.my_ele.SetPtEtaPhiM(row.ePt_ElectronResRhoDown, row.eEta,row.ePhi,  0.000511)
                                        myEle[sys] = self.my_ele
                                    if 'eresphiDown' in sys:
                                        self.my_ele.SetPtEtaPhiM(row.ePt_ElectronResPhiDown, row.eEta,row.ePhi,  0.000511)
                                        myEle[sys] = self.my_ele
                                if 'mes' in sys:
                                    if 'mesUp' in sys:
                                        self.my_mu.SetPtEtaPhiM(1.002*row.mPt,row.mEta,row.mPhi, 0.105658)
                                        self.my_MET.SetPtEtaPhiM(row.type1_pfMetEt-0.002*row.mPt,0,row.type1_pfMetPhi,0)
                                        myMu[sys] = self.my_mu
                                        myMET[sys] = self.my_MET
                                    if 'mesDown' in sys:
                                        self.my_ele.SetPtEtaPhiM(0.998*row.mPt,row.mEta,row.mPhi,  0.105658)
                                        self.my_MET.SetPtEtaPhiM(row.type1_pfMetEt+0.002*row.mPt,0,row.type1_pfMetPhi,0)
                                        myMu[sys] = self.my_mu
                                        myMET[sys] = self.my_MET
               
                                if '_jes_' in sys:
                                    self.my_MET.SetPtEtaPhiM(getattr(row,met(sys.replace('jes_','_'))), 0,
                                                             getattr(row,metphi(sys.replace('jes_','_'))),0)
                                    myMET[sys] = self.my_MET
                                if 'UES' in sys:
                                    self.my_MET.SetPtEtaPhiM(getattr(row,met(sys.replace('ues_', '_'))), 0,
                                                             getattr(row,metphi(sys.replace('ues_', '_'))),0)
                                    myMET[sys] = self.my_MET

                                jets = min(int(getattr(row,jetN(sys))), 2)
                                if sys=='' and getattr(row,jetN(sys))!=row.jetVeto30 : print sys, getattr(row,jetN(sys)), row.jetVeto30
                                if jets<2 : 

                                    totalEt = self.my_mu.Et() + self.my_MET.Et();
                                    totalPt = (self.my_mu + self.my_MET).Pt()
                                    mytMtMet = sqrt(abs(totalEt*totalEt - totalPt*totalPt))

                                    ## if sys=='' : print self.my_ele.Pt(), row.ePt, self.my_tau.Pt(), row.tPt
                                    selection_categories.extend([(sys, '', 'le1', '')])
                                    selection_categories.extend([(sys, '', str(jets), '')])
                                    if self.my_ele.Pt() > 60 and self.my_mu.Pt() >10 :
                                        if deltaPhi(self.my_ele.Phi(), self.my_mu.Phi()) > 2.2 and deltaPhi(self.my_mu.Phi() , self.my_MET.Phi())<0.7:
                                            selection_categories.extend([(sys,'LowMass', 'le1', '')])
                                            selection_categories.extend([(sys,'LowMass',str(jets), '')])
                                        if self.my_ele.Pt() > 150 and self.my_mu.Pt()>10:
                                            if deltaPhi(self.my_ele.Phi(), self.my_mu.Phi()) > 2.2 and deltaPhi(self.my_mu.Phi() , self.my_MET.Phi())<0.3:
                                                selection_categories.extend([(sys, 'HighMass', 'le1','')])
                                                selection_categories.extend([(sys, 'HighMass', str(jets),'')])
                         
                

                                
                            for selection in selection_categories:
                
                                selection_sys, massRange, jet_dir,  selection_step = selection
                                #print  selection_sys, massRange, jet_dir,  selection_step
                                dirname =  os.path.join(selection_sys, sign, massRange, jet_dir, selection_step)
                                if sign == 'ss' and 'QCD' in selection_sys :
                                    dirname =  os.path.join(selection_sys, 'os', massRange, jet_dir, selection_step)
                                if sign=='os': cut_flow_trk.Fill('sign')
                                if dirname[-1] == '/':
                                    dirname = dirname[:-1]
                                weight_to_use = weight_map[selection_sys] if selection_sys in weight_map else weight_map['']
                                #print dirname, evt_id
                                if selection_sys in myEle :
                                    self.my_ele = myEle[selection_sys]
                                else:
                                    self.my_ele.SetPtEtaPhiM(row.ePt,row.eEta,row.ePhi,  0.000511)
                                if selection_sys in myMu:
                                    self.my_mu = myMu[selection_sys]
                                else:
                                    self.my_mu.SetPtEtaPhiM(row.mPt, row.mEta, row.mPhi, 0.105658)
                                    
                                if selection_sys in myMET:
                                    self.my_MET = myMET[selection_sys]
                                else:
                                    self.my_MET.SetPtEtaPhiM(row.type1_pfMetEt,0,row.type1_pfMetPhi,0)
                                    #print dirname, weight_to_use
                                self.fill_histos(dirname, row, weight_to_use)

                
        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
