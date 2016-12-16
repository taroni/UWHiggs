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
import FinalStateAnalysis.PlotTools.pytree as pytree
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from math import sqrt, pi, cos
import itertools
import traceback
from FinalStateAnalysis.Utilities.struct import struct
from FinalStateAnalysis.PlotTools.decorators import memo
from FinalStateAnalysis.PlotTools.decorators import memo_last

import baseSelections as selections


class TriggerAnalyzerME(MegaBase):
    tree = 'em/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        logging.debug('TriggerAnalyzerME constructor')
        self.channel='EM'
        target = os.path.basename(os.environ['megatarget'])
        super(TriggerAnalyzerME, self).__init__(tree, outfile, **kwargs)
        self.tree = EMuTree(tree)
        self.out=outfile
        self.histograms = {}
        self.histo_locations = {}
        self.hfunc   = {}
                   
        
        ROOT.TH1.AddDirectory(True)
        
    def begin(self):

        folder=[]
        trigger=['', 'mu22', 'mu22er', 'mu24', 'mu24er', 'mu23ele12', 'mu23ele8']
        region =['']#,'Barrel', 'Endcap']
        sel = ['', 'musel', 'muesel']
        
        for tuple_path in itertools.product(trigger,region,sel):

            # print tuple_path
            folder.append(os.path.join(*tuple_path))
            path=list(tuple_path)
            
        for f in folder:
            self.book(f,"e_m_DR", "#DeltaR(e,#mu)", 20, 0, 2)
            self.book(f, "eIsoDB03", "eIsoDB03", 20, 0, 2)
            self.book(f, "mIsoDB03", "mIsoDB03", 20, 0, 2)
            
            self.book(f,"mPt", "m p_{T}", 30, 0, 150)             
            self.book(f,"ePt", "e p_{T}", 30, 0, 150)             
            self.book(f,"genpT", "H p_{T}", 30, 0, 150)             

        for key, value in self.histograms.iteritems():
            location = os.path.dirname(key)
            name     = os.path.basename(key)
            if location not in self.histo_locations:
                self.histo_locations[location] = {name : value}
            else:
                self.histo_locations[location][name] = value

            
    def fill_histos(self, folder_str, row, weight, filter_label = ''):
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
        return None


    def process(self):
        
        lock = ()
        
        for row in self.tree:

            evt_id = (row.run, row.lumi, row.evt)
            
            iso22=False
            iso22er=False
            iso24=False
            iso24er=False
            mu23ele12=False
            mu23ele8=False
            #print row.mGenMotherPdgId, row.eGenMotherPdgId
            if  row.mGenMotherPdgId!=25 or  row.eGenMotherPdgId!=25 : continue
            #if row.e_m_DR < 0.4 : continue
            
            
            if bool(row.singleIsoMu22Pass or row.singleIsoTkMu22Pass) :
                #if bool(row.mMatchesIsoMu22Path) or bool(row.mMatchesIsoTkMu22Path):
                iso22=True
            if bool(row.singleIsoMu22eta2p1Pass or row.singleIsoTkMu22eta2p1Pass) :
                #if bool(row.mMatchesIsoMu22eta2p1Path) or bool(row.mMatchesIsoTkMu22eta2p1Path):
                iso22er=True
            if bool(row.singleIsoMu24Pass or row.singleIsoTkMu24Pass) :
                #if bool(row.mMatchesIsoMu24Path) or bool(row.mMatchesIsoTkMu24Path):
                iso24=True
            #if bool(row.singleIsoMu24eta2p1Pass or row.singleIsoTkMu24eta2p1Pass) :
            #    if bool(row.mMatchesIsoMu24eta2p1Path) or bool(row.mMatchesIsoTkMu24eta2p1Path):
            #        iso24er=True

            if bool(row.singleMu23SingleE12Pass):
                #if bool(row.mMatchesMu19Tau20sL1Path) or bool(row.mMatchesMu19Tau20Path):
                mu23ele12=True
            if bool(row.singleMu23SingleE8Pass):
                #if bool(row.mMatchesMu19Tau20sL1Path) or bool(row.mMatchesMu19Tau20Path):
                mu23ele8=True

            muSel=False
            eSel=False
            
            ##chiedere che sia il muone con piu` alto pt (matching del trigger e` abbastanza?)
            if selections.muSelection(row, 'm'):
                #print '22', row.mPt, row.singleIsoMu22Pass, row.singleIsoTkMu22Pass , row.mMatchesIsoMu22Path, row.mMatchesIsoTkMu22Path
                #print '22er', row.mPt, row.singleIsoMu22eta2p1Pass, row.singleIsoTkMu22eta2p1Pass, row.mMatchesIsoMu22eta2p1Path, row.mMatchesIsoTkMu22eta2p1Path
                #print '24', row.mPt, row.singleIsoMu24Pass, row.singleIsoTkMu24Pass, row.mMatchesIsoMu24Path, row.mMatchesIsoTkMu24Path
                #print 'mutau',row.mPt, row.singleMu19eta2p1LooseTau20singleL1Pass,  row.singleMu19eta2p1LooseTau20Pass, row.mMatchesMu19Tau20sL1Path, row.mMatchesMu19Tau20Path 
                #if (row.mMatchesIsoMu22Path or mMatchesIsoMu22eta2p1Path or mMatchesIsoTkMu22Path or mMatchesIsoTkMu22eta2p1Path or
                if  selections.lepton_id_iso(row, 'm', 'MuIDTight_idiso1'):
                    muSel=True
               
            if selections.eSelection(row, 'e'):
                if selections.lepton_id_iso(row, 'e', 'eid16Loose_idiso1'): 
                    eSel=True


                                
            selection_categories = []
            folder = ''
            selection_categories.append(folder)
            if muSel:
                folder ='musel'
                selection_categories.append(folder)
            if muSel and eSel:
                folder='muesel'
                selection_categories.append(folder)

            if iso22:
                folder = 'mu22'
                selection_categories.append(folder)
                if muSel:
                    folder = 'mu22'+'/musel'
                    selection_categories.append(folder)
                if muSel and eSel:
                    folder='mu22'+'/muesel'
                    selection_categories.append(folder)
            if iso22er:
                folder = 'mu22er'
                selection_categories.append(folder)
                if muSel:
                    folder = 'mu22er'+'/musel'
                    selection_categories.append(folder)
                if muSel and eSel:
                    folder='mu22er'+'/muesel'
                    selection_categories.append(folder)
            if iso24:
                folder = 'mu24'
                selection_categories.append(folder)
                if muSel:
                    folder ='mu24'+'/musel'
                    selection_categories.append(folder)
                if muSel and eSel:
                    folder='mu24'+'/muesel'
                    selection_categories.append(folder)
            
            if iso24er:
                folder = 'mu24er'
                selection_categories.append(folder)
                if muSel:
                    folder = 'mu24er'+'/musel'
                    selection_categories.append(folder)
                if muSel and eSel:
                    folder='mu24er'+'/muesel'
                    selection_categories.append(folder)
            
            if mu23ele12:
                folder = 'mu23ele12'
                selection_categories.append(folder)
                if muSel:
                    folder = 'mu23ele12'+'/musel'
                    selection_categories.append(folder)
                if muSel and eSel:
                    folder='mu23ele12'+'/muesel'
                    selection_categories.append(folder)

            if mu23ele8:
                folder = 'mu23ele8'
                selection_categories.append(folder)
                if muSel:
                    folder = 'mu23ele8'+'/musel'
                    selection_categories.append(folder)
                if muSel and eSel:
                    folder='mu23ele8'+'/muesel'
                    selection_categories.append(folder)

                    
            if lock != () and evt_id == lock:
                continue
            
            lock = evt_id
                    
            for selection in selection_categories:
                dirname = selection
                if len(dirname)!=0 and dirname[-1] == '/':
                    dirname = dirname[:-1]
                weight_to_use=1.
                self.fill_histos(dirname, row, weight_to_use)

    def finish(self):
        self.write_histos()
