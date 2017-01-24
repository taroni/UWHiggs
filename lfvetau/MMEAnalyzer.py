from MMETree import MMETree
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
import mcCorrections
import FinalStateAnalysis.PlotTools.pytree as pytree
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from math import sqrt, pi, cos
import itertools
import traceback
from FinalStateAnalysis.Utilities.struct import struct
from FinalStateAnalysis.PlotTools.decorators import memo
from FinalStateAnalysis.PlotTools.decorators import memo_last
import bTagSF

from cutflowtracker import cut_flow_tracker
cut_flow_step = ['allEvents', 'msel', 'tsel', 'tdisc', 'miso', 'vetoes','sign']
                 
@memo
def getVar(name, var):
    return name+var
@memo
def split(string, separator='#'):
    return tuple(string.split(separator))
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

def ePtdiff (pt, oldpt):
    if oldpt!=-999:
        return pt-oldpt
    else:
        return -999.
def eIsodiff (iso, oldiso):
    if oldiso!=-999.:
        return iso-oldiso
    else:
        return -999.
    
pucorrector = mcCorrections.make_puCorrector('singlem', None)

        

class MMEAnalyzer(MegaBase):
    tree = 'emm/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('MMEAnalyzer constructor')
        self.channel='MME'
        target = os.path.basename(os.environ['megatarget'])
        self.is_data = target.startswith('data_')
        self.is_embedded = ('Embedded' in target)
        self.is_mc = not (self.is_data or self.is_embedded)
        self.is_DY = bool('JetsToLL_M-50' in target)
        self.is_W = bool('JetsToLNu' in target)
        
        super(MMEAnalyzer, self).__init__(tree, outfile, **kwargs)
        self.tree = MMETree(tree)
        self.out=outfile
        self.histograms = {}
        ROOT.TH1.AddDirectory(True)

        self.histo_locations = {}
        self.hfunc   = {
            #'ePtduplicate': lambda ePtdiff, weight: (, weight) if oldept!=-999. else (-999., weight),
            #'eIsoduplicate': lambda row, weight: (row.eIsoDB03-oldeiso, weight) if oldeiso!=-999. else (-999., weight)
            #'nTruePU' : lambda row, weight: (row.nTruePU,None),
            #'weight'  : lambda row, weight: (weight,None) if weight is not None else (1.,None),
            #'Event_ID': lambda row, weight: (array.array("f", [row.run,row.lumi,int(row.evt)/10**5,int(row.evt)%10**5] ), None),
        }
        self.trig_weight  = mcCorrections.efficiency_trigger_mu_2016 if not self.is_data else 1.
        self.mid_weight = mcCorrections.muonID_tight if not self.is_data else 1.
        self.mIso_weight = mcCorrections.muonIso_loose if not self.is_data else 1.
        self.mtrk_corrector= mcCorrections.muonTracking if not self.is_data else 1.
        self.eleid_weight = mcCorrections.electronID_WP80_2016
        self.eleIso_weight = mcCorrections.electronIso_0p10_2016 
        self.eleidLoose_weight = mcCorrections.electronID_WP90_2016
        self.eleIsoLoose_weight = mcCorrections.electronIso_0p15_2016 
        self.DYreweight = mcCorrections.DYreweight
 
        self.tauSF={
            'vloose' : 0.83,
            'loose'  : 0.84,
            'medium' : 0.84,
            'tight'  : 0.83,
            'vtight' : 0.80
            }
        
        self.ZTTLweight={ #Mll < 150 if ZTT or all Mll if ZLL
            0 : 0.063558578,
            1 : 0.014023359,
            2 : 0.015076197,
            3 : 0.01554784,
            4 : 0.012486114
            }
        self.Wweight={
            0 : 0.6194146,
            1 : 0.20038245,
            2 : 0.10613034,
            3 : 0.053607569,
            4 : 0.058531731
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

        mcweight = self.trig_weight(row.m1Pt, row.m1AbsEta)
        if row.m2Pt>row.m1Pt :  mcweight = self.trig_weight(row.m2Pt, row.m2AbsEta)
        #print 'computing iso weight', row.e1Pt, row.e1Eta, row.e2Pt, row.e2Eta
        m1isoweight = self.mIso_weight('Tight',row.m1Pt,row.m1AbsEta)
        m2isoweight = self.mIso_weight('Tight',row.m2Pt,row.m2AbsEta)
        m1idweight =  self.mid_weight(row.m1Pt,row.m1AbsEta)
        m2idweight =  self.mid_weight(row.m2Pt,row.m2AbsEta)
        m1Trkweight = self.mtrk_corrector(row.m1Eta)[0] #tracking correction factor is a tuple (value, error)
        m2Trkweight = self.mtrk_corrector(row.m2Eta)[0]

        eisoweight = self.eleIso_weight(row,'e')
        eidweight =  self.eleid_weight(row.eEta,row.ePt)

        eisoloosew = self.eleIsoLoose_weight(row,'e')
        eidloosew = self.eleidLoose_weight(row.eEta,row.ePt)

        dyweight = self.DYreweight(row.genMass, row.genpT) 

        #print 'tracking weight', m1Trkweight, m2Trkweight
        btagweight = 1. 
        if nbtagged>0:
            btagweight=bTagSF.bTagEventWeight(nbtagged,row.jb1pt,row.jb1hadronflavor,row.jb2pt,row.jb2hadronflavor,1,0,0)
        
        mcweight =  mcweight*pucorrector(row.nTruePU)*m1idweight*m2idweight*m1isoweight*m2isoweight*m1Trkweight*m2Trkweight*btagweight*eisoloosew


        #print 'DY weight', dyweight, mcweight, mcweight*dyweight
        if self.is_DY:
            #mcweight = mcweight*dyweight
            if row.numGenJets < 5:
                mcweight = mcweight*self.ZTTLweight[row.numGenJets]*dyweight
            else:
                mcweight = mcweight*self.ZTTLweight[0]*dyweight
            if dyweight > 1.5 : 
                print  row.evt, row.run, row.lumi, row.m1Pt, row.m2Pt, row.ePt, mcweight, dyweight, mcweight/dyweight
        if self.is_W:
            if row.numGenJets < 5:
                mcweight = mcweight*self.Wweight[row.numGenJets]
            else:
                mcweight = mcweight*self.Wweight[0]

        mcweight_tight = mcweight*eisoweight/eisoloosew
        
        weights = {'': mcweight,
                   'eVTight' : mcweight_tight
        } #put the weight here later (mc Correction, trigger eff)
        

        return weights
    
    def begin(self):
        sys_shifts = []
        signs =['os', 'ss']
        twp =[ 'isduplicate', 'eSSuperLoose','eSuperLoose','eVLoose', 'eLoose','eTight','eVTight']
        jetN = ['', '0', '1', '2', '3']
        tDM = ['', 'tDM0', 'tDM1', 'tDM10']
        region = ['','eB', 'eE']
        met = ['', 'Met30']
        folder=[]

        
        for tuple_path in itertools.product(signs, twp, region, met):
            folder.append(os.path.join(*tuple_path))
            path = list(tuple_path)
        
        #self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  32, 0, 320)
        #self.book('os/', "e1_e2_Mass",  "h_vismass",  32, 0, 320)
                
        for f in folder:
            #self.book(f,"weight", "weight", 100, 0, 10)

            self.book(f,"ePt", "e p_{T}", 40, 0, 200)             
            self.book(f,"ePhi", "e phi", 26, -3.25, 3.25)
            self.book(f,"eEta", "e eta",  50, -2.5, 2.5)
            self.book(f,"eAbsEta", "e abs(eta)",  25, 0, 2.5)
            self.book(f,"eEta_vs_ePt", "e #eta vs p_{T}", 40, 0, 200, 50, -2.5, 2.5, type=ROOT.TH2F)
            self.book(f,"eAbsEta_vs_ePt", "e |#eta| vs p_{T}", 40, 0, 200, 25, 0, 2.5, type=ROOT.TH2F)
            self.book(f,"eMtToPfMet_type1", "M_{T}(e, PFMET)" , 20, 0, 200)
            self.book(f,"eGenPdgId", "e gen pdgid", 100, -50, 50 )
            self.book(f,"eGenMotherPdgId", "e gen mother pdgid", 100, -50, 50 )

            self.book(f,"eRelIso", "e Relative Isolation", 100, 0., 2.)
            self.book(f,"eRelIso_vs_ePt", "e relIso vs Pt", 40, 0, 200., 25, 0., 1., type=ROOT.TH2F)
            self.book(f,"eIsoDB03", "e IsoDB03", 100, 0., 2.)
            self.book(f,"eIsoDB03_vs_ePt", "e IsoDB03 vs Pt", 40, 0, 200., 25, 0., 1., type=ROOT.TH2F)
            self.book(f,"eEcalIsoDR03", "eEcalIsoDR03", 200, 0, 200.)
            self.book(f,"eHcalIsoDR03", "eHcalIsoDR03", 200, 0, 200.)
            self.book(f,"eTrkIsoDR03", "eTrkIsoDR03", 200, 0, 200.)
            
            
            self.book(f,"m1Pt", "m1 p_{T}", 40, 0, 200)
            self.book(f,"m1Phi", "m1 phi",  26, -3.2, 3.2)
            self.book(f,"m1Eta", "m1 eta", 10, -2.5, 2.5)
            
            self.book(f,"m2Pt", "m2 p_{T}", 40, 0, 200)
            self.book(f,"m2Phi", "m2 phi",  26, -3.2, 3.2)
            self.book(f,"m2Eta", "m2 eta", 10, -2.5, 2.5)
             
            self.book(f, "m1_m2_Mass",  "h_m1m2mass",  40, 0, 400)
            
            self.book(f, "jetVeto20", "Number of jets, p_{T}>20", 5, -0.5, 4.5) 
            self.book(f, "jetVeto30", "Number of jets, p_{T}>30", 5, -0.5, 4.5)

            self.book(f, "nvtx", "Number of vertices", 50, 0, 50)
            self.book(f, "nTruePU", "true pileup", 60, 0, 60)
            
            self.book(f, "type1_pfMetEt", "type1 PFMET",  40, 0, 200)

            
            #index dirs and histograms
        for key, value in self.histograms.iteritems():
            location = os.path.dirname(key)
            name     = os.path.basename(key)
            if location not in self.histo_locations:
                self.histo_locations[location] = {name : value}
            else:
                self.histo_locations[location][name] = value
      
        self.book('', "CUT_FLOW", "Cut Flow", len(cut_flow_step), 0, len(cut_flow_step))
        for f in folder:
            self.book(f, "duplicatePt", "ept diff duplicate",  200, -100, 100)
            self.book(f, "duplicateIso", "eIso diff duplicate",  40, -1., 1.)
            self.book(f, "duplicateIso_vs_duplicatePt", "eIso diff vs ePt diff duplicate", 200, -100, 100, 40, -1., 1.,type=ROOT.TH2F)

        xaxis = self.histograms['CUT_FLOW'].GetXaxis()
        self.cut_flow_histo = self.histograms['CUT_FLOW']
        self.cut_flow_map   = {}
        for i, name in enumerate(cut_flow_step):
            xaxis.SetBinLabel(i+1, name)
            self.cut_flow_map[name] = i+0.5


    def fill_histos(self, folder_str, row, weight, oldept, oldeiso, filter_label = ''):
        '''fills histograms'''
        
        for attr, value in self.histo_locations[folder_str].iteritems():
            name = attr
            
            if filter_label:
                if not attr.startswith(filter_label+'$'):
                    continue
                attr = attr.replace(filter_label+'$', '')
            #print value, bool(value.InheritsFrom('ROOT.TH2F')), bool(value.InheritsFrom('TH2')), bool(value.InheritsFrom('TH2F'))
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
                    attr1, attr2 = split(attr, '_vs_')
                    v1 = getattr(row,attr1)
                    v2 = getattr(row,attr2)
                    value.Fill( v2, v1, weight ) if weight is not None else value.Fill( v2, v1 )
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
                    #print attr, weight
                    value.Fill( getattr(row,attr), weight ) if weight is not None else value.Fill( getattr(row,attr) )

        self.histograms[folder_str+'/duplicatePt'].Fill(ePtdiff(row.ePt, oldept), weight)
        self.histograms[folder_str+'/duplicateIso'].Fill(eIsodiff(row.eIsoDB03, oldeiso), weight)
        self.histograms[folder_str+'/duplicateIso_vs_duplicatePt'].Fill(ePtdiff(row.ePt, oldept),eIsodiff(row.eIsoDB03, oldeiso), weight)
                    
        return None

    def process(self):
        cut_flow_histo = self.cut_flow_histo
        cut_flow_trk   = cut_flow_tracker(cut_flow_histo)

        sys_shifts = []
        logging.debug('Starting processing')
        
        lock =()
        ievt = 0

        oldeiso=-999.
        oldept=-999.


        logging.debug('Starting evt loop')
        #print 'Starting evt loop'
        #print 'is data?', self.is_data
        for row in self.tree:
            
            #require the trigger on data. Efficiency for MC accounted in the weight
            if self.is_data:
                if not bool(row.singleIsoMu22Pass or row.singleIsoTkMu22Pass) :  continue 
            
            
            if (ievt % 100) == 0:
                logging.debug('New event')
               # print 'event number', ievt
            ievt += 1
            #avoid double counting events!
            
            evt_id = (row.run, row.lumi, row.evt)

            weight_map = self.event_weight(row, sys_shifts)
            if weight_map[''] == 0 : continue

            cut_flow_trk.new_row(row.run,row.lumi,row.evt)
            cut_flow_trk.Fill('allEvents')
            #print 'starting selections'
            ##print ievt, row.m1Eta, row.m2Eta
            if not selections.muSelection(row, 'm1'): continue
            #print 'm1selection'
            cut_flow_trk.Fill('m1sel')
            if not selections.muSelection(row, 'm2'): continue
            cut_flow_trk.Fill('m2sel')
            cut_flow_trk.Fill('msel')
            #print 'm2selection'
            if not selections.eSelection(row, 'e'): continue
            cut_flow_trk.Fill('tsel')
            #print 'tau selection'
            if abs(91.19 - row.m1_m2_Mass) > 20 : continue
            #print 'Z selection'
            
               
            cut_flow_trk.Fill('tdisc')
            logging.debug('object selection passed')
            #e ID/ISO
            if not selections.lepton_id_iso(row, 'm1', 'MuIDTight_idiso025'): continue
            logging.debug('Passed m1 selection')
            if not selections.lepton_id_iso(row, 'm2', 'MuIDTight_idiso025'): continue
            logging.debug('Passed m2 selection')
            #print 'Passed m2 selection'
            cut_flow_trk.Fill('miso')
 

            if row.tauVetoPt20Loose3HitsVtx : continue
            if row.muVetoPt5IsoIdVtx : continue
            if row.eVetoMVAIsoVtx : continue

            # if row.bjetCISVVeto30Medium!=0 : continue
            #print 'Passed vetoes'
            
            jets = min(row.jetVeto30,3)
            
            
            sign = 'ss' if row.m1_m2_SS else 'os'
            if not selections.lepton_id_iso(row, 'e', 'eid16Loose_idiso1'): continue
            isESuperLoose = selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso1')
            isEVLoose = selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso05')
            isELoose = selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso025')
            isETight = selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso015')
          
            isEVTight = bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso01'))
            
            passes_full_selection = False
            isduplicate=False
            metCut = 30.
            if evt_id != lock:
                oldmass = 0
                oldept =-999.
                oldeiso=-999.
            if lock != () and evt_id == lock:
                print 'duplicate event: %d %d %d. Zmass=%d, oldZmass=%d, m1Pt=%d, m2Pt=%d, ePt=%d, oldePt=%d, %s, %s, %s, %s, %s, %s' %(row.run, row.lumi, row.evt, row.m1_m2_Mass, oldmass, row.m1Pt, row.m2Pt, row.ePt, oldept, str(True), str(isESuperLoose), str(isEVLoose), str(isELoose), str(isETight), str(isEVTight) )
                logging.info('Removing duplicate of event: %d %d %d' % evt_id)
                isduplicate=True

            
            cut_flow_trk.Fill('vetoes')
            logging.debug('Passed Vetoes')
            selection_categories = []
            region = 'eB' if abs(row.eEta) <  1.4442 else 'eE'
            if isduplicate:
                folder=sign+'/isduplicate'
                selection_categories.append(folder)
            else:
                folder = sign+'/eSSuperLoose'
                selection_categories.append(folder)
                if row.type1_pfMetEt < metCut :
                    folder = sign+'/eSSuperLoose/Met30'
                    selection_categories.append(folder)
                    ##folder = sign + '/eSSuperLoose/' + str(int(jets))
                    ##selection_categories.append(folder)
                folder = sign + '/eSSuperLoose/' + region
                selection_categories.append(folder)
                if row.type1_pfMetEt < metCut :
                    folder = sign + '/eSSuperLoose/' + region + '/Met30'
                    selection_categories.append(folder)
            
                if isESuperLoose:
                    folder = sign+'/eSuperLoose'
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eSuperLoose/Met30'
                        selection_categories.append(folder)
                    ##folder = sign+ '/eSuperLoose/' + str(int(jets))
                    ##selection_categories.append(folder)
                    folder = sign+'/eSuperLoose/'+ region
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eSuperLoose/'+ region + '/Met30'
                        selection_categories.append(folder)
                   
                if isEVLoose :
                    folder = sign+'/eVLoose'
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eVLoose/Met30'
                        selection_categories.append(folder)
                    ##folder = sign+ '/eVLoose/' + str(int(jets))
                    ##selection_categories.append(folder)
                    folder = sign+'/eVLoose/' + region
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eVLoose/' + region + '/Met30'
                        selection_categories.append(folder)
                if isELoose :
                    folder = sign+'/eLoose'
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eLoose/Met30'
                        selection_categories.append(folder)
                    ##folder = sign+ '/eLoose/' + str(int(jets))
                    ##selection_categories.append(folder)
                    folder = sign+'/eLoose/' + region
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eLoose/' + region + '/Met30'
                        selection_categories.append(folder)
                if isETight :
                    folder = sign+'/eTight'
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eTight/Met30'
                        selection_categories.append(folder)
                    ##folder = sign+ '/eTight/' + str(int(jets))
                    ##selection_categories.append(folder)
                    folder = sign+'/eTight/' + region
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eTight/' + region + '/Met30'
                        selection_categories.append(folder)
    
                if isEVTight :
                    folder = sign+'/eVTight'
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eVTight/Met30'
                        selection_categories.append(folder)
                    ##folder = sign+ '/eVTight/' + str(int(jets))
                    ##selection_categories.append(folder)
                    folder = sign+'/eVTight/' + region
                    selection_categories.append(folder)
                    if row.type1_pfMetEt < metCut :
                        folder = sign+'/eVTight/' + region + '/Met30'
                        selection_categories.append(folder)
                
            for selection in selection_categories:
                lock = evt_id
                dirname = selection
                if sign=='os': cut_flow_trk.Fill('sign')
                
                if dirname[-1] == '/':
                    dirname = dirname[:-1]
                weight_to_use=weight_map['']
                if isEVTight : weight_to_use = weight_map['eVTight']
                #if row.isZtautau or row.isWtaunu or row.isGtautau: weight_to_use=weight_to_use*tSF
                self.fill_histos(dirname, row, weight_to_use, oldept, oldeiso)
                #print '-------------'

            lock = evt_id
            oldmass = row.m1_m2_Mass
            oldept = row.ePt
            oldeiso=row.eIsoDB03
            

        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
