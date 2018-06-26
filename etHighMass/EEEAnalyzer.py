from EEETree import EEETree
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
import numpy as np
cut_flow_step = ['allEvents', 'jets','trigger', 'e1sel', 'e2sel', 'e3sel', 'eiso','sign']

et_collmass = 'e_t_collinearmass'

@memo
def getVar(name, var):
    return name+var
@memo
def split(string, separator='#'):
    return tuple(attr.split(separator))


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


def deltaPhi(phi1, phi2):
    PHI = abs(phi1-phi2)
    if PHI<=pi:
        return PHI
    else:
        return 2*pi-PHI

def deltaR(phi1, ph2, eta1, eta2):
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
class EEEAnalyzer(MegaBase):
    tree = 'eee/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('EEEAnalyzer constructor')
        self.channel='EEE'
        super(EEEAnalyzer, self).__init__(tree, outfile, **kwargs)
        self.tree = EEETree(tree)
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

        self.systematics = { }
        
        self.histo_locations = {}

        self.hfunc   = {
            'nTruePU' : lambda row, weight: (row.nTruePU,None),
            'weight'  : lambda row, weight: (weight,None) if weight is not None else (1.,None),
            'Event_ID': lambda row, weight: (array.array("f", [row.run,row.lumi,int(row.evt)/10**5,int(row.evt)%10**5] ), None)##,
            ##'h_collmass_pfmet' : lambda row, weight: (collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi),weight),
            ##'h_collmass_vs_dPhi_pfmet' : merge_functions(
            ##    attr_getter('tDPhiToPfMet_type1'),
            ##    lambda row, weight: (collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi),weight)
            ##),
            ##'MetEt_vs_dPhi' : merge_functions(
            ##    lambda row, weight: (deltaPhi(row.tPhi, getattr(row, metphi())), weight),
            ##    attr_getter('type1_pfMetEt')
            ##),
            ##'ePFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.ePhi, getattr(row, metphi())), weight),
            ##'tPFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.tPhi, getattr(row, metphi())), weight),
            ##'evtInfo' : lambda row, weight: (struct(run=row.run,lumi=row.lumi,evt=row.evt,weight=weight), None)
            }

        self.DYreweight = mcCorrections.DYreweight
        self.triggerEff  = mcCorrections.efficiency_trigger_2016 if not self.is_data else 1.







        self.ZTTLweight={ 
            0 : 0.041581331,
            1 : 0.013349708,
            2 : 0.013626898,
            3 : 0.014012473,
            4 : 0.011483897
        }
        self.ZTTLowMassLweight={ #updated 23/10/2017
            0 : 0.641343812,
            1 : 0.012816778,
            2 : 0.006011141
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

    def fakerate_weights(self, tPt):
        fTauIso=0.1372
        if tPt<=200:
            fTauIso=0.215034-0.00047209*(tPt-30)

        frweight={
            'tLoose': fTauIso/(1-fTauIso)
            }
        return frweight

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

        if not self.is_data : # applying directly the efficiency measured in data
                ##print 'trigger SF', self.triggerEff(row.ePt, row.eAbsEta)
            lepList =[row.e1Pt, row.e2Pt, row.e3Pt]
            lepEtaList = [row.e1AbsEta, row.e2AbsEta, row.e3AbsEta]
            a=np.array(lepList)
            b=np.argmax(a)
            mcweight=self.triggerEff(lepList[b], lepEtaList[b])[0]
                ##print shift, 'trig eff ' , mcweight 
                
            #eisoweight = self.eleIso_weight(row,'e2')
            #eidweight =  self.eleid_weight(row.e2Eta,row.e2Pt)
            ##
            #eisoloosew = self.eleIsoLoose_weight(row,'e2')
            #eidloosew = self.eleidLoose_weight(row.e2Eta,row.e2Pt)
            ##
            #erecow = self.eleRecoweight(row.e2Eta,row.e2Pt)
            #eisoweight3 = self.eleIso_weight(row,'e3')
            #eidweight3 =  self.eleid_weight(row.e3Eta,row.e3Pt)
            #erecow3 = self.eleRecoweight(row.e3Eta,row.e3Pt)

            
            dyweight = self.DYreweight(row.genMass, row.genpT) 
        
            btagweight = 1. 
            if nbtagged>0:
                btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1hadronflavor,row.jb2pt,row.jb2hadronflavor,1,0,0)
            
            puweight = pucorrector[''](row.nTruePU)
            
            #mcweight =  mcweight*puweight*btagweight*eisoloosew*eidweight*erecow*self.tauSF['loose']
            mcweight =  mcweight*puweight*btagweight
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

            topptreweight=1

            if self.isTT:
                topptreweight=topPtreweight(row.topQuarkPt1,row.topQuarkPt2)

                
            mcweight_tight = mcweight*topptreweight
            #if self.is_DY and row.isZee  and row.tZTTGenMatching<5 :
            #    mcweight_tight=mcweight_tight*genEfakeTSF(abs(row.tEta))

            weights[''] =  mcweight_tight
            
  
        return weights

    
    
    def begin(self):
        signs =['os', 'ss']
        jetN = ['le1','0', '1']
        massRange = ['','eLoose', 'eTight']#,'LowMass', 'HighMass']
        folder=[]

        for tuple_path in itertools.product( signs,  massRange):
            #print tuple_path
            folder.append(os.path.join(*tuple_path))
            path = list(tuple_path)
            
        
        self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  100, 0, 1000)
        self.book('os/', "e_t_Mass",  "h_vismass",  100, 0, 1000)
                
        for f in folder:
            self.book(f,"weight", "weight", 100, 0, 10)

            self.book(f,"e1Pt", "e1 p_{T}", 100, 0, 1000)             
            self.book(f,"e1Phi", "e1 #phi", 26, -3.25, 3.25)
            self.book(f,"e1Eta", "e1 #eta",  10, -2.5, 2.5)
                          
            self.book(f,"e2Pt", "e2 p_{T}", 100, 0, 1000)
            self.book(f,"e2Phi", "e2 #phi",  26, -3.2, 3.2)
            self.book(f,"e2Eta", "e2 #eta", 10, -2.5, 2.5)
            
            self.book(f,"e3Pt", "e3 p_{T}", 100, 0, 1000)
            self.book(f,"e3Phi", "e3 #phi",  26, -3.2, 3.2)
            self.book(f,"e3Eta", "e3 #eta", 10, -2.5, 2.5)
             
            self.book(f, "e1_e2_DPhi", "e1-e2 DeltaPhi" , 20, 0, 3.2)
            self.book(f, "e1_e2_DR", "e1-e2 DeltaR" , 20, 0, 5.)
            
            self.book(f, "e1_e2_Mass",  "e1-e2 Mass",  60, 0, 300)
            self.book(f, "e1_e3_Mass",  "e1-e3 Mass",  60, 0, 300)
            self.book(f, "e2_e3_Mass",  "e2-e3 Mass",  60, 0, 300)
            
            self.book(f, "type1_pfMetEt",  "type1_pfMet_Et",  100, 0, 1000)
            self.book(f, "type1_pfMetPhi",  "type1_pfMet_Phi", 26, -3.2, 3.2)
            self.book(f, "jetVeto20", "Number of jets, p_{T}>20", 5, -0.5, 4.5) 
            self.book(f, "jetVeto30", "Number of jets, p_{T}>30", 5, -0.5, 4.5)

            self.book(f, "nvtx", "number of vertices", 100, 0, 100)
          
            
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

        
        logging.debug('Starting processing')
        


        lock =()
        ievt = 0
        logging.debug('Starting evt loop')
        
        for row in self.tree:
            if (ievt % 100) == 0:
                logging.debug('New event')
            ievt += 1
            #avoid double counting events!
            evt_id = (row.run, row.lumi, row.evt)
            if evt_id == lock: continue
            if lock != () and evt_id == lock:
                logging.info('Removing duplicate of event: %d %d %d' % evt_id)

            cut_flow_trk.new_row(row.run,row.lumi,row.evt)
            #print row.run,row.lumi,row.evt
            #if (self.is_DYTT and not bool(row.isZtautau or row.isGtautau)):
            #    continue
            #if (self.is_DY and bool(row.isZtautau or row.isGtautau) ):
            #    continue
            cut_flow_trk.Fill('allEvents')
            
            cut_flow_trk.Fill('jets')

            #if self.is_data:
            if not bool(row.singleE25eta2p1TightPass) : continue
            cut_flow_trk.Fill('trigger')
            
            if not selections.eSelection(row, 'e1'): continue
            cut_flow_trk.Fill('e1sel')
            if not selections.eSelection(row, 'e2'): continue
            cut_flow_trk.Fill('e2sel')
            if not selections.eSelection(row, 'e3'): continue
           
                            
            cut_flow_trk.Fill('e3sel')
            logging.debug('object selection passed')
            #e ID/ISO
            if not selections.lepton_id_iso(row, 'e1', 'eid16Loose_idiso025'): continue
            if not selections.lepton_id_iso(row, 'e2', 'eid16Loose_idiso025'): continue

            if not selections.lepton_id_iso(row, 'e3', 'eid16Loose_idiso01'): continue
            logging.debug('Passed preselection')
            cut_flow_trk.Fill('eiso')


 
            z1diff = abs(91.19 - row.e1_e2_Mass)
            z2diff = abs(91.19 - row.e1_e3_Mass)
            z3diff = abs(91.19 - row.e2_e3_Mass)
            #keep the event only if the Z is from the first pair (we can do better)
            if z1diff > z2diff: continue
            if z1diff > z3diff: continue

            if not abs(91.19-row.e1_e2_Mass)<20: continue

            #remove duplicates
            
            isEVTight = bool(selections.lepton_id_iso(row, 'e3', 'eid16Tight_idiso01'))
            
                
            passes_full_selection = False
            
            sign = 'os'
            if bool(row.e1_e2_SS)==True: sign='ss'
           
            if sign=='os': cut_flow_trk.Fill('sign')
            if row.tauVetoPt20Loose3HitsVtx : continue
            if row.muVetoPt5IsoIdVtx : continue
            if row.eVetoMVAIso : continue
 
            logging.debug('Passed Vetoes')


            #starting to set up the optimizer
            #tau pt cut
            selection_categories = []
            massRanges = ['','eLoose', 'eTight']
            #jetDir = ['le1', '0', '1']
            weight_map = self.event_weight(row,'')
            selection_categories.extend([( 'eLoose', '')])
            #selection_categories.extend([(sys, 'eLoose', str(jets), '')])

            if isEVTight:
                selection_categories.extend([( 'eTight', '')])
                #selection_categories.extend([(sys, 'eTight', str(jets), '')])


            for selection in selection_categories:
                massRange, selection_step = selection
                dirname =  os.path.join( sign, massRange, selection_step)
                if dirname.endswith('/'): dirname=dirname[:len(dirname)-1]
               
                weight_to_use =weight_map['']
                self.fill_histos(dirname, row, weight_to_use)

                
        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
