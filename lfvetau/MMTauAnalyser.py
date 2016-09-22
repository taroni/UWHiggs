from MMTauTree import MMTauTree
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


from cutflowtracker import cut_flow_tracker
cut_flow_step = ['allEvents', 'msel', 'tsel', 'tdisc', 'miso', 'vetoes','sign']
                 
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

#def collmass(row, met, metPhi):
#    ptnu =abs(met*cos(deltaPhi(metPhi, row.tPhi)))
#    visfrac = row.tPt/(row.tPt+ptnu)
#    #print met, cos(deltaPhi(metPhi, row.tPhi)), ptnu, visfrac
#    return (row.e_t_Mass / sqrt(visfrac))

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

pucorrector = mcCorrections.make_puCorrector('singlem', None)

class MMTauAnalyser(MegaBase):
    tree = 'mmt/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('MMTauAnalyser constructor')
        self.channel='MMT'
        target = os.path.basename(os.environ['megatarget'])
        self.is_data = target.startswith('data_')
        self.is_embedded = ('Embedded' in target)
        self.is_mc = not (self.is_data or self.is_embedded)

        super(MMTauAnalyser, self).__init__(tree, outfile, **kwargs)
        self.tree = MMTauTree(tree)
        self.out=outfile
        self.histograms = {}
        ROOT.TH1.AddDirectory(True)
        
        self.histo_locations = {}
        self.hfunc   = {
            'nTruePU' : lambda row, weight: (row.nTruePU,None),
            'weight'  : lambda row, weight: (weight,None) if weight is not None else (1.,None),
            'Event_ID': lambda row, weight: (array.array("f", [row.run,row.lumi,int(row.evt)/10**5,int(row.evt)%10**5] ), None),
        }
        self.trig_weight  = mcCorrections.efficiency_trigger_mu_2016 if not self.is_data else 1.
        self.mid_weight = mcCorrections.muonID_tight if not self.is_data else 1.
        self.mIso_weight = mcCorrections.muonIso_loose if not self.is_data else 1.
        self.mtrk_corrector= mcCorrections.muonTracking if not self.is_data else 1. 

        self.tauSF={
            'vloose' : 0.83,
            'loose'  : 0.84,
            'medium' : 0.84,
            'tight'  : 0.83,
            'vtight' : 0.80
            }
    def event_weight(self, row, sys_shifts):
        if self.is_data:
            return {'' : 1.}

        mcweight = self.trig_weight(row.m1Pt, row.m1Eta)
        if row.m2Pt>row.m1Pt :  mcweight = self.trig_weight(row.m2Pt, row.m2Eta)
        #print 'computing iso weight', row.e1Pt, row.e1Eta, row.e2Pt, row.e2Eta
        m1isoweight = self.mIso_weight('Tight',row.m1Pt,row.m1Eta)
        m2isoweight = self.mIso_weight('Tight',row.m2Pt,row.m2Eta)
        m1idweight =  self.mid_weight(row.m1Pt,row.m1Eta)
        m2idweight =  self.mid_weight(row.m2Pt,row.m2Eta)
        m1Trkweight = self.mtrk_corrector(row.m1Eta)[0] #tracking correction factor is a tuple (value, error)
        m2Trkweight = self.mtrk_corrector(row.m2Eta)[0]
        #print 'tracking weight', m1Trkweight, m2Trkweight
        mcweight =  mcweight*pucorrector(row.nTruePU)*m1idweight*m2idweight*m1isoweight*m2isoweight*m1Trkweight*m2Trkweight
        weights = {'': mcweight
        } #put the weight here later (mc Correction, trigger eff)
        

        return weights
    
    def begin(self):
        sys_shifts = []
        signs =['os', 'ss']
        twp =['tVLoose', 'tLoose', 'tMedium', 'tTight', 'tVTight']
        jetN = ['', '0', '1', '2', '3']
        tDM = ['', 'tDM0', 'tDM1', 'tDM10']
        folder=[]

        
        for tuple_path in itertools.product(signs, twp, jetN, tDM):
            folder.append(os.path.join(*tuple_path))
            path = list(tuple_path)
        
        #self.book('os/', "h_collmass_pfmet" , "h_collmass_pfmet",  32, 0, 320)
        #self.book('os/', "e1_e2_Mass",  "h_vismass",  32, 0, 320)
                
        for f in folder:
            self.book(f,"weight", "weight", 100, 0, 10)

            self.book(f,"tPt", "tau p_{T}", 40, 0, 200)             
            self.book(f,"tPhi", "tau phi", 26, -3.25, 3.25)
            self.book(f,"tEta", "tau eta",  50, -2.5, 2.5)
            self.book(f,"tAbsEta", "tau abs(eta)",  25, 0, 2.5)
            self.book(f,"tDecayMode", "tau decay mode", 12, -0.5, 11.5) 
            
            self.book(f,"m1Pt", "m1 p_{T}", 40, 0, 200)
            self.book(f,"m1Phi", "m1 phi",  26, -3.2, 3.2)
            self.book(f,"m1Eta", "m1 eta", 10, -2.5, 2.5)
            
            self.book(f,"m2Pt", "m2 p_{T}", 40, 0, 200)
            self.book(f,"m2Phi", "m2 phi",  26, -3.2, 3.2)
            self.book(f,"m2Eta", "m2 eta", 10, -2.5, 2.5)
             
            self.book(f, "m1_m2_Mass",  "h_m1m2mass",  40, 0, 400)
            
            self.book(f, "jetVeto20", "Number of jets, p_{T}>20", 5, -0.5, 4.5) 
            self.book(f, "jetVeto30", "Number of jets, p_{T}>30", 5, -0.5, 4.5)

            
            #index dirs and histograms
        for key, value in self.histograms.iteritems():
            location = os.path.dirname(key)
            name     = os.path.basename(key)
            if location not in self.histo_locations:
                self.histo_locations[location] = {name : value}
            else:
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
        print 'Starting evt loop'
        print 'is data?', self.is_data
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
            if evt_id == lock: continue
            if lock != () and evt_id == lock:
                logging.info('Removing duplicate of event: %d %d %d' % evt_id)
            
            cut_flow_trk.new_row(row.run,row.lumi,row.evt)
            cut_flow_trk.Fill('allEvents')
            #print 'starting selections'
            if not selections.muSelection(row, 'm1'): continue
            #print 'm1selection'
            cut_flow_trk.Fill('m1sel')
            if not selections.muSelection(row, 'm2'): continue
            cut_flow_trk.Fill('m2sel')
            #print 'm2selection'
            if not selections.tauSelection(row, 't'): continue
            cut_flow_trk.Fill('tsel')
            #print 'tau selection'
            if abs(91.19 - row.m1_m2_Mass) > 20 : continue
            #print 'Z selection'
            
            if not row.tAgainstElectronLooseMVA6: continue
            if not row.tAgainstMuonTight3 : continue
            if not row.tByVLooseIsolationMVArun2v1DBoldDMwLT : continue
            print 'tauDiscriminants passed'
            
            cut_flow_trk.Fill('tdisc')
            logging.debug('object selection passed')
            #e ID/ISO
            if not selections.lepton_id_iso(row, 'm1', 'MuIDTight_idiso025'): continue
            logging.debug('Passed m1 selection')
            if not selections.lepton_id_iso(row, 'm2', 'MuIDTight_idiso025'): continue
            logging.debug('Passed m2 selection')
            print 'Passed m2 selection'
            cut_flow_trk.Fill('miso')
            weight_map = self.event_weight(row, sys_shifts)

            if row.tauVetoPt20Loose3HitsVtx : continue
            if row.muVetoPt5IsoIdVtx : continue
            if row.eVetoMVAIsoVtx : continue
            print 'Passed vetoes'
            jets = min(row.jetVeto30, 3)

            sign = 'ss' if row.m1_m2_SS else 'os'
                
            isTauLoose  = bool(row.tByLooseIsolationMVArun2v1DBoldDMwLT)
            isTauMedium = bool(row.tByMediumIsolationMVArun2v1DBoldDMwLT)
            isTauTight  = bool(row.tByTightIsolationMVArun2v1DBoldDMwLT)
            isTauVTight = bool(row.tByVTightIsolationMVArun2v1DBoldDMwLT)
            
            #            isETight = bool(selections.lepton_id_iso(row, 'e', 'eid16Tight_idiso01'))
            
            passes_full_selection = False

            
            
            cut_flow_trk.Fill('vetoes')
            logging.debug('Passed Vetoes')
            
            folder = sign+'/tVLoose'


                
            #starting to set up the optimizer
            #tau pt cut
            selection_categories = []
            selection_categories.append((self.tauSF['vloose'],folder))
            folder = sign+ '/tVLoose/tDM' + str(int(row.tDecayMode))
            selection_categories.append((self.tauSF['vloose'],folder))
            folder = sign + '/tVLoose/' + str(int(jets))
            selection_categories.append((self.tauSF['vloose'],folder))
            folder = sign+ '/tVLoose/' + str(int(jets)) + '/tDM' + str(int(row.tDecayMode))
            selection_categories.append((self.tauSF['vloose'],folder))

            if isTauLoose :
                folder = sign+'/tLoose'
                selection_categories.append((self.tauSF['loose'],folder))
                folder = sign+ '/tLoose/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['loose'],folder))
                folder = sign+ '/tLoose/' + str(int(jets))
                selection_categories.append((self.tauSF['loose'],folder))
                folder = sign+ '/tLoose/' + str(int(jets)) + '/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['loose'],folder))
            if isTauMedium :
                folder = sign+'/tMedium'
                selection_categories.append((self.tauSF['medium'],folder))
                folder = sign+ '/tMedium/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['medium'],folder))
                folder = sign+ '/tMedium/' + str(int(jets))
                selection_categories.append((self.tauSF['medium'],folder))
                folder = sign+ '/tMedium/' + str(int(jets)) + '/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['medium'],folder))
            if isTauTight :
                folder = sign+'/tTight'
                selection_categories.append((self.tauSF['tight'],folder))
                folder = sign+ '/tTight/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['tight'],folder))
                folder = sign+ '/tTight/' + str(int(jets))
                selection_categories.append((self.tauSF['tight'],folder))
                folder = sign+ '/tTight/' + str(int(jets)) + '/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['tight'],folder))
            if isTauVTight :
                folder = sign+'/tVTight'
                selection_categories.append((self.tauSF['vtight'],folder))
                folder = sign+ '/tVTight/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['vtight'],folder))
                folder = sign+ '/tVTight/' + str(int(jets))
                selection_categories.append((self.tauSF['vtight'],folder))
                folder = sign+ '/tVTight/' + str(int(jets)) + '/tDM' + str(int(row.tDecayMode))
                selection_categories.append((self.tauSF['vtight'],folder))
            
            for tSF,selection in selection_categories:
                lock = evt_id
                dirname = selection
                if sign=='os': cut_flow_trk.Fill('sign')
                
                if dirname[-1] == '/':
                    dirname = dirname[:-1]
                weight_to_use=weight_map['']
                if row.isZtautau or row.isWtaunu or row.isGtautau: weight_to_use=weight_to_use*tSF
                self.fill_histos(dirname, row, weight_to_use)
        cut_flow_trk.flush() 
            
    def finish(self):
        self.write_histos()
