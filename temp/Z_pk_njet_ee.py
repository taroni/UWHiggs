##Correction Factor still to add
from EETree import EETree
import os
import ROOT
import math
import optimizer
import glob
import array
#import mcCorrections
import baseSelections as selections
import FinalStateAnalysis.PlotTools.pytree as pytree
from FinalStateAnalysis.PlotTools.decorators import  memo_last
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from math import sqrt, pi, sin, cos, acos, sinh
from cutflowtracker import cut_flow_tracker
#Makes the cut flow histogram
cut_flow_step = ['allEvents', 'doubleMuPass', 'bjetveto', 'e1sel', 'e2sel', 'e3sel', 'Zbosmass','tauveto','muveto','eveto', 'mTightIso' ]
import FinalStateAnalysis.TagAndProbe.PileupWeight as PileupWeight
import FinalStateAnalysis.TagAndProbe.MuonPOGCorrections as MuonPOGCorrections
from inspect import currentframe

def get_linenumber():
    cf = currentframe()
    return cf.f_back.f_lineno

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
pu_corrector = PileupWeight.PileupWeight('25ns_matchData', *pu_distributions)
id_corrector  = MuonPOGCorrections.make_muon_pog_PFTight_2015CD()
iso_corrector = MuonPOGCorrections.make_muon_pog_TightIso_2015CD()
tr_corrector  = MuonPOGCorrections.make_muon_pog_IsoMu20oIsoTkMu20_2015()
        
class Z_pk_njet_ee(MegaBase):
    tree = 'ee/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        self.channel='EE'
        super(Z_pk_njet_ee, self).__init__(tree, outfile, **kwargs)
        self.tree = EETree(tree)
        self.out=outfile
        self.histograms = {}
       # self.pucorrector = mcCorrections.make_puCorrector('singlemu')
        self.mye1 = 'e1'
        self.mye2 = 'e2'
        #optimizer_keys   = [ i for i in optimizer.grid_search.keys() if i.startswith(self.channel) ]
        self.grid_search = {}


    def mc_corrector_2015(self, row):
        
        pu = pu_corrector(row.nTruePU)
        muidcorr1 = id_corrector(getattr(row, self.mye1+'Pt'), abs(getattr(row, self.mye1+'Eta')))
        muisocorr1 = iso_corrector('Tight', getattr(row, self.mye1+'Pt'), abs(getattr(row, self.mye1+'Eta')))
        muidcorr2 = id_corrector(getattr(row, self.mye2+'Pt'), abs(getattr(row, self.mye2+'Eta')))
        muisocorr2 = iso_corrector('Tight',getattr(row, self.mye2+'Pt'), abs(getattr(row, self.mye2+'Eta')))
        mutrcorr = tr_corrector(getattr(row, self.mye1+'Pt'), abs(getattr(row, self.mye1+'Eta'))) if getattr(row, self.mye1+'Pt')>getattr(row, self.mye2+'Pt') else  tr_corrector(getattr(row, self.mye2+'Pt'), abs(getattr(row, self.mye2+'Eta'))) #match the electron instead
        if pu*muidcorr1*muisocorr1*muidcorr2*muisocorr2*mutrcorr==0: print pu, muidcorr1, muisocorr1, muidcorr2, muisocorr2, mutrcorr
        return pu*muidcorr1*muisocorr1*muidcorr2*muisocorr2*mutrcorr

    

    def correction(self,row):
	return self.mc_corrector_2015(row)
        
    def event_weight(self, row):
 
        if row.run > 2: #FIXME! add tight ID correction
            return 1.
        if row.GenWeight*self.correction(row) == 0 : print 'weight==0', row.GenWeight*self.correction(row), row.GenWeight, self.correction(row), row.e1Pt, row.e2Pt, row.e1Eta, row.e2Eta
        return row.GenWeight*self.correction(row) 


        #return 1
        #if bool(row.e1MatchesEle27WP80) and  not bool(row.e2MatchesEle27WP80) : etrig = 'e1'
        """   #if not bool(row.e1MatchesEle27WP80) and  bool(row.e2MatchesEle27WP80) :  etrig = 'e2'
        return self.pucorrector(row.nTruePU) * \
            mcCorrections.eid_correction( row, self.mye1, self.mye2, self.mye3) * \
            mcCorrections.eiso_correction(row, self.mye1, self.mye2, self.mye3) * \
            mcCorrections.trig_correction(row, self.mye3   )
            """
    def ee3DR(self, row):
        mye1_mye3_dr = 100.
        mye2_mye3_dr = 100.
        try:        
            mye1_mye3_dr = getattr(row, self.mye1+'_'+self.mye3+'_DR')
        except AttributeError:
            mye1_mye3_dr =getattr(row, self.mye3+'_'+self.mye1+'_DR')
        try :
            mye2_mye3_dr = getattr(row, self.mye2+'_'+self.mye3+'_DR')
        except AttributeError:
            mye2_mye3_dr =getattr(row, self.mye3+'_'+self.mye2+'_DR')

        return mye1_mye3_dr  if mye1_mye3_dr  < mye2_mye3_dr else mye1_mye3_dr 

    def ee3DPhi(self, row):
        e1e3DPhi=deltaPhi(getattr(row, self.mye1+'Phi'), getattr(row, self.mye3+'Phi'))
        e2e3DPhi=deltaPhi(getattr(row, self.mye2+'Phi'), getattr(row, self.mye3+'Phi'))
        return e1mDPhi if e1e3DPhi < e2e3DPhi else e2e3DPhi


    def Zbos(self, row):
        e1p=ROOT.TVector3(getattr(row, self.mye1+'Pt')*cos(getattr(row, self.mye1+'Phi')),getattr(row, self.mye1+'Pt')*sin(getattr(row, self.mye1+'Phi')),getattr(row, self.mye1+'Pt')*sinh(getattr(row, self.mye1+'Eta')))
        e2p=ROOT.TVector3(getattr(row, self.mye2+'Pt')*cos(getattr(row, self.mye2+'Phi')),getattr(row, self.mye2+'Pt')*sin(getattr(row, self.mye2+'Phi')),getattr(row, self.mye2+'Pt')*sinh(getattr(row, self.mye2+'Eta')))
        e1FourVector= ROOT.TLorentzVector(e1p, sqrt(e1p.Mag2()+pow(getattr(row, self.mye1+'Mass'),2)))
        e2FourVector= ROOT.TLorentzVector(e2p, sqrt(e2p.Mag2()+pow(getattr(row, self.mye2+'Mass'),2)))
        zFourVector = e1FourVector+e2FourVector
        return zFourVector




##add the trigger correction 

    def begin(self):
        
        miso = ['mLoose', 'mTight']
        folder = []
        sign = ['ss','os']
        for iso in miso:
            for s in sign:
                folder.append(s+'/'+iso)
                j=0
                while j < 4 :
                    folder.append(s+'/'+iso+'/'+str(j))
                    j+=1
                    
        for f in folder: 
            

            self.book(f,"Njets", "Num_jets", 8, 0, 8)
            self.book(f, "ZMass",  " Inv Z Mass",  32, 0, 320)

        for s in sign:
            self.book(s+'/tNoCuts', "CUT_FLOW", "Cut Flow", len(cut_flow_step), 0, len(cut_flow_step))
            
            xaxis = self.histograms[s+'/tNoCuts/CUT_FLOW'].GetXaxis()
            self.cut_flow_histo = self.histograms[s+'/tNoCuts/CUT_FLOW']
            self.cut_flow_map   = {}
            for i, name in enumerate(cut_flow_step):
                xaxis.SetBinLabel(i+1, name)
                self.cut_flow_map[name] = i+0.5
                    
    def fill_histos(self, row, folder='os/tSuperLoose', fakeRate = False):
        weight = self.event_weight(row)
        histos = self.histograms
        if weight==0 : print "weight: ", weight

        histos[folder+'/Njets'].Fill( getattr(row,'jetVeto30'), weight)
        histos[folder+'/ZMass'].Fill(abs(getattr(row, self.mye1+'_'+self.mye2+'_'+'Mass')), weight)

    def process(self):
        
        cut_flow_histo = self.cut_flow_histo
        cut_flow_trk   = cut_flow_tracker(cut_flow_histo)
        myevent =()
        for row in self.tree:
            jn = row.jetVeto30
            if jn > 3 : jn = 3

            cut_flow_trk.Fill('allEvents')

            cut_flow_trk.new_row(row.run,row.lumi,row.evt)

            if not bool(row.singleIsoMu20Pass) and not bool(row.singleIsoTkMu20Pass) : continue
                
            cut_flow_trk.Fill('triggerselection')

            if row.bjetCISVVeto30Medium!=0 : continue 
          
            cut_flow_trk.Fill('bjetveto')
            #print row.e1JetPFCISVBtag, row.e1PixHits
            if not selections.muSelection(row, 'e1'): continue

            if not selections.lepton_id_iso(row, 'e1', 'muId_idiso025'): continue
            cut_flow_trk.Fill('e1sel')            
            
           
            if not selections.muSelection(row, 'e2'): continue
           
            if not selections.lepton_id_iso(row, 'e2', 'muId_idiso025'): continue
            cut_flow_trk.Fill('e2sel')

            if abs(row.e1_e2_Mass-91.2)>25:continue

            firstmuonfromZ=self.mye1+'MatchesSingleMu'        
            secondmuonfromZ=self.mye2+'MatchesSingleMu'        
            triggerpass=bool(bool(getattr(row, firstmuonfromZ)) or bool(getattr(row, secondmuonfromZ)))
           
#            if not triggerpass: continue
            cut_flow_trk.Fill('Zbosmass')

            if row.tauVetoPt20Loose3HitsNewDMVtx : continue 
            cut_flow_trk.Fill('tauveto')          
            if row.muVetoPt5IsoIdVtx : continue
            cut_flow_trk.Fill('muveto')          
            if row.eVetoMVAIso: continue
            cut_flow_trk.Fill('eveto')          
        



            eiso = 'eLoose'
            sign = 'ss' if getattr(row, self.mye1+'_'+ self.mye2+'_SS') else 'os'
            folder = sign+'/'+eiso
          
            self.fill_histos(row, folder)
            folder=folder+'/'+str(int(jn))
            self.fill_histos(row, folder)
#            print "PASSED"
             
        cut_flow_trk.flush()
                                
             
            
    def finish(self):
        self.write_histos()
