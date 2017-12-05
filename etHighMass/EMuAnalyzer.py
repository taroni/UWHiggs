from EMuTree import EMuTree
import sys
import logging
logging.basicConfig(stream=sys.stderr, level=logging.WARNING)
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
cut_flow_step = ['allEvents', 'jets','trigger', 'esel', 'msel',  'eiso', 'vetoes','sign']
                 
@memo
def getVar(name, var):
    return name+var
@memo
def split(string, separator='#'):
    return tuple(attr.split(separator))
met_et  = 'pfMet_Et%s'
met_phi = 'pfMet_Phi%s'
ty1met_et  = 'type1_pfMetEt%s'
ty1met_phi = 'type1_pfMetPhi%s'
t_pt  = 'tPt%s'
etMass = 'e_t_Mass%s'

@memo
def metphi(shift=''):
    if not 'es' in shift :
        return ty1met_phi %shift
    return met_phi % shift

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

pucorrector = mcCorrections.make_puCorrector('singlee', None)

class EMuAnalyzer(MegaBase):
    tree = 'em/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('EMuAnalyzer constructor')
        self.channel='ET'
        super(EMuAnalyzer, self).__init__(tree, outfile, **kwargs)
        self.tree = EMuTree(tree)
        self.out=outfile
        self.histograms = {}

        #understand what we are running
        target = os.path.basename(os.environ['megatarget'])
        self.is_data = target.startswith('data_')
        self.is_embedded = ('Embedded' in target)
        self.is_mc = not (self.is_data or self.is_embedded)
        self.is_DY = bool('JetsToLL_M-50' in target)
        self.is_W = bool('JetsToLNu' in target)
        self.is_HighMass = bool('ggM' in target)

        self.histo_locations = {}

        self.hfunc   = {
            'nTruePU' : lambda row, weight: (row.nTruePU,None),
            'weight'  : lambda row, weight: (weight,None) if weight is not None else (1.,None),
            'Event_ID': lambda row, weight: (array.array("f", [row.run,row.lumi,int(row.evt)/10**5,int(row.evt)%10**5] ), None),
            'h_collmass_pfmet' : lambda row, weight: (collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi),weight),
            'h_collmass_vs_dPhi_pfmet' : merge_functions(
                attr_getter('tDPhiToPfMet_type1'),
                lambda row, weight: (collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi),weight)
            ),
            'MetEt_vs_dPhi' : merge_functions(
                lambda row, weight: (deltaPhi(row.mPhi, getattr(row, metphi())), weight),
                attr_getter('type1_pfMetEt')
            ),
            'ePFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.ePhi, getattr(row, metphi())), weight),
            'mPFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.mPhi, getattr(row, metphi())), weight),
            'evtInfo' : lambda row, weight: (struct(run=row.run,lumi=row.lumi,evt=row.evt,weight=weight), None)
            }
        self.eleid_weight = mcCorrections.electronID_Tight
        self.eleIso_weight = mcCorrections.electronIso_0p10_2016 
        self.eleidLoose_weight = mcCorrections.electronID_Tight
        self.eleIsoLoose_weight = mcCorrections.electronIso_0p15_2016
        self.eleRecoweight = mcCorrections.erecon_corrector

        self.muid_weight = mcCorrections.muonID_full2016_medium
        self.muiso_weight = mcCorrections.muonIso_full2016_loose
        self.muisoTight_weight = mcCorrections.muonIso_full2016_tight
        self.muTracking= mcCorrections.muonTracking_full2016
        
        self.DYreweight = mcCorrections.DYreweight
        self.trig_weight  = mcCorrections.efficiency_trigger_2016 if not self.is_data else 1.
        
        self.mu23Trig_weight = mcCorrections.muLeg23_trigger_2016 if not self.is_data else 1.
        self.ele23Trig_weight = mcCorrections.eleLeg23_trigger_2016 if not self.is_data else 1.
        self.mu8Trig_weight = mcCorrections.muLeg8_trigger_2016 if not self.is_data else 1.
        self.ele12Trig_weight = mcCorrections.eleLeg12_trigger_2016 if not self.is_data else 1.
        self.mc_mu23Trig_weight = mcCorrections.mc_muLeg23_trigger_2016 if not self.is_data else 1.
        self.mc_ele23Trig_weight = mcCorrections.mc_eleLeg23_trigger_2016 if not self.is_data else 1.
        self.mc_mu8Trig_weight = mcCorrections.mc_muLeg8_trigger_2016 if not self.is_data else 1.
        self.mc_ele12Trig_weight = mcCorrections.mc_eleLeg12_trigger_2016 if not self.is_data else 1.

        self.ZTTLweight={ #updated 23/10/2017
            0 : 0.041324191,
            1 : 0.013323092,
            2 : 0.013599166,
            3 : 0.013983151,
            4 : 0.011464196
        }
        self.Wweight={#updated 23/10/2017
            0 : 0.709390278,
            1 : 0.190063899,
            2 : 0.058529964,
            3 : 0.019206445,
            4 : 0.01923548
        }


        
    def event_weight(self, row, sys_shifts):
        nbtagged=row.bjetCISVVeto30Medium
        if nbtagged>2:
            nbtagged=2
        if self.is_data:
            if nbtagged>0 :
                return {'' : 0.,
                        'eVTight' : 0.}
            else:
                return {'' : 1.,
                        'eVTight' : 1.}
            
        mcweight = 1. # put here the trigger weight self.trig_weight(row.m1Pt, row.m1AbsEta)
        eleTr23 =self.ele23Trig_weight(row.ePt, row.eAbsEta )
        muTr23  =self.mu23Trig_weight(row.mPt, row.mAbsEta)
        eleTr12 =self.ele12Trig_weight(row.ePt,row.eAbsEta)
        muTr8   =self.mu8Trig_weight(row.mPt, row.mAbsEta)
        mc_eleTr23 =self.mc_ele23Trig_weight(row.ePt, row.eAbsEta )
        mc_muTr23  =self.mc_mu23Trig_weight(row.mPt, row.mAbsEta)
        mc_eleTr12 =self.mc_ele12Trig_weight(row.ePt,row.eAbsEta)
        mc_muTr8   =self.mc_mu8Trig_weight(row.mPt, row.mAbsEta)

        
        if not self.is_data :
            #applying directly the efficiency measured in data
            trig_weight = muTr23[0]*eleTr12[0]+muTr8[0]*eleTr23[0]-muTr23[0]*eleTr23[0]
            mcweight= mcweight*trig_weight
            
        #print bool(self.is_data), bool(self.is_HighMass), mcweight
        eisoweight = self.eleIso_weight(row,'e')
        eidweight =  self.eleid_weight(row.eEta,row.ePt)
        midweight=self.muid_weight(row.mPt, row.mAbsEta)
        misotightweight= self.muisoTight_weight( row.mPt, row.mAbsEta)
        mtracking = self.muTracking(row.mEta)[0]
        
        eisoloosew = self.eleIsoLoose_weight(row,'e')
        eidloosew = self.eleidLoose_weight(row.eEta,row.ePt)
        misoweight= self.muiso_weight( row.mPt,row.mAbsEta)

        erecow = self.eleRecoweight(row.eEta,row.ePt)
            
        dyweight = self.DYreweight(row.genMass, row.genpT) 
        
        btagweight = 1. 
        if nbtagged>0:
            btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1hadronflavor,row.jb2pt,row.jb2hadronflavor,1,0,0)

            
        mcweight =  mcweight*pucorrector(row.nTruePU)*btagweight*eisoloosew*erecow*eidweight*midweight*misoweight*mtracking

        
        if self.is_DY:
            if row.numGenJets < 5:
                mcweight = mcweight*self.ZTTLweight[row.numGenJets]*dyweight
            else:
                mcweight = mcweight*self.ZTTLweight[0]*dyweight
            #if dyweight > 1.5 : 
            #    print  row.evt, row.run, row.lumi, row.m1Pt, row.m2Pt, row.ePt, mcweight, dyweight, mcweight/dyweight
        if self.is_W:
            if row.numGenJets < 5:
                mcweight = mcweight*self.Wweight[row.numGenJets]
            else:
                mcweight = mcweight*self.Wweight[0]

        mcweight_tight = mcweight*eisoweight/eisoloosew*misotightweight/misoweight

        weights = {'': mcweight,
                   'eVTight' : mcweight_tight
        } 
  
        return weights
    
    def begin(self):
        sys_shifts = []
        sys_shifts = list( set( sys_shifts ) ) #remove double dirs
        signs =['os', 'ss']
        jetN = ['0', '1', 'le1']
        massRange = ['','LowMass', 'HighMass']
        folder=[]

        for tuple_path in itertools.product(sys_shifts, signs,  massRange, jetN):
        #for tuple_path in itertools.product(signs, jetN):
            folder.append(os.path.join(*tuple_path))
            path = list(tuple_path)
            #path.append('selected')
            #folder.append(os.path.join(*path))
            prefix_path = os.path.join(*tuple_path)
            ##print 'path',os.path.join(*path)[3:]
            if 'Mass' in prefix_path:
                for region in optimizer.em_regions[tuple_path[-1]]:
                    folder.append(
                        os.path.join(os.path.join(*path), region)
                    )
                ##print os.path.join(os.path.join(*path), region)
        #print folder 
        self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  100, 0, 1000)
        self.book('os/', "e_m_Mass",  "h_vismass",  40, 0, 400)
                
        for f in folder:
            #print f
            self.book(f,"weight", "weight", 100, 0, 10)

            self.book(f,"mPt", "#mu p_{T}", 100, 0, 1000)             
            self.book(f,"mPhi", "#mu phi", 26, -3.25, 3.25)
            self.book(f,"mEta", "#mu eta",  10, -2.5, 2.5)
            
            self.book(f,"ePt", "e p_{T}", 100, 0, 1000)
            self.book(f,"ePhi", "e phi",  26, -3.2, 3.2)
            self.book(f,"eEta", "e eta", 10, -2.5, 2.5)
             
            self.book(f, "e_m_DPhi", "e-#mu DeltaPhi" , 20, 0, 3.2)
            self.book(f, "e_m_DR", "e-#mu DeltaR" , 40, 0, 5)
            
            self.book(f, "h_collmass_pfmet",  "h_collmass_pfmet",  100, 0, 1000)
            self.book(f, "e_m_Mass",  "h_vismass",  100, 0, 1000)
            
            self.book(f, "MetEt_vs_dPhi", "PFMet vs #Delta#phi(#mu,PFMet)", 20, 0, 3.2, 40, 0, 400, type=ROOT.TH2F)
            #self.book(f, "mPFMET_DeltaPhi", "#mu-type1PFMET DeltaPhi" , 20, 0, 3.2)
            self.book(f, "mDPhiToPfMet_type1", "#mu-type1PFMET DeltaPhi" , 20, 0, 3.2)
            self.book(f, "ePFMET_DeltaPhi", "e-PFMET DeltaPhi" , 20, 0, 3.2)
            
            self.book(f, "mMtToPfMet_type1", "#mu-PFMET M_{T}" , 40, 0, 400)
            self.book(f, "eMtToPfMet_type1", "e-PFMET M_{T}" , 40, 0, 400)
            self.book(f, "type1_pfMetEt",  "type1_pfMet_Et",  40, 0, 400)
            self.book(f, "type1_pfMetPhi",  "type1_pfMet_Phi", 26, -3.2, 3.2)
            self.book(f, "jetVeto20", "Number of jets, p_{T}>20", 5, -0.5, 4.5) 
            self.book(f, "jetVeto30", "Number of jets, p_{T}>30", 5, -0.5, 4.5)

            self.book(f, "e_m_PZeta", "e_m_PZeta", 100, -200, 200)
            self.book(f, "e_m_PZetaLess0p85PZetaVis", "e_m_PZetaLess0p85PZetaVis", 100, -200, 200)
            self.book(f, "e_m_PZetaVis", "e_m_PZetaVis", 100, 0, 100 )
           
            
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

        sys_shifts = ['']
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
            cut_flow_trk.Fill('allEvents')
            
            jets = min(int(row.jetVeto30), 2)
            if jets==2 : continue
            cut_flow_trk.Fill('jets')

            if not  self.is_HighMass:
                if not bool(row.singleMu8SingleE23DZPass) and not  bool(row.singleMu23SingleE12DZPass): continue
            cut_flow_trk.Fill('trigger')
            
            if not selections.eSelection(row, 'e'): continue
            cut_flow_trk.Fill('esel')
            if not selections.muSelection(row, 'm'): continue
            cut_flow_trk.Fill('msel')

            logging.debug('object selection passed')
            #e ID/ISO
            if not selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso05'): continue
            if not selections.lepton_id_iso(row, 'm', 'midMedium_idiso025'): continue
            logging.debug('Passed preselection')
            cut_flow_trk.Fill('eiso')
            weight_map = self.event_weight(row, sys_shifts)

            if not row.e_m_SS:
                self.fill_histos('os', row, weight_map[''])

            sys_directories = ['']+sys_shifts
            #remove duplicates
            sys_directories = list(set(sys_directories))
            
            isMuTight = bool(selections.lepton_id_iso(row, 'm', 'midMedium_idiso015'))
            isEVTight = bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso01'))
 
            passes_full_selection = False
            
            sign = 'os'
            if bool(row.e_m_SS)==True: sign='ss'
            
            if row.tauVetoPt20Loose3HitsVtx : continue
            if row.muVetoPt5IsoIdVtx : continue
            if row.eVetoMVAIsoVtx : continue
            cut_flow_trk.Fill('vetoes')
            logging.debug('Passed Vetoes')


            #starting to set up the optimizer
            #tau pt cut
            selection_categories = []
            massRanges = ['','LowMass', 'HighMass']
            jetDir = ['le1', '0', '1']
            
            for sys in sys_directories :
            
                selection_categories.extend([(sys, '', 'le1', '')])
                selection_categories.extend([(sys, '', str(jets), '')])

                
            if isMuTight and isEVTight:
                selection_categories.extend([(sys,'LowMass', 'le1', '')])
                selection_categories.extend([(sys,'LowMass',str(jets), '')])

                selection_categories.extend([
                    (sys,'LowMass','le1',i) for i in optimizer.compute_regions_em_le1(
                        row.eMtToPfMet_type1, row.e_m_DPhi, row.eDPhiToPfMet_type1, row.mDPhiToPfMet_type1)
                ])
                if jets == 0:
                    selection_categories.extend([
                        (sys,'LowMass','0',i) for i in optimizer.compute_regions_em_0jet(
                            row.eMtToPfMet_type1, row.e_m_DPhi, row.eDPhiToPfMet_type1, row.mDPhiToPfMet_type1)
                    ])
                if jets == 1:
                    selection_categories.extend([
                        (sys,'LowMass','1',i) for i in optimizer.compute_regions_em_1jet(
                            row.eMtToPfMet_type1, row.e_m_DPhi, row.eDPhiToPfMet_type1, row.mDPhiToPfMet_type1)
                    ])
 
                
           
            
            for selection in selection_categories:
                selection_sys, massRange, jet_dir,  selection_step = selection
                dirname =  os.path.join(selection_sys, sign, massRange, jet_dir, selection_step)

                if sign=='os': cut_flow_trk.Fill('sign')                
                if dirname[-1] == '/':
                    dirname = dirname[:-1]

                weight_to_use = weight_map[sys] if sys in weight_map else weight_map['eVTight']

                self.fill_histos(dirname, row, weight_to_use)
                
               
                
        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
