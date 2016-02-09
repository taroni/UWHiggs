##Correction Factor still to add
from MMMTree import MMMTree
import os
import ROOT
import math
import optimizer
import glob
import array
import mcCorrections
import baseSelections as selections
import FinalStateAnalysis.PlotTools.pytree as pytree
from FinalStateAnalysis.PlotTools.decorators import  memo_last
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from math import sqrt, pi, sin, cos, acos, sinh
from cutflowtracker import cut_flow_tracker
#Makes the cut flow histogram
cut_flow_step = ['allEvents', 'doubleMuPass', 'bjetveto', 'm1sel', 'm2sel', 'm3sel', 'Zbosmass','tauveto','muveto','eveto', 'mTightIso' ]

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
    

class MuFakeRateAnalyzerMVA(MegaBase):
    tree = 'mmm/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        self.channel='MMM'
        super(MuFakeRateAnalyzerMVA, self).__init__(tree, outfile, **kwargs)
        self.tree = MMMTree(tree)
        self.out=outfile
        self.histograms = {}
       # self.pucorrector = mcCorrections.make_puCorrector('singlemu')
        self.mym1 = 'm1'
        self.mym2 = 'm2'
        self.mym3 = 'm3'
        #optimizer_keys   = [ i for i in optimizer.grid_search.keys() if i.startswith(self.channel) ]
        self.grid_search = {}
        #if len(optimizer_keys) > 1:
        #    for key in optimizer_keys:
        #        self.grid_search[key] = optimizer.grid_search[key]
        #else:
        #    self.grid_search[''] = optimizer.grid_search[optimizer_keys[0]]
 
    def event_weight(self, row):
        if row.run > 2: #FIXME! add tight ID correction
            return 1.
        return row.GenWeight*\
               mcCorrections.muiso15_correction(row,'m1','m2','m3')*\
               mcCorrections.muid15_tight_correction(row,'m1','m2','m3')*\
               mcCorrections.mutrig15_mva_combined(row,'m1','m2','m3')


        #return 1
        #if bool(row.e1MatchesEle27WP80) and  not bool(row.e2MatchesEle27WP80) : etrig = 'e1'
        """   #if not bool(row.e1MatchesEle27WP80) and  bool(row.e2MatchesEle27WP80) :  etrig = 'e2'
        return self.pucorrector(row.nTruePU) * \
            mcCorrections.eid_correction( row, self.mym1, self.mym2, self.mym3) * \
            mcCorrections.eiso_correction(row, self.mym1, self.mym2, self.mym3) * \
            mcCorrections.trig_correction(row, self.mym3   )
            """
    def mm3DR(self, row):
        mym1_mym3_dr = 100.
        mym2_mym3_dr = 100.
        try:        
            mym1_mym3_dr = getattr(row, self.mym1+'_'+self.mym3+'_DR')
        except AttributeError:
            mym1_mym3_dr =getattr(row, self.mym3+'_'+self.mym1+'_DR')
        try :
            mym2_mym3_dr = getattr(row, self.mym2+'_'+self.mym3+'_DR')
        except AttributeError:
            mym2_mym3_dr =getattr(row, self.mym3+'_'+self.mym2+'_DR')

        return mym1_mym3_dr  if mym1_mym3_dr  < mym2_mym3_dr else mym1_mym3_dr 

    def mm3DPhi(self, row):
        m1m3DPhi=deltaPhi(getattr(row, self.mym1+'Phi'), getattr(row, self.mym3+'Phi'))
        m2m3DPhi=deltaPhi(getattr(row, self.mym2+'Phi'), getattr(row, self.mym3+'Phi'))
        return m1mDPhi if m1m3DPhi < m2m3DPhi else m2m3DPhi


    def Zbos(self, row):
        m1p=ROOT.TVector3(getattr(row, self.mym1+'Pt')*cos(getattr(row, self.mym1+'Phi')),getattr(row, self.mym1+'Pt')*sin(getattr(row, self.mym1+'Phi')),getattr(row, self.mym1+'Pt')*sinh(getattr(row, self.mym1+'Eta')))
        m2p=ROOT.TVector3(getattr(row, self.mym2+'Pt')*cos(getattr(row, self.mym2+'Phi')),getattr(row, self.mym2+'Pt')*sin(getattr(row, self.mym2+'Phi')),getattr(row, self.mym2+'Pt')*sinh(getattr(row, self.mym2+'Eta')))
        m1FourVector= ROOT.TLorentzVector(m1p, sqrt(m1p.Mag2()+pow(getattr(row, self.mym1+'Mass'),2)))
        m2FourVector= ROOT.TLorentzVector(m2p, sqrt(m2p.Mag2()+pow(getattr(row, self.mym2+'Mass'),2)))
        zFourVector = m1FourVector+m2FourVector
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
            
            ##self.book(f,"e1Pt", "e1 p_{T}", 200, 0, 200)
            ##self.book(f,"e1Phi", "e1 phi",  100, -3.2, 3.2)
            ##self.book(f,"e1Eta", "e1 eta", 46, -2.3, 2.3)
            ##
            ##self.book(f,"e2Pt", "e2 p_{T}", 200, 0, 200)
            ##self.book(f,"e2Phi", "e2 phi",  100, -3.2, 3.2)
            ##self.book(f,"e2Eta", "e2 eta", 46, -2.3, 2.3)

            self.book(f,"mPt", "m p_{T}", 200, 0, 200)
            ##self.book(f,"mPhi", "m phi",  100, -3.2, 3.2)
            self.book(f,"mEta", "m eta", 46, -2.3, 2.3)
            self.book(f,"mAbsEta", "m abs eta", 23, 0, 2.3)
            self.book(f,"mPt_vs_mAbsEta", "m pt vs m abs eta", 23, 0, 2.3,  20, 0, 200.,  type=ROOT.TH2F)
            self.book(f, "ZMass",  " Inv Z Mass",  32, 0, 320)
            ##self.book(f, "e1e2Mass",  "e1e2 Inv Mass",  32, 0, 320)
            ##
            ##self.book(f, "e3MtToPFMET", "e3 Met MT", 100, 0, 100)
            ##
            ##
            ##self.book(f,"ee3DR", "e e3 DR", 50, 0, 10)
            ##self.book(f,"ee3DPhi", "e e3 DPhi", 32, 0, 3.2)
            ##
            ##self.book(f,"ze3DR", "Z e3 DR", 50, 0, 10)
            ##self.book(f,"ze3DPhi", "Z e3 DPhi", 32, 0, 3.2)
            ##self.book(f,"Zpt", "Z p_{T}", 200, 0, 200)
            ##
            ##
            ##
            ##self.book(f, "type1_pfMetEt", "type1_pfMetEt",200, 0, 200) 
            ##self.book(f, "jetN_30", "Number of jets, p_{T}>30", 10, -0.5, 9.5)
            ##self.book(f, "bjetCSVVeto30", "number of bjets", 10, -0.5, 9.5)

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
        print "weight: ", weight

        

        ##histos[folder+'/e1Pt'].Fill( getattr(row, self.mye1+'Pt'), weight)
        ##histos[folder+'/e1Eta'].Fill(getattr(row, self.mye1+'Eta'), weight)
        ##histos[folder+'/e1Phi'].Fill(getattr(row, self.mye1+'Phi'), weight) 
        ##
        ##histos[folder+'/e2Pt'].Fill( getattr(row, self.mye2+'Pt' ), weight)
        ##histos[folder+'/e2Eta'].Fill(getattr(row, self.mye2+'Eta'), weight)
        ##histos[folder+'/e2Phi'].Fill(getattr(row, self.mye2+'Phi'), weight)

        histos[folder+'/mPt'].Fill( getattr(row, self.mym3+'Pt' ), weight)
        histos[folder+'/mEta'].Fill(getattr(row, self.mym3+'Eta'), weight)
        ##histos[folder+'/mPhi'].Fill(getattr(row, self.mym3+'Phi'), weight)
        histos[folder+'/mAbsEta'].Fill(abs(getattr(row, self.mym3+'Eta')), weight)
        histos[folder+'/mPt_vs_mAbsEta'].Fill(abs(getattr(row, self.mym3+'Eta')), getattr(row, self.mym3+'Pt'), weight)
        histos[folder+'/ZMass'].Fill(abs(getattr(row, self.mym1+'_'+self.mym2+'_'+'Mass')), weight)
        ##histos[folder+'/e1e2Mass'].Fill(getattr(row, self.mye1+'_'+self.mye2+'_Mass'), weight)
        ###histos[folder+'/tMtToPFMET'].Fill(row.tMtToPFMET,weight)
        ##
        ## 
        ##histos[folder+'/type1_pfMetEt'].Fill(row.type1_pfMet_Et)
        ##histos[folder+'/ee3DR'].Fill(self.ee3DR(row)) 
        ##histos[folder+'/ee3DPhi'].Fill(self.ee3DPhi(row)) 
        ##histos[folder+'/jetN_30'].Fill(row.jetVeto30, weight) 
        ##histos[folder+'/bjetCSVVeto30'].Fill(row.bjetCSVVeto30, weight) 
        ##
        ##histos[folder+'/ze3DR'].Fill(deltaR(self.Z(row).Phi(), getattr(row, self.mye3+'Phi'), self.Z(row).Eta(), getattr(row, self.mye3+'Eta')))
        ##histos[folder+'/ze3DPhi'].Fill(deltaPhi(self.Z(row).Phi(), getattr(row, self.mye3+'Phi')))
        ##histos[folder+'/Zpt'].Fill(self.Z(row).Pt())
            

    def process(self):
        
        cut_flow_histo = self.cut_flow_histo
        cut_flow_trk   = cut_flow_tracker(cut_flow_histo)
        myevent =()
        for row in self.tree:
            jn = row.jetVeto30
            if jn > 3 : jn = 3

            cut_flow_trk.Fill('allEvents')

            cut_flow_trk.new_row(row.run,row.lumi,row.evt)

            if not bool(row.singleMuPass) : continue
                
            cut_flow_trk.Fill('DoubleMuPass')

            if row.bjetCISVVeto30Medium!=0 : continue 
          
            cut_flow_trk.Fill('bjetveto')
                      
            if not selections.muSelection(row, 'm1'): continue

            if not selections.lepton_id_iso(row, 'm1', 'muId_idiso025'): continue
            cut_flow_trk.Fill('m1sel')            
            
           
            if not selections.muSelection(row, 'm2'): continue
           
            if not selections.lepton_id_iso(row, 'm2', 'muId_idiso025'): continue
            cut_flow_trk.Fill('m2sel')
            

            if not selections.muSelection(row, 'm3'): continue
            if not selections.lepton_id_iso(row, 'm3', 'muId_idiso025'): continue #very loose loose eid13Tight_mvaLoose
            cut_flow_trk.Fill('m3sel')
            

            Zs= [(abs(row.m1_m2_Mass-91.2), ['m1', 'm2', 'm3']) , (abs(row.m2_m3_Mass-91.2), ['m2', 'm3', 'm1']), (abs(row.m1_m3_Mass-91.2), ['m1', 'm3', 'm2'])]
                
            for ele in range(0, 2) :
                
                if Zs[ele][0] == min(Zs[z][0] for z in range (0,2)) :
                    self.mym1 = Zs[ele][1][0]
                    self.mym2 = Zs[ele][1][1]
                    self.mym3 = Zs[ele][1][2]
                    
  
            firstmuonfromZ=self.mym1+'MatchesSingleMu'        
            secondmuonfromZ=self.mym2+'MatchesSingleMu'        
            triggerpass=bool(bool(getattr(row, firstmuonfromZ)) or bool(getattr(row, secondmuonfromZ)))
           
#            if not triggerpass: continue

            myZ=self.Zbos(row)
            Z_mass=myZ.M()
            if abs(Z_mass-91.2)>25: continue
            
            cut_flow_trk.Fill('Zbosmass')

            if row.tauVetoPt20Loose3HitsNewDMVtx : continue 
            cut_flow_trk.Fill('tauveto')          
            if row.muVetoPt5IsoIdVtx : continue
            cut_flow_trk.Fill('muveto')          
            if row.eVetoMVAIso: continue
            cut_flow_trk.Fill('eveto')          
        



            miso = 'mLoose'
            sign = 'ss' if row.m1_m2_SS else 'os'
            folder = sign+'/'+miso
          
            self.fill_histos(row, folder)
            folder=folder+'/'+str(int(jn))
            self.fill_histos(row, folder)
            print "PASSED"
            if selections.muTSelection(row, self.mym3):
                miso = 'mTight' 
                folder = sign+'/'+miso
                self.fill_histos(row,  folder)
                cut_flow_trk.Fill('mTightIso')
                folder=folder+'/'+str(int(jn))
                self.fill_histos(row, folder)
                print "PASSED TIGHT"
             
        cut_flow_trk.flush()
                                
             
            
    def finish(self):
        self.write_histos()
