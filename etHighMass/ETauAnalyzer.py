from ETauTree import ETauTree
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
#import optimizer
import mcCorrections
from cutflowtracker import cut_flow_tracker
import bTagSF
import random
from memory_profiler import profile
cut_flow_step = ['allEvents', 'jets','trigger', 'esel', 'tsel', 'tdisc', 'eiso', 'vetoes','sign']

et_collmass = 'e_t_collinearmass'

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
t_pt  = 'tPt%s'
etMass = 'e_t_Mass%s'
jetVeto = 'jetVeto30%s'

@memo
def jetN(shift=''):
    if '_Jet' in shift:
        return jetVeto %shift.replace('jes', '')
    return jetVeto %('')

@memo
def met(shift=''):
    if '_Jet' in shift or 'UES' in shift:
        return ty1met_et %shift
    return met_et

@memo
def metphi(shift=''):
    if '_Jet' in shift or 'UES' in shift:
        return ty1met_phi %shift
    return met_phi
 
 


def attr_getter(attribute):
    '''return a function that gets an attribute'''
    def f(row, weight):
        return (getattr(row,attribute), weight)
    return f

def collmass(row, met, metPhi):
    ptnu =abs(met*cos(deltaPhi(metPhi, row.tPhi)))
    visfrac = row.tPt/(row.tPt+ptnu)
    #print met, cos(deltaPhi(metPhi, row.tPhi)), ptnu, visfrac
    return (row.e_t_Mass / sqrt(visfrac))

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
        ptnu =abs(met*cos(deltaPhi(metPhi, row.tPhi)))
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

def genEfakeTSF(ABStEta):
    if (ABStEta<1.46):
        return 1.40
    elif (ABStEta>1.558):
        return 1.90
    else :
        return 1.

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
class ETauAnalyzer(MegaBase):
    tree = 'et/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('ETauAnalyzer constructor')
        self.channel='ET'
        super(ETauAnalyzer, self).__init__(tree, outfile, **kwargs)
        self.tree = ETauTree(tree)
        self.outfile=outfile
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

        self.my_tau=ROOT.TLorentzVector()
        self.my_ele=ROOT.TLorentzVector()
        self.my_MET=ROOT.TLorentzVector()

        
        self.systematics = {
            'pu'   : (['','puUp', 'puDown'] if self.is_mc else []),
            'trig' : (['', 'trUp', 'trDown'] if not self.is_data else []),
            'highTau':(['', 'highPtTauUp', 'highPtTauDown']),
            'tes'  : (['scale_t_1prong_13TeVUp','scale_t_1prong_13TeVDown','scale_t_1prong1pizero_13TeVUp','scale_t_1prong1pizero_13TeVDown','scale_t_3prong_13TeVUp','scale_t_3prong_13TeVDown'] if not self.is_data else ['']),
            'ees'  : (["", 'eesUp','eesDown','eesresrhoUp','eesresrhoDown','eesresphiDown'] if not self.is_data else ['']),
            'etfakeES': (['', 'etfakeESUp', 'etfakeESDown'] if self.is_DY or self.is_DYLowMass else ['']),
            'ues'  : (['', 'ues_CHARGEDUESUp', 'ues_CHARGEDUESDown', 'ues_ECALUESDown', 'ues_ECALUESUp', 'ues_HCALUESDown', 'ues_HCALUESUp', 'ues_HFUESDown', 'ues_HFUESUp'] if not self.is_data else ['']),
            'jes'  : (['','jes_JetAbsoluteFlavMapDown',  'jes_JetAbsoluteMPFBiasDown',  'jes_JetAbsoluteScaleDown',  'jes_JetAbsoluteStatDown',  'jes_JetFlavorQCDDown',  'jes_JetFragmentationDown',  'jes_JetPileUpDataMCDown',  'jes_JetPileUpPtBBDown',  'jes_JetPileUpPtEC1Down',  'jes_JetPileUpPtEC2Down',  'jes_JetPileUpPtHFDown',  'jes_JetPileUpPtRefDown',  'jes_JetRelativeBalDown',  'jes_JetRelativeFSRDown',  'jes_JetRelativeJEREC1Down', 'jes_JetRelativeJEREC2Down',  'jes_JetRelativeJERHFDown',  'jes_JetRelativePtBBDown',  'jes_JetRelativePtEC1Down',  'jes_JetRelativePtEC2Down',  'jes_JetRelativePtHFDown',  'jes_JetRelativeStatECDown',  'jes_JetRelativeStatFSRDown',  'jes_JetRelativeStatHFDown',  'jes_JetSinglePionECALDown',  'jes_JetSinglePionHCALDown',  'jes_JetTimePtEtaDown',  'jes_JetAbsoluteFlavMapUp', 'jes_JetAbsoluteMPFBiasUp',  'jes_JetAbsoluteScaleUp',  'jes_JetAbsoluteStatUp',  'jes_JetFlavorQCDUp',  'jes_JetFragmentationUp',  'jes_JetPileUpDataMCUp',  'jes_JetPileUpPtBBUp',  'jes_JetPileUpPtEC1Up', 'jes_JetPileUpPtEC2Up',  'jes_JetPileUpPtHFUp',  'jes_JetPileUpPtRefUp',  'jes_JetRelativeBalUp',  'jes_JetRelativeFSRUp',  'jes_JetRelativeJEREC1Up',  'jes_JetRelativeJEREC2Up',  'jes_JetRelativeJERHFUp',  'jes_JetRelativePtBBUp',  'jes_JetRelativePtEC1Up',  'jes_JetRelativePtEC2Up',  'jes_JetRelativePtHFUp',  'jes_JetRelativeStatECUp', 'jes_JetRelativeStatFSRUp',  'jes_JetRelativeStatHFUp',  'jes_JetSinglePionECALUp',  'jes_JetSinglePionHCALUp',  'jes_JetTimePtEtaUp'] if not self.is_data else [''])
        }
        
        self.histo_locations = {}

        self.hfunc   = {
            'nTruePU' : lambda row, weight: (row.nTruePU,None),
            'weight'  : lambda row, weight: (weight,None) if weight is not None else (1.,None),
            'Event_ID': lambda row, weight: (array.array("f", [row.run,row.lumi,int(row.evt)/10**5,int(row.evt)%10**5] ), None),
            'h_collmass_pfmet' : lambda row, weight: (syst_collmass(self.my_MET.Pt(), self.my_MET.Phi(), self.my_ele, self.my_tau), weight),
            'tPt' : lambda row, weight: (self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), weight),
            'met' : lambda row, weight: ( self.my_MET.Pt(),weight),
            'h_collmass_vs_dPhi_pfmet' : merge_functions(
                attr_getter('tDPhiToPfMet_type1'),
                lambda row, weight: (collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi),weight)
            ),
            'visfrac' : lambda row, weight: (make_visfrac_systematics(self.my_MET.Pt(), self.my_MET.Phi(), self.my_tau), weight), 
            'MetEt_vs_dPhi' : merge_functions(
                lambda row, weight: (deltaPhi(row.tPhi, getattr(row, metphi())), weight),
                attr_getter('type1_pfMetEt')
            ),
            'ePFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.ePhi, getattr(row, metphi())), weight),
            'tPFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.tPhi, getattr(row, metphi())), weight),
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
        self.tauSF={ #rerecoData2016
            'vloose' : 0.99,
            'loose'  : 0.99,
            'medium' : 0.97,
            'tight'  : 0.95,
            'vtight' : 0.93
        }

    @memo
    def tauPt(self, tPt, tDecayMode, tZTTGenMatching, shift=''):
        if self.is_data or self.is_DY or self.is_DYLowMass:
            return tPt
        elif not tZTTGenMatching==5:
            return tPt
        else:
            if  tDecayMode==0:
                tau_Pt_C=0.982*tPt
            elif  tDecayMode==1:
                tau_Pt_C=1.01*tPt
            elif  tDecayMode==10:
                tau_Pt_C=1.004*tPt
            return tau_Pt_C
    @memo
    def metTauC(self, tPt, tDecayMode, tZTTGenMatching, mymet, shift=''):
        themet = mymet
        if self.is_data or self.is_DY or self.is_DYLowMass:
            return themet
        elif not tZTTGenMatching==5:
            return themet
        else:
            #print themet, row.tPt
            if  tDecayMode==0:
                MET_tPtC=themet+0.018*tPt
            elif  tDecayMode==1:
                MET_tPtC=themet-0.01*tPt
            elif  tDecayMode==10:
                MET_tPtC=themet-0.004*tPt
            return MET_tPtC



    def fakerate_weights(self, tPt, tDecay):
        fTauIso=1.
        
        if tDecay==0 or tDecay==1:
            if tPt< 90:
                fTauIso=0.239-0.00085*(tPt-30.)
                fTauIsoUp=(0.239+0.004)-(0.00085+0.00022)*(tPt-30.)
                fTauIsoDown=(0.239-0.004)-(0.00085-0.00022)*(tPt-30.)
                
            elif tPt>90 and tPt< 220:
                fTauIso=0.185
                fTauIsoUp=0.185+0.013
                fTauIsoDown=0.185-0.013
            else:
                fTauIso=0.032
                fTauIsoUp=0.032+0.082
                fTauIsoDown=0.032+0.032
        else:
            if tPt< 90:
                fTauIso=0.182
                fTauIsoUp=0.182+0.003
                fTauIsoDown=0.182-0.003
            elif tPt>90 and tPt< 200:
                fTauIso=0.109
                fTauIsoUp=0.109+0.017
                fTauIsoDown=0.109-0.017
            else:
                fTauIso=0.062
                fTauIsoUp=0.062+0.088
                fTauIsoDown=0.062-0.062

                
                
        frweight={
            'tLoose': fTauIso/(1-fTauIso),
            'tLoose/Down' : fTauIsoDown/(1-fTauIsoDown),
            'tLoose/Up': fTauIsoUp/(1-fTauIsoUp)
            }
        return frweight

 
#    @profile
    def event_weight(self, row, sys_shifts):
#    def event_weight(self, bjetCISVVeto30Medium, ePt, eAbsEta,tEta, tDecayMode, tZTTGenMatching, genMass, genpT, jb1pt,jb1hadronflavor,jb2pt,jb2hadronflavor, nTruePU, numGenJets, isZee, sys_shifts):
        
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
        if not self.is_data : # applying directly the efficiency measured in data
            ##print 'trigger SF', self.triggerEff(row.ePt, row.eAbsEta)
            mcweight=self.triggerEff(row.ePt, row.eAbsEta)[0]
            ##print shift, 'trig eff ' , mcweight 
                
        dyweight = self.DYreweight(row.genMass, row.genpT) 
        
        btagweight = 1. 
        if nbtagged>0:
            btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1hadronflavor,row.jb2pt,row.jb2hadronflavor,1,0,0)
            
        puweight = pucorrector[''](row.nTruePU)
            
        mcweight =  mcweight*puweight*btagweight*self.tauSF['loose']
        if self.is_DY or self.is_DYTT:
            if row.numGenJets < 5:
                mcweight = mcweight*self.ZTTLweight[row.numGenJets]*dyweight
            else:
                mcweight = mcweight*self.ZTTLweight[0]*dyweight
                    
        if self.is_DYLowMass:
            if row.numGenJets < 3:
                mcweight = mcweight*self.ZTTLowMassLweight[row.numGenJets]*dyweight
            else:
                mcweight = mcweight*self.ZTTLowMassLweight[0]*dyweight
                       
        if self.is_W:
            if row.numGenJets < 5:
                mcweight = mcweight*self.Wweight[row.numGenJets]
            else:
                mcweight = mcweight*self.Wweight[0]
                
        mcweight_tight = mcweight*self.tauSF['vtight']/self.tauSF['loose']
        #print '----------------'
        print 'weight %s, puweight %s' %(mcweight_tight, puweight)
        if self.is_DY and row.isZee  and row.tZTTGenMatching<5 :
            mcweight_tight=mcweight_tight*genEfakeTSF(abs(row.tEta))

        
        for shift in sys_shifts:
            syst_mcweight_tight=-999.
            if shift=='trUp':
                syst_mcweight_tight=(mcweight_tight/self.triggerEff(row.ePt, row.eAbsEta)[0])*self.triggerEff(row.ePt, row.eAbsEta)[0]*1.02
 
            elif shift=='trDown':
                syst_mcweight_tight=(mcweight_tight/self.triggerEff(row.ePt, row.eAbsEta)[0])*self.triggerEff(row.ePt, row.eAbsEta)[0]*0.98
                ##    print 'trig eff dw' , mcweight 
            if shift=='puUp' or shift=='puDown':
                puweight_sys = pucorrector[shift](row.nTruePU)
                syst_mcweight_tight=mcweight_tight*puweight_sys/puweight
                print  '%s, original weight %s, puweight %s, puweightShifted %s, finale weight %s' %(shift, mcweight_tight,  puweight, puweight_sys, syst_mcweight_tight)

            if shift=='highPtTauUp':
                syst_mcweight_tight=mcweight_tight*(1.+0.05*(self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching)/1000.))
            elif shift=='highPtTauDown':
                #print shift, row.tPt, mcweight, mcweight*(1.-0.35*(row.tPt/1000.))
                syst_mcweight_tight=mcweight_tight*(1.-0.35*(self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching)/1000.))
            
            print 'weight', shift, mcweight_tight, syst_mcweight_tight
            weights[shift] =  syst_mcweight_tight if syst_mcweight_tight!=-999. else mcweight_tight

        
        return weights

    
    
    def begin(self):
        sys_shifts = ['','tLoose', 'tLoose/Up', 'tLoose/Down'] + self.systematics['pu'] + self.systematics['trig'] \
                     +  self.systematics['ees'] + self.systematics['tes'] + self.systematics['ues'] + self.systematics['jes'] + self.systematics['etfakeES']+self.systematics['highTau']
        #remove double dirs
        sys_shifts = list(set(sys_shifts))
        signs =['os']
        jetN = ['le1','0', '1']
        massRange = ['','LowMass', 'HighMass']
        folder=[]
        self.outfile.cd()
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
        
        self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  300, 0, 1500)
        self.book('os/', "e_t_Mass",  "h_vismass",  300, 0, 1500)
                
        for f in folder:
            self.book(f,"weight", "weight", 100, 0, 10)

            self.book(f,"tPt", "tau p_{T}", 100, 0, 1000)             
            self.book(f,"tPhi", "tau #phi", 26, -3.25, 3.25)
            self.book(f,"tEta", "tau #eta",  10, -2.5, 2.5)
            self.book(f, "tDecayMode", "tDecayMode", 12, -0.5, 11.5)
                        
            self.book(f,"ePt", "e p_{T}", 100, 0, 1000)
            self.book(f,"ePhi", "e #phi",  26, -3.2, 3.2)
            self.book(f,"eEta", "e #eta", 10, -2.5, 2.5)
             
            self.book(f, "e_t_DPhi", "e-tau DeltaPhi" , 20, 0, 3.2)
            self.book(f, "e_t_DR", "e-tau DeltaR" , 20, 0, 5.)
            
            self.book(f, "h_collmass_pfmet",  "h_collmass_pfmet",  300, 0, 1500)
            self.book(f, "visfrac",  "visfrac",  100, 0., 1.)
            self.book(f, "e_t_Mass",  "h_vismass",  300, 0, 1500)
            
            
            #self.book(f, "tPfMet_DeltaPhi", "Tau-PFMET M_{T}" , 100, 0, 500)
            self.book(f, "tMtToPfMet_type1", "Tau-PFMET M_{T}" , 100, 0, 500)
            self.book(f, "eMtToPfMet_type1", "e-PFMET M_{T}" , 100, 0, 500)
            #self.book(f, "eMtToPfMet_type1", "e-PFMET M_{T}" , 100, 0, 500)
            #self.book(f, "type1_pfMetEt",  "type1_pfMet_Et",  100, 0, 1000)
            self.book(f, "met",  "type1_pfMet_Et",  100, 0, 1000)
            self.book(f, "type1_pfMetPhi",  "type1_pfMet_Phi", 26, -3.2, 3.2)
            self.book(f, "jetVeto20", "Number of jets, p_{T}>20", 5, -0.5, 4.5) 
            self.book(f, "jetVeto30", "Number of jets, p_{T}>30", 5, -0.5, 4.5)

            self.book(f, "e_t_PZeta", "e_t_PZeta", 200, -400, 400)
            self.book(f, "e_t_PZetaLess0p85PZetaVis", "e_t_PZetaLess0p85PZetaVis", 100, -200, 200)
            self.book(f, "e_t_PZetaVis", "e_t_PZetaVis", 100, 0, 300 )

            self.book(f, "nvtx", "number of vertices", 100, 0, 100)

            self.book(f, "eGenEta", "e #eta (gen)", 10, -2.5, 2.5)
            self.book(f, "eGenPt", "e p_{T} (gen)", 100, 0, 1000)
            self.book(f, "eGenPhi", "e #phi (gen)",  26, -3.2, 3.2)
            self.book(f, "tGenEta", "#tau #eta (gen)", 10, -2.5, 2.5)
            self.book(f, "tGenPt", "#tau p_{T} (gen)", 100, 0, 1000)
            self.book(f, "tGenPhi", "#tau #phi (gen)",  26, -3.2, 3.2)
            self.book(f, "eComesFromHiggs", "eComesFromHiggs", 2, -0.5, 1.5)
            self.book(f, "tComesFromHiggs", "tComesFromHiggs", 2, -0.5, 1.5)
            self.book(f, "tGenDecayMode", "tGenDecayMode", 12, -0.5, 11.5)
           
            
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
                     + self.systematics['ees'] + self.systematics['tes']+ self.systematics['tes'] + self.systematics['ues'] + self.systematics['jes'] + self.systematics['etfakeES']+self.systematics['highTau']
        logging.debug('Starting processing')
        


        lock =()
        ievt = 0
        logging.debug('Starting evt loop')
        
        for row in self.tree:
            if (ievt % 1000) == 0:
                
                #print 'new event', ievt
                logging.debug('New event')
            #if ievt==1000: return
            ievt += 1
            #avoid double counting events!
            evt_id = (row.run, row.lumi, row.evt)
            if evt_id == lock: continue
            if lock != () and evt_id == lock:
                logging.info('Removing duplicate of event: %d %d %d' % evt_id)

            cut_flow_trk.new_row(row.run,row.lumi,row.evt)
            ##print row.run,row.lumi,row.evt
            if (self.is_DYTT and not bool(row.isZtautau or row.isGtautau)):
                continue
            if (self.is_DY and bool(row.isZtautau or row.isGtautau) ):
                continue
            cut_flow_trk.Fill('allEvents')
            
            cut_flow_trk.Fill('jets')

            #if self.is_data:
            if not bool(row.singleE25eta2p1TightPass) : continue
            cut_flow_trk.Fill('trigger')
            
            if not selections.eSelection(row, 'e'): continue
            cut_flow_trk.Fill('esel')
            if not selections.tauSelection(row, 't'): continue
            cut_flow_trk.Fill('tsel')

            if deltaR(row.ePhi, row.tPhi, row.eEta, row.tEta) < 0.3: continue
                            
            if not row.tAgainstElectronTightMVA6: continue
            if not row.tAgainstMuonLoose3 : continue
            if not row.tByVLooseIsolationMVArun2v1DBoldDMwLT : continue
            cut_flow_trk.Fill('tdisc')
            logging.debug('object selection passed')
            #e ID/ISO

        
            
            if not selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso025'): continue
            logging.debug('Passed preselection')
            cut_flow_trk.Fill('eiso')
            
            sys_directories = sys_shifts
            #remove duplicates
            sys_directories = list(set(sys_directories))
            
            isTauTight = bool(row.tByTightIsolationMVArun2v1DBoldDMwLT)
            isEVTight = bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso01'))

            if not isEVTight: continue
            weight_sys_shifts=sys_shifts
            weight_sys_shifts.append('')
            weight_sys_shifts=list(set(weight_sys_shifts))
            weight_map = self.event_weight(row, weight_sys_shifts)
            #print weight_map
            #if not row.e_t_SS: #Fill embedded sample normalization BEFORE the vetoes
            #    self.fill_histos('os', row, weight_map[''])

            etau_category = ['']                
            if not isTauTight :
                mc_weight = weight_map['']
                tweight=self.fakerate_weights(self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tDecayMode)['tLoose']*mc_weight
                tLoose_weight = {'tLoose': tweight}
                weight_map.update(tLoose_weight )
                sys_directories.extend(['tLoose'])
                sys_directories=remove_element(sys_directories, '')
                myrand=random.random()
                if myrand<0.5:
                    tweightDown=self.fakerate_weights(self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tDecayMode)['tLoose/Down']*mc_weight
                    tLooseDown_weight = {'tLoose/Down': tweightDown}
                    weight_map.update(tLooseDown_weight )
                    tLooseUp_weight = {'tLoose/Up': tweight}
                    weight_map.update(tLooseUp_weight )
                else:
                    tweightUp=self.fakerate_weights(self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tDecayMode)['tLoose/Up']*mc_weight
                    tLooseUp_weight = {'tLoose/Up': tweightUp}
                    weight_map.update(tLooseUp_weight )
                    tLooseDown_weight = {'tLoose/Down': tweight}
                    weight_map.update(tLooseDown_weight )
                
                sys_directories.extend(['tLoose/Up'])
                sys_directories.extend(['tLoose/Down'])
                sys_directories=remove_element(sys_directories, '')
                
            #print sys_directories
            passes_full_selection = False
            
            sign = 'os'
            if bool(row.e_t_SS)==True:
                sign='ss'
                continue
            if row.tauVetoPt20Loose3HitsVtx : continue
            if row.muVetoPt5IsoIdVtx : continue
            if row.eVetoMVAIso : continue
            cut_flow_trk.Fill('vetoes')
            logging.debug('Passed Vetoes')


            #starting to set up the optimizer
            #tau pt cut
            selection_categories = []
            massRanges = ['','LowMass', 'HighMass']
            jetDir = ['le1', '0', '1']
            
            self.my_ele.SetPtEtaPhiM(row.ePt,row.eEta,row.ePhi,  0.000511)
            self.my_tau.SetPtEtaPhiM(self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
            self.my_MET.SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching, row.type1_pfMetEt),0,row.type1_pfMetPhi,0)

            myEle = {}
            myTau = {}
            myMET = {}
            #print sys_directories
            
            for sys in sys_directories :
                #if sys=='' :
                     #print 'central value', self.my_tau.Pt(), self.my_MET.Pt(), 'evtid', row.evt
                     #print 'up', 1.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,row.type1_pfMetEt)-0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching)
                     #print 'down', 0.988*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,row.type1_pfMetEt)+0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching)
                     #print weight_map[sys] if sys in weight_map else weight_map[''], (sys in weight_map)
                #print '-------------------'
                if 'ees' in sys:
                    if 'eesUp' in sys:
                        
                        myEle[sys]= ROOT.TLorentzVector()
                        myEle[sys].SetPtEtaPhiM(row.ePt_ElectronScaleUp,row.eEta,row.ePhi, 0.000511)
                    
                    if 'eesDown' in sys:
                        myEle[sys]= ROOT.TLorentzVector()
                        myEle[sys].SetPtEtaPhiM(row.ePt_ElectronScaleDown,row.eEta,row.ePhi,  0.000511)
                        
                    
                    if 'eesresrhoUp' in sys:
                        
                        myEle[sys]= ROOT.TLorentzVector()
                        myEle[sys].SetPtEtaPhiM(row.ePt_ElectronResRhoUp, row.eEta,row.ePhi,  0.000511)
                       
                    
                    if 'eesresrhoDown' in sys:
                        myEle[sys]= ROOT.TLorentzVector()
                        myEle[sys].SetPtEtaPhiM(row.ePt_ElectronResRhoDown, row.eEta,row.ePhi,  0.000511)
                        
                    
                    if 'eesresphiDown' in sys:
                        myEle[sys]= ROOT.TLorentzVector()
                        myEle[sys].SetPtEtaPhiM(row.ePt_ElectronResPhiDown, row.eEta,row.ePhi,  0.000511)
                       
                    
                    #print sys, myEle[sys].Pt(), myTau[sys].Pt(), myMET[sys].Pt(), row.ePt, self.tauPt(row.tPt, row.tDecayMode),self.metTauC(row.tPt, row.tDecayMode, row.type1_pfMetEt)
                if 'prong' in sys:
                    if row.tDecayMode == 0:
                        if '_1prong_' in sys:
                            if 'Up' in sys:
                                myTau[sys] = ROOT.TLorentzVector()
                                myMET[sys] = ROOT.TLorentzVector()
                                myTau[sys].SetPtEtaPhiM(1.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                                myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,row.type1_pfMetEt)-0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)
                            if 'Down' in sys:
                                myTau[sys] = ROOT.TLorentzVector()
                                myMET[sys] = ROOT.TLorentzVector()
                                myTau[sys].SetPtEtaPhiM(0.988*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                                myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode,row.tZTTGenMatching, row.type1_pfMetEt)+0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)                    
                                  
                        #print sys, self.my_tau.Pt(), self.my_MET.Pt(), self.my_ele.Pt(), row.tPt, row.type1_pfMetEt, row.ePt
                    elif row.tDecayMode ==1:
                        if '1prong1pizero' in sys:
                            if 'Up' in sys:
                                myTau[sys] = ROOT.TLorentzVector()
                                myMET[sys] = ROOT.TLorentzVector()
                                myTau[sys].SetPtEtaPhiM(1.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                                myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,row.type1_pfMetEt)-0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)
                
                            if 'Down' in sys:
                                myTau[sys]= ROOT.TLorentzVector()
                                myMET[sys] = ROOT.TLorentzVector()
                                myTau[sys].SetPtEtaPhiM(0.988*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                                myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,row.type1_pfMetEt)+0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)
                                #print sys, self.my_tau.Pt(), self.my_MET.Pt(), self.my_ele.Pt(), row.tPt, row.type1_pfMetEt, row.ePt

                    elif row.tDecayMode ==10:
                        if '_3prong_' in sys:
                            #print 'central (check)', self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), self.metTauC(row.tPt, row.tDecayMode,row.tZTTGenMatching, row.type1_pfMetEt)-0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),  'evtid', row.evt
                            if 'Up' in sys:
                                myTau[sys]  = ROOT.TLorentzVector()
                                myMET[sys]  = ROOT.TLorentzVector()
                                myTau[sys].SetPtEtaPhiM(1.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                                myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode,row.tZTTGenMatching, row.type1_pfMetEt)-0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)
                                #print sys, myTau[sys].Pt(), myMET[sys].Pt()
                                #print weight_map[sys] if sys in weight_map else weight_map[''], (sys in weight_map)
                            if 'Down' in sys:
                                myTau[sys] = ROOT.TLorentzVector()
                                myMET[sys] = ROOT.TLorentzVector()
                                myTau[sys].SetPtEtaPhiM(0.988*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                                myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode,row.tZTTGenMatching, row.type1_pfMetEt)+0.012*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)
                                #print sys, myTau[sys].Pt(), myMET[sys].Pt()
                                #print weight_map[sys] if sys in weight_map else weight_map[''], (sys in weight_map)
                            #print self.my_MET.Pt(), self.my_MET.Phi(), row.type1_pfMetEt, row.tPt,  row.type1_pfMetPhi

                if 'jes_' in sys:
                    myMET[sys] =  ROOT.TLorentzVector()
                    myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching, getattr(row,met(sys.replace('jes_','_')))), 0,
                                             getattr(row,metphi(sys.replace('jes_','_'))),0)
                    #if (getattr(row,met(sys.replace('jes_','_')))-row.type1_pfMetEt)!=0 : print 'met info', sys, sys.replace('jes_','_'), getattr(row,met(sys.replace('jes_','_'))), getattr(row,metphi(sys.replace('jes_','_'))), row.type1_pfMetEt, row.type1_pfMetPhi
                     
                    
                    #print sys, self.my_tau.Pt(), self.my_MET.Pt(), self.my_ele.Pt(), syst_collmass(self.my_MET.Pt(), self.my_MET.Phi(), self.my_ele, self.my_tau), row.tPt, row.type1_pfMetEt, row.ePt, collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)
                if 'UES' in sys:
                    myMET[sys] =  ROOT.TLorentzVector()
                    myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,getattr(row,met(sys.replace('ues_', '_')))), 0,
                                             getattr(row,metphi(sys.replace('ues_', '_'))),0)
                    
                    
                    #print sys, self.my_MET.Pt(),myMET[sys].Pt(), self.my_MET.Phi(),myMET[sys].Phi(), weight_map[sys] if sys in weight_map else -999., weight_map['']

                if bool(self.is_DY or self.is_DYLowMass) and row.isZee and row.tZTTGenMatching<5 and row.tDecayMode==1:
                    if 'etfakeES' in sys:
                        if 'Up' in sys:
                            myTau[sys]  = ROOT.TLorentzVector()
                            myMET[sys] =  ROOT.TLorentzVector()
                            myTau[sys].SetPtEtaPhiM(1.03*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                            myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,row.type1_pfMetEt)-0.03*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)
                             
                        if 'Down' in sys:
                            myTau[sys]  = ROOT.TLorentzVector()
                            myMET[sys] =  ROOT.TLorentzVector()
                            myTau[sys].SetPtEtaPhiM(0.97*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                            myMET[sys].SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode,row.tZTTGenMatching,row.type1_pfMetEt)+0.03*self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching),0,row.type1_pfMetPhi,0)
                            
                        #print sys, self.my_tau.Pt(), self.my_MET.Pt(), self.my_ele.Pt(), row.tPt, row.type1_pfMetEt, row.ePt
                #print sys, len(myTau)
                #if sys in myMET: print sys, "MET", myMET[sys].Pt() , self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching, row.type1_pfMetEt)
                
                #if sys in myTau: print sys, 'Tau', myTau[sys].Pt(),  self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching)
                
                #if sys in myEle: print sys, 'Ele', myEle[sys].Pt(),   row.ePt
                

                
                jets = min(int(getattr(row,jetN(sys))), 2)
                #if sys=='' and getattr(row,jetN(sys))!=row.jetVeto30 : print sys, getattr(row,jetN(sys)), row.jetVeto30
                if jets==2 : continue

                #print 'checking syst'
                #if sys in myTau: print 'myTau', myTau[sys].Pt()
                #if sys in myEle: print 'myEle', myEle[sys].Pt()
                #if sys in myMET: print 'myMET', myMET[sys].Pt()
                

                my_tau=myTau[sys] if sys in myTau else self.my_tau
                my_met=myMET[sys] if sys in myMET else self.my_MET
                my_ele=myEle[sys] if sys in myEle else self.my_ele

                #print 'tau (%r) pt %f, ele pt %f , MET %f' %(isTauTight, my_tau.Pt(), my_ele.Pt(), my_met.Pt())
                
                totalEt = my_tau.Et() + my_met.Et();
                totalPt = (my_tau+my_met).Pt()
                mytMtMet = sqrt(abs(totalEt*totalEt - totalPt*totalPt))
                if not (sys=='tLoose' or sys=='tLoose/Up' or sys=='tLoose/Down') and isTauTight==False: continue
                ## if sys=='' : print self.my_ele.Pt(), row.ePt, self.my_tau.Pt(), row.tPt
                selection_categories.extend([(sys, '', 'le1', '')])
                selection_categories.extend([(sys, '', str(jets), '')])
                if my_ele.Pt() > 60 and my_tau.Pt() >30 :
                    if (jets<=1 and mytMtMet<120):
                        selection_categories.extend([(sys,'LowMass', 'le1', '')])
                    if (jets==0 and mytMtMet < 105) or (jets==1 and mytMtMet < 120):
                        selection_categories.extend([(sys,'LowMass',str(jets), '')])
                    if my_ele.Pt() > 150 and my_tau.Pt()>45:
                        if (jets<=1 and mytMtMet < 230):
                            selection_categories.extend([(sys, 'HighMass', 'le1','')])
                        if (jets==0 and mytMtMet < 200) or (jets==1 and mytMtMet < 230):
                            selection_categories.extend([(sys, 'HighMass', str(jets),'')])

                #print 'tau pt %f, ele pt %f , MET %f' %(my_tau.Pt(), my_ele.Pt(), my_met.Pt())

                            
            #for sys in myMET:
            #    #print sys, myTau[sys].Pt(), myMET[sys].Pt() , myEle[sys].Pt(),  self.tauPt(row.tPt, row.tDecayMode), self.metTauC(row.tPt, row.tDecayMode,row.type1_pfMetEt), row.ePt
            #    print 'rewewing syst MET',  sys,myMET[sys].Pt(), self.metTauC(row.tPt, row.tDecayMode,row.type1_pfMetEt)
            
            
            for selection in selection_categories:
                
                selection_sys, massRange, jet_dir,  selection_step = selection
                #print selection_sys, massRange, jet_dir,  selection_step
                dirname =  os.path.join(selection_sys, sign, massRange, jet_dir, selection_step)
                if sign=='os': cut_flow_trk.Fill('sign')
                tmpTau=ROOT.TLorentzVector()
                tmpEle=ROOT.TLorentzVector()
                tmpMET=ROOT.TLorentzVector()
                tmpTau.SetPtEtaPhiM(self.tauPt(row.tPt, row.tDecayMode, row.tZTTGenMatching), row.tEta, row.tPhi, 1.77686)
                tmpEle.SetPtEtaPhiM(row.ePt, row.eEta, row.ePhi,  0.000511)
                tmpMET.SetPtEtaPhiM(self.metTauC(row.tPt, row.tDecayMode, row.tZTTGenMatching,row.type1_pfMetEt),0,row.type1_pfMetPhi,0)
                mytau=myTau[selection_sys] if selection_sys in myTau else tmpTau
                mymet=myMET[selection_sys] if selection_sys in myMET else tmpMET
                myele=myEle[selection_sys] if selection_sys in myEle else tmpEle

                #print 'collmass ', selection_sys, syst_collmass(self.my_MET.Pt(), self.my_MET.Phi(), self.my_ele, self.my_tau), syst_collmass(mymet.Pt(), mymet.Phi(), myele, mytau)
                #print 'I am filling %s, tau pt %f, ele pt %f , MET %f;' %(selection_sys,mytau.Pt(), myele.Pt(), mymet.Pt()) ,  tmpTau.Pt(), tmpEle.Pt() , tmpMET.Pt()

                if dirname[-1] == '/':
                    dirname = dirname[:-1]
                weight_to_use = weight_map[selection_sys] if selection_sys in weight_map else weight_map['']
                #print dirname, evt_id
                self.my_ele = myele
                self.my_tau = mytau
                self.my_MET = mymet
                
                #print 'I am filling %s, tau pt %f, ele pt %f , MET %f;' %(selection_sys,mytau.Pt(), myele.Pt(), mymet.Pt()) ,  self.my_tau.Pt(), self.my_ele.Pt() , self.my_MET.Pt()

                #if selection_sys in myEle :
                #    self.my_ele = myEle[selection_sys]
                #else:
                #    self.my_ele.SetPtEtaPhiM(row.ePt,row.eEta,row.ePhi,  0.000511)
                #if selection_sys in myTau:
                #    self.my_tau = myTau[selection_sys]
                #else:
                #    self.my_tau.SetPtEtaPhiM(row.tPt, row.tEta, row.tPhi, 1.77686)
                #if selection_sys in myMET:
                #    self.my_MET = myMET[selection_sys]
                #else:
                #    self.my_MET.SetPtEtaPhiM(row.type1_pfMetEt,0,row.type1_pfMetPhi,0)

                #print dirname, evt_id
                #print 'sys %s: collinear mass: %.2f %.2f , ele Pt %.2f %.2f, tau Pt %.2f %.2f, met %.2f %.2f' %(selection_sys, row.e_t_collinearmass, syst_collmass(self.my_MET.Pt(),self.my_MET.Phi(), self.my_ele, self.my_tau), row.ePt, self.my_ele.Pt(),  self.tauPt(row.tPt, row.tDecayMode), self.my_tau.Pt(), self.metTauC(row.tPt, row.tDecayMode,row.type1_pfMetEt), self.my_MET.Pt())
                #print selection_sys, massRange, jet_dir, selection_step, weight_map, weight_to_use
                #print 'filling histo in', dirname
                self.fill_histos(dirname, row, weight_to_use)

                
        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
