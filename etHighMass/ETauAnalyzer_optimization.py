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
import mcCorrections
from cutflowtracker import cut_flow_tracker
import bTagSF
cut_flow_step = ['allEvents', 'jets','trigger', 'esel', 'tsel', 'tdisc', 'eiso', 'vetoes','sign']
                 
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

pucorrector = mcCorrections.make_puCorrector('singlee', None)

class ETauAnalyzer(MegaBase):
    tree = 'et/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('ETauAnalyzer constructor')
        self.channel='ET'
        super(ETauAnalyzer, self).__init__(tree, outfile, **kwargs)
        self.tree = ETauTree(tree)
        self.out=outfile
        self.histograms = {}

        #understand what we are running
        target = os.path.basename(os.environ['megatarget'])
        self.is_data = target.startswith('data_')
        self.is_embedded = ('Embedded' in target)
        self.is_mc = not (self.is_data or self.is_embedded)
        self.is_DY = bool('JetsToLL_M-50' in target)
        self.is_DYLowMass = bool('JetsToLL_M-10to50' in target)
        self.isTT= bool('TT_TuneCUETP8M2T4_13TeV-powheg-pythia8_v6-v1' in target)
        self.is_W = bool('JetsToLNu' in target)
        self.is_HighMass = bool('ggM' in target)
        self.is_bkg = not (self.is_data or self.is_embedded or self.is_HighMass)

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
        self.eleid_weight = mcCorrections.electronID_Tight
        self.eleIso_weight = mcCorrections.electronIso_0p10_2016 
        self.eleidLoose_weight = mcCorrections.electronID_Tight
        self.eleIsoLoose_weight = mcCorrections.electronIso_0p15_2016
        self.eleRecoweight = mcCorrections.erecon_corrector
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
##        self.tauSF={#prompt2016
##            'vloose' : 0.83,
##            'loose'  : 0.84,
##            'medium' : 0.84,
##            'tight'  : 0.83,
##            'vtight' : 0.80
##        }

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
            if nbtagged>0 :
                return {'' : 0.,
                        'eVTight' : 0.}
            else:
                return {'' : 1.,
                        'eVTight' : 1.}
            
        mcweight = 1. 
        if not self.is_data : # applying directly the efficiency measured in data
            mcweight=self.triggerEff( row, 'e')
            #print 'trigger Eff', mcweight
            
        eisoweight = self.eleIso_weight(row,'e')
        eidweight =  self.eleid_weight(row.eEta,row.ePt)
        
        eisoloosew = self.eleIsoLoose_weight(row,'e')
        eidloosew = self.eleidLoose_weight(row.eEta,row.ePt)

        erecow = self.eleRecoweight(row.eEta,row.ePt)
            
        dyweight = self.DYreweight(row.genMass, row.genpT) 
        
        btagweight = 1. 
        if nbtagged>0:
            btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1hadronflavor,row.jb2pt,row.jb2hadronflavor,1,0,0)
        #print 'mcweight:',mcweight, 'pu:',  pucorrector(row.nTruePU), 'btag:', btagweight, 'eiso:', eisoloosew, 'eid:', eidweight, 'ereco:', erecow, 'tauSF:', self.tauSF['loose']
        mcweight =  mcweight*pucorrector(row.nTruePU)*btagweight*eisoloosew*eidweight*erecow*self.tauSF['loose']

        
        if self.is_DY:
            if row.numGenJets < 5:
                #print  row.evt, row.run, row.lumi, ', ePt:',row.ePt, ', tPt:',row.tPt, ', mcweight:', mcweight, ', dyweight:',dyweight, ', ZTTreweigth:',self.ZTTLweight[row.numGenJets], ', totweight:',  mcweight*dyweight*self.ZTTLweight[row.numGenJets]
                mcweight = mcweight*self.ZTTLweight[row.numGenJets]*dyweight
            else:
                #print  row.evt, row.run, row.lumi, ', ePt:',row.ePt, ', tPt:',row.tPt, ', mcweight:', mcweight, ', dyweight:',dyweight, ', ZTTreweigth:',self.ZTTLweight[0], ', totweight:',  mcweight*dyweight*self.ZTTLweight[0]
                mcweight = mcweight*self.ZTTLweight[0]*dyweight
            #if dyweight > 1.5 : 
                #print  row.evt, row.run, row.lumi, row.ePt, row.tPt,  mcweight, dyweight, mcweight/dyweight
        if self.is_DYLowMass:
            if row.numGenJets < 3:
                #print  row.evt, row.run, row.lumi, ', ePt:',row.ePt, ', tPt:',row.tPt, ', mcweight:', mcweight, ', dyweight:',dyweight, ', ZTTreweigth:',self.ZTTLowMassLweight[row.numGenJets], ', totweight:',  mcweight*dyweight*self.ZTTLowMassLweight[row.numGenJets]
                mcweight = mcweight*self.ZTTLowMassLweight[row.numGenJets]*dyweight
            else:
                #print  row.evt, row.run, row.lumi, ', ePt:',row.ePt, ', tPt:',row.tPt, ', mcweight:', mcweight, ', dyweight:',dyweight, ', ZTTreweigth:',self.ZTTLowMassLweight[0], ', totweight:',  mcweight*dyweight*self.ZTTLweight[0]
                mcweight = mcweight*self.ZTTLowMassLweight[0]*dyweight
                       
        if self.is_W:
            if row.numGenJets < 5:
                mcweight = mcweight*self.Wweight[row.numGenJets]
            else:
                mcweight = mcweight*self.Wweight[0]

        topptreweight=1

        if self.isTT:
            topptreweight=topPtreweight(row.topQuarkPt1,row.topQuarkPt2)

                
        mcweight_tight = mcweight*topptreweight*eisoweight/eisoloosew*self.tauSF['vtight']/self.tauSF['loose']

        weights = {'': mcweight,
                   'eVTight' : mcweight_tight
        } 
  
        return weights
    
    def begin(self):
        sys_shifts = ['','tLoose']
        sys_shifts = list( set( sys_shifts ) ) #remove double dirs
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
            prefix_path = os.path.join(*tuple_path)
            #print path, prefix_path
            # if 'Mass' in prefix_path:
            for region in optimizer.regions[tuple_path[-1]]:
                
                folder.append(
                    os.path.join(os.path.join(*path), region)
                )
        #print folder 
        self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  100, 0, 1000)
        self.book('os/', "e_t_Mass",  "h_vismass",  100, 0, 1000)
                
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
            
            self.book(f, "h_collmass_pfmet",  "h_collmass_pfmet",  100, 0, 1000)
            self.book(f, "e_t_Mass",  "h_vismass",  100, 0, 1000)
            
            self.book(f, "MetEt_vs_dPhi", "PFMet vs #Delta#phi(#tau,PFMet)", 20, 0, 3.2, 40, 0, 400, type=ROOT.TH2F)
            self.book(f, "tPFMET_DeltaPhi", "tau-type1PFMET DeltaPhi" , 20, 0, 3.2)
            self.book(f, "ePFMET_DeltaPhi", "e-PFMET DeltaPhi" , 20, 0, 3.2)
            
            self.book(f, "tMtToPfMet_type1", "Tau-PFMET M_{T}" , 100, 0, 500)
            self.book(f, "eMtToPfMet_type1", "e-PFMET M_{T}" , 100, 0, 500)
            self.book(f, "type1_pfMetEt",  "type1_pfMet_Et",  100, 0, 1000)
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

            if self.is_data:
                if not bool(row.singleE25eta2p1TightPass) : continue
            cut_flow_trk.Fill('trigger')
            
            if not selections.eSelection(row, 'e'): continue
            cut_flow_trk.Fill('esel')
            if not selections.tauSelection(row, 't'): continue
            cut_flow_trk.Fill('tsel')
           
            if not row.tAgainstElectronTightMVA6: continue
            if not row.tAgainstMuonLoose3 : continue
            if not row.tByVLooseIsolationMVArun2v1DBoldDMwLT : continue
            cut_flow_trk.Fill('tdisc')
            logging.debug('object selection passed')
            #e ID/ISO
            if not selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso025'): continue
            logging.debug('Passed preselection')
            cut_flow_trk.Fill('eiso')
            
            sys_directories = ['']+sys_shifts
            #remove duplicates
            sys_directories = list(set(sys_directories))
            
            isTauTight = bool(row.tByTightIsolationMVArun2v1DBoldDMwLT)
            isEVTight = bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso01'))

            if not isEVTight: continue
                        
            weight_map = self.event_weight(row, sys_shifts)
            if not row.e_t_SS: #Fill embedded sample normalization BEFORE the vetoes
                self.fill_histos('os', row, weight_map['eVTight'])

            etau_category = ['']                
            if not isTauTight :
                mc_weight = weight_map['eVTight']
                
                weight_map = self.fakerate_weights(row.tPt)
                for i in weight_map:
                    weight_map[i] *= mc_weight
                
                etau_category = ['tLoose']
                

            sys_directories = etau_category

            passes_full_selection = False
            
            sign = 'os'
            if bool(row.e_t_SS)==True: sign='ss'
            
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

            for sys in sys_directories :
                
                selection_categories.extend([(sys, '', 'le1', '')])
                selection_categories.extend([(sys, '', str(jets), '')])
                selection_categories.extend([
                    (sys,'','le1',i) for i in optimizer.compute_regions_le1(
                        row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                ])
                if jets == 0:
                    selection_categories.extend([
                        (sys,'','0',i) for i in optimizer.compute_regions_0jet(
                            row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                    ])
                if jets == 1:
                    selection_categories.extend([
                        (sys,'','1',i) for i in optimizer.compute_regions_1jet(
                            row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                    ])
                if row.ePt > 60 and row.tPt>30:
                    selection_categories.extend([(sys,'LowMass', 'le1', '')])
                    selection_categories.extend([(sys,'LowMass',str(jets), '')])
                    selection_categories.extend([
                        (sys,'LowMass','le1',i) for i in optimizer.compute_regions_le1(
                            row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                    ])
                    if jets == 0:
                        selection_categories.extend([
                            (sys,'LowMass','0',i) for i in optimizer.compute_regions_0jet(
                                row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                        ])
                    if jets == 1:
                        selection_categories.extend([
                            (sys,'LowMass','1',i) for i in optimizer.compute_regions_1jet(
                                row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                        ])
                    if row.ePt > 100 and row.tPt>45:
                        selection_categories.extend([(sys, 'HighMass', 'le1','')])
                        selection_categories.extend([(sys, 'HighMass', str(jets),'')])
                        selection_categories.extend([
                            (sys,'HighMass','le1',i) for i in optimizer.compute_regions_le1(
                                row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                        ])
                        if jets == 0:
                            selection_categories.extend([
                                (sys,'HighMass','0', i) for i in optimizer.compute_regions_0jet(
                                    row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                            ])
                        if jets == 1:
                            selection_categories.extend([
                                (sys,'HighMass','1', i) for i in optimizer.compute_regions_1jet(
                                    row.eMtToPfMet_type1, row.e_t_DPhi, row.eDPhiToPfMet_type1, row.tDPhiToPfMet_type1)
                            ])
                         
                

             
            for selection in selection_categories:
                
                selection_sys, massRange, jet_dir,  selection_step = selection
                #print selection_sys, massRange, jet_dir, selection_step
                dirname =  os.path.join(selection_sys, sign, massRange, jet_dir, selection_step)
                #print 'dirname', sys, selection, dirname
                if sign=='os': cut_flow_trk.Fill('sign')
                if dirname[-1] == '/':
                    dirname = dirname[:-1]
                
                weight_to_use = weight_map[sys] if selection_sys in weight_map else weight_map['eVTight']
                #print sys, weight_map, weight_to_use
                self.fill_histos(dirname, row, weight_to_use)

                
        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
