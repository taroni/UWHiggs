

# Load relevant ROOT C++ headers
cdef extern from "TObject.h":
    cdef cppclass TObject:
        pass

cdef extern from "TBranch.h":
    cdef cppclass TBranch:
        int GetEntry(long, int)
        void SetAddress(void*)

cdef extern from "TTree.h":
    cdef cppclass TTree:
        TTree()
        int GetEntry(long, int)
        long LoadTree(long)
        long GetEntries()
        TTree* GetTree()
        int GetTreeNumber()
        TBranch* GetBranch(char*)

cdef extern from "TFile.h":
    cdef cppclass TFile:
        TFile(char*, char*, char*, int)
        TObject* Get(char*)

# Used for filtering with a string
cdef extern from "TTreeFormula.h":
    cdef cppclass TTreeFormula:
        TTreeFormula(char*, char*, TTree*)
        double EvalInstance(int, char**)
        void UpdateFormulaLeaves()
        void SetTree(TTree*)

from cpython cimport PyCObject_AsVoidPtr
import warnings
def my_warning_format(message, category, filename, lineno, line=""):
    return "%s:%s\n" % (category.__name__, message)
warnings.formatwarning = my_warning_format

cdef class MMMTree:
    # Pointers to tree (may be a chain), current active tree, and current entry
    # localentry is the entry in the current tree of the chain
    cdef TTree* tree
    cdef TTree* currentTree
    cdef int currentTreeNumber
    cdef long ientry
    cdef long localentry
    # Keep track of missing branches we have complained about.
    cdef public set complained

    # Branches and address for all

    cdef TBranch* EmbPtWeight_branch
    cdef float EmbPtWeight_value

    cdef TBranch* Eta_branch
    cdef float Eta_value

    cdef TBranch* GenWeight_branch
    cdef float GenWeight_value

    cdef TBranch* Ht_branch
    cdef float Ht_value

    cdef TBranch* LT_branch
    cdef float LT_value

    cdef TBranch* Mass_branch
    cdef float Mass_value

    cdef TBranch* MassError_branch
    cdef float MassError_value

    cdef TBranch* MassErrord1_branch
    cdef float MassErrord1_value

    cdef TBranch* MassErrord2_branch
    cdef float MassErrord2_value

    cdef TBranch* MassErrord3_branch
    cdef float MassErrord3_value

    cdef TBranch* MassErrord4_branch
    cdef float MassErrord4_value

    cdef TBranch* Mt_branch
    cdef float Mt_value

    cdef TBranch* NUP_branch
    cdef float NUP_value

    cdef TBranch* Phi_branch
    cdef float Phi_value

    cdef TBranch* Pt_branch
    cdef float Pt_value

    cdef TBranch* bjetCISVVeto20Loose_branch
    cdef float bjetCISVVeto20Loose_value

    cdef TBranch* bjetCISVVeto20Medium_branch
    cdef float bjetCISVVeto20Medium_value

    cdef TBranch* bjetCISVVeto20Tight_branch
    cdef float bjetCISVVeto20Tight_value

    cdef TBranch* bjetCISVVeto30Loose_branch
    cdef float bjetCISVVeto30Loose_value

    cdef TBranch* bjetCISVVeto30Medium_branch
    cdef float bjetCISVVeto30Medium_value

    cdef TBranch* bjetCISVVeto30Tight_branch
    cdef float bjetCISVVeto30Tight_value

    cdef TBranch* charge_branch
    cdef float charge_value

    cdef TBranch* doubleEGroup_branch
    cdef float doubleEGroup_value

    cdef TBranch* doubleEPass_branch
    cdef float doubleEPass_value

    cdef TBranch* doubleEPrescale_branch
    cdef float doubleEPrescale_value

    cdef TBranch* doubleESingleMuGroup_branch
    cdef float doubleESingleMuGroup_value

    cdef TBranch* doubleESingleMuPass_branch
    cdef float doubleESingleMuPass_value

    cdef TBranch* doubleESingleMuPrescale_branch
    cdef float doubleESingleMuPrescale_value

    cdef TBranch* doubleMuGroup_branch
    cdef float doubleMuGroup_value

    cdef TBranch* doubleMuPass_branch
    cdef float doubleMuPass_value

    cdef TBranch* doubleMuPrescale_branch
    cdef float doubleMuPrescale_value

    cdef TBranch* doubleMuSingleEGroup_branch
    cdef float doubleMuSingleEGroup_value

    cdef TBranch* doubleMuSingleEPass_branch
    cdef float doubleMuSingleEPass_value

    cdef TBranch* doubleMuSingleEPrescale_branch
    cdef float doubleMuSingleEPrescale_value

    cdef TBranch* doubleTau35Group_branch
    cdef float doubleTau35Group_value

    cdef TBranch* doubleTau35Pass_branch
    cdef float doubleTau35Pass_value

    cdef TBranch* doubleTau35Prescale_branch
    cdef float doubleTau35Prescale_value

    cdef TBranch* doubleTau40Group_branch
    cdef float doubleTau40Group_value

    cdef TBranch* doubleTau40Pass_branch
    cdef float doubleTau40Pass_value

    cdef TBranch* doubleTau40Prescale_branch
    cdef float doubleTau40Prescale_value

    cdef TBranch* eVetoMVAIso_branch
    cdef float eVetoMVAIso_value

    cdef TBranch* eVetoMVAIsoVtx_branch
    cdef float eVetoMVAIsoVtx_value

    cdef TBranch* evt_branch
    cdef unsigned long evt_value

    cdef TBranch* genHTT_branch
    cdef float genHTT_value

    cdef TBranch* isGtautau_branch
    cdef float isGtautau_value

    cdef TBranch* isWmunu_branch
    cdef float isWmunu_value

    cdef TBranch* isWtaunu_branch
    cdef float isWtaunu_value

    cdef TBranch* isZee_branch
    cdef float isZee_value

    cdef TBranch* isZmumu_branch
    cdef float isZmumu_value

    cdef TBranch* isZtautau_branch
    cdef float isZtautau_value

    cdef TBranch* isdata_branch
    cdef int isdata_value

    cdef TBranch* jetVeto20_branch
    cdef float jetVeto20_value

    cdef TBranch* jetVeto20_DR05_branch
    cdef float jetVeto20_DR05_value

    cdef TBranch* jetVeto30_branch
    cdef float jetVeto30_value

    cdef TBranch* jetVeto30Eta3_branch
    cdef float jetVeto30Eta3_value

    cdef TBranch* jetVeto30Eta3_JetEnDown_branch
    cdef float jetVeto30Eta3_JetEnDown_value

    cdef TBranch* jetVeto30Eta3_JetEnUp_branch
    cdef float jetVeto30Eta3_JetEnUp_value

    cdef TBranch* jetVeto30_DR05_branch
    cdef float jetVeto30_DR05_value

    cdef TBranch* jetVeto30_JetEnDown_branch
    cdef float jetVeto30_JetEnDown_value

    cdef TBranch* jetVeto30_JetEnUp_branch
    cdef float jetVeto30_JetEnUp_value

    cdef TBranch* jetVeto40_branch
    cdef float jetVeto40_value

    cdef TBranch* jetVeto40_DR05_branch
    cdef float jetVeto40_DR05_value

    cdef TBranch* lumi_branch
    cdef int lumi_value

    cdef TBranch* m1AbsEta_branch
    cdef float m1AbsEta_value

    cdef TBranch* m1BestTrackType_branch
    cdef float m1BestTrackType_value

    cdef TBranch* m1Charge_branch
    cdef float m1Charge_value

    cdef TBranch* m1ComesFromHiggs_branch
    cdef float m1ComesFromHiggs_value

    cdef TBranch* m1DPhiToPfMet_ElectronEnDown_branch
    cdef float m1DPhiToPfMet_ElectronEnDown_value

    cdef TBranch* m1DPhiToPfMet_ElectronEnUp_branch
    cdef float m1DPhiToPfMet_ElectronEnUp_value

    cdef TBranch* m1DPhiToPfMet_JetEnDown_branch
    cdef float m1DPhiToPfMet_JetEnDown_value

    cdef TBranch* m1DPhiToPfMet_JetEnUp_branch
    cdef float m1DPhiToPfMet_JetEnUp_value

    cdef TBranch* m1DPhiToPfMet_JetResDown_branch
    cdef float m1DPhiToPfMet_JetResDown_value

    cdef TBranch* m1DPhiToPfMet_JetResUp_branch
    cdef float m1DPhiToPfMet_JetResUp_value

    cdef TBranch* m1DPhiToPfMet_MuonEnDown_branch
    cdef float m1DPhiToPfMet_MuonEnDown_value

    cdef TBranch* m1DPhiToPfMet_MuonEnUp_branch
    cdef float m1DPhiToPfMet_MuonEnUp_value

    cdef TBranch* m1DPhiToPfMet_PhotonEnDown_branch
    cdef float m1DPhiToPfMet_PhotonEnDown_value

    cdef TBranch* m1DPhiToPfMet_PhotonEnUp_branch
    cdef float m1DPhiToPfMet_PhotonEnUp_value

    cdef TBranch* m1DPhiToPfMet_TauEnDown_branch
    cdef float m1DPhiToPfMet_TauEnDown_value

    cdef TBranch* m1DPhiToPfMet_TauEnUp_branch
    cdef float m1DPhiToPfMet_TauEnUp_value

    cdef TBranch* m1DPhiToPfMet_UnclusteredEnDown_branch
    cdef float m1DPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* m1DPhiToPfMet_UnclusteredEnUp_branch
    cdef float m1DPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* m1DPhiToPfMet_type1_branch
    cdef float m1DPhiToPfMet_type1_value

    cdef TBranch* m1EcalIsoDR03_branch
    cdef float m1EcalIsoDR03_value

    cdef TBranch* m1EffectiveArea2011_branch
    cdef float m1EffectiveArea2011_value

    cdef TBranch* m1EffectiveArea2012_branch
    cdef float m1EffectiveArea2012_value

    cdef TBranch* m1Eta_branch
    cdef float m1Eta_value

    cdef TBranch* m1Eta_MuonEnDown_branch
    cdef float m1Eta_MuonEnDown_value

    cdef TBranch* m1Eta_MuonEnUp_branch
    cdef float m1Eta_MuonEnUp_value

    cdef TBranch* m1GenCharge_branch
    cdef float m1GenCharge_value

    cdef TBranch* m1GenEnergy_branch
    cdef float m1GenEnergy_value

    cdef TBranch* m1GenEta_branch
    cdef float m1GenEta_value

    cdef TBranch* m1GenMotherPdgId_branch
    cdef float m1GenMotherPdgId_value

    cdef TBranch* m1GenPdgId_branch
    cdef float m1GenPdgId_value

    cdef TBranch* m1GenPhi_branch
    cdef float m1GenPhi_value

    cdef TBranch* m1GenPrompt_branch
    cdef float m1GenPrompt_value

    cdef TBranch* m1GenPromptTauDecay_branch
    cdef float m1GenPromptTauDecay_value

    cdef TBranch* m1GenPt_branch
    cdef float m1GenPt_value

    cdef TBranch* m1GenTauDecay_branch
    cdef float m1GenTauDecay_value

    cdef TBranch* m1GenVZ_branch
    cdef float m1GenVZ_value

    cdef TBranch* m1GenVtxPVMatch_branch
    cdef float m1GenVtxPVMatch_value

    cdef TBranch* m1HcalIsoDR03_branch
    cdef float m1HcalIsoDR03_value

    cdef TBranch* m1IP3D_branch
    cdef float m1IP3D_value

    cdef TBranch* m1IP3DErr_branch
    cdef float m1IP3DErr_value

    cdef TBranch* m1IsGlobal_branch
    cdef float m1IsGlobal_value

    cdef TBranch* m1IsPFMuon_branch
    cdef float m1IsPFMuon_value

    cdef TBranch* m1IsTracker_branch
    cdef float m1IsTracker_value

    cdef TBranch* m1JetArea_branch
    cdef float m1JetArea_value

    cdef TBranch* m1JetBtag_branch
    cdef float m1JetBtag_value

    cdef TBranch* m1JetEtaEtaMoment_branch
    cdef float m1JetEtaEtaMoment_value

    cdef TBranch* m1JetEtaPhiMoment_branch
    cdef float m1JetEtaPhiMoment_value

    cdef TBranch* m1JetEtaPhiSpread_branch
    cdef float m1JetEtaPhiSpread_value

    cdef TBranch* m1JetPFCISVBtag_branch
    cdef float m1JetPFCISVBtag_value

    cdef TBranch* m1JetPartonFlavour_branch
    cdef float m1JetPartonFlavour_value

    cdef TBranch* m1JetPhiPhiMoment_branch
    cdef float m1JetPhiPhiMoment_value

    cdef TBranch* m1JetPt_branch
    cdef float m1JetPt_value

    cdef TBranch* m1LowestMll_branch
    cdef float m1LowestMll_value

    cdef TBranch* m1Mass_branch
    cdef float m1Mass_value

    cdef TBranch* m1MatchedStations_branch
    cdef float m1MatchedStations_value

    cdef TBranch* m1MatchesDoubleESingleMu_branch
    cdef float m1MatchesDoubleESingleMu_value

    cdef TBranch* m1MatchesDoubleMu_branch
    cdef float m1MatchesDoubleMu_value

    cdef TBranch* m1MatchesDoubleMuSingleE_branch
    cdef float m1MatchesDoubleMuSingleE_value

    cdef TBranch* m1MatchesSingleESingleMu_branch
    cdef float m1MatchesSingleESingleMu_value

    cdef TBranch* m1MatchesSingleMu_branch
    cdef float m1MatchesSingleMu_value

    cdef TBranch* m1MatchesSingleMuIso20_branch
    cdef float m1MatchesSingleMuIso20_value

    cdef TBranch* m1MatchesSingleMuIsoTk20_branch
    cdef float m1MatchesSingleMuIsoTk20_value

    cdef TBranch* m1MatchesSingleMuSingleE_branch
    cdef float m1MatchesSingleMuSingleE_value

    cdef TBranch* m1MatchesSingleMu_leg1_branch
    cdef float m1MatchesSingleMu_leg1_value

    cdef TBranch* m1MatchesSingleMu_leg1_noiso_branch
    cdef float m1MatchesSingleMu_leg1_noiso_value

    cdef TBranch* m1MatchesSingleMu_leg2_branch
    cdef float m1MatchesSingleMu_leg2_value

    cdef TBranch* m1MatchesSingleMu_leg2_noiso_branch
    cdef float m1MatchesSingleMu_leg2_noiso_value

    cdef TBranch* m1MatchesTripleMu_branch
    cdef float m1MatchesTripleMu_value

    cdef TBranch* m1MtToPfMet_ElectronEnDown_branch
    cdef float m1MtToPfMet_ElectronEnDown_value

    cdef TBranch* m1MtToPfMet_ElectronEnUp_branch
    cdef float m1MtToPfMet_ElectronEnUp_value

    cdef TBranch* m1MtToPfMet_JetEnDown_branch
    cdef float m1MtToPfMet_JetEnDown_value

    cdef TBranch* m1MtToPfMet_JetEnUp_branch
    cdef float m1MtToPfMet_JetEnUp_value

    cdef TBranch* m1MtToPfMet_JetResDown_branch
    cdef float m1MtToPfMet_JetResDown_value

    cdef TBranch* m1MtToPfMet_JetResUp_branch
    cdef float m1MtToPfMet_JetResUp_value

    cdef TBranch* m1MtToPfMet_MuonEnDown_branch
    cdef float m1MtToPfMet_MuonEnDown_value

    cdef TBranch* m1MtToPfMet_MuonEnUp_branch
    cdef float m1MtToPfMet_MuonEnUp_value

    cdef TBranch* m1MtToPfMet_PhotonEnDown_branch
    cdef float m1MtToPfMet_PhotonEnDown_value

    cdef TBranch* m1MtToPfMet_PhotonEnUp_branch
    cdef float m1MtToPfMet_PhotonEnUp_value

    cdef TBranch* m1MtToPfMet_Raw_branch
    cdef float m1MtToPfMet_Raw_value

    cdef TBranch* m1MtToPfMet_TauEnDown_branch
    cdef float m1MtToPfMet_TauEnDown_value

    cdef TBranch* m1MtToPfMet_TauEnUp_branch
    cdef float m1MtToPfMet_TauEnUp_value

    cdef TBranch* m1MtToPfMet_UnclusteredEnDown_branch
    cdef float m1MtToPfMet_UnclusteredEnDown_value

    cdef TBranch* m1MtToPfMet_UnclusteredEnUp_branch
    cdef float m1MtToPfMet_UnclusteredEnUp_value

    cdef TBranch* m1MtToPfMet_type1_branch
    cdef float m1MtToPfMet_type1_value

    cdef TBranch* m1MuonHits_branch
    cdef float m1MuonHits_value

    cdef TBranch* m1NearestZMass_branch
    cdef float m1NearestZMass_value

    cdef TBranch* m1NormTrkChi2_branch
    cdef float m1NormTrkChi2_value

    cdef TBranch* m1PFChargedIso_branch
    cdef float m1PFChargedIso_value

    cdef TBranch* m1PFIDLoose_branch
    cdef float m1PFIDLoose_value

    cdef TBranch* m1PFIDMedium_branch
    cdef float m1PFIDMedium_value

    cdef TBranch* m1PFIDTight_branch
    cdef float m1PFIDTight_value

    cdef TBranch* m1PFNeutralIso_branch
    cdef float m1PFNeutralIso_value

    cdef TBranch* m1PFPUChargedIso_branch
    cdef float m1PFPUChargedIso_value

    cdef TBranch* m1PFPhotonIso_branch
    cdef float m1PFPhotonIso_value

    cdef TBranch* m1PVDXY_branch
    cdef float m1PVDXY_value

    cdef TBranch* m1PVDZ_branch
    cdef float m1PVDZ_value

    cdef TBranch* m1Phi_branch
    cdef float m1Phi_value

    cdef TBranch* m1Phi_MuonEnDown_branch
    cdef float m1Phi_MuonEnDown_value

    cdef TBranch* m1Phi_MuonEnUp_branch
    cdef float m1Phi_MuonEnUp_value

    cdef TBranch* m1PixHits_branch
    cdef float m1PixHits_value

    cdef TBranch* m1Pt_branch
    cdef float m1Pt_value

    cdef TBranch* m1Pt_MuonEnDown_branch
    cdef float m1Pt_MuonEnDown_value

    cdef TBranch* m1Pt_MuonEnUp_branch
    cdef float m1Pt_MuonEnUp_value

    cdef TBranch* m1Rank_branch
    cdef float m1Rank_value

    cdef TBranch* m1RelPFIsoDBDefault_branch
    cdef float m1RelPFIsoDBDefault_value

    cdef TBranch* m1RelPFIsoRho_branch
    cdef float m1RelPFIsoRho_value

    cdef TBranch* m1Rho_branch
    cdef float m1Rho_value

    cdef TBranch* m1SIP2D_branch
    cdef float m1SIP2D_value

    cdef TBranch* m1SIP3D_branch
    cdef float m1SIP3D_value

    cdef TBranch* m1TkLayersWithMeasurement_branch
    cdef float m1TkLayersWithMeasurement_value

    cdef TBranch* m1TrkIsoDR03_branch
    cdef float m1TrkIsoDR03_value

    cdef TBranch* m1TypeCode_branch
    cdef int m1TypeCode_value

    cdef TBranch* m1VZ_branch
    cdef float m1VZ_value

    cdef TBranch* m1_m2_CosThetaStar_branch
    cdef float m1_m2_CosThetaStar_value

    cdef TBranch* m1_m2_DPhi_branch
    cdef float m1_m2_DPhi_value

    cdef TBranch* m1_m2_DR_branch
    cdef float m1_m2_DR_value

    cdef TBranch* m1_m2_Eta_branch
    cdef float m1_m2_Eta_value

    cdef TBranch* m1_m2_Mass_branch
    cdef float m1_m2_Mass_value

    cdef TBranch* m1_m2_Mt_branch
    cdef float m1_m2_Mt_value

    cdef TBranch* m1_m2_PZeta_branch
    cdef float m1_m2_PZeta_value

    cdef TBranch* m1_m2_PZetaVis_branch
    cdef float m1_m2_PZetaVis_value

    cdef TBranch* m1_m2_Phi_branch
    cdef float m1_m2_Phi_value

    cdef TBranch* m1_m2_Pt_branch
    cdef float m1_m2_Pt_value

    cdef TBranch* m1_m2_SS_branch
    cdef float m1_m2_SS_value

    cdef TBranch* m1_m2_ToMETDPhi_Ty1_branch
    cdef float m1_m2_ToMETDPhi_Ty1_value

    cdef TBranch* m1_m2_collinearmass_branch
    cdef float m1_m2_collinearmass_value

    cdef TBranch* m1_m2_collinearmass_JetEnDown_branch
    cdef float m1_m2_collinearmass_JetEnDown_value

    cdef TBranch* m1_m2_collinearmass_JetEnUp_branch
    cdef float m1_m2_collinearmass_JetEnUp_value

    cdef TBranch* m1_m2_collinearmass_UnclusteredEnDown_branch
    cdef float m1_m2_collinearmass_UnclusteredEnDown_value

    cdef TBranch* m1_m2_collinearmass_UnclusteredEnUp_branch
    cdef float m1_m2_collinearmass_UnclusteredEnUp_value

    cdef TBranch* m1_m3_CosThetaStar_branch
    cdef float m1_m3_CosThetaStar_value

    cdef TBranch* m1_m3_DPhi_branch
    cdef float m1_m3_DPhi_value

    cdef TBranch* m1_m3_DR_branch
    cdef float m1_m3_DR_value

    cdef TBranch* m1_m3_Eta_branch
    cdef float m1_m3_Eta_value

    cdef TBranch* m1_m3_Mass_branch
    cdef float m1_m3_Mass_value

    cdef TBranch* m1_m3_Mt_branch
    cdef float m1_m3_Mt_value

    cdef TBranch* m1_m3_PZeta_branch
    cdef float m1_m3_PZeta_value

    cdef TBranch* m1_m3_PZetaVis_branch
    cdef float m1_m3_PZetaVis_value

    cdef TBranch* m1_m3_Phi_branch
    cdef float m1_m3_Phi_value

    cdef TBranch* m1_m3_Pt_branch
    cdef float m1_m3_Pt_value

    cdef TBranch* m1_m3_SS_branch
    cdef float m1_m3_SS_value

    cdef TBranch* m1_m3_ToMETDPhi_Ty1_branch
    cdef float m1_m3_ToMETDPhi_Ty1_value

    cdef TBranch* m1_m3_collinearmass_branch
    cdef float m1_m3_collinearmass_value

    cdef TBranch* m1_m3_collinearmass_JetEnDown_branch
    cdef float m1_m3_collinearmass_JetEnDown_value

    cdef TBranch* m1_m3_collinearmass_JetEnUp_branch
    cdef float m1_m3_collinearmass_JetEnUp_value

    cdef TBranch* m1_m3_collinearmass_UnclusteredEnDown_branch
    cdef float m1_m3_collinearmass_UnclusteredEnDown_value

    cdef TBranch* m1_m3_collinearmass_UnclusteredEnUp_branch
    cdef float m1_m3_collinearmass_UnclusteredEnUp_value

    cdef TBranch* m2AbsEta_branch
    cdef float m2AbsEta_value

    cdef TBranch* m2BestTrackType_branch
    cdef float m2BestTrackType_value

    cdef TBranch* m2Charge_branch
    cdef float m2Charge_value

    cdef TBranch* m2ComesFromHiggs_branch
    cdef float m2ComesFromHiggs_value

    cdef TBranch* m2DPhiToPfMet_ElectronEnDown_branch
    cdef float m2DPhiToPfMet_ElectronEnDown_value

    cdef TBranch* m2DPhiToPfMet_ElectronEnUp_branch
    cdef float m2DPhiToPfMet_ElectronEnUp_value

    cdef TBranch* m2DPhiToPfMet_JetEnDown_branch
    cdef float m2DPhiToPfMet_JetEnDown_value

    cdef TBranch* m2DPhiToPfMet_JetEnUp_branch
    cdef float m2DPhiToPfMet_JetEnUp_value

    cdef TBranch* m2DPhiToPfMet_JetResDown_branch
    cdef float m2DPhiToPfMet_JetResDown_value

    cdef TBranch* m2DPhiToPfMet_JetResUp_branch
    cdef float m2DPhiToPfMet_JetResUp_value

    cdef TBranch* m2DPhiToPfMet_MuonEnDown_branch
    cdef float m2DPhiToPfMet_MuonEnDown_value

    cdef TBranch* m2DPhiToPfMet_MuonEnUp_branch
    cdef float m2DPhiToPfMet_MuonEnUp_value

    cdef TBranch* m2DPhiToPfMet_PhotonEnDown_branch
    cdef float m2DPhiToPfMet_PhotonEnDown_value

    cdef TBranch* m2DPhiToPfMet_PhotonEnUp_branch
    cdef float m2DPhiToPfMet_PhotonEnUp_value

    cdef TBranch* m2DPhiToPfMet_TauEnDown_branch
    cdef float m2DPhiToPfMet_TauEnDown_value

    cdef TBranch* m2DPhiToPfMet_TauEnUp_branch
    cdef float m2DPhiToPfMet_TauEnUp_value

    cdef TBranch* m2DPhiToPfMet_UnclusteredEnDown_branch
    cdef float m2DPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* m2DPhiToPfMet_UnclusteredEnUp_branch
    cdef float m2DPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* m2DPhiToPfMet_type1_branch
    cdef float m2DPhiToPfMet_type1_value

    cdef TBranch* m2EcalIsoDR03_branch
    cdef float m2EcalIsoDR03_value

    cdef TBranch* m2EffectiveArea2011_branch
    cdef float m2EffectiveArea2011_value

    cdef TBranch* m2EffectiveArea2012_branch
    cdef float m2EffectiveArea2012_value

    cdef TBranch* m2Eta_branch
    cdef float m2Eta_value

    cdef TBranch* m2Eta_MuonEnDown_branch
    cdef float m2Eta_MuonEnDown_value

    cdef TBranch* m2Eta_MuonEnUp_branch
    cdef float m2Eta_MuonEnUp_value

    cdef TBranch* m2GenCharge_branch
    cdef float m2GenCharge_value

    cdef TBranch* m2GenEnergy_branch
    cdef float m2GenEnergy_value

    cdef TBranch* m2GenEta_branch
    cdef float m2GenEta_value

    cdef TBranch* m2GenMotherPdgId_branch
    cdef float m2GenMotherPdgId_value

    cdef TBranch* m2GenPdgId_branch
    cdef float m2GenPdgId_value

    cdef TBranch* m2GenPhi_branch
    cdef float m2GenPhi_value

    cdef TBranch* m2GenPrompt_branch
    cdef float m2GenPrompt_value

    cdef TBranch* m2GenPromptTauDecay_branch
    cdef float m2GenPromptTauDecay_value

    cdef TBranch* m2GenPt_branch
    cdef float m2GenPt_value

    cdef TBranch* m2GenTauDecay_branch
    cdef float m2GenTauDecay_value

    cdef TBranch* m2GenVZ_branch
    cdef float m2GenVZ_value

    cdef TBranch* m2GenVtxPVMatch_branch
    cdef float m2GenVtxPVMatch_value

    cdef TBranch* m2HcalIsoDR03_branch
    cdef float m2HcalIsoDR03_value

    cdef TBranch* m2IP3D_branch
    cdef float m2IP3D_value

    cdef TBranch* m2IP3DErr_branch
    cdef float m2IP3DErr_value

    cdef TBranch* m2IsGlobal_branch
    cdef float m2IsGlobal_value

    cdef TBranch* m2IsPFMuon_branch
    cdef float m2IsPFMuon_value

    cdef TBranch* m2IsTracker_branch
    cdef float m2IsTracker_value

    cdef TBranch* m2JetArea_branch
    cdef float m2JetArea_value

    cdef TBranch* m2JetBtag_branch
    cdef float m2JetBtag_value

    cdef TBranch* m2JetEtaEtaMoment_branch
    cdef float m2JetEtaEtaMoment_value

    cdef TBranch* m2JetEtaPhiMoment_branch
    cdef float m2JetEtaPhiMoment_value

    cdef TBranch* m2JetEtaPhiSpread_branch
    cdef float m2JetEtaPhiSpread_value

    cdef TBranch* m2JetPFCISVBtag_branch
    cdef float m2JetPFCISVBtag_value

    cdef TBranch* m2JetPartonFlavour_branch
    cdef float m2JetPartonFlavour_value

    cdef TBranch* m2JetPhiPhiMoment_branch
    cdef float m2JetPhiPhiMoment_value

    cdef TBranch* m2JetPt_branch
    cdef float m2JetPt_value

    cdef TBranch* m2LowestMll_branch
    cdef float m2LowestMll_value

    cdef TBranch* m2Mass_branch
    cdef float m2Mass_value

    cdef TBranch* m2MatchedStations_branch
    cdef float m2MatchedStations_value

    cdef TBranch* m2MatchesDoubleESingleMu_branch
    cdef float m2MatchesDoubleESingleMu_value

    cdef TBranch* m2MatchesDoubleMu_branch
    cdef float m2MatchesDoubleMu_value

    cdef TBranch* m2MatchesDoubleMuSingleE_branch
    cdef float m2MatchesDoubleMuSingleE_value

    cdef TBranch* m2MatchesSingleESingleMu_branch
    cdef float m2MatchesSingleESingleMu_value

    cdef TBranch* m2MatchesSingleMu_branch
    cdef float m2MatchesSingleMu_value

    cdef TBranch* m2MatchesSingleMuIso20_branch
    cdef float m2MatchesSingleMuIso20_value

    cdef TBranch* m2MatchesSingleMuIsoTk20_branch
    cdef float m2MatchesSingleMuIsoTk20_value

    cdef TBranch* m2MatchesSingleMuSingleE_branch
    cdef float m2MatchesSingleMuSingleE_value

    cdef TBranch* m2MatchesSingleMu_leg1_branch
    cdef float m2MatchesSingleMu_leg1_value

    cdef TBranch* m2MatchesSingleMu_leg1_noiso_branch
    cdef float m2MatchesSingleMu_leg1_noiso_value

    cdef TBranch* m2MatchesSingleMu_leg2_branch
    cdef float m2MatchesSingleMu_leg2_value

    cdef TBranch* m2MatchesSingleMu_leg2_noiso_branch
    cdef float m2MatchesSingleMu_leg2_noiso_value

    cdef TBranch* m2MatchesTripleMu_branch
    cdef float m2MatchesTripleMu_value

    cdef TBranch* m2MtToPfMet_ElectronEnDown_branch
    cdef float m2MtToPfMet_ElectronEnDown_value

    cdef TBranch* m2MtToPfMet_ElectronEnUp_branch
    cdef float m2MtToPfMet_ElectronEnUp_value

    cdef TBranch* m2MtToPfMet_JetEnDown_branch
    cdef float m2MtToPfMet_JetEnDown_value

    cdef TBranch* m2MtToPfMet_JetEnUp_branch
    cdef float m2MtToPfMet_JetEnUp_value

    cdef TBranch* m2MtToPfMet_JetResDown_branch
    cdef float m2MtToPfMet_JetResDown_value

    cdef TBranch* m2MtToPfMet_JetResUp_branch
    cdef float m2MtToPfMet_JetResUp_value

    cdef TBranch* m2MtToPfMet_MuonEnDown_branch
    cdef float m2MtToPfMet_MuonEnDown_value

    cdef TBranch* m2MtToPfMet_MuonEnUp_branch
    cdef float m2MtToPfMet_MuonEnUp_value

    cdef TBranch* m2MtToPfMet_PhotonEnDown_branch
    cdef float m2MtToPfMet_PhotonEnDown_value

    cdef TBranch* m2MtToPfMet_PhotonEnUp_branch
    cdef float m2MtToPfMet_PhotonEnUp_value

    cdef TBranch* m2MtToPfMet_Raw_branch
    cdef float m2MtToPfMet_Raw_value

    cdef TBranch* m2MtToPfMet_TauEnDown_branch
    cdef float m2MtToPfMet_TauEnDown_value

    cdef TBranch* m2MtToPfMet_TauEnUp_branch
    cdef float m2MtToPfMet_TauEnUp_value

    cdef TBranch* m2MtToPfMet_UnclusteredEnDown_branch
    cdef float m2MtToPfMet_UnclusteredEnDown_value

    cdef TBranch* m2MtToPfMet_UnclusteredEnUp_branch
    cdef float m2MtToPfMet_UnclusteredEnUp_value

    cdef TBranch* m2MtToPfMet_type1_branch
    cdef float m2MtToPfMet_type1_value

    cdef TBranch* m2MuonHits_branch
    cdef float m2MuonHits_value

    cdef TBranch* m2NearestZMass_branch
    cdef float m2NearestZMass_value

    cdef TBranch* m2NormTrkChi2_branch
    cdef float m2NormTrkChi2_value

    cdef TBranch* m2PFChargedIso_branch
    cdef float m2PFChargedIso_value

    cdef TBranch* m2PFIDLoose_branch
    cdef float m2PFIDLoose_value

    cdef TBranch* m2PFIDMedium_branch
    cdef float m2PFIDMedium_value

    cdef TBranch* m2PFIDTight_branch
    cdef float m2PFIDTight_value

    cdef TBranch* m2PFNeutralIso_branch
    cdef float m2PFNeutralIso_value

    cdef TBranch* m2PFPUChargedIso_branch
    cdef float m2PFPUChargedIso_value

    cdef TBranch* m2PFPhotonIso_branch
    cdef float m2PFPhotonIso_value

    cdef TBranch* m2PVDXY_branch
    cdef float m2PVDXY_value

    cdef TBranch* m2PVDZ_branch
    cdef float m2PVDZ_value

    cdef TBranch* m2Phi_branch
    cdef float m2Phi_value

    cdef TBranch* m2Phi_MuonEnDown_branch
    cdef float m2Phi_MuonEnDown_value

    cdef TBranch* m2Phi_MuonEnUp_branch
    cdef float m2Phi_MuonEnUp_value

    cdef TBranch* m2PixHits_branch
    cdef float m2PixHits_value

    cdef TBranch* m2Pt_branch
    cdef float m2Pt_value

    cdef TBranch* m2Pt_MuonEnDown_branch
    cdef float m2Pt_MuonEnDown_value

    cdef TBranch* m2Pt_MuonEnUp_branch
    cdef float m2Pt_MuonEnUp_value

    cdef TBranch* m2Rank_branch
    cdef float m2Rank_value

    cdef TBranch* m2RelPFIsoDBDefault_branch
    cdef float m2RelPFIsoDBDefault_value

    cdef TBranch* m2RelPFIsoRho_branch
    cdef float m2RelPFIsoRho_value

    cdef TBranch* m2Rho_branch
    cdef float m2Rho_value

    cdef TBranch* m2SIP2D_branch
    cdef float m2SIP2D_value

    cdef TBranch* m2SIP3D_branch
    cdef float m2SIP3D_value

    cdef TBranch* m2TkLayersWithMeasurement_branch
    cdef float m2TkLayersWithMeasurement_value

    cdef TBranch* m2TrkIsoDR03_branch
    cdef float m2TrkIsoDR03_value

    cdef TBranch* m2TypeCode_branch
    cdef int m2TypeCode_value

    cdef TBranch* m2VZ_branch
    cdef float m2VZ_value

    cdef TBranch* m2_m1_collinearmass_branch
    cdef float m2_m1_collinearmass_value

    cdef TBranch* m2_m1_collinearmass_JetEnDown_branch
    cdef float m2_m1_collinearmass_JetEnDown_value

    cdef TBranch* m2_m1_collinearmass_JetEnUp_branch
    cdef float m2_m1_collinearmass_JetEnUp_value

    cdef TBranch* m2_m1_collinearmass_UnclusteredEnDown_branch
    cdef float m2_m1_collinearmass_UnclusteredEnDown_value

    cdef TBranch* m2_m1_collinearmass_UnclusteredEnUp_branch
    cdef float m2_m1_collinearmass_UnclusteredEnUp_value

    cdef TBranch* m2_m3_CosThetaStar_branch
    cdef float m2_m3_CosThetaStar_value

    cdef TBranch* m2_m3_DPhi_branch
    cdef float m2_m3_DPhi_value

    cdef TBranch* m2_m3_DR_branch
    cdef float m2_m3_DR_value

    cdef TBranch* m2_m3_Eta_branch
    cdef float m2_m3_Eta_value

    cdef TBranch* m2_m3_Mass_branch
    cdef float m2_m3_Mass_value

    cdef TBranch* m2_m3_Mt_branch
    cdef float m2_m3_Mt_value

    cdef TBranch* m2_m3_PZeta_branch
    cdef float m2_m3_PZeta_value

    cdef TBranch* m2_m3_PZetaVis_branch
    cdef float m2_m3_PZetaVis_value

    cdef TBranch* m2_m3_Phi_branch
    cdef float m2_m3_Phi_value

    cdef TBranch* m2_m3_Pt_branch
    cdef float m2_m3_Pt_value

    cdef TBranch* m2_m3_SS_branch
    cdef float m2_m3_SS_value

    cdef TBranch* m2_m3_ToMETDPhi_Ty1_branch
    cdef float m2_m3_ToMETDPhi_Ty1_value

    cdef TBranch* m2_m3_collinearmass_branch
    cdef float m2_m3_collinearmass_value

    cdef TBranch* m2_m3_collinearmass_JetEnDown_branch
    cdef float m2_m3_collinearmass_JetEnDown_value

    cdef TBranch* m2_m3_collinearmass_JetEnUp_branch
    cdef float m2_m3_collinearmass_JetEnUp_value

    cdef TBranch* m2_m3_collinearmass_UnclusteredEnDown_branch
    cdef float m2_m3_collinearmass_UnclusteredEnDown_value

    cdef TBranch* m2_m3_collinearmass_UnclusteredEnUp_branch
    cdef float m2_m3_collinearmass_UnclusteredEnUp_value

    cdef TBranch* m3AbsEta_branch
    cdef float m3AbsEta_value

    cdef TBranch* m3BestTrackType_branch
    cdef float m3BestTrackType_value

    cdef TBranch* m3Charge_branch
    cdef float m3Charge_value

    cdef TBranch* m3ComesFromHiggs_branch
    cdef float m3ComesFromHiggs_value

    cdef TBranch* m3DPhiToPfMet_ElectronEnDown_branch
    cdef float m3DPhiToPfMet_ElectronEnDown_value

    cdef TBranch* m3DPhiToPfMet_ElectronEnUp_branch
    cdef float m3DPhiToPfMet_ElectronEnUp_value

    cdef TBranch* m3DPhiToPfMet_JetEnDown_branch
    cdef float m3DPhiToPfMet_JetEnDown_value

    cdef TBranch* m3DPhiToPfMet_JetEnUp_branch
    cdef float m3DPhiToPfMet_JetEnUp_value

    cdef TBranch* m3DPhiToPfMet_JetResDown_branch
    cdef float m3DPhiToPfMet_JetResDown_value

    cdef TBranch* m3DPhiToPfMet_JetResUp_branch
    cdef float m3DPhiToPfMet_JetResUp_value

    cdef TBranch* m3DPhiToPfMet_MuonEnDown_branch
    cdef float m3DPhiToPfMet_MuonEnDown_value

    cdef TBranch* m3DPhiToPfMet_MuonEnUp_branch
    cdef float m3DPhiToPfMet_MuonEnUp_value

    cdef TBranch* m3DPhiToPfMet_PhotonEnDown_branch
    cdef float m3DPhiToPfMet_PhotonEnDown_value

    cdef TBranch* m3DPhiToPfMet_PhotonEnUp_branch
    cdef float m3DPhiToPfMet_PhotonEnUp_value

    cdef TBranch* m3DPhiToPfMet_TauEnDown_branch
    cdef float m3DPhiToPfMet_TauEnDown_value

    cdef TBranch* m3DPhiToPfMet_TauEnUp_branch
    cdef float m3DPhiToPfMet_TauEnUp_value

    cdef TBranch* m3DPhiToPfMet_UnclusteredEnDown_branch
    cdef float m3DPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* m3DPhiToPfMet_UnclusteredEnUp_branch
    cdef float m3DPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* m3DPhiToPfMet_type1_branch
    cdef float m3DPhiToPfMet_type1_value

    cdef TBranch* m3EcalIsoDR03_branch
    cdef float m3EcalIsoDR03_value

    cdef TBranch* m3EffectiveArea2011_branch
    cdef float m3EffectiveArea2011_value

    cdef TBranch* m3EffectiveArea2012_branch
    cdef float m3EffectiveArea2012_value

    cdef TBranch* m3Eta_branch
    cdef float m3Eta_value

    cdef TBranch* m3Eta_MuonEnDown_branch
    cdef float m3Eta_MuonEnDown_value

    cdef TBranch* m3Eta_MuonEnUp_branch
    cdef float m3Eta_MuonEnUp_value

    cdef TBranch* m3GenCharge_branch
    cdef float m3GenCharge_value

    cdef TBranch* m3GenEnergy_branch
    cdef float m3GenEnergy_value

    cdef TBranch* m3GenEta_branch
    cdef float m3GenEta_value

    cdef TBranch* m3GenMotherPdgId_branch
    cdef float m3GenMotherPdgId_value

    cdef TBranch* m3GenPdgId_branch
    cdef float m3GenPdgId_value

    cdef TBranch* m3GenPhi_branch
    cdef float m3GenPhi_value

    cdef TBranch* m3GenPrompt_branch
    cdef float m3GenPrompt_value

    cdef TBranch* m3GenPromptTauDecay_branch
    cdef float m3GenPromptTauDecay_value

    cdef TBranch* m3GenPt_branch
    cdef float m3GenPt_value

    cdef TBranch* m3GenTauDecay_branch
    cdef float m3GenTauDecay_value

    cdef TBranch* m3GenVZ_branch
    cdef float m3GenVZ_value

    cdef TBranch* m3GenVtxPVMatch_branch
    cdef float m3GenVtxPVMatch_value

    cdef TBranch* m3HcalIsoDR03_branch
    cdef float m3HcalIsoDR03_value

    cdef TBranch* m3IP3D_branch
    cdef float m3IP3D_value

    cdef TBranch* m3IP3DErr_branch
    cdef float m3IP3DErr_value

    cdef TBranch* m3IsGlobal_branch
    cdef float m3IsGlobal_value

    cdef TBranch* m3IsPFMuon_branch
    cdef float m3IsPFMuon_value

    cdef TBranch* m3IsTracker_branch
    cdef float m3IsTracker_value

    cdef TBranch* m3JetArea_branch
    cdef float m3JetArea_value

    cdef TBranch* m3JetBtag_branch
    cdef float m3JetBtag_value

    cdef TBranch* m3JetEtaEtaMoment_branch
    cdef float m3JetEtaEtaMoment_value

    cdef TBranch* m3JetEtaPhiMoment_branch
    cdef float m3JetEtaPhiMoment_value

    cdef TBranch* m3JetEtaPhiSpread_branch
    cdef float m3JetEtaPhiSpread_value

    cdef TBranch* m3JetPFCISVBtag_branch
    cdef float m3JetPFCISVBtag_value

    cdef TBranch* m3JetPartonFlavour_branch
    cdef float m3JetPartonFlavour_value

    cdef TBranch* m3JetPhiPhiMoment_branch
    cdef float m3JetPhiPhiMoment_value

    cdef TBranch* m3JetPt_branch
    cdef float m3JetPt_value

    cdef TBranch* m3LowestMll_branch
    cdef float m3LowestMll_value

    cdef TBranch* m3Mass_branch
    cdef float m3Mass_value

    cdef TBranch* m3MatchedStations_branch
    cdef float m3MatchedStations_value

    cdef TBranch* m3MatchesDoubleESingleMu_branch
    cdef float m3MatchesDoubleESingleMu_value

    cdef TBranch* m3MatchesDoubleMu_branch
    cdef float m3MatchesDoubleMu_value

    cdef TBranch* m3MatchesDoubleMuSingleE_branch
    cdef float m3MatchesDoubleMuSingleE_value

    cdef TBranch* m3MatchesSingleESingleMu_branch
    cdef float m3MatchesSingleESingleMu_value

    cdef TBranch* m3MatchesSingleMu_branch
    cdef float m3MatchesSingleMu_value

    cdef TBranch* m3MatchesSingleMuIso20_branch
    cdef float m3MatchesSingleMuIso20_value

    cdef TBranch* m3MatchesSingleMuIsoTk20_branch
    cdef float m3MatchesSingleMuIsoTk20_value

    cdef TBranch* m3MatchesSingleMuSingleE_branch
    cdef float m3MatchesSingleMuSingleE_value

    cdef TBranch* m3MatchesSingleMu_leg1_branch
    cdef float m3MatchesSingleMu_leg1_value

    cdef TBranch* m3MatchesSingleMu_leg1_noiso_branch
    cdef float m3MatchesSingleMu_leg1_noiso_value

    cdef TBranch* m3MatchesSingleMu_leg2_branch
    cdef float m3MatchesSingleMu_leg2_value

    cdef TBranch* m3MatchesSingleMu_leg2_noiso_branch
    cdef float m3MatchesSingleMu_leg2_noiso_value

    cdef TBranch* m3MatchesTripleMu_branch
    cdef float m3MatchesTripleMu_value

    cdef TBranch* m3MtToPfMet_ElectronEnDown_branch
    cdef float m3MtToPfMet_ElectronEnDown_value

    cdef TBranch* m3MtToPfMet_ElectronEnUp_branch
    cdef float m3MtToPfMet_ElectronEnUp_value

    cdef TBranch* m3MtToPfMet_JetEnDown_branch
    cdef float m3MtToPfMet_JetEnDown_value

    cdef TBranch* m3MtToPfMet_JetEnUp_branch
    cdef float m3MtToPfMet_JetEnUp_value

    cdef TBranch* m3MtToPfMet_JetResDown_branch
    cdef float m3MtToPfMet_JetResDown_value

    cdef TBranch* m3MtToPfMet_JetResUp_branch
    cdef float m3MtToPfMet_JetResUp_value

    cdef TBranch* m3MtToPfMet_MuonEnDown_branch
    cdef float m3MtToPfMet_MuonEnDown_value

    cdef TBranch* m3MtToPfMet_MuonEnUp_branch
    cdef float m3MtToPfMet_MuonEnUp_value

    cdef TBranch* m3MtToPfMet_PhotonEnDown_branch
    cdef float m3MtToPfMet_PhotonEnDown_value

    cdef TBranch* m3MtToPfMet_PhotonEnUp_branch
    cdef float m3MtToPfMet_PhotonEnUp_value

    cdef TBranch* m3MtToPfMet_Raw_branch
    cdef float m3MtToPfMet_Raw_value

    cdef TBranch* m3MtToPfMet_TauEnDown_branch
    cdef float m3MtToPfMet_TauEnDown_value

    cdef TBranch* m3MtToPfMet_TauEnUp_branch
    cdef float m3MtToPfMet_TauEnUp_value

    cdef TBranch* m3MtToPfMet_UnclusteredEnDown_branch
    cdef float m3MtToPfMet_UnclusteredEnDown_value

    cdef TBranch* m3MtToPfMet_UnclusteredEnUp_branch
    cdef float m3MtToPfMet_UnclusteredEnUp_value

    cdef TBranch* m3MtToPfMet_type1_branch
    cdef float m3MtToPfMet_type1_value

    cdef TBranch* m3MuonHits_branch
    cdef float m3MuonHits_value

    cdef TBranch* m3NearestZMass_branch
    cdef float m3NearestZMass_value

    cdef TBranch* m3NormTrkChi2_branch
    cdef float m3NormTrkChi2_value

    cdef TBranch* m3PFChargedIso_branch
    cdef float m3PFChargedIso_value

    cdef TBranch* m3PFIDLoose_branch
    cdef float m3PFIDLoose_value

    cdef TBranch* m3PFIDMedium_branch
    cdef float m3PFIDMedium_value

    cdef TBranch* m3PFIDTight_branch
    cdef float m3PFIDTight_value

    cdef TBranch* m3PFNeutralIso_branch
    cdef float m3PFNeutralIso_value

    cdef TBranch* m3PFPUChargedIso_branch
    cdef float m3PFPUChargedIso_value

    cdef TBranch* m3PFPhotonIso_branch
    cdef float m3PFPhotonIso_value

    cdef TBranch* m3PVDXY_branch
    cdef float m3PVDXY_value

    cdef TBranch* m3PVDZ_branch
    cdef float m3PVDZ_value

    cdef TBranch* m3Phi_branch
    cdef float m3Phi_value

    cdef TBranch* m3Phi_MuonEnDown_branch
    cdef float m3Phi_MuonEnDown_value

    cdef TBranch* m3Phi_MuonEnUp_branch
    cdef float m3Phi_MuonEnUp_value

    cdef TBranch* m3PixHits_branch
    cdef float m3PixHits_value

    cdef TBranch* m3Pt_branch
    cdef float m3Pt_value

    cdef TBranch* m3Pt_MuonEnDown_branch
    cdef float m3Pt_MuonEnDown_value

    cdef TBranch* m3Pt_MuonEnUp_branch
    cdef float m3Pt_MuonEnUp_value

    cdef TBranch* m3Rank_branch
    cdef float m3Rank_value

    cdef TBranch* m3RelPFIsoDBDefault_branch
    cdef float m3RelPFIsoDBDefault_value

    cdef TBranch* m3RelPFIsoRho_branch
    cdef float m3RelPFIsoRho_value

    cdef TBranch* m3Rho_branch
    cdef float m3Rho_value

    cdef TBranch* m3SIP2D_branch
    cdef float m3SIP2D_value

    cdef TBranch* m3SIP3D_branch
    cdef float m3SIP3D_value

    cdef TBranch* m3TkLayersWithMeasurement_branch
    cdef float m3TkLayersWithMeasurement_value

    cdef TBranch* m3TrkIsoDR03_branch
    cdef float m3TrkIsoDR03_value

    cdef TBranch* m3TypeCode_branch
    cdef int m3TypeCode_value

    cdef TBranch* m3VZ_branch
    cdef float m3VZ_value

    cdef TBranch* m3_m1_collinearmass_branch
    cdef float m3_m1_collinearmass_value

    cdef TBranch* m3_m1_collinearmass_JetEnDown_branch
    cdef float m3_m1_collinearmass_JetEnDown_value

    cdef TBranch* m3_m1_collinearmass_JetEnUp_branch
    cdef float m3_m1_collinearmass_JetEnUp_value

    cdef TBranch* m3_m1_collinearmass_UnclusteredEnDown_branch
    cdef float m3_m1_collinearmass_UnclusteredEnDown_value

    cdef TBranch* m3_m1_collinearmass_UnclusteredEnUp_branch
    cdef float m3_m1_collinearmass_UnclusteredEnUp_value

    cdef TBranch* m3_m2_collinearmass_branch
    cdef float m3_m2_collinearmass_value

    cdef TBranch* m3_m2_collinearmass_JetEnDown_branch
    cdef float m3_m2_collinearmass_JetEnDown_value

    cdef TBranch* m3_m2_collinearmass_JetEnUp_branch
    cdef float m3_m2_collinearmass_JetEnUp_value

    cdef TBranch* m3_m2_collinearmass_UnclusteredEnDown_branch
    cdef float m3_m2_collinearmass_UnclusteredEnDown_value

    cdef TBranch* m3_m2_collinearmass_UnclusteredEnUp_branch
    cdef float m3_m2_collinearmass_UnclusteredEnUp_value

    cdef TBranch* muGlbIsoVetoPt10_branch
    cdef float muGlbIsoVetoPt10_value

    cdef TBranch* muVetoPt15IsoIdVtx_branch
    cdef float muVetoPt15IsoIdVtx_value

    cdef TBranch* muVetoPt5_branch
    cdef float muVetoPt5_value

    cdef TBranch* muVetoPt5IsoIdVtx_branch
    cdef float muVetoPt5IsoIdVtx_value

    cdef TBranch* nTruePU_branch
    cdef float nTruePU_value

    cdef TBranch* nvtx_branch
    cdef float nvtx_value

    cdef TBranch* processID_branch
    cdef float processID_value

    cdef TBranch* pvChi2_branch
    cdef float pvChi2_value

    cdef TBranch* pvDX_branch
    cdef float pvDX_value

    cdef TBranch* pvDY_branch
    cdef float pvDY_value

    cdef TBranch* pvDZ_branch
    cdef float pvDZ_value

    cdef TBranch* pvIsFake_branch
    cdef int pvIsFake_value

    cdef TBranch* pvIsValid_branch
    cdef int pvIsValid_value

    cdef TBranch* pvNormChi2_branch
    cdef float pvNormChi2_value

    cdef TBranch* pvRho_branch
    cdef float pvRho_value

    cdef TBranch* pvX_branch
    cdef float pvX_value

    cdef TBranch* pvY_branch
    cdef float pvY_value

    cdef TBranch* pvZ_branch
    cdef float pvZ_value

    cdef TBranch* pvndof_branch
    cdef float pvndof_value

    cdef TBranch* raw_pfMetEt_branch
    cdef float raw_pfMetEt_value

    cdef TBranch* raw_pfMetPhi_branch
    cdef float raw_pfMetPhi_value

    cdef TBranch* recoilDaught_branch
    cdef float recoilDaught_value

    cdef TBranch* recoilWithMet_branch
    cdef float recoilWithMet_value

    cdef TBranch* rho_branch
    cdef float rho_value

    cdef TBranch* run_branch
    cdef int run_value

    cdef TBranch* singleE17SingleMu8Group_branch
    cdef float singleE17SingleMu8Group_value

    cdef TBranch* singleE17SingleMu8Pass_branch
    cdef float singleE17SingleMu8Pass_value

    cdef TBranch* singleE17SingleMu8Prescale_branch
    cdef float singleE17SingleMu8Prescale_value

    cdef TBranch* singleE22WP75Group_branch
    cdef float singleE22WP75Group_value

    cdef TBranch* singleE22WP75Pass_branch
    cdef float singleE22WP75Pass_value

    cdef TBranch* singleE22WP75Prescale_branch
    cdef float singleE22WP75Prescale_value

    cdef TBranch* singleE22eta2p1LooseGroup_branch
    cdef float singleE22eta2p1LooseGroup_value

    cdef TBranch* singleE22eta2p1LoosePass_branch
    cdef float singleE22eta2p1LoosePass_value

    cdef TBranch* singleE22eta2p1LoosePrescale_branch
    cdef float singleE22eta2p1LoosePrescale_value

    cdef TBranch* singleE23SingleMu8Group_branch
    cdef float singleE23SingleMu8Group_value

    cdef TBranch* singleE23SingleMu8Pass_branch
    cdef float singleE23SingleMu8Pass_value

    cdef TBranch* singleE23SingleMu8Prescale_branch
    cdef float singleE23SingleMu8Prescale_value

    cdef TBranch* singleE23WP75Group_branch
    cdef float singleE23WP75Group_value

    cdef TBranch* singleE23WP75Pass_branch
    cdef float singleE23WP75Pass_value

    cdef TBranch* singleE23WP75Prescale_branch
    cdef float singleE23WP75Prescale_value

    cdef TBranch* singleEGroup_branch
    cdef float singleEGroup_value

    cdef TBranch* singleEPass_branch
    cdef float singleEPass_value

    cdef TBranch* singleEPrescale_branch
    cdef float singleEPrescale_value

    cdef TBranch* singleESingleMuGroup_branch
    cdef float singleESingleMuGroup_value

    cdef TBranch* singleESingleMuPass_branch
    cdef float singleESingleMuPass_value

    cdef TBranch* singleESingleMuPrescale_branch
    cdef float singleESingleMuPrescale_value

    cdef TBranch* singleE_leg1Group_branch
    cdef float singleE_leg1Group_value

    cdef TBranch* singleE_leg1Pass_branch
    cdef float singleE_leg1Pass_value

    cdef TBranch* singleE_leg1Prescale_branch
    cdef float singleE_leg1Prescale_value

    cdef TBranch* singleE_leg2Group_branch
    cdef float singleE_leg2Group_value

    cdef TBranch* singleE_leg2Pass_branch
    cdef float singleE_leg2Pass_value

    cdef TBranch* singleE_leg2Prescale_branch
    cdef float singleE_leg2Prescale_value

    cdef TBranch* singleIsoMu17eta2p1Group_branch
    cdef float singleIsoMu17eta2p1Group_value

    cdef TBranch* singleIsoMu17eta2p1Pass_branch
    cdef float singleIsoMu17eta2p1Pass_value

    cdef TBranch* singleIsoMu17eta2p1Prescale_branch
    cdef float singleIsoMu17eta2p1Prescale_value

    cdef TBranch* singleIsoMu20Group_branch
    cdef float singleIsoMu20Group_value

    cdef TBranch* singleIsoMu20Pass_branch
    cdef float singleIsoMu20Pass_value

    cdef TBranch* singleIsoMu20Prescale_branch
    cdef float singleIsoMu20Prescale_value

    cdef TBranch* singleIsoMu20eta2p1Group_branch
    cdef float singleIsoMu20eta2p1Group_value

    cdef TBranch* singleIsoMu20eta2p1Pass_branch
    cdef float singleIsoMu20eta2p1Pass_value

    cdef TBranch* singleIsoMu20eta2p1Prescale_branch
    cdef float singleIsoMu20eta2p1Prescale_value

    cdef TBranch* singleIsoMu24Group_branch
    cdef float singleIsoMu24Group_value

    cdef TBranch* singleIsoMu24Pass_branch
    cdef float singleIsoMu24Pass_value

    cdef TBranch* singleIsoMu24Prescale_branch
    cdef float singleIsoMu24Prescale_value

    cdef TBranch* singleIsoMu24eta2p1Group_branch
    cdef float singleIsoMu24eta2p1Group_value

    cdef TBranch* singleIsoMu24eta2p1Pass_branch
    cdef float singleIsoMu24eta2p1Pass_value

    cdef TBranch* singleIsoMu24eta2p1Prescale_branch
    cdef float singleIsoMu24eta2p1Prescale_value

    cdef TBranch* singleIsoTkMu20Group_branch
    cdef float singleIsoTkMu20Group_value

    cdef TBranch* singleIsoTkMu20Pass_branch
    cdef float singleIsoTkMu20Pass_value

    cdef TBranch* singleIsoTkMu20Prescale_branch
    cdef float singleIsoTkMu20Prescale_value

    cdef TBranch* singleMu17SingleE12Group_branch
    cdef float singleMu17SingleE12Group_value

    cdef TBranch* singleMu17SingleE12Pass_branch
    cdef float singleMu17SingleE12Pass_value

    cdef TBranch* singleMu17SingleE12Prescale_branch
    cdef float singleMu17SingleE12Prescale_value

    cdef TBranch* singleMu23SingleE12Group_branch
    cdef float singleMu23SingleE12Group_value

    cdef TBranch* singleMu23SingleE12Pass_branch
    cdef float singleMu23SingleE12Pass_value

    cdef TBranch* singleMu23SingleE12Prescale_branch
    cdef float singleMu23SingleE12Prescale_value

    cdef TBranch* singleMuGroup_branch
    cdef float singleMuGroup_value

    cdef TBranch* singleMuPass_branch
    cdef float singleMuPass_value

    cdef TBranch* singleMuPrescale_branch
    cdef float singleMuPrescale_value

    cdef TBranch* singleMuSingleEGroup_branch
    cdef float singleMuSingleEGroup_value

    cdef TBranch* singleMuSingleEPass_branch
    cdef float singleMuSingleEPass_value

    cdef TBranch* singleMuSingleEPrescale_branch
    cdef float singleMuSingleEPrescale_value

    cdef TBranch* singleMu_leg1Group_branch
    cdef float singleMu_leg1Group_value

    cdef TBranch* singleMu_leg1Pass_branch
    cdef float singleMu_leg1Pass_value

    cdef TBranch* singleMu_leg1Prescale_branch
    cdef float singleMu_leg1Prescale_value

    cdef TBranch* singleMu_leg1_noisoGroup_branch
    cdef float singleMu_leg1_noisoGroup_value

    cdef TBranch* singleMu_leg1_noisoPass_branch
    cdef float singleMu_leg1_noisoPass_value

    cdef TBranch* singleMu_leg1_noisoPrescale_branch
    cdef float singleMu_leg1_noisoPrescale_value

    cdef TBranch* singleMu_leg2Group_branch
    cdef float singleMu_leg2Group_value

    cdef TBranch* singleMu_leg2Pass_branch
    cdef float singleMu_leg2Pass_value

    cdef TBranch* singleMu_leg2Prescale_branch
    cdef float singleMu_leg2Prescale_value

    cdef TBranch* singleMu_leg2_noisoGroup_branch
    cdef float singleMu_leg2_noisoGroup_value

    cdef TBranch* singleMu_leg2_noisoPass_branch
    cdef float singleMu_leg2_noisoPass_value

    cdef TBranch* singleMu_leg2_noisoPrescale_branch
    cdef float singleMu_leg2_noisoPrescale_value

    cdef TBranch* tauVetoPt20Loose3HitsNewDMVtx_branch
    cdef float tauVetoPt20Loose3HitsNewDMVtx_value

    cdef TBranch* tauVetoPt20Loose3HitsVtx_branch
    cdef float tauVetoPt20Loose3HitsVtx_value

    cdef TBranch* tauVetoPt20TightMVALTNewDMVtx_branch
    cdef float tauVetoPt20TightMVALTNewDMVtx_value

    cdef TBranch* tauVetoPt20TightMVALTVtx_branch
    cdef float tauVetoPt20TightMVALTVtx_value

    cdef TBranch* tripleEGroup_branch
    cdef float tripleEGroup_value

    cdef TBranch* tripleEPass_branch
    cdef float tripleEPass_value

    cdef TBranch* tripleEPrescale_branch
    cdef float tripleEPrescale_value

    cdef TBranch* tripleMuGroup_branch
    cdef float tripleMuGroup_value

    cdef TBranch* tripleMuPass_branch
    cdef float tripleMuPass_value

    cdef TBranch* tripleMuPrescale_branch
    cdef float tripleMuPrescale_value

    cdef TBranch* type1_pfMetEt_branch
    cdef float type1_pfMetEt_value

    cdef TBranch* type1_pfMetPhi_branch
    cdef float type1_pfMetPhi_value

    cdef TBranch* type1_pfMet_shiftedPhi_ElectronEnDown_branch
    cdef float type1_pfMet_shiftedPhi_ElectronEnDown_value

    cdef TBranch* type1_pfMet_shiftedPhi_ElectronEnUp_branch
    cdef float type1_pfMet_shiftedPhi_ElectronEnUp_value

    cdef TBranch* type1_pfMet_shiftedPhi_JetEnDown_branch
    cdef float type1_pfMet_shiftedPhi_JetEnDown_value

    cdef TBranch* type1_pfMet_shiftedPhi_JetEnUp_branch
    cdef float type1_pfMet_shiftedPhi_JetEnUp_value

    cdef TBranch* type1_pfMet_shiftedPhi_JetResDown_branch
    cdef float type1_pfMet_shiftedPhi_JetResDown_value

    cdef TBranch* type1_pfMet_shiftedPhi_JetResUp_branch
    cdef float type1_pfMet_shiftedPhi_JetResUp_value

    cdef TBranch* type1_pfMet_shiftedPhi_MuonEnDown_branch
    cdef float type1_pfMet_shiftedPhi_MuonEnDown_value

    cdef TBranch* type1_pfMet_shiftedPhi_MuonEnUp_branch
    cdef float type1_pfMet_shiftedPhi_MuonEnUp_value

    cdef TBranch* type1_pfMet_shiftedPhi_PhotonEnDown_branch
    cdef float type1_pfMet_shiftedPhi_PhotonEnDown_value

    cdef TBranch* type1_pfMet_shiftedPhi_PhotonEnUp_branch
    cdef float type1_pfMet_shiftedPhi_PhotonEnUp_value

    cdef TBranch* type1_pfMet_shiftedPhi_TauEnDown_branch
    cdef float type1_pfMet_shiftedPhi_TauEnDown_value

    cdef TBranch* type1_pfMet_shiftedPhi_TauEnUp_branch
    cdef float type1_pfMet_shiftedPhi_TauEnUp_value

    cdef TBranch* type1_pfMet_shiftedPhi_UnclusteredEnDown_branch
    cdef float type1_pfMet_shiftedPhi_UnclusteredEnDown_value

    cdef TBranch* type1_pfMet_shiftedPhi_UnclusteredEnUp_branch
    cdef float type1_pfMet_shiftedPhi_UnclusteredEnUp_value

    cdef TBranch* type1_pfMet_shiftedPt_ElectronEnDown_branch
    cdef float type1_pfMet_shiftedPt_ElectronEnDown_value

    cdef TBranch* type1_pfMet_shiftedPt_ElectronEnUp_branch
    cdef float type1_pfMet_shiftedPt_ElectronEnUp_value

    cdef TBranch* type1_pfMet_shiftedPt_JetEnDown_branch
    cdef float type1_pfMet_shiftedPt_JetEnDown_value

    cdef TBranch* type1_pfMet_shiftedPt_JetEnUp_branch
    cdef float type1_pfMet_shiftedPt_JetEnUp_value

    cdef TBranch* type1_pfMet_shiftedPt_JetResDown_branch
    cdef float type1_pfMet_shiftedPt_JetResDown_value

    cdef TBranch* type1_pfMet_shiftedPt_JetResUp_branch
    cdef float type1_pfMet_shiftedPt_JetResUp_value

    cdef TBranch* type1_pfMet_shiftedPt_MuonEnDown_branch
    cdef float type1_pfMet_shiftedPt_MuonEnDown_value

    cdef TBranch* type1_pfMet_shiftedPt_MuonEnUp_branch
    cdef float type1_pfMet_shiftedPt_MuonEnUp_value

    cdef TBranch* type1_pfMet_shiftedPt_PhotonEnDown_branch
    cdef float type1_pfMet_shiftedPt_PhotonEnDown_value

    cdef TBranch* type1_pfMet_shiftedPt_PhotonEnUp_branch
    cdef float type1_pfMet_shiftedPt_PhotonEnUp_value

    cdef TBranch* type1_pfMet_shiftedPt_TauEnDown_branch
    cdef float type1_pfMet_shiftedPt_TauEnDown_value

    cdef TBranch* type1_pfMet_shiftedPt_TauEnUp_branch
    cdef float type1_pfMet_shiftedPt_TauEnUp_value

    cdef TBranch* type1_pfMet_shiftedPt_UnclusteredEnDown_branch
    cdef float type1_pfMet_shiftedPt_UnclusteredEnDown_value

    cdef TBranch* type1_pfMet_shiftedPt_UnclusteredEnUp_branch
    cdef float type1_pfMet_shiftedPt_UnclusteredEnUp_value

    cdef TBranch* vbfDeta_branch
    cdef float vbfDeta_value

    cdef TBranch* vbfDeta_JetEnDown_branch
    cdef float vbfDeta_JetEnDown_value

    cdef TBranch* vbfDeta_JetEnUp_branch
    cdef float vbfDeta_JetEnUp_value

    cdef TBranch* vbfDijetrap_branch
    cdef float vbfDijetrap_value

    cdef TBranch* vbfDijetrap_JetEnDown_branch
    cdef float vbfDijetrap_JetEnDown_value

    cdef TBranch* vbfDijetrap_JetEnUp_branch
    cdef float vbfDijetrap_JetEnUp_value

    cdef TBranch* vbfDphi_branch
    cdef float vbfDphi_value

    cdef TBranch* vbfDphi_JetEnDown_branch
    cdef float vbfDphi_JetEnDown_value

    cdef TBranch* vbfDphi_JetEnUp_branch
    cdef float vbfDphi_JetEnUp_value

    cdef TBranch* vbfDphihj_branch
    cdef float vbfDphihj_value

    cdef TBranch* vbfDphihj_JetEnDown_branch
    cdef float vbfDphihj_JetEnDown_value

    cdef TBranch* vbfDphihj_JetEnUp_branch
    cdef float vbfDphihj_JetEnUp_value

    cdef TBranch* vbfDphihjnomet_branch
    cdef float vbfDphihjnomet_value

    cdef TBranch* vbfDphihjnomet_JetEnDown_branch
    cdef float vbfDphihjnomet_JetEnDown_value

    cdef TBranch* vbfDphihjnomet_JetEnUp_branch
    cdef float vbfDphihjnomet_JetEnUp_value

    cdef TBranch* vbfHrap_branch
    cdef float vbfHrap_value

    cdef TBranch* vbfHrap_JetEnDown_branch
    cdef float vbfHrap_JetEnDown_value

    cdef TBranch* vbfHrap_JetEnUp_branch
    cdef float vbfHrap_JetEnUp_value

    cdef TBranch* vbfJetVeto20_branch
    cdef float vbfJetVeto20_value

    cdef TBranch* vbfJetVeto20_JetEnDown_branch
    cdef float vbfJetVeto20_JetEnDown_value

    cdef TBranch* vbfJetVeto20_JetEnUp_branch
    cdef float vbfJetVeto20_JetEnUp_value

    cdef TBranch* vbfJetVeto30_branch
    cdef float vbfJetVeto30_value

    cdef TBranch* vbfJetVeto30_JetEnDown_branch
    cdef float vbfJetVeto30_JetEnDown_value

    cdef TBranch* vbfJetVeto30_JetEnUp_branch
    cdef float vbfJetVeto30_JetEnUp_value

    cdef TBranch* vbfJetVetoTight20_branch
    cdef float vbfJetVetoTight20_value

    cdef TBranch* vbfJetVetoTight20_JetEnDown_branch
    cdef float vbfJetVetoTight20_JetEnDown_value

    cdef TBranch* vbfJetVetoTight20_JetEnUp_branch
    cdef float vbfJetVetoTight20_JetEnUp_value

    cdef TBranch* vbfJetVetoTight30_branch
    cdef float vbfJetVetoTight30_value

    cdef TBranch* vbfJetVetoTight30_JetEnDown_branch
    cdef float vbfJetVetoTight30_JetEnDown_value

    cdef TBranch* vbfJetVetoTight30_JetEnUp_branch
    cdef float vbfJetVetoTight30_JetEnUp_value

    cdef TBranch* vbfMVA_branch
    cdef float vbfMVA_value

    cdef TBranch* vbfMVA_JetEnDown_branch
    cdef float vbfMVA_JetEnDown_value

    cdef TBranch* vbfMVA_JetEnUp_branch
    cdef float vbfMVA_JetEnUp_value

    cdef TBranch* vbfMass_branch
    cdef float vbfMass_value

    cdef TBranch* vbfMass_JetEnDown_branch
    cdef float vbfMass_JetEnDown_value

    cdef TBranch* vbfMass_JetEnUp_branch
    cdef float vbfMass_JetEnUp_value

    cdef TBranch* vbfNJets_branch
    cdef float vbfNJets_value

    cdef TBranch* vbfNJets_JetEnDown_branch
    cdef float vbfNJets_JetEnDown_value

    cdef TBranch* vbfNJets_JetEnUp_branch
    cdef float vbfNJets_JetEnUp_value

    cdef TBranch* vbfVispt_branch
    cdef float vbfVispt_value

    cdef TBranch* vbfVispt_JetEnDown_branch
    cdef float vbfVispt_JetEnDown_value

    cdef TBranch* vbfVispt_JetEnUp_branch
    cdef float vbfVispt_JetEnUp_value

    cdef TBranch* vbfdijetpt_branch
    cdef float vbfdijetpt_value

    cdef TBranch* vbfdijetpt_JetEnDown_branch
    cdef float vbfdijetpt_JetEnDown_value

    cdef TBranch* vbfdijetpt_JetEnUp_branch
    cdef float vbfdijetpt_JetEnUp_value

    cdef TBranch* vbfditaupt_branch
    cdef float vbfditaupt_value

    cdef TBranch* vbfditaupt_JetEnDown_branch
    cdef float vbfditaupt_JetEnDown_value

    cdef TBranch* vbfditaupt_JetEnUp_branch
    cdef float vbfditaupt_JetEnUp_value

    cdef TBranch* vbfj1eta_branch
    cdef float vbfj1eta_value

    cdef TBranch* vbfj1eta_JetEnDown_branch
    cdef float vbfj1eta_JetEnDown_value

    cdef TBranch* vbfj1eta_JetEnUp_branch
    cdef float vbfj1eta_JetEnUp_value

    cdef TBranch* vbfj1pt_branch
    cdef float vbfj1pt_value

    cdef TBranch* vbfj1pt_JetEnDown_branch
    cdef float vbfj1pt_JetEnDown_value

    cdef TBranch* vbfj1pt_JetEnUp_branch
    cdef float vbfj1pt_JetEnUp_value

    cdef TBranch* vbfj2eta_branch
    cdef float vbfj2eta_value

    cdef TBranch* vbfj2eta_JetEnDown_branch
    cdef float vbfj2eta_JetEnDown_value

    cdef TBranch* vbfj2eta_JetEnUp_branch
    cdef float vbfj2eta_JetEnUp_value

    cdef TBranch* vbfj2pt_branch
    cdef float vbfj2pt_value

    cdef TBranch* vbfj2pt_JetEnDown_branch
    cdef float vbfj2pt_JetEnDown_value

    cdef TBranch* vbfj2pt_JetEnUp_branch
    cdef float vbfj2pt_JetEnUp_value

    cdef TBranch* idx_branch
    cdef int idx_value


    def __cinit__(self, ttree):
        #print "cinit"
        # Constructor from a ROOT.TTree
        from ROOT import AsCObject
        self.tree = <TTree*>PyCObject_AsVoidPtr(AsCObject(ttree))
        self.ientry = 0
        self.currentTreeNumber = -1
        #print self.tree.GetEntries()
        #self.load_entry(0)
        self.complained = set([])

    cdef load_entry(self, long i):
        #print "load", i
        # Load the correct tree and setup the branches
        self.localentry = self.tree.LoadTree(i)
        #print "local", self.localentry
        new_tree = self.tree.GetTree()
        #print "tree", <long>(new_tree)
        treenum = self.tree.GetTreeNumber()
        #print "num", treenum
        if treenum != self.currentTreeNumber or new_tree != self.currentTree:
            #print "New tree!"
            self.currentTree = new_tree
            self.currentTreeNumber = treenum
            self.setup_branches(new_tree)

    cdef setup_branches(self, TTree* the_tree):
        #print "setup"

        #print "making EmbPtWeight"
        self.EmbPtWeight_branch = the_tree.GetBranch("EmbPtWeight")
        #if not self.EmbPtWeight_branch and "EmbPtWeight" not in self.complained:
        if not self.EmbPtWeight_branch and "EmbPtWeight":
            warnings.warn( "MMMTree: Expected branch EmbPtWeight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("EmbPtWeight")
        else:
            self.EmbPtWeight_branch.SetAddress(<void*>&self.EmbPtWeight_value)

        #print "making Eta"
        self.Eta_branch = the_tree.GetBranch("Eta")
        #if not self.Eta_branch and "Eta" not in self.complained:
        if not self.Eta_branch and "Eta":
            warnings.warn( "MMMTree: Expected branch Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Eta")
        else:
            self.Eta_branch.SetAddress(<void*>&self.Eta_value)

        #print "making GenWeight"
        self.GenWeight_branch = the_tree.GetBranch("GenWeight")
        #if not self.GenWeight_branch and "GenWeight" not in self.complained:
        if not self.GenWeight_branch and "GenWeight":
            warnings.warn( "MMMTree: Expected branch GenWeight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("GenWeight")
        else:
            self.GenWeight_branch.SetAddress(<void*>&self.GenWeight_value)

        #print "making Ht"
        self.Ht_branch = the_tree.GetBranch("Ht")
        #if not self.Ht_branch and "Ht" not in self.complained:
        if not self.Ht_branch and "Ht":
            warnings.warn( "MMMTree: Expected branch Ht does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Ht")
        else:
            self.Ht_branch.SetAddress(<void*>&self.Ht_value)

        #print "making LT"
        self.LT_branch = the_tree.GetBranch("LT")
        #if not self.LT_branch and "LT" not in self.complained:
        if not self.LT_branch and "LT":
            warnings.warn( "MMMTree: Expected branch LT does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("LT")
        else:
            self.LT_branch.SetAddress(<void*>&self.LT_value)

        #print "making Mass"
        self.Mass_branch = the_tree.GetBranch("Mass")
        #if not self.Mass_branch and "Mass" not in self.complained:
        if not self.Mass_branch and "Mass":
            warnings.warn( "MMMTree: Expected branch Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Mass")
        else:
            self.Mass_branch.SetAddress(<void*>&self.Mass_value)

        #print "making MassError"
        self.MassError_branch = the_tree.GetBranch("MassError")
        #if not self.MassError_branch and "MassError" not in self.complained:
        if not self.MassError_branch and "MassError":
            warnings.warn( "MMMTree: Expected branch MassError does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassError")
        else:
            self.MassError_branch.SetAddress(<void*>&self.MassError_value)

        #print "making MassErrord1"
        self.MassErrord1_branch = the_tree.GetBranch("MassErrord1")
        #if not self.MassErrord1_branch and "MassErrord1" not in self.complained:
        if not self.MassErrord1_branch and "MassErrord1":
            warnings.warn( "MMMTree: Expected branch MassErrord1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord1")
        else:
            self.MassErrord1_branch.SetAddress(<void*>&self.MassErrord1_value)

        #print "making MassErrord2"
        self.MassErrord2_branch = the_tree.GetBranch("MassErrord2")
        #if not self.MassErrord2_branch and "MassErrord2" not in self.complained:
        if not self.MassErrord2_branch and "MassErrord2":
            warnings.warn( "MMMTree: Expected branch MassErrord2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord2")
        else:
            self.MassErrord2_branch.SetAddress(<void*>&self.MassErrord2_value)

        #print "making MassErrord3"
        self.MassErrord3_branch = the_tree.GetBranch("MassErrord3")
        #if not self.MassErrord3_branch and "MassErrord3" not in self.complained:
        if not self.MassErrord3_branch and "MassErrord3":
            warnings.warn( "MMMTree: Expected branch MassErrord3 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord3")
        else:
            self.MassErrord3_branch.SetAddress(<void*>&self.MassErrord3_value)

        #print "making MassErrord4"
        self.MassErrord4_branch = the_tree.GetBranch("MassErrord4")
        #if not self.MassErrord4_branch and "MassErrord4" not in self.complained:
        if not self.MassErrord4_branch and "MassErrord4":
            warnings.warn( "MMMTree: Expected branch MassErrord4 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord4")
        else:
            self.MassErrord4_branch.SetAddress(<void*>&self.MassErrord4_value)

        #print "making Mt"
        self.Mt_branch = the_tree.GetBranch("Mt")
        #if not self.Mt_branch and "Mt" not in self.complained:
        if not self.Mt_branch and "Mt":
            warnings.warn( "MMMTree: Expected branch Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Mt")
        else:
            self.Mt_branch.SetAddress(<void*>&self.Mt_value)

        #print "making NUP"
        self.NUP_branch = the_tree.GetBranch("NUP")
        #if not self.NUP_branch and "NUP" not in self.complained:
        if not self.NUP_branch and "NUP":
            warnings.warn( "MMMTree: Expected branch NUP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("NUP")
        else:
            self.NUP_branch.SetAddress(<void*>&self.NUP_value)

        #print "making Phi"
        self.Phi_branch = the_tree.GetBranch("Phi")
        #if not self.Phi_branch and "Phi" not in self.complained:
        if not self.Phi_branch and "Phi":
            warnings.warn( "MMMTree: Expected branch Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Phi")
        else:
            self.Phi_branch.SetAddress(<void*>&self.Phi_value)

        #print "making Pt"
        self.Pt_branch = the_tree.GetBranch("Pt")
        #if not self.Pt_branch and "Pt" not in self.complained:
        if not self.Pt_branch and "Pt":
            warnings.warn( "MMMTree: Expected branch Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Pt")
        else:
            self.Pt_branch.SetAddress(<void*>&self.Pt_value)

        #print "making bjetCISVVeto20Loose"
        self.bjetCISVVeto20Loose_branch = the_tree.GetBranch("bjetCISVVeto20Loose")
        #if not self.bjetCISVVeto20Loose_branch and "bjetCISVVeto20Loose" not in self.complained:
        if not self.bjetCISVVeto20Loose_branch and "bjetCISVVeto20Loose":
            warnings.warn( "MMMTree: Expected branch bjetCISVVeto20Loose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Loose")
        else:
            self.bjetCISVVeto20Loose_branch.SetAddress(<void*>&self.bjetCISVVeto20Loose_value)

        #print "making bjetCISVVeto20Medium"
        self.bjetCISVVeto20Medium_branch = the_tree.GetBranch("bjetCISVVeto20Medium")
        #if not self.bjetCISVVeto20Medium_branch and "bjetCISVVeto20Medium" not in self.complained:
        if not self.bjetCISVVeto20Medium_branch and "bjetCISVVeto20Medium":
            warnings.warn( "MMMTree: Expected branch bjetCISVVeto20Medium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Medium")
        else:
            self.bjetCISVVeto20Medium_branch.SetAddress(<void*>&self.bjetCISVVeto20Medium_value)

        #print "making bjetCISVVeto20Tight"
        self.bjetCISVVeto20Tight_branch = the_tree.GetBranch("bjetCISVVeto20Tight")
        #if not self.bjetCISVVeto20Tight_branch and "bjetCISVVeto20Tight" not in self.complained:
        if not self.bjetCISVVeto20Tight_branch and "bjetCISVVeto20Tight":
            warnings.warn( "MMMTree: Expected branch bjetCISVVeto20Tight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Tight")
        else:
            self.bjetCISVVeto20Tight_branch.SetAddress(<void*>&self.bjetCISVVeto20Tight_value)

        #print "making bjetCISVVeto30Loose"
        self.bjetCISVVeto30Loose_branch = the_tree.GetBranch("bjetCISVVeto30Loose")
        #if not self.bjetCISVVeto30Loose_branch and "bjetCISVVeto30Loose" not in self.complained:
        if not self.bjetCISVVeto30Loose_branch and "bjetCISVVeto30Loose":
            warnings.warn( "MMMTree: Expected branch bjetCISVVeto30Loose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Loose")
        else:
            self.bjetCISVVeto30Loose_branch.SetAddress(<void*>&self.bjetCISVVeto30Loose_value)

        #print "making bjetCISVVeto30Medium"
        self.bjetCISVVeto30Medium_branch = the_tree.GetBranch("bjetCISVVeto30Medium")
        #if not self.bjetCISVVeto30Medium_branch and "bjetCISVVeto30Medium" not in self.complained:
        if not self.bjetCISVVeto30Medium_branch and "bjetCISVVeto30Medium":
            warnings.warn( "MMMTree: Expected branch bjetCISVVeto30Medium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Medium")
        else:
            self.bjetCISVVeto30Medium_branch.SetAddress(<void*>&self.bjetCISVVeto30Medium_value)

        #print "making bjetCISVVeto30Tight"
        self.bjetCISVVeto30Tight_branch = the_tree.GetBranch("bjetCISVVeto30Tight")
        #if not self.bjetCISVVeto30Tight_branch and "bjetCISVVeto30Tight" not in self.complained:
        if not self.bjetCISVVeto30Tight_branch and "bjetCISVVeto30Tight":
            warnings.warn( "MMMTree: Expected branch bjetCISVVeto30Tight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Tight")
        else:
            self.bjetCISVVeto30Tight_branch.SetAddress(<void*>&self.bjetCISVVeto30Tight_value)

        #print "making charge"
        self.charge_branch = the_tree.GetBranch("charge")
        #if not self.charge_branch and "charge" not in self.complained:
        if not self.charge_branch and "charge":
            warnings.warn( "MMMTree: Expected branch charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("charge")
        else:
            self.charge_branch.SetAddress(<void*>&self.charge_value)

        #print "making doubleEGroup"
        self.doubleEGroup_branch = the_tree.GetBranch("doubleEGroup")
        #if not self.doubleEGroup_branch and "doubleEGroup" not in self.complained:
        if not self.doubleEGroup_branch and "doubleEGroup":
            warnings.warn( "MMMTree: Expected branch doubleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEGroup")
        else:
            self.doubleEGroup_branch.SetAddress(<void*>&self.doubleEGroup_value)

        #print "making doubleEPass"
        self.doubleEPass_branch = the_tree.GetBranch("doubleEPass")
        #if not self.doubleEPass_branch and "doubleEPass" not in self.complained:
        if not self.doubleEPass_branch and "doubleEPass":
            warnings.warn( "MMMTree: Expected branch doubleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEPass")
        else:
            self.doubleEPass_branch.SetAddress(<void*>&self.doubleEPass_value)

        #print "making doubleEPrescale"
        self.doubleEPrescale_branch = the_tree.GetBranch("doubleEPrescale")
        #if not self.doubleEPrescale_branch and "doubleEPrescale" not in self.complained:
        if not self.doubleEPrescale_branch and "doubleEPrescale":
            warnings.warn( "MMMTree: Expected branch doubleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEPrescale")
        else:
            self.doubleEPrescale_branch.SetAddress(<void*>&self.doubleEPrescale_value)

        #print "making doubleESingleMuGroup"
        self.doubleESingleMuGroup_branch = the_tree.GetBranch("doubleESingleMuGroup")
        #if not self.doubleESingleMuGroup_branch and "doubleESingleMuGroup" not in self.complained:
        if not self.doubleESingleMuGroup_branch and "doubleESingleMuGroup":
            warnings.warn( "MMMTree: Expected branch doubleESingleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuGroup")
        else:
            self.doubleESingleMuGroup_branch.SetAddress(<void*>&self.doubleESingleMuGroup_value)

        #print "making doubleESingleMuPass"
        self.doubleESingleMuPass_branch = the_tree.GetBranch("doubleESingleMuPass")
        #if not self.doubleESingleMuPass_branch and "doubleESingleMuPass" not in self.complained:
        if not self.doubleESingleMuPass_branch and "doubleESingleMuPass":
            warnings.warn( "MMMTree: Expected branch doubleESingleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuPass")
        else:
            self.doubleESingleMuPass_branch.SetAddress(<void*>&self.doubleESingleMuPass_value)

        #print "making doubleESingleMuPrescale"
        self.doubleESingleMuPrescale_branch = the_tree.GetBranch("doubleESingleMuPrescale")
        #if not self.doubleESingleMuPrescale_branch and "doubleESingleMuPrescale" not in self.complained:
        if not self.doubleESingleMuPrescale_branch and "doubleESingleMuPrescale":
            warnings.warn( "MMMTree: Expected branch doubleESingleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuPrescale")
        else:
            self.doubleESingleMuPrescale_branch.SetAddress(<void*>&self.doubleESingleMuPrescale_value)

        #print "making doubleMuGroup"
        self.doubleMuGroup_branch = the_tree.GetBranch("doubleMuGroup")
        #if not self.doubleMuGroup_branch and "doubleMuGroup" not in self.complained:
        if not self.doubleMuGroup_branch and "doubleMuGroup":
            warnings.warn( "MMMTree: Expected branch doubleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuGroup")
        else:
            self.doubleMuGroup_branch.SetAddress(<void*>&self.doubleMuGroup_value)

        #print "making doubleMuPass"
        self.doubleMuPass_branch = the_tree.GetBranch("doubleMuPass")
        #if not self.doubleMuPass_branch and "doubleMuPass" not in self.complained:
        if not self.doubleMuPass_branch and "doubleMuPass":
            warnings.warn( "MMMTree: Expected branch doubleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuPass")
        else:
            self.doubleMuPass_branch.SetAddress(<void*>&self.doubleMuPass_value)

        #print "making doubleMuPrescale"
        self.doubleMuPrescale_branch = the_tree.GetBranch("doubleMuPrescale")
        #if not self.doubleMuPrescale_branch and "doubleMuPrescale" not in self.complained:
        if not self.doubleMuPrescale_branch and "doubleMuPrescale":
            warnings.warn( "MMMTree: Expected branch doubleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuPrescale")
        else:
            self.doubleMuPrescale_branch.SetAddress(<void*>&self.doubleMuPrescale_value)

        #print "making doubleMuSingleEGroup"
        self.doubleMuSingleEGroup_branch = the_tree.GetBranch("doubleMuSingleEGroup")
        #if not self.doubleMuSingleEGroup_branch and "doubleMuSingleEGroup" not in self.complained:
        if not self.doubleMuSingleEGroup_branch and "doubleMuSingleEGroup":
            warnings.warn( "MMMTree: Expected branch doubleMuSingleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEGroup")
        else:
            self.doubleMuSingleEGroup_branch.SetAddress(<void*>&self.doubleMuSingleEGroup_value)

        #print "making doubleMuSingleEPass"
        self.doubleMuSingleEPass_branch = the_tree.GetBranch("doubleMuSingleEPass")
        #if not self.doubleMuSingleEPass_branch and "doubleMuSingleEPass" not in self.complained:
        if not self.doubleMuSingleEPass_branch and "doubleMuSingleEPass":
            warnings.warn( "MMMTree: Expected branch doubleMuSingleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEPass")
        else:
            self.doubleMuSingleEPass_branch.SetAddress(<void*>&self.doubleMuSingleEPass_value)

        #print "making doubleMuSingleEPrescale"
        self.doubleMuSingleEPrescale_branch = the_tree.GetBranch("doubleMuSingleEPrescale")
        #if not self.doubleMuSingleEPrescale_branch and "doubleMuSingleEPrescale" not in self.complained:
        if not self.doubleMuSingleEPrescale_branch and "doubleMuSingleEPrescale":
            warnings.warn( "MMMTree: Expected branch doubleMuSingleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEPrescale")
        else:
            self.doubleMuSingleEPrescale_branch.SetAddress(<void*>&self.doubleMuSingleEPrescale_value)

        #print "making doubleTau35Group"
        self.doubleTau35Group_branch = the_tree.GetBranch("doubleTau35Group")
        #if not self.doubleTau35Group_branch and "doubleTau35Group" not in self.complained:
        if not self.doubleTau35Group_branch and "doubleTau35Group":
            warnings.warn( "MMMTree: Expected branch doubleTau35Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Group")
        else:
            self.doubleTau35Group_branch.SetAddress(<void*>&self.doubleTau35Group_value)

        #print "making doubleTau35Pass"
        self.doubleTau35Pass_branch = the_tree.GetBranch("doubleTau35Pass")
        #if not self.doubleTau35Pass_branch and "doubleTau35Pass" not in self.complained:
        if not self.doubleTau35Pass_branch and "doubleTau35Pass":
            warnings.warn( "MMMTree: Expected branch doubleTau35Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Pass")
        else:
            self.doubleTau35Pass_branch.SetAddress(<void*>&self.doubleTau35Pass_value)

        #print "making doubleTau35Prescale"
        self.doubleTau35Prescale_branch = the_tree.GetBranch("doubleTau35Prescale")
        #if not self.doubleTau35Prescale_branch and "doubleTau35Prescale" not in self.complained:
        if not self.doubleTau35Prescale_branch and "doubleTau35Prescale":
            warnings.warn( "MMMTree: Expected branch doubleTau35Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Prescale")
        else:
            self.doubleTau35Prescale_branch.SetAddress(<void*>&self.doubleTau35Prescale_value)

        #print "making doubleTau40Group"
        self.doubleTau40Group_branch = the_tree.GetBranch("doubleTau40Group")
        #if not self.doubleTau40Group_branch and "doubleTau40Group" not in self.complained:
        if not self.doubleTau40Group_branch and "doubleTau40Group":
            warnings.warn( "MMMTree: Expected branch doubleTau40Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Group")
        else:
            self.doubleTau40Group_branch.SetAddress(<void*>&self.doubleTau40Group_value)

        #print "making doubleTau40Pass"
        self.doubleTau40Pass_branch = the_tree.GetBranch("doubleTau40Pass")
        #if not self.doubleTau40Pass_branch and "doubleTau40Pass" not in self.complained:
        if not self.doubleTau40Pass_branch and "doubleTau40Pass":
            warnings.warn( "MMMTree: Expected branch doubleTau40Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Pass")
        else:
            self.doubleTau40Pass_branch.SetAddress(<void*>&self.doubleTau40Pass_value)

        #print "making doubleTau40Prescale"
        self.doubleTau40Prescale_branch = the_tree.GetBranch("doubleTau40Prescale")
        #if not self.doubleTau40Prescale_branch and "doubleTau40Prescale" not in self.complained:
        if not self.doubleTau40Prescale_branch and "doubleTau40Prescale":
            warnings.warn( "MMMTree: Expected branch doubleTau40Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Prescale")
        else:
            self.doubleTau40Prescale_branch.SetAddress(<void*>&self.doubleTau40Prescale_value)

        #print "making eVetoMVAIso"
        self.eVetoMVAIso_branch = the_tree.GetBranch("eVetoMVAIso")
        #if not self.eVetoMVAIso_branch and "eVetoMVAIso" not in self.complained:
        if not self.eVetoMVAIso_branch and "eVetoMVAIso":
            warnings.warn( "MMMTree: Expected branch eVetoMVAIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eVetoMVAIso")
        else:
            self.eVetoMVAIso_branch.SetAddress(<void*>&self.eVetoMVAIso_value)

        #print "making eVetoMVAIsoVtx"
        self.eVetoMVAIsoVtx_branch = the_tree.GetBranch("eVetoMVAIsoVtx")
        #if not self.eVetoMVAIsoVtx_branch and "eVetoMVAIsoVtx" not in self.complained:
        if not self.eVetoMVAIsoVtx_branch and "eVetoMVAIsoVtx":
            warnings.warn( "MMMTree: Expected branch eVetoMVAIsoVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eVetoMVAIsoVtx")
        else:
            self.eVetoMVAIsoVtx_branch.SetAddress(<void*>&self.eVetoMVAIsoVtx_value)

        #print "making evt"
        self.evt_branch = the_tree.GetBranch("evt")
        #if not self.evt_branch and "evt" not in self.complained:
        if not self.evt_branch and "evt":
            warnings.warn( "MMMTree: Expected branch evt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("evt")
        else:
            self.evt_branch.SetAddress(<void*>&self.evt_value)

        #print "making genHTT"
        self.genHTT_branch = the_tree.GetBranch("genHTT")
        #if not self.genHTT_branch and "genHTT" not in self.complained:
        if not self.genHTT_branch and "genHTT":
            warnings.warn( "MMMTree: Expected branch genHTT does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("genHTT")
        else:
            self.genHTT_branch.SetAddress(<void*>&self.genHTT_value)

        #print "making isGtautau"
        self.isGtautau_branch = the_tree.GetBranch("isGtautau")
        #if not self.isGtautau_branch and "isGtautau" not in self.complained:
        if not self.isGtautau_branch and "isGtautau":
            warnings.warn( "MMMTree: Expected branch isGtautau does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isGtautau")
        else:
            self.isGtautau_branch.SetAddress(<void*>&self.isGtautau_value)

        #print "making isWmunu"
        self.isWmunu_branch = the_tree.GetBranch("isWmunu")
        #if not self.isWmunu_branch and "isWmunu" not in self.complained:
        if not self.isWmunu_branch and "isWmunu":
            warnings.warn( "MMMTree: Expected branch isWmunu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isWmunu")
        else:
            self.isWmunu_branch.SetAddress(<void*>&self.isWmunu_value)

        #print "making isWtaunu"
        self.isWtaunu_branch = the_tree.GetBranch("isWtaunu")
        #if not self.isWtaunu_branch and "isWtaunu" not in self.complained:
        if not self.isWtaunu_branch and "isWtaunu":
            warnings.warn( "MMMTree: Expected branch isWtaunu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isWtaunu")
        else:
            self.isWtaunu_branch.SetAddress(<void*>&self.isWtaunu_value)

        #print "making isZee"
        self.isZee_branch = the_tree.GetBranch("isZee")
        #if not self.isZee_branch and "isZee" not in self.complained:
        if not self.isZee_branch and "isZee":
            warnings.warn( "MMMTree: Expected branch isZee does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZee")
        else:
            self.isZee_branch.SetAddress(<void*>&self.isZee_value)

        #print "making isZmumu"
        self.isZmumu_branch = the_tree.GetBranch("isZmumu")
        #if not self.isZmumu_branch and "isZmumu" not in self.complained:
        if not self.isZmumu_branch and "isZmumu":
            warnings.warn( "MMMTree: Expected branch isZmumu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZmumu")
        else:
            self.isZmumu_branch.SetAddress(<void*>&self.isZmumu_value)

        #print "making isZtautau"
        self.isZtautau_branch = the_tree.GetBranch("isZtautau")
        #if not self.isZtautau_branch and "isZtautau" not in self.complained:
        if not self.isZtautau_branch and "isZtautau":
            warnings.warn( "MMMTree: Expected branch isZtautau does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZtautau")
        else:
            self.isZtautau_branch.SetAddress(<void*>&self.isZtautau_value)

        #print "making isdata"
        self.isdata_branch = the_tree.GetBranch("isdata")
        #if not self.isdata_branch and "isdata" not in self.complained:
        if not self.isdata_branch and "isdata":
            warnings.warn( "MMMTree: Expected branch isdata does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isdata")
        else:
            self.isdata_branch.SetAddress(<void*>&self.isdata_value)

        #print "making jetVeto20"
        self.jetVeto20_branch = the_tree.GetBranch("jetVeto20")
        #if not self.jetVeto20_branch and "jetVeto20" not in self.complained:
        if not self.jetVeto20_branch and "jetVeto20":
            warnings.warn( "MMMTree: Expected branch jetVeto20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto20")
        else:
            self.jetVeto20_branch.SetAddress(<void*>&self.jetVeto20_value)

        #print "making jetVeto20_DR05"
        self.jetVeto20_DR05_branch = the_tree.GetBranch("jetVeto20_DR05")
        #if not self.jetVeto20_DR05_branch and "jetVeto20_DR05" not in self.complained:
        if not self.jetVeto20_DR05_branch and "jetVeto20_DR05":
            warnings.warn( "MMMTree: Expected branch jetVeto20_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto20_DR05")
        else:
            self.jetVeto20_DR05_branch.SetAddress(<void*>&self.jetVeto20_DR05_value)

        #print "making jetVeto30"
        self.jetVeto30_branch = the_tree.GetBranch("jetVeto30")
        #if not self.jetVeto30_branch and "jetVeto30" not in self.complained:
        if not self.jetVeto30_branch and "jetVeto30":
            warnings.warn( "MMMTree: Expected branch jetVeto30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30")
        else:
            self.jetVeto30_branch.SetAddress(<void*>&self.jetVeto30_value)

        #print "making jetVeto30Eta3"
        self.jetVeto30Eta3_branch = the_tree.GetBranch("jetVeto30Eta3")
        #if not self.jetVeto30Eta3_branch and "jetVeto30Eta3" not in self.complained:
        if not self.jetVeto30Eta3_branch and "jetVeto30Eta3":
            warnings.warn( "MMMTree: Expected branch jetVeto30Eta3 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3")
        else:
            self.jetVeto30Eta3_branch.SetAddress(<void*>&self.jetVeto30Eta3_value)

        #print "making jetVeto30Eta3_JetEnDown"
        self.jetVeto30Eta3_JetEnDown_branch = the_tree.GetBranch("jetVeto30Eta3_JetEnDown")
        #if not self.jetVeto30Eta3_JetEnDown_branch and "jetVeto30Eta3_JetEnDown" not in self.complained:
        if not self.jetVeto30Eta3_JetEnDown_branch and "jetVeto30Eta3_JetEnDown":
            warnings.warn( "MMMTree: Expected branch jetVeto30Eta3_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3_JetEnDown")
        else:
            self.jetVeto30Eta3_JetEnDown_branch.SetAddress(<void*>&self.jetVeto30Eta3_JetEnDown_value)

        #print "making jetVeto30Eta3_JetEnUp"
        self.jetVeto30Eta3_JetEnUp_branch = the_tree.GetBranch("jetVeto30Eta3_JetEnUp")
        #if not self.jetVeto30Eta3_JetEnUp_branch and "jetVeto30Eta3_JetEnUp" not in self.complained:
        if not self.jetVeto30Eta3_JetEnUp_branch and "jetVeto30Eta3_JetEnUp":
            warnings.warn( "MMMTree: Expected branch jetVeto30Eta3_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3_JetEnUp")
        else:
            self.jetVeto30Eta3_JetEnUp_branch.SetAddress(<void*>&self.jetVeto30Eta3_JetEnUp_value)

        #print "making jetVeto30_DR05"
        self.jetVeto30_DR05_branch = the_tree.GetBranch("jetVeto30_DR05")
        #if not self.jetVeto30_DR05_branch and "jetVeto30_DR05" not in self.complained:
        if not self.jetVeto30_DR05_branch and "jetVeto30_DR05":
            warnings.warn( "MMMTree: Expected branch jetVeto30_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_DR05")
        else:
            self.jetVeto30_DR05_branch.SetAddress(<void*>&self.jetVeto30_DR05_value)

        #print "making jetVeto30_JetEnDown"
        self.jetVeto30_JetEnDown_branch = the_tree.GetBranch("jetVeto30_JetEnDown")
        #if not self.jetVeto30_JetEnDown_branch and "jetVeto30_JetEnDown" not in self.complained:
        if not self.jetVeto30_JetEnDown_branch and "jetVeto30_JetEnDown":
            warnings.warn( "MMMTree: Expected branch jetVeto30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_JetEnDown")
        else:
            self.jetVeto30_JetEnDown_branch.SetAddress(<void*>&self.jetVeto30_JetEnDown_value)

        #print "making jetVeto30_JetEnUp"
        self.jetVeto30_JetEnUp_branch = the_tree.GetBranch("jetVeto30_JetEnUp")
        #if not self.jetVeto30_JetEnUp_branch and "jetVeto30_JetEnUp" not in self.complained:
        if not self.jetVeto30_JetEnUp_branch and "jetVeto30_JetEnUp":
            warnings.warn( "MMMTree: Expected branch jetVeto30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_JetEnUp")
        else:
            self.jetVeto30_JetEnUp_branch.SetAddress(<void*>&self.jetVeto30_JetEnUp_value)

        #print "making jetVeto40"
        self.jetVeto40_branch = the_tree.GetBranch("jetVeto40")
        #if not self.jetVeto40_branch and "jetVeto40" not in self.complained:
        if not self.jetVeto40_branch and "jetVeto40":
            warnings.warn( "MMMTree: Expected branch jetVeto40 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto40")
        else:
            self.jetVeto40_branch.SetAddress(<void*>&self.jetVeto40_value)

        #print "making jetVeto40_DR05"
        self.jetVeto40_DR05_branch = the_tree.GetBranch("jetVeto40_DR05")
        #if not self.jetVeto40_DR05_branch and "jetVeto40_DR05" not in self.complained:
        if not self.jetVeto40_DR05_branch and "jetVeto40_DR05":
            warnings.warn( "MMMTree: Expected branch jetVeto40_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto40_DR05")
        else:
            self.jetVeto40_DR05_branch.SetAddress(<void*>&self.jetVeto40_DR05_value)

        #print "making lumi"
        self.lumi_branch = the_tree.GetBranch("lumi")
        #if not self.lumi_branch and "lumi" not in self.complained:
        if not self.lumi_branch and "lumi":
            warnings.warn( "MMMTree: Expected branch lumi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("lumi")
        else:
            self.lumi_branch.SetAddress(<void*>&self.lumi_value)

        #print "making m1AbsEta"
        self.m1AbsEta_branch = the_tree.GetBranch("m1AbsEta")
        #if not self.m1AbsEta_branch and "m1AbsEta" not in self.complained:
        if not self.m1AbsEta_branch and "m1AbsEta":
            warnings.warn( "MMMTree: Expected branch m1AbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1AbsEta")
        else:
            self.m1AbsEta_branch.SetAddress(<void*>&self.m1AbsEta_value)

        #print "making m1BestTrackType"
        self.m1BestTrackType_branch = the_tree.GetBranch("m1BestTrackType")
        #if not self.m1BestTrackType_branch and "m1BestTrackType" not in self.complained:
        if not self.m1BestTrackType_branch and "m1BestTrackType":
            warnings.warn( "MMMTree: Expected branch m1BestTrackType does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1BestTrackType")
        else:
            self.m1BestTrackType_branch.SetAddress(<void*>&self.m1BestTrackType_value)

        #print "making m1Charge"
        self.m1Charge_branch = the_tree.GetBranch("m1Charge")
        #if not self.m1Charge_branch and "m1Charge" not in self.complained:
        if not self.m1Charge_branch and "m1Charge":
            warnings.warn( "MMMTree: Expected branch m1Charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Charge")
        else:
            self.m1Charge_branch.SetAddress(<void*>&self.m1Charge_value)

        #print "making m1ComesFromHiggs"
        self.m1ComesFromHiggs_branch = the_tree.GetBranch("m1ComesFromHiggs")
        #if not self.m1ComesFromHiggs_branch and "m1ComesFromHiggs" not in self.complained:
        if not self.m1ComesFromHiggs_branch and "m1ComesFromHiggs":
            warnings.warn( "MMMTree: Expected branch m1ComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1ComesFromHiggs")
        else:
            self.m1ComesFromHiggs_branch.SetAddress(<void*>&self.m1ComesFromHiggs_value)

        #print "making m1DPhiToPfMet_ElectronEnDown"
        self.m1DPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("m1DPhiToPfMet_ElectronEnDown")
        #if not self.m1DPhiToPfMet_ElectronEnDown_branch and "m1DPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.m1DPhiToPfMet_ElectronEnDown_branch and "m1DPhiToPfMet_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_ElectronEnDown")
        else:
            self.m1DPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.m1DPhiToPfMet_ElectronEnDown_value)

        #print "making m1DPhiToPfMet_ElectronEnUp"
        self.m1DPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("m1DPhiToPfMet_ElectronEnUp")
        #if not self.m1DPhiToPfMet_ElectronEnUp_branch and "m1DPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.m1DPhiToPfMet_ElectronEnUp_branch and "m1DPhiToPfMet_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_ElectronEnUp")
        else:
            self.m1DPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.m1DPhiToPfMet_ElectronEnUp_value)

        #print "making m1DPhiToPfMet_JetEnDown"
        self.m1DPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("m1DPhiToPfMet_JetEnDown")
        #if not self.m1DPhiToPfMet_JetEnDown_branch and "m1DPhiToPfMet_JetEnDown" not in self.complained:
        if not self.m1DPhiToPfMet_JetEnDown_branch and "m1DPhiToPfMet_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_JetEnDown")
        else:
            self.m1DPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.m1DPhiToPfMet_JetEnDown_value)

        #print "making m1DPhiToPfMet_JetEnUp"
        self.m1DPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("m1DPhiToPfMet_JetEnUp")
        #if not self.m1DPhiToPfMet_JetEnUp_branch and "m1DPhiToPfMet_JetEnUp" not in self.complained:
        if not self.m1DPhiToPfMet_JetEnUp_branch and "m1DPhiToPfMet_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_JetEnUp")
        else:
            self.m1DPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.m1DPhiToPfMet_JetEnUp_value)

        #print "making m1DPhiToPfMet_JetResDown"
        self.m1DPhiToPfMet_JetResDown_branch = the_tree.GetBranch("m1DPhiToPfMet_JetResDown")
        #if not self.m1DPhiToPfMet_JetResDown_branch and "m1DPhiToPfMet_JetResDown" not in self.complained:
        if not self.m1DPhiToPfMet_JetResDown_branch and "m1DPhiToPfMet_JetResDown":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_JetResDown")
        else:
            self.m1DPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.m1DPhiToPfMet_JetResDown_value)

        #print "making m1DPhiToPfMet_JetResUp"
        self.m1DPhiToPfMet_JetResUp_branch = the_tree.GetBranch("m1DPhiToPfMet_JetResUp")
        #if not self.m1DPhiToPfMet_JetResUp_branch and "m1DPhiToPfMet_JetResUp" not in self.complained:
        if not self.m1DPhiToPfMet_JetResUp_branch and "m1DPhiToPfMet_JetResUp":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_JetResUp")
        else:
            self.m1DPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.m1DPhiToPfMet_JetResUp_value)

        #print "making m1DPhiToPfMet_MuonEnDown"
        self.m1DPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("m1DPhiToPfMet_MuonEnDown")
        #if not self.m1DPhiToPfMet_MuonEnDown_branch and "m1DPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.m1DPhiToPfMet_MuonEnDown_branch and "m1DPhiToPfMet_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_MuonEnDown")
        else:
            self.m1DPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.m1DPhiToPfMet_MuonEnDown_value)

        #print "making m1DPhiToPfMet_MuonEnUp"
        self.m1DPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("m1DPhiToPfMet_MuonEnUp")
        #if not self.m1DPhiToPfMet_MuonEnUp_branch and "m1DPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.m1DPhiToPfMet_MuonEnUp_branch and "m1DPhiToPfMet_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_MuonEnUp")
        else:
            self.m1DPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.m1DPhiToPfMet_MuonEnUp_value)

        #print "making m1DPhiToPfMet_PhotonEnDown"
        self.m1DPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("m1DPhiToPfMet_PhotonEnDown")
        #if not self.m1DPhiToPfMet_PhotonEnDown_branch and "m1DPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.m1DPhiToPfMet_PhotonEnDown_branch and "m1DPhiToPfMet_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_PhotonEnDown")
        else:
            self.m1DPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.m1DPhiToPfMet_PhotonEnDown_value)

        #print "making m1DPhiToPfMet_PhotonEnUp"
        self.m1DPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("m1DPhiToPfMet_PhotonEnUp")
        #if not self.m1DPhiToPfMet_PhotonEnUp_branch and "m1DPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.m1DPhiToPfMet_PhotonEnUp_branch and "m1DPhiToPfMet_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_PhotonEnUp")
        else:
            self.m1DPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.m1DPhiToPfMet_PhotonEnUp_value)

        #print "making m1DPhiToPfMet_TauEnDown"
        self.m1DPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("m1DPhiToPfMet_TauEnDown")
        #if not self.m1DPhiToPfMet_TauEnDown_branch and "m1DPhiToPfMet_TauEnDown" not in self.complained:
        if not self.m1DPhiToPfMet_TauEnDown_branch and "m1DPhiToPfMet_TauEnDown":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_TauEnDown")
        else:
            self.m1DPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.m1DPhiToPfMet_TauEnDown_value)

        #print "making m1DPhiToPfMet_TauEnUp"
        self.m1DPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("m1DPhiToPfMet_TauEnUp")
        #if not self.m1DPhiToPfMet_TauEnUp_branch and "m1DPhiToPfMet_TauEnUp" not in self.complained:
        if not self.m1DPhiToPfMet_TauEnUp_branch and "m1DPhiToPfMet_TauEnUp":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_TauEnUp")
        else:
            self.m1DPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.m1DPhiToPfMet_TauEnUp_value)

        #print "making m1DPhiToPfMet_UnclusteredEnDown"
        self.m1DPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("m1DPhiToPfMet_UnclusteredEnDown")
        #if not self.m1DPhiToPfMet_UnclusteredEnDown_branch and "m1DPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.m1DPhiToPfMet_UnclusteredEnDown_branch and "m1DPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_UnclusteredEnDown")
        else:
            self.m1DPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.m1DPhiToPfMet_UnclusteredEnDown_value)

        #print "making m1DPhiToPfMet_UnclusteredEnUp"
        self.m1DPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("m1DPhiToPfMet_UnclusteredEnUp")
        #if not self.m1DPhiToPfMet_UnclusteredEnUp_branch and "m1DPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.m1DPhiToPfMet_UnclusteredEnUp_branch and "m1DPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_UnclusteredEnUp")
        else:
            self.m1DPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.m1DPhiToPfMet_UnclusteredEnUp_value)

        #print "making m1DPhiToPfMet_type1"
        self.m1DPhiToPfMet_type1_branch = the_tree.GetBranch("m1DPhiToPfMet_type1")
        #if not self.m1DPhiToPfMet_type1_branch and "m1DPhiToPfMet_type1" not in self.complained:
        if not self.m1DPhiToPfMet_type1_branch and "m1DPhiToPfMet_type1":
            warnings.warn( "MMMTree: Expected branch m1DPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1DPhiToPfMet_type1")
        else:
            self.m1DPhiToPfMet_type1_branch.SetAddress(<void*>&self.m1DPhiToPfMet_type1_value)

        #print "making m1EcalIsoDR03"
        self.m1EcalIsoDR03_branch = the_tree.GetBranch("m1EcalIsoDR03")
        #if not self.m1EcalIsoDR03_branch and "m1EcalIsoDR03" not in self.complained:
        if not self.m1EcalIsoDR03_branch and "m1EcalIsoDR03":
            warnings.warn( "MMMTree: Expected branch m1EcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1EcalIsoDR03")
        else:
            self.m1EcalIsoDR03_branch.SetAddress(<void*>&self.m1EcalIsoDR03_value)

        #print "making m1EffectiveArea2011"
        self.m1EffectiveArea2011_branch = the_tree.GetBranch("m1EffectiveArea2011")
        #if not self.m1EffectiveArea2011_branch and "m1EffectiveArea2011" not in self.complained:
        if not self.m1EffectiveArea2011_branch and "m1EffectiveArea2011":
            warnings.warn( "MMMTree: Expected branch m1EffectiveArea2011 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1EffectiveArea2011")
        else:
            self.m1EffectiveArea2011_branch.SetAddress(<void*>&self.m1EffectiveArea2011_value)

        #print "making m1EffectiveArea2012"
        self.m1EffectiveArea2012_branch = the_tree.GetBranch("m1EffectiveArea2012")
        #if not self.m1EffectiveArea2012_branch and "m1EffectiveArea2012" not in self.complained:
        if not self.m1EffectiveArea2012_branch and "m1EffectiveArea2012":
            warnings.warn( "MMMTree: Expected branch m1EffectiveArea2012 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1EffectiveArea2012")
        else:
            self.m1EffectiveArea2012_branch.SetAddress(<void*>&self.m1EffectiveArea2012_value)

        #print "making m1Eta"
        self.m1Eta_branch = the_tree.GetBranch("m1Eta")
        #if not self.m1Eta_branch and "m1Eta" not in self.complained:
        if not self.m1Eta_branch and "m1Eta":
            warnings.warn( "MMMTree: Expected branch m1Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Eta")
        else:
            self.m1Eta_branch.SetAddress(<void*>&self.m1Eta_value)

        #print "making m1Eta_MuonEnDown"
        self.m1Eta_MuonEnDown_branch = the_tree.GetBranch("m1Eta_MuonEnDown")
        #if not self.m1Eta_MuonEnDown_branch and "m1Eta_MuonEnDown" not in self.complained:
        if not self.m1Eta_MuonEnDown_branch and "m1Eta_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m1Eta_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Eta_MuonEnDown")
        else:
            self.m1Eta_MuonEnDown_branch.SetAddress(<void*>&self.m1Eta_MuonEnDown_value)

        #print "making m1Eta_MuonEnUp"
        self.m1Eta_MuonEnUp_branch = the_tree.GetBranch("m1Eta_MuonEnUp")
        #if not self.m1Eta_MuonEnUp_branch and "m1Eta_MuonEnUp" not in self.complained:
        if not self.m1Eta_MuonEnUp_branch and "m1Eta_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m1Eta_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Eta_MuonEnUp")
        else:
            self.m1Eta_MuonEnUp_branch.SetAddress(<void*>&self.m1Eta_MuonEnUp_value)

        #print "making m1GenCharge"
        self.m1GenCharge_branch = the_tree.GetBranch("m1GenCharge")
        #if not self.m1GenCharge_branch and "m1GenCharge" not in self.complained:
        if not self.m1GenCharge_branch and "m1GenCharge":
            warnings.warn( "MMMTree: Expected branch m1GenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenCharge")
        else:
            self.m1GenCharge_branch.SetAddress(<void*>&self.m1GenCharge_value)

        #print "making m1GenEnergy"
        self.m1GenEnergy_branch = the_tree.GetBranch("m1GenEnergy")
        #if not self.m1GenEnergy_branch and "m1GenEnergy" not in self.complained:
        if not self.m1GenEnergy_branch and "m1GenEnergy":
            warnings.warn( "MMMTree: Expected branch m1GenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenEnergy")
        else:
            self.m1GenEnergy_branch.SetAddress(<void*>&self.m1GenEnergy_value)

        #print "making m1GenEta"
        self.m1GenEta_branch = the_tree.GetBranch("m1GenEta")
        #if not self.m1GenEta_branch and "m1GenEta" not in self.complained:
        if not self.m1GenEta_branch and "m1GenEta":
            warnings.warn( "MMMTree: Expected branch m1GenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenEta")
        else:
            self.m1GenEta_branch.SetAddress(<void*>&self.m1GenEta_value)

        #print "making m1GenMotherPdgId"
        self.m1GenMotherPdgId_branch = the_tree.GetBranch("m1GenMotherPdgId")
        #if not self.m1GenMotherPdgId_branch and "m1GenMotherPdgId" not in self.complained:
        if not self.m1GenMotherPdgId_branch and "m1GenMotherPdgId":
            warnings.warn( "MMMTree: Expected branch m1GenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenMotherPdgId")
        else:
            self.m1GenMotherPdgId_branch.SetAddress(<void*>&self.m1GenMotherPdgId_value)

        #print "making m1GenPdgId"
        self.m1GenPdgId_branch = the_tree.GetBranch("m1GenPdgId")
        #if not self.m1GenPdgId_branch and "m1GenPdgId" not in self.complained:
        if not self.m1GenPdgId_branch and "m1GenPdgId":
            warnings.warn( "MMMTree: Expected branch m1GenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenPdgId")
        else:
            self.m1GenPdgId_branch.SetAddress(<void*>&self.m1GenPdgId_value)

        #print "making m1GenPhi"
        self.m1GenPhi_branch = the_tree.GetBranch("m1GenPhi")
        #if not self.m1GenPhi_branch and "m1GenPhi" not in self.complained:
        if not self.m1GenPhi_branch and "m1GenPhi":
            warnings.warn( "MMMTree: Expected branch m1GenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenPhi")
        else:
            self.m1GenPhi_branch.SetAddress(<void*>&self.m1GenPhi_value)

        #print "making m1GenPrompt"
        self.m1GenPrompt_branch = the_tree.GetBranch("m1GenPrompt")
        #if not self.m1GenPrompt_branch and "m1GenPrompt" not in self.complained:
        if not self.m1GenPrompt_branch and "m1GenPrompt":
            warnings.warn( "MMMTree: Expected branch m1GenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenPrompt")
        else:
            self.m1GenPrompt_branch.SetAddress(<void*>&self.m1GenPrompt_value)

        #print "making m1GenPromptTauDecay"
        self.m1GenPromptTauDecay_branch = the_tree.GetBranch("m1GenPromptTauDecay")
        #if not self.m1GenPromptTauDecay_branch and "m1GenPromptTauDecay" not in self.complained:
        if not self.m1GenPromptTauDecay_branch and "m1GenPromptTauDecay":
            warnings.warn( "MMMTree: Expected branch m1GenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenPromptTauDecay")
        else:
            self.m1GenPromptTauDecay_branch.SetAddress(<void*>&self.m1GenPromptTauDecay_value)

        #print "making m1GenPt"
        self.m1GenPt_branch = the_tree.GetBranch("m1GenPt")
        #if not self.m1GenPt_branch and "m1GenPt" not in self.complained:
        if not self.m1GenPt_branch and "m1GenPt":
            warnings.warn( "MMMTree: Expected branch m1GenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenPt")
        else:
            self.m1GenPt_branch.SetAddress(<void*>&self.m1GenPt_value)

        #print "making m1GenTauDecay"
        self.m1GenTauDecay_branch = the_tree.GetBranch("m1GenTauDecay")
        #if not self.m1GenTauDecay_branch and "m1GenTauDecay" not in self.complained:
        if not self.m1GenTauDecay_branch and "m1GenTauDecay":
            warnings.warn( "MMMTree: Expected branch m1GenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenTauDecay")
        else:
            self.m1GenTauDecay_branch.SetAddress(<void*>&self.m1GenTauDecay_value)

        #print "making m1GenVZ"
        self.m1GenVZ_branch = the_tree.GetBranch("m1GenVZ")
        #if not self.m1GenVZ_branch and "m1GenVZ" not in self.complained:
        if not self.m1GenVZ_branch and "m1GenVZ":
            warnings.warn( "MMMTree: Expected branch m1GenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenVZ")
        else:
            self.m1GenVZ_branch.SetAddress(<void*>&self.m1GenVZ_value)

        #print "making m1GenVtxPVMatch"
        self.m1GenVtxPVMatch_branch = the_tree.GetBranch("m1GenVtxPVMatch")
        #if not self.m1GenVtxPVMatch_branch and "m1GenVtxPVMatch" not in self.complained:
        if not self.m1GenVtxPVMatch_branch and "m1GenVtxPVMatch":
            warnings.warn( "MMMTree: Expected branch m1GenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1GenVtxPVMatch")
        else:
            self.m1GenVtxPVMatch_branch.SetAddress(<void*>&self.m1GenVtxPVMatch_value)

        #print "making m1HcalIsoDR03"
        self.m1HcalIsoDR03_branch = the_tree.GetBranch("m1HcalIsoDR03")
        #if not self.m1HcalIsoDR03_branch and "m1HcalIsoDR03" not in self.complained:
        if not self.m1HcalIsoDR03_branch and "m1HcalIsoDR03":
            warnings.warn( "MMMTree: Expected branch m1HcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1HcalIsoDR03")
        else:
            self.m1HcalIsoDR03_branch.SetAddress(<void*>&self.m1HcalIsoDR03_value)

        #print "making m1IP3D"
        self.m1IP3D_branch = the_tree.GetBranch("m1IP3D")
        #if not self.m1IP3D_branch and "m1IP3D" not in self.complained:
        if not self.m1IP3D_branch and "m1IP3D":
            warnings.warn( "MMMTree: Expected branch m1IP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1IP3D")
        else:
            self.m1IP3D_branch.SetAddress(<void*>&self.m1IP3D_value)

        #print "making m1IP3DErr"
        self.m1IP3DErr_branch = the_tree.GetBranch("m1IP3DErr")
        #if not self.m1IP3DErr_branch and "m1IP3DErr" not in self.complained:
        if not self.m1IP3DErr_branch and "m1IP3DErr":
            warnings.warn( "MMMTree: Expected branch m1IP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1IP3DErr")
        else:
            self.m1IP3DErr_branch.SetAddress(<void*>&self.m1IP3DErr_value)

        #print "making m1IsGlobal"
        self.m1IsGlobal_branch = the_tree.GetBranch("m1IsGlobal")
        #if not self.m1IsGlobal_branch and "m1IsGlobal" not in self.complained:
        if not self.m1IsGlobal_branch and "m1IsGlobal":
            warnings.warn( "MMMTree: Expected branch m1IsGlobal does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1IsGlobal")
        else:
            self.m1IsGlobal_branch.SetAddress(<void*>&self.m1IsGlobal_value)

        #print "making m1IsPFMuon"
        self.m1IsPFMuon_branch = the_tree.GetBranch("m1IsPFMuon")
        #if not self.m1IsPFMuon_branch and "m1IsPFMuon" not in self.complained:
        if not self.m1IsPFMuon_branch and "m1IsPFMuon":
            warnings.warn( "MMMTree: Expected branch m1IsPFMuon does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1IsPFMuon")
        else:
            self.m1IsPFMuon_branch.SetAddress(<void*>&self.m1IsPFMuon_value)

        #print "making m1IsTracker"
        self.m1IsTracker_branch = the_tree.GetBranch("m1IsTracker")
        #if not self.m1IsTracker_branch and "m1IsTracker" not in self.complained:
        if not self.m1IsTracker_branch and "m1IsTracker":
            warnings.warn( "MMMTree: Expected branch m1IsTracker does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1IsTracker")
        else:
            self.m1IsTracker_branch.SetAddress(<void*>&self.m1IsTracker_value)

        #print "making m1JetArea"
        self.m1JetArea_branch = the_tree.GetBranch("m1JetArea")
        #if not self.m1JetArea_branch and "m1JetArea" not in self.complained:
        if not self.m1JetArea_branch and "m1JetArea":
            warnings.warn( "MMMTree: Expected branch m1JetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetArea")
        else:
            self.m1JetArea_branch.SetAddress(<void*>&self.m1JetArea_value)

        #print "making m1JetBtag"
        self.m1JetBtag_branch = the_tree.GetBranch("m1JetBtag")
        #if not self.m1JetBtag_branch and "m1JetBtag" not in self.complained:
        if not self.m1JetBtag_branch and "m1JetBtag":
            warnings.warn( "MMMTree: Expected branch m1JetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetBtag")
        else:
            self.m1JetBtag_branch.SetAddress(<void*>&self.m1JetBtag_value)

        #print "making m1JetEtaEtaMoment"
        self.m1JetEtaEtaMoment_branch = the_tree.GetBranch("m1JetEtaEtaMoment")
        #if not self.m1JetEtaEtaMoment_branch and "m1JetEtaEtaMoment" not in self.complained:
        if not self.m1JetEtaEtaMoment_branch and "m1JetEtaEtaMoment":
            warnings.warn( "MMMTree: Expected branch m1JetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetEtaEtaMoment")
        else:
            self.m1JetEtaEtaMoment_branch.SetAddress(<void*>&self.m1JetEtaEtaMoment_value)

        #print "making m1JetEtaPhiMoment"
        self.m1JetEtaPhiMoment_branch = the_tree.GetBranch("m1JetEtaPhiMoment")
        #if not self.m1JetEtaPhiMoment_branch and "m1JetEtaPhiMoment" not in self.complained:
        if not self.m1JetEtaPhiMoment_branch and "m1JetEtaPhiMoment":
            warnings.warn( "MMMTree: Expected branch m1JetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetEtaPhiMoment")
        else:
            self.m1JetEtaPhiMoment_branch.SetAddress(<void*>&self.m1JetEtaPhiMoment_value)

        #print "making m1JetEtaPhiSpread"
        self.m1JetEtaPhiSpread_branch = the_tree.GetBranch("m1JetEtaPhiSpread")
        #if not self.m1JetEtaPhiSpread_branch and "m1JetEtaPhiSpread" not in self.complained:
        if not self.m1JetEtaPhiSpread_branch and "m1JetEtaPhiSpread":
            warnings.warn( "MMMTree: Expected branch m1JetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetEtaPhiSpread")
        else:
            self.m1JetEtaPhiSpread_branch.SetAddress(<void*>&self.m1JetEtaPhiSpread_value)

        #print "making m1JetPFCISVBtag"
        self.m1JetPFCISVBtag_branch = the_tree.GetBranch("m1JetPFCISVBtag")
        #if not self.m1JetPFCISVBtag_branch and "m1JetPFCISVBtag" not in self.complained:
        if not self.m1JetPFCISVBtag_branch and "m1JetPFCISVBtag":
            warnings.warn( "MMMTree: Expected branch m1JetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetPFCISVBtag")
        else:
            self.m1JetPFCISVBtag_branch.SetAddress(<void*>&self.m1JetPFCISVBtag_value)

        #print "making m1JetPartonFlavour"
        self.m1JetPartonFlavour_branch = the_tree.GetBranch("m1JetPartonFlavour")
        #if not self.m1JetPartonFlavour_branch and "m1JetPartonFlavour" not in self.complained:
        if not self.m1JetPartonFlavour_branch and "m1JetPartonFlavour":
            warnings.warn( "MMMTree: Expected branch m1JetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetPartonFlavour")
        else:
            self.m1JetPartonFlavour_branch.SetAddress(<void*>&self.m1JetPartonFlavour_value)

        #print "making m1JetPhiPhiMoment"
        self.m1JetPhiPhiMoment_branch = the_tree.GetBranch("m1JetPhiPhiMoment")
        #if not self.m1JetPhiPhiMoment_branch and "m1JetPhiPhiMoment" not in self.complained:
        if not self.m1JetPhiPhiMoment_branch and "m1JetPhiPhiMoment":
            warnings.warn( "MMMTree: Expected branch m1JetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetPhiPhiMoment")
        else:
            self.m1JetPhiPhiMoment_branch.SetAddress(<void*>&self.m1JetPhiPhiMoment_value)

        #print "making m1JetPt"
        self.m1JetPt_branch = the_tree.GetBranch("m1JetPt")
        #if not self.m1JetPt_branch and "m1JetPt" not in self.complained:
        if not self.m1JetPt_branch and "m1JetPt":
            warnings.warn( "MMMTree: Expected branch m1JetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1JetPt")
        else:
            self.m1JetPt_branch.SetAddress(<void*>&self.m1JetPt_value)

        #print "making m1LowestMll"
        self.m1LowestMll_branch = the_tree.GetBranch("m1LowestMll")
        #if not self.m1LowestMll_branch and "m1LowestMll" not in self.complained:
        if not self.m1LowestMll_branch and "m1LowestMll":
            warnings.warn( "MMMTree: Expected branch m1LowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1LowestMll")
        else:
            self.m1LowestMll_branch.SetAddress(<void*>&self.m1LowestMll_value)

        #print "making m1Mass"
        self.m1Mass_branch = the_tree.GetBranch("m1Mass")
        #if not self.m1Mass_branch and "m1Mass" not in self.complained:
        if not self.m1Mass_branch and "m1Mass":
            warnings.warn( "MMMTree: Expected branch m1Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Mass")
        else:
            self.m1Mass_branch.SetAddress(<void*>&self.m1Mass_value)

        #print "making m1MatchedStations"
        self.m1MatchedStations_branch = the_tree.GetBranch("m1MatchedStations")
        #if not self.m1MatchedStations_branch and "m1MatchedStations" not in self.complained:
        if not self.m1MatchedStations_branch and "m1MatchedStations":
            warnings.warn( "MMMTree: Expected branch m1MatchedStations does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchedStations")
        else:
            self.m1MatchedStations_branch.SetAddress(<void*>&self.m1MatchedStations_value)

        #print "making m1MatchesDoubleESingleMu"
        self.m1MatchesDoubleESingleMu_branch = the_tree.GetBranch("m1MatchesDoubleESingleMu")
        #if not self.m1MatchesDoubleESingleMu_branch and "m1MatchesDoubleESingleMu" not in self.complained:
        if not self.m1MatchesDoubleESingleMu_branch and "m1MatchesDoubleESingleMu":
            warnings.warn( "MMMTree: Expected branch m1MatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesDoubleESingleMu")
        else:
            self.m1MatchesDoubleESingleMu_branch.SetAddress(<void*>&self.m1MatchesDoubleESingleMu_value)

        #print "making m1MatchesDoubleMu"
        self.m1MatchesDoubleMu_branch = the_tree.GetBranch("m1MatchesDoubleMu")
        #if not self.m1MatchesDoubleMu_branch and "m1MatchesDoubleMu" not in self.complained:
        if not self.m1MatchesDoubleMu_branch and "m1MatchesDoubleMu":
            warnings.warn( "MMMTree: Expected branch m1MatchesDoubleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesDoubleMu")
        else:
            self.m1MatchesDoubleMu_branch.SetAddress(<void*>&self.m1MatchesDoubleMu_value)

        #print "making m1MatchesDoubleMuSingleE"
        self.m1MatchesDoubleMuSingleE_branch = the_tree.GetBranch("m1MatchesDoubleMuSingleE")
        #if not self.m1MatchesDoubleMuSingleE_branch and "m1MatchesDoubleMuSingleE" not in self.complained:
        if not self.m1MatchesDoubleMuSingleE_branch and "m1MatchesDoubleMuSingleE":
            warnings.warn( "MMMTree: Expected branch m1MatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesDoubleMuSingleE")
        else:
            self.m1MatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.m1MatchesDoubleMuSingleE_value)

        #print "making m1MatchesSingleESingleMu"
        self.m1MatchesSingleESingleMu_branch = the_tree.GetBranch("m1MatchesSingleESingleMu")
        #if not self.m1MatchesSingleESingleMu_branch and "m1MatchesSingleESingleMu" not in self.complained:
        if not self.m1MatchesSingleESingleMu_branch and "m1MatchesSingleESingleMu":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleESingleMu")
        else:
            self.m1MatchesSingleESingleMu_branch.SetAddress(<void*>&self.m1MatchesSingleESingleMu_value)

        #print "making m1MatchesSingleMu"
        self.m1MatchesSingleMu_branch = the_tree.GetBranch("m1MatchesSingleMu")
        #if not self.m1MatchesSingleMu_branch and "m1MatchesSingleMu" not in self.complained:
        if not self.m1MatchesSingleMu_branch and "m1MatchesSingleMu":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMu")
        else:
            self.m1MatchesSingleMu_branch.SetAddress(<void*>&self.m1MatchesSingleMu_value)

        #print "making m1MatchesSingleMuIso20"
        self.m1MatchesSingleMuIso20_branch = the_tree.GetBranch("m1MatchesSingleMuIso20")
        #if not self.m1MatchesSingleMuIso20_branch and "m1MatchesSingleMuIso20" not in self.complained:
        if not self.m1MatchesSingleMuIso20_branch and "m1MatchesSingleMuIso20":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMuIso20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMuIso20")
        else:
            self.m1MatchesSingleMuIso20_branch.SetAddress(<void*>&self.m1MatchesSingleMuIso20_value)

        #print "making m1MatchesSingleMuIsoTk20"
        self.m1MatchesSingleMuIsoTk20_branch = the_tree.GetBranch("m1MatchesSingleMuIsoTk20")
        #if not self.m1MatchesSingleMuIsoTk20_branch and "m1MatchesSingleMuIsoTk20" not in self.complained:
        if not self.m1MatchesSingleMuIsoTk20_branch and "m1MatchesSingleMuIsoTk20":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMuIsoTk20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMuIsoTk20")
        else:
            self.m1MatchesSingleMuIsoTk20_branch.SetAddress(<void*>&self.m1MatchesSingleMuIsoTk20_value)

        #print "making m1MatchesSingleMuSingleE"
        self.m1MatchesSingleMuSingleE_branch = the_tree.GetBranch("m1MatchesSingleMuSingleE")
        #if not self.m1MatchesSingleMuSingleE_branch and "m1MatchesSingleMuSingleE" not in self.complained:
        if not self.m1MatchesSingleMuSingleE_branch and "m1MatchesSingleMuSingleE":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMuSingleE")
        else:
            self.m1MatchesSingleMuSingleE_branch.SetAddress(<void*>&self.m1MatchesSingleMuSingleE_value)

        #print "making m1MatchesSingleMu_leg1"
        self.m1MatchesSingleMu_leg1_branch = the_tree.GetBranch("m1MatchesSingleMu_leg1")
        #if not self.m1MatchesSingleMu_leg1_branch and "m1MatchesSingleMu_leg1" not in self.complained:
        if not self.m1MatchesSingleMu_leg1_branch and "m1MatchesSingleMu_leg1":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMu_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMu_leg1")
        else:
            self.m1MatchesSingleMu_leg1_branch.SetAddress(<void*>&self.m1MatchesSingleMu_leg1_value)

        #print "making m1MatchesSingleMu_leg1_noiso"
        self.m1MatchesSingleMu_leg1_noiso_branch = the_tree.GetBranch("m1MatchesSingleMu_leg1_noiso")
        #if not self.m1MatchesSingleMu_leg1_noiso_branch and "m1MatchesSingleMu_leg1_noiso" not in self.complained:
        if not self.m1MatchesSingleMu_leg1_noiso_branch and "m1MatchesSingleMu_leg1_noiso":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMu_leg1_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMu_leg1_noiso")
        else:
            self.m1MatchesSingleMu_leg1_noiso_branch.SetAddress(<void*>&self.m1MatchesSingleMu_leg1_noiso_value)

        #print "making m1MatchesSingleMu_leg2"
        self.m1MatchesSingleMu_leg2_branch = the_tree.GetBranch("m1MatchesSingleMu_leg2")
        #if not self.m1MatchesSingleMu_leg2_branch and "m1MatchesSingleMu_leg2" not in self.complained:
        if not self.m1MatchesSingleMu_leg2_branch and "m1MatchesSingleMu_leg2":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMu_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMu_leg2")
        else:
            self.m1MatchesSingleMu_leg2_branch.SetAddress(<void*>&self.m1MatchesSingleMu_leg2_value)

        #print "making m1MatchesSingleMu_leg2_noiso"
        self.m1MatchesSingleMu_leg2_noiso_branch = the_tree.GetBranch("m1MatchesSingleMu_leg2_noiso")
        #if not self.m1MatchesSingleMu_leg2_noiso_branch and "m1MatchesSingleMu_leg2_noiso" not in self.complained:
        if not self.m1MatchesSingleMu_leg2_noiso_branch and "m1MatchesSingleMu_leg2_noiso":
            warnings.warn( "MMMTree: Expected branch m1MatchesSingleMu_leg2_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesSingleMu_leg2_noiso")
        else:
            self.m1MatchesSingleMu_leg2_noiso_branch.SetAddress(<void*>&self.m1MatchesSingleMu_leg2_noiso_value)

        #print "making m1MatchesTripleMu"
        self.m1MatchesTripleMu_branch = the_tree.GetBranch("m1MatchesTripleMu")
        #if not self.m1MatchesTripleMu_branch and "m1MatchesTripleMu" not in self.complained:
        if not self.m1MatchesTripleMu_branch and "m1MatchesTripleMu":
            warnings.warn( "MMMTree: Expected branch m1MatchesTripleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MatchesTripleMu")
        else:
            self.m1MatchesTripleMu_branch.SetAddress(<void*>&self.m1MatchesTripleMu_value)

        #print "making m1MtToPfMet_ElectronEnDown"
        self.m1MtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("m1MtToPfMet_ElectronEnDown")
        #if not self.m1MtToPfMet_ElectronEnDown_branch and "m1MtToPfMet_ElectronEnDown" not in self.complained:
        if not self.m1MtToPfMet_ElectronEnDown_branch and "m1MtToPfMet_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_ElectronEnDown")
        else:
            self.m1MtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.m1MtToPfMet_ElectronEnDown_value)

        #print "making m1MtToPfMet_ElectronEnUp"
        self.m1MtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("m1MtToPfMet_ElectronEnUp")
        #if not self.m1MtToPfMet_ElectronEnUp_branch and "m1MtToPfMet_ElectronEnUp" not in self.complained:
        if not self.m1MtToPfMet_ElectronEnUp_branch and "m1MtToPfMet_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_ElectronEnUp")
        else:
            self.m1MtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.m1MtToPfMet_ElectronEnUp_value)

        #print "making m1MtToPfMet_JetEnDown"
        self.m1MtToPfMet_JetEnDown_branch = the_tree.GetBranch("m1MtToPfMet_JetEnDown")
        #if not self.m1MtToPfMet_JetEnDown_branch and "m1MtToPfMet_JetEnDown" not in self.complained:
        if not self.m1MtToPfMet_JetEnDown_branch and "m1MtToPfMet_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_JetEnDown")
        else:
            self.m1MtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.m1MtToPfMet_JetEnDown_value)

        #print "making m1MtToPfMet_JetEnUp"
        self.m1MtToPfMet_JetEnUp_branch = the_tree.GetBranch("m1MtToPfMet_JetEnUp")
        #if not self.m1MtToPfMet_JetEnUp_branch and "m1MtToPfMet_JetEnUp" not in self.complained:
        if not self.m1MtToPfMet_JetEnUp_branch and "m1MtToPfMet_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_JetEnUp")
        else:
            self.m1MtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.m1MtToPfMet_JetEnUp_value)

        #print "making m1MtToPfMet_JetResDown"
        self.m1MtToPfMet_JetResDown_branch = the_tree.GetBranch("m1MtToPfMet_JetResDown")
        #if not self.m1MtToPfMet_JetResDown_branch and "m1MtToPfMet_JetResDown" not in self.complained:
        if not self.m1MtToPfMet_JetResDown_branch and "m1MtToPfMet_JetResDown":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_JetResDown")
        else:
            self.m1MtToPfMet_JetResDown_branch.SetAddress(<void*>&self.m1MtToPfMet_JetResDown_value)

        #print "making m1MtToPfMet_JetResUp"
        self.m1MtToPfMet_JetResUp_branch = the_tree.GetBranch("m1MtToPfMet_JetResUp")
        #if not self.m1MtToPfMet_JetResUp_branch and "m1MtToPfMet_JetResUp" not in self.complained:
        if not self.m1MtToPfMet_JetResUp_branch and "m1MtToPfMet_JetResUp":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_JetResUp")
        else:
            self.m1MtToPfMet_JetResUp_branch.SetAddress(<void*>&self.m1MtToPfMet_JetResUp_value)

        #print "making m1MtToPfMet_MuonEnDown"
        self.m1MtToPfMet_MuonEnDown_branch = the_tree.GetBranch("m1MtToPfMet_MuonEnDown")
        #if not self.m1MtToPfMet_MuonEnDown_branch and "m1MtToPfMet_MuonEnDown" not in self.complained:
        if not self.m1MtToPfMet_MuonEnDown_branch and "m1MtToPfMet_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_MuonEnDown")
        else:
            self.m1MtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.m1MtToPfMet_MuonEnDown_value)

        #print "making m1MtToPfMet_MuonEnUp"
        self.m1MtToPfMet_MuonEnUp_branch = the_tree.GetBranch("m1MtToPfMet_MuonEnUp")
        #if not self.m1MtToPfMet_MuonEnUp_branch and "m1MtToPfMet_MuonEnUp" not in self.complained:
        if not self.m1MtToPfMet_MuonEnUp_branch and "m1MtToPfMet_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_MuonEnUp")
        else:
            self.m1MtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.m1MtToPfMet_MuonEnUp_value)

        #print "making m1MtToPfMet_PhotonEnDown"
        self.m1MtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("m1MtToPfMet_PhotonEnDown")
        #if not self.m1MtToPfMet_PhotonEnDown_branch and "m1MtToPfMet_PhotonEnDown" not in self.complained:
        if not self.m1MtToPfMet_PhotonEnDown_branch and "m1MtToPfMet_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_PhotonEnDown")
        else:
            self.m1MtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.m1MtToPfMet_PhotonEnDown_value)

        #print "making m1MtToPfMet_PhotonEnUp"
        self.m1MtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("m1MtToPfMet_PhotonEnUp")
        #if not self.m1MtToPfMet_PhotonEnUp_branch and "m1MtToPfMet_PhotonEnUp" not in self.complained:
        if not self.m1MtToPfMet_PhotonEnUp_branch and "m1MtToPfMet_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_PhotonEnUp")
        else:
            self.m1MtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.m1MtToPfMet_PhotonEnUp_value)

        #print "making m1MtToPfMet_Raw"
        self.m1MtToPfMet_Raw_branch = the_tree.GetBranch("m1MtToPfMet_Raw")
        #if not self.m1MtToPfMet_Raw_branch and "m1MtToPfMet_Raw" not in self.complained:
        if not self.m1MtToPfMet_Raw_branch and "m1MtToPfMet_Raw":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_Raw")
        else:
            self.m1MtToPfMet_Raw_branch.SetAddress(<void*>&self.m1MtToPfMet_Raw_value)

        #print "making m1MtToPfMet_TauEnDown"
        self.m1MtToPfMet_TauEnDown_branch = the_tree.GetBranch("m1MtToPfMet_TauEnDown")
        #if not self.m1MtToPfMet_TauEnDown_branch and "m1MtToPfMet_TauEnDown" not in self.complained:
        if not self.m1MtToPfMet_TauEnDown_branch and "m1MtToPfMet_TauEnDown":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_TauEnDown")
        else:
            self.m1MtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.m1MtToPfMet_TauEnDown_value)

        #print "making m1MtToPfMet_TauEnUp"
        self.m1MtToPfMet_TauEnUp_branch = the_tree.GetBranch("m1MtToPfMet_TauEnUp")
        #if not self.m1MtToPfMet_TauEnUp_branch and "m1MtToPfMet_TauEnUp" not in self.complained:
        if not self.m1MtToPfMet_TauEnUp_branch and "m1MtToPfMet_TauEnUp":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_TauEnUp")
        else:
            self.m1MtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.m1MtToPfMet_TauEnUp_value)

        #print "making m1MtToPfMet_UnclusteredEnDown"
        self.m1MtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("m1MtToPfMet_UnclusteredEnDown")
        #if not self.m1MtToPfMet_UnclusteredEnDown_branch and "m1MtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.m1MtToPfMet_UnclusteredEnDown_branch and "m1MtToPfMet_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_UnclusteredEnDown")
        else:
            self.m1MtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.m1MtToPfMet_UnclusteredEnDown_value)

        #print "making m1MtToPfMet_UnclusteredEnUp"
        self.m1MtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("m1MtToPfMet_UnclusteredEnUp")
        #if not self.m1MtToPfMet_UnclusteredEnUp_branch and "m1MtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.m1MtToPfMet_UnclusteredEnUp_branch and "m1MtToPfMet_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_UnclusteredEnUp")
        else:
            self.m1MtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.m1MtToPfMet_UnclusteredEnUp_value)

        #print "making m1MtToPfMet_type1"
        self.m1MtToPfMet_type1_branch = the_tree.GetBranch("m1MtToPfMet_type1")
        #if not self.m1MtToPfMet_type1_branch and "m1MtToPfMet_type1" not in self.complained:
        if not self.m1MtToPfMet_type1_branch and "m1MtToPfMet_type1":
            warnings.warn( "MMMTree: Expected branch m1MtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MtToPfMet_type1")
        else:
            self.m1MtToPfMet_type1_branch.SetAddress(<void*>&self.m1MtToPfMet_type1_value)

        #print "making m1MuonHits"
        self.m1MuonHits_branch = the_tree.GetBranch("m1MuonHits")
        #if not self.m1MuonHits_branch and "m1MuonHits" not in self.complained:
        if not self.m1MuonHits_branch and "m1MuonHits":
            warnings.warn( "MMMTree: Expected branch m1MuonHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1MuonHits")
        else:
            self.m1MuonHits_branch.SetAddress(<void*>&self.m1MuonHits_value)

        #print "making m1NearestZMass"
        self.m1NearestZMass_branch = the_tree.GetBranch("m1NearestZMass")
        #if not self.m1NearestZMass_branch and "m1NearestZMass" not in self.complained:
        if not self.m1NearestZMass_branch and "m1NearestZMass":
            warnings.warn( "MMMTree: Expected branch m1NearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1NearestZMass")
        else:
            self.m1NearestZMass_branch.SetAddress(<void*>&self.m1NearestZMass_value)

        #print "making m1NormTrkChi2"
        self.m1NormTrkChi2_branch = the_tree.GetBranch("m1NormTrkChi2")
        #if not self.m1NormTrkChi2_branch and "m1NormTrkChi2" not in self.complained:
        if not self.m1NormTrkChi2_branch and "m1NormTrkChi2":
            warnings.warn( "MMMTree: Expected branch m1NormTrkChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1NormTrkChi2")
        else:
            self.m1NormTrkChi2_branch.SetAddress(<void*>&self.m1NormTrkChi2_value)

        #print "making m1PFChargedIso"
        self.m1PFChargedIso_branch = the_tree.GetBranch("m1PFChargedIso")
        #if not self.m1PFChargedIso_branch and "m1PFChargedIso" not in self.complained:
        if not self.m1PFChargedIso_branch and "m1PFChargedIso":
            warnings.warn( "MMMTree: Expected branch m1PFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PFChargedIso")
        else:
            self.m1PFChargedIso_branch.SetAddress(<void*>&self.m1PFChargedIso_value)

        #print "making m1PFIDLoose"
        self.m1PFIDLoose_branch = the_tree.GetBranch("m1PFIDLoose")
        #if not self.m1PFIDLoose_branch and "m1PFIDLoose" not in self.complained:
        if not self.m1PFIDLoose_branch and "m1PFIDLoose":
            warnings.warn( "MMMTree: Expected branch m1PFIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PFIDLoose")
        else:
            self.m1PFIDLoose_branch.SetAddress(<void*>&self.m1PFIDLoose_value)

        #print "making m1PFIDMedium"
        self.m1PFIDMedium_branch = the_tree.GetBranch("m1PFIDMedium")
        #if not self.m1PFIDMedium_branch and "m1PFIDMedium" not in self.complained:
        if not self.m1PFIDMedium_branch and "m1PFIDMedium":
            warnings.warn( "MMMTree: Expected branch m1PFIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PFIDMedium")
        else:
            self.m1PFIDMedium_branch.SetAddress(<void*>&self.m1PFIDMedium_value)

        #print "making m1PFIDTight"
        self.m1PFIDTight_branch = the_tree.GetBranch("m1PFIDTight")
        #if not self.m1PFIDTight_branch and "m1PFIDTight" not in self.complained:
        if not self.m1PFIDTight_branch and "m1PFIDTight":
            warnings.warn( "MMMTree: Expected branch m1PFIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PFIDTight")
        else:
            self.m1PFIDTight_branch.SetAddress(<void*>&self.m1PFIDTight_value)

        #print "making m1PFNeutralIso"
        self.m1PFNeutralIso_branch = the_tree.GetBranch("m1PFNeutralIso")
        #if not self.m1PFNeutralIso_branch and "m1PFNeutralIso" not in self.complained:
        if not self.m1PFNeutralIso_branch and "m1PFNeutralIso":
            warnings.warn( "MMMTree: Expected branch m1PFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PFNeutralIso")
        else:
            self.m1PFNeutralIso_branch.SetAddress(<void*>&self.m1PFNeutralIso_value)

        #print "making m1PFPUChargedIso"
        self.m1PFPUChargedIso_branch = the_tree.GetBranch("m1PFPUChargedIso")
        #if not self.m1PFPUChargedIso_branch and "m1PFPUChargedIso" not in self.complained:
        if not self.m1PFPUChargedIso_branch and "m1PFPUChargedIso":
            warnings.warn( "MMMTree: Expected branch m1PFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PFPUChargedIso")
        else:
            self.m1PFPUChargedIso_branch.SetAddress(<void*>&self.m1PFPUChargedIso_value)

        #print "making m1PFPhotonIso"
        self.m1PFPhotonIso_branch = the_tree.GetBranch("m1PFPhotonIso")
        #if not self.m1PFPhotonIso_branch and "m1PFPhotonIso" not in self.complained:
        if not self.m1PFPhotonIso_branch and "m1PFPhotonIso":
            warnings.warn( "MMMTree: Expected branch m1PFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PFPhotonIso")
        else:
            self.m1PFPhotonIso_branch.SetAddress(<void*>&self.m1PFPhotonIso_value)

        #print "making m1PVDXY"
        self.m1PVDXY_branch = the_tree.GetBranch("m1PVDXY")
        #if not self.m1PVDXY_branch and "m1PVDXY" not in self.complained:
        if not self.m1PVDXY_branch and "m1PVDXY":
            warnings.warn( "MMMTree: Expected branch m1PVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PVDXY")
        else:
            self.m1PVDXY_branch.SetAddress(<void*>&self.m1PVDXY_value)

        #print "making m1PVDZ"
        self.m1PVDZ_branch = the_tree.GetBranch("m1PVDZ")
        #if not self.m1PVDZ_branch and "m1PVDZ" not in self.complained:
        if not self.m1PVDZ_branch and "m1PVDZ":
            warnings.warn( "MMMTree: Expected branch m1PVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PVDZ")
        else:
            self.m1PVDZ_branch.SetAddress(<void*>&self.m1PVDZ_value)

        #print "making m1Phi"
        self.m1Phi_branch = the_tree.GetBranch("m1Phi")
        #if not self.m1Phi_branch and "m1Phi" not in self.complained:
        if not self.m1Phi_branch and "m1Phi":
            warnings.warn( "MMMTree: Expected branch m1Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Phi")
        else:
            self.m1Phi_branch.SetAddress(<void*>&self.m1Phi_value)

        #print "making m1Phi_MuonEnDown"
        self.m1Phi_MuonEnDown_branch = the_tree.GetBranch("m1Phi_MuonEnDown")
        #if not self.m1Phi_MuonEnDown_branch and "m1Phi_MuonEnDown" not in self.complained:
        if not self.m1Phi_MuonEnDown_branch and "m1Phi_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m1Phi_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Phi_MuonEnDown")
        else:
            self.m1Phi_MuonEnDown_branch.SetAddress(<void*>&self.m1Phi_MuonEnDown_value)

        #print "making m1Phi_MuonEnUp"
        self.m1Phi_MuonEnUp_branch = the_tree.GetBranch("m1Phi_MuonEnUp")
        #if not self.m1Phi_MuonEnUp_branch and "m1Phi_MuonEnUp" not in self.complained:
        if not self.m1Phi_MuonEnUp_branch and "m1Phi_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m1Phi_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Phi_MuonEnUp")
        else:
            self.m1Phi_MuonEnUp_branch.SetAddress(<void*>&self.m1Phi_MuonEnUp_value)

        #print "making m1PixHits"
        self.m1PixHits_branch = the_tree.GetBranch("m1PixHits")
        #if not self.m1PixHits_branch and "m1PixHits" not in self.complained:
        if not self.m1PixHits_branch and "m1PixHits":
            warnings.warn( "MMMTree: Expected branch m1PixHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1PixHits")
        else:
            self.m1PixHits_branch.SetAddress(<void*>&self.m1PixHits_value)

        #print "making m1Pt"
        self.m1Pt_branch = the_tree.GetBranch("m1Pt")
        #if not self.m1Pt_branch and "m1Pt" not in self.complained:
        if not self.m1Pt_branch and "m1Pt":
            warnings.warn( "MMMTree: Expected branch m1Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Pt")
        else:
            self.m1Pt_branch.SetAddress(<void*>&self.m1Pt_value)

        #print "making m1Pt_MuonEnDown"
        self.m1Pt_MuonEnDown_branch = the_tree.GetBranch("m1Pt_MuonEnDown")
        #if not self.m1Pt_MuonEnDown_branch and "m1Pt_MuonEnDown" not in self.complained:
        if not self.m1Pt_MuonEnDown_branch and "m1Pt_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m1Pt_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Pt_MuonEnDown")
        else:
            self.m1Pt_MuonEnDown_branch.SetAddress(<void*>&self.m1Pt_MuonEnDown_value)

        #print "making m1Pt_MuonEnUp"
        self.m1Pt_MuonEnUp_branch = the_tree.GetBranch("m1Pt_MuonEnUp")
        #if not self.m1Pt_MuonEnUp_branch and "m1Pt_MuonEnUp" not in self.complained:
        if not self.m1Pt_MuonEnUp_branch and "m1Pt_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m1Pt_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Pt_MuonEnUp")
        else:
            self.m1Pt_MuonEnUp_branch.SetAddress(<void*>&self.m1Pt_MuonEnUp_value)

        #print "making m1Rank"
        self.m1Rank_branch = the_tree.GetBranch("m1Rank")
        #if not self.m1Rank_branch and "m1Rank" not in self.complained:
        if not self.m1Rank_branch and "m1Rank":
            warnings.warn( "MMMTree: Expected branch m1Rank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Rank")
        else:
            self.m1Rank_branch.SetAddress(<void*>&self.m1Rank_value)

        #print "making m1RelPFIsoDBDefault"
        self.m1RelPFIsoDBDefault_branch = the_tree.GetBranch("m1RelPFIsoDBDefault")
        #if not self.m1RelPFIsoDBDefault_branch and "m1RelPFIsoDBDefault" not in self.complained:
        if not self.m1RelPFIsoDBDefault_branch and "m1RelPFIsoDBDefault":
            warnings.warn( "MMMTree: Expected branch m1RelPFIsoDBDefault does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1RelPFIsoDBDefault")
        else:
            self.m1RelPFIsoDBDefault_branch.SetAddress(<void*>&self.m1RelPFIsoDBDefault_value)

        #print "making m1RelPFIsoRho"
        self.m1RelPFIsoRho_branch = the_tree.GetBranch("m1RelPFIsoRho")
        #if not self.m1RelPFIsoRho_branch and "m1RelPFIsoRho" not in self.complained:
        if not self.m1RelPFIsoRho_branch and "m1RelPFIsoRho":
            warnings.warn( "MMMTree: Expected branch m1RelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1RelPFIsoRho")
        else:
            self.m1RelPFIsoRho_branch.SetAddress(<void*>&self.m1RelPFIsoRho_value)

        #print "making m1Rho"
        self.m1Rho_branch = the_tree.GetBranch("m1Rho")
        #if not self.m1Rho_branch and "m1Rho" not in self.complained:
        if not self.m1Rho_branch and "m1Rho":
            warnings.warn( "MMMTree: Expected branch m1Rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1Rho")
        else:
            self.m1Rho_branch.SetAddress(<void*>&self.m1Rho_value)

        #print "making m1SIP2D"
        self.m1SIP2D_branch = the_tree.GetBranch("m1SIP2D")
        #if not self.m1SIP2D_branch and "m1SIP2D" not in self.complained:
        if not self.m1SIP2D_branch and "m1SIP2D":
            warnings.warn( "MMMTree: Expected branch m1SIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1SIP2D")
        else:
            self.m1SIP2D_branch.SetAddress(<void*>&self.m1SIP2D_value)

        #print "making m1SIP3D"
        self.m1SIP3D_branch = the_tree.GetBranch("m1SIP3D")
        #if not self.m1SIP3D_branch and "m1SIP3D" not in self.complained:
        if not self.m1SIP3D_branch and "m1SIP3D":
            warnings.warn( "MMMTree: Expected branch m1SIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1SIP3D")
        else:
            self.m1SIP3D_branch.SetAddress(<void*>&self.m1SIP3D_value)

        #print "making m1TkLayersWithMeasurement"
        self.m1TkLayersWithMeasurement_branch = the_tree.GetBranch("m1TkLayersWithMeasurement")
        #if not self.m1TkLayersWithMeasurement_branch and "m1TkLayersWithMeasurement" not in self.complained:
        if not self.m1TkLayersWithMeasurement_branch and "m1TkLayersWithMeasurement":
            warnings.warn( "MMMTree: Expected branch m1TkLayersWithMeasurement does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1TkLayersWithMeasurement")
        else:
            self.m1TkLayersWithMeasurement_branch.SetAddress(<void*>&self.m1TkLayersWithMeasurement_value)

        #print "making m1TrkIsoDR03"
        self.m1TrkIsoDR03_branch = the_tree.GetBranch("m1TrkIsoDR03")
        #if not self.m1TrkIsoDR03_branch and "m1TrkIsoDR03" not in self.complained:
        if not self.m1TrkIsoDR03_branch and "m1TrkIsoDR03":
            warnings.warn( "MMMTree: Expected branch m1TrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1TrkIsoDR03")
        else:
            self.m1TrkIsoDR03_branch.SetAddress(<void*>&self.m1TrkIsoDR03_value)

        #print "making m1TypeCode"
        self.m1TypeCode_branch = the_tree.GetBranch("m1TypeCode")
        #if not self.m1TypeCode_branch and "m1TypeCode" not in self.complained:
        if not self.m1TypeCode_branch and "m1TypeCode":
            warnings.warn( "MMMTree: Expected branch m1TypeCode does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1TypeCode")
        else:
            self.m1TypeCode_branch.SetAddress(<void*>&self.m1TypeCode_value)

        #print "making m1VZ"
        self.m1VZ_branch = the_tree.GetBranch("m1VZ")
        #if not self.m1VZ_branch and "m1VZ" not in self.complained:
        if not self.m1VZ_branch and "m1VZ":
            warnings.warn( "MMMTree: Expected branch m1VZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1VZ")
        else:
            self.m1VZ_branch.SetAddress(<void*>&self.m1VZ_value)

        #print "making m1_m2_CosThetaStar"
        self.m1_m2_CosThetaStar_branch = the_tree.GetBranch("m1_m2_CosThetaStar")
        #if not self.m1_m2_CosThetaStar_branch and "m1_m2_CosThetaStar" not in self.complained:
        if not self.m1_m2_CosThetaStar_branch and "m1_m2_CosThetaStar":
            warnings.warn( "MMMTree: Expected branch m1_m2_CosThetaStar does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_CosThetaStar")
        else:
            self.m1_m2_CosThetaStar_branch.SetAddress(<void*>&self.m1_m2_CosThetaStar_value)

        #print "making m1_m2_DPhi"
        self.m1_m2_DPhi_branch = the_tree.GetBranch("m1_m2_DPhi")
        #if not self.m1_m2_DPhi_branch and "m1_m2_DPhi" not in self.complained:
        if not self.m1_m2_DPhi_branch and "m1_m2_DPhi":
            warnings.warn( "MMMTree: Expected branch m1_m2_DPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_DPhi")
        else:
            self.m1_m2_DPhi_branch.SetAddress(<void*>&self.m1_m2_DPhi_value)

        #print "making m1_m2_DR"
        self.m1_m2_DR_branch = the_tree.GetBranch("m1_m2_DR")
        #if not self.m1_m2_DR_branch and "m1_m2_DR" not in self.complained:
        if not self.m1_m2_DR_branch and "m1_m2_DR":
            warnings.warn( "MMMTree: Expected branch m1_m2_DR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_DR")
        else:
            self.m1_m2_DR_branch.SetAddress(<void*>&self.m1_m2_DR_value)

        #print "making m1_m2_Eta"
        self.m1_m2_Eta_branch = the_tree.GetBranch("m1_m2_Eta")
        #if not self.m1_m2_Eta_branch and "m1_m2_Eta" not in self.complained:
        if not self.m1_m2_Eta_branch and "m1_m2_Eta":
            warnings.warn( "MMMTree: Expected branch m1_m2_Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_Eta")
        else:
            self.m1_m2_Eta_branch.SetAddress(<void*>&self.m1_m2_Eta_value)

        #print "making m1_m2_Mass"
        self.m1_m2_Mass_branch = the_tree.GetBranch("m1_m2_Mass")
        #if not self.m1_m2_Mass_branch and "m1_m2_Mass" not in self.complained:
        if not self.m1_m2_Mass_branch and "m1_m2_Mass":
            warnings.warn( "MMMTree: Expected branch m1_m2_Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_Mass")
        else:
            self.m1_m2_Mass_branch.SetAddress(<void*>&self.m1_m2_Mass_value)

        #print "making m1_m2_Mt"
        self.m1_m2_Mt_branch = the_tree.GetBranch("m1_m2_Mt")
        #if not self.m1_m2_Mt_branch and "m1_m2_Mt" not in self.complained:
        if not self.m1_m2_Mt_branch and "m1_m2_Mt":
            warnings.warn( "MMMTree: Expected branch m1_m2_Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_Mt")
        else:
            self.m1_m2_Mt_branch.SetAddress(<void*>&self.m1_m2_Mt_value)

        #print "making m1_m2_PZeta"
        self.m1_m2_PZeta_branch = the_tree.GetBranch("m1_m2_PZeta")
        #if not self.m1_m2_PZeta_branch and "m1_m2_PZeta" not in self.complained:
        if not self.m1_m2_PZeta_branch and "m1_m2_PZeta":
            warnings.warn( "MMMTree: Expected branch m1_m2_PZeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_PZeta")
        else:
            self.m1_m2_PZeta_branch.SetAddress(<void*>&self.m1_m2_PZeta_value)

        #print "making m1_m2_PZetaVis"
        self.m1_m2_PZetaVis_branch = the_tree.GetBranch("m1_m2_PZetaVis")
        #if not self.m1_m2_PZetaVis_branch and "m1_m2_PZetaVis" not in self.complained:
        if not self.m1_m2_PZetaVis_branch and "m1_m2_PZetaVis":
            warnings.warn( "MMMTree: Expected branch m1_m2_PZetaVis does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_PZetaVis")
        else:
            self.m1_m2_PZetaVis_branch.SetAddress(<void*>&self.m1_m2_PZetaVis_value)

        #print "making m1_m2_Phi"
        self.m1_m2_Phi_branch = the_tree.GetBranch("m1_m2_Phi")
        #if not self.m1_m2_Phi_branch and "m1_m2_Phi" not in self.complained:
        if not self.m1_m2_Phi_branch and "m1_m2_Phi":
            warnings.warn( "MMMTree: Expected branch m1_m2_Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_Phi")
        else:
            self.m1_m2_Phi_branch.SetAddress(<void*>&self.m1_m2_Phi_value)

        #print "making m1_m2_Pt"
        self.m1_m2_Pt_branch = the_tree.GetBranch("m1_m2_Pt")
        #if not self.m1_m2_Pt_branch and "m1_m2_Pt" not in self.complained:
        if not self.m1_m2_Pt_branch and "m1_m2_Pt":
            warnings.warn( "MMMTree: Expected branch m1_m2_Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_Pt")
        else:
            self.m1_m2_Pt_branch.SetAddress(<void*>&self.m1_m2_Pt_value)

        #print "making m1_m2_SS"
        self.m1_m2_SS_branch = the_tree.GetBranch("m1_m2_SS")
        #if not self.m1_m2_SS_branch and "m1_m2_SS" not in self.complained:
        if not self.m1_m2_SS_branch and "m1_m2_SS":
            warnings.warn( "MMMTree: Expected branch m1_m2_SS does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_SS")
        else:
            self.m1_m2_SS_branch.SetAddress(<void*>&self.m1_m2_SS_value)

        #print "making m1_m2_ToMETDPhi_Ty1"
        self.m1_m2_ToMETDPhi_Ty1_branch = the_tree.GetBranch("m1_m2_ToMETDPhi_Ty1")
        #if not self.m1_m2_ToMETDPhi_Ty1_branch and "m1_m2_ToMETDPhi_Ty1" not in self.complained:
        if not self.m1_m2_ToMETDPhi_Ty1_branch and "m1_m2_ToMETDPhi_Ty1":
            warnings.warn( "MMMTree: Expected branch m1_m2_ToMETDPhi_Ty1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_ToMETDPhi_Ty1")
        else:
            self.m1_m2_ToMETDPhi_Ty1_branch.SetAddress(<void*>&self.m1_m2_ToMETDPhi_Ty1_value)

        #print "making m1_m2_collinearmass"
        self.m1_m2_collinearmass_branch = the_tree.GetBranch("m1_m2_collinearmass")
        #if not self.m1_m2_collinearmass_branch and "m1_m2_collinearmass" not in self.complained:
        if not self.m1_m2_collinearmass_branch and "m1_m2_collinearmass":
            warnings.warn( "MMMTree: Expected branch m1_m2_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_collinearmass")
        else:
            self.m1_m2_collinearmass_branch.SetAddress(<void*>&self.m1_m2_collinearmass_value)

        #print "making m1_m2_collinearmass_JetEnDown"
        self.m1_m2_collinearmass_JetEnDown_branch = the_tree.GetBranch("m1_m2_collinearmass_JetEnDown")
        #if not self.m1_m2_collinearmass_JetEnDown_branch and "m1_m2_collinearmass_JetEnDown" not in self.complained:
        if not self.m1_m2_collinearmass_JetEnDown_branch and "m1_m2_collinearmass_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m1_m2_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_collinearmass_JetEnDown")
        else:
            self.m1_m2_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.m1_m2_collinearmass_JetEnDown_value)

        #print "making m1_m2_collinearmass_JetEnUp"
        self.m1_m2_collinearmass_JetEnUp_branch = the_tree.GetBranch("m1_m2_collinearmass_JetEnUp")
        #if not self.m1_m2_collinearmass_JetEnUp_branch and "m1_m2_collinearmass_JetEnUp" not in self.complained:
        if not self.m1_m2_collinearmass_JetEnUp_branch and "m1_m2_collinearmass_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m1_m2_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_collinearmass_JetEnUp")
        else:
            self.m1_m2_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.m1_m2_collinearmass_JetEnUp_value)

        #print "making m1_m2_collinearmass_UnclusteredEnDown"
        self.m1_m2_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("m1_m2_collinearmass_UnclusteredEnDown")
        #if not self.m1_m2_collinearmass_UnclusteredEnDown_branch and "m1_m2_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.m1_m2_collinearmass_UnclusteredEnDown_branch and "m1_m2_collinearmass_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m1_m2_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_collinearmass_UnclusteredEnDown")
        else:
            self.m1_m2_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.m1_m2_collinearmass_UnclusteredEnDown_value)

        #print "making m1_m2_collinearmass_UnclusteredEnUp"
        self.m1_m2_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("m1_m2_collinearmass_UnclusteredEnUp")
        #if not self.m1_m2_collinearmass_UnclusteredEnUp_branch and "m1_m2_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.m1_m2_collinearmass_UnclusteredEnUp_branch and "m1_m2_collinearmass_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m1_m2_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m2_collinearmass_UnclusteredEnUp")
        else:
            self.m1_m2_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.m1_m2_collinearmass_UnclusteredEnUp_value)

        #print "making m1_m3_CosThetaStar"
        self.m1_m3_CosThetaStar_branch = the_tree.GetBranch("m1_m3_CosThetaStar")
        #if not self.m1_m3_CosThetaStar_branch and "m1_m3_CosThetaStar" not in self.complained:
        if not self.m1_m3_CosThetaStar_branch and "m1_m3_CosThetaStar":
            warnings.warn( "MMMTree: Expected branch m1_m3_CosThetaStar does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_CosThetaStar")
        else:
            self.m1_m3_CosThetaStar_branch.SetAddress(<void*>&self.m1_m3_CosThetaStar_value)

        #print "making m1_m3_DPhi"
        self.m1_m3_DPhi_branch = the_tree.GetBranch("m1_m3_DPhi")
        #if not self.m1_m3_DPhi_branch and "m1_m3_DPhi" not in self.complained:
        if not self.m1_m3_DPhi_branch and "m1_m3_DPhi":
            warnings.warn( "MMMTree: Expected branch m1_m3_DPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_DPhi")
        else:
            self.m1_m3_DPhi_branch.SetAddress(<void*>&self.m1_m3_DPhi_value)

        #print "making m1_m3_DR"
        self.m1_m3_DR_branch = the_tree.GetBranch("m1_m3_DR")
        #if not self.m1_m3_DR_branch and "m1_m3_DR" not in self.complained:
        if not self.m1_m3_DR_branch and "m1_m3_DR":
            warnings.warn( "MMMTree: Expected branch m1_m3_DR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_DR")
        else:
            self.m1_m3_DR_branch.SetAddress(<void*>&self.m1_m3_DR_value)

        #print "making m1_m3_Eta"
        self.m1_m3_Eta_branch = the_tree.GetBranch("m1_m3_Eta")
        #if not self.m1_m3_Eta_branch and "m1_m3_Eta" not in self.complained:
        if not self.m1_m3_Eta_branch and "m1_m3_Eta":
            warnings.warn( "MMMTree: Expected branch m1_m3_Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_Eta")
        else:
            self.m1_m3_Eta_branch.SetAddress(<void*>&self.m1_m3_Eta_value)

        #print "making m1_m3_Mass"
        self.m1_m3_Mass_branch = the_tree.GetBranch("m1_m3_Mass")
        #if not self.m1_m3_Mass_branch and "m1_m3_Mass" not in self.complained:
        if not self.m1_m3_Mass_branch and "m1_m3_Mass":
            warnings.warn( "MMMTree: Expected branch m1_m3_Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_Mass")
        else:
            self.m1_m3_Mass_branch.SetAddress(<void*>&self.m1_m3_Mass_value)

        #print "making m1_m3_Mt"
        self.m1_m3_Mt_branch = the_tree.GetBranch("m1_m3_Mt")
        #if not self.m1_m3_Mt_branch and "m1_m3_Mt" not in self.complained:
        if not self.m1_m3_Mt_branch and "m1_m3_Mt":
            warnings.warn( "MMMTree: Expected branch m1_m3_Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_Mt")
        else:
            self.m1_m3_Mt_branch.SetAddress(<void*>&self.m1_m3_Mt_value)

        #print "making m1_m3_PZeta"
        self.m1_m3_PZeta_branch = the_tree.GetBranch("m1_m3_PZeta")
        #if not self.m1_m3_PZeta_branch and "m1_m3_PZeta" not in self.complained:
        if not self.m1_m3_PZeta_branch and "m1_m3_PZeta":
            warnings.warn( "MMMTree: Expected branch m1_m3_PZeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_PZeta")
        else:
            self.m1_m3_PZeta_branch.SetAddress(<void*>&self.m1_m3_PZeta_value)

        #print "making m1_m3_PZetaVis"
        self.m1_m3_PZetaVis_branch = the_tree.GetBranch("m1_m3_PZetaVis")
        #if not self.m1_m3_PZetaVis_branch and "m1_m3_PZetaVis" not in self.complained:
        if not self.m1_m3_PZetaVis_branch and "m1_m3_PZetaVis":
            warnings.warn( "MMMTree: Expected branch m1_m3_PZetaVis does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_PZetaVis")
        else:
            self.m1_m3_PZetaVis_branch.SetAddress(<void*>&self.m1_m3_PZetaVis_value)

        #print "making m1_m3_Phi"
        self.m1_m3_Phi_branch = the_tree.GetBranch("m1_m3_Phi")
        #if not self.m1_m3_Phi_branch and "m1_m3_Phi" not in self.complained:
        if not self.m1_m3_Phi_branch and "m1_m3_Phi":
            warnings.warn( "MMMTree: Expected branch m1_m3_Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_Phi")
        else:
            self.m1_m3_Phi_branch.SetAddress(<void*>&self.m1_m3_Phi_value)

        #print "making m1_m3_Pt"
        self.m1_m3_Pt_branch = the_tree.GetBranch("m1_m3_Pt")
        #if not self.m1_m3_Pt_branch and "m1_m3_Pt" not in self.complained:
        if not self.m1_m3_Pt_branch and "m1_m3_Pt":
            warnings.warn( "MMMTree: Expected branch m1_m3_Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_Pt")
        else:
            self.m1_m3_Pt_branch.SetAddress(<void*>&self.m1_m3_Pt_value)

        #print "making m1_m3_SS"
        self.m1_m3_SS_branch = the_tree.GetBranch("m1_m3_SS")
        #if not self.m1_m3_SS_branch and "m1_m3_SS" not in self.complained:
        if not self.m1_m3_SS_branch and "m1_m3_SS":
            warnings.warn( "MMMTree: Expected branch m1_m3_SS does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_SS")
        else:
            self.m1_m3_SS_branch.SetAddress(<void*>&self.m1_m3_SS_value)

        #print "making m1_m3_ToMETDPhi_Ty1"
        self.m1_m3_ToMETDPhi_Ty1_branch = the_tree.GetBranch("m1_m3_ToMETDPhi_Ty1")
        #if not self.m1_m3_ToMETDPhi_Ty1_branch and "m1_m3_ToMETDPhi_Ty1" not in self.complained:
        if not self.m1_m3_ToMETDPhi_Ty1_branch and "m1_m3_ToMETDPhi_Ty1":
            warnings.warn( "MMMTree: Expected branch m1_m3_ToMETDPhi_Ty1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_ToMETDPhi_Ty1")
        else:
            self.m1_m3_ToMETDPhi_Ty1_branch.SetAddress(<void*>&self.m1_m3_ToMETDPhi_Ty1_value)

        #print "making m1_m3_collinearmass"
        self.m1_m3_collinearmass_branch = the_tree.GetBranch("m1_m3_collinearmass")
        #if not self.m1_m3_collinearmass_branch and "m1_m3_collinearmass" not in self.complained:
        if not self.m1_m3_collinearmass_branch and "m1_m3_collinearmass":
            warnings.warn( "MMMTree: Expected branch m1_m3_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_collinearmass")
        else:
            self.m1_m3_collinearmass_branch.SetAddress(<void*>&self.m1_m3_collinearmass_value)

        #print "making m1_m3_collinearmass_JetEnDown"
        self.m1_m3_collinearmass_JetEnDown_branch = the_tree.GetBranch("m1_m3_collinearmass_JetEnDown")
        #if not self.m1_m3_collinearmass_JetEnDown_branch and "m1_m3_collinearmass_JetEnDown" not in self.complained:
        if not self.m1_m3_collinearmass_JetEnDown_branch and "m1_m3_collinearmass_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m1_m3_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_collinearmass_JetEnDown")
        else:
            self.m1_m3_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.m1_m3_collinearmass_JetEnDown_value)

        #print "making m1_m3_collinearmass_JetEnUp"
        self.m1_m3_collinearmass_JetEnUp_branch = the_tree.GetBranch("m1_m3_collinearmass_JetEnUp")
        #if not self.m1_m3_collinearmass_JetEnUp_branch and "m1_m3_collinearmass_JetEnUp" not in self.complained:
        if not self.m1_m3_collinearmass_JetEnUp_branch and "m1_m3_collinearmass_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m1_m3_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_collinearmass_JetEnUp")
        else:
            self.m1_m3_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.m1_m3_collinearmass_JetEnUp_value)

        #print "making m1_m3_collinearmass_UnclusteredEnDown"
        self.m1_m3_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("m1_m3_collinearmass_UnclusteredEnDown")
        #if not self.m1_m3_collinearmass_UnclusteredEnDown_branch and "m1_m3_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.m1_m3_collinearmass_UnclusteredEnDown_branch and "m1_m3_collinearmass_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m1_m3_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_collinearmass_UnclusteredEnDown")
        else:
            self.m1_m3_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.m1_m3_collinearmass_UnclusteredEnDown_value)

        #print "making m1_m3_collinearmass_UnclusteredEnUp"
        self.m1_m3_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("m1_m3_collinearmass_UnclusteredEnUp")
        #if not self.m1_m3_collinearmass_UnclusteredEnUp_branch and "m1_m3_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.m1_m3_collinearmass_UnclusteredEnUp_branch and "m1_m3_collinearmass_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m1_m3_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m1_m3_collinearmass_UnclusteredEnUp")
        else:
            self.m1_m3_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.m1_m3_collinearmass_UnclusteredEnUp_value)

        #print "making m2AbsEta"
        self.m2AbsEta_branch = the_tree.GetBranch("m2AbsEta")
        #if not self.m2AbsEta_branch and "m2AbsEta" not in self.complained:
        if not self.m2AbsEta_branch and "m2AbsEta":
            warnings.warn( "MMMTree: Expected branch m2AbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2AbsEta")
        else:
            self.m2AbsEta_branch.SetAddress(<void*>&self.m2AbsEta_value)

        #print "making m2BestTrackType"
        self.m2BestTrackType_branch = the_tree.GetBranch("m2BestTrackType")
        #if not self.m2BestTrackType_branch and "m2BestTrackType" not in self.complained:
        if not self.m2BestTrackType_branch and "m2BestTrackType":
            warnings.warn( "MMMTree: Expected branch m2BestTrackType does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2BestTrackType")
        else:
            self.m2BestTrackType_branch.SetAddress(<void*>&self.m2BestTrackType_value)

        #print "making m2Charge"
        self.m2Charge_branch = the_tree.GetBranch("m2Charge")
        #if not self.m2Charge_branch and "m2Charge" not in self.complained:
        if not self.m2Charge_branch and "m2Charge":
            warnings.warn( "MMMTree: Expected branch m2Charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Charge")
        else:
            self.m2Charge_branch.SetAddress(<void*>&self.m2Charge_value)

        #print "making m2ComesFromHiggs"
        self.m2ComesFromHiggs_branch = the_tree.GetBranch("m2ComesFromHiggs")
        #if not self.m2ComesFromHiggs_branch and "m2ComesFromHiggs" not in self.complained:
        if not self.m2ComesFromHiggs_branch and "m2ComesFromHiggs":
            warnings.warn( "MMMTree: Expected branch m2ComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2ComesFromHiggs")
        else:
            self.m2ComesFromHiggs_branch.SetAddress(<void*>&self.m2ComesFromHiggs_value)

        #print "making m2DPhiToPfMet_ElectronEnDown"
        self.m2DPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("m2DPhiToPfMet_ElectronEnDown")
        #if not self.m2DPhiToPfMet_ElectronEnDown_branch and "m2DPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.m2DPhiToPfMet_ElectronEnDown_branch and "m2DPhiToPfMet_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_ElectronEnDown")
        else:
            self.m2DPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.m2DPhiToPfMet_ElectronEnDown_value)

        #print "making m2DPhiToPfMet_ElectronEnUp"
        self.m2DPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("m2DPhiToPfMet_ElectronEnUp")
        #if not self.m2DPhiToPfMet_ElectronEnUp_branch and "m2DPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.m2DPhiToPfMet_ElectronEnUp_branch and "m2DPhiToPfMet_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_ElectronEnUp")
        else:
            self.m2DPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.m2DPhiToPfMet_ElectronEnUp_value)

        #print "making m2DPhiToPfMet_JetEnDown"
        self.m2DPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("m2DPhiToPfMet_JetEnDown")
        #if not self.m2DPhiToPfMet_JetEnDown_branch and "m2DPhiToPfMet_JetEnDown" not in self.complained:
        if not self.m2DPhiToPfMet_JetEnDown_branch and "m2DPhiToPfMet_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_JetEnDown")
        else:
            self.m2DPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.m2DPhiToPfMet_JetEnDown_value)

        #print "making m2DPhiToPfMet_JetEnUp"
        self.m2DPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("m2DPhiToPfMet_JetEnUp")
        #if not self.m2DPhiToPfMet_JetEnUp_branch and "m2DPhiToPfMet_JetEnUp" not in self.complained:
        if not self.m2DPhiToPfMet_JetEnUp_branch and "m2DPhiToPfMet_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_JetEnUp")
        else:
            self.m2DPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.m2DPhiToPfMet_JetEnUp_value)

        #print "making m2DPhiToPfMet_JetResDown"
        self.m2DPhiToPfMet_JetResDown_branch = the_tree.GetBranch("m2DPhiToPfMet_JetResDown")
        #if not self.m2DPhiToPfMet_JetResDown_branch and "m2DPhiToPfMet_JetResDown" not in self.complained:
        if not self.m2DPhiToPfMet_JetResDown_branch and "m2DPhiToPfMet_JetResDown":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_JetResDown")
        else:
            self.m2DPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.m2DPhiToPfMet_JetResDown_value)

        #print "making m2DPhiToPfMet_JetResUp"
        self.m2DPhiToPfMet_JetResUp_branch = the_tree.GetBranch("m2DPhiToPfMet_JetResUp")
        #if not self.m2DPhiToPfMet_JetResUp_branch and "m2DPhiToPfMet_JetResUp" not in self.complained:
        if not self.m2DPhiToPfMet_JetResUp_branch and "m2DPhiToPfMet_JetResUp":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_JetResUp")
        else:
            self.m2DPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.m2DPhiToPfMet_JetResUp_value)

        #print "making m2DPhiToPfMet_MuonEnDown"
        self.m2DPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("m2DPhiToPfMet_MuonEnDown")
        #if not self.m2DPhiToPfMet_MuonEnDown_branch and "m2DPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.m2DPhiToPfMet_MuonEnDown_branch and "m2DPhiToPfMet_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_MuonEnDown")
        else:
            self.m2DPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.m2DPhiToPfMet_MuonEnDown_value)

        #print "making m2DPhiToPfMet_MuonEnUp"
        self.m2DPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("m2DPhiToPfMet_MuonEnUp")
        #if not self.m2DPhiToPfMet_MuonEnUp_branch and "m2DPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.m2DPhiToPfMet_MuonEnUp_branch and "m2DPhiToPfMet_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_MuonEnUp")
        else:
            self.m2DPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.m2DPhiToPfMet_MuonEnUp_value)

        #print "making m2DPhiToPfMet_PhotonEnDown"
        self.m2DPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("m2DPhiToPfMet_PhotonEnDown")
        #if not self.m2DPhiToPfMet_PhotonEnDown_branch and "m2DPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.m2DPhiToPfMet_PhotonEnDown_branch and "m2DPhiToPfMet_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_PhotonEnDown")
        else:
            self.m2DPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.m2DPhiToPfMet_PhotonEnDown_value)

        #print "making m2DPhiToPfMet_PhotonEnUp"
        self.m2DPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("m2DPhiToPfMet_PhotonEnUp")
        #if not self.m2DPhiToPfMet_PhotonEnUp_branch and "m2DPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.m2DPhiToPfMet_PhotonEnUp_branch and "m2DPhiToPfMet_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_PhotonEnUp")
        else:
            self.m2DPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.m2DPhiToPfMet_PhotonEnUp_value)

        #print "making m2DPhiToPfMet_TauEnDown"
        self.m2DPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("m2DPhiToPfMet_TauEnDown")
        #if not self.m2DPhiToPfMet_TauEnDown_branch and "m2DPhiToPfMet_TauEnDown" not in self.complained:
        if not self.m2DPhiToPfMet_TauEnDown_branch and "m2DPhiToPfMet_TauEnDown":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_TauEnDown")
        else:
            self.m2DPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.m2DPhiToPfMet_TauEnDown_value)

        #print "making m2DPhiToPfMet_TauEnUp"
        self.m2DPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("m2DPhiToPfMet_TauEnUp")
        #if not self.m2DPhiToPfMet_TauEnUp_branch and "m2DPhiToPfMet_TauEnUp" not in self.complained:
        if not self.m2DPhiToPfMet_TauEnUp_branch and "m2DPhiToPfMet_TauEnUp":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_TauEnUp")
        else:
            self.m2DPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.m2DPhiToPfMet_TauEnUp_value)

        #print "making m2DPhiToPfMet_UnclusteredEnDown"
        self.m2DPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("m2DPhiToPfMet_UnclusteredEnDown")
        #if not self.m2DPhiToPfMet_UnclusteredEnDown_branch and "m2DPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.m2DPhiToPfMet_UnclusteredEnDown_branch and "m2DPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_UnclusteredEnDown")
        else:
            self.m2DPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.m2DPhiToPfMet_UnclusteredEnDown_value)

        #print "making m2DPhiToPfMet_UnclusteredEnUp"
        self.m2DPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("m2DPhiToPfMet_UnclusteredEnUp")
        #if not self.m2DPhiToPfMet_UnclusteredEnUp_branch and "m2DPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.m2DPhiToPfMet_UnclusteredEnUp_branch and "m2DPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_UnclusteredEnUp")
        else:
            self.m2DPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.m2DPhiToPfMet_UnclusteredEnUp_value)

        #print "making m2DPhiToPfMet_type1"
        self.m2DPhiToPfMet_type1_branch = the_tree.GetBranch("m2DPhiToPfMet_type1")
        #if not self.m2DPhiToPfMet_type1_branch and "m2DPhiToPfMet_type1" not in self.complained:
        if not self.m2DPhiToPfMet_type1_branch and "m2DPhiToPfMet_type1":
            warnings.warn( "MMMTree: Expected branch m2DPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2DPhiToPfMet_type1")
        else:
            self.m2DPhiToPfMet_type1_branch.SetAddress(<void*>&self.m2DPhiToPfMet_type1_value)

        #print "making m2EcalIsoDR03"
        self.m2EcalIsoDR03_branch = the_tree.GetBranch("m2EcalIsoDR03")
        #if not self.m2EcalIsoDR03_branch and "m2EcalIsoDR03" not in self.complained:
        if not self.m2EcalIsoDR03_branch and "m2EcalIsoDR03":
            warnings.warn( "MMMTree: Expected branch m2EcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2EcalIsoDR03")
        else:
            self.m2EcalIsoDR03_branch.SetAddress(<void*>&self.m2EcalIsoDR03_value)

        #print "making m2EffectiveArea2011"
        self.m2EffectiveArea2011_branch = the_tree.GetBranch("m2EffectiveArea2011")
        #if not self.m2EffectiveArea2011_branch and "m2EffectiveArea2011" not in self.complained:
        if not self.m2EffectiveArea2011_branch and "m2EffectiveArea2011":
            warnings.warn( "MMMTree: Expected branch m2EffectiveArea2011 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2EffectiveArea2011")
        else:
            self.m2EffectiveArea2011_branch.SetAddress(<void*>&self.m2EffectiveArea2011_value)

        #print "making m2EffectiveArea2012"
        self.m2EffectiveArea2012_branch = the_tree.GetBranch("m2EffectiveArea2012")
        #if not self.m2EffectiveArea2012_branch and "m2EffectiveArea2012" not in self.complained:
        if not self.m2EffectiveArea2012_branch and "m2EffectiveArea2012":
            warnings.warn( "MMMTree: Expected branch m2EffectiveArea2012 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2EffectiveArea2012")
        else:
            self.m2EffectiveArea2012_branch.SetAddress(<void*>&self.m2EffectiveArea2012_value)

        #print "making m2Eta"
        self.m2Eta_branch = the_tree.GetBranch("m2Eta")
        #if not self.m2Eta_branch and "m2Eta" not in self.complained:
        if not self.m2Eta_branch and "m2Eta":
            warnings.warn( "MMMTree: Expected branch m2Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Eta")
        else:
            self.m2Eta_branch.SetAddress(<void*>&self.m2Eta_value)

        #print "making m2Eta_MuonEnDown"
        self.m2Eta_MuonEnDown_branch = the_tree.GetBranch("m2Eta_MuonEnDown")
        #if not self.m2Eta_MuonEnDown_branch and "m2Eta_MuonEnDown" not in self.complained:
        if not self.m2Eta_MuonEnDown_branch and "m2Eta_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m2Eta_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Eta_MuonEnDown")
        else:
            self.m2Eta_MuonEnDown_branch.SetAddress(<void*>&self.m2Eta_MuonEnDown_value)

        #print "making m2Eta_MuonEnUp"
        self.m2Eta_MuonEnUp_branch = the_tree.GetBranch("m2Eta_MuonEnUp")
        #if not self.m2Eta_MuonEnUp_branch and "m2Eta_MuonEnUp" not in self.complained:
        if not self.m2Eta_MuonEnUp_branch and "m2Eta_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m2Eta_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Eta_MuonEnUp")
        else:
            self.m2Eta_MuonEnUp_branch.SetAddress(<void*>&self.m2Eta_MuonEnUp_value)

        #print "making m2GenCharge"
        self.m2GenCharge_branch = the_tree.GetBranch("m2GenCharge")
        #if not self.m2GenCharge_branch and "m2GenCharge" not in self.complained:
        if not self.m2GenCharge_branch and "m2GenCharge":
            warnings.warn( "MMMTree: Expected branch m2GenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenCharge")
        else:
            self.m2GenCharge_branch.SetAddress(<void*>&self.m2GenCharge_value)

        #print "making m2GenEnergy"
        self.m2GenEnergy_branch = the_tree.GetBranch("m2GenEnergy")
        #if not self.m2GenEnergy_branch and "m2GenEnergy" not in self.complained:
        if not self.m2GenEnergy_branch and "m2GenEnergy":
            warnings.warn( "MMMTree: Expected branch m2GenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenEnergy")
        else:
            self.m2GenEnergy_branch.SetAddress(<void*>&self.m2GenEnergy_value)

        #print "making m2GenEta"
        self.m2GenEta_branch = the_tree.GetBranch("m2GenEta")
        #if not self.m2GenEta_branch and "m2GenEta" not in self.complained:
        if not self.m2GenEta_branch and "m2GenEta":
            warnings.warn( "MMMTree: Expected branch m2GenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenEta")
        else:
            self.m2GenEta_branch.SetAddress(<void*>&self.m2GenEta_value)

        #print "making m2GenMotherPdgId"
        self.m2GenMotherPdgId_branch = the_tree.GetBranch("m2GenMotherPdgId")
        #if not self.m2GenMotherPdgId_branch and "m2GenMotherPdgId" not in self.complained:
        if not self.m2GenMotherPdgId_branch and "m2GenMotherPdgId":
            warnings.warn( "MMMTree: Expected branch m2GenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenMotherPdgId")
        else:
            self.m2GenMotherPdgId_branch.SetAddress(<void*>&self.m2GenMotherPdgId_value)

        #print "making m2GenPdgId"
        self.m2GenPdgId_branch = the_tree.GetBranch("m2GenPdgId")
        #if not self.m2GenPdgId_branch and "m2GenPdgId" not in self.complained:
        if not self.m2GenPdgId_branch and "m2GenPdgId":
            warnings.warn( "MMMTree: Expected branch m2GenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenPdgId")
        else:
            self.m2GenPdgId_branch.SetAddress(<void*>&self.m2GenPdgId_value)

        #print "making m2GenPhi"
        self.m2GenPhi_branch = the_tree.GetBranch("m2GenPhi")
        #if not self.m2GenPhi_branch and "m2GenPhi" not in self.complained:
        if not self.m2GenPhi_branch and "m2GenPhi":
            warnings.warn( "MMMTree: Expected branch m2GenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenPhi")
        else:
            self.m2GenPhi_branch.SetAddress(<void*>&self.m2GenPhi_value)

        #print "making m2GenPrompt"
        self.m2GenPrompt_branch = the_tree.GetBranch("m2GenPrompt")
        #if not self.m2GenPrompt_branch and "m2GenPrompt" not in self.complained:
        if not self.m2GenPrompt_branch and "m2GenPrompt":
            warnings.warn( "MMMTree: Expected branch m2GenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenPrompt")
        else:
            self.m2GenPrompt_branch.SetAddress(<void*>&self.m2GenPrompt_value)

        #print "making m2GenPromptTauDecay"
        self.m2GenPromptTauDecay_branch = the_tree.GetBranch("m2GenPromptTauDecay")
        #if not self.m2GenPromptTauDecay_branch and "m2GenPromptTauDecay" not in self.complained:
        if not self.m2GenPromptTauDecay_branch and "m2GenPromptTauDecay":
            warnings.warn( "MMMTree: Expected branch m2GenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenPromptTauDecay")
        else:
            self.m2GenPromptTauDecay_branch.SetAddress(<void*>&self.m2GenPromptTauDecay_value)

        #print "making m2GenPt"
        self.m2GenPt_branch = the_tree.GetBranch("m2GenPt")
        #if not self.m2GenPt_branch and "m2GenPt" not in self.complained:
        if not self.m2GenPt_branch and "m2GenPt":
            warnings.warn( "MMMTree: Expected branch m2GenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenPt")
        else:
            self.m2GenPt_branch.SetAddress(<void*>&self.m2GenPt_value)

        #print "making m2GenTauDecay"
        self.m2GenTauDecay_branch = the_tree.GetBranch("m2GenTauDecay")
        #if not self.m2GenTauDecay_branch and "m2GenTauDecay" not in self.complained:
        if not self.m2GenTauDecay_branch and "m2GenTauDecay":
            warnings.warn( "MMMTree: Expected branch m2GenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenTauDecay")
        else:
            self.m2GenTauDecay_branch.SetAddress(<void*>&self.m2GenTauDecay_value)

        #print "making m2GenVZ"
        self.m2GenVZ_branch = the_tree.GetBranch("m2GenVZ")
        #if not self.m2GenVZ_branch and "m2GenVZ" not in self.complained:
        if not self.m2GenVZ_branch and "m2GenVZ":
            warnings.warn( "MMMTree: Expected branch m2GenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenVZ")
        else:
            self.m2GenVZ_branch.SetAddress(<void*>&self.m2GenVZ_value)

        #print "making m2GenVtxPVMatch"
        self.m2GenVtxPVMatch_branch = the_tree.GetBranch("m2GenVtxPVMatch")
        #if not self.m2GenVtxPVMatch_branch and "m2GenVtxPVMatch" not in self.complained:
        if not self.m2GenVtxPVMatch_branch and "m2GenVtxPVMatch":
            warnings.warn( "MMMTree: Expected branch m2GenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2GenVtxPVMatch")
        else:
            self.m2GenVtxPVMatch_branch.SetAddress(<void*>&self.m2GenVtxPVMatch_value)

        #print "making m2HcalIsoDR03"
        self.m2HcalIsoDR03_branch = the_tree.GetBranch("m2HcalIsoDR03")
        #if not self.m2HcalIsoDR03_branch and "m2HcalIsoDR03" not in self.complained:
        if not self.m2HcalIsoDR03_branch and "m2HcalIsoDR03":
            warnings.warn( "MMMTree: Expected branch m2HcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2HcalIsoDR03")
        else:
            self.m2HcalIsoDR03_branch.SetAddress(<void*>&self.m2HcalIsoDR03_value)

        #print "making m2IP3D"
        self.m2IP3D_branch = the_tree.GetBranch("m2IP3D")
        #if not self.m2IP3D_branch and "m2IP3D" not in self.complained:
        if not self.m2IP3D_branch and "m2IP3D":
            warnings.warn( "MMMTree: Expected branch m2IP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2IP3D")
        else:
            self.m2IP3D_branch.SetAddress(<void*>&self.m2IP3D_value)

        #print "making m2IP3DErr"
        self.m2IP3DErr_branch = the_tree.GetBranch("m2IP3DErr")
        #if not self.m2IP3DErr_branch and "m2IP3DErr" not in self.complained:
        if not self.m2IP3DErr_branch and "m2IP3DErr":
            warnings.warn( "MMMTree: Expected branch m2IP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2IP3DErr")
        else:
            self.m2IP3DErr_branch.SetAddress(<void*>&self.m2IP3DErr_value)

        #print "making m2IsGlobal"
        self.m2IsGlobal_branch = the_tree.GetBranch("m2IsGlobal")
        #if not self.m2IsGlobal_branch and "m2IsGlobal" not in self.complained:
        if not self.m2IsGlobal_branch and "m2IsGlobal":
            warnings.warn( "MMMTree: Expected branch m2IsGlobal does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2IsGlobal")
        else:
            self.m2IsGlobal_branch.SetAddress(<void*>&self.m2IsGlobal_value)

        #print "making m2IsPFMuon"
        self.m2IsPFMuon_branch = the_tree.GetBranch("m2IsPFMuon")
        #if not self.m2IsPFMuon_branch and "m2IsPFMuon" not in self.complained:
        if not self.m2IsPFMuon_branch and "m2IsPFMuon":
            warnings.warn( "MMMTree: Expected branch m2IsPFMuon does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2IsPFMuon")
        else:
            self.m2IsPFMuon_branch.SetAddress(<void*>&self.m2IsPFMuon_value)

        #print "making m2IsTracker"
        self.m2IsTracker_branch = the_tree.GetBranch("m2IsTracker")
        #if not self.m2IsTracker_branch and "m2IsTracker" not in self.complained:
        if not self.m2IsTracker_branch and "m2IsTracker":
            warnings.warn( "MMMTree: Expected branch m2IsTracker does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2IsTracker")
        else:
            self.m2IsTracker_branch.SetAddress(<void*>&self.m2IsTracker_value)

        #print "making m2JetArea"
        self.m2JetArea_branch = the_tree.GetBranch("m2JetArea")
        #if not self.m2JetArea_branch and "m2JetArea" not in self.complained:
        if not self.m2JetArea_branch and "m2JetArea":
            warnings.warn( "MMMTree: Expected branch m2JetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetArea")
        else:
            self.m2JetArea_branch.SetAddress(<void*>&self.m2JetArea_value)

        #print "making m2JetBtag"
        self.m2JetBtag_branch = the_tree.GetBranch("m2JetBtag")
        #if not self.m2JetBtag_branch and "m2JetBtag" not in self.complained:
        if not self.m2JetBtag_branch and "m2JetBtag":
            warnings.warn( "MMMTree: Expected branch m2JetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetBtag")
        else:
            self.m2JetBtag_branch.SetAddress(<void*>&self.m2JetBtag_value)

        #print "making m2JetEtaEtaMoment"
        self.m2JetEtaEtaMoment_branch = the_tree.GetBranch("m2JetEtaEtaMoment")
        #if not self.m2JetEtaEtaMoment_branch and "m2JetEtaEtaMoment" not in self.complained:
        if not self.m2JetEtaEtaMoment_branch and "m2JetEtaEtaMoment":
            warnings.warn( "MMMTree: Expected branch m2JetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetEtaEtaMoment")
        else:
            self.m2JetEtaEtaMoment_branch.SetAddress(<void*>&self.m2JetEtaEtaMoment_value)

        #print "making m2JetEtaPhiMoment"
        self.m2JetEtaPhiMoment_branch = the_tree.GetBranch("m2JetEtaPhiMoment")
        #if not self.m2JetEtaPhiMoment_branch and "m2JetEtaPhiMoment" not in self.complained:
        if not self.m2JetEtaPhiMoment_branch and "m2JetEtaPhiMoment":
            warnings.warn( "MMMTree: Expected branch m2JetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetEtaPhiMoment")
        else:
            self.m2JetEtaPhiMoment_branch.SetAddress(<void*>&self.m2JetEtaPhiMoment_value)

        #print "making m2JetEtaPhiSpread"
        self.m2JetEtaPhiSpread_branch = the_tree.GetBranch("m2JetEtaPhiSpread")
        #if not self.m2JetEtaPhiSpread_branch and "m2JetEtaPhiSpread" not in self.complained:
        if not self.m2JetEtaPhiSpread_branch and "m2JetEtaPhiSpread":
            warnings.warn( "MMMTree: Expected branch m2JetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetEtaPhiSpread")
        else:
            self.m2JetEtaPhiSpread_branch.SetAddress(<void*>&self.m2JetEtaPhiSpread_value)

        #print "making m2JetPFCISVBtag"
        self.m2JetPFCISVBtag_branch = the_tree.GetBranch("m2JetPFCISVBtag")
        #if not self.m2JetPFCISVBtag_branch and "m2JetPFCISVBtag" not in self.complained:
        if not self.m2JetPFCISVBtag_branch and "m2JetPFCISVBtag":
            warnings.warn( "MMMTree: Expected branch m2JetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetPFCISVBtag")
        else:
            self.m2JetPFCISVBtag_branch.SetAddress(<void*>&self.m2JetPFCISVBtag_value)

        #print "making m2JetPartonFlavour"
        self.m2JetPartonFlavour_branch = the_tree.GetBranch("m2JetPartonFlavour")
        #if not self.m2JetPartonFlavour_branch and "m2JetPartonFlavour" not in self.complained:
        if not self.m2JetPartonFlavour_branch and "m2JetPartonFlavour":
            warnings.warn( "MMMTree: Expected branch m2JetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetPartonFlavour")
        else:
            self.m2JetPartonFlavour_branch.SetAddress(<void*>&self.m2JetPartonFlavour_value)

        #print "making m2JetPhiPhiMoment"
        self.m2JetPhiPhiMoment_branch = the_tree.GetBranch("m2JetPhiPhiMoment")
        #if not self.m2JetPhiPhiMoment_branch and "m2JetPhiPhiMoment" not in self.complained:
        if not self.m2JetPhiPhiMoment_branch and "m2JetPhiPhiMoment":
            warnings.warn( "MMMTree: Expected branch m2JetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetPhiPhiMoment")
        else:
            self.m2JetPhiPhiMoment_branch.SetAddress(<void*>&self.m2JetPhiPhiMoment_value)

        #print "making m2JetPt"
        self.m2JetPt_branch = the_tree.GetBranch("m2JetPt")
        #if not self.m2JetPt_branch and "m2JetPt" not in self.complained:
        if not self.m2JetPt_branch and "m2JetPt":
            warnings.warn( "MMMTree: Expected branch m2JetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2JetPt")
        else:
            self.m2JetPt_branch.SetAddress(<void*>&self.m2JetPt_value)

        #print "making m2LowestMll"
        self.m2LowestMll_branch = the_tree.GetBranch("m2LowestMll")
        #if not self.m2LowestMll_branch and "m2LowestMll" not in self.complained:
        if not self.m2LowestMll_branch and "m2LowestMll":
            warnings.warn( "MMMTree: Expected branch m2LowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2LowestMll")
        else:
            self.m2LowestMll_branch.SetAddress(<void*>&self.m2LowestMll_value)

        #print "making m2Mass"
        self.m2Mass_branch = the_tree.GetBranch("m2Mass")
        #if not self.m2Mass_branch and "m2Mass" not in self.complained:
        if not self.m2Mass_branch and "m2Mass":
            warnings.warn( "MMMTree: Expected branch m2Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Mass")
        else:
            self.m2Mass_branch.SetAddress(<void*>&self.m2Mass_value)

        #print "making m2MatchedStations"
        self.m2MatchedStations_branch = the_tree.GetBranch("m2MatchedStations")
        #if not self.m2MatchedStations_branch and "m2MatchedStations" not in self.complained:
        if not self.m2MatchedStations_branch and "m2MatchedStations":
            warnings.warn( "MMMTree: Expected branch m2MatchedStations does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchedStations")
        else:
            self.m2MatchedStations_branch.SetAddress(<void*>&self.m2MatchedStations_value)

        #print "making m2MatchesDoubleESingleMu"
        self.m2MatchesDoubleESingleMu_branch = the_tree.GetBranch("m2MatchesDoubleESingleMu")
        #if not self.m2MatchesDoubleESingleMu_branch and "m2MatchesDoubleESingleMu" not in self.complained:
        if not self.m2MatchesDoubleESingleMu_branch and "m2MatchesDoubleESingleMu":
            warnings.warn( "MMMTree: Expected branch m2MatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesDoubleESingleMu")
        else:
            self.m2MatchesDoubleESingleMu_branch.SetAddress(<void*>&self.m2MatchesDoubleESingleMu_value)

        #print "making m2MatchesDoubleMu"
        self.m2MatchesDoubleMu_branch = the_tree.GetBranch("m2MatchesDoubleMu")
        #if not self.m2MatchesDoubleMu_branch and "m2MatchesDoubleMu" not in self.complained:
        if not self.m2MatchesDoubleMu_branch and "m2MatchesDoubleMu":
            warnings.warn( "MMMTree: Expected branch m2MatchesDoubleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesDoubleMu")
        else:
            self.m2MatchesDoubleMu_branch.SetAddress(<void*>&self.m2MatchesDoubleMu_value)

        #print "making m2MatchesDoubleMuSingleE"
        self.m2MatchesDoubleMuSingleE_branch = the_tree.GetBranch("m2MatchesDoubleMuSingleE")
        #if not self.m2MatchesDoubleMuSingleE_branch and "m2MatchesDoubleMuSingleE" not in self.complained:
        if not self.m2MatchesDoubleMuSingleE_branch and "m2MatchesDoubleMuSingleE":
            warnings.warn( "MMMTree: Expected branch m2MatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesDoubleMuSingleE")
        else:
            self.m2MatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.m2MatchesDoubleMuSingleE_value)

        #print "making m2MatchesSingleESingleMu"
        self.m2MatchesSingleESingleMu_branch = the_tree.GetBranch("m2MatchesSingleESingleMu")
        #if not self.m2MatchesSingleESingleMu_branch and "m2MatchesSingleESingleMu" not in self.complained:
        if not self.m2MatchesSingleESingleMu_branch and "m2MatchesSingleESingleMu":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleESingleMu")
        else:
            self.m2MatchesSingleESingleMu_branch.SetAddress(<void*>&self.m2MatchesSingleESingleMu_value)

        #print "making m2MatchesSingleMu"
        self.m2MatchesSingleMu_branch = the_tree.GetBranch("m2MatchesSingleMu")
        #if not self.m2MatchesSingleMu_branch and "m2MatchesSingleMu" not in self.complained:
        if not self.m2MatchesSingleMu_branch and "m2MatchesSingleMu":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMu")
        else:
            self.m2MatchesSingleMu_branch.SetAddress(<void*>&self.m2MatchesSingleMu_value)

        #print "making m2MatchesSingleMuIso20"
        self.m2MatchesSingleMuIso20_branch = the_tree.GetBranch("m2MatchesSingleMuIso20")
        #if not self.m2MatchesSingleMuIso20_branch and "m2MatchesSingleMuIso20" not in self.complained:
        if not self.m2MatchesSingleMuIso20_branch and "m2MatchesSingleMuIso20":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMuIso20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMuIso20")
        else:
            self.m2MatchesSingleMuIso20_branch.SetAddress(<void*>&self.m2MatchesSingleMuIso20_value)

        #print "making m2MatchesSingleMuIsoTk20"
        self.m2MatchesSingleMuIsoTk20_branch = the_tree.GetBranch("m2MatchesSingleMuIsoTk20")
        #if not self.m2MatchesSingleMuIsoTk20_branch and "m2MatchesSingleMuIsoTk20" not in self.complained:
        if not self.m2MatchesSingleMuIsoTk20_branch and "m2MatchesSingleMuIsoTk20":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMuIsoTk20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMuIsoTk20")
        else:
            self.m2MatchesSingleMuIsoTk20_branch.SetAddress(<void*>&self.m2MatchesSingleMuIsoTk20_value)

        #print "making m2MatchesSingleMuSingleE"
        self.m2MatchesSingleMuSingleE_branch = the_tree.GetBranch("m2MatchesSingleMuSingleE")
        #if not self.m2MatchesSingleMuSingleE_branch and "m2MatchesSingleMuSingleE" not in self.complained:
        if not self.m2MatchesSingleMuSingleE_branch and "m2MatchesSingleMuSingleE":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMuSingleE")
        else:
            self.m2MatchesSingleMuSingleE_branch.SetAddress(<void*>&self.m2MatchesSingleMuSingleE_value)

        #print "making m2MatchesSingleMu_leg1"
        self.m2MatchesSingleMu_leg1_branch = the_tree.GetBranch("m2MatchesSingleMu_leg1")
        #if not self.m2MatchesSingleMu_leg1_branch and "m2MatchesSingleMu_leg1" not in self.complained:
        if not self.m2MatchesSingleMu_leg1_branch and "m2MatchesSingleMu_leg1":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMu_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMu_leg1")
        else:
            self.m2MatchesSingleMu_leg1_branch.SetAddress(<void*>&self.m2MatchesSingleMu_leg1_value)

        #print "making m2MatchesSingleMu_leg1_noiso"
        self.m2MatchesSingleMu_leg1_noiso_branch = the_tree.GetBranch("m2MatchesSingleMu_leg1_noiso")
        #if not self.m2MatchesSingleMu_leg1_noiso_branch and "m2MatchesSingleMu_leg1_noiso" not in self.complained:
        if not self.m2MatchesSingleMu_leg1_noiso_branch and "m2MatchesSingleMu_leg1_noiso":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMu_leg1_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMu_leg1_noiso")
        else:
            self.m2MatchesSingleMu_leg1_noiso_branch.SetAddress(<void*>&self.m2MatchesSingleMu_leg1_noiso_value)

        #print "making m2MatchesSingleMu_leg2"
        self.m2MatchesSingleMu_leg2_branch = the_tree.GetBranch("m2MatchesSingleMu_leg2")
        #if not self.m2MatchesSingleMu_leg2_branch and "m2MatchesSingleMu_leg2" not in self.complained:
        if not self.m2MatchesSingleMu_leg2_branch and "m2MatchesSingleMu_leg2":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMu_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMu_leg2")
        else:
            self.m2MatchesSingleMu_leg2_branch.SetAddress(<void*>&self.m2MatchesSingleMu_leg2_value)

        #print "making m2MatchesSingleMu_leg2_noiso"
        self.m2MatchesSingleMu_leg2_noiso_branch = the_tree.GetBranch("m2MatchesSingleMu_leg2_noiso")
        #if not self.m2MatchesSingleMu_leg2_noiso_branch and "m2MatchesSingleMu_leg2_noiso" not in self.complained:
        if not self.m2MatchesSingleMu_leg2_noiso_branch and "m2MatchesSingleMu_leg2_noiso":
            warnings.warn( "MMMTree: Expected branch m2MatchesSingleMu_leg2_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesSingleMu_leg2_noiso")
        else:
            self.m2MatchesSingleMu_leg2_noiso_branch.SetAddress(<void*>&self.m2MatchesSingleMu_leg2_noiso_value)

        #print "making m2MatchesTripleMu"
        self.m2MatchesTripleMu_branch = the_tree.GetBranch("m2MatchesTripleMu")
        #if not self.m2MatchesTripleMu_branch and "m2MatchesTripleMu" not in self.complained:
        if not self.m2MatchesTripleMu_branch and "m2MatchesTripleMu":
            warnings.warn( "MMMTree: Expected branch m2MatchesTripleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MatchesTripleMu")
        else:
            self.m2MatchesTripleMu_branch.SetAddress(<void*>&self.m2MatchesTripleMu_value)

        #print "making m2MtToPfMet_ElectronEnDown"
        self.m2MtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("m2MtToPfMet_ElectronEnDown")
        #if not self.m2MtToPfMet_ElectronEnDown_branch and "m2MtToPfMet_ElectronEnDown" not in self.complained:
        if not self.m2MtToPfMet_ElectronEnDown_branch and "m2MtToPfMet_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_ElectronEnDown")
        else:
            self.m2MtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.m2MtToPfMet_ElectronEnDown_value)

        #print "making m2MtToPfMet_ElectronEnUp"
        self.m2MtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("m2MtToPfMet_ElectronEnUp")
        #if not self.m2MtToPfMet_ElectronEnUp_branch and "m2MtToPfMet_ElectronEnUp" not in self.complained:
        if not self.m2MtToPfMet_ElectronEnUp_branch and "m2MtToPfMet_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_ElectronEnUp")
        else:
            self.m2MtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.m2MtToPfMet_ElectronEnUp_value)

        #print "making m2MtToPfMet_JetEnDown"
        self.m2MtToPfMet_JetEnDown_branch = the_tree.GetBranch("m2MtToPfMet_JetEnDown")
        #if not self.m2MtToPfMet_JetEnDown_branch and "m2MtToPfMet_JetEnDown" not in self.complained:
        if not self.m2MtToPfMet_JetEnDown_branch and "m2MtToPfMet_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_JetEnDown")
        else:
            self.m2MtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.m2MtToPfMet_JetEnDown_value)

        #print "making m2MtToPfMet_JetEnUp"
        self.m2MtToPfMet_JetEnUp_branch = the_tree.GetBranch("m2MtToPfMet_JetEnUp")
        #if not self.m2MtToPfMet_JetEnUp_branch and "m2MtToPfMet_JetEnUp" not in self.complained:
        if not self.m2MtToPfMet_JetEnUp_branch and "m2MtToPfMet_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_JetEnUp")
        else:
            self.m2MtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.m2MtToPfMet_JetEnUp_value)

        #print "making m2MtToPfMet_JetResDown"
        self.m2MtToPfMet_JetResDown_branch = the_tree.GetBranch("m2MtToPfMet_JetResDown")
        #if not self.m2MtToPfMet_JetResDown_branch and "m2MtToPfMet_JetResDown" not in self.complained:
        if not self.m2MtToPfMet_JetResDown_branch and "m2MtToPfMet_JetResDown":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_JetResDown")
        else:
            self.m2MtToPfMet_JetResDown_branch.SetAddress(<void*>&self.m2MtToPfMet_JetResDown_value)

        #print "making m2MtToPfMet_JetResUp"
        self.m2MtToPfMet_JetResUp_branch = the_tree.GetBranch("m2MtToPfMet_JetResUp")
        #if not self.m2MtToPfMet_JetResUp_branch and "m2MtToPfMet_JetResUp" not in self.complained:
        if not self.m2MtToPfMet_JetResUp_branch and "m2MtToPfMet_JetResUp":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_JetResUp")
        else:
            self.m2MtToPfMet_JetResUp_branch.SetAddress(<void*>&self.m2MtToPfMet_JetResUp_value)

        #print "making m2MtToPfMet_MuonEnDown"
        self.m2MtToPfMet_MuonEnDown_branch = the_tree.GetBranch("m2MtToPfMet_MuonEnDown")
        #if not self.m2MtToPfMet_MuonEnDown_branch and "m2MtToPfMet_MuonEnDown" not in self.complained:
        if not self.m2MtToPfMet_MuonEnDown_branch and "m2MtToPfMet_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_MuonEnDown")
        else:
            self.m2MtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.m2MtToPfMet_MuonEnDown_value)

        #print "making m2MtToPfMet_MuonEnUp"
        self.m2MtToPfMet_MuonEnUp_branch = the_tree.GetBranch("m2MtToPfMet_MuonEnUp")
        #if not self.m2MtToPfMet_MuonEnUp_branch and "m2MtToPfMet_MuonEnUp" not in self.complained:
        if not self.m2MtToPfMet_MuonEnUp_branch and "m2MtToPfMet_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_MuonEnUp")
        else:
            self.m2MtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.m2MtToPfMet_MuonEnUp_value)

        #print "making m2MtToPfMet_PhotonEnDown"
        self.m2MtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("m2MtToPfMet_PhotonEnDown")
        #if not self.m2MtToPfMet_PhotonEnDown_branch and "m2MtToPfMet_PhotonEnDown" not in self.complained:
        if not self.m2MtToPfMet_PhotonEnDown_branch and "m2MtToPfMet_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_PhotonEnDown")
        else:
            self.m2MtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.m2MtToPfMet_PhotonEnDown_value)

        #print "making m2MtToPfMet_PhotonEnUp"
        self.m2MtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("m2MtToPfMet_PhotonEnUp")
        #if not self.m2MtToPfMet_PhotonEnUp_branch and "m2MtToPfMet_PhotonEnUp" not in self.complained:
        if not self.m2MtToPfMet_PhotonEnUp_branch and "m2MtToPfMet_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_PhotonEnUp")
        else:
            self.m2MtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.m2MtToPfMet_PhotonEnUp_value)

        #print "making m2MtToPfMet_Raw"
        self.m2MtToPfMet_Raw_branch = the_tree.GetBranch("m2MtToPfMet_Raw")
        #if not self.m2MtToPfMet_Raw_branch and "m2MtToPfMet_Raw" not in self.complained:
        if not self.m2MtToPfMet_Raw_branch and "m2MtToPfMet_Raw":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_Raw")
        else:
            self.m2MtToPfMet_Raw_branch.SetAddress(<void*>&self.m2MtToPfMet_Raw_value)

        #print "making m2MtToPfMet_TauEnDown"
        self.m2MtToPfMet_TauEnDown_branch = the_tree.GetBranch("m2MtToPfMet_TauEnDown")
        #if not self.m2MtToPfMet_TauEnDown_branch and "m2MtToPfMet_TauEnDown" not in self.complained:
        if not self.m2MtToPfMet_TauEnDown_branch and "m2MtToPfMet_TauEnDown":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_TauEnDown")
        else:
            self.m2MtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.m2MtToPfMet_TauEnDown_value)

        #print "making m2MtToPfMet_TauEnUp"
        self.m2MtToPfMet_TauEnUp_branch = the_tree.GetBranch("m2MtToPfMet_TauEnUp")
        #if not self.m2MtToPfMet_TauEnUp_branch and "m2MtToPfMet_TauEnUp" not in self.complained:
        if not self.m2MtToPfMet_TauEnUp_branch and "m2MtToPfMet_TauEnUp":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_TauEnUp")
        else:
            self.m2MtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.m2MtToPfMet_TauEnUp_value)

        #print "making m2MtToPfMet_UnclusteredEnDown"
        self.m2MtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("m2MtToPfMet_UnclusteredEnDown")
        #if not self.m2MtToPfMet_UnclusteredEnDown_branch and "m2MtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.m2MtToPfMet_UnclusteredEnDown_branch and "m2MtToPfMet_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_UnclusteredEnDown")
        else:
            self.m2MtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.m2MtToPfMet_UnclusteredEnDown_value)

        #print "making m2MtToPfMet_UnclusteredEnUp"
        self.m2MtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("m2MtToPfMet_UnclusteredEnUp")
        #if not self.m2MtToPfMet_UnclusteredEnUp_branch and "m2MtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.m2MtToPfMet_UnclusteredEnUp_branch and "m2MtToPfMet_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_UnclusteredEnUp")
        else:
            self.m2MtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.m2MtToPfMet_UnclusteredEnUp_value)

        #print "making m2MtToPfMet_type1"
        self.m2MtToPfMet_type1_branch = the_tree.GetBranch("m2MtToPfMet_type1")
        #if not self.m2MtToPfMet_type1_branch and "m2MtToPfMet_type1" not in self.complained:
        if not self.m2MtToPfMet_type1_branch and "m2MtToPfMet_type1":
            warnings.warn( "MMMTree: Expected branch m2MtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MtToPfMet_type1")
        else:
            self.m2MtToPfMet_type1_branch.SetAddress(<void*>&self.m2MtToPfMet_type1_value)

        #print "making m2MuonHits"
        self.m2MuonHits_branch = the_tree.GetBranch("m2MuonHits")
        #if not self.m2MuonHits_branch and "m2MuonHits" not in self.complained:
        if not self.m2MuonHits_branch and "m2MuonHits":
            warnings.warn( "MMMTree: Expected branch m2MuonHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2MuonHits")
        else:
            self.m2MuonHits_branch.SetAddress(<void*>&self.m2MuonHits_value)

        #print "making m2NearestZMass"
        self.m2NearestZMass_branch = the_tree.GetBranch("m2NearestZMass")
        #if not self.m2NearestZMass_branch and "m2NearestZMass" not in self.complained:
        if not self.m2NearestZMass_branch and "m2NearestZMass":
            warnings.warn( "MMMTree: Expected branch m2NearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2NearestZMass")
        else:
            self.m2NearestZMass_branch.SetAddress(<void*>&self.m2NearestZMass_value)

        #print "making m2NormTrkChi2"
        self.m2NormTrkChi2_branch = the_tree.GetBranch("m2NormTrkChi2")
        #if not self.m2NormTrkChi2_branch and "m2NormTrkChi2" not in self.complained:
        if not self.m2NormTrkChi2_branch and "m2NormTrkChi2":
            warnings.warn( "MMMTree: Expected branch m2NormTrkChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2NormTrkChi2")
        else:
            self.m2NormTrkChi2_branch.SetAddress(<void*>&self.m2NormTrkChi2_value)

        #print "making m2PFChargedIso"
        self.m2PFChargedIso_branch = the_tree.GetBranch("m2PFChargedIso")
        #if not self.m2PFChargedIso_branch and "m2PFChargedIso" not in self.complained:
        if not self.m2PFChargedIso_branch and "m2PFChargedIso":
            warnings.warn( "MMMTree: Expected branch m2PFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PFChargedIso")
        else:
            self.m2PFChargedIso_branch.SetAddress(<void*>&self.m2PFChargedIso_value)

        #print "making m2PFIDLoose"
        self.m2PFIDLoose_branch = the_tree.GetBranch("m2PFIDLoose")
        #if not self.m2PFIDLoose_branch and "m2PFIDLoose" not in self.complained:
        if not self.m2PFIDLoose_branch and "m2PFIDLoose":
            warnings.warn( "MMMTree: Expected branch m2PFIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PFIDLoose")
        else:
            self.m2PFIDLoose_branch.SetAddress(<void*>&self.m2PFIDLoose_value)

        #print "making m2PFIDMedium"
        self.m2PFIDMedium_branch = the_tree.GetBranch("m2PFIDMedium")
        #if not self.m2PFIDMedium_branch and "m2PFIDMedium" not in self.complained:
        if not self.m2PFIDMedium_branch and "m2PFIDMedium":
            warnings.warn( "MMMTree: Expected branch m2PFIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PFIDMedium")
        else:
            self.m2PFIDMedium_branch.SetAddress(<void*>&self.m2PFIDMedium_value)

        #print "making m2PFIDTight"
        self.m2PFIDTight_branch = the_tree.GetBranch("m2PFIDTight")
        #if not self.m2PFIDTight_branch and "m2PFIDTight" not in self.complained:
        if not self.m2PFIDTight_branch and "m2PFIDTight":
            warnings.warn( "MMMTree: Expected branch m2PFIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PFIDTight")
        else:
            self.m2PFIDTight_branch.SetAddress(<void*>&self.m2PFIDTight_value)

        #print "making m2PFNeutralIso"
        self.m2PFNeutralIso_branch = the_tree.GetBranch("m2PFNeutralIso")
        #if not self.m2PFNeutralIso_branch and "m2PFNeutralIso" not in self.complained:
        if not self.m2PFNeutralIso_branch and "m2PFNeutralIso":
            warnings.warn( "MMMTree: Expected branch m2PFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PFNeutralIso")
        else:
            self.m2PFNeutralIso_branch.SetAddress(<void*>&self.m2PFNeutralIso_value)

        #print "making m2PFPUChargedIso"
        self.m2PFPUChargedIso_branch = the_tree.GetBranch("m2PFPUChargedIso")
        #if not self.m2PFPUChargedIso_branch and "m2PFPUChargedIso" not in self.complained:
        if not self.m2PFPUChargedIso_branch and "m2PFPUChargedIso":
            warnings.warn( "MMMTree: Expected branch m2PFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PFPUChargedIso")
        else:
            self.m2PFPUChargedIso_branch.SetAddress(<void*>&self.m2PFPUChargedIso_value)

        #print "making m2PFPhotonIso"
        self.m2PFPhotonIso_branch = the_tree.GetBranch("m2PFPhotonIso")
        #if not self.m2PFPhotonIso_branch and "m2PFPhotonIso" not in self.complained:
        if not self.m2PFPhotonIso_branch and "m2PFPhotonIso":
            warnings.warn( "MMMTree: Expected branch m2PFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PFPhotonIso")
        else:
            self.m2PFPhotonIso_branch.SetAddress(<void*>&self.m2PFPhotonIso_value)

        #print "making m2PVDXY"
        self.m2PVDXY_branch = the_tree.GetBranch("m2PVDXY")
        #if not self.m2PVDXY_branch and "m2PVDXY" not in self.complained:
        if not self.m2PVDXY_branch and "m2PVDXY":
            warnings.warn( "MMMTree: Expected branch m2PVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PVDXY")
        else:
            self.m2PVDXY_branch.SetAddress(<void*>&self.m2PVDXY_value)

        #print "making m2PVDZ"
        self.m2PVDZ_branch = the_tree.GetBranch("m2PVDZ")
        #if not self.m2PVDZ_branch and "m2PVDZ" not in self.complained:
        if not self.m2PVDZ_branch and "m2PVDZ":
            warnings.warn( "MMMTree: Expected branch m2PVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PVDZ")
        else:
            self.m2PVDZ_branch.SetAddress(<void*>&self.m2PVDZ_value)

        #print "making m2Phi"
        self.m2Phi_branch = the_tree.GetBranch("m2Phi")
        #if not self.m2Phi_branch and "m2Phi" not in self.complained:
        if not self.m2Phi_branch and "m2Phi":
            warnings.warn( "MMMTree: Expected branch m2Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Phi")
        else:
            self.m2Phi_branch.SetAddress(<void*>&self.m2Phi_value)

        #print "making m2Phi_MuonEnDown"
        self.m2Phi_MuonEnDown_branch = the_tree.GetBranch("m2Phi_MuonEnDown")
        #if not self.m2Phi_MuonEnDown_branch and "m2Phi_MuonEnDown" not in self.complained:
        if not self.m2Phi_MuonEnDown_branch and "m2Phi_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m2Phi_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Phi_MuonEnDown")
        else:
            self.m2Phi_MuonEnDown_branch.SetAddress(<void*>&self.m2Phi_MuonEnDown_value)

        #print "making m2Phi_MuonEnUp"
        self.m2Phi_MuonEnUp_branch = the_tree.GetBranch("m2Phi_MuonEnUp")
        #if not self.m2Phi_MuonEnUp_branch and "m2Phi_MuonEnUp" not in self.complained:
        if not self.m2Phi_MuonEnUp_branch and "m2Phi_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m2Phi_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Phi_MuonEnUp")
        else:
            self.m2Phi_MuonEnUp_branch.SetAddress(<void*>&self.m2Phi_MuonEnUp_value)

        #print "making m2PixHits"
        self.m2PixHits_branch = the_tree.GetBranch("m2PixHits")
        #if not self.m2PixHits_branch and "m2PixHits" not in self.complained:
        if not self.m2PixHits_branch and "m2PixHits":
            warnings.warn( "MMMTree: Expected branch m2PixHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2PixHits")
        else:
            self.m2PixHits_branch.SetAddress(<void*>&self.m2PixHits_value)

        #print "making m2Pt"
        self.m2Pt_branch = the_tree.GetBranch("m2Pt")
        #if not self.m2Pt_branch and "m2Pt" not in self.complained:
        if not self.m2Pt_branch and "m2Pt":
            warnings.warn( "MMMTree: Expected branch m2Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Pt")
        else:
            self.m2Pt_branch.SetAddress(<void*>&self.m2Pt_value)

        #print "making m2Pt_MuonEnDown"
        self.m2Pt_MuonEnDown_branch = the_tree.GetBranch("m2Pt_MuonEnDown")
        #if not self.m2Pt_MuonEnDown_branch and "m2Pt_MuonEnDown" not in self.complained:
        if not self.m2Pt_MuonEnDown_branch and "m2Pt_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m2Pt_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Pt_MuonEnDown")
        else:
            self.m2Pt_MuonEnDown_branch.SetAddress(<void*>&self.m2Pt_MuonEnDown_value)

        #print "making m2Pt_MuonEnUp"
        self.m2Pt_MuonEnUp_branch = the_tree.GetBranch("m2Pt_MuonEnUp")
        #if not self.m2Pt_MuonEnUp_branch and "m2Pt_MuonEnUp" not in self.complained:
        if not self.m2Pt_MuonEnUp_branch and "m2Pt_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m2Pt_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Pt_MuonEnUp")
        else:
            self.m2Pt_MuonEnUp_branch.SetAddress(<void*>&self.m2Pt_MuonEnUp_value)

        #print "making m2Rank"
        self.m2Rank_branch = the_tree.GetBranch("m2Rank")
        #if not self.m2Rank_branch and "m2Rank" not in self.complained:
        if not self.m2Rank_branch and "m2Rank":
            warnings.warn( "MMMTree: Expected branch m2Rank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Rank")
        else:
            self.m2Rank_branch.SetAddress(<void*>&self.m2Rank_value)

        #print "making m2RelPFIsoDBDefault"
        self.m2RelPFIsoDBDefault_branch = the_tree.GetBranch("m2RelPFIsoDBDefault")
        #if not self.m2RelPFIsoDBDefault_branch and "m2RelPFIsoDBDefault" not in self.complained:
        if not self.m2RelPFIsoDBDefault_branch and "m2RelPFIsoDBDefault":
            warnings.warn( "MMMTree: Expected branch m2RelPFIsoDBDefault does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2RelPFIsoDBDefault")
        else:
            self.m2RelPFIsoDBDefault_branch.SetAddress(<void*>&self.m2RelPFIsoDBDefault_value)

        #print "making m2RelPFIsoRho"
        self.m2RelPFIsoRho_branch = the_tree.GetBranch("m2RelPFIsoRho")
        #if not self.m2RelPFIsoRho_branch and "m2RelPFIsoRho" not in self.complained:
        if not self.m2RelPFIsoRho_branch and "m2RelPFIsoRho":
            warnings.warn( "MMMTree: Expected branch m2RelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2RelPFIsoRho")
        else:
            self.m2RelPFIsoRho_branch.SetAddress(<void*>&self.m2RelPFIsoRho_value)

        #print "making m2Rho"
        self.m2Rho_branch = the_tree.GetBranch("m2Rho")
        #if not self.m2Rho_branch and "m2Rho" not in self.complained:
        if not self.m2Rho_branch and "m2Rho":
            warnings.warn( "MMMTree: Expected branch m2Rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2Rho")
        else:
            self.m2Rho_branch.SetAddress(<void*>&self.m2Rho_value)

        #print "making m2SIP2D"
        self.m2SIP2D_branch = the_tree.GetBranch("m2SIP2D")
        #if not self.m2SIP2D_branch and "m2SIP2D" not in self.complained:
        if not self.m2SIP2D_branch and "m2SIP2D":
            warnings.warn( "MMMTree: Expected branch m2SIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2SIP2D")
        else:
            self.m2SIP2D_branch.SetAddress(<void*>&self.m2SIP2D_value)

        #print "making m2SIP3D"
        self.m2SIP3D_branch = the_tree.GetBranch("m2SIP3D")
        #if not self.m2SIP3D_branch and "m2SIP3D" not in self.complained:
        if not self.m2SIP3D_branch and "m2SIP3D":
            warnings.warn( "MMMTree: Expected branch m2SIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2SIP3D")
        else:
            self.m2SIP3D_branch.SetAddress(<void*>&self.m2SIP3D_value)

        #print "making m2TkLayersWithMeasurement"
        self.m2TkLayersWithMeasurement_branch = the_tree.GetBranch("m2TkLayersWithMeasurement")
        #if not self.m2TkLayersWithMeasurement_branch and "m2TkLayersWithMeasurement" not in self.complained:
        if not self.m2TkLayersWithMeasurement_branch and "m2TkLayersWithMeasurement":
            warnings.warn( "MMMTree: Expected branch m2TkLayersWithMeasurement does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2TkLayersWithMeasurement")
        else:
            self.m2TkLayersWithMeasurement_branch.SetAddress(<void*>&self.m2TkLayersWithMeasurement_value)

        #print "making m2TrkIsoDR03"
        self.m2TrkIsoDR03_branch = the_tree.GetBranch("m2TrkIsoDR03")
        #if not self.m2TrkIsoDR03_branch and "m2TrkIsoDR03" not in self.complained:
        if not self.m2TrkIsoDR03_branch and "m2TrkIsoDR03":
            warnings.warn( "MMMTree: Expected branch m2TrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2TrkIsoDR03")
        else:
            self.m2TrkIsoDR03_branch.SetAddress(<void*>&self.m2TrkIsoDR03_value)

        #print "making m2TypeCode"
        self.m2TypeCode_branch = the_tree.GetBranch("m2TypeCode")
        #if not self.m2TypeCode_branch and "m2TypeCode" not in self.complained:
        if not self.m2TypeCode_branch and "m2TypeCode":
            warnings.warn( "MMMTree: Expected branch m2TypeCode does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2TypeCode")
        else:
            self.m2TypeCode_branch.SetAddress(<void*>&self.m2TypeCode_value)

        #print "making m2VZ"
        self.m2VZ_branch = the_tree.GetBranch("m2VZ")
        #if not self.m2VZ_branch and "m2VZ" not in self.complained:
        if not self.m2VZ_branch and "m2VZ":
            warnings.warn( "MMMTree: Expected branch m2VZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2VZ")
        else:
            self.m2VZ_branch.SetAddress(<void*>&self.m2VZ_value)

        #print "making m2_m1_collinearmass"
        self.m2_m1_collinearmass_branch = the_tree.GetBranch("m2_m1_collinearmass")
        #if not self.m2_m1_collinearmass_branch and "m2_m1_collinearmass" not in self.complained:
        if not self.m2_m1_collinearmass_branch and "m2_m1_collinearmass":
            warnings.warn( "MMMTree: Expected branch m2_m1_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m1_collinearmass")
        else:
            self.m2_m1_collinearmass_branch.SetAddress(<void*>&self.m2_m1_collinearmass_value)

        #print "making m2_m1_collinearmass_JetEnDown"
        self.m2_m1_collinearmass_JetEnDown_branch = the_tree.GetBranch("m2_m1_collinearmass_JetEnDown")
        #if not self.m2_m1_collinearmass_JetEnDown_branch and "m2_m1_collinearmass_JetEnDown" not in self.complained:
        if not self.m2_m1_collinearmass_JetEnDown_branch and "m2_m1_collinearmass_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m2_m1_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m1_collinearmass_JetEnDown")
        else:
            self.m2_m1_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.m2_m1_collinearmass_JetEnDown_value)

        #print "making m2_m1_collinearmass_JetEnUp"
        self.m2_m1_collinearmass_JetEnUp_branch = the_tree.GetBranch("m2_m1_collinearmass_JetEnUp")
        #if not self.m2_m1_collinearmass_JetEnUp_branch and "m2_m1_collinearmass_JetEnUp" not in self.complained:
        if not self.m2_m1_collinearmass_JetEnUp_branch and "m2_m1_collinearmass_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m2_m1_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m1_collinearmass_JetEnUp")
        else:
            self.m2_m1_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.m2_m1_collinearmass_JetEnUp_value)

        #print "making m2_m1_collinearmass_UnclusteredEnDown"
        self.m2_m1_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("m2_m1_collinearmass_UnclusteredEnDown")
        #if not self.m2_m1_collinearmass_UnclusteredEnDown_branch and "m2_m1_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.m2_m1_collinearmass_UnclusteredEnDown_branch and "m2_m1_collinearmass_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m2_m1_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m1_collinearmass_UnclusteredEnDown")
        else:
            self.m2_m1_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.m2_m1_collinearmass_UnclusteredEnDown_value)

        #print "making m2_m1_collinearmass_UnclusteredEnUp"
        self.m2_m1_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("m2_m1_collinearmass_UnclusteredEnUp")
        #if not self.m2_m1_collinearmass_UnclusteredEnUp_branch and "m2_m1_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.m2_m1_collinearmass_UnclusteredEnUp_branch and "m2_m1_collinearmass_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m2_m1_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m1_collinearmass_UnclusteredEnUp")
        else:
            self.m2_m1_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.m2_m1_collinearmass_UnclusteredEnUp_value)

        #print "making m2_m3_CosThetaStar"
        self.m2_m3_CosThetaStar_branch = the_tree.GetBranch("m2_m3_CosThetaStar")
        #if not self.m2_m3_CosThetaStar_branch and "m2_m3_CosThetaStar" not in self.complained:
        if not self.m2_m3_CosThetaStar_branch and "m2_m3_CosThetaStar":
            warnings.warn( "MMMTree: Expected branch m2_m3_CosThetaStar does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_CosThetaStar")
        else:
            self.m2_m3_CosThetaStar_branch.SetAddress(<void*>&self.m2_m3_CosThetaStar_value)

        #print "making m2_m3_DPhi"
        self.m2_m3_DPhi_branch = the_tree.GetBranch("m2_m3_DPhi")
        #if not self.m2_m3_DPhi_branch and "m2_m3_DPhi" not in self.complained:
        if not self.m2_m3_DPhi_branch and "m2_m3_DPhi":
            warnings.warn( "MMMTree: Expected branch m2_m3_DPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_DPhi")
        else:
            self.m2_m3_DPhi_branch.SetAddress(<void*>&self.m2_m3_DPhi_value)

        #print "making m2_m3_DR"
        self.m2_m3_DR_branch = the_tree.GetBranch("m2_m3_DR")
        #if not self.m2_m3_DR_branch and "m2_m3_DR" not in self.complained:
        if not self.m2_m3_DR_branch and "m2_m3_DR":
            warnings.warn( "MMMTree: Expected branch m2_m3_DR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_DR")
        else:
            self.m2_m3_DR_branch.SetAddress(<void*>&self.m2_m3_DR_value)

        #print "making m2_m3_Eta"
        self.m2_m3_Eta_branch = the_tree.GetBranch("m2_m3_Eta")
        #if not self.m2_m3_Eta_branch and "m2_m3_Eta" not in self.complained:
        if not self.m2_m3_Eta_branch and "m2_m3_Eta":
            warnings.warn( "MMMTree: Expected branch m2_m3_Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_Eta")
        else:
            self.m2_m3_Eta_branch.SetAddress(<void*>&self.m2_m3_Eta_value)

        #print "making m2_m3_Mass"
        self.m2_m3_Mass_branch = the_tree.GetBranch("m2_m3_Mass")
        #if not self.m2_m3_Mass_branch and "m2_m3_Mass" not in self.complained:
        if not self.m2_m3_Mass_branch and "m2_m3_Mass":
            warnings.warn( "MMMTree: Expected branch m2_m3_Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_Mass")
        else:
            self.m2_m3_Mass_branch.SetAddress(<void*>&self.m2_m3_Mass_value)

        #print "making m2_m3_Mt"
        self.m2_m3_Mt_branch = the_tree.GetBranch("m2_m3_Mt")
        #if not self.m2_m3_Mt_branch and "m2_m3_Mt" not in self.complained:
        if not self.m2_m3_Mt_branch and "m2_m3_Mt":
            warnings.warn( "MMMTree: Expected branch m2_m3_Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_Mt")
        else:
            self.m2_m3_Mt_branch.SetAddress(<void*>&self.m2_m3_Mt_value)

        #print "making m2_m3_PZeta"
        self.m2_m3_PZeta_branch = the_tree.GetBranch("m2_m3_PZeta")
        #if not self.m2_m3_PZeta_branch and "m2_m3_PZeta" not in self.complained:
        if not self.m2_m3_PZeta_branch and "m2_m3_PZeta":
            warnings.warn( "MMMTree: Expected branch m2_m3_PZeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_PZeta")
        else:
            self.m2_m3_PZeta_branch.SetAddress(<void*>&self.m2_m3_PZeta_value)

        #print "making m2_m3_PZetaVis"
        self.m2_m3_PZetaVis_branch = the_tree.GetBranch("m2_m3_PZetaVis")
        #if not self.m2_m3_PZetaVis_branch and "m2_m3_PZetaVis" not in self.complained:
        if not self.m2_m3_PZetaVis_branch and "m2_m3_PZetaVis":
            warnings.warn( "MMMTree: Expected branch m2_m3_PZetaVis does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_PZetaVis")
        else:
            self.m2_m3_PZetaVis_branch.SetAddress(<void*>&self.m2_m3_PZetaVis_value)

        #print "making m2_m3_Phi"
        self.m2_m3_Phi_branch = the_tree.GetBranch("m2_m3_Phi")
        #if not self.m2_m3_Phi_branch and "m2_m3_Phi" not in self.complained:
        if not self.m2_m3_Phi_branch and "m2_m3_Phi":
            warnings.warn( "MMMTree: Expected branch m2_m3_Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_Phi")
        else:
            self.m2_m3_Phi_branch.SetAddress(<void*>&self.m2_m3_Phi_value)

        #print "making m2_m3_Pt"
        self.m2_m3_Pt_branch = the_tree.GetBranch("m2_m3_Pt")
        #if not self.m2_m3_Pt_branch and "m2_m3_Pt" not in self.complained:
        if not self.m2_m3_Pt_branch and "m2_m3_Pt":
            warnings.warn( "MMMTree: Expected branch m2_m3_Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_Pt")
        else:
            self.m2_m3_Pt_branch.SetAddress(<void*>&self.m2_m3_Pt_value)

        #print "making m2_m3_SS"
        self.m2_m3_SS_branch = the_tree.GetBranch("m2_m3_SS")
        #if not self.m2_m3_SS_branch and "m2_m3_SS" not in self.complained:
        if not self.m2_m3_SS_branch and "m2_m3_SS":
            warnings.warn( "MMMTree: Expected branch m2_m3_SS does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_SS")
        else:
            self.m2_m3_SS_branch.SetAddress(<void*>&self.m2_m3_SS_value)

        #print "making m2_m3_ToMETDPhi_Ty1"
        self.m2_m3_ToMETDPhi_Ty1_branch = the_tree.GetBranch("m2_m3_ToMETDPhi_Ty1")
        #if not self.m2_m3_ToMETDPhi_Ty1_branch and "m2_m3_ToMETDPhi_Ty1" not in self.complained:
        if not self.m2_m3_ToMETDPhi_Ty1_branch and "m2_m3_ToMETDPhi_Ty1":
            warnings.warn( "MMMTree: Expected branch m2_m3_ToMETDPhi_Ty1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_ToMETDPhi_Ty1")
        else:
            self.m2_m3_ToMETDPhi_Ty1_branch.SetAddress(<void*>&self.m2_m3_ToMETDPhi_Ty1_value)

        #print "making m2_m3_collinearmass"
        self.m2_m3_collinearmass_branch = the_tree.GetBranch("m2_m3_collinearmass")
        #if not self.m2_m3_collinearmass_branch and "m2_m3_collinearmass" not in self.complained:
        if not self.m2_m3_collinearmass_branch and "m2_m3_collinearmass":
            warnings.warn( "MMMTree: Expected branch m2_m3_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_collinearmass")
        else:
            self.m2_m3_collinearmass_branch.SetAddress(<void*>&self.m2_m3_collinearmass_value)

        #print "making m2_m3_collinearmass_JetEnDown"
        self.m2_m3_collinearmass_JetEnDown_branch = the_tree.GetBranch("m2_m3_collinearmass_JetEnDown")
        #if not self.m2_m3_collinearmass_JetEnDown_branch and "m2_m3_collinearmass_JetEnDown" not in self.complained:
        if not self.m2_m3_collinearmass_JetEnDown_branch and "m2_m3_collinearmass_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m2_m3_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_collinearmass_JetEnDown")
        else:
            self.m2_m3_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.m2_m3_collinearmass_JetEnDown_value)

        #print "making m2_m3_collinearmass_JetEnUp"
        self.m2_m3_collinearmass_JetEnUp_branch = the_tree.GetBranch("m2_m3_collinearmass_JetEnUp")
        #if not self.m2_m3_collinearmass_JetEnUp_branch and "m2_m3_collinearmass_JetEnUp" not in self.complained:
        if not self.m2_m3_collinearmass_JetEnUp_branch and "m2_m3_collinearmass_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m2_m3_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_collinearmass_JetEnUp")
        else:
            self.m2_m3_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.m2_m3_collinearmass_JetEnUp_value)

        #print "making m2_m3_collinearmass_UnclusteredEnDown"
        self.m2_m3_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("m2_m3_collinearmass_UnclusteredEnDown")
        #if not self.m2_m3_collinearmass_UnclusteredEnDown_branch and "m2_m3_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.m2_m3_collinearmass_UnclusteredEnDown_branch and "m2_m3_collinearmass_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m2_m3_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_collinearmass_UnclusteredEnDown")
        else:
            self.m2_m3_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.m2_m3_collinearmass_UnclusteredEnDown_value)

        #print "making m2_m3_collinearmass_UnclusteredEnUp"
        self.m2_m3_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("m2_m3_collinearmass_UnclusteredEnUp")
        #if not self.m2_m3_collinearmass_UnclusteredEnUp_branch and "m2_m3_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.m2_m3_collinearmass_UnclusteredEnUp_branch and "m2_m3_collinearmass_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m2_m3_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m2_m3_collinearmass_UnclusteredEnUp")
        else:
            self.m2_m3_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.m2_m3_collinearmass_UnclusteredEnUp_value)

        #print "making m3AbsEta"
        self.m3AbsEta_branch = the_tree.GetBranch("m3AbsEta")
        #if not self.m3AbsEta_branch and "m3AbsEta" not in self.complained:
        if not self.m3AbsEta_branch and "m3AbsEta":
            warnings.warn( "MMMTree: Expected branch m3AbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3AbsEta")
        else:
            self.m3AbsEta_branch.SetAddress(<void*>&self.m3AbsEta_value)

        #print "making m3BestTrackType"
        self.m3BestTrackType_branch = the_tree.GetBranch("m3BestTrackType")
        #if not self.m3BestTrackType_branch and "m3BestTrackType" not in self.complained:
        if not self.m3BestTrackType_branch and "m3BestTrackType":
            warnings.warn( "MMMTree: Expected branch m3BestTrackType does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3BestTrackType")
        else:
            self.m3BestTrackType_branch.SetAddress(<void*>&self.m3BestTrackType_value)

        #print "making m3Charge"
        self.m3Charge_branch = the_tree.GetBranch("m3Charge")
        #if not self.m3Charge_branch and "m3Charge" not in self.complained:
        if not self.m3Charge_branch and "m3Charge":
            warnings.warn( "MMMTree: Expected branch m3Charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Charge")
        else:
            self.m3Charge_branch.SetAddress(<void*>&self.m3Charge_value)

        #print "making m3ComesFromHiggs"
        self.m3ComesFromHiggs_branch = the_tree.GetBranch("m3ComesFromHiggs")
        #if not self.m3ComesFromHiggs_branch and "m3ComesFromHiggs" not in self.complained:
        if not self.m3ComesFromHiggs_branch and "m3ComesFromHiggs":
            warnings.warn( "MMMTree: Expected branch m3ComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3ComesFromHiggs")
        else:
            self.m3ComesFromHiggs_branch.SetAddress(<void*>&self.m3ComesFromHiggs_value)

        #print "making m3DPhiToPfMet_ElectronEnDown"
        self.m3DPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("m3DPhiToPfMet_ElectronEnDown")
        #if not self.m3DPhiToPfMet_ElectronEnDown_branch and "m3DPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.m3DPhiToPfMet_ElectronEnDown_branch and "m3DPhiToPfMet_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_ElectronEnDown")
        else:
            self.m3DPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.m3DPhiToPfMet_ElectronEnDown_value)

        #print "making m3DPhiToPfMet_ElectronEnUp"
        self.m3DPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("m3DPhiToPfMet_ElectronEnUp")
        #if not self.m3DPhiToPfMet_ElectronEnUp_branch and "m3DPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.m3DPhiToPfMet_ElectronEnUp_branch and "m3DPhiToPfMet_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_ElectronEnUp")
        else:
            self.m3DPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.m3DPhiToPfMet_ElectronEnUp_value)

        #print "making m3DPhiToPfMet_JetEnDown"
        self.m3DPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("m3DPhiToPfMet_JetEnDown")
        #if not self.m3DPhiToPfMet_JetEnDown_branch and "m3DPhiToPfMet_JetEnDown" not in self.complained:
        if not self.m3DPhiToPfMet_JetEnDown_branch and "m3DPhiToPfMet_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_JetEnDown")
        else:
            self.m3DPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.m3DPhiToPfMet_JetEnDown_value)

        #print "making m3DPhiToPfMet_JetEnUp"
        self.m3DPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("m3DPhiToPfMet_JetEnUp")
        #if not self.m3DPhiToPfMet_JetEnUp_branch and "m3DPhiToPfMet_JetEnUp" not in self.complained:
        if not self.m3DPhiToPfMet_JetEnUp_branch and "m3DPhiToPfMet_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_JetEnUp")
        else:
            self.m3DPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.m3DPhiToPfMet_JetEnUp_value)

        #print "making m3DPhiToPfMet_JetResDown"
        self.m3DPhiToPfMet_JetResDown_branch = the_tree.GetBranch("m3DPhiToPfMet_JetResDown")
        #if not self.m3DPhiToPfMet_JetResDown_branch and "m3DPhiToPfMet_JetResDown" not in self.complained:
        if not self.m3DPhiToPfMet_JetResDown_branch and "m3DPhiToPfMet_JetResDown":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_JetResDown")
        else:
            self.m3DPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.m3DPhiToPfMet_JetResDown_value)

        #print "making m3DPhiToPfMet_JetResUp"
        self.m3DPhiToPfMet_JetResUp_branch = the_tree.GetBranch("m3DPhiToPfMet_JetResUp")
        #if not self.m3DPhiToPfMet_JetResUp_branch and "m3DPhiToPfMet_JetResUp" not in self.complained:
        if not self.m3DPhiToPfMet_JetResUp_branch and "m3DPhiToPfMet_JetResUp":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_JetResUp")
        else:
            self.m3DPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.m3DPhiToPfMet_JetResUp_value)

        #print "making m3DPhiToPfMet_MuonEnDown"
        self.m3DPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("m3DPhiToPfMet_MuonEnDown")
        #if not self.m3DPhiToPfMet_MuonEnDown_branch and "m3DPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.m3DPhiToPfMet_MuonEnDown_branch and "m3DPhiToPfMet_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_MuonEnDown")
        else:
            self.m3DPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.m3DPhiToPfMet_MuonEnDown_value)

        #print "making m3DPhiToPfMet_MuonEnUp"
        self.m3DPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("m3DPhiToPfMet_MuonEnUp")
        #if not self.m3DPhiToPfMet_MuonEnUp_branch and "m3DPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.m3DPhiToPfMet_MuonEnUp_branch and "m3DPhiToPfMet_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_MuonEnUp")
        else:
            self.m3DPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.m3DPhiToPfMet_MuonEnUp_value)

        #print "making m3DPhiToPfMet_PhotonEnDown"
        self.m3DPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("m3DPhiToPfMet_PhotonEnDown")
        #if not self.m3DPhiToPfMet_PhotonEnDown_branch and "m3DPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.m3DPhiToPfMet_PhotonEnDown_branch and "m3DPhiToPfMet_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_PhotonEnDown")
        else:
            self.m3DPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.m3DPhiToPfMet_PhotonEnDown_value)

        #print "making m3DPhiToPfMet_PhotonEnUp"
        self.m3DPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("m3DPhiToPfMet_PhotonEnUp")
        #if not self.m3DPhiToPfMet_PhotonEnUp_branch and "m3DPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.m3DPhiToPfMet_PhotonEnUp_branch and "m3DPhiToPfMet_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_PhotonEnUp")
        else:
            self.m3DPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.m3DPhiToPfMet_PhotonEnUp_value)

        #print "making m3DPhiToPfMet_TauEnDown"
        self.m3DPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("m3DPhiToPfMet_TauEnDown")
        #if not self.m3DPhiToPfMet_TauEnDown_branch and "m3DPhiToPfMet_TauEnDown" not in self.complained:
        if not self.m3DPhiToPfMet_TauEnDown_branch and "m3DPhiToPfMet_TauEnDown":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_TauEnDown")
        else:
            self.m3DPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.m3DPhiToPfMet_TauEnDown_value)

        #print "making m3DPhiToPfMet_TauEnUp"
        self.m3DPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("m3DPhiToPfMet_TauEnUp")
        #if not self.m3DPhiToPfMet_TauEnUp_branch and "m3DPhiToPfMet_TauEnUp" not in self.complained:
        if not self.m3DPhiToPfMet_TauEnUp_branch and "m3DPhiToPfMet_TauEnUp":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_TauEnUp")
        else:
            self.m3DPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.m3DPhiToPfMet_TauEnUp_value)

        #print "making m3DPhiToPfMet_UnclusteredEnDown"
        self.m3DPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("m3DPhiToPfMet_UnclusteredEnDown")
        #if not self.m3DPhiToPfMet_UnclusteredEnDown_branch and "m3DPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.m3DPhiToPfMet_UnclusteredEnDown_branch and "m3DPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_UnclusteredEnDown")
        else:
            self.m3DPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.m3DPhiToPfMet_UnclusteredEnDown_value)

        #print "making m3DPhiToPfMet_UnclusteredEnUp"
        self.m3DPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("m3DPhiToPfMet_UnclusteredEnUp")
        #if not self.m3DPhiToPfMet_UnclusteredEnUp_branch and "m3DPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.m3DPhiToPfMet_UnclusteredEnUp_branch and "m3DPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_UnclusteredEnUp")
        else:
            self.m3DPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.m3DPhiToPfMet_UnclusteredEnUp_value)

        #print "making m3DPhiToPfMet_type1"
        self.m3DPhiToPfMet_type1_branch = the_tree.GetBranch("m3DPhiToPfMet_type1")
        #if not self.m3DPhiToPfMet_type1_branch and "m3DPhiToPfMet_type1" not in self.complained:
        if not self.m3DPhiToPfMet_type1_branch and "m3DPhiToPfMet_type1":
            warnings.warn( "MMMTree: Expected branch m3DPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3DPhiToPfMet_type1")
        else:
            self.m3DPhiToPfMet_type1_branch.SetAddress(<void*>&self.m3DPhiToPfMet_type1_value)

        #print "making m3EcalIsoDR03"
        self.m3EcalIsoDR03_branch = the_tree.GetBranch("m3EcalIsoDR03")
        #if not self.m3EcalIsoDR03_branch and "m3EcalIsoDR03" not in self.complained:
        if not self.m3EcalIsoDR03_branch and "m3EcalIsoDR03":
            warnings.warn( "MMMTree: Expected branch m3EcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3EcalIsoDR03")
        else:
            self.m3EcalIsoDR03_branch.SetAddress(<void*>&self.m3EcalIsoDR03_value)

        #print "making m3EffectiveArea2011"
        self.m3EffectiveArea2011_branch = the_tree.GetBranch("m3EffectiveArea2011")
        #if not self.m3EffectiveArea2011_branch and "m3EffectiveArea2011" not in self.complained:
        if not self.m3EffectiveArea2011_branch and "m3EffectiveArea2011":
            warnings.warn( "MMMTree: Expected branch m3EffectiveArea2011 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3EffectiveArea2011")
        else:
            self.m3EffectiveArea2011_branch.SetAddress(<void*>&self.m3EffectiveArea2011_value)

        #print "making m3EffectiveArea2012"
        self.m3EffectiveArea2012_branch = the_tree.GetBranch("m3EffectiveArea2012")
        #if not self.m3EffectiveArea2012_branch and "m3EffectiveArea2012" not in self.complained:
        if not self.m3EffectiveArea2012_branch and "m3EffectiveArea2012":
            warnings.warn( "MMMTree: Expected branch m3EffectiveArea2012 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3EffectiveArea2012")
        else:
            self.m3EffectiveArea2012_branch.SetAddress(<void*>&self.m3EffectiveArea2012_value)

        #print "making m3Eta"
        self.m3Eta_branch = the_tree.GetBranch("m3Eta")
        #if not self.m3Eta_branch and "m3Eta" not in self.complained:
        if not self.m3Eta_branch and "m3Eta":
            warnings.warn( "MMMTree: Expected branch m3Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Eta")
        else:
            self.m3Eta_branch.SetAddress(<void*>&self.m3Eta_value)

        #print "making m3Eta_MuonEnDown"
        self.m3Eta_MuonEnDown_branch = the_tree.GetBranch("m3Eta_MuonEnDown")
        #if not self.m3Eta_MuonEnDown_branch and "m3Eta_MuonEnDown" not in self.complained:
        if not self.m3Eta_MuonEnDown_branch and "m3Eta_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m3Eta_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Eta_MuonEnDown")
        else:
            self.m3Eta_MuonEnDown_branch.SetAddress(<void*>&self.m3Eta_MuonEnDown_value)

        #print "making m3Eta_MuonEnUp"
        self.m3Eta_MuonEnUp_branch = the_tree.GetBranch("m3Eta_MuonEnUp")
        #if not self.m3Eta_MuonEnUp_branch and "m3Eta_MuonEnUp" not in self.complained:
        if not self.m3Eta_MuonEnUp_branch and "m3Eta_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m3Eta_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Eta_MuonEnUp")
        else:
            self.m3Eta_MuonEnUp_branch.SetAddress(<void*>&self.m3Eta_MuonEnUp_value)

        #print "making m3GenCharge"
        self.m3GenCharge_branch = the_tree.GetBranch("m3GenCharge")
        #if not self.m3GenCharge_branch and "m3GenCharge" not in self.complained:
        if not self.m3GenCharge_branch and "m3GenCharge":
            warnings.warn( "MMMTree: Expected branch m3GenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenCharge")
        else:
            self.m3GenCharge_branch.SetAddress(<void*>&self.m3GenCharge_value)

        #print "making m3GenEnergy"
        self.m3GenEnergy_branch = the_tree.GetBranch("m3GenEnergy")
        #if not self.m3GenEnergy_branch and "m3GenEnergy" not in self.complained:
        if not self.m3GenEnergy_branch and "m3GenEnergy":
            warnings.warn( "MMMTree: Expected branch m3GenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenEnergy")
        else:
            self.m3GenEnergy_branch.SetAddress(<void*>&self.m3GenEnergy_value)

        #print "making m3GenEta"
        self.m3GenEta_branch = the_tree.GetBranch("m3GenEta")
        #if not self.m3GenEta_branch and "m3GenEta" not in self.complained:
        if not self.m3GenEta_branch and "m3GenEta":
            warnings.warn( "MMMTree: Expected branch m3GenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenEta")
        else:
            self.m3GenEta_branch.SetAddress(<void*>&self.m3GenEta_value)

        #print "making m3GenMotherPdgId"
        self.m3GenMotherPdgId_branch = the_tree.GetBranch("m3GenMotherPdgId")
        #if not self.m3GenMotherPdgId_branch and "m3GenMotherPdgId" not in self.complained:
        if not self.m3GenMotherPdgId_branch and "m3GenMotherPdgId":
            warnings.warn( "MMMTree: Expected branch m3GenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenMotherPdgId")
        else:
            self.m3GenMotherPdgId_branch.SetAddress(<void*>&self.m3GenMotherPdgId_value)

        #print "making m3GenPdgId"
        self.m3GenPdgId_branch = the_tree.GetBranch("m3GenPdgId")
        #if not self.m3GenPdgId_branch and "m3GenPdgId" not in self.complained:
        if not self.m3GenPdgId_branch and "m3GenPdgId":
            warnings.warn( "MMMTree: Expected branch m3GenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenPdgId")
        else:
            self.m3GenPdgId_branch.SetAddress(<void*>&self.m3GenPdgId_value)

        #print "making m3GenPhi"
        self.m3GenPhi_branch = the_tree.GetBranch("m3GenPhi")
        #if not self.m3GenPhi_branch and "m3GenPhi" not in self.complained:
        if not self.m3GenPhi_branch and "m3GenPhi":
            warnings.warn( "MMMTree: Expected branch m3GenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenPhi")
        else:
            self.m3GenPhi_branch.SetAddress(<void*>&self.m3GenPhi_value)

        #print "making m3GenPrompt"
        self.m3GenPrompt_branch = the_tree.GetBranch("m3GenPrompt")
        #if not self.m3GenPrompt_branch and "m3GenPrompt" not in self.complained:
        if not self.m3GenPrompt_branch and "m3GenPrompt":
            warnings.warn( "MMMTree: Expected branch m3GenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenPrompt")
        else:
            self.m3GenPrompt_branch.SetAddress(<void*>&self.m3GenPrompt_value)

        #print "making m3GenPromptTauDecay"
        self.m3GenPromptTauDecay_branch = the_tree.GetBranch("m3GenPromptTauDecay")
        #if not self.m3GenPromptTauDecay_branch and "m3GenPromptTauDecay" not in self.complained:
        if not self.m3GenPromptTauDecay_branch and "m3GenPromptTauDecay":
            warnings.warn( "MMMTree: Expected branch m3GenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenPromptTauDecay")
        else:
            self.m3GenPromptTauDecay_branch.SetAddress(<void*>&self.m3GenPromptTauDecay_value)

        #print "making m3GenPt"
        self.m3GenPt_branch = the_tree.GetBranch("m3GenPt")
        #if not self.m3GenPt_branch and "m3GenPt" not in self.complained:
        if not self.m3GenPt_branch and "m3GenPt":
            warnings.warn( "MMMTree: Expected branch m3GenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenPt")
        else:
            self.m3GenPt_branch.SetAddress(<void*>&self.m3GenPt_value)

        #print "making m3GenTauDecay"
        self.m3GenTauDecay_branch = the_tree.GetBranch("m3GenTauDecay")
        #if not self.m3GenTauDecay_branch and "m3GenTauDecay" not in self.complained:
        if not self.m3GenTauDecay_branch and "m3GenTauDecay":
            warnings.warn( "MMMTree: Expected branch m3GenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenTauDecay")
        else:
            self.m3GenTauDecay_branch.SetAddress(<void*>&self.m3GenTauDecay_value)

        #print "making m3GenVZ"
        self.m3GenVZ_branch = the_tree.GetBranch("m3GenVZ")
        #if not self.m3GenVZ_branch and "m3GenVZ" not in self.complained:
        if not self.m3GenVZ_branch and "m3GenVZ":
            warnings.warn( "MMMTree: Expected branch m3GenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenVZ")
        else:
            self.m3GenVZ_branch.SetAddress(<void*>&self.m3GenVZ_value)

        #print "making m3GenVtxPVMatch"
        self.m3GenVtxPVMatch_branch = the_tree.GetBranch("m3GenVtxPVMatch")
        #if not self.m3GenVtxPVMatch_branch and "m3GenVtxPVMatch" not in self.complained:
        if not self.m3GenVtxPVMatch_branch and "m3GenVtxPVMatch":
            warnings.warn( "MMMTree: Expected branch m3GenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3GenVtxPVMatch")
        else:
            self.m3GenVtxPVMatch_branch.SetAddress(<void*>&self.m3GenVtxPVMatch_value)

        #print "making m3HcalIsoDR03"
        self.m3HcalIsoDR03_branch = the_tree.GetBranch("m3HcalIsoDR03")
        #if not self.m3HcalIsoDR03_branch and "m3HcalIsoDR03" not in self.complained:
        if not self.m3HcalIsoDR03_branch and "m3HcalIsoDR03":
            warnings.warn( "MMMTree: Expected branch m3HcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3HcalIsoDR03")
        else:
            self.m3HcalIsoDR03_branch.SetAddress(<void*>&self.m3HcalIsoDR03_value)

        #print "making m3IP3D"
        self.m3IP3D_branch = the_tree.GetBranch("m3IP3D")
        #if not self.m3IP3D_branch and "m3IP3D" not in self.complained:
        if not self.m3IP3D_branch and "m3IP3D":
            warnings.warn( "MMMTree: Expected branch m3IP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3IP3D")
        else:
            self.m3IP3D_branch.SetAddress(<void*>&self.m3IP3D_value)

        #print "making m3IP3DErr"
        self.m3IP3DErr_branch = the_tree.GetBranch("m3IP3DErr")
        #if not self.m3IP3DErr_branch and "m3IP3DErr" not in self.complained:
        if not self.m3IP3DErr_branch and "m3IP3DErr":
            warnings.warn( "MMMTree: Expected branch m3IP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3IP3DErr")
        else:
            self.m3IP3DErr_branch.SetAddress(<void*>&self.m3IP3DErr_value)

        #print "making m3IsGlobal"
        self.m3IsGlobal_branch = the_tree.GetBranch("m3IsGlobal")
        #if not self.m3IsGlobal_branch and "m3IsGlobal" not in self.complained:
        if not self.m3IsGlobal_branch and "m3IsGlobal":
            warnings.warn( "MMMTree: Expected branch m3IsGlobal does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3IsGlobal")
        else:
            self.m3IsGlobal_branch.SetAddress(<void*>&self.m3IsGlobal_value)

        #print "making m3IsPFMuon"
        self.m3IsPFMuon_branch = the_tree.GetBranch("m3IsPFMuon")
        #if not self.m3IsPFMuon_branch and "m3IsPFMuon" not in self.complained:
        if not self.m3IsPFMuon_branch and "m3IsPFMuon":
            warnings.warn( "MMMTree: Expected branch m3IsPFMuon does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3IsPFMuon")
        else:
            self.m3IsPFMuon_branch.SetAddress(<void*>&self.m3IsPFMuon_value)

        #print "making m3IsTracker"
        self.m3IsTracker_branch = the_tree.GetBranch("m3IsTracker")
        #if not self.m3IsTracker_branch and "m3IsTracker" not in self.complained:
        if not self.m3IsTracker_branch and "m3IsTracker":
            warnings.warn( "MMMTree: Expected branch m3IsTracker does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3IsTracker")
        else:
            self.m3IsTracker_branch.SetAddress(<void*>&self.m3IsTracker_value)

        #print "making m3JetArea"
        self.m3JetArea_branch = the_tree.GetBranch("m3JetArea")
        #if not self.m3JetArea_branch and "m3JetArea" not in self.complained:
        if not self.m3JetArea_branch and "m3JetArea":
            warnings.warn( "MMMTree: Expected branch m3JetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetArea")
        else:
            self.m3JetArea_branch.SetAddress(<void*>&self.m3JetArea_value)

        #print "making m3JetBtag"
        self.m3JetBtag_branch = the_tree.GetBranch("m3JetBtag")
        #if not self.m3JetBtag_branch and "m3JetBtag" not in self.complained:
        if not self.m3JetBtag_branch and "m3JetBtag":
            warnings.warn( "MMMTree: Expected branch m3JetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetBtag")
        else:
            self.m3JetBtag_branch.SetAddress(<void*>&self.m3JetBtag_value)

        #print "making m3JetEtaEtaMoment"
        self.m3JetEtaEtaMoment_branch = the_tree.GetBranch("m3JetEtaEtaMoment")
        #if not self.m3JetEtaEtaMoment_branch and "m3JetEtaEtaMoment" not in self.complained:
        if not self.m3JetEtaEtaMoment_branch and "m3JetEtaEtaMoment":
            warnings.warn( "MMMTree: Expected branch m3JetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetEtaEtaMoment")
        else:
            self.m3JetEtaEtaMoment_branch.SetAddress(<void*>&self.m3JetEtaEtaMoment_value)

        #print "making m3JetEtaPhiMoment"
        self.m3JetEtaPhiMoment_branch = the_tree.GetBranch("m3JetEtaPhiMoment")
        #if not self.m3JetEtaPhiMoment_branch and "m3JetEtaPhiMoment" not in self.complained:
        if not self.m3JetEtaPhiMoment_branch and "m3JetEtaPhiMoment":
            warnings.warn( "MMMTree: Expected branch m3JetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetEtaPhiMoment")
        else:
            self.m3JetEtaPhiMoment_branch.SetAddress(<void*>&self.m3JetEtaPhiMoment_value)

        #print "making m3JetEtaPhiSpread"
        self.m3JetEtaPhiSpread_branch = the_tree.GetBranch("m3JetEtaPhiSpread")
        #if not self.m3JetEtaPhiSpread_branch and "m3JetEtaPhiSpread" not in self.complained:
        if not self.m3JetEtaPhiSpread_branch and "m3JetEtaPhiSpread":
            warnings.warn( "MMMTree: Expected branch m3JetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetEtaPhiSpread")
        else:
            self.m3JetEtaPhiSpread_branch.SetAddress(<void*>&self.m3JetEtaPhiSpread_value)

        #print "making m3JetPFCISVBtag"
        self.m3JetPFCISVBtag_branch = the_tree.GetBranch("m3JetPFCISVBtag")
        #if not self.m3JetPFCISVBtag_branch and "m3JetPFCISVBtag" not in self.complained:
        if not self.m3JetPFCISVBtag_branch and "m3JetPFCISVBtag":
            warnings.warn( "MMMTree: Expected branch m3JetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetPFCISVBtag")
        else:
            self.m3JetPFCISVBtag_branch.SetAddress(<void*>&self.m3JetPFCISVBtag_value)

        #print "making m3JetPartonFlavour"
        self.m3JetPartonFlavour_branch = the_tree.GetBranch("m3JetPartonFlavour")
        #if not self.m3JetPartonFlavour_branch and "m3JetPartonFlavour" not in self.complained:
        if not self.m3JetPartonFlavour_branch and "m3JetPartonFlavour":
            warnings.warn( "MMMTree: Expected branch m3JetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetPartonFlavour")
        else:
            self.m3JetPartonFlavour_branch.SetAddress(<void*>&self.m3JetPartonFlavour_value)

        #print "making m3JetPhiPhiMoment"
        self.m3JetPhiPhiMoment_branch = the_tree.GetBranch("m3JetPhiPhiMoment")
        #if not self.m3JetPhiPhiMoment_branch and "m3JetPhiPhiMoment" not in self.complained:
        if not self.m3JetPhiPhiMoment_branch and "m3JetPhiPhiMoment":
            warnings.warn( "MMMTree: Expected branch m3JetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetPhiPhiMoment")
        else:
            self.m3JetPhiPhiMoment_branch.SetAddress(<void*>&self.m3JetPhiPhiMoment_value)

        #print "making m3JetPt"
        self.m3JetPt_branch = the_tree.GetBranch("m3JetPt")
        #if not self.m3JetPt_branch and "m3JetPt" not in self.complained:
        if not self.m3JetPt_branch and "m3JetPt":
            warnings.warn( "MMMTree: Expected branch m3JetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3JetPt")
        else:
            self.m3JetPt_branch.SetAddress(<void*>&self.m3JetPt_value)

        #print "making m3LowestMll"
        self.m3LowestMll_branch = the_tree.GetBranch("m3LowestMll")
        #if not self.m3LowestMll_branch and "m3LowestMll" not in self.complained:
        if not self.m3LowestMll_branch and "m3LowestMll":
            warnings.warn( "MMMTree: Expected branch m3LowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3LowestMll")
        else:
            self.m3LowestMll_branch.SetAddress(<void*>&self.m3LowestMll_value)

        #print "making m3Mass"
        self.m3Mass_branch = the_tree.GetBranch("m3Mass")
        #if not self.m3Mass_branch and "m3Mass" not in self.complained:
        if not self.m3Mass_branch and "m3Mass":
            warnings.warn( "MMMTree: Expected branch m3Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Mass")
        else:
            self.m3Mass_branch.SetAddress(<void*>&self.m3Mass_value)

        #print "making m3MatchedStations"
        self.m3MatchedStations_branch = the_tree.GetBranch("m3MatchedStations")
        #if not self.m3MatchedStations_branch and "m3MatchedStations" not in self.complained:
        if not self.m3MatchedStations_branch and "m3MatchedStations":
            warnings.warn( "MMMTree: Expected branch m3MatchedStations does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchedStations")
        else:
            self.m3MatchedStations_branch.SetAddress(<void*>&self.m3MatchedStations_value)

        #print "making m3MatchesDoubleESingleMu"
        self.m3MatchesDoubleESingleMu_branch = the_tree.GetBranch("m3MatchesDoubleESingleMu")
        #if not self.m3MatchesDoubleESingleMu_branch and "m3MatchesDoubleESingleMu" not in self.complained:
        if not self.m3MatchesDoubleESingleMu_branch and "m3MatchesDoubleESingleMu":
            warnings.warn( "MMMTree: Expected branch m3MatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesDoubleESingleMu")
        else:
            self.m3MatchesDoubleESingleMu_branch.SetAddress(<void*>&self.m3MatchesDoubleESingleMu_value)

        #print "making m3MatchesDoubleMu"
        self.m3MatchesDoubleMu_branch = the_tree.GetBranch("m3MatchesDoubleMu")
        #if not self.m3MatchesDoubleMu_branch and "m3MatchesDoubleMu" not in self.complained:
        if not self.m3MatchesDoubleMu_branch and "m3MatchesDoubleMu":
            warnings.warn( "MMMTree: Expected branch m3MatchesDoubleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesDoubleMu")
        else:
            self.m3MatchesDoubleMu_branch.SetAddress(<void*>&self.m3MatchesDoubleMu_value)

        #print "making m3MatchesDoubleMuSingleE"
        self.m3MatchesDoubleMuSingleE_branch = the_tree.GetBranch("m3MatchesDoubleMuSingleE")
        #if not self.m3MatchesDoubleMuSingleE_branch and "m3MatchesDoubleMuSingleE" not in self.complained:
        if not self.m3MatchesDoubleMuSingleE_branch and "m3MatchesDoubleMuSingleE":
            warnings.warn( "MMMTree: Expected branch m3MatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesDoubleMuSingleE")
        else:
            self.m3MatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.m3MatchesDoubleMuSingleE_value)

        #print "making m3MatchesSingleESingleMu"
        self.m3MatchesSingleESingleMu_branch = the_tree.GetBranch("m3MatchesSingleESingleMu")
        #if not self.m3MatchesSingleESingleMu_branch and "m3MatchesSingleESingleMu" not in self.complained:
        if not self.m3MatchesSingleESingleMu_branch and "m3MatchesSingleESingleMu":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleESingleMu")
        else:
            self.m3MatchesSingleESingleMu_branch.SetAddress(<void*>&self.m3MatchesSingleESingleMu_value)

        #print "making m3MatchesSingleMu"
        self.m3MatchesSingleMu_branch = the_tree.GetBranch("m3MatchesSingleMu")
        #if not self.m3MatchesSingleMu_branch and "m3MatchesSingleMu" not in self.complained:
        if not self.m3MatchesSingleMu_branch and "m3MatchesSingleMu":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMu")
        else:
            self.m3MatchesSingleMu_branch.SetAddress(<void*>&self.m3MatchesSingleMu_value)

        #print "making m3MatchesSingleMuIso20"
        self.m3MatchesSingleMuIso20_branch = the_tree.GetBranch("m3MatchesSingleMuIso20")
        #if not self.m3MatchesSingleMuIso20_branch and "m3MatchesSingleMuIso20" not in self.complained:
        if not self.m3MatchesSingleMuIso20_branch and "m3MatchesSingleMuIso20":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMuIso20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMuIso20")
        else:
            self.m3MatchesSingleMuIso20_branch.SetAddress(<void*>&self.m3MatchesSingleMuIso20_value)

        #print "making m3MatchesSingleMuIsoTk20"
        self.m3MatchesSingleMuIsoTk20_branch = the_tree.GetBranch("m3MatchesSingleMuIsoTk20")
        #if not self.m3MatchesSingleMuIsoTk20_branch and "m3MatchesSingleMuIsoTk20" not in self.complained:
        if not self.m3MatchesSingleMuIsoTk20_branch and "m3MatchesSingleMuIsoTk20":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMuIsoTk20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMuIsoTk20")
        else:
            self.m3MatchesSingleMuIsoTk20_branch.SetAddress(<void*>&self.m3MatchesSingleMuIsoTk20_value)

        #print "making m3MatchesSingleMuSingleE"
        self.m3MatchesSingleMuSingleE_branch = the_tree.GetBranch("m3MatchesSingleMuSingleE")
        #if not self.m3MatchesSingleMuSingleE_branch and "m3MatchesSingleMuSingleE" not in self.complained:
        if not self.m3MatchesSingleMuSingleE_branch and "m3MatchesSingleMuSingleE":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMuSingleE")
        else:
            self.m3MatchesSingleMuSingleE_branch.SetAddress(<void*>&self.m3MatchesSingleMuSingleE_value)

        #print "making m3MatchesSingleMu_leg1"
        self.m3MatchesSingleMu_leg1_branch = the_tree.GetBranch("m3MatchesSingleMu_leg1")
        #if not self.m3MatchesSingleMu_leg1_branch and "m3MatchesSingleMu_leg1" not in self.complained:
        if not self.m3MatchesSingleMu_leg1_branch and "m3MatchesSingleMu_leg1":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMu_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMu_leg1")
        else:
            self.m3MatchesSingleMu_leg1_branch.SetAddress(<void*>&self.m3MatchesSingleMu_leg1_value)

        #print "making m3MatchesSingleMu_leg1_noiso"
        self.m3MatchesSingleMu_leg1_noiso_branch = the_tree.GetBranch("m3MatchesSingleMu_leg1_noiso")
        #if not self.m3MatchesSingleMu_leg1_noiso_branch and "m3MatchesSingleMu_leg1_noiso" not in self.complained:
        if not self.m3MatchesSingleMu_leg1_noiso_branch and "m3MatchesSingleMu_leg1_noiso":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMu_leg1_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMu_leg1_noiso")
        else:
            self.m3MatchesSingleMu_leg1_noiso_branch.SetAddress(<void*>&self.m3MatchesSingleMu_leg1_noiso_value)

        #print "making m3MatchesSingleMu_leg2"
        self.m3MatchesSingleMu_leg2_branch = the_tree.GetBranch("m3MatchesSingleMu_leg2")
        #if not self.m3MatchesSingleMu_leg2_branch and "m3MatchesSingleMu_leg2" not in self.complained:
        if not self.m3MatchesSingleMu_leg2_branch and "m3MatchesSingleMu_leg2":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMu_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMu_leg2")
        else:
            self.m3MatchesSingleMu_leg2_branch.SetAddress(<void*>&self.m3MatchesSingleMu_leg2_value)

        #print "making m3MatchesSingleMu_leg2_noiso"
        self.m3MatchesSingleMu_leg2_noiso_branch = the_tree.GetBranch("m3MatchesSingleMu_leg2_noiso")
        #if not self.m3MatchesSingleMu_leg2_noiso_branch and "m3MatchesSingleMu_leg2_noiso" not in self.complained:
        if not self.m3MatchesSingleMu_leg2_noiso_branch and "m3MatchesSingleMu_leg2_noiso":
            warnings.warn( "MMMTree: Expected branch m3MatchesSingleMu_leg2_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesSingleMu_leg2_noiso")
        else:
            self.m3MatchesSingleMu_leg2_noiso_branch.SetAddress(<void*>&self.m3MatchesSingleMu_leg2_noiso_value)

        #print "making m3MatchesTripleMu"
        self.m3MatchesTripleMu_branch = the_tree.GetBranch("m3MatchesTripleMu")
        #if not self.m3MatchesTripleMu_branch and "m3MatchesTripleMu" not in self.complained:
        if not self.m3MatchesTripleMu_branch and "m3MatchesTripleMu":
            warnings.warn( "MMMTree: Expected branch m3MatchesTripleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MatchesTripleMu")
        else:
            self.m3MatchesTripleMu_branch.SetAddress(<void*>&self.m3MatchesTripleMu_value)

        #print "making m3MtToPfMet_ElectronEnDown"
        self.m3MtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("m3MtToPfMet_ElectronEnDown")
        #if not self.m3MtToPfMet_ElectronEnDown_branch and "m3MtToPfMet_ElectronEnDown" not in self.complained:
        if not self.m3MtToPfMet_ElectronEnDown_branch and "m3MtToPfMet_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_ElectronEnDown")
        else:
            self.m3MtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.m3MtToPfMet_ElectronEnDown_value)

        #print "making m3MtToPfMet_ElectronEnUp"
        self.m3MtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("m3MtToPfMet_ElectronEnUp")
        #if not self.m3MtToPfMet_ElectronEnUp_branch and "m3MtToPfMet_ElectronEnUp" not in self.complained:
        if not self.m3MtToPfMet_ElectronEnUp_branch and "m3MtToPfMet_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_ElectronEnUp")
        else:
            self.m3MtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.m3MtToPfMet_ElectronEnUp_value)

        #print "making m3MtToPfMet_JetEnDown"
        self.m3MtToPfMet_JetEnDown_branch = the_tree.GetBranch("m3MtToPfMet_JetEnDown")
        #if not self.m3MtToPfMet_JetEnDown_branch and "m3MtToPfMet_JetEnDown" not in self.complained:
        if not self.m3MtToPfMet_JetEnDown_branch and "m3MtToPfMet_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_JetEnDown")
        else:
            self.m3MtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.m3MtToPfMet_JetEnDown_value)

        #print "making m3MtToPfMet_JetEnUp"
        self.m3MtToPfMet_JetEnUp_branch = the_tree.GetBranch("m3MtToPfMet_JetEnUp")
        #if not self.m3MtToPfMet_JetEnUp_branch and "m3MtToPfMet_JetEnUp" not in self.complained:
        if not self.m3MtToPfMet_JetEnUp_branch and "m3MtToPfMet_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_JetEnUp")
        else:
            self.m3MtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.m3MtToPfMet_JetEnUp_value)

        #print "making m3MtToPfMet_JetResDown"
        self.m3MtToPfMet_JetResDown_branch = the_tree.GetBranch("m3MtToPfMet_JetResDown")
        #if not self.m3MtToPfMet_JetResDown_branch and "m3MtToPfMet_JetResDown" not in self.complained:
        if not self.m3MtToPfMet_JetResDown_branch and "m3MtToPfMet_JetResDown":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_JetResDown")
        else:
            self.m3MtToPfMet_JetResDown_branch.SetAddress(<void*>&self.m3MtToPfMet_JetResDown_value)

        #print "making m3MtToPfMet_JetResUp"
        self.m3MtToPfMet_JetResUp_branch = the_tree.GetBranch("m3MtToPfMet_JetResUp")
        #if not self.m3MtToPfMet_JetResUp_branch and "m3MtToPfMet_JetResUp" not in self.complained:
        if not self.m3MtToPfMet_JetResUp_branch and "m3MtToPfMet_JetResUp":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_JetResUp")
        else:
            self.m3MtToPfMet_JetResUp_branch.SetAddress(<void*>&self.m3MtToPfMet_JetResUp_value)

        #print "making m3MtToPfMet_MuonEnDown"
        self.m3MtToPfMet_MuonEnDown_branch = the_tree.GetBranch("m3MtToPfMet_MuonEnDown")
        #if not self.m3MtToPfMet_MuonEnDown_branch and "m3MtToPfMet_MuonEnDown" not in self.complained:
        if not self.m3MtToPfMet_MuonEnDown_branch and "m3MtToPfMet_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_MuonEnDown")
        else:
            self.m3MtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.m3MtToPfMet_MuonEnDown_value)

        #print "making m3MtToPfMet_MuonEnUp"
        self.m3MtToPfMet_MuonEnUp_branch = the_tree.GetBranch("m3MtToPfMet_MuonEnUp")
        #if not self.m3MtToPfMet_MuonEnUp_branch and "m3MtToPfMet_MuonEnUp" not in self.complained:
        if not self.m3MtToPfMet_MuonEnUp_branch and "m3MtToPfMet_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_MuonEnUp")
        else:
            self.m3MtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.m3MtToPfMet_MuonEnUp_value)

        #print "making m3MtToPfMet_PhotonEnDown"
        self.m3MtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("m3MtToPfMet_PhotonEnDown")
        #if not self.m3MtToPfMet_PhotonEnDown_branch and "m3MtToPfMet_PhotonEnDown" not in self.complained:
        if not self.m3MtToPfMet_PhotonEnDown_branch and "m3MtToPfMet_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_PhotonEnDown")
        else:
            self.m3MtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.m3MtToPfMet_PhotonEnDown_value)

        #print "making m3MtToPfMet_PhotonEnUp"
        self.m3MtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("m3MtToPfMet_PhotonEnUp")
        #if not self.m3MtToPfMet_PhotonEnUp_branch and "m3MtToPfMet_PhotonEnUp" not in self.complained:
        if not self.m3MtToPfMet_PhotonEnUp_branch and "m3MtToPfMet_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_PhotonEnUp")
        else:
            self.m3MtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.m3MtToPfMet_PhotonEnUp_value)

        #print "making m3MtToPfMet_Raw"
        self.m3MtToPfMet_Raw_branch = the_tree.GetBranch("m3MtToPfMet_Raw")
        #if not self.m3MtToPfMet_Raw_branch and "m3MtToPfMet_Raw" not in self.complained:
        if not self.m3MtToPfMet_Raw_branch and "m3MtToPfMet_Raw":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_Raw")
        else:
            self.m3MtToPfMet_Raw_branch.SetAddress(<void*>&self.m3MtToPfMet_Raw_value)

        #print "making m3MtToPfMet_TauEnDown"
        self.m3MtToPfMet_TauEnDown_branch = the_tree.GetBranch("m3MtToPfMet_TauEnDown")
        #if not self.m3MtToPfMet_TauEnDown_branch and "m3MtToPfMet_TauEnDown" not in self.complained:
        if not self.m3MtToPfMet_TauEnDown_branch and "m3MtToPfMet_TauEnDown":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_TauEnDown")
        else:
            self.m3MtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.m3MtToPfMet_TauEnDown_value)

        #print "making m3MtToPfMet_TauEnUp"
        self.m3MtToPfMet_TauEnUp_branch = the_tree.GetBranch("m3MtToPfMet_TauEnUp")
        #if not self.m3MtToPfMet_TauEnUp_branch and "m3MtToPfMet_TauEnUp" not in self.complained:
        if not self.m3MtToPfMet_TauEnUp_branch and "m3MtToPfMet_TauEnUp":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_TauEnUp")
        else:
            self.m3MtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.m3MtToPfMet_TauEnUp_value)

        #print "making m3MtToPfMet_UnclusteredEnDown"
        self.m3MtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("m3MtToPfMet_UnclusteredEnDown")
        #if not self.m3MtToPfMet_UnclusteredEnDown_branch and "m3MtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.m3MtToPfMet_UnclusteredEnDown_branch and "m3MtToPfMet_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_UnclusteredEnDown")
        else:
            self.m3MtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.m3MtToPfMet_UnclusteredEnDown_value)

        #print "making m3MtToPfMet_UnclusteredEnUp"
        self.m3MtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("m3MtToPfMet_UnclusteredEnUp")
        #if not self.m3MtToPfMet_UnclusteredEnUp_branch and "m3MtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.m3MtToPfMet_UnclusteredEnUp_branch and "m3MtToPfMet_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_UnclusteredEnUp")
        else:
            self.m3MtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.m3MtToPfMet_UnclusteredEnUp_value)

        #print "making m3MtToPfMet_type1"
        self.m3MtToPfMet_type1_branch = the_tree.GetBranch("m3MtToPfMet_type1")
        #if not self.m3MtToPfMet_type1_branch and "m3MtToPfMet_type1" not in self.complained:
        if not self.m3MtToPfMet_type1_branch and "m3MtToPfMet_type1":
            warnings.warn( "MMMTree: Expected branch m3MtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MtToPfMet_type1")
        else:
            self.m3MtToPfMet_type1_branch.SetAddress(<void*>&self.m3MtToPfMet_type1_value)

        #print "making m3MuonHits"
        self.m3MuonHits_branch = the_tree.GetBranch("m3MuonHits")
        #if not self.m3MuonHits_branch and "m3MuonHits" not in self.complained:
        if not self.m3MuonHits_branch and "m3MuonHits":
            warnings.warn( "MMMTree: Expected branch m3MuonHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3MuonHits")
        else:
            self.m3MuonHits_branch.SetAddress(<void*>&self.m3MuonHits_value)

        #print "making m3NearestZMass"
        self.m3NearestZMass_branch = the_tree.GetBranch("m3NearestZMass")
        #if not self.m3NearestZMass_branch and "m3NearestZMass" not in self.complained:
        if not self.m3NearestZMass_branch and "m3NearestZMass":
            warnings.warn( "MMMTree: Expected branch m3NearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3NearestZMass")
        else:
            self.m3NearestZMass_branch.SetAddress(<void*>&self.m3NearestZMass_value)

        #print "making m3NormTrkChi2"
        self.m3NormTrkChi2_branch = the_tree.GetBranch("m3NormTrkChi2")
        #if not self.m3NormTrkChi2_branch and "m3NormTrkChi2" not in self.complained:
        if not self.m3NormTrkChi2_branch and "m3NormTrkChi2":
            warnings.warn( "MMMTree: Expected branch m3NormTrkChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3NormTrkChi2")
        else:
            self.m3NormTrkChi2_branch.SetAddress(<void*>&self.m3NormTrkChi2_value)

        #print "making m3PFChargedIso"
        self.m3PFChargedIso_branch = the_tree.GetBranch("m3PFChargedIso")
        #if not self.m3PFChargedIso_branch and "m3PFChargedIso" not in self.complained:
        if not self.m3PFChargedIso_branch and "m3PFChargedIso":
            warnings.warn( "MMMTree: Expected branch m3PFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PFChargedIso")
        else:
            self.m3PFChargedIso_branch.SetAddress(<void*>&self.m3PFChargedIso_value)

        #print "making m3PFIDLoose"
        self.m3PFIDLoose_branch = the_tree.GetBranch("m3PFIDLoose")
        #if not self.m3PFIDLoose_branch and "m3PFIDLoose" not in self.complained:
        if not self.m3PFIDLoose_branch and "m3PFIDLoose":
            warnings.warn( "MMMTree: Expected branch m3PFIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PFIDLoose")
        else:
            self.m3PFIDLoose_branch.SetAddress(<void*>&self.m3PFIDLoose_value)

        #print "making m3PFIDMedium"
        self.m3PFIDMedium_branch = the_tree.GetBranch("m3PFIDMedium")
        #if not self.m3PFIDMedium_branch and "m3PFIDMedium" not in self.complained:
        if not self.m3PFIDMedium_branch and "m3PFIDMedium":
            warnings.warn( "MMMTree: Expected branch m3PFIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PFIDMedium")
        else:
            self.m3PFIDMedium_branch.SetAddress(<void*>&self.m3PFIDMedium_value)

        #print "making m3PFIDTight"
        self.m3PFIDTight_branch = the_tree.GetBranch("m3PFIDTight")
        #if not self.m3PFIDTight_branch and "m3PFIDTight" not in self.complained:
        if not self.m3PFIDTight_branch and "m3PFIDTight":
            warnings.warn( "MMMTree: Expected branch m3PFIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PFIDTight")
        else:
            self.m3PFIDTight_branch.SetAddress(<void*>&self.m3PFIDTight_value)

        #print "making m3PFNeutralIso"
        self.m3PFNeutralIso_branch = the_tree.GetBranch("m3PFNeutralIso")
        #if not self.m3PFNeutralIso_branch and "m3PFNeutralIso" not in self.complained:
        if not self.m3PFNeutralIso_branch and "m3PFNeutralIso":
            warnings.warn( "MMMTree: Expected branch m3PFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PFNeutralIso")
        else:
            self.m3PFNeutralIso_branch.SetAddress(<void*>&self.m3PFNeutralIso_value)

        #print "making m3PFPUChargedIso"
        self.m3PFPUChargedIso_branch = the_tree.GetBranch("m3PFPUChargedIso")
        #if not self.m3PFPUChargedIso_branch and "m3PFPUChargedIso" not in self.complained:
        if not self.m3PFPUChargedIso_branch and "m3PFPUChargedIso":
            warnings.warn( "MMMTree: Expected branch m3PFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PFPUChargedIso")
        else:
            self.m3PFPUChargedIso_branch.SetAddress(<void*>&self.m3PFPUChargedIso_value)

        #print "making m3PFPhotonIso"
        self.m3PFPhotonIso_branch = the_tree.GetBranch("m3PFPhotonIso")
        #if not self.m3PFPhotonIso_branch and "m3PFPhotonIso" not in self.complained:
        if not self.m3PFPhotonIso_branch and "m3PFPhotonIso":
            warnings.warn( "MMMTree: Expected branch m3PFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PFPhotonIso")
        else:
            self.m3PFPhotonIso_branch.SetAddress(<void*>&self.m3PFPhotonIso_value)

        #print "making m3PVDXY"
        self.m3PVDXY_branch = the_tree.GetBranch("m3PVDXY")
        #if not self.m3PVDXY_branch and "m3PVDXY" not in self.complained:
        if not self.m3PVDXY_branch and "m3PVDXY":
            warnings.warn( "MMMTree: Expected branch m3PVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PVDXY")
        else:
            self.m3PVDXY_branch.SetAddress(<void*>&self.m3PVDXY_value)

        #print "making m3PVDZ"
        self.m3PVDZ_branch = the_tree.GetBranch("m3PVDZ")
        #if not self.m3PVDZ_branch and "m3PVDZ" not in self.complained:
        if not self.m3PVDZ_branch and "m3PVDZ":
            warnings.warn( "MMMTree: Expected branch m3PVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PVDZ")
        else:
            self.m3PVDZ_branch.SetAddress(<void*>&self.m3PVDZ_value)

        #print "making m3Phi"
        self.m3Phi_branch = the_tree.GetBranch("m3Phi")
        #if not self.m3Phi_branch and "m3Phi" not in self.complained:
        if not self.m3Phi_branch and "m3Phi":
            warnings.warn( "MMMTree: Expected branch m3Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Phi")
        else:
            self.m3Phi_branch.SetAddress(<void*>&self.m3Phi_value)

        #print "making m3Phi_MuonEnDown"
        self.m3Phi_MuonEnDown_branch = the_tree.GetBranch("m3Phi_MuonEnDown")
        #if not self.m3Phi_MuonEnDown_branch and "m3Phi_MuonEnDown" not in self.complained:
        if not self.m3Phi_MuonEnDown_branch and "m3Phi_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m3Phi_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Phi_MuonEnDown")
        else:
            self.m3Phi_MuonEnDown_branch.SetAddress(<void*>&self.m3Phi_MuonEnDown_value)

        #print "making m3Phi_MuonEnUp"
        self.m3Phi_MuonEnUp_branch = the_tree.GetBranch("m3Phi_MuonEnUp")
        #if not self.m3Phi_MuonEnUp_branch and "m3Phi_MuonEnUp" not in self.complained:
        if not self.m3Phi_MuonEnUp_branch and "m3Phi_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m3Phi_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Phi_MuonEnUp")
        else:
            self.m3Phi_MuonEnUp_branch.SetAddress(<void*>&self.m3Phi_MuonEnUp_value)

        #print "making m3PixHits"
        self.m3PixHits_branch = the_tree.GetBranch("m3PixHits")
        #if not self.m3PixHits_branch and "m3PixHits" not in self.complained:
        if not self.m3PixHits_branch and "m3PixHits":
            warnings.warn( "MMMTree: Expected branch m3PixHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3PixHits")
        else:
            self.m3PixHits_branch.SetAddress(<void*>&self.m3PixHits_value)

        #print "making m3Pt"
        self.m3Pt_branch = the_tree.GetBranch("m3Pt")
        #if not self.m3Pt_branch and "m3Pt" not in self.complained:
        if not self.m3Pt_branch and "m3Pt":
            warnings.warn( "MMMTree: Expected branch m3Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Pt")
        else:
            self.m3Pt_branch.SetAddress(<void*>&self.m3Pt_value)

        #print "making m3Pt_MuonEnDown"
        self.m3Pt_MuonEnDown_branch = the_tree.GetBranch("m3Pt_MuonEnDown")
        #if not self.m3Pt_MuonEnDown_branch and "m3Pt_MuonEnDown" not in self.complained:
        if not self.m3Pt_MuonEnDown_branch and "m3Pt_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch m3Pt_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Pt_MuonEnDown")
        else:
            self.m3Pt_MuonEnDown_branch.SetAddress(<void*>&self.m3Pt_MuonEnDown_value)

        #print "making m3Pt_MuonEnUp"
        self.m3Pt_MuonEnUp_branch = the_tree.GetBranch("m3Pt_MuonEnUp")
        #if not self.m3Pt_MuonEnUp_branch and "m3Pt_MuonEnUp" not in self.complained:
        if not self.m3Pt_MuonEnUp_branch and "m3Pt_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch m3Pt_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Pt_MuonEnUp")
        else:
            self.m3Pt_MuonEnUp_branch.SetAddress(<void*>&self.m3Pt_MuonEnUp_value)

        #print "making m3Rank"
        self.m3Rank_branch = the_tree.GetBranch("m3Rank")
        #if not self.m3Rank_branch and "m3Rank" not in self.complained:
        if not self.m3Rank_branch and "m3Rank":
            warnings.warn( "MMMTree: Expected branch m3Rank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Rank")
        else:
            self.m3Rank_branch.SetAddress(<void*>&self.m3Rank_value)

        #print "making m3RelPFIsoDBDefault"
        self.m3RelPFIsoDBDefault_branch = the_tree.GetBranch("m3RelPFIsoDBDefault")
        #if not self.m3RelPFIsoDBDefault_branch and "m3RelPFIsoDBDefault" not in self.complained:
        if not self.m3RelPFIsoDBDefault_branch and "m3RelPFIsoDBDefault":
            warnings.warn( "MMMTree: Expected branch m3RelPFIsoDBDefault does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3RelPFIsoDBDefault")
        else:
            self.m3RelPFIsoDBDefault_branch.SetAddress(<void*>&self.m3RelPFIsoDBDefault_value)

        #print "making m3RelPFIsoRho"
        self.m3RelPFIsoRho_branch = the_tree.GetBranch("m3RelPFIsoRho")
        #if not self.m3RelPFIsoRho_branch and "m3RelPFIsoRho" not in self.complained:
        if not self.m3RelPFIsoRho_branch and "m3RelPFIsoRho":
            warnings.warn( "MMMTree: Expected branch m3RelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3RelPFIsoRho")
        else:
            self.m3RelPFIsoRho_branch.SetAddress(<void*>&self.m3RelPFIsoRho_value)

        #print "making m3Rho"
        self.m3Rho_branch = the_tree.GetBranch("m3Rho")
        #if not self.m3Rho_branch and "m3Rho" not in self.complained:
        if not self.m3Rho_branch and "m3Rho":
            warnings.warn( "MMMTree: Expected branch m3Rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3Rho")
        else:
            self.m3Rho_branch.SetAddress(<void*>&self.m3Rho_value)

        #print "making m3SIP2D"
        self.m3SIP2D_branch = the_tree.GetBranch("m3SIP2D")
        #if not self.m3SIP2D_branch and "m3SIP2D" not in self.complained:
        if not self.m3SIP2D_branch and "m3SIP2D":
            warnings.warn( "MMMTree: Expected branch m3SIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3SIP2D")
        else:
            self.m3SIP2D_branch.SetAddress(<void*>&self.m3SIP2D_value)

        #print "making m3SIP3D"
        self.m3SIP3D_branch = the_tree.GetBranch("m3SIP3D")
        #if not self.m3SIP3D_branch and "m3SIP3D" not in self.complained:
        if not self.m3SIP3D_branch and "m3SIP3D":
            warnings.warn( "MMMTree: Expected branch m3SIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3SIP3D")
        else:
            self.m3SIP3D_branch.SetAddress(<void*>&self.m3SIP3D_value)

        #print "making m3TkLayersWithMeasurement"
        self.m3TkLayersWithMeasurement_branch = the_tree.GetBranch("m3TkLayersWithMeasurement")
        #if not self.m3TkLayersWithMeasurement_branch and "m3TkLayersWithMeasurement" not in self.complained:
        if not self.m3TkLayersWithMeasurement_branch and "m3TkLayersWithMeasurement":
            warnings.warn( "MMMTree: Expected branch m3TkLayersWithMeasurement does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3TkLayersWithMeasurement")
        else:
            self.m3TkLayersWithMeasurement_branch.SetAddress(<void*>&self.m3TkLayersWithMeasurement_value)

        #print "making m3TrkIsoDR03"
        self.m3TrkIsoDR03_branch = the_tree.GetBranch("m3TrkIsoDR03")
        #if not self.m3TrkIsoDR03_branch and "m3TrkIsoDR03" not in self.complained:
        if not self.m3TrkIsoDR03_branch and "m3TrkIsoDR03":
            warnings.warn( "MMMTree: Expected branch m3TrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3TrkIsoDR03")
        else:
            self.m3TrkIsoDR03_branch.SetAddress(<void*>&self.m3TrkIsoDR03_value)

        #print "making m3TypeCode"
        self.m3TypeCode_branch = the_tree.GetBranch("m3TypeCode")
        #if not self.m3TypeCode_branch and "m3TypeCode" not in self.complained:
        if not self.m3TypeCode_branch and "m3TypeCode":
            warnings.warn( "MMMTree: Expected branch m3TypeCode does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3TypeCode")
        else:
            self.m3TypeCode_branch.SetAddress(<void*>&self.m3TypeCode_value)

        #print "making m3VZ"
        self.m3VZ_branch = the_tree.GetBranch("m3VZ")
        #if not self.m3VZ_branch and "m3VZ" not in self.complained:
        if not self.m3VZ_branch and "m3VZ":
            warnings.warn( "MMMTree: Expected branch m3VZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3VZ")
        else:
            self.m3VZ_branch.SetAddress(<void*>&self.m3VZ_value)

        #print "making m3_m1_collinearmass"
        self.m3_m1_collinearmass_branch = the_tree.GetBranch("m3_m1_collinearmass")
        #if not self.m3_m1_collinearmass_branch and "m3_m1_collinearmass" not in self.complained:
        if not self.m3_m1_collinearmass_branch and "m3_m1_collinearmass":
            warnings.warn( "MMMTree: Expected branch m3_m1_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m1_collinearmass")
        else:
            self.m3_m1_collinearmass_branch.SetAddress(<void*>&self.m3_m1_collinearmass_value)

        #print "making m3_m1_collinearmass_JetEnDown"
        self.m3_m1_collinearmass_JetEnDown_branch = the_tree.GetBranch("m3_m1_collinearmass_JetEnDown")
        #if not self.m3_m1_collinearmass_JetEnDown_branch and "m3_m1_collinearmass_JetEnDown" not in self.complained:
        if not self.m3_m1_collinearmass_JetEnDown_branch and "m3_m1_collinearmass_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m3_m1_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m1_collinearmass_JetEnDown")
        else:
            self.m3_m1_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.m3_m1_collinearmass_JetEnDown_value)

        #print "making m3_m1_collinearmass_JetEnUp"
        self.m3_m1_collinearmass_JetEnUp_branch = the_tree.GetBranch("m3_m1_collinearmass_JetEnUp")
        #if not self.m3_m1_collinearmass_JetEnUp_branch and "m3_m1_collinearmass_JetEnUp" not in self.complained:
        if not self.m3_m1_collinearmass_JetEnUp_branch and "m3_m1_collinearmass_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m3_m1_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m1_collinearmass_JetEnUp")
        else:
            self.m3_m1_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.m3_m1_collinearmass_JetEnUp_value)

        #print "making m3_m1_collinearmass_UnclusteredEnDown"
        self.m3_m1_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("m3_m1_collinearmass_UnclusteredEnDown")
        #if not self.m3_m1_collinearmass_UnclusteredEnDown_branch and "m3_m1_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.m3_m1_collinearmass_UnclusteredEnDown_branch and "m3_m1_collinearmass_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m3_m1_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m1_collinearmass_UnclusteredEnDown")
        else:
            self.m3_m1_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.m3_m1_collinearmass_UnclusteredEnDown_value)

        #print "making m3_m1_collinearmass_UnclusteredEnUp"
        self.m3_m1_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("m3_m1_collinearmass_UnclusteredEnUp")
        #if not self.m3_m1_collinearmass_UnclusteredEnUp_branch and "m3_m1_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.m3_m1_collinearmass_UnclusteredEnUp_branch and "m3_m1_collinearmass_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m3_m1_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m1_collinearmass_UnclusteredEnUp")
        else:
            self.m3_m1_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.m3_m1_collinearmass_UnclusteredEnUp_value)

        #print "making m3_m2_collinearmass"
        self.m3_m2_collinearmass_branch = the_tree.GetBranch("m3_m2_collinearmass")
        #if not self.m3_m2_collinearmass_branch and "m3_m2_collinearmass" not in self.complained:
        if not self.m3_m2_collinearmass_branch and "m3_m2_collinearmass":
            warnings.warn( "MMMTree: Expected branch m3_m2_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m2_collinearmass")
        else:
            self.m3_m2_collinearmass_branch.SetAddress(<void*>&self.m3_m2_collinearmass_value)

        #print "making m3_m2_collinearmass_JetEnDown"
        self.m3_m2_collinearmass_JetEnDown_branch = the_tree.GetBranch("m3_m2_collinearmass_JetEnDown")
        #if not self.m3_m2_collinearmass_JetEnDown_branch and "m3_m2_collinearmass_JetEnDown" not in self.complained:
        if not self.m3_m2_collinearmass_JetEnDown_branch and "m3_m2_collinearmass_JetEnDown":
            warnings.warn( "MMMTree: Expected branch m3_m2_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m2_collinearmass_JetEnDown")
        else:
            self.m3_m2_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.m3_m2_collinearmass_JetEnDown_value)

        #print "making m3_m2_collinearmass_JetEnUp"
        self.m3_m2_collinearmass_JetEnUp_branch = the_tree.GetBranch("m3_m2_collinearmass_JetEnUp")
        #if not self.m3_m2_collinearmass_JetEnUp_branch and "m3_m2_collinearmass_JetEnUp" not in self.complained:
        if not self.m3_m2_collinearmass_JetEnUp_branch and "m3_m2_collinearmass_JetEnUp":
            warnings.warn( "MMMTree: Expected branch m3_m2_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m2_collinearmass_JetEnUp")
        else:
            self.m3_m2_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.m3_m2_collinearmass_JetEnUp_value)

        #print "making m3_m2_collinearmass_UnclusteredEnDown"
        self.m3_m2_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("m3_m2_collinearmass_UnclusteredEnDown")
        #if not self.m3_m2_collinearmass_UnclusteredEnDown_branch and "m3_m2_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.m3_m2_collinearmass_UnclusteredEnDown_branch and "m3_m2_collinearmass_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch m3_m2_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m2_collinearmass_UnclusteredEnDown")
        else:
            self.m3_m2_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.m3_m2_collinearmass_UnclusteredEnDown_value)

        #print "making m3_m2_collinearmass_UnclusteredEnUp"
        self.m3_m2_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("m3_m2_collinearmass_UnclusteredEnUp")
        #if not self.m3_m2_collinearmass_UnclusteredEnUp_branch and "m3_m2_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.m3_m2_collinearmass_UnclusteredEnUp_branch and "m3_m2_collinearmass_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch m3_m2_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m3_m2_collinearmass_UnclusteredEnUp")
        else:
            self.m3_m2_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.m3_m2_collinearmass_UnclusteredEnUp_value)

        #print "making muGlbIsoVetoPt10"
        self.muGlbIsoVetoPt10_branch = the_tree.GetBranch("muGlbIsoVetoPt10")
        #if not self.muGlbIsoVetoPt10_branch and "muGlbIsoVetoPt10" not in self.complained:
        if not self.muGlbIsoVetoPt10_branch and "muGlbIsoVetoPt10":
            warnings.warn( "MMMTree: Expected branch muGlbIsoVetoPt10 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muGlbIsoVetoPt10")
        else:
            self.muGlbIsoVetoPt10_branch.SetAddress(<void*>&self.muGlbIsoVetoPt10_value)

        #print "making muVetoPt15IsoIdVtx"
        self.muVetoPt15IsoIdVtx_branch = the_tree.GetBranch("muVetoPt15IsoIdVtx")
        #if not self.muVetoPt15IsoIdVtx_branch and "muVetoPt15IsoIdVtx" not in self.complained:
        if not self.muVetoPt15IsoIdVtx_branch and "muVetoPt15IsoIdVtx":
            warnings.warn( "MMMTree: Expected branch muVetoPt15IsoIdVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt15IsoIdVtx")
        else:
            self.muVetoPt15IsoIdVtx_branch.SetAddress(<void*>&self.muVetoPt15IsoIdVtx_value)

        #print "making muVetoPt5"
        self.muVetoPt5_branch = the_tree.GetBranch("muVetoPt5")
        #if not self.muVetoPt5_branch and "muVetoPt5" not in self.complained:
        if not self.muVetoPt5_branch and "muVetoPt5":
            warnings.warn( "MMMTree: Expected branch muVetoPt5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt5")
        else:
            self.muVetoPt5_branch.SetAddress(<void*>&self.muVetoPt5_value)

        #print "making muVetoPt5IsoIdVtx"
        self.muVetoPt5IsoIdVtx_branch = the_tree.GetBranch("muVetoPt5IsoIdVtx")
        #if not self.muVetoPt5IsoIdVtx_branch and "muVetoPt5IsoIdVtx" not in self.complained:
        if not self.muVetoPt5IsoIdVtx_branch and "muVetoPt5IsoIdVtx":
            warnings.warn( "MMMTree: Expected branch muVetoPt5IsoIdVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt5IsoIdVtx")
        else:
            self.muVetoPt5IsoIdVtx_branch.SetAddress(<void*>&self.muVetoPt5IsoIdVtx_value)

        #print "making nTruePU"
        self.nTruePU_branch = the_tree.GetBranch("nTruePU")
        #if not self.nTruePU_branch and "nTruePU" not in self.complained:
        if not self.nTruePU_branch and "nTruePU":
            warnings.warn( "MMMTree: Expected branch nTruePU does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("nTruePU")
        else:
            self.nTruePU_branch.SetAddress(<void*>&self.nTruePU_value)

        #print "making nvtx"
        self.nvtx_branch = the_tree.GetBranch("nvtx")
        #if not self.nvtx_branch and "nvtx" not in self.complained:
        if not self.nvtx_branch and "nvtx":
            warnings.warn( "MMMTree: Expected branch nvtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("nvtx")
        else:
            self.nvtx_branch.SetAddress(<void*>&self.nvtx_value)

        #print "making processID"
        self.processID_branch = the_tree.GetBranch("processID")
        #if not self.processID_branch and "processID" not in self.complained:
        if not self.processID_branch and "processID":
            warnings.warn( "MMMTree: Expected branch processID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("processID")
        else:
            self.processID_branch.SetAddress(<void*>&self.processID_value)

        #print "making pvChi2"
        self.pvChi2_branch = the_tree.GetBranch("pvChi2")
        #if not self.pvChi2_branch and "pvChi2" not in self.complained:
        if not self.pvChi2_branch and "pvChi2":
            warnings.warn( "MMMTree: Expected branch pvChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvChi2")
        else:
            self.pvChi2_branch.SetAddress(<void*>&self.pvChi2_value)

        #print "making pvDX"
        self.pvDX_branch = the_tree.GetBranch("pvDX")
        #if not self.pvDX_branch and "pvDX" not in self.complained:
        if not self.pvDX_branch and "pvDX":
            warnings.warn( "MMMTree: Expected branch pvDX does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDX")
        else:
            self.pvDX_branch.SetAddress(<void*>&self.pvDX_value)

        #print "making pvDY"
        self.pvDY_branch = the_tree.GetBranch("pvDY")
        #if not self.pvDY_branch and "pvDY" not in self.complained:
        if not self.pvDY_branch and "pvDY":
            warnings.warn( "MMMTree: Expected branch pvDY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDY")
        else:
            self.pvDY_branch.SetAddress(<void*>&self.pvDY_value)

        #print "making pvDZ"
        self.pvDZ_branch = the_tree.GetBranch("pvDZ")
        #if not self.pvDZ_branch and "pvDZ" not in self.complained:
        if not self.pvDZ_branch and "pvDZ":
            warnings.warn( "MMMTree: Expected branch pvDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDZ")
        else:
            self.pvDZ_branch.SetAddress(<void*>&self.pvDZ_value)

        #print "making pvIsFake"
        self.pvIsFake_branch = the_tree.GetBranch("pvIsFake")
        #if not self.pvIsFake_branch and "pvIsFake" not in self.complained:
        if not self.pvIsFake_branch and "pvIsFake":
            warnings.warn( "MMMTree: Expected branch pvIsFake does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvIsFake")
        else:
            self.pvIsFake_branch.SetAddress(<void*>&self.pvIsFake_value)

        #print "making pvIsValid"
        self.pvIsValid_branch = the_tree.GetBranch("pvIsValid")
        #if not self.pvIsValid_branch and "pvIsValid" not in self.complained:
        if not self.pvIsValid_branch and "pvIsValid":
            warnings.warn( "MMMTree: Expected branch pvIsValid does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvIsValid")
        else:
            self.pvIsValid_branch.SetAddress(<void*>&self.pvIsValid_value)

        #print "making pvNormChi2"
        self.pvNormChi2_branch = the_tree.GetBranch("pvNormChi2")
        #if not self.pvNormChi2_branch and "pvNormChi2" not in self.complained:
        if not self.pvNormChi2_branch and "pvNormChi2":
            warnings.warn( "MMMTree: Expected branch pvNormChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvNormChi2")
        else:
            self.pvNormChi2_branch.SetAddress(<void*>&self.pvNormChi2_value)

        #print "making pvRho"
        self.pvRho_branch = the_tree.GetBranch("pvRho")
        #if not self.pvRho_branch and "pvRho" not in self.complained:
        if not self.pvRho_branch and "pvRho":
            warnings.warn( "MMMTree: Expected branch pvRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvRho")
        else:
            self.pvRho_branch.SetAddress(<void*>&self.pvRho_value)

        #print "making pvX"
        self.pvX_branch = the_tree.GetBranch("pvX")
        #if not self.pvX_branch and "pvX" not in self.complained:
        if not self.pvX_branch and "pvX":
            warnings.warn( "MMMTree: Expected branch pvX does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvX")
        else:
            self.pvX_branch.SetAddress(<void*>&self.pvX_value)

        #print "making pvY"
        self.pvY_branch = the_tree.GetBranch("pvY")
        #if not self.pvY_branch and "pvY" not in self.complained:
        if not self.pvY_branch and "pvY":
            warnings.warn( "MMMTree: Expected branch pvY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvY")
        else:
            self.pvY_branch.SetAddress(<void*>&self.pvY_value)

        #print "making pvZ"
        self.pvZ_branch = the_tree.GetBranch("pvZ")
        #if not self.pvZ_branch and "pvZ" not in self.complained:
        if not self.pvZ_branch and "pvZ":
            warnings.warn( "MMMTree: Expected branch pvZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvZ")
        else:
            self.pvZ_branch.SetAddress(<void*>&self.pvZ_value)

        #print "making pvndof"
        self.pvndof_branch = the_tree.GetBranch("pvndof")
        #if not self.pvndof_branch and "pvndof" not in self.complained:
        if not self.pvndof_branch and "pvndof":
            warnings.warn( "MMMTree: Expected branch pvndof does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvndof")
        else:
            self.pvndof_branch.SetAddress(<void*>&self.pvndof_value)

        #print "making raw_pfMetEt"
        self.raw_pfMetEt_branch = the_tree.GetBranch("raw_pfMetEt")
        #if not self.raw_pfMetEt_branch and "raw_pfMetEt" not in self.complained:
        if not self.raw_pfMetEt_branch and "raw_pfMetEt":
            warnings.warn( "MMMTree: Expected branch raw_pfMetEt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("raw_pfMetEt")
        else:
            self.raw_pfMetEt_branch.SetAddress(<void*>&self.raw_pfMetEt_value)

        #print "making raw_pfMetPhi"
        self.raw_pfMetPhi_branch = the_tree.GetBranch("raw_pfMetPhi")
        #if not self.raw_pfMetPhi_branch and "raw_pfMetPhi" not in self.complained:
        if not self.raw_pfMetPhi_branch and "raw_pfMetPhi":
            warnings.warn( "MMMTree: Expected branch raw_pfMetPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("raw_pfMetPhi")
        else:
            self.raw_pfMetPhi_branch.SetAddress(<void*>&self.raw_pfMetPhi_value)

        #print "making recoilDaught"
        self.recoilDaught_branch = the_tree.GetBranch("recoilDaught")
        #if not self.recoilDaught_branch and "recoilDaught" not in self.complained:
        if not self.recoilDaught_branch and "recoilDaught":
            warnings.warn( "MMMTree: Expected branch recoilDaught does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("recoilDaught")
        else:
            self.recoilDaught_branch.SetAddress(<void*>&self.recoilDaught_value)

        #print "making recoilWithMet"
        self.recoilWithMet_branch = the_tree.GetBranch("recoilWithMet")
        #if not self.recoilWithMet_branch and "recoilWithMet" not in self.complained:
        if not self.recoilWithMet_branch and "recoilWithMet":
            warnings.warn( "MMMTree: Expected branch recoilWithMet does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("recoilWithMet")
        else:
            self.recoilWithMet_branch.SetAddress(<void*>&self.recoilWithMet_value)

        #print "making rho"
        self.rho_branch = the_tree.GetBranch("rho")
        #if not self.rho_branch and "rho" not in self.complained:
        if not self.rho_branch and "rho":
            warnings.warn( "MMMTree: Expected branch rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("rho")
        else:
            self.rho_branch.SetAddress(<void*>&self.rho_value)

        #print "making run"
        self.run_branch = the_tree.GetBranch("run")
        #if not self.run_branch and "run" not in self.complained:
        if not self.run_branch and "run":
            warnings.warn( "MMMTree: Expected branch run does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("run")
        else:
            self.run_branch.SetAddress(<void*>&self.run_value)

        #print "making singleE17SingleMu8Group"
        self.singleE17SingleMu8Group_branch = the_tree.GetBranch("singleE17SingleMu8Group")
        #if not self.singleE17SingleMu8Group_branch and "singleE17SingleMu8Group" not in self.complained:
        if not self.singleE17SingleMu8Group_branch and "singleE17SingleMu8Group":
            warnings.warn( "MMMTree: Expected branch singleE17SingleMu8Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Group")
        else:
            self.singleE17SingleMu8Group_branch.SetAddress(<void*>&self.singleE17SingleMu8Group_value)

        #print "making singleE17SingleMu8Pass"
        self.singleE17SingleMu8Pass_branch = the_tree.GetBranch("singleE17SingleMu8Pass")
        #if not self.singleE17SingleMu8Pass_branch and "singleE17SingleMu8Pass" not in self.complained:
        if not self.singleE17SingleMu8Pass_branch and "singleE17SingleMu8Pass":
            warnings.warn( "MMMTree: Expected branch singleE17SingleMu8Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Pass")
        else:
            self.singleE17SingleMu8Pass_branch.SetAddress(<void*>&self.singleE17SingleMu8Pass_value)

        #print "making singleE17SingleMu8Prescale"
        self.singleE17SingleMu8Prescale_branch = the_tree.GetBranch("singleE17SingleMu8Prescale")
        #if not self.singleE17SingleMu8Prescale_branch and "singleE17SingleMu8Prescale" not in self.complained:
        if not self.singleE17SingleMu8Prescale_branch and "singleE17SingleMu8Prescale":
            warnings.warn( "MMMTree: Expected branch singleE17SingleMu8Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Prescale")
        else:
            self.singleE17SingleMu8Prescale_branch.SetAddress(<void*>&self.singleE17SingleMu8Prescale_value)

        #print "making singleE22WP75Group"
        self.singleE22WP75Group_branch = the_tree.GetBranch("singleE22WP75Group")
        #if not self.singleE22WP75Group_branch and "singleE22WP75Group" not in self.complained:
        if not self.singleE22WP75Group_branch and "singleE22WP75Group":
            warnings.warn( "MMMTree: Expected branch singleE22WP75Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Group")
        else:
            self.singleE22WP75Group_branch.SetAddress(<void*>&self.singleE22WP75Group_value)

        #print "making singleE22WP75Pass"
        self.singleE22WP75Pass_branch = the_tree.GetBranch("singleE22WP75Pass")
        #if not self.singleE22WP75Pass_branch and "singleE22WP75Pass" not in self.complained:
        if not self.singleE22WP75Pass_branch and "singleE22WP75Pass":
            warnings.warn( "MMMTree: Expected branch singleE22WP75Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Pass")
        else:
            self.singleE22WP75Pass_branch.SetAddress(<void*>&self.singleE22WP75Pass_value)

        #print "making singleE22WP75Prescale"
        self.singleE22WP75Prescale_branch = the_tree.GetBranch("singleE22WP75Prescale")
        #if not self.singleE22WP75Prescale_branch and "singleE22WP75Prescale" not in self.complained:
        if not self.singleE22WP75Prescale_branch and "singleE22WP75Prescale":
            warnings.warn( "MMMTree: Expected branch singleE22WP75Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Prescale")
        else:
            self.singleE22WP75Prescale_branch.SetAddress(<void*>&self.singleE22WP75Prescale_value)

        #print "making singleE22eta2p1LooseGroup"
        self.singleE22eta2p1LooseGroup_branch = the_tree.GetBranch("singleE22eta2p1LooseGroup")
        #if not self.singleE22eta2p1LooseGroup_branch and "singleE22eta2p1LooseGroup" not in self.complained:
        if not self.singleE22eta2p1LooseGroup_branch and "singleE22eta2p1LooseGroup":
            warnings.warn( "MMMTree: Expected branch singleE22eta2p1LooseGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LooseGroup")
        else:
            self.singleE22eta2p1LooseGroup_branch.SetAddress(<void*>&self.singleE22eta2p1LooseGroup_value)

        #print "making singleE22eta2p1LoosePass"
        self.singleE22eta2p1LoosePass_branch = the_tree.GetBranch("singleE22eta2p1LoosePass")
        #if not self.singleE22eta2p1LoosePass_branch and "singleE22eta2p1LoosePass" not in self.complained:
        if not self.singleE22eta2p1LoosePass_branch and "singleE22eta2p1LoosePass":
            warnings.warn( "MMMTree: Expected branch singleE22eta2p1LoosePass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LoosePass")
        else:
            self.singleE22eta2p1LoosePass_branch.SetAddress(<void*>&self.singleE22eta2p1LoosePass_value)

        #print "making singleE22eta2p1LoosePrescale"
        self.singleE22eta2p1LoosePrescale_branch = the_tree.GetBranch("singleE22eta2p1LoosePrescale")
        #if not self.singleE22eta2p1LoosePrescale_branch and "singleE22eta2p1LoosePrescale" not in self.complained:
        if not self.singleE22eta2p1LoosePrescale_branch and "singleE22eta2p1LoosePrescale":
            warnings.warn( "MMMTree: Expected branch singleE22eta2p1LoosePrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LoosePrescale")
        else:
            self.singleE22eta2p1LoosePrescale_branch.SetAddress(<void*>&self.singleE22eta2p1LoosePrescale_value)

        #print "making singleE23SingleMu8Group"
        self.singleE23SingleMu8Group_branch = the_tree.GetBranch("singleE23SingleMu8Group")
        #if not self.singleE23SingleMu8Group_branch and "singleE23SingleMu8Group" not in self.complained:
        if not self.singleE23SingleMu8Group_branch and "singleE23SingleMu8Group":
            warnings.warn( "MMMTree: Expected branch singleE23SingleMu8Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Group")
        else:
            self.singleE23SingleMu8Group_branch.SetAddress(<void*>&self.singleE23SingleMu8Group_value)

        #print "making singleE23SingleMu8Pass"
        self.singleE23SingleMu8Pass_branch = the_tree.GetBranch("singleE23SingleMu8Pass")
        #if not self.singleE23SingleMu8Pass_branch and "singleE23SingleMu8Pass" not in self.complained:
        if not self.singleE23SingleMu8Pass_branch and "singleE23SingleMu8Pass":
            warnings.warn( "MMMTree: Expected branch singleE23SingleMu8Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Pass")
        else:
            self.singleE23SingleMu8Pass_branch.SetAddress(<void*>&self.singleE23SingleMu8Pass_value)

        #print "making singleE23SingleMu8Prescale"
        self.singleE23SingleMu8Prescale_branch = the_tree.GetBranch("singleE23SingleMu8Prescale")
        #if not self.singleE23SingleMu8Prescale_branch and "singleE23SingleMu8Prescale" not in self.complained:
        if not self.singleE23SingleMu8Prescale_branch and "singleE23SingleMu8Prescale":
            warnings.warn( "MMMTree: Expected branch singleE23SingleMu8Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Prescale")
        else:
            self.singleE23SingleMu8Prescale_branch.SetAddress(<void*>&self.singleE23SingleMu8Prescale_value)

        #print "making singleE23WP75Group"
        self.singleE23WP75Group_branch = the_tree.GetBranch("singleE23WP75Group")
        #if not self.singleE23WP75Group_branch and "singleE23WP75Group" not in self.complained:
        if not self.singleE23WP75Group_branch and "singleE23WP75Group":
            warnings.warn( "MMMTree: Expected branch singleE23WP75Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Group")
        else:
            self.singleE23WP75Group_branch.SetAddress(<void*>&self.singleE23WP75Group_value)

        #print "making singleE23WP75Pass"
        self.singleE23WP75Pass_branch = the_tree.GetBranch("singleE23WP75Pass")
        #if not self.singleE23WP75Pass_branch and "singleE23WP75Pass" not in self.complained:
        if not self.singleE23WP75Pass_branch and "singleE23WP75Pass":
            warnings.warn( "MMMTree: Expected branch singleE23WP75Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Pass")
        else:
            self.singleE23WP75Pass_branch.SetAddress(<void*>&self.singleE23WP75Pass_value)

        #print "making singleE23WP75Prescale"
        self.singleE23WP75Prescale_branch = the_tree.GetBranch("singleE23WP75Prescale")
        #if not self.singleE23WP75Prescale_branch and "singleE23WP75Prescale" not in self.complained:
        if not self.singleE23WP75Prescale_branch and "singleE23WP75Prescale":
            warnings.warn( "MMMTree: Expected branch singleE23WP75Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Prescale")
        else:
            self.singleE23WP75Prescale_branch.SetAddress(<void*>&self.singleE23WP75Prescale_value)

        #print "making singleEGroup"
        self.singleEGroup_branch = the_tree.GetBranch("singleEGroup")
        #if not self.singleEGroup_branch and "singleEGroup" not in self.complained:
        if not self.singleEGroup_branch and "singleEGroup":
            warnings.warn( "MMMTree: Expected branch singleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEGroup")
        else:
            self.singleEGroup_branch.SetAddress(<void*>&self.singleEGroup_value)

        #print "making singleEPass"
        self.singleEPass_branch = the_tree.GetBranch("singleEPass")
        #if not self.singleEPass_branch and "singleEPass" not in self.complained:
        if not self.singleEPass_branch and "singleEPass":
            warnings.warn( "MMMTree: Expected branch singleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEPass")
        else:
            self.singleEPass_branch.SetAddress(<void*>&self.singleEPass_value)

        #print "making singleEPrescale"
        self.singleEPrescale_branch = the_tree.GetBranch("singleEPrescale")
        #if not self.singleEPrescale_branch and "singleEPrescale" not in self.complained:
        if not self.singleEPrescale_branch and "singleEPrescale":
            warnings.warn( "MMMTree: Expected branch singleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEPrescale")
        else:
            self.singleEPrescale_branch.SetAddress(<void*>&self.singleEPrescale_value)

        #print "making singleESingleMuGroup"
        self.singleESingleMuGroup_branch = the_tree.GetBranch("singleESingleMuGroup")
        #if not self.singleESingleMuGroup_branch and "singleESingleMuGroup" not in self.complained:
        if not self.singleESingleMuGroup_branch and "singleESingleMuGroup":
            warnings.warn( "MMMTree: Expected branch singleESingleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuGroup")
        else:
            self.singleESingleMuGroup_branch.SetAddress(<void*>&self.singleESingleMuGroup_value)

        #print "making singleESingleMuPass"
        self.singleESingleMuPass_branch = the_tree.GetBranch("singleESingleMuPass")
        #if not self.singleESingleMuPass_branch and "singleESingleMuPass" not in self.complained:
        if not self.singleESingleMuPass_branch and "singleESingleMuPass":
            warnings.warn( "MMMTree: Expected branch singleESingleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuPass")
        else:
            self.singleESingleMuPass_branch.SetAddress(<void*>&self.singleESingleMuPass_value)

        #print "making singleESingleMuPrescale"
        self.singleESingleMuPrescale_branch = the_tree.GetBranch("singleESingleMuPrescale")
        #if not self.singleESingleMuPrescale_branch and "singleESingleMuPrescale" not in self.complained:
        if not self.singleESingleMuPrescale_branch and "singleESingleMuPrescale":
            warnings.warn( "MMMTree: Expected branch singleESingleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuPrescale")
        else:
            self.singleESingleMuPrescale_branch.SetAddress(<void*>&self.singleESingleMuPrescale_value)

        #print "making singleE_leg1Group"
        self.singleE_leg1Group_branch = the_tree.GetBranch("singleE_leg1Group")
        #if not self.singleE_leg1Group_branch and "singleE_leg1Group" not in self.complained:
        if not self.singleE_leg1Group_branch and "singleE_leg1Group":
            warnings.warn( "MMMTree: Expected branch singleE_leg1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Group")
        else:
            self.singleE_leg1Group_branch.SetAddress(<void*>&self.singleE_leg1Group_value)

        #print "making singleE_leg1Pass"
        self.singleE_leg1Pass_branch = the_tree.GetBranch("singleE_leg1Pass")
        #if not self.singleE_leg1Pass_branch and "singleE_leg1Pass" not in self.complained:
        if not self.singleE_leg1Pass_branch and "singleE_leg1Pass":
            warnings.warn( "MMMTree: Expected branch singleE_leg1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Pass")
        else:
            self.singleE_leg1Pass_branch.SetAddress(<void*>&self.singleE_leg1Pass_value)

        #print "making singleE_leg1Prescale"
        self.singleE_leg1Prescale_branch = the_tree.GetBranch("singleE_leg1Prescale")
        #if not self.singleE_leg1Prescale_branch and "singleE_leg1Prescale" not in self.complained:
        if not self.singleE_leg1Prescale_branch and "singleE_leg1Prescale":
            warnings.warn( "MMMTree: Expected branch singleE_leg1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Prescale")
        else:
            self.singleE_leg1Prescale_branch.SetAddress(<void*>&self.singleE_leg1Prescale_value)

        #print "making singleE_leg2Group"
        self.singleE_leg2Group_branch = the_tree.GetBranch("singleE_leg2Group")
        #if not self.singleE_leg2Group_branch and "singleE_leg2Group" not in self.complained:
        if not self.singleE_leg2Group_branch and "singleE_leg2Group":
            warnings.warn( "MMMTree: Expected branch singleE_leg2Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Group")
        else:
            self.singleE_leg2Group_branch.SetAddress(<void*>&self.singleE_leg2Group_value)

        #print "making singleE_leg2Pass"
        self.singleE_leg2Pass_branch = the_tree.GetBranch("singleE_leg2Pass")
        #if not self.singleE_leg2Pass_branch and "singleE_leg2Pass" not in self.complained:
        if not self.singleE_leg2Pass_branch and "singleE_leg2Pass":
            warnings.warn( "MMMTree: Expected branch singleE_leg2Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Pass")
        else:
            self.singleE_leg2Pass_branch.SetAddress(<void*>&self.singleE_leg2Pass_value)

        #print "making singleE_leg2Prescale"
        self.singleE_leg2Prescale_branch = the_tree.GetBranch("singleE_leg2Prescale")
        #if not self.singleE_leg2Prescale_branch and "singleE_leg2Prescale" not in self.complained:
        if not self.singleE_leg2Prescale_branch and "singleE_leg2Prescale":
            warnings.warn( "MMMTree: Expected branch singleE_leg2Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Prescale")
        else:
            self.singleE_leg2Prescale_branch.SetAddress(<void*>&self.singleE_leg2Prescale_value)

        #print "making singleIsoMu17eta2p1Group"
        self.singleIsoMu17eta2p1Group_branch = the_tree.GetBranch("singleIsoMu17eta2p1Group")
        #if not self.singleIsoMu17eta2p1Group_branch and "singleIsoMu17eta2p1Group" not in self.complained:
        if not self.singleIsoMu17eta2p1Group_branch and "singleIsoMu17eta2p1Group":
            warnings.warn( "MMMTree: Expected branch singleIsoMu17eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Group")
        else:
            self.singleIsoMu17eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Group_value)

        #print "making singleIsoMu17eta2p1Pass"
        self.singleIsoMu17eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu17eta2p1Pass")
        #if not self.singleIsoMu17eta2p1Pass_branch and "singleIsoMu17eta2p1Pass" not in self.complained:
        if not self.singleIsoMu17eta2p1Pass_branch and "singleIsoMu17eta2p1Pass":
            warnings.warn( "MMMTree: Expected branch singleIsoMu17eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Pass")
        else:
            self.singleIsoMu17eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Pass_value)

        #print "making singleIsoMu17eta2p1Prescale"
        self.singleIsoMu17eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu17eta2p1Prescale")
        #if not self.singleIsoMu17eta2p1Prescale_branch and "singleIsoMu17eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu17eta2p1Prescale_branch and "singleIsoMu17eta2p1Prescale":
            warnings.warn( "MMMTree: Expected branch singleIsoMu17eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Prescale")
        else:
            self.singleIsoMu17eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Prescale_value)

        #print "making singleIsoMu20Group"
        self.singleIsoMu20Group_branch = the_tree.GetBranch("singleIsoMu20Group")
        #if not self.singleIsoMu20Group_branch and "singleIsoMu20Group" not in self.complained:
        if not self.singleIsoMu20Group_branch and "singleIsoMu20Group":
            warnings.warn( "MMMTree: Expected branch singleIsoMu20Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Group")
        else:
            self.singleIsoMu20Group_branch.SetAddress(<void*>&self.singleIsoMu20Group_value)

        #print "making singleIsoMu20Pass"
        self.singleIsoMu20Pass_branch = the_tree.GetBranch("singleIsoMu20Pass")
        #if not self.singleIsoMu20Pass_branch and "singleIsoMu20Pass" not in self.complained:
        if not self.singleIsoMu20Pass_branch and "singleIsoMu20Pass":
            warnings.warn( "MMMTree: Expected branch singleIsoMu20Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Pass")
        else:
            self.singleIsoMu20Pass_branch.SetAddress(<void*>&self.singleIsoMu20Pass_value)

        #print "making singleIsoMu20Prescale"
        self.singleIsoMu20Prescale_branch = the_tree.GetBranch("singleIsoMu20Prescale")
        #if not self.singleIsoMu20Prescale_branch and "singleIsoMu20Prescale" not in self.complained:
        if not self.singleIsoMu20Prescale_branch and "singleIsoMu20Prescale":
            warnings.warn( "MMMTree: Expected branch singleIsoMu20Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Prescale")
        else:
            self.singleIsoMu20Prescale_branch.SetAddress(<void*>&self.singleIsoMu20Prescale_value)

        #print "making singleIsoMu20eta2p1Group"
        self.singleIsoMu20eta2p1Group_branch = the_tree.GetBranch("singleIsoMu20eta2p1Group")
        #if not self.singleIsoMu20eta2p1Group_branch and "singleIsoMu20eta2p1Group" not in self.complained:
        if not self.singleIsoMu20eta2p1Group_branch and "singleIsoMu20eta2p1Group":
            warnings.warn( "MMMTree: Expected branch singleIsoMu20eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Group")
        else:
            self.singleIsoMu20eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Group_value)

        #print "making singleIsoMu20eta2p1Pass"
        self.singleIsoMu20eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu20eta2p1Pass")
        #if not self.singleIsoMu20eta2p1Pass_branch and "singleIsoMu20eta2p1Pass" not in self.complained:
        if not self.singleIsoMu20eta2p1Pass_branch and "singleIsoMu20eta2p1Pass":
            warnings.warn( "MMMTree: Expected branch singleIsoMu20eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Pass")
        else:
            self.singleIsoMu20eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Pass_value)

        #print "making singleIsoMu20eta2p1Prescale"
        self.singleIsoMu20eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu20eta2p1Prescale")
        #if not self.singleIsoMu20eta2p1Prescale_branch and "singleIsoMu20eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu20eta2p1Prescale_branch and "singleIsoMu20eta2p1Prescale":
            warnings.warn( "MMMTree: Expected branch singleIsoMu20eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Prescale")
        else:
            self.singleIsoMu20eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Prescale_value)

        #print "making singleIsoMu24Group"
        self.singleIsoMu24Group_branch = the_tree.GetBranch("singleIsoMu24Group")
        #if not self.singleIsoMu24Group_branch and "singleIsoMu24Group" not in self.complained:
        if not self.singleIsoMu24Group_branch and "singleIsoMu24Group":
            warnings.warn( "MMMTree: Expected branch singleIsoMu24Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Group")
        else:
            self.singleIsoMu24Group_branch.SetAddress(<void*>&self.singleIsoMu24Group_value)

        #print "making singleIsoMu24Pass"
        self.singleIsoMu24Pass_branch = the_tree.GetBranch("singleIsoMu24Pass")
        #if not self.singleIsoMu24Pass_branch and "singleIsoMu24Pass" not in self.complained:
        if not self.singleIsoMu24Pass_branch and "singleIsoMu24Pass":
            warnings.warn( "MMMTree: Expected branch singleIsoMu24Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Pass")
        else:
            self.singleIsoMu24Pass_branch.SetAddress(<void*>&self.singleIsoMu24Pass_value)

        #print "making singleIsoMu24Prescale"
        self.singleIsoMu24Prescale_branch = the_tree.GetBranch("singleIsoMu24Prescale")
        #if not self.singleIsoMu24Prescale_branch and "singleIsoMu24Prescale" not in self.complained:
        if not self.singleIsoMu24Prescale_branch and "singleIsoMu24Prescale":
            warnings.warn( "MMMTree: Expected branch singleIsoMu24Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Prescale")
        else:
            self.singleIsoMu24Prescale_branch.SetAddress(<void*>&self.singleIsoMu24Prescale_value)

        #print "making singleIsoMu24eta2p1Group"
        self.singleIsoMu24eta2p1Group_branch = the_tree.GetBranch("singleIsoMu24eta2p1Group")
        #if not self.singleIsoMu24eta2p1Group_branch and "singleIsoMu24eta2p1Group" not in self.complained:
        if not self.singleIsoMu24eta2p1Group_branch and "singleIsoMu24eta2p1Group":
            warnings.warn( "MMMTree: Expected branch singleIsoMu24eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Group")
        else:
            self.singleIsoMu24eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Group_value)

        #print "making singleIsoMu24eta2p1Pass"
        self.singleIsoMu24eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu24eta2p1Pass")
        #if not self.singleIsoMu24eta2p1Pass_branch and "singleIsoMu24eta2p1Pass" not in self.complained:
        if not self.singleIsoMu24eta2p1Pass_branch and "singleIsoMu24eta2p1Pass":
            warnings.warn( "MMMTree: Expected branch singleIsoMu24eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Pass")
        else:
            self.singleIsoMu24eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Pass_value)

        #print "making singleIsoMu24eta2p1Prescale"
        self.singleIsoMu24eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu24eta2p1Prescale")
        #if not self.singleIsoMu24eta2p1Prescale_branch and "singleIsoMu24eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu24eta2p1Prescale_branch and "singleIsoMu24eta2p1Prescale":
            warnings.warn( "MMMTree: Expected branch singleIsoMu24eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Prescale")
        else:
            self.singleIsoMu24eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Prescale_value)

        #print "making singleIsoTkMu20Group"
        self.singleIsoTkMu20Group_branch = the_tree.GetBranch("singleIsoTkMu20Group")
        #if not self.singleIsoTkMu20Group_branch and "singleIsoTkMu20Group" not in self.complained:
        if not self.singleIsoTkMu20Group_branch and "singleIsoTkMu20Group":
            warnings.warn( "MMMTree: Expected branch singleIsoTkMu20Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Group")
        else:
            self.singleIsoTkMu20Group_branch.SetAddress(<void*>&self.singleIsoTkMu20Group_value)

        #print "making singleIsoTkMu20Pass"
        self.singleIsoTkMu20Pass_branch = the_tree.GetBranch("singleIsoTkMu20Pass")
        #if not self.singleIsoTkMu20Pass_branch and "singleIsoTkMu20Pass" not in self.complained:
        if not self.singleIsoTkMu20Pass_branch and "singleIsoTkMu20Pass":
            warnings.warn( "MMMTree: Expected branch singleIsoTkMu20Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Pass")
        else:
            self.singleIsoTkMu20Pass_branch.SetAddress(<void*>&self.singleIsoTkMu20Pass_value)

        #print "making singleIsoTkMu20Prescale"
        self.singleIsoTkMu20Prescale_branch = the_tree.GetBranch("singleIsoTkMu20Prescale")
        #if not self.singleIsoTkMu20Prescale_branch and "singleIsoTkMu20Prescale" not in self.complained:
        if not self.singleIsoTkMu20Prescale_branch and "singleIsoTkMu20Prescale":
            warnings.warn( "MMMTree: Expected branch singleIsoTkMu20Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Prescale")
        else:
            self.singleIsoTkMu20Prescale_branch.SetAddress(<void*>&self.singleIsoTkMu20Prescale_value)

        #print "making singleMu17SingleE12Group"
        self.singleMu17SingleE12Group_branch = the_tree.GetBranch("singleMu17SingleE12Group")
        #if not self.singleMu17SingleE12Group_branch and "singleMu17SingleE12Group" not in self.complained:
        if not self.singleMu17SingleE12Group_branch and "singleMu17SingleE12Group":
            warnings.warn( "MMMTree: Expected branch singleMu17SingleE12Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Group")
        else:
            self.singleMu17SingleE12Group_branch.SetAddress(<void*>&self.singleMu17SingleE12Group_value)

        #print "making singleMu17SingleE12Pass"
        self.singleMu17SingleE12Pass_branch = the_tree.GetBranch("singleMu17SingleE12Pass")
        #if not self.singleMu17SingleE12Pass_branch and "singleMu17SingleE12Pass" not in self.complained:
        if not self.singleMu17SingleE12Pass_branch and "singleMu17SingleE12Pass":
            warnings.warn( "MMMTree: Expected branch singleMu17SingleE12Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Pass")
        else:
            self.singleMu17SingleE12Pass_branch.SetAddress(<void*>&self.singleMu17SingleE12Pass_value)

        #print "making singleMu17SingleE12Prescale"
        self.singleMu17SingleE12Prescale_branch = the_tree.GetBranch("singleMu17SingleE12Prescale")
        #if not self.singleMu17SingleE12Prescale_branch and "singleMu17SingleE12Prescale" not in self.complained:
        if not self.singleMu17SingleE12Prescale_branch and "singleMu17SingleE12Prescale":
            warnings.warn( "MMMTree: Expected branch singleMu17SingleE12Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Prescale")
        else:
            self.singleMu17SingleE12Prescale_branch.SetAddress(<void*>&self.singleMu17SingleE12Prescale_value)

        #print "making singleMu23SingleE12Group"
        self.singleMu23SingleE12Group_branch = the_tree.GetBranch("singleMu23SingleE12Group")
        #if not self.singleMu23SingleE12Group_branch and "singleMu23SingleE12Group" not in self.complained:
        if not self.singleMu23SingleE12Group_branch and "singleMu23SingleE12Group":
            warnings.warn( "MMMTree: Expected branch singleMu23SingleE12Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Group")
        else:
            self.singleMu23SingleE12Group_branch.SetAddress(<void*>&self.singleMu23SingleE12Group_value)

        #print "making singleMu23SingleE12Pass"
        self.singleMu23SingleE12Pass_branch = the_tree.GetBranch("singleMu23SingleE12Pass")
        #if not self.singleMu23SingleE12Pass_branch and "singleMu23SingleE12Pass" not in self.complained:
        if not self.singleMu23SingleE12Pass_branch and "singleMu23SingleE12Pass":
            warnings.warn( "MMMTree: Expected branch singleMu23SingleE12Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Pass")
        else:
            self.singleMu23SingleE12Pass_branch.SetAddress(<void*>&self.singleMu23SingleE12Pass_value)

        #print "making singleMu23SingleE12Prescale"
        self.singleMu23SingleE12Prescale_branch = the_tree.GetBranch("singleMu23SingleE12Prescale")
        #if not self.singleMu23SingleE12Prescale_branch and "singleMu23SingleE12Prescale" not in self.complained:
        if not self.singleMu23SingleE12Prescale_branch and "singleMu23SingleE12Prescale":
            warnings.warn( "MMMTree: Expected branch singleMu23SingleE12Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Prescale")
        else:
            self.singleMu23SingleE12Prescale_branch.SetAddress(<void*>&self.singleMu23SingleE12Prescale_value)

        #print "making singleMuGroup"
        self.singleMuGroup_branch = the_tree.GetBranch("singleMuGroup")
        #if not self.singleMuGroup_branch and "singleMuGroup" not in self.complained:
        if not self.singleMuGroup_branch and "singleMuGroup":
            warnings.warn( "MMMTree: Expected branch singleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuGroup")
        else:
            self.singleMuGroup_branch.SetAddress(<void*>&self.singleMuGroup_value)

        #print "making singleMuPass"
        self.singleMuPass_branch = the_tree.GetBranch("singleMuPass")
        #if not self.singleMuPass_branch and "singleMuPass" not in self.complained:
        if not self.singleMuPass_branch and "singleMuPass":
            warnings.warn( "MMMTree: Expected branch singleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuPass")
        else:
            self.singleMuPass_branch.SetAddress(<void*>&self.singleMuPass_value)

        #print "making singleMuPrescale"
        self.singleMuPrescale_branch = the_tree.GetBranch("singleMuPrescale")
        #if not self.singleMuPrescale_branch and "singleMuPrescale" not in self.complained:
        if not self.singleMuPrescale_branch and "singleMuPrescale":
            warnings.warn( "MMMTree: Expected branch singleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuPrescale")
        else:
            self.singleMuPrescale_branch.SetAddress(<void*>&self.singleMuPrescale_value)

        #print "making singleMuSingleEGroup"
        self.singleMuSingleEGroup_branch = the_tree.GetBranch("singleMuSingleEGroup")
        #if not self.singleMuSingleEGroup_branch and "singleMuSingleEGroup" not in self.complained:
        if not self.singleMuSingleEGroup_branch and "singleMuSingleEGroup":
            warnings.warn( "MMMTree: Expected branch singleMuSingleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEGroup")
        else:
            self.singleMuSingleEGroup_branch.SetAddress(<void*>&self.singleMuSingleEGroup_value)

        #print "making singleMuSingleEPass"
        self.singleMuSingleEPass_branch = the_tree.GetBranch("singleMuSingleEPass")
        #if not self.singleMuSingleEPass_branch and "singleMuSingleEPass" not in self.complained:
        if not self.singleMuSingleEPass_branch and "singleMuSingleEPass":
            warnings.warn( "MMMTree: Expected branch singleMuSingleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEPass")
        else:
            self.singleMuSingleEPass_branch.SetAddress(<void*>&self.singleMuSingleEPass_value)

        #print "making singleMuSingleEPrescale"
        self.singleMuSingleEPrescale_branch = the_tree.GetBranch("singleMuSingleEPrescale")
        #if not self.singleMuSingleEPrescale_branch and "singleMuSingleEPrescale" not in self.complained:
        if not self.singleMuSingleEPrescale_branch and "singleMuSingleEPrescale":
            warnings.warn( "MMMTree: Expected branch singleMuSingleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEPrescale")
        else:
            self.singleMuSingleEPrescale_branch.SetAddress(<void*>&self.singleMuSingleEPrescale_value)

        #print "making singleMu_leg1Group"
        self.singleMu_leg1Group_branch = the_tree.GetBranch("singleMu_leg1Group")
        #if not self.singleMu_leg1Group_branch and "singleMu_leg1Group" not in self.complained:
        if not self.singleMu_leg1Group_branch and "singleMu_leg1Group":
            warnings.warn( "MMMTree: Expected branch singleMu_leg1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Group")
        else:
            self.singleMu_leg1Group_branch.SetAddress(<void*>&self.singleMu_leg1Group_value)

        #print "making singleMu_leg1Pass"
        self.singleMu_leg1Pass_branch = the_tree.GetBranch("singleMu_leg1Pass")
        #if not self.singleMu_leg1Pass_branch and "singleMu_leg1Pass" not in self.complained:
        if not self.singleMu_leg1Pass_branch and "singleMu_leg1Pass":
            warnings.warn( "MMMTree: Expected branch singleMu_leg1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Pass")
        else:
            self.singleMu_leg1Pass_branch.SetAddress(<void*>&self.singleMu_leg1Pass_value)

        #print "making singleMu_leg1Prescale"
        self.singleMu_leg1Prescale_branch = the_tree.GetBranch("singleMu_leg1Prescale")
        #if not self.singleMu_leg1Prescale_branch and "singleMu_leg1Prescale" not in self.complained:
        if not self.singleMu_leg1Prescale_branch and "singleMu_leg1Prescale":
            warnings.warn( "MMMTree: Expected branch singleMu_leg1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Prescale")
        else:
            self.singleMu_leg1Prescale_branch.SetAddress(<void*>&self.singleMu_leg1Prescale_value)

        #print "making singleMu_leg1_noisoGroup"
        self.singleMu_leg1_noisoGroup_branch = the_tree.GetBranch("singleMu_leg1_noisoGroup")
        #if not self.singleMu_leg1_noisoGroup_branch and "singleMu_leg1_noisoGroup" not in self.complained:
        if not self.singleMu_leg1_noisoGroup_branch and "singleMu_leg1_noisoGroup":
            warnings.warn( "MMMTree: Expected branch singleMu_leg1_noisoGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoGroup")
        else:
            self.singleMu_leg1_noisoGroup_branch.SetAddress(<void*>&self.singleMu_leg1_noisoGroup_value)

        #print "making singleMu_leg1_noisoPass"
        self.singleMu_leg1_noisoPass_branch = the_tree.GetBranch("singleMu_leg1_noisoPass")
        #if not self.singleMu_leg1_noisoPass_branch and "singleMu_leg1_noisoPass" not in self.complained:
        if not self.singleMu_leg1_noisoPass_branch and "singleMu_leg1_noisoPass":
            warnings.warn( "MMMTree: Expected branch singleMu_leg1_noisoPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoPass")
        else:
            self.singleMu_leg1_noisoPass_branch.SetAddress(<void*>&self.singleMu_leg1_noisoPass_value)

        #print "making singleMu_leg1_noisoPrescale"
        self.singleMu_leg1_noisoPrescale_branch = the_tree.GetBranch("singleMu_leg1_noisoPrescale")
        #if not self.singleMu_leg1_noisoPrescale_branch and "singleMu_leg1_noisoPrescale" not in self.complained:
        if not self.singleMu_leg1_noisoPrescale_branch and "singleMu_leg1_noisoPrescale":
            warnings.warn( "MMMTree: Expected branch singleMu_leg1_noisoPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoPrescale")
        else:
            self.singleMu_leg1_noisoPrescale_branch.SetAddress(<void*>&self.singleMu_leg1_noisoPrescale_value)

        #print "making singleMu_leg2Group"
        self.singleMu_leg2Group_branch = the_tree.GetBranch("singleMu_leg2Group")
        #if not self.singleMu_leg2Group_branch and "singleMu_leg2Group" not in self.complained:
        if not self.singleMu_leg2Group_branch and "singleMu_leg2Group":
            warnings.warn( "MMMTree: Expected branch singleMu_leg2Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Group")
        else:
            self.singleMu_leg2Group_branch.SetAddress(<void*>&self.singleMu_leg2Group_value)

        #print "making singleMu_leg2Pass"
        self.singleMu_leg2Pass_branch = the_tree.GetBranch("singleMu_leg2Pass")
        #if not self.singleMu_leg2Pass_branch and "singleMu_leg2Pass" not in self.complained:
        if not self.singleMu_leg2Pass_branch and "singleMu_leg2Pass":
            warnings.warn( "MMMTree: Expected branch singleMu_leg2Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Pass")
        else:
            self.singleMu_leg2Pass_branch.SetAddress(<void*>&self.singleMu_leg2Pass_value)

        #print "making singleMu_leg2Prescale"
        self.singleMu_leg2Prescale_branch = the_tree.GetBranch("singleMu_leg2Prescale")
        #if not self.singleMu_leg2Prescale_branch and "singleMu_leg2Prescale" not in self.complained:
        if not self.singleMu_leg2Prescale_branch and "singleMu_leg2Prescale":
            warnings.warn( "MMMTree: Expected branch singleMu_leg2Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Prescale")
        else:
            self.singleMu_leg2Prescale_branch.SetAddress(<void*>&self.singleMu_leg2Prescale_value)

        #print "making singleMu_leg2_noisoGroup"
        self.singleMu_leg2_noisoGroup_branch = the_tree.GetBranch("singleMu_leg2_noisoGroup")
        #if not self.singleMu_leg2_noisoGroup_branch and "singleMu_leg2_noisoGroup" not in self.complained:
        if not self.singleMu_leg2_noisoGroup_branch and "singleMu_leg2_noisoGroup":
            warnings.warn( "MMMTree: Expected branch singleMu_leg2_noisoGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoGroup")
        else:
            self.singleMu_leg2_noisoGroup_branch.SetAddress(<void*>&self.singleMu_leg2_noisoGroup_value)

        #print "making singleMu_leg2_noisoPass"
        self.singleMu_leg2_noisoPass_branch = the_tree.GetBranch("singleMu_leg2_noisoPass")
        #if not self.singleMu_leg2_noisoPass_branch and "singleMu_leg2_noisoPass" not in self.complained:
        if not self.singleMu_leg2_noisoPass_branch and "singleMu_leg2_noisoPass":
            warnings.warn( "MMMTree: Expected branch singleMu_leg2_noisoPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoPass")
        else:
            self.singleMu_leg2_noisoPass_branch.SetAddress(<void*>&self.singleMu_leg2_noisoPass_value)

        #print "making singleMu_leg2_noisoPrescale"
        self.singleMu_leg2_noisoPrescale_branch = the_tree.GetBranch("singleMu_leg2_noisoPrescale")
        #if not self.singleMu_leg2_noisoPrescale_branch and "singleMu_leg2_noisoPrescale" not in self.complained:
        if not self.singleMu_leg2_noisoPrescale_branch and "singleMu_leg2_noisoPrescale":
            warnings.warn( "MMMTree: Expected branch singleMu_leg2_noisoPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoPrescale")
        else:
            self.singleMu_leg2_noisoPrescale_branch.SetAddress(<void*>&self.singleMu_leg2_noisoPrescale_value)

        #print "making tauVetoPt20Loose3HitsNewDMVtx"
        self.tauVetoPt20Loose3HitsNewDMVtx_branch = the_tree.GetBranch("tauVetoPt20Loose3HitsNewDMVtx")
        #if not self.tauVetoPt20Loose3HitsNewDMVtx_branch and "tauVetoPt20Loose3HitsNewDMVtx" not in self.complained:
        if not self.tauVetoPt20Loose3HitsNewDMVtx_branch and "tauVetoPt20Loose3HitsNewDMVtx":
            warnings.warn( "MMMTree: Expected branch tauVetoPt20Loose3HitsNewDMVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20Loose3HitsNewDMVtx")
        else:
            self.tauVetoPt20Loose3HitsNewDMVtx_branch.SetAddress(<void*>&self.tauVetoPt20Loose3HitsNewDMVtx_value)

        #print "making tauVetoPt20Loose3HitsVtx"
        self.tauVetoPt20Loose3HitsVtx_branch = the_tree.GetBranch("tauVetoPt20Loose3HitsVtx")
        #if not self.tauVetoPt20Loose3HitsVtx_branch and "tauVetoPt20Loose3HitsVtx" not in self.complained:
        if not self.tauVetoPt20Loose3HitsVtx_branch and "tauVetoPt20Loose3HitsVtx":
            warnings.warn( "MMMTree: Expected branch tauVetoPt20Loose3HitsVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20Loose3HitsVtx")
        else:
            self.tauVetoPt20Loose3HitsVtx_branch.SetAddress(<void*>&self.tauVetoPt20Loose3HitsVtx_value)

        #print "making tauVetoPt20TightMVALTNewDMVtx"
        self.tauVetoPt20TightMVALTNewDMVtx_branch = the_tree.GetBranch("tauVetoPt20TightMVALTNewDMVtx")
        #if not self.tauVetoPt20TightMVALTNewDMVtx_branch and "tauVetoPt20TightMVALTNewDMVtx" not in self.complained:
        if not self.tauVetoPt20TightMVALTNewDMVtx_branch and "tauVetoPt20TightMVALTNewDMVtx":
            warnings.warn( "MMMTree: Expected branch tauVetoPt20TightMVALTNewDMVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20TightMVALTNewDMVtx")
        else:
            self.tauVetoPt20TightMVALTNewDMVtx_branch.SetAddress(<void*>&self.tauVetoPt20TightMVALTNewDMVtx_value)

        #print "making tauVetoPt20TightMVALTVtx"
        self.tauVetoPt20TightMVALTVtx_branch = the_tree.GetBranch("tauVetoPt20TightMVALTVtx")
        #if not self.tauVetoPt20TightMVALTVtx_branch and "tauVetoPt20TightMVALTVtx" not in self.complained:
        if not self.tauVetoPt20TightMVALTVtx_branch and "tauVetoPt20TightMVALTVtx":
            warnings.warn( "MMMTree: Expected branch tauVetoPt20TightMVALTVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20TightMVALTVtx")
        else:
            self.tauVetoPt20TightMVALTVtx_branch.SetAddress(<void*>&self.tauVetoPt20TightMVALTVtx_value)

        #print "making tripleEGroup"
        self.tripleEGroup_branch = the_tree.GetBranch("tripleEGroup")
        #if not self.tripleEGroup_branch and "tripleEGroup" not in self.complained:
        if not self.tripleEGroup_branch and "tripleEGroup":
            warnings.warn( "MMMTree: Expected branch tripleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEGroup")
        else:
            self.tripleEGroup_branch.SetAddress(<void*>&self.tripleEGroup_value)

        #print "making tripleEPass"
        self.tripleEPass_branch = the_tree.GetBranch("tripleEPass")
        #if not self.tripleEPass_branch and "tripleEPass" not in self.complained:
        if not self.tripleEPass_branch and "tripleEPass":
            warnings.warn( "MMMTree: Expected branch tripleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEPass")
        else:
            self.tripleEPass_branch.SetAddress(<void*>&self.tripleEPass_value)

        #print "making tripleEPrescale"
        self.tripleEPrescale_branch = the_tree.GetBranch("tripleEPrescale")
        #if not self.tripleEPrescale_branch and "tripleEPrescale" not in self.complained:
        if not self.tripleEPrescale_branch and "tripleEPrescale":
            warnings.warn( "MMMTree: Expected branch tripleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEPrescale")
        else:
            self.tripleEPrescale_branch.SetAddress(<void*>&self.tripleEPrescale_value)

        #print "making tripleMuGroup"
        self.tripleMuGroup_branch = the_tree.GetBranch("tripleMuGroup")
        #if not self.tripleMuGroup_branch and "tripleMuGroup" not in self.complained:
        if not self.tripleMuGroup_branch and "tripleMuGroup":
            warnings.warn( "MMMTree: Expected branch tripleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuGroup")
        else:
            self.tripleMuGroup_branch.SetAddress(<void*>&self.tripleMuGroup_value)

        #print "making tripleMuPass"
        self.tripleMuPass_branch = the_tree.GetBranch("tripleMuPass")
        #if not self.tripleMuPass_branch and "tripleMuPass" not in self.complained:
        if not self.tripleMuPass_branch and "tripleMuPass":
            warnings.warn( "MMMTree: Expected branch tripleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuPass")
        else:
            self.tripleMuPass_branch.SetAddress(<void*>&self.tripleMuPass_value)

        #print "making tripleMuPrescale"
        self.tripleMuPrescale_branch = the_tree.GetBranch("tripleMuPrescale")
        #if not self.tripleMuPrescale_branch and "tripleMuPrescale" not in self.complained:
        if not self.tripleMuPrescale_branch and "tripleMuPrescale":
            warnings.warn( "MMMTree: Expected branch tripleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuPrescale")
        else:
            self.tripleMuPrescale_branch.SetAddress(<void*>&self.tripleMuPrescale_value)

        #print "making type1_pfMetEt"
        self.type1_pfMetEt_branch = the_tree.GetBranch("type1_pfMetEt")
        #if not self.type1_pfMetEt_branch and "type1_pfMetEt" not in self.complained:
        if not self.type1_pfMetEt_branch and "type1_pfMetEt":
            warnings.warn( "MMMTree: Expected branch type1_pfMetEt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMetEt")
        else:
            self.type1_pfMetEt_branch.SetAddress(<void*>&self.type1_pfMetEt_value)

        #print "making type1_pfMetPhi"
        self.type1_pfMetPhi_branch = the_tree.GetBranch("type1_pfMetPhi")
        #if not self.type1_pfMetPhi_branch and "type1_pfMetPhi" not in self.complained:
        if not self.type1_pfMetPhi_branch and "type1_pfMetPhi":
            warnings.warn( "MMMTree: Expected branch type1_pfMetPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMetPhi")
        else:
            self.type1_pfMetPhi_branch.SetAddress(<void*>&self.type1_pfMetPhi_value)

        #print "making type1_pfMet_shiftedPhi_ElectronEnDown"
        self.type1_pfMet_shiftedPhi_ElectronEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_ElectronEnDown")
        #if not self.type1_pfMet_shiftedPhi_ElectronEnDown_branch and "type1_pfMet_shiftedPhi_ElectronEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_ElectronEnDown_branch and "type1_pfMet_shiftedPhi_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_ElectronEnDown")
        else:
            self.type1_pfMet_shiftedPhi_ElectronEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_ElectronEnDown_value)

        #print "making type1_pfMet_shiftedPhi_ElectronEnUp"
        self.type1_pfMet_shiftedPhi_ElectronEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_ElectronEnUp")
        #if not self.type1_pfMet_shiftedPhi_ElectronEnUp_branch and "type1_pfMet_shiftedPhi_ElectronEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_ElectronEnUp_branch and "type1_pfMet_shiftedPhi_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_ElectronEnUp")
        else:
            self.type1_pfMet_shiftedPhi_ElectronEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_ElectronEnUp_value)

        #print "making type1_pfMet_shiftedPhi_JetEnDown"
        self.type1_pfMet_shiftedPhi_JetEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetEnDown")
        #if not self.type1_pfMet_shiftedPhi_JetEnDown_branch and "type1_pfMet_shiftedPhi_JetEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetEnDown_branch and "type1_pfMet_shiftedPhi_JetEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetEnDown")
        else:
            self.type1_pfMet_shiftedPhi_JetEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetEnDown_value)

        #print "making type1_pfMet_shiftedPhi_JetEnUp"
        self.type1_pfMet_shiftedPhi_JetEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetEnUp")
        #if not self.type1_pfMet_shiftedPhi_JetEnUp_branch and "type1_pfMet_shiftedPhi_JetEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetEnUp_branch and "type1_pfMet_shiftedPhi_JetEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetEnUp")
        else:
            self.type1_pfMet_shiftedPhi_JetEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetEnUp_value)

        #print "making type1_pfMet_shiftedPhi_JetResDown"
        self.type1_pfMet_shiftedPhi_JetResDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetResDown")
        #if not self.type1_pfMet_shiftedPhi_JetResDown_branch and "type1_pfMet_shiftedPhi_JetResDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetResDown_branch and "type1_pfMet_shiftedPhi_JetResDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetResDown")
        else:
            self.type1_pfMet_shiftedPhi_JetResDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetResDown_value)

        #print "making type1_pfMet_shiftedPhi_JetResUp"
        self.type1_pfMet_shiftedPhi_JetResUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetResUp")
        #if not self.type1_pfMet_shiftedPhi_JetResUp_branch and "type1_pfMet_shiftedPhi_JetResUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetResUp_branch and "type1_pfMet_shiftedPhi_JetResUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetResUp")
        else:
            self.type1_pfMet_shiftedPhi_JetResUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetResUp_value)

        #print "making type1_pfMet_shiftedPhi_MuonEnDown"
        self.type1_pfMet_shiftedPhi_MuonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_MuonEnDown")
        #if not self.type1_pfMet_shiftedPhi_MuonEnDown_branch and "type1_pfMet_shiftedPhi_MuonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_MuonEnDown_branch and "type1_pfMet_shiftedPhi_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_MuonEnDown")
        else:
            self.type1_pfMet_shiftedPhi_MuonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_MuonEnDown_value)

        #print "making type1_pfMet_shiftedPhi_MuonEnUp"
        self.type1_pfMet_shiftedPhi_MuonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_MuonEnUp")
        #if not self.type1_pfMet_shiftedPhi_MuonEnUp_branch and "type1_pfMet_shiftedPhi_MuonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_MuonEnUp_branch and "type1_pfMet_shiftedPhi_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_MuonEnUp")
        else:
            self.type1_pfMet_shiftedPhi_MuonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_MuonEnUp_value)

        #print "making type1_pfMet_shiftedPhi_PhotonEnDown"
        self.type1_pfMet_shiftedPhi_PhotonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_PhotonEnDown")
        #if not self.type1_pfMet_shiftedPhi_PhotonEnDown_branch and "type1_pfMet_shiftedPhi_PhotonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_PhotonEnDown_branch and "type1_pfMet_shiftedPhi_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_PhotonEnDown")
        else:
            self.type1_pfMet_shiftedPhi_PhotonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_PhotonEnDown_value)

        #print "making type1_pfMet_shiftedPhi_PhotonEnUp"
        self.type1_pfMet_shiftedPhi_PhotonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_PhotonEnUp")
        #if not self.type1_pfMet_shiftedPhi_PhotonEnUp_branch and "type1_pfMet_shiftedPhi_PhotonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_PhotonEnUp_branch and "type1_pfMet_shiftedPhi_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_PhotonEnUp")
        else:
            self.type1_pfMet_shiftedPhi_PhotonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_PhotonEnUp_value)

        #print "making type1_pfMet_shiftedPhi_TauEnDown"
        self.type1_pfMet_shiftedPhi_TauEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_TauEnDown")
        #if not self.type1_pfMet_shiftedPhi_TauEnDown_branch and "type1_pfMet_shiftedPhi_TauEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_TauEnDown_branch and "type1_pfMet_shiftedPhi_TauEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_TauEnDown")
        else:
            self.type1_pfMet_shiftedPhi_TauEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_TauEnDown_value)

        #print "making type1_pfMet_shiftedPhi_TauEnUp"
        self.type1_pfMet_shiftedPhi_TauEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_TauEnUp")
        #if not self.type1_pfMet_shiftedPhi_TauEnUp_branch and "type1_pfMet_shiftedPhi_TauEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_TauEnUp_branch and "type1_pfMet_shiftedPhi_TauEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_TauEnUp")
        else:
            self.type1_pfMet_shiftedPhi_TauEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_TauEnUp_value)

        #print "making type1_pfMet_shiftedPhi_UnclusteredEnDown"
        self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_UnclusteredEnDown")
        #if not self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch and "type1_pfMet_shiftedPhi_UnclusteredEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch and "type1_pfMet_shiftedPhi_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_UnclusteredEnDown")
        else:
            self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_UnclusteredEnDown_value)

        #print "making type1_pfMet_shiftedPhi_UnclusteredEnUp"
        self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_UnclusteredEnUp")
        #if not self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch and "type1_pfMet_shiftedPhi_UnclusteredEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch and "type1_pfMet_shiftedPhi_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPhi_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_UnclusteredEnUp")
        else:
            self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_UnclusteredEnUp_value)

        #print "making type1_pfMet_shiftedPt_ElectronEnDown"
        self.type1_pfMet_shiftedPt_ElectronEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_ElectronEnDown")
        #if not self.type1_pfMet_shiftedPt_ElectronEnDown_branch and "type1_pfMet_shiftedPt_ElectronEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_ElectronEnDown_branch and "type1_pfMet_shiftedPt_ElectronEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_ElectronEnDown")
        else:
            self.type1_pfMet_shiftedPt_ElectronEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_ElectronEnDown_value)

        #print "making type1_pfMet_shiftedPt_ElectronEnUp"
        self.type1_pfMet_shiftedPt_ElectronEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_ElectronEnUp")
        #if not self.type1_pfMet_shiftedPt_ElectronEnUp_branch and "type1_pfMet_shiftedPt_ElectronEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_ElectronEnUp_branch and "type1_pfMet_shiftedPt_ElectronEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_ElectronEnUp")
        else:
            self.type1_pfMet_shiftedPt_ElectronEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_ElectronEnUp_value)

        #print "making type1_pfMet_shiftedPt_JetEnDown"
        self.type1_pfMet_shiftedPt_JetEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetEnDown")
        #if not self.type1_pfMet_shiftedPt_JetEnDown_branch and "type1_pfMet_shiftedPt_JetEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetEnDown_branch and "type1_pfMet_shiftedPt_JetEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetEnDown")
        else:
            self.type1_pfMet_shiftedPt_JetEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetEnDown_value)

        #print "making type1_pfMet_shiftedPt_JetEnUp"
        self.type1_pfMet_shiftedPt_JetEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetEnUp")
        #if not self.type1_pfMet_shiftedPt_JetEnUp_branch and "type1_pfMet_shiftedPt_JetEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetEnUp_branch and "type1_pfMet_shiftedPt_JetEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetEnUp")
        else:
            self.type1_pfMet_shiftedPt_JetEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetEnUp_value)

        #print "making type1_pfMet_shiftedPt_JetResDown"
        self.type1_pfMet_shiftedPt_JetResDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetResDown")
        #if not self.type1_pfMet_shiftedPt_JetResDown_branch and "type1_pfMet_shiftedPt_JetResDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetResDown_branch and "type1_pfMet_shiftedPt_JetResDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetResDown")
        else:
            self.type1_pfMet_shiftedPt_JetResDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetResDown_value)

        #print "making type1_pfMet_shiftedPt_JetResUp"
        self.type1_pfMet_shiftedPt_JetResUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetResUp")
        #if not self.type1_pfMet_shiftedPt_JetResUp_branch and "type1_pfMet_shiftedPt_JetResUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetResUp_branch and "type1_pfMet_shiftedPt_JetResUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetResUp")
        else:
            self.type1_pfMet_shiftedPt_JetResUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetResUp_value)

        #print "making type1_pfMet_shiftedPt_MuonEnDown"
        self.type1_pfMet_shiftedPt_MuonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_MuonEnDown")
        #if not self.type1_pfMet_shiftedPt_MuonEnDown_branch and "type1_pfMet_shiftedPt_MuonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_MuonEnDown_branch and "type1_pfMet_shiftedPt_MuonEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_MuonEnDown")
        else:
            self.type1_pfMet_shiftedPt_MuonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_MuonEnDown_value)

        #print "making type1_pfMet_shiftedPt_MuonEnUp"
        self.type1_pfMet_shiftedPt_MuonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_MuonEnUp")
        #if not self.type1_pfMet_shiftedPt_MuonEnUp_branch and "type1_pfMet_shiftedPt_MuonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_MuonEnUp_branch and "type1_pfMet_shiftedPt_MuonEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_MuonEnUp")
        else:
            self.type1_pfMet_shiftedPt_MuonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_MuonEnUp_value)

        #print "making type1_pfMet_shiftedPt_PhotonEnDown"
        self.type1_pfMet_shiftedPt_PhotonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_PhotonEnDown")
        #if not self.type1_pfMet_shiftedPt_PhotonEnDown_branch and "type1_pfMet_shiftedPt_PhotonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_PhotonEnDown_branch and "type1_pfMet_shiftedPt_PhotonEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_PhotonEnDown")
        else:
            self.type1_pfMet_shiftedPt_PhotonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_PhotonEnDown_value)

        #print "making type1_pfMet_shiftedPt_PhotonEnUp"
        self.type1_pfMet_shiftedPt_PhotonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_PhotonEnUp")
        #if not self.type1_pfMet_shiftedPt_PhotonEnUp_branch and "type1_pfMet_shiftedPt_PhotonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_PhotonEnUp_branch and "type1_pfMet_shiftedPt_PhotonEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_PhotonEnUp")
        else:
            self.type1_pfMet_shiftedPt_PhotonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_PhotonEnUp_value)

        #print "making type1_pfMet_shiftedPt_TauEnDown"
        self.type1_pfMet_shiftedPt_TauEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_TauEnDown")
        #if not self.type1_pfMet_shiftedPt_TauEnDown_branch and "type1_pfMet_shiftedPt_TauEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_TauEnDown_branch and "type1_pfMet_shiftedPt_TauEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_TauEnDown")
        else:
            self.type1_pfMet_shiftedPt_TauEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_TauEnDown_value)

        #print "making type1_pfMet_shiftedPt_TauEnUp"
        self.type1_pfMet_shiftedPt_TauEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_TauEnUp")
        #if not self.type1_pfMet_shiftedPt_TauEnUp_branch and "type1_pfMet_shiftedPt_TauEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_TauEnUp_branch and "type1_pfMet_shiftedPt_TauEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_TauEnUp")
        else:
            self.type1_pfMet_shiftedPt_TauEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_TauEnUp_value)

        #print "making type1_pfMet_shiftedPt_UnclusteredEnDown"
        self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_UnclusteredEnDown")
        #if not self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch and "type1_pfMet_shiftedPt_UnclusteredEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch and "type1_pfMet_shiftedPt_UnclusteredEnDown":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_UnclusteredEnDown")
        else:
            self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_UnclusteredEnDown_value)

        #print "making type1_pfMet_shiftedPt_UnclusteredEnUp"
        self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_UnclusteredEnUp")
        #if not self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch and "type1_pfMet_shiftedPt_UnclusteredEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch and "type1_pfMet_shiftedPt_UnclusteredEnUp":
            warnings.warn( "MMMTree: Expected branch type1_pfMet_shiftedPt_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_UnclusteredEnUp")
        else:
            self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_UnclusteredEnUp_value)

        #print "making vbfDeta"
        self.vbfDeta_branch = the_tree.GetBranch("vbfDeta")
        #if not self.vbfDeta_branch and "vbfDeta" not in self.complained:
        if not self.vbfDeta_branch and "vbfDeta":
            warnings.warn( "MMMTree: Expected branch vbfDeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta")
        else:
            self.vbfDeta_branch.SetAddress(<void*>&self.vbfDeta_value)

        #print "making vbfDeta_JetEnDown"
        self.vbfDeta_JetEnDown_branch = the_tree.GetBranch("vbfDeta_JetEnDown")
        #if not self.vbfDeta_JetEnDown_branch and "vbfDeta_JetEnDown" not in self.complained:
        if not self.vbfDeta_JetEnDown_branch and "vbfDeta_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfDeta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta_JetEnDown")
        else:
            self.vbfDeta_JetEnDown_branch.SetAddress(<void*>&self.vbfDeta_JetEnDown_value)

        #print "making vbfDeta_JetEnUp"
        self.vbfDeta_JetEnUp_branch = the_tree.GetBranch("vbfDeta_JetEnUp")
        #if not self.vbfDeta_JetEnUp_branch and "vbfDeta_JetEnUp" not in self.complained:
        if not self.vbfDeta_JetEnUp_branch and "vbfDeta_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfDeta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta_JetEnUp")
        else:
            self.vbfDeta_JetEnUp_branch.SetAddress(<void*>&self.vbfDeta_JetEnUp_value)

        #print "making vbfDijetrap"
        self.vbfDijetrap_branch = the_tree.GetBranch("vbfDijetrap")
        #if not self.vbfDijetrap_branch and "vbfDijetrap" not in self.complained:
        if not self.vbfDijetrap_branch and "vbfDijetrap":
            warnings.warn( "MMMTree: Expected branch vbfDijetrap does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap")
        else:
            self.vbfDijetrap_branch.SetAddress(<void*>&self.vbfDijetrap_value)

        #print "making vbfDijetrap_JetEnDown"
        self.vbfDijetrap_JetEnDown_branch = the_tree.GetBranch("vbfDijetrap_JetEnDown")
        #if not self.vbfDijetrap_JetEnDown_branch and "vbfDijetrap_JetEnDown" not in self.complained:
        if not self.vbfDijetrap_JetEnDown_branch and "vbfDijetrap_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfDijetrap_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap_JetEnDown")
        else:
            self.vbfDijetrap_JetEnDown_branch.SetAddress(<void*>&self.vbfDijetrap_JetEnDown_value)

        #print "making vbfDijetrap_JetEnUp"
        self.vbfDijetrap_JetEnUp_branch = the_tree.GetBranch("vbfDijetrap_JetEnUp")
        #if not self.vbfDijetrap_JetEnUp_branch and "vbfDijetrap_JetEnUp" not in self.complained:
        if not self.vbfDijetrap_JetEnUp_branch and "vbfDijetrap_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfDijetrap_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap_JetEnUp")
        else:
            self.vbfDijetrap_JetEnUp_branch.SetAddress(<void*>&self.vbfDijetrap_JetEnUp_value)

        #print "making vbfDphi"
        self.vbfDphi_branch = the_tree.GetBranch("vbfDphi")
        #if not self.vbfDphi_branch and "vbfDphi" not in self.complained:
        if not self.vbfDphi_branch and "vbfDphi":
            warnings.warn( "MMMTree: Expected branch vbfDphi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi")
        else:
            self.vbfDphi_branch.SetAddress(<void*>&self.vbfDphi_value)

        #print "making vbfDphi_JetEnDown"
        self.vbfDphi_JetEnDown_branch = the_tree.GetBranch("vbfDphi_JetEnDown")
        #if not self.vbfDphi_JetEnDown_branch and "vbfDphi_JetEnDown" not in self.complained:
        if not self.vbfDphi_JetEnDown_branch and "vbfDphi_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfDphi_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi_JetEnDown")
        else:
            self.vbfDphi_JetEnDown_branch.SetAddress(<void*>&self.vbfDphi_JetEnDown_value)

        #print "making vbfDphi_JetEnUp"
        self.vbfDphi_JetEnUp_branch = the_tree.GetBranch("vbfDphi_JetEnUp")
        #if not self.vbfDphi_JetEnUp_branch and "vbfDphi_JetEnUp" not in self.complained:
        if not self.vbfDphi_JetEnUp_branch and "vbfDphi_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfDphi_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi_JetEnUp")
        else:
            self.vbfDphi_JetEnUp_branch.SetAddress(<void*>&self.vbfDphi_JetEnUp_value)

        #print "making vbfDphihj"
        self.vbfDphihj_branch = the_tree.GetBranch("vbfDphihj")
        #if not self.vbfDphihj_branch and "vbfDphihj" not in self.complained:
        if not self.vbfDphihj_branch and "vbfDphihj":
            warnings.warn( "MMMTree: Expected branch vbfDphihj does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj")
        else:
            self.vbfDphihj_branch.SetAddress(<void*>&self.vbfDphihj_value)

        #print "making vbfDphihj_JetEnDown"
        self.vbfDphihj_JetEnDown_branch = the_tree.GetBranch("vbfDphihj_JetEnDown")
        #if not self.vbfDphihj_JetEnDown_branch and "vbfDphihj_JetEnDown" not in self.complained:
        if not self.vbfDphihj_JetEnDown_branch and "vbfDphihj_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfDphihj_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj_JetEnDown")
        else:
            self.vbfDphihj_JetEnDown_branch.SetAddress(<void*>&self.vbfDphihj_JetEnDown_value)

        #print "making vbfDphihj_JetEnUp"
        self.vbfDphihj_JetEnUp_branch = the_tree.GetBranch("vbfDphihj_JetEnUp")
        #if not self.vbfDphihj_JetEnUp_branch and "vbfDphihj_JetEnUp" not in self.complained:
        if not self.vbfDphihj_JetEnUp_branch and "vbfDphihj_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfDphihj_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj_JetEnUp")
        else:
            self.vbfDphihj_JetEnUp_branch.SetAddress(<void*>&self.vbfDphihj_JetEnUp_value)

        #print "making vbfDphihjnomet"
        self.vbfDphihjnomet_branch = the_tree.GetBranch("vbfDphihjnomet")
        #if not self.vbfDphihjnomet_branch and "vbfDphihjnomet" not in self.complained:
        if not self.vbfDphihjnomet_branch and "vbfDphihjnomet":
            warnings.warn( "MMMTree: Expected branch vbfDphihjnomet does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet")
        else:
            self.vbfDphihjnomet_branch.SetAddress(<void*>&self.vbfDphihjnomet_value)

        #print "making vbfDphihjnomet_JetEnDown"
        self.vbfDphihjnomet_JetEnDown_branch = the_tree.GetBranch("vbfDphihjnomet_JetEnDown")
        #if not self.vbfDphihjnomet_JetEnDown_branch and "vbfDphihjnomet_JetEnDown" not in self.complained:
        if not self.vbfDphihjnomet_JetEnDown_branch and "vbfDphihjnomet_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfDphihjnomet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet_JetEnDown")
        else:
            self.vbfDphihjnomet_JetEnDown_branch.SetAddress(<void*>&self.vbfDphihjnomet_JetEnDown_value)

        #print "making vbfDphihjnomet_JetEnUp"
        self.vbfDphihjnomet_JetEnUp_branch = the_tree.GetBranch("vbfDphihjnomet_JetEnUp")
        #if not self.vbfDphihjnomet_JetEnUp_branch and "vbfDphihjnomet_JetEnUp" not in self.complained:
        if not self.vbfDphihjnomet_JetEnUp_branch and "vbfDphihjnomet_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfDphihjnomet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet_JetEnUp")
        else:
            self.vbfDphihjnomet_JetEnUp_branch.SetAddress(<void*>&self.vbfDphihjnomet_JetEnUp_value)

        #print "making vbfHrap"
        self.vbfHrap_branch = the_tree.GetBranch("vbfHrap")
        #if not self.vbfHrap_branch and "vbfHrap" not in self.complained:
        if not self.vbfHrap_branch and "vbfHrap":
            warnings.warn( "MMMTree: Expected branch vbfHrap does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap")
        else:
            self.vbfHrap_branch.SetAddress(<void*>&self.vbfHrap_value)

        #print "making vbfHrap_JetEnDown"
        self.vbfHrap_JetEnDown_branch = the_tree.GetBranch("vbfHrap_JetEnDown")
        #if not self.vbfHrap_JetEnDown_branch and "vbfHrap_JetEnDown" not in self.complained:
        if not self.vbfHrap_JetEnDown_branch and "vbfHrap_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfHrap_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap_JetEnDown")
        else:
            self.vbfHrap_JetEnDown_branch.SetAddress(<void*>&self.vbfHrap_JetEnDown_value)

        #print "making vbfHrap_JetEnUp"
        self.vbfHrap_JetEnUp_branch = the_tree.GetBranch("vbfHrap_JetEnUp")
        #if not self.vbfHrap_JetEnUp_branch and "vbfHrap_JetEnUp" not in self.complained:
        if not self.vbfHrap_JetEnUp_branch and "vbfHrap_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfHrap_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap_JetEnUp")
        else:
            self.vbfHrap_JetEnUp_branch.SetAddress(<void*>&self.vbfHrap_JetEnUp_value)

        #print "making vbfJetVeto20"
        self.vbfJetVeto20_branch = the_tree.GetBranch("vbfJetVeto20")
        #if not self.vbfJetVeto20_branch and "vbfJetVeto20" not in self.complained:
        if not self.vbfJetVeto20_branch and "vbfJetVeto20":
            warnings.warn( "MMMTree: Expected branch vbfJetVeto20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20")
        else:
            self.vbfJetVeto20_branch.SetAddress(<void*>&self.vbfJetVeto20_value)

        #print "making vbfJetVeto20_JetEnDown"
        self.vbfJetVeto20_JetEnDown_branch = the_tree.GetBranch("vbfJetVeto20_JetEnDown")
        #if not self.vbfJetVeto20_JetEnDown_branch and "vbfJetVeto20_JetEnDown" not in self.complained:
        if not self.vbfJetVeto20_JetEnDown_branch and "vbfJetVeto20_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfJetVeto20_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20_JetEnDown")
        else:
            self.vbfJetVeto20_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVeto20_JetEnDown_value)

        #print "making vbfJetVeto20_JetEnUp"
        self.vbfJetVeto20_JetEnUp_branch = the_tree.GetBranch("vbfJetVeto20_JetEnUp")
        #if not self.vbfJetVeto20_JetEnUp_branch and "vbfJetVeto20_JetEnUp" not in self.complained:
        if not self.vbfJetVeto20_JetEnUp_branch and "vbfJetVeto20_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfJetVeto20_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20_JetEnUp")
        else:
            self.vbfJetVeto20_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVeto20_JetEnUp_value)

        #print "making vbfJetVeto30"
        self.vbfJetVeto30_branch = the_tree.GetBranch("vbfJetVeto30")
        #if not self.vbfJetVeto30_branch and "vbfJetVeto30" not in self.complained:
        if not self.vbfJetVeto30_branch and "vbfJetVeto30":
            warnings.warn( "MMMTree: Expected branch vbfJetVeto30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30")
        else:
            self.vbfJetVeto30_branch.SetAddress(<void*>&self.vbfJetVeto30_value)

        #print "making vbfJetVeto30_JetEnDown"
        self.vbfJetVeto30_JetEnDown_branch = the_tree.GetBranch("vbfJetVeto30_JetEnDown")
        #if not self.vbfJetVeto30_JetEnDown_branch and "vbfJetVeto30_JetEnDown" not in self.complained:
        if not self.vbfJetVeto30_JetEnDown_branch and "vbfJetVeto30_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfJetVeto30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30_JetEnDown")
        else:
            self.vbfJetVeto30_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVeto30_JetEnDown_value)

        #print "making vbfJetVeto30_JetEnUp"
        self.vbfJetVeto30_JetEnUp_branch = the_tree.GetBranch("vbfJetVeto30_JetEnUp")
        #if not self.vbfJetVeto30_JetEnUp_branch and "vbfJetVeto30_JetEnUp" not in self.complained:
        if not self.vbfJetVeto30_JetEnUp_branch and "vbfJetVeto30_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfJetVeto30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30_JetEnUp")
        else:
            self.vbfJetVeto30_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVeto30_JetEnUp_value)

        #print "making vbfJetVetoTight20"
        self.vbfJetVetoTight20_branch = the_tree.GetBranch("vbfJetVetoTight20")
        #if not self.vbfJetVetoTight20_branch and "vbfJetVetoTight20" not in self.complained:
        if not self.vbfJetVetoTight20_branch and "vbfJetVetoTight20":
            warnings.warn( "MMMTree: Expected branch vbfJetVetoTight20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20")
        else:
            self.vbfJetVetoTight20_branch.SetAddress(<void*>&self.vbfJetVetoTight20_value)

        #print "making vbfJetVetoTight20_JetEnDown"
        self.vbfJetVetoTight20_JetEnDown_branch = the_tree.GetBranch("vbfJetVetoTight20_JetEnDown")
        #if not self.vbfJetVetoTight20_JetEnDown_branch and "vbfJetVetoTight20_JetEnDown" not in self.complained:
        if not self.vbfJetVetoTight20_JetEnDown_branch and "vbfJetVetoTight20_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfJetVetoTight20_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20_JetEnDown")
        else:
            self.vbfJetVetoTight20_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVetoTight20_JetEnDown_value)

        #print "making vbfJetVetoTight20_JetEnUp"
        self.vbfJetVetoTight20_JetEnUp_branch = the_tree.GetBranch("vbfJetVetoTight20_JetEnUp")
        #if not self.vbfJetVetoTight20_JetEnUp_branch and "vbfJetVetoTight20_JetEnUp" not in self.complained:
        if not self.vbfJetVetoTight20_JetEnUp_branch and "vbfJetVetoTight20_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfJetVetoTight20_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20_JetEnUp")
        else:
            self.vbfJetVetoTight20_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVetoTight20_JetEnUp_value)

        #print "making vbfJetVetoTight30"
        self.vbfJetVetoTight30_branch = the_tree.GetBranch("vbfJetVetoTight30")
        #if not self.vbfJetVetoTight30_branch and "vbfJetVetoTight30" not in self.complained:
        if not self.vbfJetVetoTight30_branch and "vbfJetVetoTight30":
            warnings.warn( "MMMTree: Expected branch vbfJetVetoTight30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30")
        else:
            self.vbfJetVetoTight30_branch.SetAddress(<void*>&self.vbfJetVetoTight30_value)

        #print "making vbfJetVetoTight30_JetEnDown"
        self.vbfJetVetoTight30_JetEnDown_branch = the_tree.GetBranch("vbfJetVetoTight30_JetEnDown")
        #if not self.vbfJetVetoTight30_JetEnDown_branch and "vbfJetVetoTight30_JetEnDown" not in self.complained:
        if not self.vbfJetVetoTight30_JetEnDown_branch and "vbfJetVetoTight30_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfJetVetoTight30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30_JetEnDown")
        else:
            self.vbfJetVetoTight30_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVetoTight30_JetEnDown_value)

        #print "making vbfJetVetoTight30_JetEnUp"
        self.vbfJetVetoTight30_JetEnUp_branch = the_tree.GetBranch("vbfJetVetoTight30_JetEnUp")
        #if not self.vbfJetVetoTight30_JetEnUp_branch and "vbfJetVetoTight30_JetEnUp" not in self.complained:
        if not self.vbfJetVetoTight30_JetEnUp_branch and "vbfJetVetoTight30_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfJetVetoTight30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30_JetEnUp")
        else:
            self.vbfJetVetoTight30_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVetoTight30_JetEnUp_value)

        #print "making vbfMVA"
        self.vbfMVA_branch = the_tree.GetBranch("vbfMVA")
        #if not self.vbfMVA_branch and "vbfMVA" not in self.complained:
        if not self.vbfMVA_branch and "vbfMVA":
            warnings.warn( "MMMTree: Expected branch vbfMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA")
        else:
            self.vbfMVA_branch.SetAddress(<void*>&self.vbfMVA_value)

        #print "making vbfMVA_JetEnDown"
        self.vbfMVA_JetEnDown_branch = the_tree.GetBranch("vbfMVA_JetEnDown")
        #if not self.vbfMVA_JetEnDown_branch and "vbfMVA_JetEnDown" not in self.complained:
        if not self.vbfMVA_JetEnDown_branch and "vbfMVA_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfMVA_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA_JetEnDown")
        else:
            self.vbfMVA_JetEnDown_branch.SetAddress(<void*>&self.vbfMVA_JetEnDown_value)

        #print "making vbfMVA_JetEnUp"
        self.vbfMVA_JetEnUp_branch = the_tree.GetBranch("vbfMVA_JetEnUp")
        #if not self.vbfMVA_JetEnUp_branch and "vbfMVA_JetEnUp" not in self.complained:
        if not self.vbfMVA_JetEnUp_branch and "vbfMVA_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfMVA_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA_JetEnUp")
        else:
            self.vbfMVA_JetEnUp_branch.SetAddress(<void*>&self.vbfMVA_JetEnUp_value)

        #print "making vbfMass"
        self.vbfMass_branch = the_tree.GetBranch("vbfMass")
        #if not self.vbfMass_branch and "vbfMass" not in self.complained:
        if not self.vbfMass_branch and "vbfMass":
            warnings.warn( "MMMTree: Expected branch vbfMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass")
        else:
            self.vbfMass_branch.SetAddress(<void*>&self.vbfMass_value)

        #print "making vbfMass_JetEnDown"
        self.vbfMass_JetEnDown_branch = the_tree.GetBranch("vbfMass_JetEnDown")
        #if not self.vbfMass_JetEnDown_branch and "vbfMass_JetEnDown" not in self.complained:
        if not self.vbfMass_JetEnDown_branch and "vbfMass_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfMass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass_JetEnDown")
        else:
            self.vbfMass_JetEnDown_branch.SetAddress(<void*>&self.vbfMass_JetEnDown_value)

        #print "making vbfMass_JetEnUp"
        self.vbfMass_JetEnUp_branch = the_tree.GetBranch("vbfMass_JetEnUp")
        #if not self.vbfMass_JetEnUp_branch and "vbfMass_JetEnUp" not in self.complained:
        if not self.vbfMass_JetEnUp_branch and "vbfMass_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfMass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass_JetEnUp")
        else:
            self.vbfMass_JetEnUp_branch.SetAddress(<void*>&self.vbfMass_JetEnUp_value)

        #print "making vbfNJets"
        self.vbfNJets_branch = the_tree.GetBranch("vbfNJets")
        #if not self.vbfNJets_branch and "vbfNJets" not in self.complained:
        if not self.vbfNJets_branch and "vbfNJets":
            warnings.warn( "MMMTree: Expected branch vbfNJets does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets")
        else:
            self.vbfNJets_branch.SetAddress(<void*>&self.vbfNJets_value)

        #print "making vbfNJets_JetEnDown"
        self.vbfNJets_JetEnDown_branch = the_tree.GetBranch("vbfNJets_JetEnDown")
        #if not self.vbfNJets_JetEnDown_branch and "vbfNJets_JetEnDown" not in self.complained:
        if not self.vbfNJets_JetEnDown_branch and "vbfNJets_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfNJets_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets_JetEnDown")
        else:
            self.vbfNJets_JetEnDown_branch.SetAddress(<void*>&self.vbfNJets_JetEnDown_value)

        #print "making vbfNJets_JetEnUp"
        self.vbfNJets_JetEnUp_branch = the_tree.GetBranch("vbfNJets_JetEnUp")
        #if not self.vbfNJets_JetEnUp_branch and "vbfNJets_JetEnUp" not in self.complained:
        if not self.vbfNJets_JetEnUp_branch and "vbfNJets_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfNJets_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets_JetEnUp")
        else:
            self.vbfNJets_JetEnUp_branch.SetAddress(<void*>&self.vbfNJets_JetEnUp_value)

        #print "making vbfVispt"
        self.vbfVispt_branch = the_tree.GetBranch("vbfVispt")
        #if not self.vbfVispt_branch and "vbfVispt" not in self.complained:
        if not self.vbfVispt_branch and "vbfVispt":
            warnings.warn( "MMMTree: Expected branch vbfVispt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt")
        else:
            self.vbfVispt_branch.SetAddress(<void*>&self.vbfVispt_value)

        #print "making vbfVispt_JetEnDown"
        self.vbfVispt_JetEnDown_branch = the_tree.GetBranch("vbfVispt_JetEnDown")
        #if not self.vbfVispt_JetEnDown_branch and "vbfVispt_JetEnDown" not in self.complained:
        if not self.vbfVispt_JetEnDown_branch and "vbfVispt_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfVispt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt_JetEnDown")
        else:
            self.vbfVispt_JetEnDown_branch.SetAddress(<void*>&self.vbfVispt_JetEnDown_value)

        #print "making vbfVispt_JetEnUp"
        self.vbfVispt_JetEnUp_branch = the_tree.GetBranch("vbfVispt_JetEnUp")
        #if not self.vbfVispt_JetEnUp_branch and "vbfVispt_JetEnUp" not in self.complained:
        if not self.vbfVispt_JetEnUp_branch and "vbfVispt_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfVispt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt_JetEnUp")
        else:
            self.vbfVispt_JetEnUp_branch.SetAddress(<void*>&self.vbfVispt_JetEnUp_value)

        #print "making vbfdijetpt"
        self.vbfdijetpt_branch = the_tree.GetBranch("vbfdijetpt")
        #if not self.vbfdijetpt_branch and "vbfdijetpt" not in self.complained:
        if not self.vbfdijetpt_branch and "vbfdijetpt":
            warnings.warn( "MMMTree: Expected branch vbfdijetpt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt")
        else:
            self.vbfdijetpt_branch.SetAddress(<void*>&self.vbfdijetpt_value)

        #print "making vbfdijetpt_JetEnDown"
        self.vbfdijetpt_JetEnDown_branch = the_tree.GetBranch("vbfdijetpt_JetEnDown")
        #if not self.vbfdijetpt_JetEnDown_branch and "vbfdijetpt_JetEnDown" not in self.complained:
        if not self.vbfdijetpt_JetEnDown_branch and "vbfdijetpt_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfdijetpt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt_JetEnDown")
        else:
            self.vbfdijetpt_JetEnDown_branch.SetAddress(<void*>&self.vbfdijetpt_JetEnDown_value)

        #print "making vbfdijetpt_JetEnUp"
        self.vbfdijetpt_JetEnUp_branch = the_tree.GetBranch("vbfdijetpt_JetEnUp")
        #if not self.vbfdijetpt_JetEnUp_branch and "vbfdijetpt_JetEnUp" not in self.complained:
        if not self.vbfdijetpt_JetEnUp_branch and "vbfdijetpt_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfdijetpt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt_JetEnUp")
        else:
            self.vbfdijetpt_JetEnUp_branch.SetAddress(<void*>&self.vbfdijetpt_JetEnUp_value)

        #print "making vbfditaupt"
        self.vbfditaupt_branch = the_tree.GetBranch("vbfditaupt")
        #if not self.vbfditaupt_branch and "vbfditaupt" not in self.complained:
        if not self.vbfditaupt_branch and "vbfditaupt":
            warnings.warn( "MMMTree: Expected branch vbfditaupt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt")
        else:
            self.vbfditaupt_branch.SetAddress(<void*>&self.vbfditaupt_value)

        #print "making vbfditaupt_JetEnDown"
        self.vbfditaupt_JetEnDown_branch = the_tree.GetBranch("vbfditaupt_JetEnDown")
        #if not self.vbfditaupt_JetEnDown_branch and "vbfditaupt_JetEnDown" not in self.complained:
        if not self.vbfditaupt_JetEnDown_branch and "vbfditaupt_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfditaupt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt_JetEnDown")
        else:
            self.vbfditaupt_JetEnDown_branch.SetAddress(<void*>&self.vbfditaupt_JetEnDown_value)

        #print "making vbfditaupt_JetEnUp"
        self.vbfditaupt_JetEnUp_branch = the_tree.GetBranch("vbfditaupt_JetEnUp")
        #if not self.vbfditaupt_JetEnUp_branch and "vbfditaupt_JetEnUp" not in self.complained:
        if not self.vbfditaupt_JetEnUp_branch and "vbfditaupt_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfditaupt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt_JetEnUp")
        else:
            self.vbfditaupt_JetEnUp_branch.SetAddress(<void*>&self.vbfditaupt_JetEnUp_value)

        #print "making vbfj1eta"
        self.vbfj1eta_branch = the_tree.GetBranch("vbfj1eta")
        #if not self.vbfj1eta_branch and "vbfj1eta" not in self.complained:
        if not self.vbfj1eta_branch and "vbfj1eta":
            warnings.warn( "MMMTree: Expected branch vbfj1eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta")
        else:
            self.vbfj1eta_branch.SetAddress(<void*>&self.vbfj1eta_value)

        #print "making vbfj1eta_JetEnDown"
        self.vbfj1eta_JetEnDown_branch = the_tree.GetBranch("vbfj1eta_JetEnDown")
        #if not self.vbfj1eta_JetEnDown_branch and "vbfj1eta_JetEnDown" not in self.complained:
        if not self.vbfj1eta_JetEnDown_branch and "vbfj1eta_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfj1eta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta_JetEnDown")
        else:
            self.vbfj1eta_JetEnDown_branch.SetAddress(<void*>&self.vbfj1eta_JetEnDown_value)

        #print "making vbfj1eta_JetEnUp"
        self.vbfj1eta_JetEnUp_branch = the_tree.GetBranch("vbfj1eta_JetEnUp")
        #if not self.vbfj1eta_JetEnUp_branch and "vbfj1eta_JetEnUp" not in self.complained:
        if not self.vbfj1eta_JetEnUp_branch and "vbfj1eta_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfj1eta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta_JetEnUp")
        else:
            self.vbfj1eta_JetEnUp_branch.SetAddress(<void*>&self.vbfj1eta_JetEnUp_value)

        #print "making vbfj1pt"
        self.vbfj1pt_branch = the_tree.GetBranch("vbfj1pt")
        #if not self.vbfj1pt_branch and "vbfj1pt" not in self.complained:
        if not self.vbfj1pt_branch and "vbfj1pt":
            warnings.warn( "MMMTree: Expected branch vbfj1pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt")
        else:
            self.vbfj1pt_branch.SetAddress(<void*>&self.vbfj1pt_value)

        #print "making vbfj1pt_JetEnDown"
        self.vbfj1pt_JetEnDown_branch = the_tree.GetBranch("vbfj1pt_JetEnDown")
        #if not self.vbfj1pt_JetEnDown_branch and "vbfj1pt_JetEnDown" not in self.complained:
        if not self.vbfj1pt_JetEnDown_branch and "vbfj1pt_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfj1pt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt_JetEnDown")
        else:
            self.vbfj1pt_JetEnDown_branch.SetAddress(<void*>&self.vbfj1pt_JetEnDown_value)

        #print "making vbfj1pt_JetEnUp"
        self.vbfj1pt_JetEnUp_branch = the_tree.GetBranch("vbfj1pt_JetEnUp")
        #if not self.vbfj1pt_JetEnUp_branch and "vbfj1pt_JetEnUp" not in self.complained:
        if not self.vbfj1pt_JetEnUp_branch and "vbfj1pt_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfj1pt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt_JetEnUp")
        else:
            self.vbfj1pt_JetEnUp_branch.SetAddress(<void*>&self.vbfj1pt_JetEnUp_value)

        #print "making vbfj2eta"
        self.vbfj2eta_branch = the_tree.GetBranch("vbfj2eta")
        #if not self.vbfj2eta_branch and "vbfj2eta" not in self.complained:
        if not self.vbfj2eta_branch and "vbfj2eta":
            warnings.warn( "MMMTree: Expected branch vbfj2eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta")
        else:
            self.vbfj2eta_branch.SetAddress(<void*>&self.vbfj2eta_value)

        #print "making vbfj2eta_JetEnDown"
        self.vbfj2eta_JetEnDown_branch = the_tree.GetBranch("vbfj2eta_JetEnDown")
        #if not self.vbfj2eta_JetEnDown_branch and "vbfj2eta_JetEnDown" not in self.complained:
        if not self.vbfj2eta_JetEnDown_branch and "vbfj2eta_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfj2eta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta_JetEnDown")
        else:
            self.vbfj2eta_JetEnDown_branch.SetAddress(<void*>&self.vbfj2eta_JetEnDown_value)

        #print "making vbfj2eta_JetEnUp"
        self.vbfj2eta_JetEnUp_branch = the_tree.GetBranch("vbfj2eta_JetEnUp")
        #if not self.vbfj2eta_JetEnUp_branch and "vbfj2eta_JetEnUp" not in self.complained:
        if not self.vbfj2eta_JetEnUp_branch and "vbfj2eta_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfj2eta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta_JetEnUp")
        else:
            self.vbfj2eta_JetEnUp_branch.SetAddress(<void*>&self.vbfj2eta_JetEnUp_value)

        #print "making vbfj2pt"
        self.vbfj2pt_branch = the_tree.GetBranch("vbfj2pt")
        #if not self.vbfj2pt_branch and "vbfj2pt" not in self.complained:
        if not self.vbfj2pt_branch and "vbfj2pt":
            warnings.warn( "MMMTree: Expected branch vbfj2pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt")
        else:
            self.vbfj2pt_branch.SetAddress(<void*>&self.vbfj2pt_value)

        #print "making vbfj2pt_JetEnDown"
        self.vbfj2pt_JetEnDown_branch = the_tree.GetBranch("vbfj2pt_JetEnDown")
        #if not self.vbfj2pt_JetEnDown_branch and "vbfj2pt_JetEnDown" not in self.complained:
        if not self.vbfj2pt_JetEnDown_branch and "vbfj2pt_JetEnDown":
            warnings.warn( "MMMTree: Expected branch vbfj2pt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt_JetEnDown")
        else:
            self.vbfj2pt_JetEnDown_branch.SetAddress(<void*>&self.vbfj2pt_JetEnDown_value)

        #print "making vbfj2pt_JetEnUp"
        self.vbfj2pt_JetEnUp_branch = the_tree.GetBranch("vbfj2pt_JetEnUp")
        #if not self.vbfj2pt_JetEnUp_branch and "vbfj2pt_JetEnUp" not in self.complained:
        if not self.vbfj2pt_JetEnUp_branch and "vbfj2pt_JetEnUp":
            warnings.warn( "MMMTree: Expected branch vbfj2pt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt_JetEnUp")
        else:
            self.vbfj2pt_JetEnUp_branch.SetAddress(<void*>&self.vbfj2pt_JetEnUp_value)

        #print "making idx"
        self.idx_branch = the_tree.GetBranch("idx")
        #if not self.idx_branch and "idx" not in self.complained:
        if not self.idx_branch and "idx":
            warnings.warn( "MMMTree: Expected branch idx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("idx")
        else:
            self.idx_branch.SetAddress(<void*>&self.idx_value)


    # Iterating over the tree
    def __iter__(self):
        self.ientry = 0
        while self.ientry < self.tree.GetEntries():
            self.load_entry(self.ientry)
            yield self
            self.ientry += 1

    # Iterate over rows which pass the filter
    def where(self, filter):
        print "where"
        cdef TTreeFormula* formula = new TTreeFormula(
            "cyiter", filter, self.tree)
        self.ientry = 0
        cdef TTree* currentTree = self.tree.GetTree()
        while self.ientry < self.tree.GetEntries():
            self.tree.LoadTree(self.ientry)
            if currentTree != self.tree.GetTree():
                currentTree = self.tree.GetTree()
                formula.SetTree(currentTree)
                formula.UpdateFormulaLeaves()
            if formula.EvalInstance(0, NULL):
                yield self
            self.ientry += 1
        del formula

    # Getting/setting the Tree entry number
    property entry:
        def __get__(self):
            return self.ientry
        def __set__(self, int i):
            print i
            self.ientry = i
            self.load_entry(i)

    # Access to the current branch values

    property EmbPtWeight:
        def __get__(self):
            self.EmbPtWeight_branch.GetEntry(self.localentry, 0)
            return self.EmbPtWeight_value

    property Eta:
        def __get__(self):
            self.Eta_branch.GetEntry(self.localentry, 0)
            return self.Eta_value

    property GenWeight:
        def __get__(self):
            self.GenWeight_branch.GetEntry(self.localentry, 0)
            return self.GenWeight_value

    property Ht:
        def __get__(self):
            self.Ht_branch.GetEntry(self.localentry, 0)
            return self.Ht_value

    property LT:
        def __get__(self):
            self.LT_branch.GetEntry(self.localentry, 0)
            return self.LT_value

    property Mass:
        def __get__(self):
            self.Mass_branch.GetEntry(self.localentry, 0)
            return self.Mass_value

    property MassError:
        def __get__(self):
            self.MassError_branch.GetEntry(self.localentry, 0)
            return self.MassError_value

    property MassErrord1:
        def __get__(self):
            self.MassErrord1_branch.GetEntry(self.localentry, 0)
            return self.MassErrord1_value

    property MassErrord2:
        def __get__(self):
            self.MassErrord2_branch.GetEntry(self.localentry, 0)
            return self.MassErrord2_value

    property MassErrord3:
        def __get__(self):
            self.MassErrord3_branch.GetEntry(self.localentry, 0)
            return self.MassErrord3_value

    property MassErrord4:
        def __get__(self):
            self.MassErrord4_branch.GetEntry(self.localentry, 0)
            return self.MassErrord4_value

    property Mt:
        def __get__(self):
            self.Mt_branch.GetEntry(self.localentry, 0)
            return self.Mt_value

    property NUP:
        def __get__(self):
            self.NUP_branch.GetEntry(self.localentry, 0)
            return self.NUP_value

    property Phi:
        def __get__(self):
            self.Phi_branch.GetEntry(self.localentry, 0)
            return self.Phi_value

    property Pt:
        def __get__(self):
            self.Pt_branch.GetEntry(self.localentry, 0)
            return self.Pt_value

    property bjetCISVVeto20Loose:
        def __get__(self):
            self.bjetCISVVeto20Loose_branch.GetEntry(self.localentry, 0)
            return self.bjetCISVVeto20Loose_value

    property bjetCISVVeto20Medium:
        def __get__(self):
            self.bjetCISVVeto20Medium_branch.GetEntry(self.localentry, 0)
            return self.bjetCISVVeto20Medium_value

    property bjetCISVVeto20Tight:
        def __get__(self):
            self.bjetCISVVeto20Tight_branch.GetEntry(self.localentry, 0)
            return self.bjetCISVVeto20Tight_value

    property bjetCISVVeto30Loose:
        def __get__(self):
            self.bjetCISVVeto30Loose_branch.GetEntry(self.localentry, 0)
            return self.bjetCISVVeto30Loose_value

    property bjetCISVVeto30Medium:
        def __get__(self):
            self.bjetCISVVeto30Medium_branch.GetEntry(self.localentry, 0)
            return self.bjetCISVVeto30Medium_value

    property bjetCISVVeto30Tight:
        def __get__(self):
            self.bjetCISVVeto30Tight_branch.GetEntry(self.localentry, 0)
            return self.bjetCISVVeto30Tight_value

    property charge:
        def __get__(self):
            self.charge_branch.GetEntry(self.localentry, 0)
            return self.charge_value

    property doubleEGroup:
        def __get__(self):
            self.doubleEGroup_branch.GetEntry(self.localentry, 0)
            return self.doubleEGroup_value

    property doubleEPass:
        def __get__(self):
            self.doubleEPass_branch.GetEntry(self.localentry, 0)
            return self.doubleEPass_value

    property doubleEPrescale:
        def __get__(self):
            self.doubleEPrescale_branch.GetEntry(self.localentry, 0)
            return self.doubleEPrescale_value

    property doubleESingleMuGroup:
        def __get__(self):
            self.doubleESingleMuGroup_branch.GetEntry(self.localentry, 0)
            return self.doubleESingleMuGroup_value

    property doubleESingleMuPass:
        def __get__(self):
            self.doubleESingleMuPass_branch.GetEntry(self.localentry, 0)
            return self.doubleESingleMuPass_value

    property doubleESingleMuPrescale:
        def __get__(self):
            self.doubleESingleMuPrescale_branch.GetEntry(self.localentry, 0)
            return self.doubleESingleMuPrescale_value

    property doubleMuGroup:
        def __get__(self):
            self.doubleMuGroup_branch.GetEntry(self.localentry, 0)
            return self.doubleMuGroup_value

    property doubleMuPass:
        def __get__(self):
            self.doubleMuPass_branch.GetEntry(self.localentry, 0)
            return self.doubleMuPass_value

    property doubleMuPrescale:
        def __get__(self):
            self.doubleMuPrescale_branch.GetEntry(self.localentry, 0)
            return self.doubleMuPrescale_value

    property doubleMuSingleEGroup:
        def __get__(self):
            self.doubleMuSingleEGroup_branch.GetEntry(self.localentry, 0)
            return self.doubleMuSingleEGroup_value

    property doubleMuSingleEPass:
        def __get__(self):
            self.doubleMuSingleEPass_branch.GetEntry(self.localentry, 0)
            return self.doubleMuSingleEPass_value

    property doubleMuSingleEPrescale:
        def __get__(self):
            self.doubleMuSingleEPrescale_branch.GetEntry(self.localentry, 0)
            return self.doubleMuSingleEPrescale_value

    property doubleTau35Group:
        def __get__(self):
            self.doubleTau35Group_branch.GetEntry(self.localentry, 0)
            return self.doubleTau35Group_value

    property doubleTau35Pass:
        def __get__(self):
            self.doubleTau35Pass_branch.GetEntry(self.localentry, 0)
            return self.doubleTau35Pass_value

    property doubleTau35Prescale:
        def __get__(self):
            self.doubleTau35Prescale_branch.GetEntry(self.localentry, 0)
            return self.doubleTau35Prescale_value

    property doubleTau40Group:
        def __get__(self):
            self.doubleTau40Group_branch.GetEntry(self.localentry, 0)
            return self.doubleTau40Group_value

    property doubleTau40Pass:
        def __get__(self):
            self.doubleTau40Pass_branch.GetEntry(self.localentry, 0)
            return self.doubleTau40Pass_value

    property doubleTau40Prescale:
        def __get__(self):
            self.doubleTau40Prescale_branch.GetEntry(self.localentry, 0)
            return self.doubleTau40Prescale_value

    property eVetoMVAIso:
        def __get__(self):
            self.eVetoMVAIso_branch.GetEntry(self.localentry, 0)
            return self.eVetoMVAIso_value

    property eVetoMVAIsoVtx:
        def __get__(self):
            self.eVetoMVAIsoVtx_branch.GetEntry(self.localentry, 0)
            return self.eVetoMVAIsoVtx_value

    property evt:
        def __get__(self):
            self.evt_branch.GetEntry(self.localentry, 0)
            return self.evt_value

    property genHTT:
        def __get__(self):
            self.genHTT_branch.GetEntry(self.localentry, 0)
            return self.genHTT_value

    property isGtautau:
        def __get__(self):
            self.isGtautau_branch.GetEntry(self.localentry, 0)
            return self.isGtautau_value

    property isWmunu:
        def __get__(self):
            self.isWmunu_branch.GetEntry(self.localentry, 0)
            return self.isWmunu_value

    property isWtaunu:
        def __get__(self):
            self.isWtaunu_branch.GetEntry(self.localentry, 0)
            return self.isWtaunu_value

    property isZee:
        def __get__(self):
            self.isZee_branch.GetEntry(self.localentry, 0)
            return self.isZee_value

    property isZmumu:
        def __get__(self):
            self.isZmumu_branch.GetEntry(self.localentry, 0)
            return self.isZmumu_value

    property isZtautau:
        def __get__(self):
            self.isZtautau_branch.GetEntry(self.localentry, 0)
            return self.isZtautau_value

    property isdata:
        def __get__(self):
            self.isdata_branch.GetEntry(self.localentry, 0)
            return self.isdata_value

    property jetVeto20:
        def __get__(self):
            self.jetVeto20_branch.GetEntry(self.localentry, 0)
            return self.jetVeto20_value

    property jetVeto20_DR05:
        def __get__(self):
            self.jetVeto20_DR05_branch.GetEntry(self.localentry, 0)
            return self.jetVeto20_DR05_value

    property jetVeto30:
        def __get__(self):
            self.jetVeto30_branch.GetEntry(self.localentry, 0)
            return self.jetVeto30_value

    property jetVeto30Eta3:
        def __get__(self):
            self.jetVeto30Eta3_branch.GetEntry(self.localentry, 0)
            return self.jetVeto30Eta3_value

    property jetVeto30Eta3_JetEnDown:
        def __get__(self):
            self.jetVeto30Eta3_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.jetVeto30Eta3_JetEnDown_value

    property jetVeto30Eta3_JetEnUp:
        def __get__(self):
            self.jetVeto30Eta3_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.jetVeto30Eta3_JetEnUp_value

    property jetVeto30_DR05:
        def __get__(self):
            self.jetVeto30_DR05_branch.GetEntry(self.localentry, 0)
            return self.jetVeto30_DR05_value

    property jetVeto30_JetEnDown:
        def __get__(self):
            self.jetVeto30_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.jetVeto30_JetEnDown_value

    property jetVeto30_JetEnUp:
        def __get__(self):
            self.jetVeto30_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.jetVeto30_JetEnUp_value

    property jetVeto40:
        def __get__(self):
            self.jetVeto40_branch.GetEntry(self.localentry, 0)
            return self.jetVeto40_value

    property jetVeto40_DR05:
        def __get__(self):
            self.jetVeto40_DR05_branch.GetEntry(self.localentry, 0)
            return self.jetVeto40_DR05_value

    property lumi:
        def __get__(self):
            self.lumi_branch.GetEntry(self.localentry, 0)
            return self.lumi_value

    property m1AbsEta:
        def __get__(self):
            self.m1AbsEta_branch.GetEntry(self.localentry, 0)
            return self.m1AbsEta_value

    property m1BestTrackType:
        def __get__(self):
            self.m1BestTrackType_branch.GetEntry(self.localentry, 0)
            return self.m1BestTrackType_value

    property m1Charge:
        def __get__(self):
            self.m1Charge_branch.GetEntry(self.localentry, 0)
            return self.m1Charge_value

    property m1ComesFromHiggs:
        def __get__(self):
            self.m1ComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.m1ComesFromHiggs_value

    property m1DPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.m1DPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_ElectronEnDown_value

    property m1DPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.m1DPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_ElectronEnUp_value

    property m1DPhiToPfMet_JetEnDown:
        def __get__(self):
            self.m1DPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_JetEnDown_value

    property m1DPhiToPfMet_JetEnUp:
        def __get__(self):
            self.m1DPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_JetEnUp_value

    property m1DPhiToPfMet_JetResDown:
        def __get__(self):
            self.m1DPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_JetResDown_value

    property m1DPhiToPfMet_JetResUp:
        def __get__(self):
            self.m1DPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_JetResUp_value

    property m1DPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.m1DPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_MuonEnDown_value

    property m1DPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.m1DPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_MuonEnUp_value

    property m1DPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.m1DPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_PhotonEnDown_value

    property m1DPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.m1DPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_PhotonEnUp_value

    property m1DPhiToPfMet_TauEnDown:
        def __get__(self):
            self.m1DPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_TauEnDown_value

    property m1DPhiToPfMet_TauEnUp:
        def __get__(self):
            self.m1DPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_TauEnUp_value

    property m1DPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.m1DPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_UnclusteredEnDown_value

    property m1DPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.m1DPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_UnclusteredEnUp_value

    property m1DPhiToPfMet_type1:
        def __get__(self):
            self.m1DPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.m1DPhiToPfMet_type1_value

    property m1EcalIsoDR03:
        def __get__(self):
            self.m1EcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m1EcalIsoDR03_value

    property m1EffectiveArea2011:
        def __get__(self):
            self.m1EffectiveArea2011_branch.GetEntry(self.localentry, 0)
            return self.m1EffectiveArea2011_value

    property m1EffectiveArea2012:
        def __get__(self):
            self.m1EffectiveArea2012_branch.GetEntry(self.localentry, 0)
            return self.m1EffectiveArea2012_value

    property m1Eta:
        def __get__(self):
            self.m1Eta_branch.GetEntry(self.localentry, 0)
            return self.m1Eta_value

    property m1Eta_MuonEnDown:
        def __get__(self):
            self.m1Eta_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1Eta_MuonEnDown_value

    property m1Eta_MuonEnUp:
        def __get__(self):
            self.m1Eta_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1Eta_MuonEnUp_value

    property m1GenCharge:
        def __get__(self):
            self.m1GenCharge_branch.GetEntry(self.localentry, 0)
            return self.m1GenCharge_value

    property m1GenEnergy:
        def __get__(self):
            self.m1GenEnergy_branch.GetEntry(self.localentry, 0)
            return self.m1GenEnergy_value

    property m1GenEta:
        def __get__(self):
            self.m1GenEta_branch.GetEntry(self.localentry, 0)
            return self.m1GenEta_value

    property m1GenMotherPdgId:
        def __get__(self):
            self.m1GenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.m1GenMotherPdgId_value

    property m1GenPdgId:
        def __get__(self):
            self.m1GenPdgId_branch.GetEntry(self.localentry, 0)
            return self.m1GenPdgId_value

    property m1GenPhi:
        def __get__(self):
            self.m1GenPhi_branch.GetEntry(self.localentry, 0)
            return self.m1GenPhi_value

    property m1GenPrompt:
        def __get__(self):
            self.m1GenPrompt_branch.GetEntry(self.localentry, 0)
            return self.m1GenPrompt_value

    property m1GenPromptTauDecay:
        def __get__(self):
            self.m1GenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.m1GenPromptTauDecay_value

    property m1GenPt:
        def __get__(self):
            self.m1GenPt_branch.GetEntry(self.localentry, 0)
            return self.m1GenPt_value

    property m1GenTauDecay:
        def __get__(self):
            self.m1GenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.m1GenTauDecay_value

    property m1GenVZ:
        def __get__(self):
            self.m1GenVZ_branch.GetEntry(self.localentry, 0)
            return self.m1GenVZ_value

    property m1GenVtxPVMatch:
        def __get__(self):
            self.m1GenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.m1GenVtxPVMatch_value

    property m1HcalIsoDR03:
        def __get__(self):
            self.m1HcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m1HcalIsoDR03_value

    property m1IP3D:
        def __get__(self):
            self.m1IP3D_branch.GetEntry(self.localentry, 0)
            return self.m1IP3D_value

    property m1IP3DErr:
        def __get__(self):
            self.m1IP3DErr_branch.GetEntry(self.localentry, 0)
            return self.m1IP3DErr_value

    property m1IsGlobal:
        def __get__(self):
            self.m1IsGlobal_branch.GetEntry(self.localentry, 0)
            return self.m1IsGlobal_value

    property m1IsPFMuon:
        def __get__(self):
            self.m1IsPFMuon_branch.GetEntry(self.localentry, 0)
            return self.m1IsPFMuon_value

    property m1IsTracker:
        def __get__(self):
            self.m1IsTracker_branch.GetEntry(self.localentry, 0)
            return self.m1IsTracker_value

    property m1JetArea:
        def __get__(self):
            self.m1JetArea_branch.GetEntry(self.localentry, 0)
            return self.m1JetArea_value

    property m1JetBtag:
        def __get__(self):
            self.m1JetBtag_branch.GetEntry(self.localentry, 0)
            return self.m1JetBtag_value

    property m1JetEtaEtaMoment:
        def __get__(self):
            self.m1JetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.m1JetEtaEtaMoment_value

    property m1JetEtaPhiMoment:
        def __get__(self):
            self.m1JetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.m1JetEtaPhiMoment_value

    property m1JetEtaPhiSpread:
        def __get__(self):
            self.m1JetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.m1JetEtaPhiSpread_value

    property m1JetPFCISVBtag:
        def __get__(self):
            self.m1JetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.m1JetPFCISVBtag_value

    property m1JetPartonFlavour:
        def __get__(self):
            self.m1JetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.m1JetPartonFlavour_value

    property m1JetPhiPhiMoment:
        def __get__(self):
            self.m1JetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.m1JetPhiPhiMoment_value

    property m1JetPt:
        def __get__(self):
            self.m1JetPt_branch.GetEntry(self.localentry, 0)
            return self.m1JetPt_value

    property m1LowestMll:
        def __get__(self):
            self.m1LowestMll_branch.GetEntry(self.localentry, 0)
            return self.m1LowestMll_value

    property m1Mass:
        def __get__(self):
            self.m1Mass_branch.GetEntry(self.localentry, 0)
            return self.m1Mass_value

    property m1MatchedStations:
        def __get__(self):
            self.m1MatchedStations_branch.GetEntry(self.localentry, 0)
            return self.m1MatchedStations_value

    property m1MatchesDoubleESingleMu:
        def __get__(self):
            self.m1MatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesDoubleESingleMu_value

    property m1MatchesDoubleMu:
        def __get__(self):
            self.m1MatchesDoubleMu_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesDoubleMu_value

    property m1MatchesDoubleMuSingleE:
        def __get__(self):
            self.m1MatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesDoubleMuSingleE_value

    property m1MatchesSingleESingleMu:
        def __get__(self):
            self.m1MatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleESingleMu_value

    property m1MatchesSingleMu:
        def __get__(self):
            self.m1MatchesSingleMu_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMu_value

    property m1MatchesSingleMuIso20:
        def __get__(self):
            self.m1MatchesSingleMuIso20_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMuIso20_value

    property m1MatchesSingleMuIsoTk20:
        def __get__(self):
            self.m1MatchesSingleMuIsoTk20_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMuIsoTk20_value

    property m1MatchesSingleMuSingleE:
        def __get__(self):
            self.m1MatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMuSingleE_value

    property m1MatchesSingleMu_leg1:
        def __get__(self):
            self.m1MatchesSingleMu_leg1_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMu_leg1_value

    property m1MatchesSingleMu_leg1_noiso:
        def __get__(self):
            self.m1MatchesSingleMu_leg1_noiso_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMu_leg1_noiso_value

    property m1MatchesSingleMu_leg2:
        def __get__(self):
            self.m1MatchesSingleMu_leg2_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMu_leg2_value

    property m1MatchesSingleMu_leg2_noiso:
        def __get__(self):
            self.m1MatchesSingleMu_leg2_noiso_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesSingleMu_leg2_noiso_value

    property m1MatchesTripleMu:
        def __get__(self):
            self.m1MatchesTripleMu_branch.GetEntry(self.localentry, 0)
            return self.m1MatchesTripleMu_value

    property m1MtToPfMet_ElectronEnDown:
        def __get__(self):
            self.m1MtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_ElectronEnDown_value

    property m1MtToPfMet_ElectronEnUp:
        def __get__(self):
            self.m1MtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_ElectronEnUp_value

    property m1MtToPfMet_JetEnDown:
        def __get__(self):
            self.m1MtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_JetEnDown_value

    property m1MtToPfMet_JetEnUp:
        def __get__(self):
            self.m1MtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_JetEnUp_value

    property m1MtToPfMet_JetResDown:
        def __get__(self):
            self.m1MtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_JetResDown_value

    property m1MtToPfMet_JetResUp:
        def __get__(self):
            self.m1MtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_JetResUp_value

    property m1MtToPfMet_MuonEnDown:
        def __get__(self):
            self.m1MtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_MuonEnDown_value

    property m1MtToPfMet_MuonEnUp:
        def __get__(self):
            self.m1MtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_MuonEnUp_value

    property m1MtToPfMet_PhotonEnDown:
        def __get__(self):
            self.m1MtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_PhotonEnDown_value

    property m1MtToPfMet_PhotonEnUp:
        def __get__(self):
            self.m1MtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_PhotonEnUp_value

    property m1MtToPfMet_Raw:
        def __get__(self):
            self.m1MtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_Raw_value

    property m1MtToPfMet_TauEnDown:
        def __get__(self):
            self.m1MtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_TauEnDown_value

    property m1MtToPfMet_TauEnUp:
        def __get__(self):
            self.m1MtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_TauEnUp_value

    property m1MtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.m1MtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_UnclusteredEnDown_value

    property m1MtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.m1MtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_UnclusteredEnUp_value

    property m1MtToPfMet_type1:
        def __get__(self):
            self.m1MtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.m1MtToPfMet_type1_value

    property m1MuonHits:
        def __get__(self):
            self.m1MuonHits_branch.GetEntry(self.localentry, 0)
            return self.m1MuonHits_value

    property m1NearestZMass:
        def __get__(self):
            self.m1NearestZMass_branch.GetEntry(self.localentry, 0)
            return self.m1NearestZMass_value

    property m1NormTrkChi2:
        def __get__(self):
            self.m1NormTrkChi2_branch.GetEntry(self.localentry, 0)
            return self.m1NormTrkChi2_value

    property m1PFChargedIso:
        def __get__(self):
            self.m1PFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.m1PFChargedIso_value

    property m1PFIDLoose:
        def __get__(self):
            self.m1PFIDLoose_branch.GetEntry(self.localentry, 0)
            return self.m1PFIDLoose_value

    property m1PFIDMedium:
        def __get__(self):
            self.m1PFIDMedium_branch.GetEntry(self.localentry, 0)
            return self.m1PFIDMedium_value

    property m1PFIDTight:
        def __get__(self):
            self.m1PFIDTight_branch.GetEntry(self.localentry, 0)
            return self.m1PFIDTight_value

    property m1PFNeutralIso:
        def __get__(self):
            self.m1PFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.m1PFNeutralIso_value

    property m1PFPUChargedIso:
        def __get__(self):
            self.m1PFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.m1PFPUChargedIso_value

    property m1PFPhotonIso:
        def __get__(self):
            self.m1PFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.m1PFPhotonIso_value

    property m1PVDXY:
        def __get__(self):
            self.m1PVDXY_branch.GetEntry(self.localentry, 0)
            return self.m1PVDXY_value

    property m1PVDZ:
        def __get__(self):
            self.m1PVDZ_branch.GetEntry(self.localentry, 0)
            return self.m1PVDZ_value

    property m1Phi:
        def __get__(self):
            self.m1Phi_branch.GetEntry(self.localentry, 0)
            return self.m1Phi_value

    property m1Phi_MuonEnDown:
        def __get__(self):
            self.m1Phi_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1Phi_MuonEnDown_value

    property m1Phi_MuonEnUp:
        def __get__(self):
            self.m1Phi_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1Phi_MuonEnUp_value

    property m1PixHits:
        def __get__(self):
            self.m1PixHits_branch.GetEntry(self.localentry, 0)
            return self.m1PixHits_value

    property m1Pt:
        def __get__(self):
            self.m1Pt_branch.GetEntry(self.localentry, 0)
            return self.m1Pt_value

    property m1Pt_MuonEnDown:
        def __get__(self):
            self.m1Pt_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1Pt_MuonEnDown_value

    property m1Pt_MuonEnUp:
        def __get__(self):
            self.m1Pt_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1Pt_MuonEnUp_value

    property m1Rank:
        def __get__(self):
            self.m1Rank_branch.GetEntry(self.localentry, 0)
            return self.m1Rank_value

    property m1RelPFIsoDBDefault:
        def __get__(self):
            self.m1RelPFIsoDBDefault_branch.GetEntry(self.localentry, 0)
            return self.m1RelPFIsoDBDefault_value

    property m1RelPFIsoRho:
        def __get__(self):
            self.m1RelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.m1RelPFIsoRho_value

    property m1Rho:
        def __get__(self):
            self.m1Rho_branch.GetEntry(self.localentry, 0)
            return self.m1Rho_value

    property m1SIP2D:
        def __get__(self):
            self.m1SIP2D_branch.GetEntry(self.localentry, 0)
            return self.m1SIP2D_value

    property m1SIP3D:
        def __get__(self):
            self.m1SIP3D_branch.GetEntry(self.localentry, 0)
            return self.m1SIP3D_value

    property m1TkLayersWithMeasurement:
        def __get__(self):
            self.m1TkLayersWithMeasurement_branch.GetEntry(self.localentry, 0)
            return self.m1TkLayersWithMeasurement_value

    property m1TrkIsoDR03:
        def __get__(self):
            self.m1TrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m1TrkIsoDR03_value

    property m1TypeCode:
        def __get__(self):
            self.m1TypeCode_branch.GetEntry(self.localentry, 0)
            return self.m1TypeCode_value

    property m1VZ:
        def __get__(self):
            self.m1VZ_branch.GetEntry(self.localentry, 0)
            return self.m1VZ_value

    property m1_m2_CosThetaStar:
        def __get__(self):
            self.m1_m2_CosThetaStar_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_CosThetaStar_value

    property m1_m2_DPhi:
        def __get__(self):
            self.m1_m2_DPhi_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_DPhi_value

    property m1_m2_DR:
        def __get__(self):
            self.m1_m2_DR_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_DR_value

    property m1_m2_Eta:
        def __get__(self):
            self.m1_m2_Eta_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_Eta_value

    property m1_m2_Mass:
        def __get__(self):
            self.m1_m2_Mass_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_Mass_value

    property m1_m2_Mt:
        def __get__(self):
            self.m1_m2_Mt_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_Mt_value

    property m1_m2_PZeta:
        def __get__(self):
            self.m1_m2_PZeta_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_PZeta_value

    property m1_m2_PZetaVis:
        def __get__(self):
            self.m1_m2_PZetaVis_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_PZetaVis_value

    property m1_m2_Phi:
        def __get__(self):
            self.m1_m2_Phi_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_Phi_value

    property m1_m2_Pt:
        def __get__(self):
            self.m1_m2_Pt_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_Pt_value

    property m1_m2_SS:
        def __get__(self):
            self.m1_m2_SS_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_SS_value

    property m1_m2_ToMETDPhi_Ty1:
        def __get__(self):
            self.m1_m2_ToMETDPhi_Ty1_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_ToMETDPhi_Ty1_value

    property m1_m2_collinearmass:
        def __get__(self):
            self.m1_m2_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_collinearmass_value

    property m1_m2_collinearmass_JetEnDown:
        def __get__(self):
            self.m1_m2_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_collinearmass_JetEnDown_value

    property m1_m2_collinearmass_JetEnUp:
        def __get__(self):
            self.m1_m2_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_collinearmass_JetEnUp_value

    property m1_m2_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.m1_m2_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_collinearmass_UnclusteredEnDown_value

    property m1_m2_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.m1_m2_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1_m2_collinearmass_UnclusteredEnUp_value

    property m1_m3_CosThetaStar:
        def __get__(self):
            self.m1_m3_CosThetaStar_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_CosThetaStar_value

    property m1_m3_DPhi:
        def __get__(self):
            self.m1_m3_DPhi_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_DPhi_value

    property m1_m3_DR:
        def __get__(self):
            self.m1_m3_DR_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_DR_value

    property m1_m3_Eta:
        def __get__(self):
            self.m1_m3_Eta_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_Eta_value

    property m1_m3_Mass:
        def __get__(self):
            self.m1_m3_Mass_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_Mass_value

    property m1_m3_Mt:
        def __get__(self):
            self.m1_m3_Mt_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_Mt_value

    property m1_m3_PZeta:
        def __get__(self):
            self.m1_m3_PZeta_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_PZeta_value

    property m1_m3_PZetaVis:
        def __get__(self):
            self.m1_m3_PZetaVis_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_PZetaVis_value

    property m1_m3_Phi:
        def __get__(self):
            self.m1_m3_Phi_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_Phi_value

    property m1_m3_Pt:
        def __get__(self):
            self.m1_m3_Pt_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_Pt_value

    property m1_m3_SS:
        def __get__(self):
            self.m1_m3_SS_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_SS_value

    property m1_m3_ToMETDPhi_Ty1:
        def __get__(self):
            self.m1_m3_ToMETDPhi_Ty1_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_ToMETDPhi_Ty1_value

    property m1_m3_collinearmass:
        def __get__(self):
            self.m1_m3_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_collinearmass_value

    property m1_m3_collinearmass_JetEnDown:
        def __get__(self):
            self.m1_m3_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_collinearmass_JetEnDown_value

    property m1_m3_collinearmass_JetEnUp:
        def __get__(self):
            self.m1_m3_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_collinearmass_JetEnUp_value

    property m1_m3_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.m1_m3_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_collinearmass_UnclusteredEnDown_value

    property m1_m3_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.m1_m3_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m1_m3_collinearmass_UnclusteredEnUp_value

    property m2AbsEta:
        def __get__(self):
            self.m2AbsEta_branch.GetEntry(self.localentry, 0)
            return self.m2AbsEta_value

    property m2BestTrackType:
        def __get__(self):
            self.m2BestTrackType_branch.GetEntry(self.localentry, 0)
            return self.m2BestTrackType_value

    property m2Charge:
        def __get__(self):
            self.m2Charge_branch.GetEntry(self.localentry, 0)
            return self.m2Charge_value

    property m2ComesFromHiggs:
        def __get__(self):
            self.m2ComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.m2ComesFromHiggs_value

    property m2DPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.m2DPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_ElectronEnDown_value

    property m2DPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.m2DPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_ElectronEnUp_value

    property m2DPhiToPfMet_JetEnDown:
        def __get__(self):
            self.m2DPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_JetEnDown_value

    property m2DPhiToPfMet_JetEnUp:
        def __get__(self):
            self.m2DPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_JetEnUp_value

    property m2DPhiToPfMet_JetResDown:
        def __get__(self):
            self.m2DPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_JetResDown_value

    property m2DPhiToPfMet_JetResUp:
        def __get__(self):
            self.m2DPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_JetResUp_value

    property m2DPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.m2DPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_MuonEnDown_value

    property m2DPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.m2DPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_MuonEnUp_value

    property m2DPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.m2DPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_PhotonEnDown_value

    property m2DPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.m2DPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_PhotonEnUp_value

    property m2DPhiToPfMet_TauEnDown:
        def __get__(self):
            self.m2DPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_TauEnDown_value

    property m2DPhiToPfMet_TauEnUp:
        def __get__(self):
            self.m2DPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_TauEnUp_value

    property m2DPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.m2DPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_UnclusteredEnDown_value

    property m2DPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.m2DPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_UnclusteredEnUp_value

    property m2DPhiToPfMet_type1:
        def __get__(self):
            self.m2DPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.m2DPhiToPfMet_type1_value

    property m2EcalIsoDR03:
        def __get__(self):
            self.m2EcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m2EcalIsoDR03_value

    property m2EffectiveArea2011:
        def __get__(self):
            self.m2EffectiveArea2011_branch.GetEntry(self.localentry, 0)
            return self.m2EffectiveArea2011_value

    property m2EffectiveArea2012:
        def __get__(self):
            self.m2EffectiveArea2012_branch.GetEntry(self.localentry, 0)
            return self.m2EffectiveArea2012_value

    property m2Eta:
        def __get__(self):
            self.m2Eta_branch.GetEntry(self.localentry, 0)
            return self.m2Eta_value

    property m2Eta_MuonEnDown:
        def __get__(self):
            self.m2Eta_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2Eta_MuonEnDown_value

    property m2Eta_MuonEnUp:
        def __get__(self):
            self.m2Eta_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2Eta_MuonEnUp_value

    property m2GenCharge:
        def __get__(self):
            self.m2GenCharge_branch.GetEntry(self.localentry, 0)
            return self.m2GenCharge_value

    property m2GenEnergy:
        def __get__(self):
            self.m2GenEnergy_branch.GetEntry(self.localentry, 0)
            return self.m2GenEnergy_value

    property m2GenEta:
        def __get__(self):
            self.m2GenEta_branch.GetEntry(self.localentry, 0)
            return self.m2GenEta_value

    property m2GenMotherPdgId:
        def __get__(self):
            self.m2GenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.m2GenMotherPdgId_value

    property m2GenPdgId:
        def __get__(self):
            self.m2GenPdgId_branch.GetEntry(self.localentry, 0)
            return self.m2GenPdgId_value

    property m2GenPhi:
        def __get__(self):
            self.m2GenPhi_branch.GetEntry(self.localentry, 0)
            return self.m2GenPhi_value

    property m2GenPrompt:
        def __get__(self):
            self.m2GenPrompt_branch.GetEntry(self.localentry, 0)
            return self.m2GenPrompt_value

    property m2GenPromptTauDecay:
        def __get__(self):
            self.m2GenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.m2GenPromptTauDecay_value

    property m2GenPt:
        def __get__(self):
            self.m2GenPt_branch.GetEntry(self.localentry, 0)
            return self.m2GenPt_value

    property m2GenTauDecay:
        def __get__(self):
            self.m2GenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.m2GenTauDecay_value

    property m2GenVZ:
        def __get__(self):
            self.m2GenVZ_branch.GetEntry(self.localentry, 0)
            return self.m2GenVZ_value

    property m2GenVtxPVMatch:
        def __get__(self):
            self.m2GenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.m2GenVtxPVMatch_value

    property m2HcalIsoDR03:
        def __get__(self):
            self.m2HcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m2HcalIsoDR03_value

    property m2IP3D:
        def __get__(self):
            self.m2IP3D_branch.GetEntry(self.localentry, 0)
            return self.m2IP3D_value

    property m2IP3DErr:
        def __get__(self):
            self.m2IP3DErr_branch.GetEntry(self.localentry, 0)
            return self.m2IP3DErr_value

    property m2IsGlobal:
        def __get__(self):
            self.m2IsGlobal_branch.GetEntry(self.localentry, 0)
            return self.m2IsGlobal_value

    property m2IsPFMuon:
        def __get__(self):
            self.m2IsPFMuon_branch.GetEntry(self.localentry, 0)
            return self.m2IsPFMuon_value

    property m2IsTracker:
        def __get__(self):
            self.m2IsTracker_branch.GetEntry(self.localentry, 0)
            return self.m2IsTracker_value

    property m2JetArea:
        def __get__(self):
            self.m2JetArea_branch.GetEntry(self.localentry, 0)
            return self.m2JetArea_value

    property m2JetBtag:
        def __get__(self):
            self.m2JetBtag_branch.GetEntry(self.localentry, 0)
            return self.m2JetBtag_value

    property m2JetEtaEtaMoment:
        def __get__(self):
            self.m2JetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.m2JetEtaEtaMoment_value

    property m2JetEtaPhiMoment:
        def __get__(self):
            self.m2JetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.m2JetEtaPhiMoment_value

    property m2JetEtaPhiSpread:
        def __get__(self):
            self.m2JetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.m2JetEtaPhiSpread_value

    property m2JetPFCISVBtag:
        def __get__(self):
            self.m2JetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.m2JetPFCISVBtag_value

    property m2JetPartonFlavour:
        def __get__(self):
            self.m2JetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.m2JetPartonFlavour_value

    property m2JetPhiPhiMoment:
        def __get__(self):
            self.m2JetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.m2JetPhiPhiMoment_value

    property m2JetPt:
        def __get__(self):
            self.m2JetPt_branch.GetEntry(self.localentry, 0)
            return self.m2JetPt_value

    property m2LowestMll:
        def __get__(self):
            self.m2LowestMll_branch.GetEntry(self.localentry, 0)
            return self.m2LowestMll_value

    property m2Mass:
        def __get__(self):
            self.m2Mass_branch.GetEntry(self.localentry, 0)
            return self.m2Mass_value

    property m2MatchedStations:
        def __get__(self):
            self.m2MatchedStations_branch.GetEntry(self.localentry, 0)
            return self.m2MatchedStations_value

    property m2MatchesDoubleESingleMu:
        def __get__(self):
            self.m2MatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesDoubleESingleMu_value

    property m2MatchesDoubleMu:
        def __get__(self):
            self.m2MatchesDoubleMu_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesDoubleMu_value

    property m2MatchesDoubleMuSingleE:
        def __get__(self):
            self.m2MatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesDoubleMuSingleE_value

    property m2MatchesSingleESingleMu:
        def __get__(self):
            self.m2MatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleESingleMu_value

    property m2MatchesSingleMu:
        def __get__(self):
            self.m2MatchesSingleMu_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMu_value

    property m2MatchesSingleMuIso20:
        def __get__(self):
            self.m2MatchesSingleMuIso20_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMuIso20_value

    property m2MatchesSingleMuIsoTk20:
        def __get__(self):
            self.m2MatchesSingleMuIsoTk20_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMuIsoTk20_value

    property m2MatchesSingleMuSingleE:
        def __get__(self):
            self.m2MatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMuSingleE_value

    property m2MatchesSingleMu_leg1:
        def __get__(self):
            self.m2MatchesSingleMu_leg1_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMu_leg1_value

    property m2MatchesSingleMu_leg1_noiso:
        def __get__(self):
            self.m2MatchesSingleMu_leg1_noiso_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMu_leg1_noiso_value

    property m2MatchesSingleMu_leg2:
        def __get__(self):
            self.m2MatchesSingleMu_leg2_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMu_leg2_value

    property m2MatchesSingleMu_leg2_noiso:
        def __get__(self):
            self.m2MatchesSingleMu_leg2_noiso_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesSingleMu_leg2_noiso_value

    property m2MatchesTripleMu:
        def __get__(self):
            self.m2MatchesTripleMu_branch.GetEntry(self.localentry, 0)
            return self.m2MatchesTripleMu_value

    property m2MtToPfMet_ElectronEnDown:
        def __get__(self):
            self.m2MtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_ElectronEnDown_value

    property m2MtToPfMet_ElectronEnUp:
        def __get__(self):
            self.m2MtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_ElectronEnUp_value

    property m2MtToPfMet_JetEnDown:
        def __get__(self):
            self.m2MtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_JetEnDown_value

    property m2MtToPfMet_JetEnUp:
        def __get__(self):
            self.m2MtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_JetEnUp_value

    property m2MtToPfMet_JetResDown:
        def __get__(self):
            self.m2MtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_JetResDown_value

    property m2MtToPfMet_JetResUp:
        def __get__(self):
            self.m2MtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_JetResUp_value

    property m2MtToPfMet_MuonEnDown:
        def __get__(self):
            self.m2MtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_MuonEnDown_value

    property m2MtToPfMet_MuonEnUp:
        def __get__(self):
            self.m2MtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_MuonEnUp_value

    property m2MtToPfMet_PhotonEnDown:
        def __get__(self):
            self.m2MtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_PhotonEnDown_value

    property m2MtToPfMet_PhotonEnUp:
        def __get__(self):
            self.m2MtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_PhotonEnUp_value

    property m2MtToPfMet_Raw:
        def __get__(self):
            self.m2MtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_Raw_value

    property m2MtToPfMet_TauEnDown:
        def __get__(self):
            self.m2MtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_TauEnDown_value

    property m2MtToPfMet_TauEnUp:
        def __get__(self):
            self.m2MtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_TauEnUp_value

    property m2MtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.m2MtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_UnclusteredEnDown_value

    property m2MtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.m2MtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_UnclusteredEnUp_value

    property m2MtToPfMet_type1:
        def __get__(self):
            self.m2MtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.m2MtToPfMet_type1_value

    property m2MuonHits:
        def __get__(self):
            self.m2MuonHits_branch.GetEntry(self.localentry, 0)
            return self.m2MuonHits_value

    property m2NearestZMass:
        def __get__(self):
            self.m2NearestZMass_branch.GetEntry(self.localentry, 0)
            return self.m2NearestZMass_value

    property m2NormTrkChi2:
        def __get__(self):
            self.m2NormTrkChi2_branch.GetEntry(self.localentry, 0)
            return self.m2NormTrkChi2_value

    property m2PFChargedIso:
        def __get__(self):
            self.m2PFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.m2PFChargedIso_value

    property m2PFIDLoose:
        def __get__(self):
            self.m2PFIDLoose_branch.GetEntry(self.localentry, 0)
            return self.m2PFIDLoose_value

    property m2PFIDMedium:
        def __get__(self):
            self.m2PFIDMedium_branch.GetEntry(self.localentry, 0)
            return self.m2PFIDMedium_value

    property m2PFIDTight:
        def __get__(self):
            self.m2PFIDTight_branch.GetEntry(self.localentry, 0)
            return self.m2PFIDTight_value

    property m2PFNeutralIso:
        def __get__(self):
            self.m2PFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.m2PFNeutralIso_value

    property m2PFPUChargedIso:
        def __get__(self):
            self.m2PFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.m2PFPUChargedIso_value

    property m2PFPhotonIso:
        def __get__(self):
            self.m2PFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.m2PFPhotonIso_value

    property m2PVDXY:
        def __get__(self):
            self.m2PVDXY_branch.GetEntry(self.localentry, 0)
            return self.m2PVDXY_value

    property m2PVDZ:
        def __get__(self):
            self.m2PVDZ_branch.GetEntry(self.localentry, 0)
            return self.m2PVDZ_value

    property m2Phi:
        def __get__(self):
            self.m2Phi_branch.GetEntry(self.localentry, 0)
            return self.m2Phi_value

    property m2Phi_MuonEnDown:
        def __get__(self):
            self.m2Phi_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2Phi_MuonEnDown_value

    property m2Phi_MuonEnUp:
        def __get__(self):
            self.m2Phi_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2Phi_MuonEnUp_value

    property m2PixHits:
        def __get__(self):
            self.m2PixHits_branch.GetEntry(self.localentry, 0)
            return self.m2PixHits_value

    property m2Pt:
        def __get__(self):
            self.m2Pt_branch.GetEntry(self.localentry, 0)
            return self.m2Pt_value

    property m2Pt_MuonEnDown:
        def __get__(self):
            self.m2Pt_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2Pt_MuonEnDown_value

    property m2Pt_MuonEnUp:
        def __get__(self):
            self.m2Pt_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2Pt_MuonEnUp_value

    property m2Rank:
        def __get__(self):
            self.m2Rank_branch.GetEntry(self.localentry, 0)
            return self.m2Rank_value

    property m2RelPFIsoDBDefault:
        def __get__(self):
            self.m2RelPFIsoDBDefault_branch.GetEntry(self.localentry, 0)
            return self.m2RelPFIsoDBDefault_value

    property m2RelPFIsoRho:
        def __get__(self):
            self.m2RelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.m2RelPFIsoRho_value

    property m2Rho:
        def __get__(self):
            self.m2Rho_branch.GetEntry(self.localentry, 0)
            return self.m2Rho_value

    property m2SIP2D:
        def __get__(self):
            self.m2SIP2D_branch.GetEntry(self.localentry, 0)
            return self.m2SIP2D_value

    property m2SIP3D:
        def __get__(self):
            self.m2SIP3D_branch.GetEntry(self.localentry, 0)
            return self.m2SIP3D_value

    property m2TkLayersWithMeasurement:
        def __get__(self):
            self.m2TkLayersWithMeasurement_branch.GetEntry(self.localentry, 0)
            return self.m2TkLayersWithMeasurement_value

    property m2TrkIsoDR03:
        def __get__(self):
            self.m2TrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m2TrkIsoDR03_value

    property m2TypeCode:
        def __get__(self):
            self.m2TypeCode_branch.GetEntry(self.localentry, 0)
            return self.m2TypeCode_value

    property m2VZ:
        def __get__(self):
            self.m2VZ_branch.GetEntry(self.localentry, 0)
            return self.m2VZ_value

    property m2_m1_collinearmass:
        def __get__(self):
            self.m2_m1_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.m2_m1_collinearmass_value

    property m2_m1_collinearmass_JetEnDown:
        def __get__(self):
            self.m2_m1_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2_m1_collinearmass_JetEnDown_value

    property m2_m1_collinearmass_JetEnUp:
        def __get__(self):
            self.m2_m1_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2_m1_collinearmass_JetEnUp_value

    property m2_m1_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.m2_m1_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2_m1_collinearmass_UnclusteredEnDown_value

    property m2_m1_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.m2_m1_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2_m1_collinearmass_UnclusteredEnUp_value

    property m2_m3_CosThetaStar:
        def __get__(self):
            self.m2_m3_CosThetaStar_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_CosThetaStar_value

    property m2_m3_DPhi:
        def __get__(self):
            self.m2_m3_DPhi_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_DPhi_value

    property m2_m3_DR:
        def __get__(self):
            self.m2_m3_DR_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_DR_value

    property m2_m3_Eta:
        def __get__(self):
            self.m2_m3_Eta_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_Eta_value

    property m2_m3_Mass:
        def __get__(self):
            self.m2_m3_Mass_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_Mass_value

    property m2_m3_Mt:
        def __get__(self):
            self.m2_m3_Mt_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_Mt_value

    property m2_m3_PZeta:
        def __get__(self):
            self.m2_m3_PZeta_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_PZeta_value

    property m2_m3_PZetaVis:
        def __get__(self):
            self.m2_m3_PZetaVis_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_PZetaVis_value

    property m2_m3_Phi:
        def __get__(self):
            self.m2_m3_Phi_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_Phi_value

    property m2_m3_Pt:
        def __get__(self):
            self.m2_m3_Pt_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_Pt_value

    property m2_m3_SS:
        def __get__(self):
            self.m2_m3_SS_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_SS_value

    property m2_m3_ToMETDPhi_Ty1:
        def __get__(self):
            self.m2_m3_ToMETDPhi_Ty1_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_ToMETDPhi_Ty1_value

    property m2_m3_collinearmass:
        def __get__(self):
            self.m2_m3_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_collinearmass_value

    property m2_m3_collinearmass_JetEnDown:
        def __get__(self):
            self.m2_m3_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_collinearmass_JetEnDown_value

    property m2_m3_collinearmass_JetEnUp:
        def __get__(self):
            self.m2_m3_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_collinearmass_JetEnUp_value

    property m2_m3_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.m2_m3_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_collinearmass_UnclusteredEnDown_value

    property m2_m3_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.m2_m3_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m2_m3_collinearmass_UnclusteredEnUp_value

    property m3AbsEta:
        def __get__(self):
            self.m3AbsEta_branch.GetEntry(self.localentry, 0)
            return self.m3AbsEta_value

    property m3BestTrackType:
        def __get__(self):
            self.m3BestTrackType_branch.GetEntry(self.localentry, 0)
            return self.m3BestTrackType_value

    property m3Charge:
        def __get__(self):
            self.m3Charge_branch.GetEntry(self.localentry, 0)
            return self.m3Charge_value

    property m3ComesFromHiggs:
        def __get__(self):
            self.m3ComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.m3ComesFromHiggs_value

    property m3DPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.m3DPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_ElectronEnDown_value

    property m3DPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.m3DPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_ElectronEnUp_value

    property m3DPhiToPfMet_JetEnDown:
        def __get__(self):
            self.m3DPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_JetEnDown_value

    property m3DPhiToPfMet_JetEnUp:
        def __get__(self):
            self.m3DPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_JetEnUp_value

    property m3DPhiToPfMet_JetResDown:
        def __get__(self):
            self.m3DPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_JetResDown_value

    property m3DPhiToPfMet_JetResUp:
        def __get__(self):
            self.m3DPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_JetResUp_value

    property m3DPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.m3DPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_MuonEnDown_value

    property m3DPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.m3DPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_MuonEnUp_value

    property m3DPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.m3DPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_PhotonEnDown_value

    property m3DPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.m3DPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_PhotonEnUp_value

    property m3DPhiToPfMet_TauEnDown:
        def __get__(self):
            self.m3DPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_TauEnDown_value

    property m3DPhiToPfMet_TauEnUp:
        def __get__(self):
            self.m3DPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_TauEnUp_value

    property m3DPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.m3DPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_UnclusteredEnDown_value

    property m3DPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.m3DPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_UnclusteredEnUp_value

    property m3DPhiToPfMet_type1:
        def __get__(self):
            self.m3DPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.m3DPhiToPfMet_type1_value

    property m3EcalIsoDR03:
        def __get__(self):
            self.m3EcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m3EcalIsoDR03_value

    property m3EffectiveArea2011:
        def __get__(self):
            self.m3EffectiveArea2011_branch.GetEntry(self.localentry, 0)
            return self.m3EffectiveArea2011_value

    property m3EffectiveArea2012:
        def __get__(self):
            self.m3EffectiveArea2012_branch.GetEntry(self.localentry, 0)
            return self.m3EffectiveArea2012_value

    property m3Eta:
        def __get__(self):
            self.m3Eta_branch.GetEntry(self.localentry, 0)
            return self.m3Eta_value

    property m3Eta_MuonEnDown:
        def __get__(self):
            self.m3Eta_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3Eta_MuonEnDown_value

    property m3Eta_MuonEnUp:
        def __get__(self):
            self.m3Eta_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3Eta_MuonEnUp_value

    property m3GenCharge:
        def __get__(self):
            self.m3GenCharge_branch.GetEntry(self.localentry, 0)
            return self.m3GenCharge_value

    property m3GenEnergy:
        def __get__(self):
            self.m3GenEnergy_branch.GetEntry(self.localentry, 0)
            return self.m3GenEnergy_value

    property m3GenEta:
        def __get__(self):
            self.m3GenEta_branch.GetEntry(self.localentry, 0)
            return self.m3GenEta_value

    property m3GenMotherPdgId:
        def __get__(self):
            self.m3GenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.m3GenMotherPdgId_value

    property m3GenPdgId:
        def __get__(self):
            self.m3GenPdgId_branch.GetEntry(self.localentry, 0)
            return self.m3GenPdgId_value

    property m3GenPhi:
        def __get__(self):
            self.m3GenPhi_branch.GetEntry(self.localentry, 0)
            return self.m3GenPhi_value

    property m3GenPrompt:
        def __get__(self):
            self.m3GenPrompt_branch.GetEntry(self.localentry, 0)
            return self.m3GenPrompt_value

    property m3GenPromptTauDecay:
        def __get__(self):
            self.m3GenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.m3GenPromptTauDecay_value

    property m3GenPt:
        def __get__(self):
            self.m3GenPt_branch.GetEntry(self.localentry, 0)
            return self.m3GenPt_value

    property m3GenTauDecay:
        def __get__(self):
            self.m3GenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.m3GenTauDecay_value

    property m3GenVZ:
        def __get__(self):
            self.m3GenVZ_branch.GetEntry(self.localentry, 0)
            return self.m3GenVZ_value

    property m3GenVtxPVMatch:
        def __get__(self):
            self.m3GenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.m3GenVtxPVMatch_value

    property m3HcalIsoDR03:
        def __get__(self):
            self.m3HcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m3HcalIsoDR03_value

    property m3IP3D:
        def __get__(self):
            self.m3IP3D_branch.GetEntry(self.localentry, 0)
            return self.m3IP3D_value

    property m3IP3DErr:
        def __get__(self):
            self.m3IP3DErr_branch.GetEntry(self.localentry, 0)
            return self.m3IP3DErr_value

    property m3IsGlobal:
        def __get__(self):
            self.m3IsGlobal_branch.GetEntry(self.localentry, 0)
            return self.m3IsGlobal_value

    property m3IsPFMuon:
        def __get__(self):
            self.m3IsPFMuon_branch.GetEntry(self.localentry, 0)
            return self.m3IsPFMuon_value

    property m3IsTracker:
        def __get__(self):
            self.m3IsTracker_branch.GetEntry(self.localentry, 0)
            return self.m3IsTracker_value

    property m3JetArea:
        def __get__(self):
            self.m3JetArea_branch.GetEntry(self.localentry, 0)
            return self.m3JetArea_value

    property m3JetBtag:
        def __get__(self):
            self.m3JetBtag_branch.GetEntry(self.localentry, 0)
            return self.m3JetBtag_value

    property m3JetEtaEtaMoment:
        def __get__(self):
            self.m3JetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.m3JetEtaEtaMoment_value

    property m3JetEtaPhiMoment:
        def __get__(self):
            self.m3JetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.m3JetEtaPhiMoment_value

    property m3JetEtaPhiSpread:
        def __get__(self):
            self.m3JetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.m3JetEtaPhiSpread_value

    property m3JetPFCISVBtag:
        def __get__(self):
            self.m3JetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.m3JetPFCISVBtag_value

    property m3JetPartonFlavour:
        def __get__(self):
            self.m3JetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.m3JetPartonFlavour_value

    property m3JetPhiPhiMoment:
        def __get__(self):
            self.m3JetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.m3JetPhiPhiMoment_value

    property m3JetPt:
        def __get__(self):
            self.m3JetPt_branch.GetEntry(self.localentry, 0)
            return self.m3JetPt_value

    property m3LowestMll:
        def __get__(self):
            self.m3LowestMll_branch.GetEntry(self.localentry, 0)
            return self.m3LowestMll_value

    property m3Mass:
        def __get__(self):
            self.m3Mass_branch.GetEntry(self.localentry, 0)
            return self.m3Mass_value

    property m3MatchedStations:
        def __get__(self):
            self.m3MatchedStations_branch.GetEntry(self.localentry, 0)
            return self.m3MatchedStations_value

    property m3MatchesDoubleESingleMu:
        def __get__(self):
            self.m3MatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesDoubleESingleMu_value

    property m3MatchesDoubleMu:
        def __get__(self):
            self.m3MatchesDoubleMu_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesDoubleMu_value

    property m3MatchesDoubleMuSingleE:
        def __get__(self):
            self.m3MatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesDoubleMuSingleE_value

    property m3MatchesSingleESingleMu:
        def __get__(self):
            self.m3MatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleESingleMu_value

    property m3MatchesSingleMu:
        def __get__(self):
            self.m3MatchesSingleMu_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMu_value

    property m3MatchesSingleMuIso20:
        def __get__(self):
            self.m3MatchesSingleMuIso20_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMuIso20_value

    property m3MatchesSingleMuIsoTk20:
        def __get__(self):
            self.m3MatchesSingleMuIsoTk20_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMuIsoTk20_value

    property m3MatchesSingleMuSingleE:
        def __get__(self):
            self.m3MatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMuSingleE_value

    property m3MatchesSingleMu_leg1:
        def __get__(self):
            self.m3MatchesSingleMu_leg1_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMu_leg1_value

    property m3MatchesSingleMu_leg1_noiso:
        def __get__(self):
            self.m3MatchesSingleMu_leg1_noiso_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMu_leg1_noiso_value

    property m3MatchesSingleMu_leg2:
        def __get__(self):
            self.m3MatchesSingleMu_leg2_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMu_leg2_value

    property m3MatchesSingleMu_leg2_noiso:
        def __get__(self):
            self.m3MatchesSingleMu_leg2_noiso_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesSingleMu_leg2_noiso_value

    property m3MatchesTripleMu:
        def __get__(self):
            self.m3MatchesTripleMu_branch.GetEntry(self.localentry, 0)
            return self.m3MatchesTripleMu_value

    property m3MtToPfMet_ElectronEnDown:
        def __get__(self):
            self.m3MtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_ElectronEnDown_value

    property m3MtToPfMet_ElectronEnUp:
        def __get__(self):
            self.m3MtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_ElectronEnUp_value

    property m3MtToPfMet_JetEnDown:
        def __get__(self):
            self.m3MtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_JetEnDown_value

    property m3MtToPfMet_JetEnUp:
        def __get__(self):
            self.m3MtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_JetEnUp_value

    property m3MtToPfMet_JetResDown:
        def __get__(self):
            self.m3MtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_JetResDown_value

    property m3MtToPfMet_JetResUp:
        def __get__(self):
            self.m3MtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_JetResUp_value

    property m3MtToPfMet_MuonEnDown:
        def __get__(self):
            self.m3MtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_MuonEnDown_value

    property m3MtToPfMet_MuonEnUp:
        def __get__(self):
            self.m3MtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_MuonEnUp_value

    property m3MtToPfMet_PhotonEnDown:
        def __get__(self):
            self.m3MtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_PhotonEnDown_value

    property m3MtToPfMet_PhotonEnUp:
        def __get__(self):
            self.m3MtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_PhotonEnUp_value

    property m3MtToPfMet_Raw:
        def __get__(self):
            self.m3MtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_Raw_value

    property m3MtToPfMet_TauEnDown:
        def __get__(self):
            self.m3MtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_TauEnDown_value

    property m3MtToPfMet_TauEnUp:
        def __get__(self):
            self.m3MtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_TauEnUp_value

    property m3MtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.m3MtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_UnclusteredEnDown_value

    property m3MtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.m3MtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_UnclusteredEnUp_value

    property m3MtToPfMet_type1:
        def __get__(self):
            self.m3MtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.m3MtToPfMet_type1_value

    property m3MuonHits:
        def __get__(self):
            self.m3MuonHits_branch.GetEntry(self.localentry, 0)
            return self.m3MuonHits_value

    property m3NearestZMass:
        def __get__(self):
            self.m3NearestZMass_branch.GetEntry(self.localentry, 0)
            return self.m3NearestZMass_value

    property m3NormTrkChi2:
        def __get__(self):
            self.m3NormTrkChi2_branch.GetEntry(self.localentry, 0)
            return self.m3NormTrkChi2_value

    property m3PFChargedIso:
        def __get__(self):
            self.m3PFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.m3PFChargedIso_value

    property m3PFIDLoose:
        def __get__(self):
            self.m3PFIDLoose_branch.GetEntry(self.localentry, 0)
            return self.m3PFIDLoose_value

    property m3PFIDMedium:
        def __get__(self):
            self.m3PFIDMedium_branch.GetEntry(self.localentry, 0)
            return self.m3PFIDMedium_value

    property m3PFIDTight:
        def __get__(self):
            self.m3PFIDTight_branch.GetEntry(self.localentry, 0)
            return self.m3PFIDTight_value

    property m3PFNeutralIso:
        def __get__(self):
            self.m3PFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.m3PFNeutralIso_value

    property m3PFPUChargedIso:
        def __get__(self):
            self.m3PFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.m3PFPUChargedIso_value

    property m3PFPhotonIso:
        def __get__(self):
            self.m3PFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.m3PFPhotonIso_value

    property m3PVDXY:
        def __get__(self):
            self.m3PVDXY_branch.GetEntry(self.localentry, 0)
            return self.m3PVDXY_value

    property m3PVDZ:
        def __get__(self):
            self.m3PVDZ_branch.GetEntry(self.localentry, 0)
            return self.m3PVDZ_value

    property m3Phi:
        def __get__(self):
            self.m3Phi_branch.GetEntry(self.localentry, 0)
            return self.m3Phi_value

    property m3Phi_MuonEnDown:
        def __get__(self):
            self.m3Phi_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3Phi_MuonEnDown_value

    property m3Phi_MuonEnUp:
        def __get__(self):
            self.m3Phi_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3Phi_MuonEnUp_value

    property m3PixHits:
        def __get__(self):
            self.m3PixHits_branch.GetEntry(self.localentry, 0)
            return self.m3PixHits_value

    property m3Pt:
        def __get__(self):
            self.m3Pt_branch.GetEntry(self.localentry, 0)
            return self.m3Pt_value

    property m3Pt_MuonEnDown:
        def __get__(self):
            self.m3Pt_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3Pt_MuonEnDown_value

    property m3Pt_MuonEnUp:
        def __get__(self):
            self.m3Pt_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3Pt_MuonEnUp_value

    property m3Rank:
        def __get__(self):
            self.m3Rank_branch.GetEntry(self.localentry, 0)
            return self.m3Rank_value

    property m3RelPFIsoDBDefault:
        def __get__(self):
            self.m3RelPFIsoDBDefault_branch.GetEntry(self.localentry, 0)
            return self.m3RelPFIsoDBDefault_value

    property m3RelPFIsoRho:
        def __get__(self):
            self.m3RelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.m3RelPFIsoRho_value

    property m3Rho:
        def __get__(self):
            self.m3Rho_branch.GetEntry(self.localentry, 0)
            return self.m3Rho_value

    property m3SIP2D:
        def __get__(self):
            self.m3SIP2D_branch.GetEntry(self.localentry, 0)
            return self.m3SIP2D_value

    property m3SIP3D:
        def __get__(self):
            self.m3SIP3D_branch.GetEntry(self.localentry, 0)
            return self.m3SIP3D_value

    property m3TkLayersWithMeasurement:
        def __get__(self):
            self.m3TkLayersWithMeasurement_branch.GetEntry(self.localentry, 0)
            return self.m3TkLayersWithMeasurement_value

    property m3TrkIsoDR03:
        def __get__(self):
            self.m3TrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.m3TrkIsoDR03_value

    property m3TypeCode:
        def __get__(self):
            self.m3TypeCode_branch.GetEntry(self.localentry, 0)
            return self.m3TypeCode_value

    property m3VZ:
        def __get__(self):
            self.m3VZ_branch.GetEntry(self.localentry, 0)
            return self.m3VZ_value

    property m3_m1_collinearmass:
        def __get__(self):
            self.m3_m1_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.m3_m1_collinearmass_value

    property m3_m1_collinearmass_JetEnDown:
        def __get__(self):
            self.m3_m1_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3_m1_collinearmass_JetEnDown_value

    property m3_m1_collinearmass_JetEnUp:
        def __get__(self):
            self.m3_m1_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3_m1_collinearmass_JetEnUp_value

    property m3_m1_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.m3_m1_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3_m1_collinearmass_UnclusteredEnDown_value

    property m3_m1_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.m3_m1_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3_m1_collinearmass_UnclusteredEnUp_value

    property m3_m2_collinearmass:
        def __get__(self):
            self.m3_m2_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.m3_m2_collinearmass_value

    property m3_m2_collinearmass_JetEnDown:
        def __get__(self):
            self.m3_m2_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3_m2_collinearmass_JetEnDown_value

    property m3_m2_collinearmass_JetEnUp:
        def __get__(self):
            self.m3_m2_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3_m2_collinearmass_JetEnUp_value

    property m3_m2_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.m3_m2_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m3_m2_collinearmass_UnclusteredEnDown_value

    property m3_m2_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.m3_m2_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m3_m2_collinearmass_UnclusteredEnUp_value

    property muGlbIsoVetoPt10:
        def __get__(self):
            self.muGlbIsoVetoPt10_branch.GetEntry(self.localentry, 0)
            return self.muGlbIsoVetoPt10_value

    property muVetoPt15IsoIdVtx:
        def __get__(self):
            self.muVetoPt15IsoIdVtx_branch.GetEntry(self.localentry, 0)
            return self.muVetoPt15IsoIdVtx_value

    property muVetoPt5:
        def __get__(self):
            self.muVetoPt5_branch.GetEntry(self.localentry, 0)
            return self.muVetoPt5_value

    property muVetoPt5IsoIdVtx:
        def __get__(self):
            self.muVetoPt5IsoIdVtx_branch.GetEntry(self.localentry, 0)
            return self.muVetoPt5IsoIdVtx_value

    property nTruePU:
        def __get__(self):
            self.nTruePU_branch.GetEntry(self.localentry, 0)
            return self.nTruePU_value

    property nvtx:
        def __get__(self):
            self.nvtx_branch.GetEntry(self.localentry, 0)
            return self.nvtx_value

    property processID:
        def __get__(self):
            self.processID_branch.GetEntry(self.localentry, 0)
            return self.processID_value

    property pvChi2:
        def __get__(self):
            self.pvChi2_branch.GetEntry(self.localentry, 0)
            return self.pvChi2_value

    property pvDX:
        def __get__(self):
            self.pvDX_branch.GetEntry(self.localentry, 0)
            return self.pvDX_value

    property pvDY:
        def __get__(self):
            self.pvDY_branch.GetEntry(self.localentry, 0)
            return self.pvDY_value

    property pvDZ:
        def __get__(self):
            self.pvDZ_branch.GetEntry(self.localentry, 0)
            return self.pvDZ_value

    property pvIsFake:
        def __get__(self):
            self.pvIsFake_branch.GetEntry(self.localentry, 0)
            return self.pvIsFake_value

    property pvIsValid:
        def __get__(self):
            self.pvIsValid_branch.GetEntry(self.localentry, 0)
            return self.pvIsValid_value

    property pvNormChi2:
        def __get__(self):
            self.pvNormChi2_branch.GetEntry(self.localentry, 0)
            return self.pvNormChi2_value

    property pvRho:
        def __get__(self):
            self.pvRho_branch.GetEntry(self.localentry, 0)
            return self.pvRho_value

    property pvX:
        def __get__(self):
            self.pvX_branch.GetEntry(self.localentry, 0)
            return self.pvX_value

    property pvY:
        def __get__(self):
            self.pvY_branch.GetEntry(self.localentry, 0)
            return self.pvY_value

    property pvZ:
        def __get__(self):
            self.pvZ_branch.GetEntry(self.localentry, 0)
            return self.pvZ_value

    property pvndof:
        def __get__(self):
            self.pvndof_branch.GetEntry(self.localentry, 0)
            return self.pvndof_value

    property raw_pfMetEt:
        def __get__(self):
            self.raw_pfMetEt_branch.GetEntry(self.localentry, 0)
            return self.raw_pfMetEt_value

    property raw_pfMetPhi:
        def __get__(self):
            self.raw_pfMetPhi_branch.GetEntry(self.localentry, 0)
            return self.raw_pfMetPhi_value

    property recoilDaught:
        def __get__(self):
            self.recoilDaught_branch.GetEntry(self.localentry, 0)
            return self.recoilDaught_value

    property recoilWithMet:
        def __get__(self):
            self.recoilWithMet_branch.GetEntry(self.localentry, 0)
            return self.recoilWithMet_value

    property rho:
        def __get__(self):
            self.rho_branch.GetEntry(self.localentry, 0)
            return self.rho_value

    property run:
        def __get__(self):
            self.run_branch.GetEntry(self.localentry, 0)
            return self.run_value

    property singleE17SingleMu8Group:
        def __get__(self):
            self.singleE17SingleMu8Group_branch.GetEntry(self.localentry, 0)
            return self.singleE17SingleMu8Group_value

    property singleE17SingleMu8Pass:
        def __get__(self):
            self.singleE17SingleMu8Pass_branch.GetEntry(self.localentry, 0)
            return self.singleE17SingleMu8Pass_value

    property singleE17SingleMu8Prescale:
        def __get__(self):
            self.singleE17SingleMu8Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleE17SingleMu8Prescale_value

    property singleE22WP75Group:
        def __get__(self):
            self.singleE22WP75Group_branch.GetEntry(self.localentry, 0)
            return self.singleE22WP75Group_value

    property singleE22WP75Pass:
        def __get__(self):
            self.singleE22WP75Pass_branch.GetEntry(self.localentry, 0)
            return self.singleE22WP75Pass_value

    property singleE22WP75Prescale:
        def __get__(self):
            self.singleE22WP75Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleE22WP75Prescale_value

    property singleE22eta2p1LooseGroup:
        def __get__(self):
            self.singleE22eta2p1LooseGroup_branch.GetEntry(self.localentry, 0)
            return self.singleE22eta2p1LooseGroup_value

    property singleE22eta2p1LoosePass:
        def __get__(self):
            self.singleE22eta2p1LoosePass_branch.GetEntry(self.localentry, 0)
            return self.singleE22eta2p1LoosePass_value

    property singleE22eta2p1LoosePrescale:
        def __get__(self):
            self.singleE22eta2p1LoosePrescale_branch.GetEntry(self.localentry, 0)
            return self.singleE22eta2p1LoosePrescale_value

    property singleE23SingleMu8Group:
        def __get__(self):
            self.singleE23SingleMu8Group_branch.GetEntry(self.localentry, 0)
            return self.singleE23SingleMu8Group_value

    property singleE23SingleMu8Pass:
        def __get__(self):
            self.singleE23SingleMu8Pass_branch.GetEntry(self.localentry, 0)
            return self.singleE23SingleMu8Pass_value

    property singleE23SingleMu8Prescale:
        def __get__(self):
            self.singleE23SingleMu8Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleE23SingleMu8Prescale_value

    property singleE23WP75Group:
        def __get__(self):
            self.singleE23WP75Group_branch.GetEntry(self.localentry, 0)
            return self.singleE23WP75Group_value

    property singleE23WP75Pass:
        def __get__(self):
            self.singleE23WP75Pass_branch.GetEntry(self.localentry, 0)
            return self.singleE23WP75Pass_value

    property singleE23WP75Prescale:
        def __get__(self):
            self.singleE23WP75Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleE23WP75Prescale_value

    property singleEGroup:
        def __get__(self):
            self.singleEGroup_branch.GetEntry(self.localentry, 0)
            return self.singleEGroup_value

    property singleEPass:
        def __get__(self):
            self.singleEPass_branch.GetEntry(self.localentry, 0)
            return self.singleEPass_value

    property singleEPrescale:
        def __get__(self):
            self.singleEPrescale_branch.GetEntry(self.localentry, 0)
            return self.singleEPrescale_value

    property singleESingleMuGroup:
        def __get__(self):
            self.singleESingleMuGroup_branch.GetEntry(self.localentry, 0)
            return self.singleESingleMuGroup_value

    property singleESingleMuPass:
        def __get__(self):
            self.singleESingleMuPass_branch.GetEntry(self.localentry, 0)
            return self.singleESingleMuPass_value

    property singleESingleMuPrescale:
        def __get__(self):
            self.singleESingleMuPrescale_branch.GetEntry(self.localentry, 0)
            return self.singleESingleMuPrescale_value

    property singleE_leg1Group:
        def __get__(self):
            self.singleE_leg1Group_branch.GetEntry(self.localentry, 0)
            return self.singleE_leg1Group_value

    property singleE_leg1Pass:
        def __get__(self):
            self.singleE_leg1Pass_branch.GetEntry(self.localentry, 0)
            return self.singleE_leg1Pass_value

    property singleE_leg1Prescale:
        def __get__(self):
            self.singleE_leg1Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleE_leg1Prescale_value

    property singleE_leg2Group:
        def __get__(self):
            self.singleE_leg2Group_branch.GetEntry(self.localentry, 0)
            return self.singleE_leg2Group_value

    property singleE_leg2Pass:
        def __get__(self):
            self.singleE_leg2Pass_branch.GetEntry(self.localentry, 0)
            return self.singleE_leg2Pass_value

    property singleE_leg2Prescale:
        def __get__(self):
            self.singleE_leg2Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleE_leg2Prescale_value

    property singleIsoMu17eta2p1Group:
        def __get__(self):
            self.singleIsoMu17eta2p1Group_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu17eta2p1Group_value

    property singleIsoMu17eta2p1Pass:
        def __get__(self):
            self.singleIsoMu17eta2p1Pass_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu17eta2p1Pass_value

    property singleIsoMu17eta2p1Prescale:
        def __get__(self):
            self.singleIsoMu17eta2p1Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu17eta2p1Prescale_value

    property singleIsoMu20Group:
        def __get__(self):
            self.singleIsoMu20Group_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu20Group_value

    property singleIsoMu20Pass:
        def __get__(self):
            self.singleIsoMu20Pass_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu20Pass_value

    property singleIsoMu20Prescale:
        def __get__(self):
            self.singleIsoMu20Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu20Prescale_value

    property singleIsoMu20eta2p1Group:
        def __get__(self):
            self.singleIsoMu20eta2p1Group_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu20eta2p1Group_value

    property singleIsoMu20eta2p1Pass:
        def __get__(self):
            self.singleIsoMu20eta2p1Pass_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu20eta2p1Pass_value

    property singleIsoMu20eta2p1Prescale:
        def __get__(self):
            self.singleIsoMu20eta2p1Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu20eta2p1Prescale_value

    property singleIsoMu24Group:
        def __get__(self):
            self.singleIsoMu24Group_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu24Group_value

    property singleIsoMu24Pass:
        def __get__(self):
            self.singleIsoMu24Pass_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu24Pass_value

    property singleIsoMu24Prescale:
        def __get__(self):
            self.singleIsoMu24Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu24Prescale_value

    property singleIsoMu24eta2p1Group:
        def __get__(self):
            self.singleIsoMu24eta2p1Group_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu24eta2p1Group_value

    property singleIsoMu24eta2p1Pass:
        def __get__(self):
            self.singleIsoMu24eta2p1Pass_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu24eta2p1Pass_value

    property singleIsoMu24eta2p1Prescale:
        def __get__(self):
            self.singleIsoMu24eta2p1Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu24eta2p1Prescale_value

    property singleIsoTkMu20Group:
        def __get__(self):
            self.singleIsoTkMu20Group_branch.GetEntry(self.localentry, 0)
            return self.singleIsoTkMu20Group_value

    property singleIsoTkMu20Pass:
        def __get__(self):
            self.singleIsoTkMu20Pass_branch.GetEntry(self.localentry, 0)
            return self.singleIsoTkMu20Pass_value

    property singleIsoTkMu20Prescale:
        def __get__(self):
            self.singleIsoTkMu20Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleIsoTkMu20Prescale_value

    property singleMu17SingleE12Group:
        def __get__(self):
            self.singleMu17SingleE12Group_branch.GetEntry(self.localentry, 0)
            return self.singleMu17SingleE12Group_value

    property singleMu17SingleE12Pass:
        def __get__(self):
            self.singleMu17SingleE12Pass_branch.GetEntry(self.localentry, 0)
            return self.singleMu17SingleE12Pass_value

    property singleMu17SingleE12Prescale:
        def __get__(self):
            self.singleMu17SingleE12Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleMu17SingleE12Prescale_value

    property singleMu23SingleE12Group:
        def __get__(self):
            self.singleMu23SingleE12Group_branch.GetEntry(self.localentry, 0)
            return self.singleMu23SingleE12Group_value

    property singleMu23SingleE12Pass:
        def __get__(self):
            self.singleMu23SingleE12Pass_branch.GetEntry(self.localentry, 0)
            return self.singleMu23SingleE12Pass_value

    property singleMu23SingleE12Prescale:
        def __get__(self):
            self.singleMu23SingleE12Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleMu23SingleE12Prescale_value

    property singleMuGroup:
        def __get__(self):
            self.singleMuGroup_branch.GetEntry(self.localentry, 0)
            return self.singleMuGroup_value

    property singleMuPass:
        def __get__(self):
            self.singleMuPass_branch.GetEntry(self.localentry, 0)
            return self.singleMuPass_value

    property singleMuPrescale:
        def __get__(self):
            self.singleMuPrescale_branch.GetEntry(self.localentry, 0)
            return self.singleMuPrescale_value

    property singleMuSingleEGroup:
        def __get__(self):
            self.singleMuSingleEGroup_branch.GetEntry(self.localentry, 0)
            return self.singleMuSingleEGroup_value

    property singleMuSingleEPass:
        def __get__(self):
            self.singleMuSingleEPass_branch.GetEntry(self.localentry, 0)
            return self.singleMuSingleEPass_value

    property singleMuSingleEPrescale:
        def __get__(self):
            self.singleMuSingleEPrescale_branch.GetEntry(self.localentry, 0)
            return self.singleMuSingleEPrescale_value

    property singleMu_leg1Group:
        def __get__(self):
            self.singleMu_leg1Group_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg1Group_value

    property singleMu_leg1Pass:
        def __get__(self):
            self.singleMu_leg1Pass_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg1Pass_value

    property singleMu_leg1Prescale:
        def __get__(self):
            self.singleMu_leg1Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg1Prescale_value

    property singleMu_leg1_noisoGroup:
        def __get__(self):
            self.singleMu_leg1_noisoGroup_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg1_noisoGroup_value

    property singleMu_leg1_noisoPass:
        def __get__(self):
            self.singleMu_leg1_noisoPass_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg1_noisoPass_value

    property singleMu_leg1_noisoPrescale:
        def __get__(self):
            self.singleMu_leg1_noisoPrescale_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg1_noisoPrescale_value

    property singleMu_leg2Group:
        def __get__(self):
            self.singleMu_leg2Group_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg2Group_value

    property singleMu_leg2Pass:
        def __get__(self):
            self.singleMu_leg2Pass_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg2Pass_value

    property singleMu_leg2Prescale:
        def __get__(self):
            self.singleMu_leg2Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg2Prescale_value

    property singleMu_leg2_noisoGroup:
        def __get__(self):
            self.singleMu_leg2_noisoGroup_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg2_noisoGroup_value

    property singleMu_leg2_noisoPass:
        def __get__(self):
            self.singleMu_leg2_noisoPass_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg2_noisoPass_value

    property singleMu_leg2_noisoPrescale:
        def __get__(self):
            self.singleMu_leg2_noisoPrescale_branch.GetEntry(self.localentry, 0)
            return self.singleMu_leg2_noisoPrescale_value

    property tauVetoPt20Loose3HitsNewDMVtx:
        def __get__(self):
            self.tauVetoPt20Loose3HitsNewDMVtx_branch.GetEntry(self.localentry, 0)
            return self.tauVetoPt20Loose3HitsNewDMVtx_value

    property tauVetoPt20Loose3HitsVtx:
        def __get__(self):
            self.tauVetoPt20Loose3HitsVtx_branch.GetEntry(self.localentry, 0)
            return self.tauVetoPt20Loose3HitsVtx_value

    property tauVetoPt20TightMVALTNewDMVtx:
        def __get__(self):
            self.tauVetoPt20TightMVALTNewDMVtx_branch.GetEntry(self.localentry, 0)
            return self.tauVetoPt20TightMVALTNewDMVtx_value

    property tauVetoPt20TightMVALTVtx:
        def __get__(self):
            self.tauVetoPt20TightMVALTVtx_branch.GetEntry(self.localentry, 0)
            return self.tauVetoPt20TightMVALTVtx_value

    property tripleEGroup:
        def __get__(self):
            self.tripleEGroup_branch.GetEntry(self.localentry, 0)
            return self.tripleEGroup_value

    property tripleEPass:
        def __get__(self):
            self.tripleEPass_branch.GetEntry(self.localentry, 0)
            return self.tripleEPass_value

    property tripleEPrescale:
        def __get__(self):
            self.tripleEPrescale_branch.GetEntry(self.localentry, 0)
            return self.tripleEPrescale_value

    property tripleMuGroup:
        def __get__(self):
            self.tripleMuGroup_branch.GetEntry(self.localentry, 0)
            return self.tripleMuGroup_value

    property tripleMuPass:
        def __get__(self):
            self.tripleMuPass_branch.GetEntry(self.localentry, 0)
            return self.tripleMuPass_value

    property tripleMuPrescale:
        def __get__(self):
            self.tripleMuPrescale_branch.GetEntry(self.localentry, 0)
            return self.tripleMuPrescale_value

    property type1_pfMetEt:
        def __get__(self):
            self.type1_pfMetEt_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMetEt_value

    property type1_pfMetPhi:
        def __get__(self):
            self.type1_pfMetPhi_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMetPhi_value

    property type1_pfMet_shiftedPhi_ElectronEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_ElectronEnDown_value

    property type1_pfMet_shiftedPhi_ElectronEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_ElectronEnUp_value

    property type1_pfMet_shiftedPhi_JetEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_JetEnDown_value

    property type1_pfMet_shiftedPhi_JetEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_JetEnUp_value

    property type1_pfMet_shiftedPhi_JetResDown:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_JetResDown_value

    property type1_pfMet_shiftedPhi_JetResUp:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_JetResUp_value

    property type1_pfMet_shiftedPhi_MuonEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_MuonEnDown_value

    property type1_pfMet_shiftedPhi_MuonEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_MuonEnUp_value

    property type1_pfMet_shiftedPhi_PhotonEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_PhotonEnDown_value

    property type1_pfMet_shiftedPhi_PhotonEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_PhotonEnUp_value

    property type1_pfMet_shiftedPhi_TauEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_TauEnDown_value

    property type1_pfMet_shiftedPhi_TauEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_TauEnUp_value

    property type1_pfMet_shiftedPhi_UnclusteredEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_UnclusteredEnDown_value

    property type1_pfMet_shiftedPhi_UnclusteredEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPhi_UnclusteredEnUp_value

    property type1_pfMet_shiftedPt_ElectronEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPt_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_ElectronEnDown_value

    property type1_pfMet_shiftedPt_ElectronEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPt_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_ElectronEnUp_value

    property type1_pfMet_shiftedPt_JetEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPt_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_JetEnDown_value

    property type1_pfMet_shiftedPt_JetEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPt_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_JetEnUp_value

    property type1_pfMet_shiftedPt_JetResDown:
        def __get__(self):
            self.type1_pfMet_shiftedPt_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_JetResDown_value

    property type1_pfMet_shiftedPt_JetResUp:
        def __get__(self):
            self.type1_pfMet_shiftedPt_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_JetResUp_value

    property type1_pfMet_shiftedPt_MuonEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPt_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_MuonEnDown_value

    property type1_pfMet_shiftedPt_MuonEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPt_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_MuonEnUp_value

    property type1_pfMet_shiftedPt_PhotonEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPt_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_PhotonEnDown_value

    property type1_pfMet_shiftedPt_PhotonEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPt_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_PhotonEnUp_value

    property type1_pfMet_shiftedPt_TauEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPt_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_TauEnDown_value

    property type1_pfMet_shiftedPt_TauEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPt_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_TauEnUp_value

    property type1_pfMet_shiftedPt_UnclusteredEnDown:
        def __get__(self):
            self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_UnclusteredEnDown_value

    property type1_pfMet_shiftedPt_UnclusteredEnUp:
        def __get__(self):
            self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.type1_pfMet_shiftedPt_UnclusteredEnUp_value

    property vbfDeta:
        def __get__(self):
            self.vbfDeta_branch.GetEntry(self.localentry, 0)
            return self.vbfDeta_value

    property vbfDeta_JetEnDown:
        def __get__(self):
            self.vbfDeta_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfDeta_JetEnDown_value

    property vbfDeta_JetEnUp:
        def __get__(self):
            self.vbfDeta_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfDeta_JetEnUp_value

    property vbfDijetrap:
        def __get__(self):
            self.vbfDijetrap_branch.GetEntry(self.localentry, 0)
            return self.vbfDijetrap_value

    property vbfDijetrap_JetEnDown:
        def __get__(self):
            self.vbfDijetrap_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfDijetrap_JetEnDown_value

    property vbfDijetrap_JetEnUp:
        def __get__(self):
            self.vbfDijetrap_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfDijetrap_JetEnUp_value

    property vbfDphi:
        def __get__(self):
            self.vbfDphi_branch.GetEntry(self.localentry, 0)
            return self.vbfDphi_value

    property vbfDphi_JetEnDown:
        def __get__(self):
            self.vbfDphi_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfDphi_JetEnDown_value

    property vbfDphi_JetEnUp:
        def __get__(self):
            self.vbfDphi_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfDphi_JetEnUp_value

    property vbfDphihj:
        def __get__(self):
            self.vbfDphihj_branch.GetEntry(self.localentry, 0)
            return self.vbfDphihj_value

    property vbfDphihj_JetEnDown:
        def __get__(self):
            self.vbfDphihj_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfDphihj_JetEnDown_value

    property vbfDphihj_JetEnUp:
        def __get__(self):
            self.vbfDphihj_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfDphihj_JetEnUp_value

    property vbfDphihjnomet:
        def __get__(self):
            self.vbfDphihjnomet_branch.GetEntry(self.localentry, 0)
            return self.vbfDphihjnomet_value

    property vbfDphihjnomet_JetEnDown:
        def __get__(self):
            self.vbfDphihjnomet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfDphihjnomet_JetEnDown_value

    property vbfDphihjnomet_JetEnUp:
        def __get__(self):
            self.vbfDphihjnomet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfDphihjnomet_JetEnUp_value

    property vbfHrap:
        def __get__(self):
            self.vbfHrap_branch.GetEntry(self.localentry, 0)
            return self.vbfHrap_value

    property vbfHrap_JetEnDown:
        def __get__(self):
            self.vbfHrap_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfHrap_JetEnDown_value

    property vbfHrap_JetEnUp:
        def __get__(self):
            self.vbfHrap_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfHrap_JetEnUp_value

    property vbfJetVeto20:
        def __get__(self):
            self.vbfJetVeto20_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVeto20_value

    property vbfJetVeto20_JetEnDown:
        def __get__(self):
            self.vbfJetVeto20_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVeto20_JetEnDown_value

    property vbfJetVeto20_JetEnUp:
        def __get__(self):
            self.vbfJetVeto20_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVeto20_JetEnUp_value

    property vbfJetVeto30:
        def __get__(self):
            self.vbfJetVeto30_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVeto30_value

    property vbfJetVeto30_JetEnDown:
        def __get__(self):
            self.vbfJetVeto30_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVeto30_JetEnDown_value

    property vbfJetVeto30_JetEnUp:
        def __get__(self):
            self.vbfJetVeto30_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVeto30_JetEnUp_value

    property vbfJetVetoTight20:
        def __get__(self):
            self.vbfJetVetoTight20_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVetoTight20_value

    property vbfJetVetoTight20_JetEnDown:
        def __get__(self):
            self.vbfJetVetoTight20_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVetoTight20_JetEnDown_value

    property vbfJetVetoTight20_JetEnUp:
        def __get__(self):
            self.vbfJetVetoTight20_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVetoTight20_JetEnUp_value

    property vbfJetVetoTight30:
        def __get__(self):
            self.vbfJetVetoTight30_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVetoTight30_value

    property vbfJetVetoTight30_JetEnDown:
        def __get__(self):
            self.vbfJetVetoTight30_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVetoTight30_JetEnDown_value

    property vbfJetVetoTight30_JetEnUp:
        def __get__(self):
            self.vbfJetVetoTight30_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfJetVetoTight30_JetEnUp_value

    property vbfMVA:
        def __get__(self):
            self.vbfMVA_branch.GetEntry(self.localentry, 0)
            return self.vbfMVA_value

    property vbfMVA_JetEnDown:
        def __get__(self):
            self.vbfMVA_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfMVA_JetEnDown_value

    property vbfMVA_JetEnUp:
        def __get__(self):
            self.vbfMVA_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfMVA_JetEnUp_value

    property vbfMass:
        def __get__(self):
            self.vbfMass_branch.GetEntry(self.localentry, 0)
            return self.vbfMass_value

    property vbfMass_JetEnDown:
        def __get__(self):
            self.vbfMass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfMass_JetEnDown_value

    property vbfMass_JetEnUp:
        def __get__(self):
            self.vbfMass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfMass_JetEnUp_value

    property vbfNJets:
        def __get__(self):
            self.vbfNJets_branch.GetEntry(self.localentry, 0)
            return self.vbfNJets_value

    property vbfNJets_JetEnDown:
        def __get__(self):
            self.vbfNJets_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfNJets_JetEnDown_value

    property vbfNJets_JetEnUp:
        def __get__(self):
            self.vbfNJets_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfNJets_JetEnUp_value

    property vbfVispt:
        def __get__(self):
            self.vbfVispt_branch.GetEntry(self.localentry, 0)
            return self.vbfVispt_value

    property vbfVispt_JetEnDown:
        def __get__(self):
            self.vbfVispt_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfVispt_JetEnDown_value

    property vbfVispt_JetEnUp:
        def __get__(self):
            self.vbfVispt_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfVispt_JetEnUp_value

    property vbfdijetpt:
        def __get__(self):
            self.vbfdijetpt_branch.GetEntry(self.localentry, 0)
            return self.vbfdijetpt_value

    property vbfdijetpt_JetEnDown:
        def __get__(self):
            self.vbfdijetpt_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfdijetpt_JetEnDown_value

    property vbfdijetpt_JetEnUp:
        def __get__(self):
            self.vbfdijetpt_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfdijetpt_JetEnUp_value

    property vbfditaupt:
        def __get__(self):
            self.vbfditaupt_branch.GetEntry(self.localentry, 0)
            return self.vbfditaupt_value

    property vbfditaupt_JetEnDown:
        def __get__(self):
            self.vbfditaupt_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfditaupt_JetEnDown_value

    property vbfditaupt_JetEnUp:
        def __get__(self):
            self.vbfditaupt_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfditaupt_JetEnUp_value

    property vbfj1eta:
        def __get__(self):
            self.vbfj1eta_branch.GetEntry(self.localentry, 0)
            return self.vbfj1eta_value

    property vbfj1eta_JetEnDown:
        def __get__(self):
            self.vbfj1eta_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfj1eta_JetEnDown_value

    property vbfj1eta_JetEnUp:
        def __get__(self):
            self.vbfj1eta_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfj1eta_JetEnUp_value

    property vbfj1pt:
        def __get__(self):
            self.vbfj1pt_branch.GetEntry(self.localentry, 0)
            return self.vbfj1pt_value

    property vbfj1pt_JetEnDown:
        def __get__(self):
            self.vbfj1pt_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfj1pt_JetEnDown_value

    property vbfj1pt_JetEnUp:
        def __get__(self):
            self.vbfj1pt_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfj1pt_JetEnUp_value

    property vbfj2eta:
        def __get__(self):
            self.vbfj2eta_branch.GetEntry(self.localentry, 0)
            return self.vbfj2eta_value

    property vbfj2eta_JetEnDown:
        def __get__(self):
            self.vbfj2eta_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfj2eta_JetEnDown_value

    property vbfj2eta_JetEnUp:
        def __get__(self):
            self.vbfj2eta_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfj2eta_JetEnUp_value

    property vbfj2pt:
        def __get__(self):
            self.vbfj2pt_branch.GetEntry(self.localentry, 0)
            return self.vbfj2pt_value

    property vbfj2pt_JetEnDown:
        def __get__(self):
            self.vbfj2pt_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.vbfj2pt_JetEnDown_value

    property vbfj2pt_JetEnUp:
        def __get__(self):
            self.vbfj2pt_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.vbfj2pt_JetEnUp_value

    property idx:
        def __get__(self):
            self.idx_branch.GetEntry(self.localentry, 0)
            return self.idx_value


