from ETauTree import ETauTree
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
from cutflowtracker import cut_flow_tracker
cut_flow_step = ['allEvents', 'esel', 'tsel', 'tdisc', 'eiso', 'vetoes','sign']
                 
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
    if  not 'es' in shift :
        return ty1met_phi %shift
    return met_phi % shift

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


class LFVHETauAnalyzer_13TeV(MegaBase):
    tree = 'et/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('LFVHETauAnalyzer_13TeV constructor')
        self.channel='ET'
        super(LFVHETauAnalyzer_13TeV, self).__init__(tree, outfile, **kwargs)
        self.tree = ETauTree(tree)
        self.out=outfile
        self.histograms = {}

        #understand what we are running
        target = os.path.basename(os.environ['megatarget'])
        self.is_data = target.startswith('data_')
        
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
                lambda row, weight: (deltaPhi(row.tPhi, getattr(row, metphi())), weight),
                attr_getter('type1_pfMetEt')
            ),
            'ePFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.ePhi, getattr(row, metphi())), weight),
            'tPFMET_DeltaPhi' : lambda row, weight: (deltaPhi(row.tPhi, getattr(row, metphi())), weight),
            'evtInfo' : lambda row, weight: (struct(run=row.run,lumi=row.lumi,evt=row.evt,weight=weight), None)
            }
        
    def event_weight(self, row, sys_shifts):
        if self.is_data:
            return {'' : 1.}
        
        weights = {'':1.} #put the weight here later (mc Correction, trigger eff)

        return weights
    
    def begin(self):
        sys_shifts = []
        signs =['os', 'ss']
        jetN = ['0', '1', '2', '3']
        folder=[]

        for tuple_path in itertools.product(signs, jetN):
            folder.append(os.path.join(*tuple_path))
            path = list(tuple_path)
            path.append('selected')
            folder.append(os.path.join(*path))
            prefix_path = os.path.join(*tuple_path)
            for region in optimizer.regions[tuple_path[-1]]:
                folder.append(
                    os.path.join(prefix_path, region)
                )
        #print folder 
        self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  32, 0, 320)
        self.book('os/', "e_t_Mass",  "h_vismass",  32, 0, 320)
                
        for f in folder:
            #print f
            self.book(f,"weight", "weight", 100, 0, 10)

            self.book(f,"tPt", "tau p_{T}", 40, 0, 200)             
            self.book(f,"tPhi", "tau phi", 26, -3.25, 3.25)
            self.book(f,"tEta", "tau eta",  10, -2.5, 2.5)
            
            self.book(f,"ePt", "e p_{T}", 40, 0, 200)
            self.book(f,"ePhi", "e phi",  26, -3.2, 3.2)
            self.book(f,"eEta", "e eta", 10, -2.5, 2.5)
             
            self.book(f, "e_t_DPhi", "e-tau DeltaPhi" , 20, 0, 3.2)
            self.book(f, "e_t_DR", "e-tau DeltaR" , 20, 0, 3.2)
            
            self.book(f, "h_collmass_pfmet",  "h_collmass_pfmet",  40, 0, 400)
            self.book(f, "h_collmass_vs_dPhi_pfmet",  "h_collmass_vs_dPhi_pfmet", 20, 0, 3.2, 40, 0, 400, type=ROOT.TH2F)
            self.book(f, "e_t_Mass",  "h_vismass",  40, 0, 400)
            
            self.book(f, "MetEt_vs_dPhi", "PFMet vs #Delta#phi(#tau,PFMet)", 20, 0, 3.2, 40, 0, 400, type=ROOT.TH2F)
            self.book(f, "tPFMET_DeltaPhi", "tau-type1PFMET DeltaPhi" , 20, 0, 3.2)
            self.book(f, "ePFMET_DeltaPhi", "e-PFMET DeltaPhi" , 20, 0, 3.2)
            
            self.book(f, "tMtToPfMet_type1", "Tau-PFMET M_{T}" , 40, 0, 200)
            self.book(f, "eMtToPfMet_type1", "e-PFMET M_{T}" , 40, 0, 200)
            self.book(f, "type1_pfMetEt",  "type1_pfMet_Et",  40, 0, 200)
            self.book(f, "type1_pfMetPhi",  "type1_pfMet_Phi", 26, -3.2, 3.2)
            self.book(f, "jetVeto20", "Number of jets, p_{T}>20", 5, -0.5, 4.5) 
            self.book(f, "jetVeto30", "Number of jets, p_{T}>30", 5, -0.5, 4.5)

            
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

        sys_shifts = []
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
            
            ##if self.is_data:
            ##    if not bool(row.singleE22eta2p1LoosePass) : continue

            if not selections.eSelection(row, 'e'): continue
            cut_flow_trk.Fill('esel')
            if not selections.tauSelection(row, 't'): continue
            cut_flow_trk.Fill('tsel')
           
            if not row.tAgainstElectronTightMVA6: continue
            if not row.tAgainstMuonLoose3 : continue
            if not row.tByLooseIsolationMVArun2v1DBoldDMwLT : continue
            cut_flow_trk.Fill('tdisc')
            logging.debug('object selection passed')
            #e ID/ISO
            if not selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso05'): continue
            logging.debug('Passed preselection')
            cut_flow_trk.Fill('eiso')
            weight_map = self.event_weight(row, sys_shifts)

            if not row.e_t_SS:
                self.fill_histos('os', row, weight_map[''])
            
            isTauTight = bool(row.tByTightIsolationMVArun2v1DBoldDMwLT)
            isETight = bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso01'))

            passes_full_selection = False

            sign = 'ss' if row.e_t_SS else 'os'
            jets = min(row.jetVeto30, 3)
            if row.tauVetoPt20Loose3HitsVtx : continue
            if row.muVetoPt5IsoIdVtx : continue
            if row.eVetoMVAIsoVtx : continue
            cut_flow_trk.Fill('vetoes')
            logging.debug('Passed Vetoes')


            #starting to set up the optimizer
            #tau pt cut
            selection_categories = []
            
            if jets == 0:
                selection_categories.extend([
                        ('0', i) for i in optimizer.compute_regions_0jet(
                            row.tPt, row.ePt, deltaPhi(row.ePhi, row.tPhi),
                            row.tMtToPfMet_type1)
                        ])
            if jets == 1:
                selection_categories.extend([
                        ('1', i) for i in optimizer.compute_regions_1jet(
                            row.tPt, row.ePt, 
                            row.tMtToPfMet_type1)
                        ])
            if jets == 2:
                selection_categories.extend([
                        ('2', i) for i in optimizer.compute_regions_2jet(
                            row.tPt, row.ePt,
                            row.tMtToPfMet_type1, row.vbfMass, row.vbfDeta)
                        ])
                

            
            for selection in selection_categories:
                jet_dir, selection_step = selection
                
                dirname = os.path.join( sign,str(int(jets)), selection_step)
                if sign=='os': cut_flow_trk.Fill('sign')
                
                if dirname[-1] == '/':
                    dirname = dirname[:-1]
                weight_to_use=1.
                self.fill_histos(dirname, row, weight_to_use)
        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
