# check in https://twiki.cern.ch/twiki/bin/view/CMS/HiggsToTauTauWorking2015#MET when the mva met receipe is available.
from EMTree import EMTree
import os
import ROOT
import math
import glob
import array
#import mcCorrections
import baseSelections as selections
import FinalStateAnalysis.PlotTools.pytree as pytree
from FinalStateAnalysis.PlotTools.decorators import  memo_last
from FinalStateAnalysis.PlotTools.MegaBase import MegaBase
from cutflowtracker import cut_flow_tracker
from math import sqrt, pi, cos
from fakerate_functions import fakerate_central_histogram, fakerate_p1s_histogram, fakerate_m1s_histogram
import FinalStateAnalysis.TagAndProbe.PileupWeight as PileupWeight
import FinalStateAnalysis.TagAndProbe.MuonPOGCorrections as MuonPOGCorrections
from inspect import currentframe



cut_flow_step=['allEvents','HLTIsoPasstrg','esel','eiso','musel','muiso','bjetveto','mtight','DR_e_mu','surplus_mu_veto','surplus_tau_veto','surplus_e_veto','jet0sel','jet1sel','jet2sel']

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




class LFVHETauMuAnalyzer(MegaBase):
    tree = 'em/final/Ntuple'
    def __init__(self, tree, outfile, **kwargs):
        self.channel='ETauMu'
        super(LFVHETauMuAnalyzer, self).__init__(tree, outfile, **kwargs)
        self.tree = EMTree(tree)
        self.out=outfile
        self.histograms = {}
        self.mym1 = 'm'
        self.mye1='e'
     
        """need to think about this"""
    @staticmethod 
    def tau_veto(row):
        if not row.tAntiMuonLoose2 or not row.tAntiElectronMVA3Tight or not row.tDecayFinding :
            return False

    @staticmethod
    def obj1_matches_gen(row):
        return row.eGenPdgId == -1*row.eCharge*11
    @staticmethod 
    def obj3_matches_gen(row):
        return t.genDecayMode != -2 


    def mc_corrector_2015(self, row):
        
        pu = pu_corrector(row.nTruePU)
        muidcorr = id_corrector(getattr(row, self.mym1+'Pt'), abs(getattr(row, self.mym1+'Eta')))
        muisocorr = iso_corrector('Tight', getattr(row, self.mym1+'Pt'), abs(getattr(row, self.mym1+'Eta')))
        mutrcorr = tr_corrector(getattr(row, self.mym1+'Pt'), abs(getattr(row, self.mym1+'Eta'))) 
       # if pu*muidcorr1*muisocorr1*muidcorr2*muisocorr2*mutrcorr==0: print pu, muidcorr1, muisocorr1, muidcorr2, muisocorr2, mutrcorr
        return pu*muidcorr*muisocorr*mutrcorr

    

    def correction(self,row):
	return self.mc_corrector_2015(row)
        
    def event_weight(self, row):
 
        if row.run > 2: #FIXME! add tight ID correction
            return 1.
       # if row.GenWeight*self.correction(row) == 0 : print 'weight==0', row.GenWeight*self.correction(row), row.GenWeight, self.correction(row), row.m1Pt, row.m2Pt, row.m1Eta, row.m2Eta
       # print row.GenWeight, "lkdfh"
        return row.GenWeight*self.correction(row) 

## 
    def begin(self):
        print "booking"

        processtype=['gg']
        threshold=[]
        sign=[ 'ss','os']
        jetN = [0, 1, 2, 3]
        folder=[]
#        pudir = ['','p1s/', 'm1s/','trp1s/', 'trm1s/', 'eidp1s/','eidm1s/',  'eisop1s/','eisom1s/', 'mLoose/','mLooseUp/','mLooseDown/', ]
        pudir=['','mLoose/']

        for d  in pudir :
            for i in sign:
                for j in processtype:
                    #for k in threshold:
                    for jn in jetN: 

                        folder.append(d+i+'/'+j +'/'+str(jn))
                        folder.append(d+i+'/'+j +'/'+str(jn)+'/selected')
                        
        for f in folder:
            self.book(f,"mPt", "mu p_{T}", 200, 0, 200)
            self.book(f,"mPhi", "mu phi", 100, -3.2, 3.2)
            self.book(f,"mEta", "mu eta",  50, -2.5, 2.5)
            
            self.book(f,"ePt", "e p_{T}", 200, 0, 200)
            self.book(f,"ePhi", "e phi",  100, -3.2, 3.2)
            self.book(f,"eEta", "e eta", 50, -2.5, 2.5)
            
            self.book(f, "em_DeltaPhi", "e-mu DeltaPhi" , 50, 0, 3.2)
            self.book(f, "em_DeltaR", "e-mu DeltaR" , 50, 0, 3.2)
            
            self.book(f, "h_collmass_pfmet",  "h_collmass_pfmet",  32, 0, 320)

#            self.book(f, "h_collmass_mvamet",  "h_collmass_mvamet",  32, 0, 320)
#
#            self.book(f, "h_collmass_pfmet_Ty1",  "h_collmass_pfmet_Ty1",  32, 0, 320)
#            self.book(f, "h_collmass_pfmet_jes", "h_collmass_pfmet_jes", 50, 0, 100)
#            self.book(f, "h_collmass_pfmet_mes", "h_collmass_pfmet_mes", 50, 0, 100 )
#            self.book(f, "h_collmass_pfmet_tes", "h_collmass_pfmet_tes", 50, 0, 100)
#           #self.book(f, "h_collmass_pfmet_ees", "h_collmass_pfmet_ees", 50, 0, 100)
#            self.book(f, "h_collmass_pfmet_ues", "h_collmass_pfmet_ues", 50, 0, 100)
#
#
#
#            self.book(f, "h_collmassSpread_pfmet",  "h_collmassSpread_pfmet",  40, -100, 100)
#            self.book(f, "h_collmassSpread_mvamet",  "h_collmassSpread_mvamet",  40, -100, 100)
#            self.book(f, "h_collmassSpread_lowPhi_pfmet",  "h_collmassSpread_lowPhi_pfmet",  40, -100, 100)
#            self.book(f, "h_collmassSpread_lowPhi_mvamet",  "h_collmassSpread_lowPhi_mvamet", 40, -100, 100)
#            self.book(f, "h_collmassSpread_highPhi_pfmet",  "h_collmassSpread_highPhi_pfmet", 40, -100, 100)
#            self.book(f, "h_collmassSpread_highPhi_mvamet",  "h_collmassSpread_highPhi_mvamet", 40, -100, 100)
#            self.book(f, "h_collmass_lowPhi_pfmet",  "h_collmass_lowPhi_pfmet",  32, 0, 320)
#            self.book(f, "h_collmass_lowPhi_mvamet",  "h_collmass_lowPhi_mvamet",  32, 0, 320)
#            self.book(f, "h_collmass_highPhi_pfmet",  "h_collmass_highPhi_pfmet",  32, 0, 320)
#            self.book(f, "h_collmass_highPhi_mvamet", "h_collmass_highPhi_mvamet",  32, 0, 320)
#            self.book(f, "h_collmass_vs_dPhi_pfmet",  "h_collmass_vs_dPhi_pfmet", 50, 0, 3.2, 32, 0, 320, type=ROOT.TH2F)
#            self.book(f, "h_collmass_vs_dPhi_mvamet",  "h_collmass_vs_dPhi_mvamet", 50, 0, 3.2, 32, 0, 320, type=ROOT.TH2F)
#            self.book(f, "h_collmassSpread_vs_dPhi_pfmet",  "h_collmassSpread_vs_dPhi_pfmet", 50, 0, 3.2, 20, -100, 100, type=ROOT.TH2F)
#            self.book(f, "h_collmassSpread_vs_dPhi_mvamet",  "h_collmassSpread_vs_dPhi_mvamet", 50, 0, 3.2, 20, -100, 100, type=ROOT.TH2F)
#            
            self.book(f, "h_vismass",  "h_vismass",  32, 0, 320)
#            
#            self.book(f, "type1_pfMetEt_vs_dPhi", "PFMet vs #Delta#phi(#tau,PFMet)", 50, 0, 3.2, 64, 0, 320, type=ROOT.TH2F)
#            self.book(f, "mvaMetEt_vs_dPhi", "MVAMet vs #Delta#phi(#tau,MVAMet)", 50, 0, 3.2, 64, 0, 320, type=ROOT.TH2F)
#
#            self.book(f, "mPFMET_DeltaPhi", "mu-PFMET DeltaPhi" , 50, 0, 3.2)
#            self.book(f, "mPFMET_Mt", "mu-PFMET M_{T}" , 200, 0, 200)
#            self.book(f, "mPFMET_DeltaPhi_Ty1", "mu-type1PFMET DeltaPhi" , 50, 0, 3.2)
#            self.book(f, "mPFMET_Mt_Ty1", "mu-type1PFMET M_{T}" , 200, 0, 200)
#            self.book(f, 'mPFMET_Mt_jes', "mu-MVAMET M_{T} JES" , 200, 0, 200)
#            self.book(f, 'mPFMET_Mt_mes', "mu-MVAMET M_{T} JES" , 200, 0, 200)
#            #self.book(f, 'mPFMET_Mt_ees', "mu-MVAMET M_{T} JES" , 200, 0, 200)
#            self.book(f, 'mPFMET_Mt_tes', "mu-MVAMET M_{T} JES" , 200, 0, 200)
#            self.book(f, 'mPFMET_Mt_ues', "mu-MVAMET M_{T} JES" , 200, 0, 200)
#            
#            self.book(f, "mMVAMET_DeltaPhi", "mu-MVAMET DeltaPhi" , 50, 0, 3.2)
#            self.book(f, "mMVAMET_Mt", "mu-MVAMET M_{T}" , 200, 0, 200)
#               
#            self.book(f, "ePFMET_DeltaPhi_Ty1", "e-type1PFMET DeltaPhi" , 50, 0, 3.2)
#            self.book(f, "ePFMET_Mt_Ty1", "e-type1PFMET M_{T}" , 200, 0, 200)
#            self.book(f, "ePFMET_DeltaPhi", "e-PFMET DeltaPhi" , 50, 0, 3.2)
#            self.book(f, "ePFMET_Mt", "e-PFMET M_{T}" , 200, 0, 200)
#            self.book(f, 'ePFMET_Mt_jes', "e-MVAMET M_{T} JES" , 200, 0, 200)
#            self.book(f, 'ePFMET_Mt_mes', "e-MVAMET M_{T} JES" , 200, 0, 200)
#            #self.book(f, 'ePFMET_Mt_ees', "e-MVAMET M_{T} JES" , 200, 0, 200)
#            self.book(f, 'ePFMET_Mt_tes', "e-MVAMET M_{T} JES" , 200, 0, 200)
#            self.book(f, 'ePFMET_Mt_ues', "e-MVAMET M_{T} JES" , 200, 0, 200)
#
#            self.book(f, "eMVAMET_DeltaPhi", "e-MVAMET DeltaPhi" , 50, 0, 3.2)
#            self.book(f, "eMVAMET_Mt", "e-MVAMET M_{T}" , 200, 0, 200)
#            
            self.book(f, "jetN_20", "Number of jets, p_{T}>20", 10, -0.5, 9.5) 
            self.book(f, "jetN_30", "Number of jets, p_{T}>30", 10, -0.5, 9.5) 

        
        
        for s in sign:
            
            self.book(s+'/tNoCuts', "CUT_FLOW", "Cut Flow", len(cut_flow_step), 0, len(cut_flow_step))
            
            xaxis = self.histograms[s+'/tNoCuts/CUT_FLOW'].GetXaxis()
            self.cut_flow_histo = self.histograms[s+'/tNoCuts/CUT_FLOW']
            self.cut_flow_map   = {}
            for i, name in enumerate(cut_flow_step):
                xaxis.SetBinLabel(i+1, name)
                self.cut_flow_map[name] = i+0.5

            


    def fakerate_weights(self, tEta, central_weights, p1s_weights, m1s_weights):
        frweight=[1.,1.,1.]

        #central_weights = fakerate_central_histogram(25,0, 2.5)
        #p1s_weights = fakerate_central_histogram(25,0, 2.5)
        #m1s_weights = fakerate_central_histogram(25,0, 2.5)

        for n,w in enumerate( central_weights ):
            if abs(tEta) < w[1]:
                break
            ##frweight[0] = w[0]
            ##frweight[1] = p1s_weights[n][0]
            ##frweight[2] = m1s_weights[n][0]
            freight[0] = 1.
            freight[1] = 1.
            freight[2] = 1.
            
        
        return  frweight;

    
                    
    def fill_histos(self, row, f='os/gg/ept0/0',  isElecTight=False, frw=[1.,1.,1.]):
        weight = [self.event_weight(row)]
        histos = self.histograms
        pudir =['']
#        print "re re ma"
#        if row.run < 2: pudir.extend( ['p1s/', 'm1s/', 'trp1s/', 'trm1s/', 'eidp1s/','eidm1s/',  'eisop1s/','eisom1s/'])
#        looseList = ['mLoose/', 'mLooseUp/', 'mLooseDown/']
        
        looseList=['mLoose/']
        #print isElecTight

        if not isElecTight:
            frweight_bv = 1.
            ####frweight_bv = frw[0]/(1.-frw[0])
            err = frweight_bv*0.05
            ####err = abs(frw[0] - frw[1])* abs(frw[0]/((1-frw[0])*(1-frw[0])) + 1/(1-frw[0]))
            frweight_p1s = frweight_bv*(1+err)
            frweight_m1s = frweight_bv*(1-err)
        
            fr_weights = [frweight_bv, frweight_p1s, frweight_m1s]
        
            for n, l in enumerate(looseList) :
                frweight = weight[0]*fr_weights[n]
                folder = l+f
 #               print folder
                #print folder , frweight, fr_weights[n], frw[0]
                histos[folder+'/mPt'].Fill(row.mPt, frweight)
                histos[folder+'/mEta'].Fill(row.mEta, frweight)
                histos[folder+'/mPhi'].Fill(row.mPhi, frweight) 
                histos[folder+'/ePt'].Fill(row.ePt, frweight)
                histos[folder+'/eEta'].Fill(row.eEta, frweight)
                histos[folder+'/ePhi'].Fill(row.ePhi, frweight)
                histos[folder+'/em_DeltaPhi'].Fill(deltaPhi(row.ePhi, row.mPhi), frweight)
                histos[folder+'/em_DeltaR'].Fill(row.e_m_DR, frweight)
#
#                histos[folder+'/h_collmass_vs_dPhi_pfmet'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi), frweight)
#                #histos[folder+'/h_collmass_vs_dPhi_mvamet'].Fill(deltaPhi(row.tPhi, row.mva_metPhi), collmass(row, row.mva_metEt, row.mva_metPhi), frweight)
#                histos[folder+'/h_collmassSpread_vs_dPhi_pfmet'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, frweight)
#                #histos[folder+'/h_collmassSpread_vs_dPhi_mvamet'].Fill(deltaPhi(row.tPhi, row.mva_metPhi), collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, frweight)
#                if deltaPhi(row.mPhi, row.raw_pfMetPhi) > 1.57 :  
#                    histos[folder+'/h_collmass_highPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi), frweight)
#                    histos[folder+'/h_collmassSpread_highPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, frweight)
#                if deltaPhi(row.mPhi, row.raw_pfMetPhi) < 1.57 :  
#                    histos[folder+'/h_collmass_lowPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi), frweight)
#                    histos[folder+'/h_collmassSpread_lowPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, frweight)
#                #if deltaPhi(row.tPhi, row.mva_metPhi) > 1.57 :  
#                    #histos[folder+'/h_collmass_highPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi), frweight)
#                    #histos[folder+'/h_collmassSpread_highPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, frweight)
#                #if deltaPhi(row.tPhi, row.mva_metPhi) < 1.57 :  
#                    #histos[folder+'/h_collmass_lowPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi), frweight)
#                    #histos[folder+'/h_collmassSpread_lowPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, frweight)
#                histos[folder+'/h_collmassSpread_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, frweight)                
#                #histos[folder+'/h_collmassSpread_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, frweight)
#                
#                ##********
                histos[folder+'/h_collmass_pfmet'].Fill(collmass(row, row.raw_pfMetEt, row.raw_pfMetPhi), frweight)
                ##********

                #histos[folder+'/h_collmass_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi), frweight)
#                histos[folder+'/h_collmass_pfmet_Ty1'].Fill(collmass(row, row.type1_pfMetEt, row.raw_pfMetPhi), frweight)
#                histos[folder+'/h_collmass_pfmet_jes'].Fill(collmass(row, row.pfMet_jes_Et, row.pfMet_jes_Phi), frweight)
 #               histos[folder+'/h_collmass_pfmet_mes'].Fill(collmass(row, row.pfMet_mes_Et, row.pfMet_mes_Phi), frweight)
  #              histos[folder+'/h_collmass_pfmet_tes'].Fill(collmass(row, row.pfMet_tes_Et, row.pfMet_tes_Phi), frweight)
                #histos[folder+'/h_collmass_pfmet_ees'].Fill(collmass(row, row.pfMet_ees_Et, row.pfMet_ees_Phi), frweight)
   #             histos[folder+'/h_collmass_pfmet_ues'].Fill(collmass(row, row.pfMet_ues_Et, row.pfMet_ues_Phi), frweight)

                ##********
                histos[folder+'/h_vismass'].Fill(row.e_m_Mass, frweight)
                ##********

#               histos[folder+'/type1_pfMetEt_vs_dPhi'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), row.type1_pfMetEt, frweight)
#               #histos[folder+'/mvaMetEt_vs_dPhi'].Fill(deltaPhi(row.tPhi, row.mva_metPhi), row.mva_metEt, frweight)
#
#               histos[folder+'/ePFMET_DeltaPhi'].Fill(deltaPhi(row.ePhi, row.raw_pfMetPhi), frweight)
#               histos[folder+'/ePFMET_DeltaPhi_Ty1'].Fill(deltaPhi(row.ePhi, row.type1_pfMetPhi), frweight)
#               #histos[folder+'/eMVAMET_DeltaPhi'].Fill(deltaPhi(row.ePhi, row.mva_metPhi), frweight)
#               histos[folder+'/ePFMET_Mt'].Fill(row.eMtToPfMet_Raw, frweight)
#                histos[folder+'/ePFMET_Mt_Ty1'].Fill(row.eMtToPfMet_Raw_Ty1, frweight)
#                histos[folder+'/ePFMET_Mt_jes'].Fill(row.eMtToPfMet_Raw_jes, frweight)
##               histos[folder+'/ePFMET_Mt_mes'].Fill(row.eMtToPfMet_Raw_mes, frweight)
#               ##histos[folder+'/ePFMET_Mt_ees'].Fill(row.eMtToPfMet_Raw_ees, frweight)
# #              histos[folder+'/ePFMET_Mt_tes'].Fill(row.eMtToPfMet_Raw_tes, frweight)
#  #             histos[folder+'/ePFMET_Mt_ues'].Fill(row.eMtToPfMet_Raw_ues, frweight)
#               #histos[folder+'/eMVAMET_Mt'].Fill(row.eMtToMVAMET, frweight)
#               histos[folder+'/mPFMET_DeltaPhi'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), frweight)
#                histos[folder+'/mPFMET_DeltaPhi'].Fill(deltaPhi(row.mPhi, row.pfMemPhi), frweight)
##               histos[folder+'/mPFMET_DeltaPhi_Ty1'].Fill(deltaPhi(row.mPhi, row.type1_pfMemPhi), frweight)
#               #histos[folder+'/tMVAMET_DeltaPhi'].Fill(deltaPhi(row.mPhi, row.mva_memPhi), frweight)
#               histos[folder+'/mPFMET_Mt'].Fill(row.mMtToPfMet_Raw, frweight)
#               #histos[folder+'/mMVAMET_Mt'].Fill(row.mMtToMVAMET, frweight)
#                histos[folder+'/mPFMET_Mt_jes'].Fill(row.mMtToPfMet_Raw_jes, frweight)
##               histos[folder+'/mPFMET_Mt_mes'].Fill(row.mMtToPfMet_Raw_mes, frweight)
# #              #histos[folder+'/mPFMET_Mt_ees'].Fill(row.mMtToPfMet_Raw_ees, frweight)
#  #             histos[folder+'/mPFMET_Mt_tes'].Fill(row.mMtToPfMet_Raw_tes, frweight)
#   #            histos[folder+'/mPFMET_Mt_ues'].Fill(row.mMtToPfMet_Raw_ues, frweight)
#
                histos[folder+'/jetN_20'].Fill(row.jetVeto20, frweight) 
                histos[folder+'/jetN_30'].Fill(row.jetVeto30, frweight) 

        else:
            for n,d  in enumerate(pudir) :
#                print "chupakabra"
                folder = d+f
                histos[folder+'/mPt'].Fill(row.mPt, weight[n])
                histos[folder+'/mEta'].Fill(row.mEta, weight[n])
                histos[folder+'/mPhi'].Fill(row.mPhi, weight[n]) 
                histos[folder+'/ePt'].Fill(row.ePt, weight[n])
                histos[folder+'/eEta'].Fill(row.eEta, weight[n])
                histos[folder+'/ePhi'].Fill(row.ePhi, weight[n])
                histos[folder+'/em_DeltaPhi'].Fill(deltaPhi(row.ePhi, row.mPhi), weight[n])
                histos[folder+'/em_DeltaR'].Fill(row.e_m_DR, weight[n])
#                histos[folder+'/h_collmass_vs_dPhi_pfmet'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi), weight[n])
#                #histos[folder+'/h_collmass_vs_dPhi_mvamet'].Fill(deltaPhi(row.tPhi, row.mva_metPhi), collmass(row, row.mva_metEt, row.mva_metPhi), weight[n])
#                histos[folder+'/h_collmassSpread_vs_dPhi_pfmet'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, weight[n])
#                #histos[folder+'/h_collmassSpread_vs_dPhi_mvamet'].Fill(deltaPhi(row.tPhi, row.mva_metPhi), collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, weight[n])
#                if deltaPhi(row.mPhi, row.raw_pfMetPhi) > 1.57 :  
#                    histos[folder+'/h_collmass_highPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi), weight[n])
#                    histos[folder+'/h_collmassSpread_highPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, weight[n])
#                if deltaPhi(row.mPhi, row.raw_pfMetPhi) < 1.57 :  
#                    histos[folder+'/h_collmass_lowPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi), weight[n])
#                    histos[folder+'/h_collmassSpread_lowPhi_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, weight[n])
#                #if deltaPhi(row.tPhi, row.mva_metPhi) > 1.57 :  
#     #histos[folder+'/h_collmass_highPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi), weight[n])
#                    #histos[folder+'/h_collmassSpread_highPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, weight[n])
#                #if deltaPhi(row.tPhi, row.mva_metPhi) < 1.57 :  
#                    #histos[folder+'/h_collmass_lowPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi), weight[n])
#                    #histos[folder+'/h_collmassSpread_lowPhi_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, weight[n])
#                histos[folder+'/h_collmassSpread_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi)-125.0, weight[n])
#                #histos[folder+'/h_collmassSpread_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi)-125.0, weight[n])
#

                histos[folder+'/h_collmass_pfmet'].Fill(collmass(row, row.type1_pfMetEt, row.type1_pfMetPhi), weight[n])
                #histos[folder+'/h_collmass_mvamet'].Fill(collmass(row, row.mva_metEt, row.mva_metPhi), weight[n])


                histos[folder+'/h_vismass'].Fill(row.e_m_Mass, weight[n])


#                histos[folder+'/type1_pfMetEt_vs_dPhi'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), row.type1_pfMetEt, weight[n])
#                #histos[folder+'/mvaMetEt_vs_dPhi'].Fill(deltaPhi(row.tPhi, row.mva_metPhi), row.mva_metEt, weight[n])
#                histos[folder+'/ePFMET_DeltaPhi'].Fill(deltaPhi(row.ePhi, row.type1_pfMetPhi), weight[n])
#                #histos[folder+'/eMVAMET_DeltaPhi'].Fill(deltaPhi(row.ePhi, row.mva_metPhi), weight[n])
#                histos[folder+'/ePFMET_Mt'].Fill(row.eMtToPfMet_Raw, weight[n])
#                #histos[folder+'/eMVAMET_Mt'].Fill(row.eMtToMVAMET, weight[n])
#                histos[folder+'/mPFMET_DeltaPhi'].Fill(deltaPhi(row.mPhi, row.type1_pfMetPhi), weight[n])
#                #histos[folder+'/tMVAMET_DeltaPhi'].Fill(deltaPhi(row.tPhi, row.mva_metPhi), weight[n])
#                histos[folder+'/mPFMET_Mt'].Fill(row.mMtToPfMet_Raw, weight[n])
#                #histos[folder+'/tMVAMET_Mt'].Fill(row.tMtToMVAMET, weight[n])
                histos[folder+'/jetN_20'].Fill(row.jetVeto20, weight[n]) 
                histos[folder+'/jetN_30'].Fill(row.jetVeto30, weight[n]) 



        

    def process(self):
        
        #central_weights = fakerate_central_histogram(25,0, 2.5)
        #p1s_weights = fakerate_p1s_histogram(25,0, 2.5)#fakerate_p1s_histogram(25,0, 2.5)
        #m1s_weights = fakerate_m1s_histogram(25,0, 2.5)#fakerate_m1s_histogram(25,0, 2.5)
        cut_flow_histo = self.cut_flow_histo
        cut_flow_trk   = cut_flow_tracker(cut_flow_histo)
        myevent=()


        frw = []
        for row in self.tree:
            sign = 'ss' if row.e_m_SS else 'os'

            ptthreshold = [30]
            processtype ='gg'##changed from 20

            cut_flow_trk.new_row(row.run,row.lumi,row.evt)
           
            cut_flow_trk.Fill('allEvents')

            if not bool(row.singleE17SingleMu8Pass) : continue
            cut_flow_trk.Fill('HLTIsoPasstrg')



            jn = row.jetVeto30
            #print 'number of jets', jn
            if jn > 3 : jn = 3

            #take care of ecal gap
            if row.eAbsEta > 1.4442 and row.eAbsEta < 1.566 : continue             

            #e Preselection
            if not selections.eSelection(row, 'e'): continue
            cut_flow_trk.Fill('esel')
            if not selections.lepton_id_iso(row, 'e', 'eid15Loose_etauiso01'): continue
            cut_flow_trk.Fill('eiso')

            #mu Preselection
            if not selections.muSelection(row, 'm'): continue
            cut_flow_trk.Fill('musel')
            if not selections.lepton_id_iso(row, 'm', 'MuIDTight_mutauiso025'): continue
            cut_flow_trk.Fill('muiso')

            frw=1. ## add the correct fakerate weight once we have it


            isMuonTight=False
            if selections.lepton_id_iso(row, 'm', 'MuIDTight_mutauiso015'): 
                isMuonTight=True
            #event cleaning
#            cut_flow_trk.Fill('mtight')


 #           if row.bjetCISVVeto30Loose : continue
            cut_flow_trk.Fill('bjetveto')

#            if deltaR(row.ePhi,row.mPhi,row.eEta,row.mEta)<0.1:continue
            cut_flow_trk.Fill('DR_e_mu')
            
            if row.muVetoPt5IsoIdVtx :continue
            cut_flow_trk.Fill('surplus_mu_veto')

            if row.tauVetoPt20Loose3HitsNewDMVtx:continue
            cut_flow_trk.Fill('surplus_tau_veto')

            if row.eVetoMVAIsoVtx :continue
            cut_flow_trk.Fill('surplus_e_veto')
            #need to add Surpluse Veto

#            for j in ptthreshold:
            folder = sign+'/'+processtype+'/'+str(int(jn))
            self.fill_histos(row, folder,isMuonTight, frw)
            if jn == 0 :
                if row.ePt < 50: continue 
                if row.mPt < 15 : continue
                if deltaPhi(row.mPhi, row.raw_pfMetPhi) > 0.8 : continue
                # if row.mMtToPfMet_Raw < 50 : continue
                # if row.eMtToPfMet_Raw > 65 : continue
                cut_flow_trk.Fill('jet0sel')
                
            if jn == 1 :
                if row.mPt < 15: continue 
                if row.ePt < 40 : continue
                if deltaPhi(row.ePhi, row.mPhi) < 0.5 : continue
                if deltaPhi(row.mPhi, row.raw_pfMetPhi) > 0.8 : continue
#                    if deltaR(row.ePhi,row.mPhi,row.eEta,row.mEta)<1:continue
                if row.mMtToPfMet_Raw > 40 : continue
                    #                    if row.eMtToPfMet_Raw > 65 : continue
                cut_flow_trk.Fill('jet1sel')

            if jn == 2 :
                if row.mPt < 15: continue 
                if row.ePt < 40 : continue # no cut as only electrons with pt>30 are in the ntuples
                    #                    if deltaPhi(row.ePhi, row.raw_pfMetPhi) > 0.3 : continue
                if row.mMtToPfMet_Raw > 40 : continue
                    #                    if row.eMtToPfMet_Raw > 25 : continue
                if row.vbfMass < 200 : continue
                if row.vbfDeta < 3 : continue
                cut_flow_trk.Fill('jet2sel')

            folder = sign+'/'+processtype+'/'+str(int(jn))+'/selected'
            self.fill_histos(row, folder, isMuonTight,frw)
        cut_flow_trk.flush()        

   
             
            
    def finish(self):
        self.write_histos()

