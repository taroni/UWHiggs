

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

cdef class EEETree:
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

    cdef TBranch* e1AbsEta_branch
    cdef float e1AbsEta_value

    cdef TBranch* e1CBIDLoose_branch
    cdef float e1CBIDLoose_value

    cdef TBranch* e1CBIDLooseNoIso_branch
    cdef float e1CBIDLooseNoIso_value

    cdef TBranch* e1CBIDMedium_branch
    cdef float e1CBIDMedium_value

    cdef TBranch* e1CBIDMediumNoIso_branch
    cdef float e1CBIDMediumNoIso_value

    cdef TBranch* e1CBIDTight_branch
    cdef float e1CBIDTight_value

    cdef TBranch* e1CBIDTightNoIso_branch
    cdef float e1CBIDTightNoIso_value

    cdef TBranch* e1CBIDVeto_branch
    cdef float e1CBIDVeto_value

    cdef TBranch* e1CBIDVetoNoIso_branch
    cdef float e1CBIDVetoNoIso_value

    cdef TBranch* e1Charge_branch
    cdef float e1Charge_value

    cdef TBranch* e1ChargeIdLoose_branch
    cdef float e1ChargeIdLoose_value

    cdef TBranch* e1ChargeIdMed_branch
    cdef float e1ChargeIdMed_value

    cdef TBranch* e1ChargeIdTight_branch
    cdef float e1ChargeIdTight_value

    cdef TBranch* e1ComesFromHiggs_branch
    cdef float e1ComesFromHiggs_value

    cdef TBranch* e1DPhiToPfMet_ElectronEnDown_branch
    cdef float e1DPhiToPfMet_ElectronEnDown_value

    cdef TBranch* e1DPhiToPfMet_ElectronEnUp_branch
    cdef float e1DPhiToPfMet_ElectronEnUp_value

    cdef TBranch* e1DPhiToPfMet_JetEnDown_branch
    cdef float e1DPhiToPfMet_JetEnDown_value

    cdef TBranch* e1DPhiToPfMet_JetEnUp_branch
    cdef float e1DPhiToPfMet_JetEnUp_value

    cdef TBranch* e1DPhiToPfMet_JetResDown_branch
    cdef float e1DPhiToPfMet_JetResDown_value

    cdef TBranch* e1DPhiToPfMet_JetResUp_branch
    cdef float e1DPhiToPfMet_JetResUp_value

    cdef TBranch* e1DPhiToPfMet_MuonEnDown_branch
    cdef float e1DPhiToPfMet_MuonEnDown_value

    cdef TBranch* e1DPhiToPfMet_MuonEnUp_branch
    cdef float e1DPhiToPfMet_MuonEnUp_value

    cdef TBranch* e1DPhiToPfMet_PhotonEnDown_branch
    cdef float e1DPhiToPfMet_PhotonEnDown_value

    cdef TBranch* e1DPhiToPfMet_PhotonEnUp_branch
    cdef float e1DPhiToPfMet_PhotonEnUp_value

    cdef TBranch* e1DPhiToPfMet_TauEnDown_branch
    cdef float e1DPhiToPfMet_TauEnDown_value

    cdef TBranch* e1DPhiToPfMet_TauEnUp_branch
    cdef float e1DPhiToPfMet_TauEnUp_value

    cdef TBranch* e1DPhiToPfMet_UnclusteredEnDown_branch
    cdef float e1DPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* e1DPhiToPfMet_UnclusteredEnUp_branch
    cdef float e1DPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* e1DPhiToPfMet_type1_branch
    cdef float e1DPhiToPfMet_type1_value

    cdef TBranch* e1E1x5_branch
    cdef float e1E1x5_value

    cdef TBranch* e1E2x5Max_branch
    cdef float e1E2x5Max_value

    cdef TBranch* e1E5x5_branch
    cdef float e1E5x5_value

    cdef TBranch* e1EcalIsoDR03_branch
    cdef float e1EcalIsoDR03_value

    cdef TBranch* e1EffectiveArea2012Data_branch
    cdef float e1EffectiveArea2012Data_value

    cdef TBranch* e1EffectiveAreaSpring15_branch
    cdef float e1EffectiveAreaSpring15_value

    cdef TBranch* e1EnergyError_branch
    cdef float e1EnergyError_value

    cdef TBranch* e1Eta_branch
    cdef float e1Eta_value

    cdef TBranch* e1Eta_ElectronEnDown_branch
    cdef float e1Eta_ElectronEnDown_value

    cdef TBranch* e1Eta_ElectronEnUp_branch
    cdef float e1Eta_ElectronEnUp_value

    cdef TBranch* e1GenCharge_branch
    cdef float e1GenCharge_value

    cdef TBranch* e1GenEnergy_branch
    cdef float e1GenEnergy_value

    cdef TBranch* e1GenEta_branch
    cdef float e1GenEta_value

    cdef TBranch* e1GenMotherPdgId_branch
    cdef float e1GenMotherPdgId_value

    cdef TBranch* e1GenParticle_branch
    cdef float e1GenParticle_value

    cdef TBranch* e1GenPdgId_branch
    cdef float e1GenPdgId_value

    cdef TBranch* e1GenPhi_branch
    cdef float e1GenPhi_value

    cdef TBranch* e1GenPrompt_branch
    cdef float e1GenPrompt_value

    cdef TBranch* e1GenPromptTauDecay_branch
    cdef float e1GenPromptTauDecay_value

    cdef TBranch* e1GenPt_branch
    cdef float e1GenPt_value

    cdef TBranch* e1GenTauDecay_branch
    cdef float e1GenTauDecay_value

    cdef TBranch* e1GenVZ_branch
    cdef float e1GenVZ_value

    cdef TBranch* e1GenVtxPVMatch_branch
    cdef float e1GenVtxPVMatch_value

    cdef TBranch* e1HadronicDepth1OverEm_branch
    cdef float e1HadronicDepth1OverEm_value

    cdef TBranch* e1HadronicDepth2OverEm_branch
    cdef float e1HadronicDepth2OverEm_value

    cdef TBranch* e1HadronicOverEM_branch
    cdef float e1HadronicOverEM_value

    cdef TBranch* e1HcalIsoDR03_branch
    cdef float e1HcalIsoDR03_value

    cdef TBranch* e1IP3D_branch
    cdef float e1IP3D_value

    cdef TBranch* e1IP3DErr_branch
    cdef float e1IP3DErr_value

    cdef TBranch* e1JetArea_branch
    cdef float e1JetArea_value

    cdef TBranch* e1JetBtag_branch
    cdef float e1JetBtag_value

    cdef TBranch* e1JetEtaEtaMoment_branch
    cdef float e1JetEtaEtaMoment_value

    cdef TBranch* e1JetEtaPhiMoment_branch
    cdef float e1JetEtaPhiMoment_value

    cdef TBranch* e1JetEtaPhiSpread_branch
    cdef float e1JetEtaPhiSpread_value

    cdef TBranch* e1JetPFCISVBtag_branch
    cdef float e1JetPFCISVBtag_value

    cdef TBranch* e1JetPartonFlavour_branch
    cdef float e1JetPartonFlavour_value

    cdef TBranch* e1JetPhiPhiMoment_branch
    cdef float e1JetPhiPhiMoment_value

    cdef TBranch* e1JetPt_branch
    cdef float e1JetPt_value

    cdef TBranch* e1LowestMll_branch
    cdef float e1LowestMll_value

    cdef TBranch* e1MVANonTrigCategory_branch
    cdef float e1MVANonTrigCategory_value

    cdef TBranch* e1MVANonTrigID_branch
    cdef float e1MVANonTrigID_value

    cdef TBranch* e1MVANonTrigWP80_branch
    cdef float e1MVANonTrigWP80_value

    cdef TBranch* e1MVANonTrigWP90_branch
    cdef float e1MVANonTrigWP90_value

    cdef TBranch* e1MVATrigCategory_branch
    cdef float e1MVATrigCategory_value

    cdef TBranch* e1MVATrigID_branch
    cdef float e1MVATrigID_value

    cdef TBranch* e1MVATrigWP80_branch
    cdef float e1MVATrigWP80_value

    cdef TBranch* e1MVATrigWP90_branch
    cdef float e1MVATrigWP90_value

    cdef TBranch* e1Mass_branch
    cdef float e1Mass_value

    cdef TBranch* e1MatchesDoubleE_branch
    cdef float e1MatchesDoubleE_value

    cdef TBranch* e1MatchesDoubleESingleMu_branch
    cdef float e1MatchesDoubleESingleMu_value

    cdef TBranch* e1MatchesDoubleMuSingleE_branch
    cdef float e1MatchesDoubleMuSingleE_value

    cdef TBranch* e1MatchesSingleE_branch
    cdef float e1MatchesSingleE_value

    cdef TBranch* e1MatchesSingleESingleMu_branch
    cdef float e1MatchesSingleESingleMu_value

    cdef TBranch* e1MatchesSingleE_leg1_branch
    cdef float e1MatchesSingleE_leg1_value

    cdef TBranch* e1MatchesSingleE_leg2_branch
    cdef float e1MatchesSingleE_leg2_value

    cdef TBranch* e1MatchesSingleMuSingleE_branch
    cdef float e1MatchesSingleMuSingleE_value

    cdef TBranch* e1MatchesTripleE_branch
    cdef float e1MatchesTripleE_value

    cdef TBranch* e1MissingHits_branch
    cdef float e1MissingHits_value

    cdef TBranch* e1MtToPfMet_ElectronEnDown_branch
    cdef float e1MtToPfMet_ElectronEnDown_value

    cdef TBranch* e1MtToPfMet_ElectronEnUp_branch
    cdef float e1MtToPfMet_ElectronEnUp_value

    cdef TBranch* e1MtToPfMet_JetEnDown_branch
    cdef float e1MtToPfMet_JetEnDown_value

    cdef TBranch* e1MtToPfMet_JetEnUp_branch
    cdef float e1MtToPfMet_JetEnUp_value

    cdef TBranch* e1MtToPfMet_JetResDown_branch
    cdef float e1MtToPfMet_JetResDown_value

    cdef TBranch* e1MtToPfMet_JetResUp_branch
    cdef float e1MtToPfMet_JetResUp_value

    cdef TBranch* e1MtToPfMet_MuonEnDown_branch
    cdef float e1MtToPfMet_MuonEnDown_value

    cdef TBranch* e1MtToPfMet_MuonEnUp_branch
    cdef float e1MtToPfMet_MuonEnUp_value

    cdef TBranch* e1MtToPfMet_PhotonEnDown_branch
    cdef float e1MtToPfMet_PhotonEnDown_value

    cdef TBranch* e1MtToPfMet_PhotonEnUp_branch
    cdef float e1MtToPfMet_PhotonEnUp_value

    cdef TBranch* e1MtToPfMet_Raw_branch
    cdef float e1MtToPfMet_Raw_value

    cdef TBranch* e1MtToPfMet_TauEnDown_branch
    cdef float e1MtToPfMet_TauEnDown_value

    cdef TBranch* e1MtToPfMet_TauEnUp_branch
    cdef float e1MtToPfMet_TauEnUp_value

    cdef TBranch* e1MtToPfMet_UnclusteredEnDown_branch
    cdef float e1MtToPfMet_UnclusteredEnDown_value

    cdef TBranch* e1MtToPfMet_UnclusteredEnUp_branch
    cdef float e1MtToPfMet_UnclusteredEnUp_value

    cdef TBranch* e1MtToPfMet_type1_branch
    cdef float e1MtToPfMet_type1_value

    cdef TBranch* e1NearMuonVeto_branch
    cdef float e1NearMuonVeto_value

    cdef TBranch* e1NearestMuonDR_branch
    cdef float e1NearestMuonDR_value

    cdef TBranch* e1NearestZMass_branch
    cdef float e1NearestZMass_value

    cdef TBranch* e1PFChargedIso_branch
    cdef float e1PFChargedIso_value

    cdef TBranch* e1PFNeutralIso_branch
    cdef float e1PFNeutralIso_value

    cdef TBranch* e1PFPUChargedIso_branch
    cdef float e1PFPUChargedIso_value

    cdef TBranch* e1PFPhotonIso_branch
    cdef float e1PFPhotonIso_value

    cdef TBranch* e1PVDXY_branch
    cdef float e1PVDXY_value

    cdef TBranch* e1PVDZ_branch
    cdef float e1PVDZ_value

    cdef TBranch* e1PassesConversionVeto_branch
    cdef float e1PassesConversionVeto_value

    cdef TBranch* e1Phi_branch
    cdef float e1Phi_value

    cdef TBranch* e1Phi_ElectronEnDown_branch
    cdef float e1Phi_ElectronEnDown_value

    cdef TBranch* e1Phi_ElectronEnUp_branch
    cdef float e1Phi_ElectronEnUp_value

    cdef TBranch* e1Pt_branch
    cdef float e1Pt_value

    cdef TBranch* e1Pt_ElectronEnDown_branch
    cdef float e1Pt_ElectronEnDown_value

    cdef TBranch* e1Pt_ElectronEnUp_branch
    cdef float e1Pt_ElectronEnUp_value

    cdef TBranch* e1Rank_branch
    cdef float e1Rank_value

    cdef TBranch* e1RelIso_branch
    cdef float e1RelIso_value

    cdef TBranch* e1RelPFIsoDB_branch
    cdef float e1RelPFIsoDB_value

    cdef TBranch* e1RelPFIsoRho_branch
    cdef float e1RelPFIsoRho_value

    cdef TBranch* e1Rho_branch
    cdef float e1Rho_value

    cdef TBranch* e1SCEnergy_branch
    cdef float e1SCEnergy_value

    cdef TBranch* e1SCEta_branch
    cdef float e1SCEta_value

    cdef TBranch* e1SCEtaWidth_branch
    cdef float e1SCEtaWidth_value

    cdef TBranch* e1SCPhi_branch
    cdef float e1SCPhi_value

    cdef TBranch* e1SCPhiWidth_branch
    cdef float e1SCPhiWidth_value

    cdef TBranch* e1SCPreshowerEnergy_branch
    cdef float e1SCPreshowerEnergy_value

    cdef TBranch* e1SCRawEnergy_branch
    cdef float e1SCRawEnergy_value

    cdef TBranch* e1SIP2D_branch
    cdef float e1SIP2D_value

    cdef TBranch* e1SIP3D_branch
    cdef float e1SIP3D_value

    cdef TBranch* e1SigmaIEtaIEta_branch
    cdef float e1SigmaIEtaIEta_value

    cdef TBranch* e1TrkIsoDR03_branch
    cdef float e1TrkIsoDR03_value

    cdef TBranch* e1VZ_branch
    cdef float e1VZ_value

    cdef TBranch* e1WWLoose_branch
    cdef float e1WWLoose_value

    cdef TBranch* e1_e2_CosThetaStar_branch
    cdef float e1_e2_CosThetaStar_value

    cdef TBranch* e1_e2_DPhi_branch
    cdef float e1_e2_DPhi_value

    cdef TBranch* e1_e2_DR_branch
    cdef float e1_e2_DR_value

    cdef TBranch* e1_e2_Eta_branch
    cdef float e1_e2_Eta_value

    cdef TBranch* e1_e2_Mass_branch
    cdef float e1_e2_Mass_value

    cdef TBranch* e1_e2_Mt_branch
    cdef float e1_e2_Mt_value

    cdef TBranch* e1_e2_PZeta_branch
    cdef float e1_e2_PZeta_value

    cdef TBranch* e1_e2_PZetaVis_branch
    cdef float e1_e2_PZetaVis_value

    cdef TBranch* e1_e2_Phi_branch
    cdef float e1_e2_Phi_value

    cdef TBranch* e1_e2_Pt_branch
    cdef float e1_e2_Pt_value

    cdef TBranch* e1_e2_SS_branch
    cdef float e1_e2_SS_value

    cdef TBranch* e1_e2_ToMETDPhi_Ty1_branch
    cdef float e1_e2_ToMETDPhi_Ty1_value

    cdef TBranch* e1_e2_collinearmass_branch
    cdef float e1_e2_collinearmass_value

    cdef TBranch* e1_e2_collinearmass_JetEnDown_branch
    cdef float e1_e2_collinearmass_JetEnDown_value

    cdef TBranch* e1_e2_collinearmass_JetEnUp_branch
    cdef float e1_e2_collinearmass_JetEnUp_value

    cdef TBranch* e1_e2_collinearmass_UnclusteredEnDown_branch
    cdef float e1_e2_collinearmass_UnclusteredEnDown_value

    cdef TBranch* e1_e2_collinearmass_UnclusteredEnUp_branch
    cdef float e1_e2_collinearmass_UnclusteredEnUp_value

    cdef TBranch* e1_e3_CosThetaStar_branch
    cdef float e1_e3_CosThetaStar_value

    cdef TBranch* e1_e3_DPhi_branch
    cdef float e1_e3_DPhi_value

    cdef TBranch* e1_e3_DR_branch
    cdef float e1_e3_DR_value

    cdef TBranch* e1_e3_Eta_branch
    cdef float e1_e3_Eta_value

    cdef TBranch* e1_e3_Mass_branch
    cdef float e1_e3_Mass_value

    cdef TBranch* e1_e3_Mt_branch
    cdef float e1_e3_Mt_value

    cdef TBranch* e1_e3_PZeta_branch
    cdef float e1_e3_PZeta_value

    cdef TBranch* e1_e3_PZetaVis_branch
    cdef float e1_e3_PZetaVis_value

    cdef TBranch* e1_e3_Phi_branch
    cdef float e1_e3_Phi_value

    cdef TBranch* e1_e3_Pt_branch
    cdef float e1_e3_Pt_value

    cdef TBranch* e1_e3_SS_branch
    cdef float e1_e3_SS_value

    cdef TBranch* e1_e3_ToMETDPhi_Ty1_branch
    cdef float e1_e3_ToMETDPhi_Ty1_value

    cdef TBranch* e1_e3_collinearmass_branch
    cdef float e1_e3_collinearmass_value

    cdef TBranch* e1_e3_collinearmass_JetEnDown_branch
    cdef float e1_e3_collinearmass_JetEnDown_value

    cdef TBranch* e1_e3_collinearmass_JetEnUp_branch
    cdef float e1_e3_collinearmass_JetEnUp_value

    cdef TBranch* e1_e3_collinearmass_UnclusteredEnDown_branch
    cdef float e1_e3_collinearmass_UnclusteredEnDown_value

    cdef TBranch* e1_e3_collinearmass_UnclusteredEnUp_branch
    cdef float e1_e3_collinearmass_UnclusteredEnUp_value

    cdef TBranch* e1deltaEtaSuperClusterTrackAtVtx_branch
    cdef float e1deltaEtaSuperClusterTrackAtVtx_value

    cdef TBranch* e1deltaPhiSuperClusterTrackAtVtx_branch
    cdef float e1deltaPhiSuperClusterTrackAtVtx_value

    cdef TBranch* e1eSuperClusterOverP_branch
    cdef float e1eSuperClusterOverP_value

    cdef TBranch* e1ecalEnergy_branch
    cdef float e1ecalEnergy_value

    cdef TBranch* e1fBrem_branch
    cdef float e1fBrem_value

    cdef TBranch* e1trackMomentumAtVtxP_branch
    cdef float e1trackMomentumAtVtxP_value

    cdef TBranch* e2AbsEta_branch
    cdef float e2AbsEta_value

    cdef TBranch* e2CBIDLoose_branch
    cdef float e2CBIDLoose_value

    cdef TBranch* e2CBIDLooseNoIso_branch
    cdef float e2CBIDLooseNoIso_value

    cdef TBranch* e2CBIDMedium_branch
    cdef float e2CBIDMedium_value

    cdef TBranch* e2CBIDMediumNoIso_branch
    cdef float e2CBIDMediumNoIso_value

    cdef TBranch* e2CBIDTight_branch
    cdef float e2CBIDTight_value

    cdef TBranch* e2CBIDTightNoIso_branch
    cdef float e2CBIDTightNoIso_value

    cdef TBranch* e2CBIDVeto_branch
    cdef float e2CBIDVeto_value

    cdef TBranch* e2CBIDVetoNoIso_branch
    cdef float e2CBIDVetoNoIso_value

    cdef TBranch* e2Charge_branch
    cdef float e2Charge_value

    cdef TBranch* e2ChargeIdLoose_branch
    cdef float e2ChargeIdLoose_value

    cdef TBranch* e2ChargeIdMed_branch
    cdef float e2ChargeIdMed_value

    cdef TBranch* e2ChargeIdTight_branch
    cdef float e2ChargeIdTight_value

    cdef TBranch* e2ComesFromHiggs_branch
    cdef float e2ComesFromHiggs_value

    cdef TBranch* e2DPhiToPfMet_ElectronEnDown_branch
    cdef float e2DPhiToPfMet_ElectronEnDown_value

    cdef TBranch* e2DPhiToPfMet_ElectronEnUp_branch
    cdef float e2DPhiToPfMet_ElectronEnUp_value

    cdef TBranch* e2DPhiToPfMet_JetEnDown_branch
    cdef float e2DPhiToPfMet_JetEnDown_value

    cdef TBranch* e2DPhiToPfMet_JetEnUp_branch
    cdef float e2DPhiToPfMet_JetEnUp_value

    cdef TBranch* e2DPhiToPfMet_JetResDown_branch
    cdef float e2DPhiToPfMet_JetResDown_value

    cdef TBranch* e2DPhiToPfMet_JetResUp_branch
    cdef float e2DPhiToPfMet_JetResUp_value

    cdef TBranch* e2DPhiToPfMet_MuonEnDown_branch
    cdef float e2DPhiToPfMet_MuonEnDown_value

    cdef TBranch* e2DPhiToPfMet_MuonEnUp_branch
    cdef float e2DPhiToPfMet_MuonEnUp_value

    cdef TBranch* e2DPhiToPfMet_PhotonEnDown_branch
    cdef float e2DPhiToPfMet_PhotonEnDown_value

    cdef TBranch* e2DPhiToPfMet_PhotonEnUp_branch
    cdef float e2DPhiToPfMet_PhotonEnUp_value

    cdef TBranch* e2DPhiToPfMet_TauEnDown_branch
    cdef float e2DPhiToPfMet_TauEnDown_value

    cdef TBranch* e2DPhiToPfMet_TauEnUp_branch
    cdef float e2DPhiToPfMet_TauEnUp_value

    cdef TBranch* e2DPhiToPfMet_UnclusteredEnDown_branch
    cdef float e2DPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* e2DPhiToPfMet_UnclusteredEnUp_branch
    cdef float e2DPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* e2DPhiToPfMet_type1_branch
    cdef float e2DPhiToPfMet_type1_value

    cdef TBranch* e2E1x5_branch
    cdef float e2E1x5_value

    cdef TBranch* e2E2x5Max_branch
    cdef float e2E2x5Max_value

    cdef TBranch* e2E5x5_branch
    cdef float e2E5x5_value

    cdef TBranch* e2EcalIsoDR03_branch
    cdef float e2EcalIsoDR03_value

    cdef TBranch* e2EffectiveArea2012Data_branch
    cdef float e2EffectiveArea2012Data_value

    cdef TBranch* e2EffectiveAreaSpring15_branch
    cdef float e2EffectiveAreaSpring15_value

    cdef TBranch* e2EnergyError_branch
    cdef float e2EnergyError_value

    cdef TBranch* e2Eta_branch
    cdef float e2Eta_value

    cdef TBranch* e2Eta_ElectronEnDown_branch
    cdef float e2Eta_ElectronEnDown_value

    cdef TBranch* e2Eta_ElectronEnUp_branch
    cdef float e2Eta_ElectronEnUp_value

    cdef TBranch* e2GenCharge_branch
    cdef float e2GenCharge_value

    cdef TBranch* e2GenEnergy_branch
    cdef float e2GenEnergy_value

    cdef TBranch* e2GenEta_branch
    cdef float e2GenEta_value

    cdef TBranch* e2GenMotherPdgId_branch
    cdef float e2GenMotherPdgId_value

    cdef TBranch* e2GenParticle_branch
    cdef float e2GenParticle_value

    cdef TBranch* e2GenPdgId_branch
    cdef float e2GenPdgId_value

    cdef TBranch* e2GenPhi_branch
    cdef float e2GenPhi_value

    cdef TBranch* e2GenPrompt_branch
    cdef float e2GenPrompt_value

    cdef TBranch* e2GenPromptTauDecay_branch
    cdef float e2GenPromptTauDecay_value

    cdef TBranch* e2GenPt_branch
    cdef float e2GenPt_value

    cdef TBranch* e2GenTauDecay_branch
    cdef float e2GenTauDecay_value

    cdef TBranch* e2GenVZ_branch
    cdef float e2GenVZ_value

    cdef TBranch* e2GenVtxPVMatch_branch
    cdef float e2GenVtxPVMatch_value

    cdef TBranch* e2HadronicDepth1OverEm_branch
    cdef float e2HadronicDepth1OverEm_value

    cdef TBranch* e2HadronicDepth2OverEm_branch
    cdef float e2HadronicDepth2OverEm_value

    cdef TBranch* e2HadronicOverEM_branch
    cdef float e2HadronicOverEM_value

    cdef TBranch* e2HcalIsoDR03_branch
    cdef float e2HcalIsoDR03_value

    cdef TBranch* e2IP3D_branch
    cdef float e2IP3D_value

    cdef TBranch* e2IP3DErr_branch
    cdef float e2IP3DErr_value

    cdef TBranch* e2JetArea_branch
    cdef float e2JetArea_value

    cdef TBranch* e2JetBtag_branch
    cdef float e2JetBtag_value

    cdef TBranch* e2JetEtaEtaMoment_branch
    cdef float e2JetEtaEtaMoment_value

    cdef TBranch* e2JetEtaPhiMoment_branch
    cdef float e2JetEtaPhiMoment_value

    cdef TBranch* e2JetEtaPhiSpread_branch
    cdef float e2JetEtaPhiSpread_value

    cdef TBranch* e2JetPFCISVBtag_branch
    cdef float e2JetPFCISVBtag_value

    cdef TBranch* e2JetPartonFlavour_branch
    cdef float e2JetPartonFlavour_value

    cdef TBranch* e2JetPhiPhiMoment_branch
    cdef float e2JetPhiPhiMoment_value

    cdef TBranch* e2JetPt_branch
    cdef float e2JetPt_value

    cdef TBranch* e2LowestMll_branch
    cdef float e2LowestMll_value

    cdef TBranch* e2MVANonTrigCategory_branch
    cdef float e2MVANonTrigCategory_value

    cdef TBranch* e2MVANonTrigID_branch
    cdef float e2MVANonTrigID_value

    cdef TBranch* e2MVANonTrigWP80_branch
    cdef float e2MVANonTrigWP80_value

    cdef TBranch* e2MVANonTrigWP90_branch
    cdef float e2MVANonTrigWP90_value

    cdef TBranch* e2MVATrigCategory_branch
    cdef float e2MVATrigCategory_value

    cdef TBranch* e2MVATrigID_branch
    cdef float e2MVATrigID_value

    cdef TBranch* e2MVATrigWP80_branch
    cdef float e2MVATrigWP80_value

    cdef TBranch* e2MVATrigWP90_branch
    cdef float e2MVATrigWP90_value

    cdef TBranch* e2Mass_branch
    cdef float e2Mass_value

    cdef TBranch* e2MatchesDoubleE_branch
    cdef float e2MatchesDoubleE_value

    cdef TBranch* e2MatchesDoubleESingleMu_branch
    cdef float e2MatchesDoubleESingleMu_value

    cdef TBranch* e2MatchesDoubleMuSingleE_branch
    cdef float e2MatchesDoubleMuSingleE_value

    cdef TBranch* e2MatchesSingleE_branch
    cdef float e2MatchesSingleE_value

    cdef TBranch* e2MatchesSingleESingleMu_branch
    cdef float e2MatchesSingleESingleMu_value

    cdef TBranch* e2MatchesSingleE_leg1_branch
    cdef float e2MatchesSingleE_leg1_value

    cdef TBranch* e2MatchesSingleE_leg2_branch
    cdef float e2MatchesSingleE_leg2_value

    cdef TBranch* e2MatchesSingleMuSingleE_branch
    cdef float e2MatchesSingleMuSingleE_value

    cdef TBranch* e2MatchesTripleE_branch
    cdef float e2MatchesTripleE_value

    cdef TBranch* e2MissingHits_branch
    cdef float e2MissingHits_value

    cdef TBranch* e2MtToPfMet_ElectronEnDown_branch
    cdef float e2MtToPfMet_ElectronEnDown_value

    cdef TBranch* e2MtToPfMet_ElectronEnUp_branch
    cdef float e2MtToPfMet_ElectronEnUp_value

    cdef TBranch* e2MtToPfMet_JetEnDown_branch
    cdef float e2MtToPfMet_JetEnDown_value

    cdef TBranch* e2MtToPfMet_JetEnUp_branch
    cdef float e2MtToPfMet_JetEnUp_value

    cdef TBranch* e2MtToPfMet_JetResDown_branch
    cdef float e2MtToPfMet_JetResDown_value

    cdef TBranch* e2MtToPfMet_JetResUp_branch
    cdef float e2MtToPfMet_JetResUp_value

    cdef TBranch* e2MtToPfMet_MuonEnDown_branch
    cdef float e2MtToPfMet_MuonEnDown_value

    cdef TBranch* e2MtToPfMet_MuonEnUp_branch
    cdef float e2MtToPfMet_MuonEnUp_value

    cdef TBranch* e2MtToPfMet_PhotonEnDown_branch
    cdef float e2MtToPfMet_PhotonEnDown_value

    cdef TBranch* e2MtToPfMet_PhotonEnUp_branch
    cdef float e2MtToPfMet_PhotonEnUp_value

    cdef TBranch* e2MtToPfMet_Raw_branch
    cdef float e2MtToPfMet_Raw_value

    cdef TBranch* e2MtToPfMet_TauEnDown_branch
    cdef float e2MtToPfMet_TauEnDown_value

    cdef TBranch* e2MtToPfMet_TauEnUp_branch
    cdef float e2MtToPfMet_TauEnUp_value

    cdef TBranch* e2MtToPfMet_UnclusteredEnDown_branch
    cdef float e2MtToPfMet_UnclusteredEnDown_value

    cdef TBranch* e2MtToPfMet_UnclusteredEnUp_branch
    cdef float e2MtToPfMet_UnclusteredEnUp_value

    cdef TBranch* e2MtToPfMet_type1_branch
    cdef float e2MtToPfMet_type1_value

    cdef TBranch* e2NearMuonVeto_branch
    cdef float e2NearMuonVeto_value

    cdef TBranch* e2NearestMuonDR_branch
    cdef float e2NearestMuonDR_value

    cdef TBranch* e2NearestZMass_branch
    cdef float e2NearestZMass_value

    cdef TBranch* e2PFChargedIso_branch
    cdef float e2PFChargedIso_value

    cdef TBranch* e2PFNeutralIso_branch
    cdef float e2PFNeutralIso_value

    cdef TBranch* e2PFPUChargedIso_branch
    cdef float e2PFPUChargedIso_value

    cdef TBranch* e2PFPhotonIso_branch
    cdef float e2PFPhotonIso_value

    cdef TBranch* e2PVDXY_branch
    cdef float e2PVDXY_value

    cdef TBranch* e2PVDZ_branch
    cdef float e2PVDZ_value

    cdef TBranch* e2PassesConversionVeto_branch
    cdef float e2PassesConversionVeto_value

    cdef TBranch* e2Phi_branch
    cdef float e2Phi_value

    cdef TBranch* e2Phi_ElectronEnDown_branch
    cdef float e2Phi_ElectronEnDown_value

    cdef TBranch* e2Phi_ElectronEnUp_branch
    cdef float e2Phi_ElectronEnUp_value

    cdef TBranch* e2Pt_branch
    cdef float e2Pt_value

    cdef TBranch* e2Pt_ElectronEnDown_branch
    cdef float e2Pt_ElectronEnDown_value

    cdef TBranch* e2Pt_ElectronEnUp_branch
    cdef float e2Pt_ElectronEnUp_value

    cdef TBranch* e2Rank_branch
    cdef float e2Rank_value

    cdef TBranch* e2RelIso_branch
    cdef float e2RelIso_value

    cdef TBranch* e2RelPFIsoDB_branch
    cdef float e2RelPFIsoDB_value

    cdef TBranch* e2RelPFIsoRho_branch
    cdef float e2RelPFIsoRho_value

    cdef TBranch* e2Rho_branch
    cdef float e2Rho_value

    cdef TBranch* e2SCEnergy_branch
    cdef float e2SCEnergy_value

    cdef TBranch* e2SCEta_branch
    cdef float e2SCEta_value

    cdef TBranch* e2SCEtaWidth_branch
    cdef float e2SCEtaWidth_value

    cdef TBranch* e2SCPhi_branch
    cdef float e2SCPhi_value

    cdef TBranch* e2SCPhiWidth_branch
    cdef float e2SCPhiWidth_value

    cdef TBranch* e2SCPreshowerEnergy_branch
    cdef float e2SCPreshowerEnergy_value

    cdef TBranch* e2SCRawEnergy_branch
    cdef float e2SCRawEnergy_value

    cdef TBranch* e2SIP2D_branch
    cdef float e2SIP2D_value

    cdef TBranch* e2SIP3D_branch
    cdef float e2SIP3D_value

    cdef TBranch* e2SigmaIEtaIEta_branch
    cdef float e2SigmaIEtaIEta_value

    cdef TBranch* e2TrkIsoDR03_branch
    cdef float e2TrkIsoDR03_value

    cdef TBranch* e2VZ_branch
    cdef float e2VZ_value

    cdef TBranch* e2WWLoose_branch
    cdef float e2WWLoose_value

    cdef TBranch* e2_e1_collinearmass_branch
    cdef float e2_e1_collinearmass_value

    cdef TBranch* e2_e1_collinearmass_JetEnDown_branch
    cdef float e2_e1_collinearmass_JetEnDown_value

    cdef TBranch* e2_e1_collinearmass_JetEnUp_branch
    cdef float e2_e1_collinearmass_JetEnUp_value

    cdef TBranch* e2_e1_collinearmass_UnclusteredEnDown_branch
    cdef float e2_e1_collinearmass_UnclusteredEnDown_value

    cdef TBranch* e2_e1_collinearmass_UnclusteredEnUp_branch
    cdef float e2_e1_collinearmass_UnclusteredEnUp_value

    cdef TBranch* e2_e3_CosThetaStar_branch
    cdef float e2_e3_CosThetaStar_value

    cdef TBranch* e2_e3_DPhi_branch
    cdef float e2_e3_DPhi_value

    cdef TBranch* e2_e3_DR_branch
    cdef float e2_e3_DR_value

    cdef TBranch* e2_e3_Eta_branch
    cdef float e2_e3_Eta_value

    cdef TBranch* e2_e3_Mass_branch
    cdef float e2_e3_Mass_value

    cdef TBranch* e2_e3_Mt_branch
    cdef float e2_e3_Mt_value

    cdef TBranch* e2_e3_PZeta_branch
    cdef float e2_e3_PZeta_value

    cdef TBranch* e2_e3_PZetaVis_branch
    cdef float e2_e3_PZetaVis_value

    cdef TBranch* e2_e3_Phi_branch
    cdef float e2_e3_Phi_value

    cdef TBranch* e2_e3_Pt_branch
    cdef float e2_e3_Pt_value

    cdef TBranch* e2_e3_SS_branch
    cdef float e2_e3_SS_value

    cdef TBranch* e2_e3_ToMETDPhi_Ty1_branch
    cdef float e2_e3_ToMETDPhi_Ty1_value

    cdef TBranch* e2_e3_collinearmass_branch
    cdef float e2_e3_collinearmass_value

    cdef TBranch* e2_e3_collinearmass_JetEnDown_branch
    cdef float e2_e3_collinearmass_JetEnDown_value

    cdef TBranch* e2_e3_collinearmass_JetEnUp_branch
    cdef float e2_e3_collinearmass_JetEnUp_value

    cdef TBranch* e2_e3_collinearmass_UnclusteredEnDown_branch
    cdef float e2_e3_collinearmass_UnclusteredEnDown_value

    cdef TBranch* e2_e3_collinearmass_UnclusteredEnUp_branch
    cdef float e2_e3_collinearmass_UnclusteredEnUp_value

    cdef TBranch* e2deltaEtaSuperClusterTrackAtVtx_branch
    cdef float e2deltaEtaSuperClusterTrackAtVtx_value

    cdef TBranch* e2deltaPhiSuperClusterTrackAtVtx_branch
    cdef float e2deltaPhiSuperClusterTrackAtVtx_value

    cdef TBranch* e2eSuperClusterOverP_branch
    cdef float e2eSuperClusterOverP_value

    cdef TBranch* e2ecalEnergy_branch
    cdef float e2ecalEnergy_value

    cdef TBranch* e2fBrem_branch
    cdef float e2fBrem_value

    cdef TBranch* e2trackMomentumAtVtxP_branch
    cdef float e2trackMomentumAtVtxP_value

    cdef TBranch* e3AbsEta_branch
    cdef float e3AbsEta_value

    cdef TBranch* e3CBIDLoose_branch
    cdef float e3CBIDLoose_value

    cdef TBranch* e3CBIDLooseNoIso_branch
    cdef float e3CBIDLooseNoIso_value

    cdef TBranch* e3CBIDMedium_branch
    cdef float e3CBIDMedium_value

    cdef TBranch* e3CBIDMediumNoIso_branch
    cdef float e3CBIDMediumNoIso_value

    cdef TBranch* e3CBIDTight_branch
    cdef float e3CBIDTight_value

    cdef TBranch* e3CBIDTightNoIso_branch
    cdef float e3CBIDTightNoIso_value

    cdef TBranch* e3CBIDVeto_branch
    cdef float e3CBIDVeto_value

    cdef TBranch* e3CBIDVetoNoIso_branch
    cdef float e3CBIDVetoNoIso_value

    cdef TBranch* e3Charge_branch
    cdef float e3Charge_value

    cdef TBranch* e3ChargeIdLoose_branch
    cdef float e3ChargeIdLoose_value

    cdef TBranch* e3ChargeIdMed_branch
    cdef float e3ChargeIdMed_value

    cdef TBranch* e3ChargeIdTight_branch
    cdef float e3ChargeIdTight_value

    cdef TBranch* e3ComesFromHiggs_branch
    cdef float e3ComesFromHiggs_value

    cdef TBranch* e3DPhiToPfMet_ElectronEnDown_branch
    cdef float e3DPhiToPfMet_ElectronEnDown_value

    cdef TBranch* e3DPhiToPfMet_ElectronEnUp_branch
    cdef float e3DPhiToPfMet_ElectronEnUp_value

    cdef TBranch* e3DPhiToPfMet_JetEnDown_branch
    cdef float e3DPhiToPfMet_JetEnDown_value

    cdef TBranch* e3DPhiToPfMet_JetEnUp_branch
    cdef float e3DPhiToPfMet_JetEnUp_value

    cdef TBranch* e3DPhiToPfMet_JetResDown_branch
    cdef float e3DPhiToPfMet_JetResDown_value

    cdef TBranch* e3DPhiToPfMet_JetResUp_branch
    cdef float e3DPhiToPfMet_JetResUp_value

    cdef TBranch* e3DPhiToPfMet_MuonEnDown_branch
    cdef float e3DPhiToPfMet_MuonEnDown_value

    cdef TBranch* e3DPhiToPfMet_MuonEnUp_branch
    cdef float e3DPhiToPfMet_MuonEnUp_value

    cdef TBranch* e3DPhiToPfMet_PhotonEnDown_branch
    cdef float e3DPhiToPfMet_PhotonEnDown_value

    cdef TBranch* e3DPhiToPfMet_PhotonEnUp_branch
    cdef float e3DPhiToPfMet_PhotonEnUp_value

    cdef TBranch* e3DPhiToPfMet_TauEnDown_branch
    cdef float e3DPhiToPfMet_TauEnDown_value

    cdef TBranch* e3DPhiToPfMet_TauEnUp_branch
    cdef float e3DPhiToPfMet_TauEnUp_value

    cdef TBranch* e3DPhiToPfMet_UnclusteredEnDown_branch
    cdef float e3DPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* e3DPhiToPfMet_UnclusteredEnUp_branch
    cdef float e3DPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* e3DPhiToPfMet_type1_branch
    cdef float e3DPhiToPfMet_type1_value

    cdef TBranch* e3E1x5_branch
    cdef float e3E1x5_value

    cdef TBranch* e3E2x5Max_branch
    cdef float e3E2x5Max_value

    cdef TBranch* e3E5x5_branch
    cdef float e3E5x5_value

    cdef TBranch* e3EcalIsoDR03_branch
    cdef float e3EcalIsoDR03_value

    cdef TBranch* e3EffectiveArea2012Data_branch
    cdef float e3EffectiveArea2012Data_value

    cdef TBranch* e3EffectiveAreaSpring15_branch
    cdef float e3EffectiveAreaSpring15_value

    cdef TBranch* e3EnergyError_branch
    cdef float e3EnergyError_value

    cdef TBranch* e3Eta_branch
    cdef float e3Eta_value

    cdef TBranch* e3Eta_ElectronEnDown_branch
    cdef float e3Eta_ElectronEnDown_value

    cdef TBranch* e3Eta_ElectronEnUp_branch
    cdef float e3Eta_ElectronEnUp_value

    cdef TBranch* e3GenCharge_branch
    cdef float e3GenCharge_value

    cdef TBranch* e3GenEnergy_branch
    cdef float e3GenEnergy_value

    cdef TBranch* e3GenEta_branch
    cdef float e3GenEta_value

    cdef TBranch* e3GenMotherPdgId_branch
    cdef float e3GenMotherPdgId_value

    cdef TBranch* e3GenParticle_branch
    cdef float e3GenParticle_value

    cdef TBranch* e3GenPdgId_branch
    cdef float e3GenPdgId_value

    cdef TBranch* e3GenPhi_branch
    cdef float e3GenPhi_value

    cdef TBranch* e3GenPrompt_branch
    cdef float e3GenPrompt_value

    cdef TBranch* e3GenPromptTauDecay_branch
    cdef float e3GenPromptTauDecay_value

    cdef TBranch* e3GenPt_branch
    cdef float e3GenPt_value

    cdef TBranch* e3GenTauDecay_branch
    cdef float e3GenTauDecay_value

    cdef TBranch* e3GenVZ_branch
    cdef float e3GenVZ_value

    cdef TBranch* e3GenVtxPVMatch_branch
    cdef float e3GenVtxPVMatch_value

    cdef TBranch* e3HadronicDepth1OverEm_branch
    cdef float e3HadronicDepth1OverEm_value

    cdef TBranch* e3HadronicDepth2OverEm_branch
    cdef float e3HadronicDepth2OverEm_value

    cdef TBranch* e3HadronicOverEM_branch
    cdef float e3HadronicOverEM_value

    cdef TBranch* e3HcalIsoDR03_branch
    cdef float e3HcalIsoDR03_value

    cdef TBranch* e3IP3D_branch
    cdef float e3IP3D_value

    cdef TBranch* e3IP3DErr_branch
    cdef float e3IP3DErr_value

    cdef TBranch* e3JetArea_branch
    cdef float e3JetArea_value

    cdef TBranch* e3JetBtag_branch
    cdef float e3JetBtag_value

    cdef TBranch* e3JetEtaEtaMoment_branch
    cdef float e3JetEtaEtaMoment_value

    cdef TBranch* e3JetEtaPhiMoment_branch
    cdef float e3JetEtaPhiMoment_value

    cdef TBranch* e3JetEtaPhiSpread_branch
    cdef float e3JetEtaPhiSpread_value

    cdef TBranch* e3JetPFCISVBtag_branch
    cdef float e3JetPFCISVBtag_value

    cdef TBranch* e3JetPartonFlavour_branch
    cdef float e3JetPartonFlavour_value

    cdef TBranch* e3JetPhiPhiMoment_branch
    cdef float e3JetPhiPhiMoment_value

    cdef TBranch* e3JetPt_branch
    cdef float e3JetPt_value

    cdef TBranch* e3LowestMll_branch
    cdef float e3LowestMll_value

    cdef TBranch* e3MVANonTrigCategory_branch
    cdef float e3MVANonTrigCategory_value

    cdef TBranch* e3MVANonTrigID_branch
    cdef float e3MVANonTrigID_value

    cdef TBranch* e3MVANonTrigWP80_branch
    cdef float e3MVANonTrigWP80_value

    cdef TBranch* e3MVANonTrigWP90_branch
    cdef float e3MVANonTrigWP90_value

    cdef TBranch* e3MVATrigCategory_branch
    cdef float e3MVATrigCategory_value

    cdef TBranch* e3MVATrigID_branch
    cdef float e3MVATrigID_value

    cdef TBranch* e3MVATrigWP80_branch
    cdef float e3MVATrigWP80_value

    cdef TBranch* e3MVATrigWP90_branch
    cdef float e3MVATrigWP90_value

    cdef TBranch* e3Mass_branch
    cdef float e3Mass_value

    cdef TBranch* e3MatchesDoubleE_branch
    cdef float e3MatchesDoubleE_value

    cdef TBranch* e3MatchesDoubleESingleMu_branch
    cdef float e3MatchesDoubleESingleMu_value

    cdef TBranch* e3MatchesDoubleMuSingleE_branch
    cdef float e3MatchesDoubleMuSingleE_value

    cdef TBranch* e3MatchesSingleE_branch
    cdef float e3MatchesSingleE_value

    cdef TBranch* e3MatchesSingleESingleMu_branch
    cdef float e3MatchesSingleESingleMu_value

    cdef TBranch* e3MatchesSingleE_leg1_branch
    cdef float e3MatchesSingleE_leg1_value

    cdef TBranch* e3MatchesSingleE_leg2_branch
    cdef float e3MatchesSingleE_leg2_value

    cdef TBranch* e3MatchesSingleMuSingleE_branch
    cdef float e3MatchesSingleMuSingleE_value

    cdef TBranch* e3MatchesTripleE_branch
    cdef float e3MatchesTripleE_value

    cdef TBranch* e3MissingHits_branch
    cdef float e3MissingHits_value

    cdef TBranch* e3MtToPfMet_ElectronEnDown_branch
    cdef float e3MtToPfMet_ElectronEnDown_value

    cdef TBranch* e3MtToPfMet_ElectronEnUp_branch
    cdef float e3MtToPfMet_ElectronEnUp_value

    cdef TBranch* e3MtToPfMet_JetEnDown_branch
    cdef float e3MtToPfMet_JetEnDown_value

    cdef TBranch* e3MtToPfMet_JetEnUp_branch
    cdef float e3MtToPfMet_JetEnUp_value

    cdef TBranch* e3MtToPfMet_JetResDown_branch
    cdef float e3MtToPfMet_JetResDown_value

    cdef TBranch* e3MtToPfMet_JetResUp_branch
    cdef float e3MtToPfMet_JetResUp_value

    cdef TBranch* e3MtToPfMet_MuonEnDown_branch
    cdef float e3MtToPfMet_MuonEnDown_value

    cdef TBranch* e3MtToPfMet_MuonEnUp_branch
    cdef float e3MtToPfMet_MuonEnUp_value

    cdef TBranch* e3MtToPfMet_PhotonEnDown_branch
    cdef float e3MtToPfMet_PhotonEnDown_value

    cdef TBranch* e3MtToPfMet_PhotonEnUp_branch
    cdef float e3MtToPfMet_PhotonEnUp_value

    cdef TBranch* e3MtToPfMet_Raw_branch
    cdef float e3MtToPfMet_Raw_value

    cdef TBranch* e3MtToPfMet_TauEnDown_branch
    cdef float e3MtToPfMet_TauEnDown_value

    cdef TBranch* e3MtToPfMet_TauEnUp_branch
    cdef float e3MtToPfMet_TauEnUp_value

    cdef TBranch* e3MtToPfMet_UnclusteredEnDown_branch
    cdef float e3MtToPfMet_UnclusteredEnDown_value

    cdef TBranch* e3MtToPfMet_UnclusteredEnUp_branch
    cdef float e3MtToPfMet_UnclusteredEnUp_value

    cdef TBranch* e3MtToPfMet_type1_branch
    cdef float e3MtToPfMet_type1_value

    cdef TBranch* e3NearMuonVeto_branch
    cdef float e3NearMuonVeto_value

    cdef TBranch* e3NearestMuonDR_branch
    cdef float e3NearestMuonDR_value

    cdef TBranch* e3NearestZMass_branch
    cdef float e3NearestZMass_value

    cdef TBranch* e3PFChargedIso_branch
    cdef float e3PFChargedIso_value

    cdef TBranch* e3PFNeutralIso_branch
    cdef float e3PFNeutralIso_value

    cdef TBranch* e3PFPUChargedIso_branch
    cdef float e3PFPUChargedIso_value

    cdef TBranch* e3PFPhotonIso_branch
    cdef float e3PFPhotonIso_value

    cdef TBranch* e3PVDXY_branch
    cdef float e3PVDXY_value

    cdef TBranch* e3PVDZ_branch
    cdef float e3PVDZ_value

    cdef TBranch* e3PassesConversionVeto_branch
    cdef float e3PassesConversionVeto_value

    cdef TBranch* e3Phi_branch
    cdef float e3Phi_value

    cdef TBranch* e3Phi_ElectronEnDown_branch
    cdef float e3Phi_ElectronEnDown_value

    cdef TBranch* e3Phi_ElectronEnUp_branch
    cdef float e3Phi_ElectronEnUp_value

    cdef TBranch* e3Pt_branch
    cdef float e3Pt_value

    cdef TBranch* e3Pt_ElectronEnDown_branch
    cdef float e3Pt_ElectronEnDown_value

    cdef TBranch* e3Pt_ElectronEnUp_branch
    cdef float e3Pt_ElectronEnUp_value

    cdef TBranch* e3Rank_branch
    cdef float e3Rank_value

    cdef TBranch* e3RelIso_branch
    cdef float e3RelIso_value

    cdef TBranch* e3RelPFIsoDB_branch
    cdef float e3RelPFIsoDB_value

    cdef TBranch* e3RelPFIsoRho_branch
    cdef float e3RelPFIsoRho_value

    cdef TBranch* e3Rho_branch
    cdef float e3Rho_value

    cdef TBranch* e3SCEnergy_branch
    cdef float e3SCEnergy_value

    cdef TBranch* e3SCEta_branch
    cdef float e3SCEta_value

    cdef TBranch* e3SCEtaWidth_branch
    cdef float e3SCEtaWidth_value

    cdef TBranch* e3SCPhi_branch
    cdef float e3SCPhi_value

    cdef TBranch* e3SCPhiWidth_branch
    cdef float e3SCPhiWidth_value

    cdef TBranch* e3SCPreshowerEnergy_branch
    cdef float e3SCPreshowerEnergy_value

    cdef TBranch* e3SCRawEnergy_branch
    cdef float e3SCRawEnergy_value

    cdef TBranch* e3SIP2D_branch
    cdef float e3SIP2D_value

    cdef TBranch* e3SIP3D_branch
    cdef float e3SIP3D_value

    cdef TBranch* e3SigmaIEtaIEta_branch
    cdef float e3SigmaIEtaIEta_value

    cdef TBranch* e3TrkIsoDR03_branch
    cdef float e3TrkIsoDR03_value

    cdef TBranch* e3VZ_branch
    cdef float e3VZ_value

    cdef TBranch* e3WWLoose_branch
    cdef float e3WWLoose_value

    cdef TBranch* e3_e1_collinearmass_branch
    cdef float e3_e1_collinearmass_value

    cdef TBranch* e3_e1_collinearmass_JetEnDown_branch
    cdef float e3_e1_collinearmass_JetEnDown_value

    cdef TBranch* e3_e1_collinearmass_JetEnUp_branch
    cdef float e3_e1_collinearmass_JetEnUp_value

    cdef TBranch* e3_e1_collinearmass_UnclusteredEnDown_branch
    cdef float e3_e1_collinearmass_UnclusteredEnDown_value

    cdef TBranch* e3_e1_collinearmass_UnclusteredEnUp_branch
    cdef float e3_e1_collinearmass_UnclusteredEnUp_value

    cdef TBranch* e3_e2_collinearmass_branch
    cdef float e3_e2_collinearmass_value

    cdef TBranch* e3_e2_collinearmass_JetEnDown_branch
    cdef float e3_e2_collinearmass_JetEnDown_value

    cdef TBranch* e3_e2_collinearmass_JetEnUp_branch
    cdef float e3_e2_collinearmass_JetEnUp_value

    cdef TBranch* e3_e2_collinearmass_UnclusteredEnDown_branch
    cdef float e3_e2_collinearmass_UnclusteredEnDown_value

    cdef TBranch* e3_e2_collinearmass_UnclusteredEnUp_branch
    cdef float e3_e2_collinearmass_UnclusteredEnUp_value

    cdef TBranch* e3deltaEtaSuperClusterTrackAtVtx_branch
    cdef float e3deltaEtaSuperClusterTrackAtVtx_value

    cdef TBranch* e3deltaPhiSuperClusterTrackAtVtx_branch
    cdef float e3deltaPhiSuperClusterTrackAtVtx_value

    cdef TBranch* e3eSuperClusterOverP_branch
    cdef float e3eSuperClusterOverP_value

    cdef TBranch* e3ecalEnergy_branch
    cdef float e3ecalEnergy_value

    cdef TBranch* e3fBrem_branch
    cdef float e3fBrem_value

    cdef TBranch* e3trackMomentumAtVtxP_branch
    cdef float e3trackMomentumAtVtxP_value

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

    cdef TBranch* jet1BJetCISV_branch
    cdef float jet1BJetCISV_value

    cdef TBranch* jet1Eta_branch
    cdef float jet1Eta_value

    cdef TBranch* jet1IDLoose_branch
    cdef float jet1IDLoose_value

    cdef TBranch* jet1IDTight_branch
    cdef float jet1IDTight_value

    cdef TBranch* jet1IDTightLepVeto_branch
    cdef float jet1IDTightLepVeto_value

    cdef TBranch* jet1PUMVA_branch
    cdef float jet1PUMVA_value

    cdef TBranch* jet1Phi_branch
    cdef float jet1Phi_value

    cdef TBranch* jet1Pt_branch
    cdef float jet1Pt_value

    cdef TBranch* jet2BJetCISV_branch
    cdef float jet2BJetCISV_value

    cdef TBranch* jet2Eta_branch
    cdef float jet2Eta_value

    cdef TBranch* jet2IDLoose_branch
    cdef float jet2IDLoose_value

    cdef TBranch* jet2IDTight_branch
    cdef float jet2IDTight_value

    cdef TBranch* jet2IDTightLepVeto_branch
    cdef float jet2IDTightLepVeto_value

    cdef TBranch* jet2PUMVA_branch
    cdef float jet2PUMVA_value

    cdef TBranch* jet2Phi_branch
    cdef float jet2Phi_value

    cdef TBranch* jet2Pt_branch
    cdef float jet2Pt_value

    cdef TBranch* jet3BJetCISV_branch
    cdef float jet3BJetCISV_value

    cdef TBranch* jet3Eta_branch
    cdef float jet3Eta_value

    cdef TBranch* jet3IDLoose_branch
    cdef float jet3IDLoose_value

    cdef TBranch* jet3IDTight_branch
    cdef float jet3IDTight_value

    cdef TBranch* jet3IDTightLepVeto_branch
    cdef float jet3IDTightLepVeto_value

    cdef TBranch* jet3PUMVA_branch
    cdef float jet3PUMVA_value

    cdef TBranch* jet3Phi_branch
    cdef float jet3Phi_value

    cdef TBranch* jet3Pt_branch
    cdef float jet3Pt_value

    cdef TBranch* jet4BJetCISV_branch
    cdef float jet4BJetCISV_value

    cdef TBranch* jet4Eta_branch
    cdef float jet4Eta_value

    cdef TBranch* jet4IDLoose_branch
    cdef float jet4IDLoose_value

    cdef TBranch* jet4IDTight_branch
    cdef float jet4IDTight_value

    cdef TBranch* jet4IDTightLepVeto_branch
    cdef float jet4IDTightLepVeto_value

    cdef TBranch* jet4PUMVA_branch
    cdef float jet4PUMVA_value

    cdef TBranch* jet4Phi_branch
    cdef float jet4Phi_value

    cdef TBranch* jet4Pt_branch
    cdef float jet4Pt_value

    cdef TBranch* jet5BJetCISV_branch
    cdef float jet5BJetCISV_value

    cdef TBranch* jet5Eta_branch
    cdef float jet5Eta_value

    cdef TBranch* jet5IDLoose_branch
    cdef float jet5IDLoose_value

    cdef TBranch* jet5IDTight_branch
    cdef float jet5IDTight_value

    cdef TBranch* jet5IDTightLepVeto_branch
    cdef float jet5IDTightLepVeto_value

    cdef TBranch* jet5PUMVA_branch
    cdef float jet5PUMVA_value

    cdef TBranch* jet5Phi_branch
    cdef float jet5Phi_value

    cdef TBranch* jet5Pt_branch
    cdef float jet5Pt_value

    cdef TBranch* jet6BJetCISV_branch
    cdef float jet6BJetCISV_value

    cdef TBranch* jet6Eta_branch
    cdef float jet6Eta_value

    cdef TBranch* jet6IDLoose_branch
    cdef float jet6IDLoose_value

    cdef TBranch* jet6IDTight_branch
    cdef float jet6IDTight_value

    cdef TBranch* jet6IDTightLepVeto_branch
    cdef float jet6IDTightLepVeto_value

    cdef TBranch* jet6PUMVA_branch
    cdef float jet6PUMVA_value

    cdef TBranch* jet6Phi_branch
    cdef float jet6Phi_value

    cdef TBranch* jet6Pt_branch
    cdef float jet6Pt_value

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

    cdef TBranch* singleE23WPLooseGroup_branch
    cdef float singleE23WPLooseGroup_value

    cdef TBranch* singleE23WPLoosePass_branch
    cdef float singleE23WPLoosePass_value

    cdef TBranch* singleE23WPLoosePrescale_branch
    cdef float singleE23WPLoosePrescale_value

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

    cdef TBranch* singleIsoMu27Group_branch
    cdef float singleIsoMu27Group_value

    cdef TBranch* singleIsoMu27Pass_branch
    cdef float singleIsoMu27Pass_value

    cdef TBranch* singleIsoMu27Prescale_branch
    cdef float singleIsoMu27Prescale_value

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
            warnings.warn( "EEETree: Expected branch EmbPtWeight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("EmbPtWeight")
        else:
            self.EmbPtWeight_branch.SetAddress(<void*>&self.EmbPtWeight_value)

        #print "making Eta"
        self.Eta_branch = the_tree.GetBranch("Eta")
        #if not self.Eta_branch and "Eta" not in self.complained:
        if not self.Eta_branch and "Eta":
            warnings.warn( "EEETree: Expected branch Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Eta")
        else:
            self.Eta_branch.SetAddress(<void*>&self.Eta_value)

        #print "making GenWeight"
        self.GenWeight_branch = the_tree.GetBranch("GenWeight")
        #if not self.GenWeight_branch and "GenWeight" not in self.complained:
        if not self.GenWeight_branch and "GenWeight":
            warnings.warn( "EEETree: Expected branch GenWeight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("GenWeight")
        else:
            self.GenWeight_branch.SetAddress(<void*>&self.GenWeight_value)

        #print "making Ht"
        self.Ht_branch = the_tree.GetBranch("Ht")
        #if not self.Ht_branch and "Ht" not in self.complained:
        if not self.Ht_branch and "Ht":
            warnings.warn( "EEETree: Expected branch Ht does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Ht")
        else:
            self.Ht_branch.SetAddress(<void*>&self.Ht_value)

        #print "making LT"
        self.LT_branch = the_tree.GetBranch("LT")
        #if not self.LT_branch and "LT" not in self.complained:
        if not self.LT_branch and "LT":
            warnings.warn( "EEETree: Expected branch LT does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("LT")
        else:
            self.LT_branch.SetAddress(<void*>&self.LT_value)

        #print "making Mass"
        self.Mass_branch = the_tree.GetBranch("Mass")
        #if not self.Mass_branch and "Mass" not in self.complained:
        if not self.Mass_branch and "Mass":
            warnings.warn( "EEETree: Expected branch Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Mass")
        else:
            self.Mass_branch.SetAddress(<void*>&self.Mass_value)

        #print "making MassError"
        self.MassError_branch = the_tree.GetBranch("MassError")
        #if not self.MassError_branch and "MassError" not in self.complained:
        if not self.MassError_branch and "MassError":
            warnings.warn( "EEETree: Expected branch MassError does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassError")
        else:
            self.MassError_branch.SetAddress(<void*>&self.MassError_value)

        #print "making MassErrord1"
        self.MassErrord1_branch = the_tree.GetBranch("MassErrord1")
        #if not self.MassErrord1_branch and "MassErrord1" not in self.complained:
        if not self.MassErrord1_branch and "MassErrord1":
            warnings.warn( "EEETree: Expected branch MassErrord1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord1")
        else:
            self.MassErrord1_branch.SetAddress(<void*>&self.MassErrord1_value)

        #print "making MassErrord2"
        self.MassErrord2_branch = the_tree.GetBranch("MassErrord2")
        #if not self.MassErrord2_branch and "MassErrord2" not in self.complained:
        if not self.MassErrord2_branch and "MassErrord2":
            warnings.warn( "EEETree: Expected branch MassErrord2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord2")
        else:
            self.MassErrord2_branch.SetAddress(<void*>&self.MassErrord2_value)

        #print "making MassErrord3"
        self.MassErrord3_branch = the_tree.GetBranch("MassErrord3")
        #if not self.MassErrord3_branch and "MassErrord3" not in self.complained:
        if not self.MassErrord3_branch and "MassErrord3":
            warnings.warn( "EEETree: Expected branch MassErrord3 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord3")
        else:
            self.MassErrord3_branch.SetAddress(<void*>&self.MassErrord3_value)

        #print "making MassErrord4"
        self.MassErrord4_branch = the_tree.GetBranch("MassErrord4")
        #if not self.MassErrord4_branch and "MassErrord4" not in self.complained:
        if not self.MassErrord4_branch and "MassErrord4":
            warnings.warn( "EEETree: Expected branch MassErrord4 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord4")
        else:
            self.MassErrord4_branch.SetAddress(<void*>&self.MassErrord4_value)

        #print "making Mt"
        self.Mt_branch = the_tree.GetBranch("Mt")
        #if not self.Mt_branch and "Mt" not in self.complained:
        if not self.Mt_branch and "Mt":
            warnings.warn( "EEETree: Expected branch Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Mt")
        else:
            self.Mt_branch.SetAddress(<void*>&self.Mt_value)

        #print "making NUP"
        self.NUP_branch = the_tree.GetBranch("NUP")
        #if not self.NUP_branch and "NUP" not in self.complained:
        if not self.NUP_branch and "NUP":
            warnings.warn( "EEETree: Expected branch NUP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("NUP")
        else:
            self.NUP_branch.SetAddress(<void*>&self.NUP_value)

        #print "making Phi"
        self.Phi_branch = the_tree.GetBranch("Phi")
        #if not self.Phi_branch and "Phi" not in self.complained:
        if not self.Phi_branch and "Phi":
            warnings.warn( "EEETree: Expected branch Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Phi")
        else:
            self.Phi_branch.SetAddress(<void*>&self.Phi_value)

        #print "making Pt"
        self.Pt_branch = the_tree.GetBranch("Pt")
        #if not self.Pt_branch and "Pt" not in self.complained:
        if not self.Pt_branch and "Pt":
            warnings.warn( "EEETree: Expected branch Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Pt")
        else:
            self.Pt_branch.SetAddress(<void*>&self.Pt_value)

        #print "making bjetCISVVeto20Loose"
        self.bjetCISVVeto20Loose_branch = the_tree.GetBranch("bjetCISVVeto20Loose")
        #if not self.bjetCISVVeto20Loose_branch and "bjetCISVVeto20Loose" not in self.complained:
        if not self.bjetCISVVeto20Loose_branch and "bjetCISVVeto20Loose":
            warnings.warn( "EEETree: Expected branch bjetCISVVeto20Loose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Loose")
        else:
            self.bjetCISVVeto20Loose_branch.SetAddress(<void*>&self.bjetCISVVeto20Loose_value)

        #print "making bjetCISVVeto20Medium"
        self.bjetCISVVeto20Medium_branch = the_tree.GetBranch("bjetCISVVeto20Medium")
        #if not self.bjetCISVVeto20Medium_branch and "bjetCISVVeto20Medium" not in self.complained:
        if not self.bjetCISVVeto20Medium_branch and "bjetCISVVeto20Medium":
            warnings.warn( "EEETree: Expected branch bjetCISVVeto20Medium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Medium")
        else:
            self.bjetCISVVeto20Medium_branch.SetAddress(<void*>&self.bjetCISVVeto20Medium_value)

        #print "making bjetCISVVeto20Tight"
        self.bjetCISVVeto20Tight_branch = the_tree.GetBranch("bjetCISVVeto20Tight")
        #if not self.bjetCISVVeto20Tight_branch and "bjetCISVVeto20Tight" not in self.complained:
        if not self.bjetCISVVeto20Tight_branch and "bjetCISVVeto20Tight":
            warnings.warn( "EEETree: Expected branch bjetCISVVeto20Tight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Tight")
        else:
            self.bjetCISVVeto20Tight_branch.SetAddress(<void*>&self.bjetCISVVeto20Tight_value)

        #print "making bjetCISVVeto30Loose"
        self.bjetCISVVeto30Loose_branch = the_tree.GetBranch("bjetCISVVeto30Loose")
        #if not self.bjetCISVVeto30Loose_branch and "bjetCISVVeto30Loose" not in self.complained:
        if not self.bjetCISVVeto30Loose_branch and "bjetCISVVeto30Loose":
            warnings.warn( "EEETree: Expected branch bjetCISVVeto30Loose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Loose")
        else:
            self.bjetCISVVeto30Loose_branch.SetAddress(<void*>&self.bjetCISVVeto30Loose_value)

        #print "making bjetCISVVeto30Medium"
        self.bjetCISVVeto30Medium_branch = the_tree.GetBranch("bjetCISVVeto30Medium")
        #if not self.bjetCISVVeto30Medium_branch and "bjetCISVVeto30Medium" not in self.complained:
        if not self.bjetCISVVeto30Medium_branch and "bjetCISVVeto30Medium":
            warnings.warn( "EEETree: Expected branch bjetCISVVeto30Medium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Medium")
        else:
            self.bjetCISVVeto30Medium_branch.SetAddress(<void*>&self.bjetCISVVeto30Medium_value)

        #print "making bjetCISVVeto30Tight"
        self.bjetCISVVeto30Tight_branch = the_tree.GetBranch("bjetCISVVeto30Tight")
        #if not self.bjetCISVVeto30Tight_branch and "bjetCISVVeto30Tight" not in self.complained:
        if not self.bjetCISVVeto30Tight_branch and "bjetCISVVeto30Tight":
            warnings.warn( "EEETree: Expected branch bjetCISVVeto30Tight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Tight")
        else:
            self.bjetCISVVeto30Tight_branch.SetAddress(<void*>&self.bjetCISVVeto30Tight_value)

        #print "making charge"
        self.charge_branch = the_tree.GetBranch("charge")
        #if not self.charge_branch and "charge" not in self.complained:
        if not self.charge_branch and "charge":
            warnings.warn( "EEETree: Expected branch charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("charge")
        else:
            self.charge_branch.SetAddress(<void*>&self.charge_value)

        #print "making doubleEGroup"
        self.doubleEGroup_branch = the_tree.GetBranch("doubleEGroup")
        #if not self.doubleEGroup_branch and "doubleEGroup" not in self.complained:
        if not self.doubleEGroup_branch and "doubleEGroup":
            warnings.warn( "EEETree: Expected branch doubleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEGroup")
        else:
            self.doubleEGroup_branch.SetAddress(<void*>&self.doubleEGroup_value)

        #print "making doubleEPass"
        self.doubleEPass_branch = the_tree.GetBranch("doubleEPass")
        #if not self.doubleEPass_branch and "doubleEPass" not in self.complained:
        if not self.doubleEPass_branch and "doubleEPass":
            warnings.warn( "EEETree: Expected branch doubleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEPass")
        else:
            self.doubleEPass_branch.SetAddress(<void*>&self.doubleEPass_value)

        #print "making doubleEPrescale"
        self.doubleEPrescale_branch = the_tree.GetBranch("doubleEPrescale")
        #if not self.doubleEPrescale_branch and "doubleEPrescale" not in self.complained:
        if not self.doubleEPrescale_branch and "doubleEPrescale":
            warnings.warn( "EEETree: Expected branch doubleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEPrescale")
        else:
            self.doubleEPrescale_branch.SetAddress(<void*>&self.doubleEPrescale_value)

        #print "making doubleESingleMuGroup"
        self.doubleESingleMuGroup_branch = the_tree.GetBranch("doubleESingleMuGroup")
        #if not self.doubleESingleMuGroup_branch and "doubleESingleMuGroup" not in self.complained:
        if not self.doubleESingleMuGroup_branch and "doubleESingleMuGroup":
            warnings.warn( "EEETree: Expected branch doubleESingleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuGroup")
        else:
            self.doubleESingleMuGroup_branch.SetAddress(<void*>&self.doubleESingleMuGroup_value)

        #print "making doubleESingleMuPass"
        self.doubleESingleMuPass_branch = the_tree.GetBranch("doubleESingleMuPass")
        #if not self.doubleESingleMuPass_branch and "doubleESingleMuPass" not in self.complained:
        if not self.doubleESingleMuPass_branch and "doubleESingleMuPass":
            warnings.warn( "EEETree: Expected branch doubleESingleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuPass")
        else:
            self.doubleESingleMuPass_branch.SetAddress(<void*>&self.doubleESingleMuPass_value)

        #print "making doubleESingleMuPrescale"
        self.doubleESingleMuPrescale_branch = the_tree.GetBranch("doubleESingleMuPrescale")
        #if not self.doubleESingleMuPrescale_branch and "doubleESingleMuPrescale" not in self.complained:
        if not self.doubleESingleMuPrescale_branch and "doubleESingleMuPrescale":
            warnings.warn( "EEETree: Expected branch doubleESingleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuPrescale")
        else:
            self.doubleESingleMuPrescale_branch.SetAddress(<void*>&self.doubleESingleMuPrescale_value)

        #print "making doubleMuGroup"
        self.doubleMuGroup_branch = the_tree.GetBranch("doubleMuGroup")
        #if not self.doubleMuGroup_branch and "doubleMuGroup" not in self.complained:
        if not self.doubleMuGroup_branch and "doubleMuGroup":
            warnings.warn( "EEETree: Expected branch doubleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuGroup")
        else:
            self.doubleMuGroup_branch.SetAddress(<void*>&self.doubleMuGroup_value)

        #print "making doubleMuPass"
        self.doubleMuPass_branch = the_tree.GetBranch("doubleMuPass")
        #if not self.doubleMuPass_branch and "doubleMuPass" not in self.complained:
        if not self.doubleMuPass_branch and "doubleMuPass":
            warnings.warn( "EEETree: Expected branch doubleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuPass")
        else:
            self.doubleMuPass_branch.SetAddress(<void*>&self.doubleMuPass_value)

        #print "making doubleMuPrescale"
        self.doubleMuPrescale_branch = the_tree.GetBranch("doubleMuPrescale")
        #if not self.doubleMuPrescale_branch and "doubleMuPrescale" not in self.complained:
        if not self.doubleMuPrescale_branch and "doubleMuPrescale":
            warnings.warn( "EEETree: Expected branch doubleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuPrescale")
        else:
            self.doubleMuPrescale_branch.SetAddress(<void*>&self.doubleMuPrescale_value)

        #print "making doubleMuSingleEGroup"
        self.doubleMuSingleEGroup_branch = the_tree.GetBranch("doubleMuSingleEGroup")
        #if not self.doubleMuSingleEGroup_branch and "doubleMuSingleEGroup" not in self.complained:
        if not self.doubleMuSingleEGroup_branch and "doubleMuSingleEGroup":
            warnings.warn( "EEETree: Expected branch doubleMuSingleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEGroup")
        else:
            self.doubleMuSingleEGroup_branch.SetAddress(<void*>&self.doubleMuSingleEGroup_value)

        #print "making doubleMuSingleEPass"
        self.doubleMuSingleEPass_branch = the_tree.GetBranch("doubleMuSingleEPass")
        #if not self.doubleMuSingleEPass_branch and "doubleMuSingleEPass" not in self.complained:
        if not self.doubleMuSingleEPass_branch and "doubleMuSingleEPass":
            warnings.warn( "EEETree: Expected branch doubleMuSingleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEPass")
        else:
            self.doubleMuSingleEPass_branch.SetAddress(<void*>&self.doubleMuSingleEPass_value)

        #print "making doubleMuSingleEPrescale"
        self.doubleMuSingleEPrescale_branch = the_tree.GetBranch("doubleMuSingleEPrescale")
        #if not self.doubleMuSingleEPrescale_branch and "doubleMuSingleEPrescale" not in self.complained:
        if not self.doubleMuSingleEPrescale_branch and "doubleMuSingleEPrescale":
            warnings.warn( "EEETree: Expected branch doubleMuSingleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEPrescale")
        else:
            self.doubleMuSingleEPrescale_branch.SetAddress(<void*>&self.doubleMuSingleEPrescale_value)

        #print "making doubleTau35Group"
        self.doubleTau35Group_branch = the_tree.GetBranch("doubleTau35Group")
        #if not self.doubleTau35Group_branch and "doubleTau35Group" not in self.complained:
        if not self.doubleTau35Group_branch and "doubleTau35Group":
            warnings.warn( "EEETree: Expected branch doubleTau35Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Group")
        else:
            self.doubleTau35Group_branch.SetAddress(<void*>&self.doubleTau35Group_value)

        #print "making doubleTau35Pass"
        self.doubleTau35Pass_branch = the_tree.GetBranch("doubleTau35Pass")
        #if not self.doubleTau35Pass_branch and "doubleTau35Pass" not in self.complained:
        if not self.doubleTau35Pass_branch and "doubleTau35Pass":
            warnings.warn( "EEETree: Expected branch doubleTau35Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Pass")
        else:
            self.doubleTau35Pass_branch.SetAddress(<void*>&self.doubleTau35Pass_value)

        #print "making doubleTau35Prescale"
        self.doubleTau35Prescale_branch = the_tree.GetBranch("doubleTau35Prescale")
        #if not self.doubleTau35Prescale_branch and "doubleTau35Prescale" not in self.complained:
        if not self.doubleTau35Prescale_branch and "doubleTau35Prescale":
            warnings.warn( "EEETree: Expected branch doubleTau35Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Prescale")
        else:
            self.doubleTau35Prescale_branch.SetAddress(<void*>&self.doubleTau35Prescale_value)

        #print "making doubleTau40Group"
        self.doubleTau40Group_branch = the_tree.GetBranch("doubleTau40Group")
        #if not self.doubleTau40Group_branch and "doubleTau40Group" not in self.complained:
        if not self.doubleTau40Group_branch and "doubleTau40Group":
            warnings.warn( "EEETree: Expected branch doubleTau40Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Group")
        else:
            self.doubleTau40Group_branch.SetAddress(<void*>&self.doubleTau40Group_value)

        #print "making doubleTau40Pass"
        self.doubleTau40Pass_branch = the_tree.GetBranch("doubleTau40Pass")
        #if not self.doubleTau40Pass_branch and "doubleTau40Pass" not in self.complained:
        if not self.doubleTau40Pass_branch and "doubleTau40Pass":
            warnings.warn( "EEETree: Expected branch doubleTau40Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Pass")
        else:
            self.doubleTau40Pass_branch.SetAddress(<void*>&self.doubleTau40Pass_value)

        #print "making doubleTau40Prescale"
        self.doubleTau40Prescale_branch = the_tree.GetBranch("doubleTau40Prescale")
        #if not self.doubleTau40Prescale_branch and "doubleTau40Prescale" not in self.complained:
        if not self.doubleTau40Prescale_branch and "doubleTau40Prescale":
            warnings.warn( "EEETree: Expected branch doubleTau40Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Prescale")
        else:
            self.doubleTau40Prescale_branch.SetAddress(<void*>&self.doubleTau40Prescale_value)

        #print "making e1AbsEta"
        self.e1AbsEta_branch = the_tree.GetBranch("e1AbsEta")
        #if not self.e1AbsEta_branch and "e1AbsEta" not in self.complained:
        if not self.e1AbsEta_branch and "e1AbsEta":
            warnings.warn( "EEETree: Expected branch e1AbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1AbsEta")
        else:
            self.e1AbsEta_branch.SetAddress(<void*>&self.e1AbsEta_value)

        #print "making e1CBIDLoose"
        self.e1CBIDLoose_branch = the_tree.GetBranch("e1CBIDLoose")
        #if not self.e1CBIDLoose_branch and "e1CBIDLoose" not in self.complained:
        if not self.e1CBIDLoose_branch and "e1CBIDLoose":
            warnings.warn( "EEETree: Expected branch e1CBIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDLoose")
        else:
            self.e1CBIDLoose_branch.SetAddress(<void*>&self.e1CBIDLoose_value)

        #print "making e1CBIDLooseNoIso"
        self.e1CBIDLooseNoIso_branch = the_tree.GetBranch("e1CBIDLooseNoIso")
        #if not self.e1CBIDLooseNoIso_branch and "e1CBIDLooseNoIso" not in self.complained:
        if not self.e1CBIDLooseNoIso_branch and "e1CBIDLooseNoIso":
            warnings.warn( "EEETree: Expected branch e1CBIDLooseNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDLooseNoIso")
        else:
            self.e1CBIDLooseNoIso_branch.SetAddress(<void*>&self.e1CBIDLooseNoIso_value)

        #print "making e1CBIDMedium"
        self.e1CBIDMedium_branch = the_tree.GetBranch("e1CBIDMedium")
        #if not self.e1CBIDMedium_branch and "e1CBIDMedium" not in self.complained:
        if not self.e1CBIDMedium_branch and "e1CBIDMedium":
            warnings.warn( "EEETree: Expected branch e1CBIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDMedium")
        else:
            self.e1CBIDMedium_branch.SetAddress(<void*>&self.e1CBIDMedium_value)

        #print "making e1CBIDMediumNoIso"
        self.e1CBIDMediumNoIso_branch = the_tree.GetBranch("e1CBIDMediumNoIso")
        #if not self.e1CBIDMediumNoIso_branch and "e1CBIDMediumNoIso" not in self.complained:
        if not self.e1CBIDMediumNoIso_branch and "e1CBIDMediumNoIso":
            warnings.warn( "EEETree: Expected branch e1CBIDMediumNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDMediumNoIso")
        else:
            self.e1CBIDMediumNoIso_branch.SetAddress(<void*>&self.e1CBIDMediumNoIso_value)

        #print "making e1CBIDTight"
        self.e1CBIDTight_branch = the_tree.GetBranch("e1CBIDTight")
        #if not self.e1CBIDTight_branch and "e1CBIDTight" not in self.complained:
        if not self.e1CBIDTight_branch and "e1CBIDTight":
            warnings.warn( "EEETree: Expected branch e1CBIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDTight")
        else:
            self.e1CBIDTight_branch.SetAddress(<void*>&self.e1CBIDTight_value)

        #print "making e1CBIDTightNoIso"
        self.e1CBIDTightNoIso_branch = the_tree.GetBranch("e1CBIDTightNoIso")
        #if not self.e1CBIDTightNoIso_branch and "e1CBIDTightNoIso" not in self.complained:
        if not self.e1CBIDTightNoIso_branch and "e1CBIDTightNoIso":
            warnings.warn( "EEETree: Expected branch e1CBIDTightNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDTightNoIso")
        else:
            self.e1CBIDTightNoIso_branch.SetAddress(<void*>&self.e1CBIDTightNoIso_value)

        #print "making e1CBIDVeto"
        self.e1CBIDVeto_branch = the_tree.GetBranch("e1CBIDVeto")
        #if not self.e1CBIDVeto_branch and "e1CBIDVeto" not in self.complained:
        if not self.e1CBIDVeto_branch and "e1CBIDVeto":
            warnings.warn( "EEETree: Expected branch e1CBIDVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDVeto")
        else:
            self.e1CBIDVeto_branch.SetAddress(<void*>&self.e1CBIDVeto_value)

        #print "making e1CBIDVetoNoIso"
        self.e1CBIDVetoNoIso_branch = the_tree.GetBranch("e1CBIDVetoNoIso")
        #if not self.e1CBIDVetoNoIso_branch and "e1CBIDVetoNoIso" not in self.complained:
        if not self.e1CBIDVetoNoIso_branch and "e1CBIDVetoNoIso":
            warnings.warn( "EEETree: Expected branch e1CBIDVetoNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1CBIDVetoNoIso")
        else:
            self.e1CBIDVetoNoIso_branch.SetAddress(<void*>&self.e1CBIDVetoNoIso_value)

        #print "making e1Charge"
        self.e1Charge_branch = the_tree.GetBranch("e1Charge")
        #if not self.e1Charge_branch and "e1Charge" not in self.complained:
        if not self.e1Charge_branch and "e1Charge":
            warnings.warn( "EEETree: Expected branch e1Charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Charge")
        else:
            self.e1Charge_branch.SetAddress(<void*>&self.e1Charge_value)

        #print "making e1ChargeIdLoose"
        self.e1ChargeIdLoose_branch = the_tree.GetBranch("e1ChargeIdLoose")
        #if not self.e1ChargeIdLoose_branch and "e1ChargeIdLoose" not in self.complained:
        if not self.e1ChargeIdLoose_branch and "e1ChargeIdLoose":
            warnings.warn( "EEETree: Expected branch e1ChargeIdLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1ChargeIdLoose")
        else:
            self.e1ChargeIdLoose_branch.SetAddress(<void*>&self.e1ChargeIdLoose_value)

        #print "making e1ChargeIdMed"
        self.e1ChargeIdMed_branch = the_tree.GetBranch("e1ChargeIdMed")
        #if not self.e1ChargeIdMed_branch and "e1ChargeIdMed" not in self.complained:
        if not self.e1ChargeIdMed_branch and "e1ChargeIdMed":
            warnings.warn( "EEETree: Expected branch e1ChargeIdMed does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1ChargeIdMed")
        else:
            self.e1ChargeIdMed_branch.SetAddress(<void*>&self.e1ChargeIdMed_value)

        #print "making e1ChargeIdTight"
        self.e1ChargeIdTight_branch = the_tree.GetBranch("e1ChargeIdTight")
        #if not self.e1ChargeIdTight_branch and "e1ChargeIdTight" not in self.complained:
        if not self.e1ChargeIdTight_branch and "e1ChargeIdTight":
            warnings.warn( "EEETree: Expected branch e1ChargeIdTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1ChargeIdTight")
        else:
            self.e1ChargeIdTight_branch.SetAddress(<void*>&self.e1ChargeIdTight_value)

        #print "making e1ComesFromHiggs"
        self.e1ComesFromHiggs_branch = the_tree.GetBranch("e1ComesFromHiggs")
        #if not self.e1ComesFromHiggs_branch and "e1ComesFromHiggs" not in self.complained:
        if not self.e1ComesFromHiggs_branch and "e1ComesFromHiggs":
            warnings.warn( "EEETree: Expected branch e1ComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1ComesFromHiggs")
        else:
            self.e1ComesFromHiggs_branch.SetAddress(<void*>&self.e1ComesFromHiggs_value)

        #print "making e1DPhiToPfMet_ElectronEnDown"
        self.e1DPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("e1DPhiToPfMet_ElectronEnDown")
        #if not self.e1DPhiToPfMet_ElectronEnDown_branch and "e1DPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.e1DPhiToPfMet_ElectronEnDown_branch and "e1DPhiToPfMet_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_ElectronEnDown")
        else:
            self.e1DPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.e1DPhiToPfMet_ElectronEnDown_value)

        #print "making e1DPhiToPfMet_ElectronEnUp"
        self.e1DPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("e1DPhiToPfMet_ElectronEnUp")
        #if not self.e1DPhiToPfMet_ElectronEnUp_branch and "e1DPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.e1DPhiToPfMet_ElectronEnUp_branch and "e1DPhiToPfMet_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_ElectronEnUp")
        else:
            self.e1DPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.e1DPhiToPfMet_ElectronEnUp_value)

        #print "making e1DPhiToPfMet_JetEnDown"
        self.e1DPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("e1DPhiToPfMet_JetEnDown")
        #if not self.e1DPhiToPfMet_JetEnDown_branch and "e1DPhiToPfMet_JetEnDown" not in self.complained:
        if not self.e1DPhiToPfMet_JetEnDown_branch and "e1DPhiToPfMet_JetEnDown":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_JetEnDown")
        else:
            self.e1DPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.e1DPhiToPfMet_JetEnDown_value)

        #print "making e1DPhiToPfMet_JetEnUp"
        self.e1DPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("e1DPhiToPfMet_JetEnUp")
        #if not self.e1DPhiToPfMet_JetEnUp_branch and "e1DPhiToPfMet_JetEnUp" not in self.complained:
        if not self.e1DPhiToPfMet_JetEnUp_branch and "e1DPhiToPfMet_JetEnUp":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_JetEnUp")
        else:
            self.e1DPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.e1DPhiToPfMet_JetEnUp_value)

        #print "making e1DPhiToPfMet_JetResDown"
        self.e1DPhiToPfMet_JetResDown_branch = the_tree.GetBranch("e1DPhiToPfMet_JetResDown")
        #if not self.e1DPhiToPfMet_JetResDown_branch and "e1DPhiToPfMet_JetResDown" not in self.complained:
        if not self.e1DPhiToPfMet_JetResDown_branch and "e1DPhiToPfMet_JetResDown":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_JetResDown")
        else:
            self.e1DPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.e1DPhiToPfMet_JetResDown_value)

        #print "making e1DPhiToPfMet_JetResUp"
        self.e1DPhiToPfMet_JetResUp_branch = the_tree.GetBranch("e1DPhiToPfMet_JetResUp")
        #if not self.e1DPhiToPfMet_JetResUp_branch and "e1DPhiToPfMet_JetResUp" not in self.complained:
        if not self.e1DPhiToPfMet_JetResUp_branch and "e1DPhiToPfMet_JetResUp":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_JetResUp")
        else:
            self.e1DPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.e1DPhiToPfMet_JetResUp_value)

        #print "making e1DPhiToPfMet_MuonEnDown"
        self.e1DPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("e1DPhiToPfMet_MuonEnDown")
        #if not self.e1DPhiToPfMet_MuonEnDown_branch and "e1DPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.e1DPhiToPfMet_MuonEnDown_branch and "e1DPhiToPfMet_MuonEnDown":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_MuonEnDown")
        else:
            self.e1DPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.e1DPhiToPfMet_MuonEnDown_value)

        #print "making e1DPhiToPfMet_MuonEnUp"
        self.e1DPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("e1DPhiToPfMet_MuonEnUp")
        #if not self.e1DPhiToPfMet_MuonEnUp_branch and "e1DPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.e1DPhiToPfMet_MuonEnUp_branch and "e1DPhiToPfMet_MuonEnUp":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_MuonEnUp")
        else:
            self.e1DPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.e1DPhiToPfMet_MuonEnUp_value)

        #print "making e1DPhiToPfMet_PhotonEnDown"
        self.e1DPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("e1DPhiToPfMet_PhotonEnDown")
        #if not self.e1DPhiToPfMet_PhotonEnDown_branch and "e1DPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.e1DPhiToPfMet_PhotonEnDown_branch and "e1DPhiToPfMet_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_PhotonEnDown")
        else:
            self.e1DPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.e1DPhiToPfMet_PhotonEnDown_value)

        #print "making e1DPhiToPfMet_PhotonEnUp"
        self.e1DPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("e1DPhiToPfMet_PhotonEnUp")
        #if not self.e1DPhiToPfMet_PhotonEnUp_branch and "e1DPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.e1DPhiToPfMet_PhotonEnUp_branch and "e1DPhiToPfMet_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_PhotonEnUp")
        else:
            self.e1DPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.e1DPhiToPfMet_PhotonEnUp_value)

        #print "making e1DPhiToPfMet_TauEnDown"
        self.e1DPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("e1DPhiToPfMet_TauEnDown")
        #if not self.e1DPhiToPfMet_TauEnDown_branch and "e1DPhiToPfMet_TauEnDown" not in self.complained:
        if not self.e1DPhiToPfMet_TauEnDown_branch and "e1DPhiToPfMet_TauEnDown":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_TauEnDown")
        else:
            self.e1DPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.e1DPhiToPfMet_TauEnDown_value)

        #print "making e1DPhiToPfMet_TauEnUp"
        self.e1DPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("e1DPhiToPfMet_TauEnUp")
        #if not self.e1DPhiToPfMet_TauEnUp_branch and "e1DPhiToPfMet_TauEnUp" not in self.complained:
        if not self.e1DPhiToPfMet_TauEnUp_branch and "e1DPhiToPfMet_TauEnUp":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_TauEnUp")
        else:
            self.e1DPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.e1DPhiToPfMet_TauEnUp_value)

        #print "making e1DPhiToPfMet_UnclusteredEnDown"
        self.e1DPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("e1DPhiToPfMet_UnclusteredEnDown")
        #if not self.e1DPhiToPfMet_UnclusteredEnDown_branch and "e1DPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.e1DPhiToPfMet_UnclusteredEnDown_branch and "e1DPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_UnclusteredEnDown")
        else:
            self.e1DPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.e1DPhiToPfMet_UnclusteredEnDown_value)

        #print "making e1DPhiToPfMet_UnclusteredEnUp"
        self.e1DPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("e1DPhiToPfMet_UnclusteredEnUp")
        #if not self.e1DPhiToPfMet_UnclusteredEnUp_branch and "e1DPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.e1DPhiToPfMet_UnclusteredEnUp_branch and "e1DPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_UnclusteredEnUp")
        else:
            self.e1DPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.e1DPhiToPfMet_UnclusteredEnUp_value)

        #print "making e1DPhiToPfMet_type1"
        self.e1DPhiToPfMet_type1_branch = the_tree.GetBranch("e1DPhiToPfMet_type1")
        #if not self.e1DPhiToPfMet_type1_branch and "e1DPhiToPfMet_type1" not in self.complained:
        if not self.e1DPhiToPfMet_type1_branch and "e1DPhiToPfMet_type1":
            warnings.warn( "EEETree: Expected branch e1DPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1DPhiToPfMet_type1")
        else:
            self.e1DPhiToPfMet_type1_branch.SetAddress(<void*>&self.e1DPhiToPfMet_type1_value)

        #print "making e1E1x5"
        self.e1E1x5_branch = the_tree.GetBranch("e1E1x5")
        #if not self.e1E1x5_branch and "e1E1x5" not in self.complained:
        if not self.e1E1x5_branch and "e1E1x5":
            warnings.warn( "EEETree: Expected branch e1E1x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1E1x5")
        else:
            self.e1E1x5_branch.SetAddress(<void*>&self.e1E1x5_value)

        #print "making e1E2x5Max"
        self.e1E2x5Max_branch = the_tree.GetBranch("e1E2x5Max")
        #if not self.e1E2x5Max_branch and "e1E2x5Max" not in self.complained:
        if not self.e1E2x5Max_branch and "e1E2x5Max":
            warnings.warn( "EEETree: Expected branch e1E2x5Max does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1E2x5Max")
        else:
            self.e1E2x5Max_branch.SetAddress(<void*>&self.e1E2x5Max_value)

        #print "making e1E5x5"
        self.e1E5x5_branch = the_tree.GetBranch("e1E5x5")
        #if not self.e1E5x5_branch and "e1E5x5" not in self.complained:
        if not self.e1E5x5_branch and "e1E5x5":
            warnings.warn( "EEETree: Expected branch e1E5x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1E5x5")
        else:
            self.e1E5x5_branch.SetAddress(<void*>&self.e1E5x5_value)

        #print "making e1EcalIsoDR03"
        self.e1EcalIsoDR03_branch = the_tree.GetBranch("e1EcalIsoDR03")
        #if not self.e1EcalIsoDR03_branch and "e1EcalIsoDR03" not in self.complained:
        if not self.e1EcalIsoDR03_branch and "e1EcalIsoDR03":
            warnings.warn( "EEETree: Expected branch e1EcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1EcalIsoDR03")
        else:
            self.e1EcalIsoDR03_branch.SetAddress(<void*>&self.e1EcalIsoDR03_value)

        #print "making e1EffectiveArea2012Data"
        self.e1EffectiveArea2012Data_branch = the_tree.GetBranch("e1EffectiveArea2012Data")
        #if not self.e1EffectiveArea2012Data_branch and "e1EffectiveArea2012Data" not in self.complained:
        if not self.e1EffectiveArea2012Data_branch and "e1EffectiveArea2012Data":
            warnings.warn( "EEETree: Expected branch e1EffectiveArea2012Data does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1EffectiveArea2012Data")
        else:
            self.e1EffectiveArea2012Data_branch.SetAddress(<void*>&self.e1EffectiveArea2012Data_value)

        #print "making e1EffectiveAreaSpring15"
        self.e1EffectiveAreaSpring15_branch = the_tree.GetBranch("e1EffectiveAreaSpring15")
        #if not self.e1EffectiveAreaSpring15_branch and "e1EffectiveAreaSpring15" not in self.complained:
        if not self.e1EffectiveAreaSpring15_branch and "e1EffectiveAreaSpring15":
            warnings.warn( "EEETree: Expected branch e1EffectiveAreaSpring15 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1EffectiveAreaSpring15")
        else:
            self.e1EffectiveAreaSpring15_branch.SetAddress(<void*>&self.e1EffectiveAreaSpring15_value)

        #print "making e1EnergyError"
        self.e1EnergyError_branch = the_tree.GetBranch("e1EnergyError")
        #if not self.e1EnergyError_branch and "e1EnergyError" not in self.complained:
        if not self.e1EnergyError_branch and "e1EnergyError":
            warnings.warn( "EEETree: Expected branch e1EnergyError does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1EnergyError")
        else:
            self.e1EnergyError_branch.SetAddress(<void*>&self.e1EnergyError_value)

        #print "making e1Eta"
        self.e1Eta_branch = the_tree.GetBranch("e1Eta")
        #if not self.e1Eta_branch and "e1Eta" not in self.complained:
        if not self.e1Eta_branch and "e1Eta":
            warnings.warn( "EEETree: Expected branch e1Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Eta")
        else:
            self.e1Eta_branch.SetAddress(<void*>&self.e1Eta_value)

        #print "making e1Eta_ElectronEnDown"
        self.e1Eta_ElectronEnDown_branch = the_tree.GetBranch("e1Eta_ElectronEnDown")
        #if not self.e1Eta_ElectronEnDown_branch and "e1Eta_ElectronEnDown" not in self.complained:
        if not self.e1Eta_ElectronEnDown_branch and "e1Eta_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e1Eta_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Eta_ElectronEnDown")
        else:
            self.e1Eta_ElectronEnDown_branch.SetAddress(<void*>&self.e1Eta_ElectronEnDown_value)

        #print "making e1Eta_ElectronEnUp"
        self.e1Eta_ElectronEnUp_branch = the_tree.GetBranch("e1Eta_ElectronEnUp")
        #if not self.e1Eta_ElectronEnUp_branch and "e1Eta_ElectronEnUp" not in self.complained:
        if not self.e1Eta_ElectronEnUp_branch and "e1Eta_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e1Eta_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Eta_ElectronEnUp")
        else:
            self.e1Eta_ElectronEnUp_branch.SetAddress(<void*>&self.e1Eta_ElectronEnUp_value)

        #print "making e1GenCharge"
        self.e1GenCharge_branch = the_tree.GetBranch("e1GenCharge")
        #if not self.e1GenCharge_branch and "e1GenCharge" not in self.complained:
        if not self.e1GenCharge_branch and "e1GenCharge":
            warnings.warn( "EEETree: Expected branch e1GenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenCharge")
        else:
            self.e1GenCharge_branch.SetAddress(<void*>&self.e1GenCharge_value)

        #print "making e1GenEnergy"
        self.e1GenEnergy_branch = the_tree.GetBranch("e1GenEnergy")
        #if not self.e1GenEnergy_branch and "e1GenEnergy" not in self.complained:
        if not self.e1GenEnergy_branch and "e1GenEnergy":
            warnings.warn( "EEETree: Expected branch e1GenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenEnergy")
        else:
            self.e1GenEnergy_branch.SetAddress(<void*>&self.e1GenEnergy_value)

        #print "making e1GenEta"
        self.e1GenEta_branch = the_tree.GetBranch("e1GenEta")
        #if not self.e1GenEta_branch and "e1GenEta" not in self.complained:
        if not self.e1GenEta_branch and "e1GenEta":
            warnings.warn( "EEETree: Expected branch e1GenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenEta")
        else:
            self.e1GenEta_branch.SetAddress(<void*>&self.e1GenEta_value)

        #print "making e1GenMotherPdgId"
        self.e1GenMotherPdgId_branch = the_tree.GetBranch("e1GenMotherPdgId")
        #if not self.e1GenMotherPdgId_branch and "e1GenMotherPdgId" not in self.complained:
        if not self.e1GenMotherPdgId_branch and "e1GenMotherPdgId":
            warnings.warn( "EEETree: Expected branch e1GenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenMotherPdgId")
        else:
            self.e1GenMotherPdgId_branch.SetAddress(<void*>&self.e1GenMotherPdgId_value)

        #print "making e1GenParticle"
        self.e1GenParticle_branch = the_tree.GetBranch("e1GenParticle")
        #if not self.e1GenParticle_branch and "e1GenParticle" not in self.complained:
        if not self.e1GenParticle_branch and "e1GenParticle":
            warnings.warn( "EEETree: Expected branch e1GenParticle does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenParticle")
        else:
            self.e1GenParticle_branch.SetAddress(<void*>&self.e1GenParticle_value)

        #print "making e1GenPdgId"
        self.e1GenPdgId_branch = the_tree.GetBranch("e1GenPdgId")
        #if not self.e1GenPdgId_branch and "e1GenPdgId" not in self.complained:
        if not self.e1GenPdgId_branch and "e1GenPdgId":
            warnings.warn( "EEETree: Expected branch e1GenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenPdgId")
        else:
            self.e1GenPdgId_branch.SetAddress(<void*>&self.e1GenPdgId_value)

        #print "making e1GenPhi"
        self.e1GenPhi_branch = the_tree.GetBranch("e1GenPhi")
        #if not self.e1GenPhi_branch and "e1GenPhi" not in self.complained:
        if not self.e1GenPhi_branch and "e1GenPhi":
            warnings.warn( "EEETree: Expected branch e1GenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenPhi")
        else:
            self.e1GenPhi_branch.SetAddress(<void*>&self.e1GenPhi_value)

        #print "making e1GenPrompt"
        self.e1GenPrompt_branch = the_tree.GetBranch("e1GenPrompt")
        #if not self.e1GenPrompt_branch and "e1GenPrompt" not in self.complained:
        if not self.e1GenPrompt_branch and "e1GenPrompt":
            warnings.warn( "EEETree: Expected branch e1GenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenPrompt")
        else:
            self.e1GenPrompt_branch.SetAddress(<void*>&self.e1GenPrompt_value)

        #print "making e1GenPromptTauDecay"
        self.e1GenPromptTauDecay_branch = the_tree.GetBranch("e1GenPromptTauDecay")
        #if not self.e1GenPromptTauDecay_branch and "e1GenPromptTauDecay" not in self.complained:
        if not self.e1GenPromptTauDecay_branch and "e1GenPromptTauDecay":
            warnings.warn( "EEETree: Expected branch e1GenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenPromptTauDecay")
        else:
            self.e1GenPromptTauDecay_branch.SetAddress(<void*>&self.e1GenPromptTauDecay_value)

        #print "making e1GenPt"
        self.e1GenPt_branch = the_tree.GetBranch("e1GenPt")
        #if not self.e1GenPt_branch and "e1GenPt" not in self.complained:
        if not self.e1GenPt_branch and "e1GenPt":
            warnings.warn( "EEETree: Expected branch e1GenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenPt")
        else:
            self.e1GenPt_branch.SetAddress(<void*>&self.e1GenPt_value)

        #print "making e1GenTauDecay"
        self.e1GenTauDecay_branch = the_tree.GetBranch("e1GenTauDecay")
        #if not self.e1GenTauDecay_branch and "e1GenTauDecay" not in self.complained:
        if not self.e1GenTauDecay_branch and "e1GenTauDecay":
            warnings.warn( "EEETree: Expected branch e1GenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenTauDecay")
        else:
            self.e1GenTauDecay_branch.SetAddress(<void*>&self.e1GenTauDecay_value)

        #print "making e1GenVZ"
        self.e1GenVZ_branch = the_tree.GetBranch("e1GenVZ")
        #if not self.e1GenVZ_branch and "e1GenVZ" not in self.complained:
        if not self.e1GenVZ_branch and "e1GenVZ":
            warnings.warn( "EEETree: Expected branch e1GenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenVZ")
        else:
            self.e1GenVZ_branch.SetAddress(<void*>&self.e1GenVZ_value)

        #print "making e1GenVtxPVMatch"
        self.e1GenVtxPVMatch_branch = the_tree.GetBranch("e1GenVtxPVMatch")
        #if not self.e1GenVtxPVMatch_branch and "e1GenVtxPVMatch" not in self.complained:
        if not self.e1GenVtxPVMatch_branch and "e1GenVtxPVMatch":
            warnings.warn( "EEETree: Expected branch e1GenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1GenVtxPVMatch")
        else:
            self.e1GenVtxPVMatch_branch.SetAddress(<void*>&self.e1GenVtxPVMatch_value)

        #print "making e1HadronicDepth1OverEm"
        self.e1HadronicDepth1OverEm_branch = the_tree.GetBranch("e1HadronicDepth1OverEm")
        #if not self.e1HadronicDepth1OverEm_branch and "e1HadronicDepth1OverEm" not in self.complained:
        if not self.e1HadronicDepth1OverEm_branch and "e1HadronicDepth1OverEm":
            warnings.warn( "EEETree: Expected branch e1HadronicDepth1OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1HadronicDepth1OverEm")
        else:
            self.e1HadronicDepth1OverEm_branch.SetAddress(<void*>&self.e1HadronicDepth1OverEm_value)

        #print "making e1HadronicDepth2OverEm"
        self.e1HadronicDepth2OverEm_branch = the_tree.GetBranch("e1HadronicDepth2OverEm")
        #if not self.e1HadronicDepth2OverEm_branch and "e1HadronicDepth2OverEm" not in self.complained:
        if not self.e1HadronicDepth2OverEm_branch and "e1HadronicDepth2OverEm":
            warnings.warn( "EEETree: Expected branch e1HadronicDepth2OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1HadronicDepth2OverEm")
        else:
            self.e1HadronicDepth2OverEm_branch.SetAddress(<void*>&self.e1HadronicDepth2OverEm_value)

        #print "making e1HadronicOverEM"
        self.e1HadronicOverEM_branch = the_tree.GetBranch("e1HadronicOverEM")
        #if not self.e1HadronicOverEM_branch and "e1HadronicOverEM" not in self.complained:
        if not self.e1HadronicOverEM_branch and "e1HadronicOverEM":
            warnings.warn( "EEETree: Expected branch e1HadronicOverEM does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1HadronicOverEM")
        else:
            self.e1HadronicOverEM_branch.SetAddress(<void*>&self.e1HadronicOverEM_value)

        #print "making e1HcalIsoDR03"
        self.e1HcalIsoDR03_branch = the_tree.GetBranch("e1HcalIsoDR03")
        #if not self.e1HcalIsoDR03_branch and "e1HcalIsoDR03" not in self.complained:
        if not self.e1HcalIsoDR03_branch and "e1HcalIsoDR03":
            warnings.warn( "EEETree: Expected branch e1HcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1HcalIsoDR03")
        else:
            self.e1HcalIsoDR03_branch.SetAddress(<void*>&self.e1HcalIsoDR03_value)

        #print "making e1IP3D"
        self.e1IP3D_branch = the_tree.GetBranch("e1IP3D")
        #if not self.e1IP3D_branch and "e1IP3D" not in self.complained:
        if not self.e1IP3D_branch and "e1IP3D":
            warnings.warn( "EEETree: Expected branch e1IP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1IP3D")
        else:
            self.e1IP3D_branch.SetAddress(<void*>&self.e1IP3D_value)

        #print "making e1IP3DErr"
        self.e1IP3DErr_branch = the_tree.GetBranch("e1IP3DErr")
        #if not self.e1IP3DErr_branch and "e1IP3DErr" not in self.complained:
        if not self.e1IP3DErr_branch and "e1IP3DErr":
            warnings.warn( "EEETree: Expected branch e1IP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1IP3DErr")
        else:
            self.e1IP3DErr_branch.SetAddress(<void*>&self.e1IP3DErr_value)

        #print "making e1JetArea"
        self.e1JetArea_branch = the_tree.GetBranch("e1JetArea")
        #if not self.e1JetArea_branch and "e1JetArea" not in self.complained:
        if not self.e1JetArea_branch and "e1JetArea":
            warnings.warn( "EEETree: Expected branch e1JetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetArea")
        else:
            self.e1JetArea_branch.SetAddress(<void*>&self.e1JetArea_value)

        #print "making e1JetBtag"
        self.e1JetBtag_branch = the_tree.GetBranch("e1JetBtag")
        #if not self.e1JetBtag_branch and "e1JetBtag" not in self.complained:
        if not self.e1JetBtag_branch and "e1JetBtag":
            warnings.warn( "EEETree: Expected branch e1JetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetBtag")
        else:
            self.e1JetBtag_branch.SetAddress(<void*>&self.e1JetBtag_value)

        #print "making e1JetEtaEtaMoment"
        self.e1JetEtaEtaMoment_branch = the_tree.GetBranch("e1JetEtaEtaMoment")
        #if not self.e1JetEtaEtaMoment_branch and "e1JetEtaEtaMoment" not in self.complained:
        if not self.e1JetEtaEtaMoment_branch and "e1JetEtaEtaMoment":
            warnings.warn( "EEETree: Expected branch e1JetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetEtaEtaMoment")
        else:
            self.e1JetEtaEtaMoment_branch.SetAddress(<void*>&self.e1JetEtaEtaMoment_value)

        #print "making e1JetEtaPhiMoment"
        self.e1JetEtaPhiMoment_branch = the_tree.GetBranch("e1JetEtaPhiMoment")
        #if not self.e1JetEtaPhiMoment_branch and "e1JetEtaPhiMoment" not in self.complained:
        if not self.e1JetEtaPhiMoment_branch and "e1JetEtaPhiMoment":
            warnings.warn( "EEETree: Expected branch e1JetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetEtaPhiMoment")
        else:
            self.e1JetEtaPhiMoment_branch.SetAddress(<void*>&self.e1JetEtaPhiMoment_value)

        #print "making e1JetEtaPhiSpread"
        self.e1JetEtaPhiSpread_branch = the_tree.GetBranch("e1JetEtaPhiSpread")
        #if not self.e1JetEtaPhiSpread_branch and "e1JetEtaPhiSpread" not in self.complained:
        if not self.e1JetEtaPhiSpread_branch and "e1JetEtaPhiSpread":
            warnings.warn( "EEETree: Expected branch e1JetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetEtaPhiSpread")
        else:
            self.e1JetEtaPhiSpread_branch.SetAddress(<void*>&self.e1JetEtaPhiSpread_value)

        #print "making e1JetPFCISVBtag"
        self.e1JetPFCISVBtag_branch = the_tree.GetBranch("e1JetPFCISVBtag")
        #if not self.e1JetPFCISVBtag_branch and "e1JetPFCISVBtag" not in self.complained:
        if not self.e1JetPFCISVBtag_branch and "e1JetPFCISVBtag":
            warnings.warn( "EEETree: Expected branch e1JetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetPFCISVBtag")
        else:
            self.e1JetPFCISVBtag_branch.SetAddress(<void*>&self.e1JetPFCISVBtag_value)

        #print "making e1JetPartonFlavour"
        self.e1JetPartonFlavour_branch = the_tree.GetBranch("e1JetPartonFlavour")
        #if not self.e1JetPartonFlavour_branch and "e1JetPartonFlavour" not in self.complained:
        if not self.e1JetPartonFlavour_branch and "e1JetPartonFlavour":
            warnings.warn( "EEETree: Expected branch e1JetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetPartonFlavour")
        else:
            self.e1JetPartonFlavour_branch.SetAddress(<void*>&self.e1JetPartonFlavour_value)

        #print "making e1JetPhiPhiMoment"
        self.e1JetPhiPhiMoment_branch = the_tree.GetBranch("e1JetPhiPhiMoment")
        #if not self.e1JetPhiPhiMoment_branch and "e1JetPhiPhiMoment" not in self.complained:
        if not self.e1JetPhiPhiMoment_branch and "e1JetPhiPhiMoment":
            warnings.warn( "EEETree: Expected branch e1JetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetPhiPhiMoment")
        else:
            self.e1JetPhiPhiMoment_branch.SetAddress(<void*>&self.e1JetPhiPhiMoment_value)

        #print "making e1JetPt"
        self.e1JetPt_branch = the_tree.GetBranch("e1JetPt")
        #if not self.e1JetPt_branch and "e1JetPt" not in self.complained:
        if not self.e1JetPt_branch and "e1JetPt":
            warnings.warn( "EEETree: Expected branch e1JetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1JetPt")
        else:
            self.e1JetPt_branch.SetAddress(<void*>&self.e1JetPt_value)

        #print "making e1LowestMll"
        self.e1LowestMll_branch = the_tree.GetBranch("e1LowestMll")
        #if not self.e1LowestMll_branch and "e1LowestMll" not in self.complained:
        if not self.e1LowestMll_branch and "e1LowestMll":
            warnings.warn( "EEETree: Expected branch e1LowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1LowestMll")
        else:
            self.e1LowestMll_branch.SetAddress(<void*>&self.e1LowestMll_value)

        #print "making e1MVANonTrigCategory"
        self.e1MVANonTrigCategory_branch = the_tree.GetBranch("e1MVANonTrigCategory")
        #if not self.e1MVANonTrigCategory_branch and "e1MVANonTrigCategory" not in self.complained:
        if not self.e1MVANonTrigCategory_branch and "e1MVANonTrigCategory":
            warnings.warn( "EEETree: Expected branch e1MVANonTrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVANonTrigCategory")
        else:
            self.e1MVANonTrigCategory_branch.SetAddress(<void*>&self.e1MVANonTrigCategory_value)

        #print "making e1MVANonTrigID"
        self.e1MVANonTrigID_branch = the_tree.GetBranch("e1MVANonTrigID")
        #if not self.e1MVANonTrigID_branch and "e1MVANonTrigID" not in self.complained:
        if not self.e1MVANonTrigID_branch and "e1MVANonTrigID":
            warnings.warn( "EEETree: Expected branch e1MVANonTrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVANonTrigID")
        else:
            self.e1MVANonTrigID_branch.SetAddress(<void*>&self.e1MVANonTrigID_value)

        #print "making e1MVANonTrigWP80"
        self.e1MVANonTrigWP80_branch = the_tree.GetBranch("e1MVANonTrigWP80")
        #if not self.e1MVANonTrigWP80_branch and "e1MVANonTrigWP80" not in self.complained:
        if not self.e1MVANonTrigWP80_branch and "e1MVANonTrigWP80":
            warnings.warn( "EEETree: Expected branch e1MVANonTrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVANonTrigWP80")
        else:
            self.e1MVANonTrigWP80_branch.SetAddress(<void*>&self.e1MVANonTrigWP80_value)

        #print "making e1MVANonTrigWP90"
        self.e1MVANonTrigWP90_branch = the_tree.GetBranch("e1MVANonTrigWP90")
        #if not self.e1MVANonTrigWP90_branch and "e1MVANonTrigWP90" not in self.complained:
        if not self.e1MVANonTrigWP90_branch and "e1MVANonTrigWP90":
            warnings.warn( "EEETree: Expected branch e1MVANonTrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVANonTrigWP90")
        else:
            self.e1MVANonTrigWP90_branch.SetAddress(<void*>&self.e1MVANonTrigWP90_value)

        #print "making e1MVATrigCategory"
        self.e1MVATrigCategory_branch = the_tree.GetBranch("e1MVATrigCategory")
        #if not self.e1MVATrigCategory_branch and "e1MVATrigCategory" not in self.complained:
        if not self.e1MVATrigCategory_branch and "e1MVATrigCategory":
            warnings.warn( "EEETree: Expected branch e1MVATrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVATrigCategory")
        else:
            self.e1MVATrigCategory_branch.SetAddress(<void*>&self.e1MVATrigCategory_value)

        #print "making e1MVATrigID"
        self.e1MVATrigID_branch = the_tree.GetBranch("e1MVATrigID")
        #if not self.e1MVATrigID_branch and "e1MVATrigID" not in self.complained:
        if not self.e1MVATrigID_branch and "e1MVATrigID":
            warnings.warn( "EEETree: Expected branch e1MVATrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVATrigID")
        else:
            self.e1MVATrigID_branch.SetAddress(<void*>&self.e1MVATrigID_value)

        #print "making e1MVATrigWP80"
        self.e1MVATrigWP80_branch = the_tree.GetBranch("e1MVATrigWP80")
        #if not self.e1MVATrigWP80_branch and "e1MVATrigWP80" not in self.complained:
        if not self.e1MVATrigWP80_branch and "e1MVATrigWP80":
            warnings.warn( "EEETree: Expected branch e1MVATrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVATrigWP80")
        else:
            self.e1MVATrigWP80_branch.SetAddress(<void*>&self.e1MVATrigWP80_value)

        #print "making e1MVATrigWP90"
        self.e1MVATrigWP90_branch = the_tree.GetBranch("e1MVATrigWP90")
        #if not self.e1MVATrigWP90_branch and "e1MVATrigWP90" not in self.complained:
        if not self.e1MVATrigWP90_branch and "e1MVATrigWP90":
            warnings.warn( "EEETree: Expected branch e1MVATrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MVATrigWP90")
        else:
            self.e1MVATrigWP90_branch.SetAddress(<void*>&self.e1MVATrigWP90_value)

        #print "making e1Mass"
        self.e1Mass_branch = the_tree.GetBranch("e1Mass")
        #if not self.e1Mass_branch and "e1Mass" not in self.complained:
        if not self.e1Mass_branch and "e1Mass":
            warnings.warn( "EEETree: Expected branch e1Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Mass")
        else:
            self.e1Mass_branch.SetAddress(<void*>&self.e1Mass_value)

        #print "making e1MatchesDoubleE"
        self.e1MatchesDoubleE_branch = the_tree.GetBranch("e1MatchesDoubleE")
        #if not self.e1MatchesDoubleE_branch and "e1MatchesDoubleE" not in self.complained:
        if not self.e1MatchesDoubleE_branch and "e1MatchesDoubleE":
            warnings.warn( "EEETree: Expected branch e1MatchesDoubleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesDoubleE")
        else:
            self.e1MatchesDoubleE_branch.SetAddress(<void*>&self.e1MatchesDoubleE_value)

        #print "making e1MatchesDoubleESingleMu"
        self.e1MatchesDoubleESingleMu_branch = the_tree.GetBranch("e1MatchesDoubleESingleMu")
        #if not self.e1MatchesDoubleESingleMu_branch and "e1MatchesDoubleESingleMu" not in self.complained:
        if not self.e1MatchesDoubleESingleMu_branch and "e1MatchesDoubleESingleMu":
            warnings.warn( "EEETree: Expected branch e1MatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesDoubleESingleMu")
        else:
            self.e1MatchesDoubleESingleMu_branch.SetAddress(<void*>&self.e1MatchesDoubleESingleMu_value)

        #print "making e1MatchesDoubleMuSingleE"
        self.e1MatchesDoubleMuSingleE_branch = the_tree.GetBranch("e1MatchesDoubleMuSingleE")
        #if not self.e1MatchesDoubleMuSingleE_branch and "e1MatchesDoubleMuSingleE" not in self.complained:
        if not self.e1MatchesDoubleMuSingleE_branch and "e1MatchesDoubleMuSingleE":
            warnings.warn( "EEETree: Expected branch e1MatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesDoubleMuSingleE")
        else:
            self.e1MatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.e1MatchesDoubleMuSingleE_value)

        #print "making e1MatchesSingleE"
        self.e1MatchesSingleE_branch = the_tree.GetBranch("e1MatchesSingleE")
        #if not self.e1MatchesSingleE_branch and "e1MatchesSingleE" not in self.complained:
        if not self.e1MatchesSingleE_branch and "e1MatchesSingleE":
            warnings.warn( "EEETree: Expected branch e1MatchesSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesSingleE")
        else:
            self.e1MatchesSingleE_branch.SetAddress(<void*>&self.e1MatchesSingleE_value)

        #print "making e1MatchesSingleESingleMu"
        self.e1MatchesSingleESingleMu_branch = the_tree.GetBranch("e1MatchesSingleESingleMu")
        #if not self.e1MatchesSingleESingleMu_branch and "e1MatchesSingleESingleMu" not in self.complained:
        if not self.e1MatchesSingleESingleMu_branch and "e1MatchesSingleESingleMu":
            warnings.warn( "EEETree: Expected branch e1MatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesSingleESingleMu")
        else:
            self.e1MatchesSingleESingleMu_branch.SetAddress(<void*>&self.e1MatchesSingleESingleMu_value)

        #print "making e1MatchesSingleE_leg1"
        self.e1MatchesSingleE_leg1_branch = the_tree.GetBranch("e1MatchesSingleE_leg1")
        #if not self.e1MatchesSingleE_leg1_branch and "e1MatchesSingleE_leg1" not in self.complained:
        if not self.e1MatchesSingleE_leg1_branch and "e1MatchesSingleE_leg1":
            warnings.warn( "EEETree: Expected branch e1MatchesSingleE_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesSingleE_leg1")
        else:
            self.e1MatchesSingleE_leg1_branch.SetAddress(<void*>&self.e1MatchesSingleE_leg1_value)

        #print "making e1MatchesSingleE_leg2"
        self.e1MatchesSingleE_leg2_branch = the_tree.GetBranch("e1MatchesSingleE_leg2")
        #if not self.e1MatchesSingleE_leg2_branch and "e1MatchesSingleE_leg2" not in self.complained:
        if not self.e1MatchesSingleE_leg2_branch and "e1MatchesSingleE_leg2":
            warnings.warn( "EEETree: Expected branch e1MatchesSingleE_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesSingleE_leg2")
        else:
            self.e1MatchesSingleE_leg2_branch.SetAddress(<void*>&self.e1MatchesSingleE_leg2_value)

        #print "making e1MatchesSingleMuSingleE"
        self.e1MatchesSingleMuSingleE_branch = the_tree.GetBranch("e1MatchesSingleMuSingleE")
        #if not self.e1MatchesSingleMuSingleE_branch and "e1MatchesSingleMuSingleE" not in self.complained:
        if not self.e1MatchesSingleMuSingleE_branch and "e1MatchesSingleMuSingleE":
            warnings.warn( "EEETree: Expected branch e1MatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesSingleMuSingleE")
        else:
            self.e1MatchesSingleMuSingleE_branch.SetAddress(<void*>&self.e1MatchesSingleMuSingleE_value)

        #print "making e1MatchesTripleE"
        self.e1MatchesTripleE_branch = the_tree.GetBranch("e1MatchesTripleE")
        #if not self.e1MatchesTripleE_branch and "e1MatchesTripleE" not in self.complained:
        if not self.e1MatchesTripleE_branch and "e1MatchesTripleE":
            warnings.warn( "EEETree: Expected branch e1MatchesTripleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MatchesTripleE")
        else:
            self.e1MatchesTripleE_branch.SetAddress(<void*>&self.e1MatchesTripleE_value)

        #print "making e1MissingHits"
        self.e1MissingHits_branch = the_tree.GetBranch("e1MissingHits")
        #if not self.e1MissingHits_branch and "e1MissingHits" not in self.complained:
        if not self.e1MissingHits_branch and "e1MissingHits":
            warnings.warn( "EEETree: Expected branch e1MissingHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MissingHits")
        else:
            self.e1MissingHits_branch.SetAddress(<void*>&self.e1MissingHits_value)

        #print "making e1MtToPfMet_ElectronEnDown"
        self.e1MtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("e1MtToPfMet_ElectronEnDown")
        #if not self.e1MtToPfMet_ElectronEnDown_branch and "e1MtToPfMet_ElectronEnDown" not in self.complained:
        if not self.e1MtToPfMet_ElectronEnDown_branch and "e1MtToPfMet_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_ElectronEnDown")
        else:
            self.e1MtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.e1MtToPfMet_ElectronEnDown_value)

        #print "making e1MtToPfMet_ElectronEnUp"
        self.e1MtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("e1MtToPfMet_ElectronEnUp")
        #if not self.e1MtToPfMet_ElectronEnUp_branch and "e1MtToPfMet_ElectronEnUp" not in self.complained:
        if not self.e1MtToPfMet_ElectronEnUp_branch and "e1MtToPfMet_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_ElectronEnUp")
        else:
            self.e1MtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.e1MtToPfMet_ElectronEnUp_value)

        #print "making e1MtToPfMet_JetEnDown"
        self.e1MtToPfMet_JetEnDown_branch = the_tree.GetBranch("e1MtToPfMet_JetEnDown")
        #if not self.e1MtToPfMet_JetEnDown_branch and "e1MtToPfMet_JetEnDown" not in self.complained:
        if not self.e1MtToPfMet_JetEnDown_branch and "e1MtToPfMet_JetEnDown":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_JetEnDown")
        else:
            self.e1MtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.e1MtToPfMet_JetEnDown_value)

        #print "making e1MtToPfMet_JetEnUp"
        self.e1MtToPfMet_JetEnUp_branch = the_tree.GetBranch("e1MtToPfMet_JetEnUp")
        #if not self.e1MtToPfMet_JetEnUp_branch and "e1MtToPfMet_JetEnUp" not in self.complained:
        if not self.e1MtToPfMet_JetEnUp_branch and "e1MtToPfMet_JetEnUp":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_JetEnUp")
        else:
            self.e1MtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.e1MtToPfMet_JetEnUp_value)

        #print "making e1MtToPfMet_JetResDown"
        self.e1MtToPfMet_JetResDown_branch = the_tree.GetBranch("e1MtToPfMet_JetResDown")
        #if not self.e1MtToPfMet_JetResDown_branch and "e1MtToPfMet_JetResDown" not in self.complained:
        if not self.e1MtToPfMet_JetResDown_branch and "e1MtToPfMet_JetResDown":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_JetResDown")
        else:
            self.e1MtToPfMet_JetResDown_branch.SetAddress(<void*>&self.e1MtToPfMet_JetResDown_value)

        #print "making e1MtToPfMet_JetResUp"
        self.e1MtToPfMet_JetResUp_branch = the_tree.GetBranch("e1MtToPfMet_JetResUp")
        #if not self.e1MtToPfMet_JetResUp_branch and "e1MtToPfMet_JetResUp" not in self.complained:
        if not self.e1MtToPfMet_JetResUp_branch and "e1MtToPfMet_JetResUp":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_JetResUp")
        else:
            self.e1MtToPfMet_JetResUp_branch.SetAddress(<void*>&self.e1MtToPfMet_JetResUp_value)

        #print "making e1MtToPfMet_MuonEnDown"
        self.e1MtToPfMet_MuonEnDown_branch = the_tree.GetBranch("e1MtToPfMet_MuonEnDown")
        #if not self.e1MtToPfMet_MuonEnDown_branch and "e1MtToPfMet_MuonEnDown" not in self.complained:
        if not self.e1MtToPfMet_MuonEnDown_branch and "e1MtToPfMet_MuonEnDown":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_MuonEnDown")
        else:
            self.e1MtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.e1MtToPfMet_MuonEnDown_value)

        #print "making e1MtToPfMet_MuonEnUp"
        self.e1MtToPfMet_MuonEnUp_branch = the_tree.GetBranch("e1MtToPfMet_MuonEnUp")
        #if not self.e1MtToPfMet_MuonEnUp_branch and "e1MtToPfMet_MuonEnUp" not in self.complained:
        if not self.e1MtToPfMet_MuonEnUp_branch and "e1MtToPfMet_MuonEnUp":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_MuonEnUp")
        else:
            self.e1MtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.e1MtToPfMet_MuonEnUp_value)

        #print "making e1MtToPfMet_PhotonEnDown"
        self.e1MtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("e1MtToPfMet_PhotonEnDown")
        #if not self.e1MtToPfMet_PhotonEnDown_branch and "e1MtToPfMet_PhotonEnDown" not in self.complained:
        if not self.e1MtToPfMet_PhotonEnDown_branch and "e1MtToPfMet_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_PhotonEnDown")
        else:
            self.e1MtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.e1MtToPfMet_PhotonEnDown_value)

        #print "making e1MtToPfMet_PhotonEnUp"
        self.e1MtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("e1MtToPfMet_PhotonEnUp")
        #if not self.e1MtToPfMet_PhotonEnUp_branch and "e1MtToPfMet_PhotonEnUp" not in self.complained:
        if not self.e1MtToPfMet_PhotonEnUp_branch and "e1MtToPfMet_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_PhotonEnUp")
        else:
            self.e1MtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.e1MtToPfMet_PhotonEnUp_value)

        #print "making e1MtToPfMet_Raw"
        self.e1MtToPfMet_Raw_branch = the_tree.GetBranch("e1MtToPfMet_Raw")
        #if not self.e1MtToPfMet_Raw_branch and "e1MtToPfMet_Raw" not in self.complained:
        if not self.e1MtToPfMet_Raw_branch and "e1MtToPfMet_Raw":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_Raw")
        else:
            self.e1MtToPfMet_Raw_branch.SetAddress(<void*>&self.e1MtToPfMet_Raw_value)

        #print "making e1MtToPfMet_TauEnDown"
        self.e1MtToPfMet_TauEnDown_branch = the_tree.GetBranch("e1MtToPfMet_TauEnDown")
        #if not self.e1MtToPfMet_TauEnDown_branch and "e1MtToPfMet_TauEnDown" not in self.complained:
        if not self.e1MtToPfMet_TauEnDown_branch and "e1MtToPfMet_TauEnDown":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_TauEnDown")
        else:
            self.e1MtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.e1MtToPfMet_TauEnDown_value)

        #print "making e1MtToPfMet_TauEnUp"
        self.e1MtToPfMet_TauEnUp_branch = the_tree.GetBranch("e1MtToPfMet_TauEnUp")
        #if not self.e1MtToPfMet_TauEnUp_branch and "e1MtToPfMet_TauEnUp" not in self.complained:
        if not self.e1MtToPfMet_TauEnUp_branch and "e1MtToPfMet_TauEnUp":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_TauEnUp")
        else:
            self.e1MtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.e1MtToPfMet_TauEnUp_value)

        #print "making e1MtToPfMet_UnclusteredEnDown"
        self.e1MtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("e1MtToPfMet_UnclusteredEnDown")
        #if not self.e1MtToPfMet_UnclusteredEnDown_branch and "e1MtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.e1MtToPfMet_UnclusteredEnDown_branch and "e1MtToPfMet_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_UnclusteredEnDown")
        else:
            self.e1MtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.e1MtToPfMet_UnclusteredEnDown_value)

        #print "making e1MtToPfMet_UnclusteredEnUp"
        self.e1MtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("e1MtToPfMet_UnclusteredEnUp")
        #if not self.e1MtToPfMet_UnclusteredEnUp_branch and "e1MtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.e1MtToPfMet_UnclusteredEnUp_branch and "e1MtToPfMet_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_UnclusteredEnUp")
        else:
            self.e1MtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.e1MtToPfMet_UnclusteredEnUp_value)

        #print "making e1MtToPfMet_type1"
        self.e1MtToPfMet_type1_branch = the_tree.GetBranch("e1MtToPfMet_type1")
        #if not self.e1MtToPfMet_type1_branch and "e1MtToPfMet_type1" not in self.complained:
        if not self.e1MtToPfMet_type1_branch and "e1MtToPfMet_type1":
            warnings.warn( "EEETree: Expected branch e1MtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1MtToPfMet_type1")
        else:
            self.e1MtToPfMet_type1_branch.SetAddress(<void*>&self.e1MtToPfMet_type1_value)

        #print "making e1NearMuonVeto"
        self.e1NearMuonVeto_branch = the_tree.GetBranch("e1NearMuonVeto")
        #if not self.e1NearMuonVeto_branch and "e1NearMuonVeto" not in self.complained:
        if not self.e1NearMuonVeto_branch and "e1NearMuonVeto":
            warnings.warn( "EEETree: Expected branch e1NearMuonVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1NearMuonVeto")
        else:
            self.e1NearMuonVeto_branch.SetAddress(<void*>&self.e1NearMuonVeto_value)

        #print "making e1NearestMuonDR"
        self.e1NearestMuonDR_branch = the_tree.GetBranch("e1NearestMuonDR")
        #if not self.e1NearestMuonDR_branch and "e1NearestMuonDR" not in self.complained:
        if not self.e1NearestMuonDR_branch and "e1NearestMuonDR":
            warnings.warn( "EEETree: Expected branch e1NearestMuonDR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1NearestMuonDR")
        else:
            self.e1NearestMuonDR_branch.SetAddress(<void*>&self.e1NearestMuonDR_value)

        #print "making e1NearestZMass"
        self.e1NearestZMass_branch = the_tree.GetBranch("e1NearestZMass")
        #if not self.e1NearestZMass_branch and "e1NearestZMass" not in self.complained:
        if not self.e1NearestZMass_branch and "e1NearestZMass":
            warnings.warn( "EEETree: Expected branch e1NearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1NearestZMass")
        else:
            self.e1NearestZMass_branch.SetAddress(<void*>&self.e1NearestZMass_value)

        #print "making e1PFChargedIso"
        self.e1PFChargedIso_branch = the_tree.GetBranch("e1PFChargedIso")
        #if not self.e1PFChargedIso_branch and "e1PFChargedIso" not in self.complained:
        if not self.e1PFChargedIso_branch and "e1PFChargedIso":
            warnings.warn( "EEETree: Expected branch e1PFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1PFChargedIso")
        else:
            self.e1PFChargedIso_branch.SetAddress(<void*>&self.e1PFChargedIso_value)

        #print "making e1PFNeutralIso"
        self.e1PFNeutralIso_branch = the_tree.GetBranch("e1PFNeutralIso")
        #if not self.e1PFNeutralIso_branch and "e1PFNeutralIso" not in self.complained:
        if not self.e1PFNeutralIso_branch and "e1PFNeutralIso":
            warnings.warn( "EEETree: Expected branch e1PFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1PFNeutralIso")
        else:
            self.e1PFNeutralIso_branch.SetAddress(<void*>&self.e1PFNeutralIso_value)

        #print "making e1PFPUChargedIso"
        self.e1PFPUChargedIso_branch = the_tree.GetBranch("e1PFPUChargedIso")
        #if not self.e1PFPUChargedIso_branch and "e1PFPUChargedIso" not in self.complained:
        if not self.e1PFPUChargedIso_branch and "e1PFPUChargedIso":
            warnings.warn( "EEETree: Expected branch e1PFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1PFPUChargedIso")
        else:
            self.e1PFPUChargedIso_branch.SetAddress(<void*>&self.e1PFPUChargedIso_value)

        #print "making e1PFPhotonIso"
        self.e1PFPhotonIso_branch = the_tree.GetBranch("e1PFPhotonIso")
        #if not self.e1PFPhotonIso_branch and "e1PFPhotonIso" not in self.complained:
        if not self.e1PFPhotonIso_branch and "e1PFPhotonIso":
            warnings.warn( "EEETree: Expected branch e1PFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1PFPhotonIso")
        else:
            self.e1PFPhotonIso_branch.SetAddress(<void*>&self.e1PFPhotonIso_value)

        #print "making e1PVDXY"
        self.e1PVDXY_branch = the_tree.GetBranch("e1PVDXY")
        #if not self.e1PVDXY_branch and "e1PVDXY" not in self.complained:
        if not self.e1PVDXY_branch and "e1PVDXY":
            warnings.warn( "EEETree: Expected branch e1PVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1PVDXY")
        else:
            self.e1PVDXY_branch.SetAddress(<void*>&self.e1PVDXY_value)

        #print "making e1PVDZ"
        self.e1PVDZ_branch = the_tree.GetBranch("e1PVDZ")
        #if not self.e1PVDZ_branch and "e1PVDZ" not in self.complained:
        if not self.e1PVDZ_branch and "e1PVDZ":
            warnings.warn( "EEETree: Expected branch e1PVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1PVDZ")
        else:
            self.e1PVDZ_branch.SetAddress(<void*>&self.e1PVDZ_value)

        #print "making e1PassesConversionVeto"
        self.e1PassesConversionVeto_branch = the_tree.GetBranch("e1PassesConversionVeto")
        #if not self.e1PassesConversionVeto_branch and "e1PassesConversionVeto" not in self.complained:
        if not self.e1PassesConversionVeto_branch and "e1PassesConversionVeto":
            warnings.warn( "EEETree: Expected branch e1PassesConversionVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1PassesConversionVeto")
        else:
            self.e1PassesConversionVeto_branch.SetAddress(<void*>&self.e1PassesConversionVeto_value)

        #print "making e1Phi"
        self.e1Phi_branch = the_tree.GetBranch("e1Phi")
        #if not self.e1Phi_branch and "e1Phi" not in self.complained:
        if not self.e1Phi_branch and "e1Phi":
            warnings.warn( "EEETree: Expected branch e1Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Phi")
        else:
            self.e1Phi_branch.SetAddress(<void*>&self.e1Phi_value)

        #print "making e1Phi_ElectronEnDown"
        self.e1Phi_ElectronEnDown_branch = the_tree.GetBranch("e1Phi_ElectronEnDown")
        #if not self.e1Phi_ElectronEnDown_branch and "e1Phi_ElectronEnDown" not in self.complained:
        if not self.e1Phi_ElectronEnDown_branch and "e1Phi_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e1Phi_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Phi_ElectronEnDown")
        else:
            self.e1Phi_ElectronEnDown_branch.SetAddress(<void*>&self.e1Phi_ElectronEnDown_value)

        #print "making e1Phi_ElectronEnUp"
        self.e1Phi_ElectronEnUp_branch = the_tree.GetBranch("e1Phi_ElectronEnUp")
        #if not self.e1Phi_ElectronEnUp_branch and "e1Phi_ElectronEnUp" not in self.complained:
        if not self.e1Phi_ElectronEnUp_branch and "e1Phi_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e1Phi_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Phi_ElectronEnUp")
        else:
            self.e1Phi_ElectronEnUp_branch.SetAddress(<void*>&self.e1Phi_ElectronEnUp_value)

        #print "making e1Pt"
        self.e1Pt_branch = the_tree.GetBranch("e1Pt")
        #if not self.e1Pt_branch and "e1Pt" not in self.complained:
        if not self.e1Pt_branch and "e1Pt":
            warnings.warn( "EEETree: Expected branch e1Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Pt")
        else:
            self.e1Pt_branch.SetAddress(<void*>&self.e1Pt_value)

        #print "making e1Pt_ElectronEnDown"
        self.e1Pt_ElectronEnDown_branch = the_tree.GetBranch("e1Pt_ElectronEnDown")
        #if not self.e1Pt_ElectronEnDown_branch and "e1Pt_ElectronEnDown" not in self.complained:
        if not self.e1Pt_ElectronEnDown_branch and "e1Pt_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e1Pt_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Pt_ElectronEnDown")
        else:
            self.e1Pt_ElectronEnDown_branch.SetAddress(<void*>&self.e1Pt_ElectronEnDown_value)

        #print "making e1Pt_ElectronEnUp"
        self.e1Pt_ElectronEnUp_branch = the_tree.GetBranch("e1Pt_ElectronEnUp")
        #if not self.e1Pt_ElectronEnUp_branch and "e1Pt_ElectronEnUp" not in self.complained:
        if not self.e1Pt_ElectronEnUp_branch and "e1Pt_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e1Pt_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Pt_ElectronEnUp")
        else:
            self.e1Pt_ElectronEnUp_branch.SetAddress(<void*>&self.e1Pt_ElectronEnUp_value)

        #print "making e1Rank"
        self.e1Rank_branch = the_tree.GetBranch("e1Rank")
        #if not self.e1Rank_branch and "e1Rank" not in self.complained:
        if not self.e1Rank_branch and "e1Rank":
            warnings.warn( "EEETree: Expected branch e1Rank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Rank")
        else:
            self.e1Rank_branch.SetAddress(<void*>&self.e1Rank_value)

        #print "making e1RelIso"
        self.e1RelIso_branch = the_tree.GetBranch("e1RelIso")
        #if not self.e1RelIso_branch and "e1RelIso" not in self.complained:
        if not self.e1RelIso_branch and "e1RelIso":
            warnings.warn( "EEETree: Expected branch e1RelIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1RelIso")
        else:
            self.e1RelIso_branch.SetAddress(<void*>&self.e1RelIso_value)

        #print "making e1RelPFIsoDB"
        self.e1RelPFIsoDB_branch = the_tree.GetBranch("e1RelPFIsoDB")
        #if not self.e1RelPFIsoDB_branch and "e1RelPFIsoDB" not in self.complained:
        if not self.e1RelPFIsoDB_branch and "e1RelPFIsoDB":
            warnings.warn( "EEETree: Expected branch e1RelPFIsoDB does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1RelPFIsoDB")
        else:
            self.e1RelPFIsoDB_branch.SetAddress(<void*>&self.e1RelPFIsoDB_value)

        #print "making e1RelPFIsoRho"
        self.e1RelPFIsoRho_branch = the_tree.GetBranch("e1RelPFIsoRho")
        #if not self.e1RelPFIsoRho_branch and "e1RelPFIsoRho" not in self.complained:
        if not self.e1RelPFIsoRho_branch and "e1RelPFIsoRho":
            warnings.warn( "EEETree: Expected branch e1RelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1RelPFIsoRho")
        else:
            self.e1RelPFIsoRho_branch.SetAddress(<void*>&self.e1RelPFIsoRho_value)

        #print "making e1Rho"
        self.e1Rho_branch = the_tree.GetBranch("e1Rho")
        #if not self.e1Rho_branch and "e1Rho" not in self.complained:
        if not self.e1Rho_branch and "e1Rho":
            warnings.warn( "EEETree: Expected branch e1Rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1Rho")
        else:
            self.e1Rho_branch.SetAddress(<void*>&self.e1Rho_value)

        #print "making e1SCEnergy"
        self.e1SCEnergy_branch = the_tree.GetBranch("e1SCEnergy")
        #if not self.e1SCEnergy_branch and "e1SCEnergy" not in self.complained:
        if not self.e1SCEnergy_branch and "e1SCEnergy":
            warnings.warn( "EEETree: Expected branch e1SCEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SCEnergy")
        else:
            self.e1SCEnergy_branch.SetAddress(<void*>&self.e1SCEnergy_value)

        #print "making e1SCEta"
        self.e1SCEta_branch = the_tree.GetBranch("e1SCEta")
        #if not self.e1SCEta_branch and "e1SCEta" not in self.complained:
        if not self.e1SCEta_branch and "e1SCEta":
            warnings.warn( "EEETree: Expected branch e1SCEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SCEta")
        else:
            self.e1SCEta_branch.SetAddress(<void*>&self.e1SCEta_value)

        #print "making e1SCEtaWidth"
        self.e1SCEtaWidth_branch = the_tree.GetBranch("e1SCEtaWidth")
        #if not self.e1SCEtaWidth_branch and "e1SCEtaWidth" not in self.complained:
        if not self.e1SCEtaWidth_branch and "e1SCEtaWidth":
            warnings.warn( "EEETree: Expected branch e1SCEtaWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SCEtaWidth")
        else:
            self.e1SCEtaWidth_branch.SetAddress(<void*>&self.e1SCEtaWidth_value)

        #print "making e1SCPhi"
        self.e1SCPhi_branch = the_tree.GetBranch("e1SCPhi")
        #if not self.e1SCPhi_branch and "e1SCPhi" not in self.complained:
        if not self.e1SCPhi_branch and "e1SCPhi":
            warnings.warn( "EEETree: Expected branch e1SCPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SCPhi")
        else:
            self.e1SCPhi_branch.SetAddress(<void*>&self.e1SCPhi_value)

        #print "making e1SCPhiWidth"
        self.e1SCPhiWidth_branch = the_tree.GetBranch("e1SCPhiWidth")
        #if not self.e1SCPhiWidth_branch and "e1SCPhiWidth" not in self.complained:
        if not self.e1SCPhiWidth_branch and "e1SCPhiWidth":
            warnings.warn( "EEETree: Expected branch e1SCPhiWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SCPhiWidth")
        else:
            self.e1SCPhiWidth_branch.SetAddress(<void*>&self.e1SCPhiWidth_value)

        #print "making e1SCPreshowerEnergy"
        self.e1SCPreshowerEnergy_branch = the_tree.GetBranch("e1SCPreshowerEnergy")
        #if not self.e1SCPreshowerEnergy_branch and "e1SCPreshowerEnergy" not in self.complained:
        if not self.e1SCPreshowerEnergy_branch and "e1SCPreshowerEnergy":
            warnings.warn( "EEETree: Expected branch e1SCPreshowerEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SCPreshowerEnergy")
        else:
            self.e1SCPreshowerEnergy_branch.SetAddress(<void*>&self.e1SCPreshowerEnergy_value)

        #print "making e1SCRawEnergy"
        self.e1SCRawEnergy_branch = the_tree.GetBranch("e1SCRawEnergy")
        #if not self.e1SCRawEnergy_branch and "e1SCRawEnergy" not in self.complained:
        if not self.e1SCRawEnergy_branch and "e1SCRawEnergy":
            warnings.warn( "EEETree: Expected branch e1SCRawEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SCRawEnergy")
        else:
            self.e1SCRawEnergy_branch.SetAddress(<void*>&self.e1SCRawEnergy_value)

        #print "making e1SIP2D"
        self.e1SIP2D_branch = the_tree.GetBranch("e1SIP2D")
        #if not self.e1SIP2D_branch and "e1SIP2D" not in self.complained:
        if not self.e1SIP2D_branch and "e1SIP2D":
            warnings.warn( "EEETree: Expected branch e1SIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SIP2D")
        else:
            self.e1SIP2D_branch.SetAddress(<void*>&self.e1SIP2D_value)

        #print "making e1SIP3D"
        self.e1SIP3D_branch = the_tree.GetBranch("e1SIP3D")
        #if not self.e1SIP3D_branch and "e1SIP3D" not in self.complained:
        if not self.e1SIP3D_branch and "e1SIP3D":
            warnings.warn( "EEETree: Expected branch e1SIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SIP3D")
        else:
            self.e1SIP3D_branch.SetAddress(<void*>&self.e1SIP3D_value)

        #print "making e1SigmaIEtaIEta"
        self.e1SigmaIEtaIEta_branch = the_tree.GetBranch("e1SigmaIEtaIEta")
        #if not self.e1SigmaIEtaIEta_branch and "e1SigmaIEtaIEta" not in self.complained:
        if not self.e1SigmaIEtaIEta_branch and "e1SigmaIEtaIEta":
            warnings.warn( "EEETree: Expected branch e1SigmaIEtaIEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1SigmaIEtaIEta")
        else:
            self.e1SigmaIEtaIEta_branch.SetAddress(<void*>&self.e1SigmaIEtaIEta_value)

        #print "making e1TrkIsoDR03"
        self.e1TrkIsoDR03_branch = the_tree.GetBranch("e1TrkIsoDR03")
        #if not self.e1TrkIsoDR03_branch and "e1TrkIsoDR03" not in self.complained:
        if not self.e1TrkIsoDR03_branch and "e1TrkIsoDR03":
            warnings.warn( "EEETree: Expected branch e1TrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1TrkIsoDR03")
        else:
            self.e1TrkIsoDR03_branch.SetAddress(<void*>&self.e1TrkIsoDR03_value)

        #print "making e1VZ"
        self.e1VZ_branch = the_tree.GetBranch("e1VZ")
        #if not self.e1VZ_branch and "e1VZ" not in self.complained:
        if not self.e1VZ_branch and "e1VZ":
            warnings.warn( "EEETree: Expected branch e1VZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1VZ")
        else:
            self.e1VZ_branch.SetAddress(<void*>&self.e1VZ_value)

        #print "making e1WWLoose"
        self.e1WWLoose_branch = the_tree.GetBranch("e1WWLoose")
        #if not self.e1WWLoose_branch and "e1WWLoose" not in self.complained:
        if not self.e1WWLoose_branch and "e1WWLoose":
            warnings.warn( "EEETree: Expected branch e1WWLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1WWLoose")
        else:
            self.e1WWLoose_branch.SetAddress(<void*>&self.e1WWLoose_value)

        #print "making e1_e2_CosThetaStar"
        self.e1_e2_CosThetaStar_branch = the_tree.GetBranch("e1_e2_CosThetaStar")
        #if not self.e1_e2_CosThetaStar_branch and "e1_e2_CosThetaStar" not in self.complained:
        if not self.e1_e2_CosThetaStar_branch and "e1_e2_CosThetaStar":
            warnings.warn( "EEETree: Expected branch e1_e2_CosThetaStar does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_CosThetaStar")
        else:
            self.e1_e2_CosThetaStar_branch.SetAddress(<void*>&self.e1_e2_CosThetaStar_value)

        #print "making e1_e2_DPhi"
        self.e1_e2_DPhi_branch = the_tree.GetBranch("e1_e2_DPhi")
        #if not self.e1_e2_DPhi_branch and "e1_e2_DPhi" not in self.complained:
        if not self.e1_e2_DPhi_branch and "e1_e2_DPhi":
            warnings.warn( "EEETree: Expected branch e1_e2_DPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_DPhi")
        else:
            self.e1_e2_DPhi_branch.SetAddress(<void*>&self.e1_e2_DPhi_value)

        #print "making e1_e2_DR"
        self.e1_e2_DR_branch = the_tree.GetBranch("e1_e2_DR")
        #if not self.e1_e2_DR_branch and "e1_e2_DR" not in self.complained:
        if not self.e1_e2_DR_branch and "e1_e2_DR":
            warnings.warn( "EEETree: Expected branch e1_e2_DR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_DR")
        else:
            self.e1_e2_DR_branch.SetAddress(<void*>&self.e1_e2_DR_value)

        #print "making e1_e2_Eta"
        self.e1_e2_Eta_branch = the_tree.GetBranch("e1_e2_Eta")
        #if not self.e1_e2_Eta_branch and "e1_e2_Eta" not in self.complained:
        if not self.e1_e2_Eta_branch and "e1_e2_Eta":
            warnings.warn( "EEETree: Expected branch e1_e2_Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_Eta")
        else:
            self.e1_e2_Eta_branch.SetAddress(<void*>&self.e1_e2_Eta_value)

        #print "making e1_e2_Mass"
        self.e1_e2_Mass_branch = the_tree.GetBranch("e1_e2_Mass")
        #if not self.e1_e2_Mass_branch and "e1_e2_Mass" not in self.complained:
        if not self.e1_e2_Mass_branch and "e1_e2_Mass":
            warnings.warn( "EEETree: Expected branch e1_e2_Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_Mass")
        else:
            self.e1_e2_Mass_branch.SetAddress(<void*>&self.e1_e2_Mass_value)

        #print "making e1_e2_Mt"
        self.e1_e2_Mt_branch = the_tree.GetBranch("e1_e2_Mt")
        #if not self.e1_e2_Mt_branch and "e1_e2_Mt" not in self.complained:
        if not self.e1_e2_Mt_branch and "e1_e2_Mt":
            warnings.warn( "EEETree: Expected branch e1_e2_Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_Mt")
        else:
            self.e1_e2_Mt_branch.SetAddress(<void*>&self.e1_e2_Mt_value)

        #print "making e1_e2_PZeta"
        self.e1_e2_PZeta_branch = the_tree.GetBranch("e1_e2_PZeta")
        #if not self.e1_e2_PZeta_branch and "e1_e2_PZeta" not in self.complained:
        if not self.e1_e2_PZeta_branch and "e1_e2_PZeta":
            warnings.warn( "EEETree: Expected branch e1_e2_PZeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_PZeta")
        else:
            self.e1_e2_PZeta_branch.SetAddress(<void*>&self.e1_e2_PZeta_value)

        #print "making e1_e2_PZetaVis"
        self.e1_e2_PZetaVis_branch = the_tree.GetBranch("e1_e2_PZetaVis")
        #if not self.e1_e2_PZetaVis_branch and "e1_e2_PZetaVis" not in self.complained:
        if not self.e1_e2_PZetaVis_branch and "e1_e2_PZetaVis":
            warnings.warn( "EEETree: Expected branch e1_e2_PZetaVis does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_PZetaVis")
        else:
            self.e1_e2_PZetaVis_branch.SetAddress(<void*>&self.e1_e2_PZetaVis_value)

        #print "making e1_e2_Phi"
        self.e1_e2_Phi_branch = the_tree.GetBranch("e1_e2_Phi")
        #if not self.e1_e2_Phi_branch and "e1_e2_Phi" not in self.complained:
        if not self.e1_e2_Phi_branch and "e1_e2_Phi":
            warnings.warn( "EEETree: Expected branch e1_e2_Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_Phi")
        else:
            self.e1_e2_Phi_branch.SetAddress(<void*>&self.e1_e2_Phi_value)

        #print "making e1_e2_Pt"
        self.e1_e2_Pt_branch = the_tree.GetBranch("e1_e2_Pt")
        #if not self.e1_e2_Pt_branch and "e1_e2_Pt" not in self.complained:
        if not self.e1_e2_Pt_branch and "e1_e2_Pt":
            warnings.warn( "EEETree: Expected branch e1_e2_Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_Pt")
        else:
            self.e1_e2_Pt_branch.SetAddress(<void*>&self.e1_e2_Pt_value)

        #print "making e1_e2_SS"
        self.e1_e2_SS_branch = the_tree.GetBranch("e1_e2_SS")
        #if not self.e1_e2_SS_branch and "e1_e2_SS" not in self.complained:
        if not self.e1_e2_SS_branch and "e1_e2_SS":
            warnings.warn( "EEETree: Expected branch e1_e2_SS does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_SS")
        else:
            self.e1_e2_SS_branch.SetAddress(<void*>&self.e1_e2_SS_value)

        #print "making e1_e2_ToMETDPhi_Ty1"
        self.e1_e2_ToMETDPhi_Ty1_branch = the_tree.GetBranch("e1_e2_ToMETDPhi_Ty1")
        #if not self.e1_e2_ToMETDPhi_Ty1_branch and "e1_e2_ToMETDPhi_Ty1" not in self.complained:
        if not self.e1_e2_ToMETDPhi_Ty1_branch and "e1_e2_ToMETDPhi_Ty1":
            warnings.warn( "EEETree: Expected branch e1_e2_ToMETDPhi_Ty1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_ToMETDPhi_Ty1")
        else:
            self.e1_e2_ToMETDPhi_Ty1_branch.SetAddress(<void*>&self.e1_e2_ToMETDPhi_Ty1_value)

        #print "making e1_e2_collinearmass"
        self.e1_e2_collinearmass_branch = the_tree.GetBranch("e1_e2_collinearmass")
        #if not self.e1_e2_collinearmass_branch and "e1_e2_collinearmass" not in self.complained:
        if not self.e1_e2_collinearmass_branch and "e1_e2_collinearmass":
            warnings.warn( "EEETree: Expected branch e1_e2_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_collinearmass")
        else:
            self.e1_e2_collinearmass_branch.SetAddress(<void*>&self.e1_e2_collinearmass_value)

        #print "making e1_e2_collinearmass_JetEnDown"
        self.e1_e2_collinearmass_JetEnDown_branch = the_tree.GetBranch("e1_e2_collinearmass_JetEnDown")
        #if not self.e1_e2_collinearmass_JetEnDown_branch and "e1_e2_collinearmass_JetEnDown" not in self.complained:
        if not self.e1_e2_collinearmass_JetEnDown_branch and "e1_e2_collinearmass_JetEnDown":
            warnings.warn( "EEETree: Expected branch e1_e2_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_collinearmass_JetEnDown")
        else:
            self.e1_e2_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.e1_e2_collinearmass_JetEnDown_value)

        #print "making e1_e2_collinearmass_JetEnUp"
        self.e1_e2_collinearmass_JetEnUp_branch = the_tree.GetBranch("e1_e2_collinearmass_JetEnUp")
        #if not self.e1_e2_collinearmass_JetEnUp_branch and "e1_e2_collinearmass_JetEnUp" not in self.complained:
        if not self.e1_e2_collinearmass_JetEnUp_branch and "e1_e2_collinearmass_JetEnUp":
            warnings.warn( "EEETree: Expected branch e1_e2_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_collinearmass_JetEnUp")
        else:
            self.e1_e2_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.e1_e2_collinearmass_JetEnUp_value)

        #print "making e1_e2_collinearmass_UnclusteredEnDown"
        self.e1_e2_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("e1_e2_collinearmass_UnclusteredEnDown")
        #if not self.e1_e2_collinearmass_UnclusteredEnDown_branch and "e1_e2_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.e1_e2_collinearmass_UnclusteredEnDown_branch and "e1_e2_collinearmass_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e1_e2_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_collinearmass_UnclusteredEnDown")
        else:
            self.e1_e2_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.e1_e2_collinearmass_UnclusteredEnDown_value)

        #print "making e1_e2_collinearmass_UnclusteredEnUp"
        self.e1_e2_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("e1_e2_collinearmass_UnclusteredEnUp")
        #if not self.e1_e2_collinearmass_UnclusteredEnUp_branch and "e1_e2_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.e1_e2_collinearmass_UnclusteredEnUp_branch and "e1_e2_collinearmass_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e1_e2_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e2_collinearmass_UnclusteredEnUp")
        else:
            self.e1_e2_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.e1_e2_collinearmass_UnclusteredEnUp_value)

        #print "making e1_e3_CosThetaStar"
        self.e1_e3_CosThetaStar_branch = the_tree.GetBranch("e1_e3_CosThetaStar")
        #if not self.e1_e3_CosThetaStar_branch and "e1_e3_CosThetaStar" not in self.complained:
        if not self.e1_e3_CosThetaStar_branch and "e1_e3_CosThetaStar":
            warnings.warn( "EEETree: Expected branch e1_e3_CosThetaStar does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_CosThetaStar")
        else:
            self.e1_e3_CosThetaStar_branch.SetAddress(<void*>&self.e1_e3_CosThetaStar_value)

        #print "making e1_e3_DPhi"
        self.e1_e3_DPhi_branch = the_tree.GetBranch("e1_e3_DPhi")
        #if not self.e1_e3_DPhi_branch and "e1_e3_DPhi" not in self.complained:
        if not self.e1_e3_DPhi_branch and "e1_e3_DPhi":
            warnings.warn( "EEETree: Expected branch e1_e3_DPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_DPhi")
        else:
            self.e1_e3_DPhi_branch.SetAddress(<void*>&self.e1_e3_DPhi_value)

        #print "making e1_e3_DR"
        self.e1_e3_DR_branch = the_tree.GetBranch("e1_e3_DR")
        #if not self.e1_e3_DR_branch and "e1_e3_DR" not in self.complained:
        if not self.e1_e3_DR_branch and "e1_e3_DR":
            warnings.warn( "EEETree: Expected branch e1_e3_DR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_DR")
        else:
            self.e1_e3_DR_branch.SetAddress(<void*>&self.e1_e3_DR_value)

        #print "making e1_e3_Eta"
        self.e1_e3_Eta_branch = the_tree.GetBranch("e1_e3_Eta")
        #if not self.e1_e3_Eta_branch and "e1_e3_Eta" not in self.complained:
        if not self.e1_e3_Eta_branch and "e1_e3_Eta":
            warnings.warn( "EEETree: Expected branch e1_e3_Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_Eta")
        else:
            self.e1_e3_Eta_branch.SetAddress(<void*>&self.e1_e3_Eta_value)

        #print "making e1_e3_Mass"
        self.e1_e3_Mass_branch = the_tree.GetBranch("e1_e3_Mass")
        #if not self.e1_e3_Mass_branch and "e1_e3_Mass" not in self.complained:
        if not self.e1_e3_Mass_branch and "e1_e3_Mass":
            warnings.warn( "EEETree: Expected branch e1_e3_Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_Mass")
        else:
            self.e1_e3_Mass_branch.SetAddress(<void*>&self.e1_e3_Mass_value)

        #print "making e1_e3_Mt"
        self.e1_e3_Mt_branch = the_tree.GetBranch("e1_e3_Mt")
        #if not self.e1_e3_Mt_branch and "e1_e3_Mt" not in self.complained:
        if not self.e1_e3_Mt_branch and "e1_e3_Mt":
            warnings.warn( "EEETree: Expected branch e1_e3_Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_Mt")
        else:
            self.e1_e3_Mt_branch.SetAddress(<void*>&self.e1_e3_Mt_value)

        #print "making e1_e3_PZeta"
        self.e1_e3_PZeta_branch = the_tree.GetBranch("e1_e3_PZeta")
        #if not self.e1_e3_PZeta_branch and "e1_e3_PZeta" not in self.complained:
        if not self.e1_e3_PZeta_branch and "e1_e3_PZeta":
            warnings.warn( "EEETree: Expected branch e1_e3_PZeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_PZeta")
        else:
            self.e1_e3_PZeta_branch.SetAddress(<void*>&self.e1_e3_PZeta_value)

        #print "making e1_e3_PZetaVis"
        self.e1_e3_PZetaVis_branch = the_tree.GetBranch("e1_e3_PZetaVis")
        #if not self.e1_e3_PZetaVis_branch and "e1_e3_PZetaVis" not in self.complained:
        if not self.e1_e3_PZetaVis_branch and "e1_e3_PZetaVis":
            warnings.warn( "EEETree: Expected branch e1_e3_PZetaVis does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_PZetaVis")
        else:
            self.e1_e3_PZetaVis_branch.SetAddress(<void*>&self.e1_e3_PZetaVis_value)

        #print "making e1_e3_Phi"
        self.e1_e3_Phi_branch = the_tree.GetBranch("e1_e3_Phi")
        #if not self.e1_e3_Phi_branch and "e1_e3_Phi" not in self.complained:
        if not self.e1_e3_Phi_branch and "e1_e3_Phi":
            warnings.warn( "EEETree: Expected branch e1_e3_Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_Phi")
        else:
            self.e1_e3_Phi_branch.SetAddress(<void*>&self.e1_e3_Phi_value)

        #print "making e1_e3_Pt"
        self.e1_e3_Pt_branch = the_tree.GetBranch("e1_e3_Pt")
        #if not self.e1_e3_Pt_branch and "e1_e3_Pt" not in self.complained:
        if not self.e1_e3_Pt_branch and "e1_e3_Pt":
            warnings.warn( "EEETree: Expected branch e1_e3_Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_Pt")
        else:
            self.e1_e3_Pt_branch.SetAddress(<void*>&self.e1_e3_Pt_value)

        #print "making e1_e3_SS"
        self.e1_e3_SS_branch = the_tree.GetBranch("e1_e3_SS")
        #if not self.e1_e3_SS_branch and "e1_e3_SS" not in self.complained:
        if not self.e1_e3_SS_branch and "e1_e3_SS":
            warnings.warn( "EEETree: Expected branch e1_e3_SS does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_SS")
        else:
            self.e1_e3_SS_branch.SetAddress(<void*>&self.e1_e3_SS_value)

        #print "making e1_e3_ToMETDPhi_Ty1"
        self.e1_e3_ToMETDPhi_Ty1_branch = the_tree.GetBranch("e1_e3_ToMETDPhi_Ty1")
        #if not self.e1_e3_ToMETDPhi_Ty1_branch and "e1_e3_ToMETDPhi_Ty1" not in self.complained:
        if not self.e1_e3_ToMETDPhi_Ty1_branch and "e1_e3_ToMETDPhi_Ty1":
            warnings.warn( "EEETree: Expected branch e1_e3_ToMETDPhi_Ty1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_ToMETDPhi_Ty1")
        else:
            self.e1_e3_ToMETDPhi_Ty1_branch.SetAddress(<void*>&self.e1_e3_ToMETDPhi_Ty1_value)

        #print "making e1_e3_collinearmass"
        self.e1_e3_collinearmass_branch = the_tree.GetBranch("e1_e3_collinearmass")
        #if not self.e1_e3_collinearmass_branch and "e1_e3_collinearmass" not in self.complained:
        if not self.e1_e3_collinearmass_branch and "e1_e3_collinearmass":
            warnings.warn( "EEETree: Expected branch e1_e3_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_collinearmass")
        else:
            self.e1_e3_collinearmass_branch.SetAddress(<void*>&self.e1_e3_collinearmass_value)

        #print "making e1_e3_collinearmass_JetEnDown"
        self.e1_e3_collinearmass_JetEnDown_branch = the_tree.GetBranch("e1_e3_collinearmass_JetEnDown")
        #if not self.e1_e3_collinearmass_JetEnDown_branch and "e1_e3_collinearmass_JetEnDown" not in self.complained:
        if not self.e1_e3_collinearmass_JetEnDown_branch and "e1_e3_collinearmass_JetEnDown":
            warnings.warn( "EEETree: Expected branch e1_e3_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_collinearmass_JetEnDown")
        else:
            self.e1_e3_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.e1_e3_collinearmass_JetEnDown_value)

        #print "making e1_e3_collinearmass_JetEnUp"
        self.e1_e3_collinearmass_JetEnUp_branch = the_tree.GetBranch("e1_e3_collinearmass_JetEnUp")
        #if not self.e1_e3_collinearmass_JetEnUp_branch and "e1_e3_collinearmass_JetEnUp" not in self.complained:
        if not self.e1_e3_collinearmass_JetEnUp_branch and "e1_e3_collinearmass_JetEnUp":
            warnings.warn( "EEETree: Expected branch e1_e3_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_collinearmass_JetEnUp")
        else:
            self.e1_e3_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.e1_e3_collinearmass_JetEnUp_value)

        #print "making e1_e3_collinearmass_UnclusteredEnDown"
        self.e1_e3_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("e1_e3_collinearmass_UnclusteredEnDown")
        #if not self.e1_e3_collinearmass_UnclusteredEnDown_branch and "e1_e3_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.e1_e3_collinearmass_UnclusteredEnDown_branch and "e1_e3_collinearmass_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e1_e3_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_collinearmass_UnclusteredEnDown")
        else:
            self.e1_e3_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.e1_e3_collinearmass_UnclusteredEnDown_value)

        #print "making e1_e3_collinearmass_UnclusteredEnUp"
        self.e1_e3_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("e1_e3_collinearmass_UnclusteredEnUp")
        #if not self.e1_e3_collinearmass_UnclusteredEnUp_branch and "e1_e3_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.e1_e3_collinearmass_UnclusteredEnUp_branch and "e1_e3_collinearmass_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e1_e3_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1_e3_collinearmass_UnclusteredEnUp")
        else:
            self.e1_e3_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.e1_e3_collinearmass_UnclusteredEnUp_value)

        #print "making e1deltaEtaSuperClusterTrackAtVtx"
        self.e1deltaEtaSuperClusterTrackAtVtx_branch = the_tree.GetBranch("e1deltaEtaSuperClusterTrackAtVtx")
        #if not self.e1deltaEtaSuperClusterTrackAtVtx_branch and "e1deltaEtaSuperClusterTrackAtVtx" not in self.complained:
        if not self.e1deltaEtaSuperClusterTrackAtVtx_branch and "e1deltaEtaSuperClusterTrackAtVtx":
            warnings.warn( "EEETree: Expected branch e1deltaEtaSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1deltaEtaSuperClusterTrackAtVtx")
        else:
            self.e1deltaEtaSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.e1deltaEtaSuperClusterTrackAtVtx_value)

        #print "making e1deltaPhiSuperClusterTrackAtVtx"
        self.e1deltaPhiSuperClusterTrackAtVtx_branch = the_tree.GetBranch("e1deltaPhiSuperClusterTrackAtVtx")
        #if not self.e1deltaPhiSuperClusterTrackAtVtx_branch and "e1deltaPhiSuperClusterTrackAtVtx" not in self.complained:
        if not self.e1deltaPhiSuperClusterTrackAtVtx_branch and "e1deltaPhiSuperClusterTrackAtVtx":
            warnings.warn( "EEETree: Expected branch e1deltaPhiSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1deltaPhiSuperClusterTrackAtVtx")
        else:
            self.e1deltaPhiSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.e1deltaPhiSuperClusterTrackAtVtx_value)

        #print "making e1eSuperClusterOverP"
        self.e1eSuperClusterOverP_branch = the_tree.GetBranch("e1eSuperClusterOverP")
        #if not self.e1eSuperClusterOverP_branch and "e1eSuperClusterOverP" not in self.complained:
        if not self.e1eSuperClusterOverP_branch and "e1eSuperClusterOverP":
            warnings.warn( "EEETree: Expected branch e1eSuperClusterOverP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1eSuperClusterOverP")
        else:
            self.e1eSuperClusterOverP_branch.SetAddress(<void*>&self.e1eSuperClusterOverP_value)

        #print "making e1ecalEnergy"
        self.e1ecalEnergy_branch = the_tree.GetBranch("e1ecalEnergy")
        #if not self.e1ecalEnergy_branch and "e1ecalEnergy" not in self.complained:
        if not self.e1ecalEnergy_branch and "e1ecalEnergy":
            warnings.warn( "EEETree: Expected branch e1ecalEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1ecalEnergy")
        else:
            self.e1ecalEnergy_branch.SetAddress(<void*>&self.e1ecalEnergy_value)

        #print "making e1fBrem"
        self.e1fBrem_branch = the_tree.GetBranch("e1fBrem")
        #if not self.e1fBrem_branch and "e1fBrem" not in self.complained:
        if not self.e1fBrem_branch and "e1fBrem":
            warnings.warn( "EEETree: Expected branch e1fBrem does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1fBrem")
        else:
            self.e1fBrem_branch.SetAddress(<void*>&self.e1fBrem_value)

        #print "making e1trackMomentumAtVtxP"
        self.e1trackMomentumAtVtxP_branch = the_tree.GetBranch("e1trackMomentumAtVtxP")
        #if not self.e1trackMomentumAtVtxP_branch and "e1trackMomentumAtVtxP" not in self.complained:
        if not self.e1trackMomentumAtVtxP_branch and "e1trackMomentumAtVtxP":
            warnings.warn( "EEETree: Expected branch e1trackMomentumAtVtxP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e1trackMomentumAtVtxP")
        else:
            self.e1trackMomentumAtVtxP_branch.SetAddress(<void*>&self.e1trackMomentumAtVtxP_value)

        #print "making e2AbsEta"
        self.e2AbsEta_branch = the_tree.GetBranch("e2AbsEta")
        #if not self.e2AbsEta_branch and "e2AbsEta" not in self.complained:
        if not self.e2AbsEta_branch and "e2AbsEta":
            warnings.warn( "EEETree: Expected branch e2AbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2AbsEta")
        else:
            self.e2AbsEta_branch.SetAddress(<void*>&self.e2AbsEta_value)

        #print "making e2CBIDLoose"
        self.e2CBIDLoose_branch = the_tree.GetBranch("e2CBIDLoose")
        #if not self.e2CBIDLoose_branch and "e2CBIDLoose" not in self.complained:
        if not self.e2CBIDLoose_branch and "e2CBIDLoose":
            warnings.warn( "EEETree: Expected branch e2CBIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDLoose")
        else:
            self.e2CBIDLoose_branch.SetAddress(<void*>&self.e2CBIDLoose_value)

        #print "making e2CBIDLooseNoIso"
        self.e2CBIDLooseNoIso_branch = the_tree.GetBranch("e2CBIDLooseNoIso")
        #if not self.e2CBIDLooseNoIso_branch and "e2CBIDLooseNoIso" not in self.complained:
        if not self.e2CBIDLooseNoIso_branch and "e2CBIDLooseNoIso":
            warnings.warn( "EEETree: Expected branch e2CBIDLooseNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDLooseNoIso")
        else:
            self.e2CBIDLooseNoIso_branch.SetAddress(<void*>&self.e2CBIDLooseNoIso_value)

        #print "making e2CBIDMedium"
        self.e2CBIDMedium_branch = the_tree.GetBranch("e2CBIDMedium")
        #if not self.e2CBIDMedium_branch and "e2CBIDMedium" not in self.complained:
        if not self.e2CBIDMedium_branch and "e2CBIDMedium":
            warnings.warn( "EEETree: Expected branch e2CBIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDMedium")
        else:
            self.e2CBIDMedium_branch.SetAddress(<void*>&self.e2CBIDMedium_value)

        #print "making e2CBIDMediumNoIso"
        self.e2CBIDMediumNoIso_branch = the_tree.GetBranch("e2CBIDMediumNoIso")
        #if not self.e2CBIDMediumNoIso_branch and "e2CBIDMediumNoIso" not in self.complained:
        if not self.e2CBIDMediumNoIso_branch and "e2CBIDMediumNoIso":
            warnings.warn( "EEETree: Expected branch e2CBIDMediumNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDMediumNoIso")
        else:
            self.e2CBIDMediumNoIso_branch.SetAddress(<void*>&self.e2CBIDMediumNoIso_value)

        #print "making e2CBIDTight"
        self.e2CBIDTight_branch = the_tree.GetBranch("e2CBIDTight")
        #if not self.e2CBIDTight_branch and "e2CBIDTight" not in self.complained:
        if not self.e2CBIDTight_branch and "e2CBIDTight":
            warnings.warn( "EEETree: Expected branch e2CBIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDTight")
        else:
            self.e2CBIDTight_branch.SetAddress(<void*>&self.e2CBIDTight_value)

        #print "making e2CBIDTightNoIso"
        self.e2CBIDTightNoIso_branch = the_tree.GetBranch("e2CBIDTightNoIso")
        #if not self.e2CBIDTightNoIso_branch and "e2CBIDTightNoIso" not in self.complained:
        if not self.e2CBIDTightNoIso_branch and "e2CBIDTightNoIso":
            warnings.warn( "EEETree: Expected branch e2CBIDTightNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDTightNoIso")
        else:
            self.e2CBIDTightNoIso_branch.SetAddress(<void*>&self.e2CBIDTightNoIso_value)

        #print "making e2CBIDVeto"
        self.e2CBIDVeto_branch = the_tree.GetBranch("e2CBIDVeto")
        #if not self.e2CBIDVeto_branch and "e2CBIDVeto" not in self.complained:
        if not self.e2CBIDVeto_branch and "e2CBIDVeto":
            warnings.warn( "EEETree: Expected branch e2CBIDVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDVeto")
        else:
            self.e2CBIDVeto_branch.SetAddress(<void*>&self.e2CBIDVeto_value)

        #print "making e2CBIDVetoNoIso"
        self.e2CBIDVetoNoIso_branch = the_tree.GetBranch("e2CBIDVetoNoIso")
        #if not self.e2CBIDVetoNoIso_branch and "e2CBIDVetoNoIso" not in self.complained:
        if not self.e2CBIDVetoNoIso_branch and "e2CBIDVetoNoIso":
            warnings.warn( "EEETree: Expected branch e2CBIDVetoNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2CBIDVetoNoIso")
        else:
            self.e2CBIDVetoNoIso_branch.SetAddress(<void*>&self.e2CBIDVetoNoIso_value)

        #print "making e2Charge"
        self.e2Charge_branch = the_tree.GetBranch("e2Charge")
        #if not self.e2Charge_branch and "e2Charge" not in self.complained:
        if not self.e2Charge_branch and "e2Charge":
            warnings.warn( "EEETree: Expected branch e2Charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Charge")
        else:
            self.e2Charge_branch.SetAddress(<void*>&self.e2Charge_value)

        #print "making e2ChargeIdLoose"
        self.e2ChargeIdLoose_branch = the_tree.GetBranch("e2ChargeIdLoose")
        #if not self.e2ChargeIdLoose_branch and "e2ChargeIdLoose" not in self.complained:
        if not self.e2ChargeIdLoose_branch and "e2ChargeIdLoose":
            warnings.warn( "EEETree: Expected branch e2ChargeIdLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2ChargeIdLoose")
        else:
            self.e2ChargeIdLoose_branch.SetAddress(<void*>&self.e2ChargeIdLoose_value)

        #print "making e2ChargeIdMed"
        self.e2ChargeIdMed_branch = the_tree.GetBranch("e2ChargeIdMed")
        #if not self.e2ChargeIdMed_branch and "e2ChargeIdMed" not in self.complained:
        if not self.e2ChargeIdMed_branch and "e2ChargeIdMed":
            warnings.warn( "EEETree: Expected branch e2ChargeIdMed does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2ChargeIdMed")
        else:
            self.e2ChargeIdMed_branch.SetAddress(<void*>&self.e2ChargeIdMed_value)

        #print "making e2ChargeIdTight"
        self.e2ChargeIdTight_branch = the_tree.GetBranch("e2ChargeIdTight")
        #if not self.e2ChargeIdTight_branch and "e2ChargeIdTight" not in self.complained:
        if not self.e2ChargeIdTight_branch and "e2ChargeIdTight":
            warnings.warn( "EEETree: Expected branch e2ChargeIdTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2ChargeIdTight")
        else:
            self.e2ChargeIdTight_branch.SetAddress(<void*>&self.e2ChargeIdTight_value)

        #print "making e2ComesFromHiggs"
        self.e2ComesFromHiggs_branch = the_tree.GetBranch("e2ComesFromHiggs")
        #if not self.e2ComesFromHiggs_branch and "e2ComesFromHiggs" not in self.complained:
        if not self.e2ComesFromHiggs_branch and "e2ComesFromHiggs":
            warnings.warn( "EEETree: Expected branch e2ComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2ComesFromHiggs")
        else:
            self.e2ComesFromHiggs_branch.SetAddress(<void*>&self.e2ComesFromHiggs_value)

        #print "making e2DPhiToPfMet_ElectronEnDown"
        self.e2DPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("e2DPhiToPfMet_ElectronEnDown")
        #if not self.e2DPhiToPfMet_ElectronEnDown_branch and "e2DPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.e2DPhiToPfMet_ElectronEnDown_branch and "e2DPhiToPfMet_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_ElectronEnDown")
        else:
            self.e2DPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.e2DPhiToPfMet_ElectronEnDown_value)

        #print "making e2DPhiToPfMet_ElectronEnUp"
        self.e2DPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("e2DPhiToPfMet_ElectronEnUp")
        #if not self.e2DPhiToPfMet_ElectronEnUp_branch and "e2DPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.e2DPhiToPfMet_ElectronEnUp_branch and "e2DPhiToPfMet_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_ElectronEnUp")
        else:
            self.e2DPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.e2DPhiToPfMet_ElectronEnUp_value)

        #print "making e2DPhiToPfMet_JetEnDown"
        self.e2DPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("e2DPhiToPfMet_JetEnDown")
        #if not self.e2DPhiToPfMet_JetEnDown_branch and "e2DPhiToPfMet_JetEnDown" not in self.complained:
        if not self.e2DPhiToPfMet_JetEnDown_branch and "e2DPhiToPfMet_JetEnDown":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_JetEnDown")
        else:
            self.e2DPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.e2DPhiToPfMet_JetEnDown_value)

        #print "making e2DPhiToPfMet_JetEnUp"
        self.e2DPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("e2DPhiToPfMet_JetEnUp")
        #if not self.e2DPhiToPfMet_JetEnUp_branch and "e2DPhiToPfMet_JetEnUp" not in self.complained:
        if not self.e2DPhiToPfMet_JetEnUp_branch and "e2DPhiToPfMet_JetEnUp":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_JetEnUp")
        else:
            self.e2DPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.e2DPhiToPfMet_JetEnUp_value)

        #print "making e2DPhiToPfMet_JetResDown"
        self.e2DPhiToPfMet_JetResDown_branch = the_tree.GetBranch("e2DPhiToPfMet_JetResDown")
        #if not self.e2DPhiToPfMet_JetResDown_branch and "e2DPhiToPfMet_JetResDown" not in self.complained:
        if not self.e2DPhiToPfMet_JetResDown_branch and "e2DPhiToPfMet_JetResDown":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_JetResDown")
        else:
            self.e2DPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.e2DPhiToPfMet_JetResDown_value)

        #print "making e2DPhiToPfMet_JetResUp"
        self.e2DPhiToPfMet_JetResUp_branch = the_tree.GetBranch("e2DPhiToPfMet_JetResUp")
        #if not self.e2DPhiToPfMet_JetResUp_branch and "e2DPhiToPfMet_JetResUp" not in self.complained:
        if not self.e2DPhiToPfMet_JetResUp_branch and "e2DPhiToPfMet_JetResUp":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_JetResUp")
        else:
            self.e2DPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.e2DPhiToPfMet_JetResUp_value)

        #print "making e2DPhiToPfMet_MuonEnDown"
        self.e2DPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("e2DPhiToPfMet_MuonEnDown")
        #if not self.e2DPhiToPfMet_MuonEnDown_branch and "e2DPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.e2DPhiToPfMet_MuonEnDown_branch and "e2DPhiToPfMet_MuonEnDown":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_MuonEnDown")
        else:
            self.e2DPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.e2DPhiToPfMet_MuonEnDown_value)

        #print "making e2DPhiToPfMet_MuonEnUp"
        self.e2DPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("e2DPhiToPfMet_MuonEnUp")
        #if not self.e2DPhiToPfMet_MuonEnUp_branch and "e2DPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.e2DPhiToPfMet_MuonEnUp_branch and "e2DPhiToPfMet_MuonEnUp":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_MuonEnUp")
        else:
            self.e2DPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.e2DPhiToPfMet_MuonEnUp_value)

        #print "making e2DPhiToPfMet_PhotonEnDown"
        self.e2DPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("e2DPhiToPfMet_PhotonEnDown")
        #if not self.e2DPhiToPfMet_PhotonEnDown_branch and "e2DPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.e2DPhiToPfMet_PhotonEnDown_branch and "e2DPhiToPfMet_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_PhotonEnDown")
        else:
            self.e2DPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.e2DPhiToPfMet_PhotonEnDown_value)

        #print "making e2DPhiToPfMet_PhotonEnUp"
        self.e2DPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("e2DPhiToPfMet_PhotonEnUp")
        #if not self.e2DPhiToPfMet_PhotonEnUp_branch and "e2DPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.e2DPhiToPfMet_PhotonEnUp_branch and "e2DPhiToPfMet_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_PhotonEnUp")
        else:
            self.e2DPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.e2DPhiToPfMet_PhotonEnUp_value)

        #print "making e2DPhiToPfMet_TauEnDown"
        self.e2DPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("e2DPhiToPfMet_TauEnDown")
        #if not self.e2DPhiToPfMet_TauEnDown_branch and "e2DPhiToPfMet_TauEnDown" not in self.complained:
        if not self.e2DPhiToPfMet_TauEnDown_branch and "e2DPhiToPfMet_TauEnDown":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_TauEnDown")
        else:
            self.e2DPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.e2DPhiToPfMet_TauEnDown_value)

        #print "making e2DPhiToPfMet_TauEnUp"
        self.e2DPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("e2DPhiToPfMet_TauEnUp")
        #if not self.e2DPhiToPfMet_TauEnUp_branch and "e2DPhiToPfMet_TauEnUp" not in self.complained:
        if not self.e2DPhiToPfMet_TauEnUp_branch and "e2DPhiToPfMet_TauEnUp":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_TauEnUp")
        else:
            self.e2DPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.e2DPhiToPfMet_TauEnUp_value)

        #print "making e2DPhiToPfMet_UnclusteredEnDown"
        self.e2DPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("e2DPhiToPfMet_UnclusteredEnDown")
        #if not self.e2DPhiToPfMet_UnclusteredEnDown_branch and "e2DPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.e2DPhiToPfMet_UnclusteredEnDown_branch and "e2DPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_UnclusteredEnDown")
        else:
            self.e2DPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.e2DPhiToPfMet_UnclusteredEnDown_value)

        #print "making e2DPhiToPfMet_UnclusteredEnUp"
        self.e2DPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("e2DPhiToPfMet_UnclusteredEnUp")
        #if not self.e2DPhiToPfMet_UnclusteredEnUp_branch and "e2DPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.e2DPhiToPfMet_UnclusteredEnUp_branch and "e2DPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_UnclusteredEnUp")
        else:
            self.e2DPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.e2DPhiToPfMet_UnclusteredEnUp_value)

        #print "making e2DPhiToPfMet_type1"
        self.e2DPhiToPfMet_type1_branch = the_tree.GetBranch("e2DPhiToPfMet_type1")
        #if not self.e2DPhiToPfMet_type1_branch and "e2DPhiToPfMet_type1" not in self.complained:
        if not self.e2DPhiToPfMet_type1_branch and "e2DPhiToPfMet_type1":
            warnings.warn( "EEETree: Expected branch e2DPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2DPhiToPfMet_type1")
        else:
            self.e2DPhiToPfMet_type1_branch.SetAddress(<void*>&self.e2DPhiToPfMet_type1_value)

        #print "making e2E1x5"
        self.e2E1x5_branch = the_tree.GetBranch("e2E1x5")
        #if not self.e2E1x5_branch and "e2E1x5" not in self.complained:
        if not self.e2E1x5_branch and "e2E1x5":
            warnings.warn( "EEETree: Expected branch e2E1x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2E1x5")
        else:
            self.e2E1x5_branch.SetAddress(<void*>&self.e2E1x5_value)

        #print "making e2E2x5Max"
        self.e2E2x5Max_branch = the_tree.GetBranch("e2E2x5Max")
        #if not self.e2E2x5Max_branch and "e2E2x5Max" not in self.complained:
        if not self.e2E2x5Max_branch and "e2E2x5Max":
            warnings.warn( "EEETree: Expected branch e2E2x5Max does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2E2x5Max")
        else:
            self.e2E2x5Max_branch.SetAddress(<void*>&self.e2E2x5Max_value)

        #print "making e2E5x5"
        self.e2E5x5_branch = the_tree.GetBranch("e2E5x5")
        #if not self.e2E5x5_branch and "e2E5x5" not in self.complained:
        if not self.e2E5x5_branch and "e2E5x5":
            warnings.warn( "EEETree: Expected branch e2E5x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2E5x5")
        else:
            self.e2E5x5_branch.SetAddress(<void*>&self.e2E5x5_value)

        #print "making e2EcalIsoDR03"
        self.e2EcalIsoDR03_branch = the_tree.GetBranch("e2EcalIsoDR03")
        #if not self.e2EcalIsoDR03_branch and "e2EcalIsoDR03" not in self.complained:
        if not self.e2EcalIsoDR03_branch and "e2EcalIsoDR03":
            warnings.warn( "EEETree: Expected branch e2EcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2EcalIsoDR03")
        else:
            self.e2EcalIsoDR03_branch.SetAddress(<void*>&self.e2EcalIsoDR03_value)

        #print "making e2EffectiveArea2012Data"
        self.e2EffectiveArea2012Data_branch = the_tree.GetBranch("e2EffectiveArea2012Data")
        #if not self.e2EffectiveArea2012Data_branch and "e2EffectiveArea2012Data" not in self.complained:
        if not self.e2EffectiveArea2012Data_branch and "e2EffectiveArea2012Data":
            warnings.warn( "EEETree: Expected branch e2EffectiveArea2012Data does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2EffectiveArea2012Data")
        else:
            self.e2EffectiveArea2012Data_branch.SetAddress(<void*>&self.e2EffectiveArea2012Data_value)

        #print "making e2EffectiveAreaSpring15"
        self.e2EffectiveAreaSpring15_branch = the_tree.GetBranch("e2EffectiveAreaSpring15")
        #if not self.e2EffectiveAreaSpring15_branch and "e2EffectiveAreaSpring15" not in self.complained:
        if not self.e2EffectiveAreaSpring15_branch and "e2EffectiveAreaSpring15":
            warnings.warn( "EEETree: Expected branch e2EffectiveAreaSpring15 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2EffectiveAreaSpring15")
        else:
            self.e2EffectiveAreaSpring15_branch.SetAddress(<void*>&self.e2EffectiveAreaSpring15_value)

        #print "making e2EnergyError"
        self.e2EnergyError_branch = the_tree.GetBranch("e2EnergyError")
        #if not self.e2EnergyError_branch and "e2EnergyError" not in self.complained:
        if not self.e2EnergyError_branch and "e2EnergyError":
            warnings.warn( "EEETree: Expected branch e2EnergyError does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2EnergyError")
        else:
            self.e2EnergyError_branch.SetAddress(<void*>&self.e2EnergyError_value)

        #print "making e2Eta"
        self.e2Eta_branch = the_tree.GetBranch("e2Eta")
        #if not self.e2Eta_branch and "e2Eta" not in self.complained:
        if not self.e2Eta_branch and "e2Eta":
            warnings.warn( "EEETree: Expected branch e2Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Eta")
        else:
            self.e2Eta_branch.SetAddress(<void*>&self.e2Eta_value)

        #print "making e2Eta_ElectronEnDown"
        self.e2Eta_ElectronEnDown_branch = the_tree.GetBranch("e2Eta_ElectronEnDown")
        #if not self.e2Eta_ElectronEnDown_branch and "e2Eta_ElectronEnDown" not in self.complained:
        if not self.e2Eta_ElectronEnDown_branch and "e2Eta_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e2Eta_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Eta_ElectronEnDown")
        else:
            self.e2Eta_ElectronEnDown_branch.SetAddress(<void*>&self.e2Eta_ElectronEnDown_value)

        #print "making e2Eta_ElectronEnUp"
        self.e2Eta_ElectronEnUp_branch = the_tree.GetBranch("e2Eta_ElectronEnUp")
        #if not self.e2Eta_ElectronEnUp_branch and "e2Eta_ElectronEnUp" not in self.complained:
        if not self.e2Eta_ElectronEnUp_branch and "e2Eta_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e2Eta_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Eta_ElectronEnUp")
        else:
            self.e2Eta_ElectronEnUp_branch.SetAddress(<void*>&self.e2Eta_ElectronEnUp_value)

        #print "making e2GenCharge"
        self.e2GenCharge_branch = the_tree.GetBranch("e2GenCharge")
        #if not self.e2GenCharge_branch and "e2GenCharge" not in self.complained:
        if not self.e2GenCharge_branch and "e2GenCharge":
            warnings.warn( "EEETree: Expected branch e2GenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenCharge")
        else:
            self.e2GenCharge_branch.SetAddress(<void*>&self.e2GenCharge_value)

        #print "making e2GenEnergy"
        self.e2GenEnergy_branch = the_tree.GetBranch("e2GenEnergy")
        #if not self.e2GenEnergy_branch and "e2GenEnergy" not in self.complained:
        if not self.e2GenEnergy_branch and "e2GenEnergy":
            warnings.warn( "EEETree: Expected branch e2GenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenEnergy")
        else:
            self.e2GenEnergy_branch.SetAddress(<void*>&self.e2GenEnergy_value)

        #print "making e2GenEta"
        self.e2GenEta_branch = the_tree.GetBranch("e2GenEta")
        #if not self.e2GenEta_branch and "e2GenEta" not in self.complained:
        if not self.e2GenEta_branch and "e2GenEta":
            warnings.warn( "EEETree: Expected branch e2GenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenEta")
        else:
            self.e2GenEta_branch.SetAddress(<void*>&self.e2GenEta_value)

        #print "making e2GenMotherPdgId"
        self.e2GenMotherPdgId_branch = the_tree.GetBranch("e2GenMotherPdgId")
        #if not self.e2GenMotherPdgId_branch and "e2GenMotherPdgId" not in self.complained:
        if not self.e2GenMotherPdgId_branch and "e2GenMotherPdgId":
            warnings.warn( "EEETree: Expected branch e2GenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenMotherPdgId")
        else:
            self.e2GenMotherPdgId_branch.SetAddress(<void*>&self.e2GenMotherPdgId_value)

        #print "making e2GenParticle"
        self.e2GenParticle_branch = the_tree.GetBranch("e2GenParticle")
        #if not self.e2GenParticle_branch and "e2GenParticle" not in self.complained:
        if not self.e2GenParticle_branch and "e2GenParticle":
            warnings.warn( "EEETree: Expected branch e2GenParticle does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenParticle")
        else:
            self.e2GenParticle_branch.SetAddress(<void*>&self.e2GenParticle_value)

        #print "making e2GenPdgId"
        self.e2GenPdgId_branch = the_tree.GetBranch("e2GenPdgId")
        #if not self.e2GenPdgId_branch and "e2GenPdgId" not in self.complained:
        if not self.e2GenPdgId_branch and "e2GenPdgId":
            warnings.warn( "EEETree: Expected branch e2GenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenPdgId")
        else:
            self.e2GenPdgId_branch.SetAddress(<void*>&self.e2GenPdgId_value)

        #print "making e2GenPhi"
        self.e2GenPhi_branch = the_tree.GetBranch("e2GenPhi")
        #if not self.e2GenPhi_branch and "e2GenPhi" not in self.complained:
        if not self.e2GenPhi_branch and "e2GenPhi":
            warnings.warn( "EEETree: Expected branch e2GenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenPhi")
        else:
            self.e2GenPhi_branch.SetAddress(<void*>&self.e2GenPhi_value)

        #print "making e2GenPrompt"
        self.e2GenPrompt_branch = the_tree.GetBranch("e2GenPrompt")
        #if not self.e2GenPrompt_branch and "e2GenPrompt" not in self.complained:
        if not self.e2GenPrompt_branch and "e2GenPrompt":
            warnings.warn( "EEETree: Expected branch e2GenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenPrompt")
        else:
            self.e2GenPrompt_branch.SetAddress(<void*>&self.e2GenPrompt_value)

        #print "making e2GenPromptTauDecay"
        self.e2GenPromptTauDecay_branch = the_tree.GetBranch("e2GenPromptTauDecay")
        #if not self.e2GenPromptTauDecay_branch and "e2GenPromptTauDecay" not in self.complained:
        if not self.e2GenPromptTauDecay_branch and "e2GenPromptTauDecay":
            warnings.warn( "EEETree: Expected branch e2GenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenPromptTauDecay")
        else:
            self.e2GenPromptTauDecay_branch.SetAddress(<void*>&self.e2GenPromptTauDecay_value)

        #print "making e2GenPt"
        self.e2GenPt_branch = the_tree.GetBranch("e2GenPt")
        #if not self.e2GenPt_branch and "e2GenPt" not in self.complained:
        if not self.e2GenPt_branch and "e2GenPt":
            warnings.warn( "EEETree: Expected branch e2GenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenPt")
        else:
            self.e2GenPt_branch.SetAddress(<void*>&self.e2GenPt_value)

        #print "making e2GenTauDecay"
        self.e2GenTauDecay_branch = the_tree.GetBranch("e2GenTauDecay")
        #if not self.e2GenTauDecay_branch and "e2GenTauDecay" not in self.complained:
        if not self.e2GenTauDecay_branch and "e2GenTauDecay":
            warnings.warn( "EEETree: Expected branch e2GenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenTauDecay")
        else:
            self.e2GenTauDecay_branch.SetAddress(<void*>&self.e2GenTauDecay_value)

        #print "making e2GenVZ"
        self.e2GenVZ_branch = the_tree.GetBranch("e2GenVZ")
        #if not self.e2GenVZ_branch and "e2GenVZ" not in self.complained:
        if not self.e2GenVZ_branch and "e2GenVZ":
            warnings.warn( "EEETree: Expected branch e2GenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenVZ")
        else:
            self.e2GenVZ_branch.SetAddress(<void*>&self.e2GenVZ_value)

        #print "making e2GenVtxPVMatch"
        self.e2GenVtxPVMatch_branch = the_tree.GetBranch("e2GenVtxPVMatch")
        #if not self.e2GenVtxPVMatch_branch and "e2GenVtxPVMatch" not in self.complained:
        if not self.e2GenVtxPVMatch_branch and "e2GenVtxPVMatch":
            warnings.warn( "EEETree: Expected branch e2GenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2GenVtxPVMatch")
        else:
            self.e2GenVtxPVMatch_branch.SetAddress(<void*>&self.e2GenVtxPVMatch_value)

        #print "making e2HadronicDepth1OverEm"
        self.e2HadronicDepth1OverEm_branch = the_tree.GetBranch("e2HadronicDepth1OverEm")
        #if not self.e2HadronicDepth1OverEm_branch and "e2HadronicDepth1OverEm" not in self.complained:
        if not self.e2HadronicDepth1OverEm_branch and "e2HadronicDepth1OverEm":
            warnings.warn( "EEETree: Expected branch e2HadronicDepth1OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2HadronicDepth1OverEm")
        else:
            self.e2HadronicDepth1OverEm_branch.SetAddress(<void*>&self.e2HadronicDepth1OverEm_value)

        #print "making e2HadronicDepth2OverEm"
        self.e2HadronicDepth2OverEm_branch = the_tree.GetBranch("e2HadronicDepth2OverEm")
        #if not self.e2HadronicDepth2OverEm_branch and "e2HadronicDepth2OverEm" not in self.complained:
        if not self.e2HadronicDepth2OverEm_branch and "e2HadronicDepth2OverEm":
            warnings.warn( "EEETree: Expected branch e2HadronicDepth2OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2HadronicDepth2OverEm")
        else:
            self.e2HadronicDepth2OverEm_branch.SetAddress(<void*>&self.e2HadronicDepth2OverEm_value)

        #print "making e2HadronicOverEM"
        self.e2HadronicOverEM_branch = the_tree.GetBranch("e2HadronicOverEM")
        #if not self.e2HadronicOverEM_branch and "e2HadronicOverEM" not in self.complained:
        if not self.e2HadronicOverEM_branch and "e2HadronicOverEM":
            warnings.warn( "EEETree: Expected branch e2HadronicOverEM does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2HadronicOverEM")
        else:
            self.e2HadronicOverEM_branch.SetAddress(<void*>&self.e2HadronicOverEM_value)

        #print "making e2HcalIsoDR03"
        self.e2HcalIsoDR03_branch = the_tree.GetBranch("e2HcalIsoDR03")
        #if not self.e2HcalIsoDR03_branch and "e2HcalIsoDR03" not in self.complained:
        if not self.e2HcalIsoDR03_branch and "e2HcalIsoDR03":
            warnings.warn( "EEETree: Expected branch e2HcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2HcalIsoDR03")
        else:
            self.e2HcalIsoDR03_branch.SetAddress(<void*>&self.e2HcalIsoDR03_value)

        #print "making e2IP3D"
        self.e2IP3D_branch = the_tree.GetBranch("e2IP3D")
        #if not self.e2IP3D_branch and "e2IP3D" not in self.complained:
        if not self.e2IP3D_branch and "e2IP3D":
            warnings.warn( "EEETree: Expected branch e2IP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2IP3D")
        else:
            self.e2IP3D_branch.SetAddress(<void*>&self.e2IP3D_value)

        #print "making e2IP3DErr"
        self.e2IP3DErr_branch = the_tree.GetBranch("e2IP3DErr")
        #if not self.e2IP3DErr_branch and "e2IP3DErr" not in self.complained:
        if not self.e2IP3DErr_branch and "e2IP3DErr":
            warnings.warn( "EEETree: Expected branch e2IP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2IP3DErr")
        else:
            self.e2IP3DErr_branch.SetAddress(<void*>&self.e2IP3DErr_value)

        #print "making e2JetArea"
        self.e2JetArea_branch = the_tree.GetBranch("e2JetArea")
        #if not self.e2JetArea_branch and "e2JetArea" not in self.complained:
        if not self.e2JetArea_branch and "e2JetArea":
            warnings.warn( "EEETree: Expected branch e2JetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetArea")
        else:
            self.e2JetArea_branch.SetAddress(<void*>&self.e2JetArea_value)

        #print "making e2JetBtag"
        self.e2JetBtag_branch = the_tree.GetBranch("e2JetBtag")
        #if not self.e2JetBtag_branch and "e2JetBtag" not in self.complained:
        if not self.e2JetBtag_branch and "e2JetBtag":
            warnings.warn( "EEETree: Expected branch e2JetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetBtag")
        else:
            self.e2JetBtag_branch.SetAddress(<void*>&self.e2JetBtag_value)

        #print "making e2JetEtaEtaMoment"
        self.e2JetEtaEtaMoment_branch = the_tree.GetBranch("e2JetEtaEtaMoment")
        #if not self.e2JetEtaEtaMoment_branch and "e2JetEtaEtaMoment" not in self.complained:
        if not self.e2JetEtaEtaMoment_branch and "e2JetEtaEtaMoment":
            warnings.warn( "EEETree: Expected branch e2JetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetEtaEtaMoment")
        else:
            self.e2JetEtaEtaMoment_branch.SetAddress(<void*>&self.e2JetEtaEtaMoment_value)

        #print "making e2JetEtaPhiMoment"
        self.e2JetEtaPhiMoment_branch = the_tree.GetBranch("e2JetEtaPhiMoment")
        #if not self.e2JetEtaPhiMoment_branch and "e2JetEtaPhiMoment" not in self.complained:
        if not self.e2JetEtaPhiMoment_branch and "e2JetEtaPhiMoment":
            warnings.warn( "EEETree: Expected branch e2JetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetEtaPhiMoment")
        else:
            self.e2JetEtaPhiMoment_branch.SetAddress(<void*>&self.e2JetEtaPhiMoment_value)

        #print "making e2JetEtaPhiSpread"
        self.e2JetEtaPhiSpread_branch = the_tree.GetBranch("e2JetEtaPhiSpread")
        #if not self.e2JetEtaPhiSpread_branch and "e2JetEtaPhiSpread" not in self.complained:
        if not self.e2JetEtaPhiSpread_branch and "e2JetEtaPhiSpread":
            warnings.warn( "EEETree: Expected branch e2JetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetEtaPhiSpread")
        else:
            self.e2JetEtaPhiSpread_branch.SetAddress(<void*>&self.e2JetEtaPhiSpread_value)

        #print "making e2JetPFCISVBtag"
        self.e2JetPFCISVBtag_branch = the_tree.GetBranch("e2JetPFCISVBtag")
        #if not self.e2JetPFCISVBtag_branch and "e2JetPFCISVBtag" not in self.complained:
        if not self.e2JetPFCISVBtag_branch and "e2JetPFCISVBtag":
            warnings.warn( "EEETree: Expected branch e2JetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetPFCISVBtag")
        else:
            self.e2JetPFCISVBtag_branch.SetAddress(<void*>&self.e2JetPFCISVBtag_value)

        #print "making e2JetPartonFlavour"
        self.e2JetPartonFlavour_branch = the_tree.GetBranch("e2JetPartonFlavour")
        #if not self.e2JetPartonFlavour_branch and "e2JetPartonFlavour" not in self.complained:
        if not self.e2JetPartonFlavour_branch and "e2JetPartonFlavour":
            warnings.warn( "EEETree: Expected branch e2JetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetPartonFlavour")
        else:
            self.e2JetPartonFlavour_branch.SetAddress(<void*>&self.e2JetPartonFlavour_value)

        #print "making e2JetPhiPhiMoment"
        self.e2JetPhiPhiMoment_branch = the_tree.GetBranch("e2JetPhiPhiMoment")
        #if not self.e2JetPhiPhiMoment_branch and "e2JetPhiPhiMoment" not in self.complained:
        if not self.e2JetPhiPhiMoment_branch and "e2JetPhiPhiMoment":
            warnings.warn( "EEETree: Expected branch e2JetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetPhiPhiMoment")
        else:
            self.e2JetPhiPhiMoment_branch.SetAddress(<void*>&self.e2JetPhiPhiMoment_value)

        #print "making e2JetPt"
        self.e2JetPt_branch = the_tree.GetBranch("e2JetPt")
        #if not self.e2JetPt_branch and "e2JetPt" not in self.complained:
        if not self.e2JetPt_branch and "e2JetPt":
            warnings.warn( "EEETree: Expected branch e2JetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2JetPt")
        else:
            self.e2JetPt_branch.SetAddress(<void*>&self.e2JetPt_value)

        #print "making e2LowestMll"
        self.e2LowestMll_branch = the_tree.GetBranch("e2LowestMll")
        #if not self.e2LowestMll_branch and "e2LowestMll" not in self.complained:
        if not self.e2LowestMll_branch and "e2LowestMll":
            warnings.warn( "EEETree: Expected branch e2LowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2LowestMll")
        else:
            self.e2LowestMll_branch.SetAddress(<void*>&self.e2LowestMll_value)

        #print "making e2MVANonTrigCategory"
        self.e2MVANonTrigCategory_branch = the_tree.GetBranch("e2MVANonTrigCategory")
        #if not self.e2MVANonTrigCategory_branch and "e2MVANonTrigCategory" not in self.complained:
        if not self.e2MVANonTrigCategory_branch and "e2MVANonTrigCategory":
            warnings.warn( "EEETree: Expected branch e2MVANonTrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVANonTrigCategory")
        else:
            self.e2MVANonTrigCategory_branch.SetAddress(<void*>&self.e2MVANonTrigCategory_value)

        #print "making e2MVANonTrigID"
        self.e2MVANonTrigID_branch = the_tree.GetBranch("e2MVANonTrigID")
        #if not self.e2MVANonTrigID_branch and "e2MVANonTrigID" not in self.complained:
        if not self.e2MVANonTrigID_branch and "e2MVANonTrigID":
            warnings.warn( "EEETree: Expected branch e2MVANonTrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVANonTrigID")
        else:
            self.e2MVANonTrigID_branch.SetAddress(<void*>&self.e2MVANonTrigID_value)

        #print "making e2MVANonTrigWP80"
        self.e2MVANonTrigWP80_branch = the_tree.GetBranch("e2MVANonTrigWP80")
        #if not self.e2MVANonTrigWP80_branch and "e2MVANonTrigWP80" not in self.complained:
        if not self.e2MVANonTrigWP80_branch and "e2MVANonTrigWP80":
            warnings.warn( "EEETree: Expected branch e2MVANonTrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVANonTrigWP80")
        else:
            self.e2MVANonTrigWP80_branch.SetAddress(<void*>&self.e2MVANonTrigWP80_value)

        #print "making e2MVANonTrigWP90"
        self.e2MVANonTrigWP90_branch = the_tree.GetBranch("e2MVANonTrigWP90")
        #if not self.e2MVANonTrigWP90_branch and "e2MVANonTrigWP90" not in self.complained:
        if not self.e2MVANonTrigWP90_branch and "e2MVANonTrigWP90":
            warnings.warn( "EEETree: Expected branch e2MVANonTrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVANonTrigWP90")
        else:
            self.e2MVANonTrigWP90_branch.SetAddress(<void*>&self.e2MVANonTrigWP90_value)

        #print "making e2MVATrigCategory"
        self.e2MVATrigCategory_branch = the_tree.GetBranch("e2MVATrigCategory")
        #if not self.e2MVATrigCategory_branch and "e2MVATrigCategory" not in self.complained:
        if not self.e2MVATrigCategory_branch and "e2MVATrigCategory":
            warnings.warn( "EEETree: Expected branch e2MVATrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVATrigCategory")
        else:
            self.e2MVATrigCategory_branch.SetAddress(<void*>&self.e2MVATrigCategory_value)

        #print "making e2MVATrigID"
        self.e2MVATrigID_branch = the_tree.GetBranch("e2MVATrigID")
        #if not self.e2MVATrigID_branch and "e2MVATrigID" not in self.complained:
        if not self.e2MVATrigID_branch and "e2MVATrigID":
            warnings.warn( "EEETree: Expected branch e2MVATrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVATrigID")
        else:
            self.e2MVATrigID_branch.SetAddress(<void*>&self.e2MVATrigID_value)

        #print "making e2MVATrigWP80"
        self.e2MVATrigWP80_branch = the_tree.GetBranch("e2MVATrigWP80")
        #if not self.e2MVATrigWP80_branch and "e2MVATrigWP80" not in self.complained:
        if not self.e2MVATrigWP80_branch and "e2MVATrigWP80":
            warnings.warn( "EEETree: Expected branch e2MVATrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVATrigWP80")
        else:
            self.e2MVATrigWP80_branch.SetAddress(<void*>&self.e2MVATrigWP80_value)

        #print "making e2MVATrigWP90"
        self.e2MVATrigWP90_branch = the_tree.GetBranch("e2MVATrigWP90")
        #if not self.e2MVATrigWP90_branch and "e2MVATrigWP90" not in self.complained:
        if not self.e2MVATrigWP90_branch and "e2MVATrigWP90":
            warnings.warn( "EEETree: Expected branch e2MVATrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MVATrigWP90")
        else:
            self.e2MVATrigWP90_branch.SetAddress(<void*>&self.e2MVATrigWP90_value)

        #print "making e2Mass"
        self.e2Mass_branch = the_tree.GetBranch("e2Mass")
        #if not self.e2Mass_branch and "e2Mass" not in self.complained:
        if not self.e2Mass_branch and "e2Mass":
            warnings.warn( "EEETree: Expected branch e2Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Mass")
        else:
            self.e2Mass_branch.SetAddress(<void*>&self.e2Mass_value)

        #print "making e2MatchesDoubleE"
        self.e2MatchesDoubleE_branch = the_tree.GetBranch("e2MatchesDoubleE")
        #if not self.e2MatchesDoubleE_branch and "e2MatchesDoubleE" not in self.complained:
        if not self.e2MatchesDoubleE_branch and "e2MatchesDoubleE":
            warnings.warn( "EEETree: Expected branch e2MatchesDoubleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesDoubleE")
        else:
            self.e2MatchesDoubleE_branch.SetAddress(<void*>&self.e2MatchesDoubleE_value)

        #print "making e2MatchesDoubleESingleMu"
        self.e2MatchesDoubleESingleMu_branch = the_tree.GetBranch("e2MatchesDoubleESingleMu")
        #if not self.e2MatchesDoubleESingleMu_branch and "e2MatchesDoubleESingleMu" not in self.complained:
        if not self.e2MatchesDoubleESingleMu_branch and "e2MatchesDoubleESingleMu":
            warnings.warn( "EEETree: Expected branch e2MatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesDoubleESingleMu")
        else:
            self.e2MatchesDoubleESingleMu_branch.SetAddress(<void*>&self.e2MatchesDoubleESingleMu_value)

        #print "making e2MatchesDoubleMuSingleE"
        self.e2MatchesDoubleMuSingleE_branch = the_tree.GetBranch("e2MatchesDoubleMuSingleE")
        #if not self.e2MatchesDoubleMuSingleE_branch and "e2MatchesDoubleMuSingleE" not in self.complained:
        if not self.e2MatchesDoubleMuSingleE_branch and "e2MatchesDoubleMuSingleE":
            warnings.warn( "EEETree: Expected branch e2MatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesDoubleMuSingleE")
        else:
            self.e2MatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.e2MatchesDoubleMuSingleE_value)

        #print "making e2MatchesSingleE"
        self.e2MatchesSingleE_branch = the_tree.GetBranch("e2MatchesSingleE")
        #if not self.e2MatchesSingleE_branch and "e2MatchesSingleE" not in self.complained:
        if not self.e2MatchesSingleE_branch and "e2MatchesSingleE":
            warnings.warn( "EEETree: Expected branch e2MatchesSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesSingleE")
        else:
            self.e2MatchesSingleE_branch.SetAddress(<void*>&self.e2MatchesSingleE_value)

        #print "making e2MatchesSingleESingleMu"
        self.e2MatchesSingleESingleMu_branch = the_tree.GetBranch("e2MatchesSingleESingleMu")
        #if not self.e2MatchesSingleESingleMu_branch and "e2MatchesSingleESingleMu" not in self.complained:
        if not self.e2MatchesSingleESingleMu_branch and "e2MatchesSingleESingleMu":
            warnings.warn( "EEETree: Expected branch e2MatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesSingleESingleMu")
        else:
            self.e2MatchesSingleESingleMu_branch.SetAddress(<void*>&self.e2MatchesSingleESingleMu_value)

        #print "making e2MatchesSingleE_leg1"
        self.e2MatchesSingleE_leg1_branch = the_tree.GetBranch("e2MatchesSingleE_leg1")
        #if not self.e2MatchesSingleE_leg1_branch and "e2MatchesSingleE_leg1" not in self.complained:
        if not self.e2MatchesSingleE_leg1_branch and "e2MatchesSingleE_leg1":
            warnings.warn( "EEETree: Expected branch e2MatchesSingleE_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesSingleE_leg1")
        else:
            self.e2MatchesSingleE_leg1_branch.SetAddress(<void*>&self.e2MatchesSingleE_leg1_value)

        #print "making e2MatchesSingleE_leg2"
        self.e2MatchesSingleE_leg2_branch = the_tree.GetBranch("e2MatchesSingleE_leg2")
        #if not self.e2MatchesSingleE_leg2_branch and "e2MatchesSingleE_leg2" not in self.complained:
        if not self.e2MatchesSingleE_leg2_branch and "e2MatchesSingleE_leg2":
            warnings.warn( "EEETree: Expected branch e2MatchesSingleE_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesSingleE_leg2")
        else:
            self.e2MatchesSingleE_leg2_branch.SetAddress(<void*>&self.e2MatchesSingleE_leg2_value)

        #print "making e2MatchesSingleMuSingleE"
        self.e2MatchesSingleMuSingleE_branch = the_tree.GetBranch("e2MatchesSingleMuSingleE")
        #if not self.e2MatchesSingleMuSingleE_branch and "e2MatchesSingleMuSingleE" not in self.complained:
        if not self.e2MatchesSingleMuSingleE_branch and "e2MatchesSingleMuSingleE":
            warnings.warn( "EEETree: Expected branch e2MatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesSingleMuSingleE")
        else:
            self.e2MatchesSingleMuSingleE_branch.SetAddress(<void*>&self.e2MatchesSingleMuSingleE_value)

        #print "making e2MatchesTripleE"
        self.e2MatchesTripleE_branch = the_tree.GetBranch("e2MatchesTripleE")
        #if not self.e2MatchesTripleE_branch and "e2MatchesTripleE" not in self.complained:
        if not self.e2MatchesTripleE_branch and "e2MatchesTripleE":
            warnings.warn( "EEETree: Expected branch e2MatchesTripleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MatchesTripleE")
        else:
            self.e2MatchesTripleE_branch.SetAddress(<void*>&self.e2MatchesTripleE_value)

        #print "making e2MissingHits"
        self.e2MissingHits_branch = the_tree.GetBranch("e2MissingHits")
        #if not self.e2MissingHits_branch and "e2MissingHits" not in self.complained:
        if not self.e2MissingHits_branch and "e2MissingHits":
            warnings.warn( "EEETree: Expected branch e2MissingHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MissingHits")
        else:
            self.e2MissingHits_branch.SetAddress(<void*>&self.e2MissingHits_value)

        #print "making e2MtToPfMet_ElectronEnDown"
        self.e2MtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("e2MtToPfMet_ElectronEnDown")
        #if not self.e2MtToPfMet_ElectronEnDown_branch and "e2MtToPfMet_ElectronEnDown" not in self.complained:
        if not self.e2MtToPfMet_ElectronEnDown_branch and "e2MtToPfMet_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_ElectronEnDown")
        else:
            self.e2MtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.e2MtToPfMet_ElectronEnDown_value)

        #print "making e2MtToPfMet_ElectronEnUp"
        self.e2MtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("e2MtToPfMet_ElectronEnUp")
        #if not self.e2MtToPfMet_ElectronEnUp_branch and "e2MtToPfMet_ElectronEnUp" not in self.complained:
        if not self.e2MtToPfMet_ElectronEnUp_branch and "e2MtToPfMet_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_ElectronEnUp")
        else:
            self.e2MtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.e2MtToPfMet_ElectronEnUp_value)

        #print "making e2MtToPfMet_JetEnDown"
        self.e2MtToPfMet_JetEnDown_branch = the_tree.GetBranch("e2MtToPfMet_JetEnDown")
        #if not self.e2MtToPfMet_JetEnDown_branch and "e2MtToPfMet_JetEnDown" not in self.complained:
        if not self.e2MtToPfMet_JetEnDown_branch and "e2MtToPfMet_JetEnDown":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_JetEnDown")
        else:
            self.e2MtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.e2MtToPfMet_JetEnDown_value)

        #print "making e2MtToPfMet_JetEnUp"
        self.e2MtToPfMet_JetEnUp_branch = the_tree.GetBranch("e2MtToPfMet_JetEnUp")
        #if not self.e2MtToPfMet_JetEnUp_branch and "e2MtToPfMet_JetEnUp" not in self.complained:
        if not self.e2MtToPfMet_JetEnUp_branch and "e2MtToPfMet_JetEnUp":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_JetEnUp")
        else:
            self.e2MtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.e2MtToPfMet_JetEnUp_value)

        #print "making e2MtToPfMet_JetResDown"
        self.e2MtToPfMet_JetResDown_branch = the_tree.GetBranch("e2MtToPfMet_JetResDown")
        #if not self.e2MtToPfMet_JetResDown_branch and "e2MtToPfMet_JetResDown" not in self.complained:
        if not self.e2MtToPfMet_JetResDown_branch and "e2MtToPfMet_JetResDown":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_JetResDown")
        else:
            self.e2MtToPfMet_JetResDown_branch.SetAddress(<void*>&self.e2MtToPfMet_JetResDown_value)

        #print "making e2MtToPfMet_JetResUp"
        self.e2MtToPfMet_JetResUp_branch = the_tree.GetBranch("e2MtToPfMet_JetResUp")
        #if not self.e2MtToPfMet_JetResUp_branch and "e2MtToPfMet_JetResUp" not in self.complained:
        if not self.e2MtToPfMet_JetResUp_branch and "e2MtToPfMet_JetResUp":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_JetResUp")
        else:
            self.e2MtToPfMet_JetResUp_branch.SetAddress(<void*>&self.e2MtToPfMet_JetResUp_value)

        #print "making e2MtToPfMet_MuonEnDown"
        self.e2MtToPfMet_MuonEnDown_branch = the_tree.GetBranch("e2MtToPfMet_MuonEnDown")
        #if not self.e2MtToPfMet_MuonEnDown_branch and "e2MtToPfMet_MuonEnDown" not in self.complained:
        if not self.e2MtToPfMet_MuonEnDown_branch and "e2MtToPfMet_MuonEnDown":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_MuonEnDown")
        else:
            self.e2MtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.e2MtToPfMet_MuonEnDown_value)

        #print "making e2MtToPfMet_MuonEnUp"
        self.e2MtToPfMet_MuonEnUp_branch = the_tree.GetBranch("e2MtToPfMet_MuonEnUp")
        #if not self.e2MtToPfMet_MuonEnUp_branch and "e2MtToPfMet_MuonEnUp" not in self.complained:
        if not self.e2MtToPfMet_MuonEnUp_branch and "e2MtToPfMet_MuonEnUp":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_MuonEnUp")
        else:
            self.e2MtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.e2MtToPfMet_MuonEnUp_value)

        #print "making e2MtToPfMet_PhotonEnDown"
        self.e2MtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("e2MtToPfMet_PhotonEnDown")
        #if not self.e2MtToPfMet_PhotonEnDown_branch and "e2MtToPfMet_PhotonEnDown" not in self.complained:
        if not self.e2MtToPfMet_PhotonEnDown_branch and "e2MtToPfMet_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_PhotonEnDown")
        else:
            self.e2MtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.e2MtToPfMet_PhotonEnDown_value)

        #print "making e2MtToPfMet_PhotonEnUp"
        self.e2MtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("e2MtToPfMet_PhotonEnUp")
        #if not self.e2MtToPfMet_PhotonEnUp_branch and "e2MtToPfMet_PhotonEnUp" not in self.complained:
        if not self.e2MtToPfMet_PhotonEnUp_branch and "e2MtToPfMet_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_PhotonEnUp")
        else:
            self.e2MtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.e2MtToPfMet_PhotonEnUp_value)

        #print "making e2MtToPfMet_Raw"
        self.e2MtToPfMet_Raw_branch = the_tree.GetBranch("e2MtToPfMet_Raw")
        #if not self.e2MtToPfMet_Raw_branch and "e2MtToPfMet_Raw" not in self.complained:
        if not self.e2MtToPfMet_Raw_branch and "e2MtToPfMet_Raw":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_Raw")
        else:
            self.e2MtToPfMet_Raw_branch.SetAddress(<void*>&self.e2MtToPfMet_Raw_value)

        #print "making e2MtToPfMet_TauEnDown"
        self.e2MtToPfMet_TauEnDown_branch = the_tree.GetBranch("e2MtToPfMet_TauEnDown")
        #if not self.e2MtToPfMet_TauEnDown_branch and "e2MtToPfMet_TauEnDown" not in self.complained:
        if not self.e2MtToPfMet_TauEnDown_branch and "e2MtToPfMet_TauEnDown":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_TauEnDown")
        else:
            self.e2MtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.e2MtToPfMet_TauEnDown_value)

        #print "making e2MtToPfMet_TauEnUp"
        self.e2MtToPfMet_TauEnUp_branch = the_tree.GetBranch("e2MtToPfMet_TauEnUp")
        #if not self.e2MtToPfMet_TauEnUp_branch and "e2MtToPfMet_TauEnUp" not in self.complained:
        if not self.e2MtToPfMet_TauEnUp_branch and "e2MtToPfMet_TauEnUp":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_TauEnUp")
        else:
            self.e2MtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.e2MtToPfMet_TauEnUp_value)

        #print "making e2MtToPfMet_UnclusteredEnDown"
        self.e2MtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("e2MtToPfMet_UnclusteredEnDown")
        #if not self.e2MtToPfMet_UnclusteredEnDown_branch and "e2MtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.e2MtToPfMet_UnclusteredEnDown_branch and "e2MtToPfMet_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_UnclusteredEnDown")
        else:
            self.e2MtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.e2MtToPfMet_UnclusteredEnDown_value)

        #print "making e2MtToPfMet_UnclusteredEnUp"
        self.e2MtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("e2MtToPfMet_UnclusteredEnUp")
        #if not self.e2MtToPfMet_UnclusteredEnUp_branch and "e2MtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.e2MtToPfMet_UnclusteredEnUp_branch and "e2MtToPfMet_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_UnclusteredEnUp")
        else:
            self.e2MtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.e2MtToPfMet_UnclusteredEnUp_value)

        #print "making e2MtToPfMet_type1"
        self.e2MtToPfMet_type1_branch = the_tree.GetBranch("e2MtToPfMet_type1")
        #if not self.e2MtToPfMet_type1_branch and "e2MtToPfMet_type1" not in self.complained:
        if not self.e2MtToPfMet_type1_branch and "e2MtToPfMet_type1":
            warnings.warn( "EEETree: Expected branch e2MtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2MtToPfMet_type1")
        else:
            self.e2MtToPfMet_type1_branch.SetAddress(<void*>&self.e2MtToPfMet_type1_value)

        #print "making e2NearMuonVeto"
        self.e2NearMuonVeto_branch = the_tree.GetBranch("e2NearMuonVeto")
        #if not self.e2NearMuonVeto_branch and "e2NearMuonVeto" not in self.complained:
        if not self.e2NearMuonVeto_branch and "e2NearMuonVeto":
            warnings.warn( "EEETree: Expected branch e2NearMuonVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2NearMuonVeto")
        else:
            self.e2NearMuonVeto_branch.SetAddress(<void*>&self.e2NearMuonVeto_value)

        #print "making e2NearestMuonDR"
        self.e2NearestMuonDR_branch = the_tree.GetBranch("e2NearestMuonDR")
        #if not self.e2NearestMuonDR_branch and "e2NearestMuonDR" not in self.complained:
        if not self.e2NearestMuonDR_branch and "e2NearestMuonDR":
            warnings.warn( "EEETree: Expected branch e2NearestMuonDR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2NearestMuonDR")
        else:
            self.e2NearestMuonDR_branch.SetAddress(<void*>&self.e2NearestMuonDR_value)

        #print "making e2NearestZMass"
        self.e2NearestZMass_branch = the_tree.GetBranch("e2NearestZMass")
        #if not self.e2NearestZMass_branch and "e2NearestZMass" not in self.complained:
        if not self.e2NearestZMass_branch and "e2NearestZMass":
            warnings.warn( "EEETree: Expected branch e2NearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2NearestZMass")
        else:
            self.e2NearestZMass_branch.SetAddress(<void*>&self.e2NearestZMass_value)

        #print "making e2PFChargedIso"
        self.e2PFChargedIso_branch = the_tree.GetBranch("e2PFChargedIso")
        #if not self.e2PFChargedIso_branch and "e2PFChargedIso" not in self.complained:
        if not self.e2PFChargedIso_branch and "e2PFChargedIso":
            warnings.warn( "EEETree: Expected branch e2PFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2PFChargedIso")
        else:
            self.e2PFChargedIso_branch.SetAddress(<void*>&self.e2PFChargedIso_value)

        #print "making e2PFNeutralIso"
        self.e2PFNeutralIso_branch = the_tree.GetBranch("e2PFNeutralIso")
        #if not self.e2PFNeutralIso_branch and "e2PFNeutralIso" not in self.complained:
        if not self.e2PFNeutralIso_branch and "e2PFNeutralIso":
            warnings.warn( "EEETree: Expected branch e2PFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2PFNeutralIso")
        else:
            self.e2PFNeutralIso_branch.SetAddress(<void*>&self.e2PFNeutralIso_value)

        #print "making e2PFPUChargedIso"
        self.e2PFPUChargedIso_branch = the_tree.GetBranch("e2PFPUChargedIso")
        #if not self.e2PFPUChargedIso_branch and "e2PFPUChargedIso" not in self.complained:
        if not self.e2PFPUChargedIso_branch and "e2PFPUChargedIso":
            warnings.warn( "EEETree: Expected branch e2PFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2PFPUChargedIso")
        else:
            self.e2PFPUChargedIso_branch.SetAddress(<void*>&self.e2PFPUChargedIso_value)

        #print "making e2PFPhotonIso"
        self.e2PFPhotonIso_branch = the_tree.GetBranch("e2PFPhotonIso")
        #if not self.e2PFPhotonIso_branch and "e2PFPhotonIso" not in self.complained:
        if not self.e2PFPhotonIso_branch and "e2PFPhotonIso":
            warnings.warn( "EEETree: Expected branch e2PFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2PFPhotonIso")
        else:
            self.e2PFPhotonIso_branch.SetAddress(<void*>&self.e2PFPhotonIso_value)

        #print "making e2PVDXY"
        self.e2PVDXY_branch = the_tree.GetBranch("e2PVDXY")
        #if not self.e2PVDXY_branch and "e2PVDXY" not in self.complained:
        if not self.e2PVDXY_branch and "e2PVDXY":
            warnings.warn( "EEETree: Expected branch e2PVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2PVDXY")
        else:
            self.e2PVDXY_branch.SetAddress(<void*>&self.e2PVDXY_value)

        #print "making e2PVDZ"
        self.e2PVDZ_branch = the_tree.GetBranch("e2PVDZ")
        #if not self.e2PVDZ_branch and "e2PVDZ" not in self.complained:
        if not self.e2PVDZ_branch and "e2PVDZ":
            warnings.warn( "EEETree: Expected branch e2PVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2PVDZ")
        else:
            self.e2PVDZ_branch.SetAddress(<void*>&self.e2PVDZ_value)

        #print "making e2PassesConversionVeto"
        self.e2PassesConversionVeto_branch = the_tree.GetBranch("e2PassesConversionVeto")
        #if not self.e2PassesConversionVeto_branch and "e2PassesConversionVeto" not in self.complained:
        if not self.e2PassesConversionVeto_branch and "e2PassesConversionVeto":
            warnings.warn( "EEETree: Expected branch e2PassesConversionVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2PassesConversionVeto")
        else:
            self.e2PassesConversionVeto_branch.SetAddress(<void*>&self.e2PassesConversionVeto_value)

        #print "making e2Phi"
        self.e2Phi_branch = the_tree.GetBranch("e2Phi")
        #if not self.e2Phi_branch and "e2Phi" not in self.complained:
        if not self.e2Phi_branch and "e2Phi":
            warnings.warn( "EEETree: Expected branch e2Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Phi")
        else:
            self.e2Phi_branch.SetAddress(<void*>&self.e2Phi_value)

        #print "making e2Phi_ElectronEnDown"
        self.e2Phi_ElectronEnDown_branch = the_tree.GetBranch("e2Phi_ElectronEnDown")
        #if not self.e2Phi_ElectronEnDown_branch and "e2Phi_ElectronEnDown" not in self.complained:
        if not self.e2Phi_ElectronEnDown_branch and "e2Phi_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e2Phi_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Phi_ElectronEnDown")
        else:
            self.e2Phi_ElectronEnDown_branch.SetAddress(<void*>&self.e2Phi_ElectronEnDown_value)

        #print "making e2Phi_ElectronEnUp"
        self.e2Phi_ElectronEnUp_branch = the_tree.GetBranch("e2Phi_ElectronEnUp")
        #if not self.e2Phi_ElectronEnUp_branch and "e2Phi_ElectronEnUp" not in self.complained:
        if not self.e2Phi_ElectronEnUp_branch and "e2Phi_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e2Phi_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Phi_ElectronEnUp")
        else:
            self.e2Phi_ElectronEnUp_branch.SetAddress(<void*>&self.e2Phi_ElectronEnUp_value)

        #print "making e2Pt"
        self.e2Pt_branch = the_tree.GetBranch("e2Pt")
        #if not self.e2Pt_branch and "e2Pt" not in self.complained:
        if not self.e2Pt_branch and "e2Pt":
            warnings.warn( "EEETree: Expected branch e2Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Pt")
        else:
            self.e2Pt_branch.SetAddress(<void*>&self.e2Pt_value)

        #print "making e2Pt_ElectronEnDown"
        self.e2Pt_ElectronEnDown_branch = the_tree.GetBranch("e2Pt_ElectronEnDown")
        #if not self.e2Pt_ElectronEnDown_branch and "e2Pt_ElectronEnDown" not in self.complained:
        if not self.e2Pt_ElectronEnDown_branch and "e2Pt_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e2Pt_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Pt_ElectronEnDown")
        else:
            self.e2Pt_ElectronEnDown_branch.SetAddress(<void*>&self.e2Pt_ElectronEnDown_value)

        #print "making e2Pt_ElectronEnUp"
        self.e2Pt_ElectronEnUp_branch = the_tree.GetBranch("e2Pt_ElectronEnUp")
        #if not self.e2Pt_ElectronEnUp_branch and "e2Pt_ElectronEnUp" not in self.complained:
        if not self.e2Pt_ElectronEnUp_branch and "e2Pt_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e2Pt_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Pt_ElectronEnUp")
        else:
            self.e2Pt_ElectronEnUp_branch.SetAddress(<void*>&self.e2Pt_ElectronEnUp_value)

        #print "making e2Rank"
        self.e2Rank_branch = the_tree.GetBranch("e2Rank")
        #if not self.e2Rank_branch and "e2Rank" not in self.complained:
        if not self.e2Rank_branch and "e2Rank":
            warnings.warn( "EEETree: Expected branch e2Rank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Rank")
        else:
            self.e2Rank_branch.SetAddress(<void*>&self.e2Rank_value)

        #print "making e2RelIso"
        self.e2RelIso_branch = the_tree.GetBranch("e2RelIso")
        #if not self.e2RelIso_branch and "e2RelIso" not in self.complained:
        if not self.e2RelIso_branch and "e2RelIso":
            warnings.warn( "EEETree: Expected branch e2RelIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2RelIso")
        else:
            self.e2RelIso_branch.SetAddress(<void*>&self.e2RelIso_value)

        #print "making e2RelPFIsoDB"
        self.e2RelPFIsoDB_branch = the_tree.GetBranch("e2RelPFIsoDB")
        #if not self.e2RelPFIsoDB_branch and "e2RelPFIsoDB" not in self.complained:
        if not self.e2RelPFIsoDB_branch and "e2RelPFIsoDB":
            warnings.warn( "EEETree: Expected branch e2RelPFIsoDB does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2RelPFIsoDB")
        else:
            self.e2RelPFIsoDB_branch.SetAddress(<void*>&self.e2RelPFIsoDB_value)

        #print "making e2RelPFIsoRho"
        self.e2RelPFIsoRho_branch = the_tree.GetBranch("e2RelPFIsoRho")
        #if not self.e2RelPFIsoRho_branch and "e2RelPFIsoRho" not in self.complained:
        if not self.e2RelPFIsoRho_branch and "e2RelPFIsoRho":
            warnings.warn( "EEETree: Expected branch e2RelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2RelPFIsoRho")
        else:
            self.e2RelPFIsoRho_branch.SetAddress(<void*>&self.e2RelPFIsoRho_value)

        #print "making e2Rho"
        self.e2Rho_branch = the_tree.GetBranch("e2Rho")
        #if not self.e2Rho_branch and "e2Rho" not in self.complained:
        if not self.e2Rho_branch and "e2Rho":
            warnings.warn( "EEETree: Expected branch e2Rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2Rho")
        else:
            self.e2Rho_branch.SetAddress(<void*>&self.e2Rho_value)

        #print "making e2SCEnergy"
        self.e2SCEnergy_branch = the_tree.GetBranch("e2SCEnergy")
        #if not self.e2SCEnergy_branch and "e2SCEnergy" not in self.complained:
        if not self.e2SCEnergy_branch and "e2SCEnergy":
            warnings.warn( "EEETree: Expected branch e2SCEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SCEnergy")
        else:
            self.e2SCEnergy_branch.SetAddress(<void*>&self.e2SCEnergy_value)

        #print "making e2SCEta"
        self.e2SCEta_branch = the_tree.GetBranch("e2SCEta")
        #if not self.e2SCEta_branch and "e2SCEta" not in self.complained:
        if not self.e2SCEta_branch and "e2SCEta":
            warnings.warn( "EEETree: Expected branch e2SCEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SCEta")
        else:
            self.e2SCEta_branch.SetAddress(<void*>&self.e2SCEta_value)

        #print "making e2SCEtaWidth"
        self.e2SCEtaWidth_branch = the_tree.GetBranch("e2SCEtaWidth")
        #if not self.e2SCEtaWidth_branch and "e2SCEtaWidth" not in self.complained:
        if not self.e2SCEtaWidth_branch and "e2SCEtaWidth":
            warnings.warn( "EEETree: Expected branch e2SCEtaWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SCEtaWidth")
        else:
            self.e2SCEtaWidth_branch.SetAddress(<void*>&self.e2SCEtaWidth_value)

        #print "making e2SCPhi"
        self.e2SCPhi_branch = the_tree.GetBranch("e2SCPhi")
        #if not self.e2SCPhi_branch and "e2SCPhi" not in self.complained:
        if not self.e2SCPhi_branch and "e2SCPhi":
            warnings.warn( "EEETree: Expected branch e2SCPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SCPhi")
        else:
            self.e2SCPhi_branch.SetAddress(<void*>&self.e2SCPhi_value)

        #print "making e2SCPhiWidth"
        self.e2SCPhiWidth_branch = the_tree.GetBranch("e2SCPhiWidth")
        #if not self.e2SCPhiWidth_branch and "e2SCPhiWidth" not in self.complained:
        if not self.e2SCPhiWidth_branch and "e2SCPhiWidth":
            warnings.warn( "EEETree: Expected branch e2SCPhiWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SCPhiWidth")
        else:
            self.e2SCPhiWidth_branch.SetAddress(<void*>&self.e2SCPhiWidth_value)

        #print "making e2SCPreshowerEnergy"
        self.e2SCPreshowerEnergy_branch = the_tree.GetBranch("e2SCPreshowerEnergy")
        #if not self.e2SCPreshowerEnergy_branch and "e2SCPreshowerEnergy" not in self.complained:
        if not self.e2SCPreshowerEnergy_branch and "e2SCPreshowerEnergy":
            warnings.warn( "EEETree: Expected branch e2SCPreshowerEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SCPreshowerEnergy")
        else:
            self.e2SCPreshowerEnergy_branch.SetAddress(<void*>&self.e2SCPreshowerEnergy_value)

        #print "making e2SCRawEnergy"
        self.e2SCRawEnergy_branch = the_tree.GetBranch("e2SCRawEnergy")
        #if not self.e2SCRawEnergy_branch and "e2SCRawEnergy" not in self.complained:
        if not self.e2SCRawEnergy_branch and "e2SCRawEnergy":
            warnings.warn( "EEETree: Expected branch e2SCRawEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SCRawEnergy")
        else:
            self.e2SCRawEnergy_branch.SetAddress(<void*>&self.e2SCRawEnergy_value)

        #print "making e2SIP2D"
        self.e2SIP2D_branch = the_tree.GetBranch("e2SIP2D")
        #if not self.e2SIP2D_branch and "e2SIP2D" not in self.complained:
        if not self.e2SIP2D_branch and "e2SIP2D":
            warnings.warn( "EEETree: Expected branch e2SIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SIP2D")
        else:
            self.e2SIP2D_branch.SetAddress(<void*>&self.e2SIP2D_value)

        #print "making e2SIP3D"
        self.e2SIP3D_branch = the_tree.GetBranch("e2SIP3D")
        #if not self.e2SIP3D_branch and "e2SIP3D" not in self.complained:
        if not self.e2SIP3D_branch and "e2SIP3D":
            warnings.warn( "EEETree: Expected branch e2SIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SIP3D")
        else:
            self.e2SIP3D_branch.SetAddress(<void*>&self.e2SIP3D_value)

        #print "making e2SigmaIEtaIEta"
        self.e2SigmaIEtaIEta_branch = the_tree.GetBranch("e2SigmaIEtaIEta")
        #if not self.e2SigmaIEtaIEta_branch and "e2SigmaIEtaIEta" not in self.complained:
        if not self.e2SigmaIEtaIEta_branch and "e2SigmaIEtaIEta":
            warnings.warn( "EEETree: Expected branch e2SigmaIEtaIEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2SigmaIEtaIEta")
        else:
            self.e2SigmaIEtaIEta_branch.SetAddress(<void*>&self.e2SigmaIEtaIEta_value)

        #print "making e2TrkIsoDR03"
        self.e2TrkIsoDR03_branch = the_tree.GetBranch("e2TrkIsoDR03")
        #if not self.e2TrkIsoDR03_branch and "e2TrkIsoDR03" not in self.complained:
        if not self.e2TrkIsoDR03_branch and "e2TrkIsoDR03":
            warnings.warn( "EEETree: Expected branch e2TrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2TrkIsoDR03")
        else:
            self.e2TrkIsoDR03_branch.SetAddress(<void*>&self.e2TrkIsoDR03_value)

        #print "making e2VZ"
        self.e2VZ_branch = the_tree.GetBranch("e2VZ")
        #if not self.e2VZ_branch and "e2VZ" not in self.complained:
        if not self.e2VZ_branch and "e2VZ":
            warnings.warn( "EEETree: Expected branch e2VZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2VZ")
        else:
            self.e2VZ_branch.SetAddress(<void*>&self.e2VZ_value)

        #print "making e2WWLoose"
        self.e2WWLoose_branch = the_tree.GetBranch("e2WWLoose")
        #if not self.e2WWLoose_branch and "e2WWLoose" not in self.complained:
        if not self.e2WWLoose_branch and "e2WWLoose":
            warnings.warn( "EEETree: Expected branch e2WWLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2WWLoose")
        else:
            self.e2WWLoose_branch.SetAddress(<void*>&self.e2WWLoose_value)

        #print "making e2_e1_collinearmass"
        self.e2_e1_collinearmass_branch = the_tree.GetBranch("e2_e1_collinearmass")
        #if not self.e2_e1_collinearmass_branch and "e2_e1_collinearmass" not in self.complained:
        if not self.e2_e1_collinearmass_branch and "e2_e1_collinearmass":
            warnings.warn( "EEETree: Expected branch e2_e1_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e1_collinearmass")
        else:
            self.e2_e1_collinearmass_branch.SetAddress(<void*>&self.e2_e1_collinearmass_value)

        #print "making e2_e1_collinearmass_JetEnDown"
        self.e2_e1_collinearmass_JetEnDown_branch = the_tree.GetBranch("e2_e1_collinearmass_JetEnDown")
        #if not self.e2_e1_collinearmass_JetEnDown_branch and "e2_e1_collinearmass_JetEnDown" not in self.complained:
        if not self.e2_e1_collinearmass_JetEnDown_branch and "e2_e1_collinearmass_JetEnDown":
            warnings.warn( "EEETree: Expected branch e2_e1_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e1_collinearmass_JetEnDown")
        else:
            self.e2_e1_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.e2_e1_collinearmass_JetEnDown_value)

        #print "making e2_e1_collinearmass_JetEnUp"
        self.e2_e1_collinearmass_JetEnUp_branch = the_tree.GetBranch("e2_e1_collinearmass_JetEnUp")
        #if not self.e2_e1_collinearmass_JetEnUp_branch and "e2_e1_collinearmass_JetEnUp" not in self.complained:
        if not self.e2_e1_collinearmass_JetEnUp_branch and "e2_e1_collinearmass_JetEnUp":
            warnings.warn( "EEETree: Expected branch e2_e1_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e1_collinearmass_JetEnUp")
        else:
            self.e2_e1_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.e2_e1_collinearmass_JetEnUp_value)

        #print "making e2_e1_collinearmass_UnclusteredEnDown"
        self.e2_e1_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("e2_e1_collinearmass_UnclusteredEnDown")
        #if not self.e2_e1_collinearmass_UnclusteredEnDown_branch and "e2_e1_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.e2_e1_collinearmass_UnclusteredEnDown_branch and "e2_e1_collinearmass_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e2_e1_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e1_collinearmass_UnclusteredEnDown")
        else:
            self.e2_e1_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.e2_e1_collinearmass_UnclusteredEnDown_value)

        #print "making e2_e1_collinearmass_UnclusteredEnUp"
        self.e2_e1_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("e2_e1_collinearmass_UnclusteredEnUp")
        #if not self.e2_e1_collinearmass_UnclusteredEnUp_branch and "e2_e1_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.e2_e1_collinearmass_UnclusteredEnUp_branch and "e2_e1_collinearmass_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e2_e1_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e1_collinearmass_UnclusteredEnUp")
        else:
            self.e2_e1_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.e2_e1_collinearmass_UnclusteredEnUp_value)

        #print "making e2_e3_CosThetaStar"
        self.e2_e3_CosThetaStar_branch = the_tree.GetBranch("e2_e3_CosThetaStar")
        #if not self.e2_e3_CosThetaStar_branch and "e2_e3_CosThetaStar" not in self.complained:
        if not self.e2_e3_CosThetaStar_branch and "e2_e3_CosThetaStar":
            warnings.warn( "EEETree: Expected branch e2_e3_CosThetaStar does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_CosThetaStar")
        else:
            self.e2_e3_CosThetaStar_branch.SetAddress(<void*>&self.e2_e3_CosThetaStar_value)

        #print "making e2_e3_DPhi"
        self.e2_e3_DPhi_branch = the_tree.GetBranch("e2_e3_DPhi")
        #if not self.e2_e3_DPhi_branch and "e2_e3_DPhi" not in self.complained:
        if not self.e2_e3_DPhi_branch and "e2_e3_DPhi":
            warnings.warn( "EEETree: Expected branch e2_e3_DPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_DPhi")
        else:
            self.e2_e3_DPhi_branch.SetAddress(<void*>&self.e2_e3_DPhi_value)

        #print "making e2_e3_DR"
        self.e2_e3_DR_branch = the_tree.GetBranch("e2_e3_DR")
        #if not self.e2_e3_DR_branch and "e2_e3_DR" not in self.complained:
        if not self.e2_e3_DR_branch and "e2_e3_DR":
            warnings.warn( "EEETree: Expected branch e2_e3_DR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_DR")
        else:
            self.e2_e3_DR_branch.SetAddress(<void*>&self.e2_e3_DR_value)

        #print "making e2_e3_Eta"
        self.e2_e3_Eta_branch = the_tree.GetBranch("e2_e3_Eta")
        #if not self.e2_e3_Eta_branch and "e2_e3_Eta" not in self.complained:
        if not self.e2_e3_Eta_branch and "e2_e3_Eta":
            warnings.warn( "EEETree: Expected branch e2_e3_Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_Eta")
        else:
            self.e2_e3_Eta_branch.SetAddress(<void*>&self.e2_e3_Eta_value)

        #print "making e2_e3_Mass"
        self.e2_e3_Mass_branch = the_tree.GetBranch("e2_e3_Mass")
        #if not self.e2_e3_Mass_branch and "e2_e3_Mass" not in self.complained:
        if not self.e2_e3_Mass_branch and "e2_e3_Mass":
            warnings.warn( "EEETree: Expected branch e2_e3_Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_Mass")
        else:
            self.e2_e3_Mass_branch.SetAddress(<void*>&self.e2_e3_Mass_value)

        #print "making e2_e3_Mt"
        self.e2_e3_Mt_branch = the_tree.GetBranch("e2_e3_Mt")
        #if not self.e2_e3_Mt_branch and "e2_e3_Mt" not in self.complained:
        if not self.e2_e3_Mt_branch and "e2_e3_Mt":
            warnings.warn( "EEETree: Expected branch e2_e3_Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_Mt")
        else:
            self.e2_e3_Mt_branch.SetAddress(<void*>&self.e2_e3_Mt_value)

        #print "making e2_e3_PZeta"
        self.e2_e3_PZeta_branch = the_tree.GetBranch("e2_e3_PZeta")
        #if not self.e2_e3_PZeta_branch and "e2_e3_PZeta" not in self.complained:
        if not self.e2_e3_PZeta_branch and "e2_e3_PZeta":
            warnings.warn( "EEETree: Expected branch e2_e3_PZeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_PZeta")
        else:
            self.e2_e3_PZeta_branch.SetAddress(<void*>&self.e2_e3_PZeta_value)

        #print "making e2_e3_PZetaVis"
        self.e2_e3_PZetaVis_branch = the_tree.GetBranch("e2_e3_PZetaVis")
        #if not self.e2_e3_PZetaVis_branch and "e2_e3_PZetaVis" not in self.complained:
        if not self.e2_e3_PZetaVis_branch and "e2_e3_PZetaVis":
            warnings.warn( "EEETree: Expected branch e2_e3_PZetaVis does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_PZetaVis")
        else:
            self.e2_e3_PZetaVis_branch.SetAddress(<void*>&self.e2_e3_PZetaVis_value)

        #print "making e2_e3_Phi"
        self.e2_e3_Phi_branch = the_tree.GetBranch("e2_e3_Phi")
        #if not self.e2_e3_Phi_branch and "e2_e3_Phi" not in self.complained:
        if not self.e2_e3_Phi_branch and "e2_e3_Phi":
            warnings.warn( "EEETree: Expected branch e2_e3_Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_Phi")
        else:
            self.e2_e3_Phi_branch.SetAddress(<void*>&self.e2_e3_Phi_value)

        #print "making e2_e3_Pt"
        self.e2_e3_Pt_branch = the_tree.GetBranch("e2_e3_Pt")
        #if not self.e2_e3_Pt_branch and "e2_e3_Pt" not in self.complained:
        if not self.e2_e3_Pt_branch and "e2_e3_Pt":
            warnings.warn( "EEETree: Expected branch e2_e3_Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_Pt")
        else:
            self.e2_e3_Pt_branch.SetAddress(<void*>&self.e2_e3_Pt_value)

        #print "making e2_e3_SS"
        self.e2_e3_SS_branch = the_tree.GetBranch("e2_e3_SS")
        #if not self.e2_e3_SS_branch and "e2_e3_SS" not in self.complained:
        if not self.e2_e3_SS_branch and "e2_e3_SS":
            warnings.warn( "EEETree: Expected branch e2_e3_SS does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_SS")
        else:
            self.e2_e3_SS_branch.SetAddress(<void*>&self.e2_e3_SS_value)

        #print "making e2_e3_ToMETDPhi_Ty1"
        self.e2_e3_ToMETDPhi_Ty1_branch = the_tree.GetBranch("e2_e3_ToMETDPhi_Ty1")
        #if not self.e2_e3_ToMETDPhi_Ty1_branch and "e2_e3_ToMETDPhi_Ty1" not in self.complained:
        if not self.e2_e3_ToMETDPhi_Ty1_branch and "e2_e3_ToMETDPhi_Ty1":
            warnings.warn( "EEETree: Expected branch e2_e3_ToMETDPhi_Ty1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_ToMETDPhi_Ty1")
        else:
            self.e2_e3_ToMETDPhi_Ty1_branch.SetAddress(<void*>&self.e2_e3_ToMETDPhi_Ty1_value)

        #print "making e2_e3_collinearmass"
        self.e2_e3_collinearmass_branch = the_tree.GetBranch("e2_e3_collinearmass")
        #if not self.e2_e3_collinearmass_branch and "e2_e3_collinearmass" not in self.complained:
        if not self.e2_e3_collinearmass_branch and "e2_e3_collinearmass":
            warnings.warn( "EEETree: Expected branch e2_e3_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_collinearmass")
        else:
            self.e2_e3_collinearmass_branch.SetAddress(<void*>&self.e2_e3_collinearmass_value)

        #print "making e2_e3_collinearmass_JetEnDown"
        self.e2_e3_collinearmass_JetEnDown_branch = the_tree.GetBranch("e2_e3_collinearmass_JetEnDown")
        #if not self.e2_e3_collinearmass_JetEnDown_branch and "e2_e3_collinearmass_JetEnDown" not in self.complained:
        if not self.e2_e3_collinearmass_JetEnDown_branch and "e2_e3_collinearmass_JetEnDown":
            warnings.warn( "EEETree: Expected branch e2_e3_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_collinearmass_JetEnDown")
        else:
            self.e2_e3_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.e2_e3_collinearmass_JetEnDown_value)

        #print "making e2_e3_collinearmass_JetEnUp"
        self.e2_e3_collinearmass_JetEnUp_branch = the_tree.GetBranch("e2_e3_collinearmass_JetEnUp")
        #if not self.e2_e3_collinearmass_JetEnUp_branch and "e2_e3_collinearmass_JetEnUp" not in self.complained:
        if not self.e2_e3_collinearmass_JetEnUp_branch and "e2_e3_collinearmass_JetEnUp":
            warnings.warn( "EEETree: Expected branch e2_e3_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_collinearmass_JetEnUp")
        else:
            self.e2_e3_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.e2_e3_collinearmass_JetEnUp_value)

        #print "making e2_e3_collinearmass_UnclusteredEnDown"
        self.e2_e3_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("e2_e3_collinearmass_UnclusteredEnDown")
        #if not self.e2_e3_collinearmass_UnclusteredEnDown_branch and "e2_e3_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.e2_e3_collinearmass_UnclusteredEnDown_branch and "e2_e3_collinearmass_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e2_e3_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_collinearmass_UnclusteredEnDown")
        else:
            self.e2_e3_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.e2_e3_collinearmass_UnclusteredEnDown_value)

        #print "making e2_e3_collinearmass_UnclusteredEnUp"
        self.e2_e3_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("e2_e3_collinearmass_UnclusteredEnUp")
        #if not self.e2_e3_collinearmass_UnclusteredEnUp_branch and "e2_e3_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.e2_e3_collinearmass_UnclusteredEnUp_branch and "e2_e3_collinearmass_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e2_e3_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2_e3_collinearmass_UnclusteredEnUp")
        else:
            self.e2_e3_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.e2_e3_collinearmass_UnclusteredEnUp_value)

        #print "making e2deltaEtaSuperClusterTrackAtVtx"
        self.e2deltaEtaSuperClusterTrackAtVtx_branch = the_tree.GetBranch("e2deltaEtaSuperClusterTrackAtVtx")
        #if not self.e2deltaEtaSuperClusterTrackAtVtx_branch and "e2deltaEtaSuperClusterTrackAtVtx" not in self.complained:
        if not self.e2deltaEtaSuperClusterTrackAtVtx_branch and "e2deltaEtaSuperClusterTrackAtVtx":
            warnings.warn( "EEETree: Expected branch e2deltaEtaSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2deltaEtaSuperClusterTrackAtVtx")
        else:
            self.e2deltaEtaSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.e2deltaEtaSuperClusterTrackAtVtx_value)

        #print "making e2deltaPhiSuperClusterTrackAtVtx"
        self.e2deltaPhiSuperClusterTrackAtVtx_branch = the_tree.GetBranch("e2deltaPhiSuperClusterTrackAtVtx")
        #if not self.e2deltaPhiSuperClusterTrackAtVtx_branch and "e2deltaPhiSuperClusterTrackAtVtx" not in self.complained:
        if not self.e2deltaPhiSuperClusterTrackAtVtx_branch and "e2deltaPhiSuperClusterTrackAtVtx":
            warnings.warn( "EEETree: Expected branch e2deltaPhiSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2deltaPhiSuperClusterTrackAtVtx")
        else:
            self.e2deltaPhiSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.e2deltaPhiSuperClusterTrackAtVtx_value)

        #print "making e2eSuperClusterOverP"
        self.e2eSuperClusterOverP_branch = the_tree.GetBranch("e2eSuperClusterOverP")
        #if not self.e2eSuperClusterOverP_branch and "e2eSuperClusterOverP" not in self.complained:
        if not self.e2eSuperClusterOverP_branch and "e2eSuperClusterOverP":
            warnings.warn( "EEETree: Expected branch e2eSuperClusterOverP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2eSuperClusterOverP")
        else:
            self.e2eSuperClusterOverP_branch.SetAddress(<void*>&self.e2eSuperClusterOverP_value)

        #print "making e2ecalEnergy"
        self.e2ecalEnergy_branch = the_tree.GetBranch("e2ecalEnergy")
        #if not self.e2ecalEnergy_branch and "e2ecalEnergy" not in self.complained:
        if not self.e2ecalEnergy_branch and "e2ecalEnergy":
            warnings.warn( "EEETree: Expected branch e2ecalEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2ecalEnergy")
        else:
            self.e2ecalEnergy_branch.SetAddress(<void*>&self.e2ecalEnergy_value)

        #print "making e2fBrem"
        self.e2fBrem_branch = the_tree.GetBranch("e2fBrem")
        #if not self.e2fBrem_branch and "e2fBrem" not in self.complained:
        if not self.e2fBrem_branch and "e2fBrem":
            warnings.warn( "EEETree: Expected branch e2fBrem does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2fBrem")
        else:
            self.e2fBrem_branch.SetAddress(<void*>&self.e2fBrem_value)

        #print "making e2trackMomentumAtVtxP"
        self.e2trackMomentumAtVtxP_branch = the_tree.GetBranch("e2trackMomentumAtVtxP")
        #if not self.e2trackMomentumAtVtxP_branch and "e2trackMomentumAtVtxP" not in self.complained:
        if not self.e2trackMomentumAtVtxP_branch and "e2trackMomentumAtVtxP":
            warnings.warn( "EEETree: Expected branch e2trackMomentumAtVtxP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e2trackMomentumAtVtxP")
        else:
            self.e2trackMomentumAtVtxP_branch.SetAddress(<void*>&self.e2trackMomentumAtVtxP_value)

        #print "making e3AbsEta"
        self.e3AbsEta_branch = the_tree.GetBranch("e3AbsEta")
        #if not self.e3AbsEta_branch and "e3AbsEta" not in self.complained:
        if not self.e3AbsEta_branch and "e3AbsEta":
            warnings.warn( "EEETree: Expected branch e3AbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3AbsEta")
        else:
            self.e3AbsEta_branch.SetAddress(<void*>&self.e3AbsEta_value)

        #print "making e3CBIDLoose"
        self.e3CBIDLoose_branch = the_tree.GetBranch("e3CBIDLoose")
        #if not self.e3CBIDLoose_branch and "e3CBIDLoose" not in self.complained:
        if not self.e3CBIDLoose_branch and "e3CBIDLoose":
            warnings.warn( "EEETree: Expected branch e3CBIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDLoose")
        else:
            self.e3CBIDLoose_branch.SetAddress(<void*>&self.e3CBIDLoose_value)

        #print "making e3CBIDLooseNoIso"
        self.e3CBIDLooseNoIso_branch = the_tree.GetBranch("e3CBIDLooseNoIso")
        #if not self.e3CBIDLooseNoIso_branch and "e3CBIDLooseNoIso" not in self.complained:
        if not self.e3CBIDLooseNoIso_branch and "e3CBIDLooseNoIso":
            warnings.warn( "EEETree: Expected branch e3CBIDLooseNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDLooseNoIso")
        else:
            self.e3CBIDLooseNoIso_branch.SetAddress(<void*>&self.e3CBIDLooseNoIso_value)

        #print "making e3CBIDMedium"
        self.e3CBIDMedium_branch = the_tree.GetBranch("e3CBIDMedium")
        #if not self.e3CBIDMedium_branch and "e3CBIDMedium" not in self.complained:
        if not self.e3CBIDMedium_branch and "e3CBIDMedium":
            warnings.warn( "EEETree: Expected branch e3CBIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDMedium")
        else:
            self.e3CBIDMedium_branch.SetAddress(<void*>&self.e3CBIDMedium_value)

        #print "making e3CBIDMediumNoIso"
        self.e3CBIDMediumNoIso_branch = the_tree.GetBranch("e3CBIDMediumNoIso")
        #if not self.e3CBIDMediumNoIso_branch and "e3CBIDMediumNoIso" not in self.complained:
        if not self.e3CBIDMediumNoIso_branch and "e3CBIDMediumNoIso":
            warnings.warn( "EEETree: Expected branch e3CBIDMediumNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDMediumNoIso")
        else:
            self.e3CBIDMediumNoIso_branch.SetAddress(<void*>&self.e3CBIDMediumNoIso_value)

        #print "making e3CBIDTight"
        self.e3CBIDTight_branch = the_tree.GetBranch("e3CBIDTight")
        #if not self.e3CBIDTight_branch and "e3CBIDTight" not in self.complained:
        if not self.e3CBIDTight_branch and "e3CBIDTight":
            warnings.warn( "EEETree: Expected branch e3CBIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDTight")
        else:
            self.e3CBIDTight_branch.SetAddress(<void*>&self.e3CBIDTight_value)

        #print "making e3CBIDTightNoIso"
        self.e3CBIDTightNoIso_branch = the_tree.GetBranch("e3CBIDTightNoIso")
        #if not self.e3CBIDTightNoIso_branch and "e3CBIDTightNoIso" not in self.complained:
        if not self.e3CBIDTightNoIso_branch and "e3CBIDTightNoIso":
            warnings.warn( "EEETree: Expected branch e3CBIDTightNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDTightNoIso")
        else:
            self.e3CBIDTightNoIso_branch.SetAddress(<void*>&self.e3CBIDTightNoIso_value)

        #print "making e3CBIDVeto"
        self.e3CBIDVeto_branch = the_tree.GetBranch("e3CBIDVeto")
        #if not self.e3CBIDVeto_branch and "e3CBIDVeto" not in self.complained:
        if not self.e3CBIDVeto_branch and "e3CBIDVeto":
            warnings.warn( "EEETree: Expected branch e3CBIDVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDVeto")
        else:
            self.e3CBIDVeto_branch.SetAddress(<void*>&self.e3CBIDVeto_value)

        #print "making e3CBIDVetoNoIso"
        self.e3CBIDVetoNoIso_branch = the_tree.GetBranch("e3CBIDVetoNoIso")
        #if not self.e3CBIDVetoNoIso_branch and "e3CBIDVetoNoIso" not in self.complained:
        if not self.e3CBIDVetoNoIso_branch and "e3CBIDVetoNoIso":
            warnings.warn( "EEETree: Expected branch e3CBIDVetoNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3CBIDVetoNoIso")
        else:
            self.e3CBIDVetoNoIso_branch.SetAddress(<void*>&self.e3CBIDVetoNoIso_value)

        #print "making e3Charge"
        self.e3Charge_branch = the_tree.GetBranch("e3Charge")
        #if not self.e3Charge_branch and "e3Charge" not in self.complained:
        if not self.e3Charge_branch and "e3Charge":
            warnings.warn( "EEETree: Expected branch e3Charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Charge")
        else:
            self.e3Charge_branch.SetAddress(<void*>&self.e3Charge_value)

        #print "making e3ChargeIdLoose"
        self.e3ChargeIdLoose_branch = the_tree.GetBranch("e3ChargeIdLoose")
        #if not self.e3ChargeIdLoose_branch and "e3ChargeIdLoose" not in self.complained:
        if not self.e3ChargeIdLoose_branch and "e3ChargeIdLoose":
            warnings.warn( "EEETree: Expected branch e3ChargeIdLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3ChargeIdLoose")
        else:
            self.e3ChargeIdLoose_branch.SetAddress(<void*>&self.e3ChargeIdLoose_value)

        #print "making e3ChargeIdMed"
        self.e3ChargeIdMed_branch = the_tree.GetBranch("e3ChargeIdMed")
        #if not self.e3ChargeIdMed_branch and "e3ChargeIdMed" not in self.complained:
        if not self.e3ChargeIdMed_branch and "e3ChargeIdMed":
            warnings.warn( "EEETree: Expected branch e3ChargeIdMed does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3ChargeIdMed")
        else:
            self.e3ChargeIdMed_branch.SetAddress(<void*>&self.e3ChargeIdMed_value)

        #print "making e3ChargeIdTight"
        self.e3ChargeIdTight_branch = the_tree.GetBranch("e3ChargeIdTight")
        #if not self.e3ChargeIdTight_branch and "e3ChargeIdTight" not in self.complained:
        if not self.e3ChargeIdTight_branch and "e3ChargeIdTight":
            warnings.warn( "EEETree: Expected branch e3ChargeIdTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3ChargeIdTight")
        else:
            self.e3ChargeIdTight_branch.SetAddress(<void*>&self.e3ChargeIdTight_value)

        #print "making e3ComesFromHiggs"
        self.e3ComesFromHiggs_branch = the_tree.GetBranch("e3ComesFromHiggs")
        #if not self.e3ComesFromHiggs_branch and "e3ComesFromHiggs" not in self.complained:
        if not self.e3ComesFromHiggs_branch and "e3ComesFromHiggs":
            warnings.warn( "EEETree: Expected branch e3ComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3ComesFromHiggs")
        else:
            self.e3ComesFromHiggs_branch.SetAddress(<void*>&self.e3ComesFromHiggs_value)

        #print "making e3DPhiToPfMet_ElectronEnDown"
        self.e3DPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("e3DPhiToPfMet_ElectronEnDown")
        #if not self.e3DPhiToPfMet_ElectronEnDown_branch and "e3DPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.e3DPhiToPfMet_ElectronEnDown_branch and "e3DPhiToPfMet_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_ElectronEnDown")
        else:
            self.e3DPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.e3DPhiToPfMet_ElectronEnDown_value)

        #print "making e3DPhiToPfMet_ElectronEnUp"
        self.e3DPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("e3DPhiToPfMet_ElectronEnUp")
        #if not self.e3DPhiToPfMet_ElectronEnUp_branch and "e3DPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.e3DPhiToPfMet_ElectronEnUp_branch and "e3DPhiToPfMet_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_ElectronEnUp")
        else:
            self.e3DPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.e3DPhiToPfMet_ElectronEnUp_value)

        #print "making e3DPhiToPfMet_JetEnDown"
        self.e3DPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("e3DPhiToPfMet_JetEnDown")
        #if not self.e3DPhiToPfMet_JetEnDown_branch and "e3DPhiToPfMet_JetEnDown" not in self.complained:
        if not self.e3DPhiToPfMet_JetEnDown_branch and "e3DPhiToPfMet_JetEnDown":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_JetEnDown")
        else:
            self.e3DPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.e3DPhiToPfMet_JetEnDown_value)

        #print "making e3DPhiToPfMet_JetEnUp"
        self.e3DPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("e3DPhiToPfMet_JetEnUp")
        #if not self.e3DPhiToPfMet_JetEnUp_branch and "e3DPhiToPfMet_JetEnUp" not in self.complained:
        if not self.e3DPhiToPfMet_JetEnUp_branch and "e3DPhiToPfMet_JetEnUp":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_JetEnUp")
        else:
            self.e3DPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.e3DPhiToPfMet_JetEnUp_value)

        #print "making e3DPhiToPfMet_JetResDown"
        self.e3DPhiToPfMet_JetResDown_branch = the_tree.GetBranch("e3DPhiToPfMet_JetResDown")
        #if not self.e3DPhiToPfMet_JetResDown_branch and "e3DPhiToPfMet_JetResDown" not in self.complained:
        if not self.e3DPhiToPfMet_JetResDown_branch and "e3DPhiToPfMet_JetResDown":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_JetResDown")
        else:
            self.e3DPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.e3DPhiToPfMet_JetResDown_value)

        #print "making e3DPhiToPfMet_JetResUp"
        self.e3DPhiToPfMet_JetResUp_branch = the_tree.GetBranch("e3DPhiToPfMet_JetResUp")
        #if not self.e3DPhiToPfMet_JetResUp_branch and "e3DPhiToPfMet_JetResUp" not in self.complained:
        if not self.e3DPhiToPfMet_JetResUp_branch and "e3DPhiToPfMet_JetResUp":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_JetResUp")
        else:
            self.e3DPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.e3DPhiToPfMet_JetResUp_value)

        #print "making e3DPhiToPfMet_MuonEnDown"
        self.e3DPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("e3DPhiToPfMet_MuonEnDown")
        #if not self.e3DPhiToPfMet_MuonEnDown_branch and "e3DPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.e3DPhiToPfMet_MuonEnDown_branch and "e3DPhiToPfMet_MuonEnDown":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_MuonEnDown")
        else:
            self.e3DPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.e3DPhiToPfMet_MuonEnDown_value)

        #print "making e3DPhiToPfMet_MuonEnUp"
        self.e3DPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("e3DPhiToPfMet_MuonEnUp")
        #if not self.e3DPhiToPfMet_MuonEnUp_branch and "e3DPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.e3DPhiToPfMet_MuonEnUp_branch and "e3DPhiToPfMet_MuonEnUp":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_MuonEnUp")
        else:
            self.e3DPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.e3DPhiToPfMet_MuonEnUp_value)

        #print "making e3DPhiToPfMet_PhotonEnDown"
        self.e3DPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("e3DPhiToPfMet_PhotonEnDown")
        #if not self.e3DPhiToPfMet_PhotonEnDown_branch and "e3DPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.e3DPhiToPfMet_PhotonEnDown_branch and "e3DPhiToPfMet_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_PhotonEnDown")
        else:
            self.e3DPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.e3DPhiToPfMet_PhotonEnDown_value)

        #print "making e3DPhiToPfMet_PhotonEnUp"
        self.e3DPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("e3DPhiToPfMet_PhotonEnUp")
        #if not self.e3DPhiToPfMet_PhotonEnUp_branch and "e3DPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.e3DPhiToPfMet_PhotonEnUp_branch and "e3DPhiToPfMet_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_PhotonEnUp")
        else:
            self.e3DPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.e3DPhiToPfMet_PhotonEnUp_value)

        #print "making e3DPhiToPfMet_TauEnDown"
        self.e3DPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("e3DPhiToPfMet_TauEnDown")
        #if not self.e3DPhiToPfMet_TauEnDown_branch and "e3DPhiToPfMet_TauEnDown" not in self.complained:
        if not self.e3DPhiToPfMet_TauEnDown_branch and "e3DPhiToPfMet_TauEnDown":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_TauEnDown")
        else:
            self.e3DPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.e3DPhiToPfMet_TauEnDown_value)

        #print "making e3DPhiToPfMet_TauEnUp"
        self.e3DPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("e3DPhiToPfMet_TauEnUp")
        #if not self.e3DPhiToPfMet_TauEnUp_branch and "e3DPhiToPfMet_TauEnUp" not in self.complained:
        if not self.e3DPhiToPfMet_TauEnUp_branch and "e3DPhiToPfMet_TauEnUp":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_TauEnUp")
        else:
            self.e3DPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.e3DPhiToPfMet_TauEnUp_value)

        #print "making e3DPhiToPfMet_UnclusteredEnDown"
        self.e3DPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("e3DPhiToPfMet_UnclusteredEnDown")
        #if not self.e3DPhiToPfMet_UnclusteredEnDown_branch and "e3DPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.e3DPhiToPfMet_UnclusteredEnDown_branch and "e3DPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_UnclusteredEnDown")
        else:
            self.e3DPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.e3DPhiToPfMet_UnclusteredEnDown_value)

        #print "making e3DPhiToPfMet_UnclusteredEnUp"
        self.e3DPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("e3DPhiToPfMet_UnclusteredEnUp")
        #if not self.e3DPhiToPfMet_UnclusteredEnUp_branch and "e3DPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.e3DPhiToPfMet_UnclusteredEnUp_branch and "e3DPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_UnclusteredEnUp")
        else:
            self.e3DPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.e3DPhiToPfMet_UnclusteredEnUp_value)

        #print "making e3DPhiToPfMet_type1"
        self.e3DPhiToPfMet_type1_branch = the_tree.GetBranch("e3DPhiToPfMet_type1")
        #if not self.e3DPhiToPfMet_type1_branch and "e3DPhiToPfMet_type1" not in self.complained:
        if not self.e3DPhiToPfMet_type1_branch and "e3DPhiToPfMet_type1":
            warnings.warn( "EEETree: Expected branch e3DPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3DPhiToPfMet_type1")
        else:
            self.e3DPhiToPfMet_type1_branch.SetAddress(<void*>&self.e3DPhiToPfMet_type1_value)

        #print "making e3E1x5"
        self.e3E1x5_branch = the_tree.GetBranch("e3E1x5")
        #if not self.e3E1x5_branch and "e3E1x5" not in self.complained:
        if not self.e3E1x5_branch and "e3E1x5":
            warnings.warn( "EEETree: Expected branch e3E1x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3E1x5")
        else:
            self.e3E1x5_branch.SetAddress(<void*>&self.e3E1x5_value)

        #print "making e3E2x5Max"
        self.e3E2x5Max_branch = the_tree.GetBranch("e3E2x5Max")
        #if not self.e3E2x5Max_branch and "e3E2x5Max" not in self.complained:
        if not self.e3E2x5Max_branch and "e3E2x5Max":
            warnings.warn( "EEETree: Expected branch e3E2x5Max does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3E2x5Max")
        else:
            self.e3E2x5Max_branch.SetAddress(<void*>&self.e3E2x5Max_value)

        #print "making e3E5x5"
        self.e3E5x5_branch = the_tree.GetBranch("e3E5x5")
        #if not self.e3E5x5_branch and "e3E5x5" not in self.complained:
        if not self.e3E5x5_branch and "e3E5x5":
            warnings.warn( "EEETree: Expected branch e3E5x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3E5x5")
        else:
            self.e3E5x5_branch.SetAddress(<void*>&self.e3E5x5_value)

        #print "making e3EcalIsoDR03"
        self.e3EcalIsoDR03_branch = the_tree.GetBranch("e3EcalIsoDR03")
        #if not self.e3EcalIsoDR03_branch and "e3EcalIsoDR03" not in self.complained:
        if not self.e3EcalIsoDR03_branch and "e3EcalIsoDR03":
            warnings.warn( "EEETree: Expected branch e3EcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3EcalIsoDR03")
        else:
            self.e3EcalIsoDR03_branch.SetAddress(<void*>&self.e3EcalIsoDR03_value)

        #print "making e3EffectiveArea2012Data"
        self.e3EffectiveArea2012Data_branch = the_tree.GetBranch("e3EffectiveArea2012Data")
        #if not self.e3EffectiveArea2012Data_branch and "e3EffectiveArea2012Data" not in self.complained:
        if not self.e3EffectiveArea2012Data_branch and "e3EffectiveArea2012Data":
            warnings.warn( "EEETree: Expected branch e3EffectiveArea2012Data does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3EffectiveArea2012Data")
        else:
            self.e3EffectiveArea2012Data_branch.SetAddress(<void*>&self.e3EffectiveArea2012Data_value)

        #print "making e3EffectiveAreaSpring15"
        self.e3EffectiveAreaSpring15_branch = the_tree.GetBranch("e3EffectiveAreaSpring15")
        #if not self.e3EffectiveAreaSpring15_branch and "e3EffectiveAreaSpring15" not in self.complained:
        if not self.e3EffectiveAreaSpring15_branch and "e3EffectiveAreaSpring15":
            warnings.warn( "EEETree: Expected branch e3EffectiveAreaSpring15 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3EffectiveAreaSpring15")
        else:
            self.e3EffectiveAreaSpring15_branch.SetAddress(<void*>&self.e3EffectiveAreaSpring15_value)

        #print "making e3EnergyError"
        self.e3EnergyError_branch = the_tree.GetBranch("e3EnergyError")
        #if not self.e3EnergyError_branch and "e3EnergyError" not in self.complained:
        if not self.e3EnergyError_branch and "e3EnergyError":
            warnings.warn( "EEETree: Expected branch e3EnergyError does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3EnergyError")
        else:
            self.e3EnergyError_branch.SetAddress(<void*>&self.e3EnergyError_value)

        #print "making e3Eta"
        self.e3Eta_branch = the_tree.GetBranch("e3Eta")
        #if not self.e3Eta_branch and "e3Eta" not in self.complained:
        if not self.e3Eta_branch and "e3Eta":
            warnings.warn( "EEETree: Expected branch e3Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Eta")
        else:
            self.e3Eta_branch.SetAddress(<void*>&self.e3Eta_value)

        #print "making e3Eta_ElectronEnDown"
        self.e3Eta_ElectronEnDown_branch = the_tree.GetBranch("e3Eta_ElectronEnDown")
        #if not self.e3Eta_ElectronEnDown_branch and "e3Eta_ElectronEnDown" not in self.complained:
        if not self.e3Eta_ElectronEnDown_branch and "e3Eta_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e3Eta_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Eta_ElectronEnDown")
        else:
            self.e3Eta_ElectronEnDown_branch.SetAddress(<void*>&self.e3Eta_ElectronEnDown_value)

        #print "making e3Eta_ElectronEnUp"
        self.e3Eta_ElectronEnUp_branch = the_tree.GetBranch("e3Eta_ElectronEnUp")
        #if not self.e3Eta_ElectronEnUp_branch and "e3Eta_ElectronEnUp" not in self.complained:
        if not self.e3Eta_ElectronEnUp_branch and "e3Eta_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e3Eta_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Eta_ElectronEnUp")
        else:
            self.e3Eta_ElectronEnUp_branch.SetAddress(<void*>&self.e3Eta_ElectronEnUp_value)

        #print "making e3GenCharge"
        self.e3GenCharge_branch = the_tree.GetBranch("e3GenCharge")
        #if not self.e3GenCharge_branch and "e3GenCharge" not in self.complained:
        if not self.e3GenCharge_branch and "e3GenCharge":
            warnings.warn( "EEETree: Expected branch e3GenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenCharge")
        else:
            self.e3GenCharge_branch.SetAddress(<void*>&self.e3GenCharge_value)

        #print "making e3GenEnergy"
        self.e3GenEnergy_branch = the_tree.GetBranch("e3GenEnergy")
        #if not self.e3GenEnergy_branch and "e3GenEnergy" not in self.complained:
        if not self.e3GenEnergy_branch and "e3GenEnergy":
            warnings.warn( "EEETree: Expected branch e3GenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenEnergy")
        else:
            self.e3GenEnergy_branch.SetAddress(<void*>&self.e3GenEnergy_value)

        #print "making e3GenEta"
        self.e3GenEta_branch = the_tree.GetBranch("e3GenEta")
        #if not self.e3GenEta_branch and "e3GenEta" not in self.complained:
        if not self.e3GenEta_branch and "e3GenEta":
            warnings.warn( "EEETree: Expected branch e3GenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenEta")
        else:
            self.e3GenEta_branch.SetAddress(<void*>&self.e3GenEta_value)

        #print "making e3GenMotherPdgId"
        self.e3GenMotherPdgId_branch = the_tree.GetBranch("e3GenMotherPdgId")
        #if not self.e3GenMotherPdgId_branch and "e3GenMotherPdgId" not in self.complained:
        if not self.e3GenMotherPdgId_branch and "e3GenMotherPdgId":
            warnings.warn( "EEETree: Expected branch e3GenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenMotherPdgId")
        else:
            self.e3GenMotherPdgId_branch.SetAddress(<void*>&self.e3GenMotherPdgId_value)

        #print "making e3GenParticle"
        self.e3GenParticle_branch = the_tree.GetBranch("e3GenParticle")
        #if not self.e3GenParticle_branch and "e3GenParticle" not in self.complained:
        if not self.e3GenParticle_branch and "e3GenParticle":
            warnings.warn( "EEETree: Expected branch e3GenParticle does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenParticle")
        else:
            self.e3GenParticle_branch.SetAddress(<void*>&self.e3GenParticle_value)

        #print "making e3GenPdgId"
        self.e3GenPdgId_branch = the_tree.GetBranch("e3GenPdgId")
        #if not self.e3GenPdgId_branch and "e3GenPdgId" not in self.complained:
        if not self.e3GenPdgId_branch and "e3GenPdgId":
            warnings.warn( "EEETree: Expected branch e3GenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenPdgId")
        else:
            self.e3GenPdgId_branch.SetAddress(<void*>&self.e3GenPdgId_value)

        #print "making e3GenPhi"
        self.e3GenPhi_branch = the_tree.GetBranch("e3GenPhi")
        #if not self.e3GenPhi_branch and "e3GenPhi" not in self.complained:
        if not self.e3GenPhi_branch and "e3GenPhi":
            warnings.warn( "EEETree: Expected branch e3GenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenPhi")
        else:
            self.e3GenPhi_branch.SetAddress(<void*>&self.e3GenPhi_value)

        #print "making e3GenPrompt"
        self.e3GenPrompt_branch = the_tree.GetBranch("e3GenPrompt")
        #if not self.e3GenPrompt_branch and "e3GenPrompt" not in self.complained:
        if not self.e3GenPrompt_branch and "e3GenPrompt":
            warnings.warn( "EEETree: Expected branch e3GenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenPrompt")
        else:
            self.e3GenPrompt_branch.SetAddress(<void*>&self.e3GenPrompt_value)

        #print "making e3GenPromptTauDecay"
        self.e3GenPromptTauDecay_branch = the_tree.GetBranch("e3GenPromptTauDecay")
        #if not self.e3GenPromptTauDecay_branch and "e3GenPromptTauDecay" not in self.complained:
        if not self.e3GenPromptTauDecay_branch and "e3GenPromptTauDecay":
            warnings.warn( "EEETree: Expected branch e3GenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenPromptTauDecay")
        else:
            self.e3GenPromptTauDecay_branch.SetAddress(<void*>&self.e3GenPromptTauDecay_value)

        #print "making e3GenPt"
        self.e3GenPt_branch = the_tree.GetBranch("e3GenPt")
        #if not self.e3GenPt_branch and "e3GenPt" not in self.complained:
        if not self.e3GenPt_branch and "e3GenPt":
            warnings.warn( "EEETree: Expected branch e3GenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenPt")
        else:
            self.e3GenPt_branch.SetAddress(<void*>&self.e3GenPt_value)

        #print "making e3GenTauDecay"
        self.e3GenTauDecay_branch = the_tree.GetBranch("e3GenTauDecay")
        #if not self.e3GenTauDecay_branch and "e3GenTauDecay" not in self.complained:
        if not self.e3GenTauDecay_branch and "e3GenTauDecay":
            warnings.warn( "EEETree: Expected branch e3GenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenTauDecay")
        else:
            self.e3GenTauDecay_branch.SetAddress(<void*>&self.e3GenTauDecay_value)

        #print "making e3GenVZ"
        self.e3GenVZ_branch = the_tree.GetBranch("e3GenVZ")
        #if not self.e3GenVZ_branch and "e3GenVZ" not in self.complained:
        if not self.e3GenVZ_branch and "e3GenVZ":
            warnings.warn( "EEETree: Expected branch e3GenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenVZ")
        else:
            self.e3GenVZ_branch.SetAddress(<void*>&self.e3GenVZ_value)

        #print "making e3GenVtxPVMatch"
        self.e3GenVtxPVMatch_branch = the_tree.GetBranch("e3GenVtxPVMatch")
        #if not self.e3GenVtxPVMatch_branch and "e3GenVtxPVMatch" not in self.complained:
        if not self.e3GenVtxPVMatch_branch and "e3GenVtxPVMatch":
            warnings.warn( "EEETree: Expected branch e3GenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3GenVtxPVMatch")
        else:
            self.e3GenVtxPVMatch_branch.SetAddress(<void*>&self.e3GenVtxPVMatch_value)

        #print "making e3HadronicDepth1OverEm"
        self.e3HadronicDepth1OverEm_branch = the_tree.GetBranch("e3HadronicDepth1OverEm")
        #if not self.e3HadronicDepth1OverEm_branch and "e3HadronicDepth1OverEm" not in self.complained:
        if not self.e3HadronicDepth1OverEm_branch and "e3HadronicDepth1OverEm":
            warnings.warn( "EEETree: Expected branch e3HadronicDepth1OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3HadronicDepth1OverEm")
        else:
            self.e3HadronicDepth1OverEm_branch.SetAddress(<void*>&self.e3HadronicDepth1OverEm_value)

        #print "making e3HadronicDepth2OverEm"
        self.e3HadronicDepth2OverEm_branch = the_tree.GetBranch("e3HadronicDepth2OverEm")
        #if not self.e3HadronicDepth2OverEm_branch and "e3HadronicDepth2OverEm" not in self.complained:
        if not self.e3HadronicDepth2OverEm_branch and "e3HadronicDepth2OverEm":
            warnings.warn( "EEETree: Expected branch e3HadronicDepth2OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3HadronicDepth2OverEm")
        else:
            self.e3HadronicDepth2OverEm_branch.SetAddress(<void*>&self.e3HadronicDepth2OverEm_value)

        #print "making e3HadronicOverEM"
        self.e3HadronicOverEM_branch = the_tree.GetBranch("e3HadronicOverEM")
        #if not self.e3HadronicOverEM_branch and "e3HadronicOverEM" not in self.complained:
        if not self.e3HadronicOverEM_branch and "e3HadronicOverEM":
            warnings.warn( "EEETree: Expected branch e3HadronicOverEM does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3HadronicOverEM")
        else:
            self.e3HadronicOverEM_branch.SetAddress(<void*>&self.e3HadronicOverEM_value)

        #print "making e3HcalIsoDR03"
        self.e3HcalIsoDR03_branch = the_tree.GetBranch("e3HcalIsoDR03")
        #if not self.e3HcalIsoDR03_branch and "e3HcalIsoDR03" not in self.complained:
        if not self.e3HcalIsoDR03_branch and "e3HcalIsoDR03":
            warnings.warn( "EEETree: Expected branch e3HcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3HcalIsoDR03")
        else:
            self.e3HcalIsoDR03_branch.SetAddress(<void*>&self.e3HcalIsoDR03_value)

        #print "making e3IP3D"
        self.e3IP3D_branch = the_tree.GetBranch("e3IP3D")
        #if not self.e3IP3D_branch and "e3IP3D" not in self.complained:
        if not self.e3IP3D_branch and "e3IP3D":
            warnings.warn( "EEETree: Expected branch e3IP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3IP3D")
        else:
            self.e3IP3D_branch.SetAddress(<void*>&self.e3IP3D_value)

        #print "making e3IP3DErr"
        self.e3IP3DErr_branch = the_tree.GetBranch("e3IP3DErr")
        #if not self.e3IP3DErr_branch and "e3IP3DErr" not in self.complained:
        if not self.e3IP3DErr_branch and "e3IP3DErr":
            warnings.warn( "EEETree: Expected branch e3IP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3IP3DErr")
        else:
            self.e3IP3DErr_branch.SetAddress(<void*>&self.e3IP3DErr_value)

        #print "making e3JetArea"
        self.e3JetArea_branch = the_tree.GetBranch("e3JetArea")
        #if not self.e3JetArea_branch and "e3JetArea" not in self.complained:
        if not self.e3JetArea_branch and "e3JetArea":
            warnings.warn( "EEETree: Expected branch e3JetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetArea")
        else:
            self.e3JetArea_branch.SetAddress(<void*>&self.e3JetArea_value)

        #print "making e3JetBtag"
        self.e3JetBtag_branch = the_tree.GetBranch("e3JetBtag")
        #if not self.e3JetBtag_branch and "e3JetBtag" not in self.complained:
        if not self.e3JetBtag_branch and "e3JetBtag":
            warnings.warn( "EEETree: Expected branch e3JetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetBtag")
        else:
            self.e3JetBtag_branch.SetAddress(<void*>&self.e3JetBtag_value)

        #print "making e3JetEtaEtaMoment"
        self.e3JetEtaEtaMoment_branch = the_tree.GetBranch("e3JetEtaEtaMoment")
        #if not self.e3JetEtaEtaMoment_branch and "e3JetEtaEtaMoment" not in self.complained:
        if not self.e3JetEtaEtaMoment_branch and "e3JetEtaEtaMoment":
            warnings.warn( "EEETree: Expected branch e3JetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetEtaEtaMoment")
        else:
            self.e3JetEtaEtaMoment_branch.SetAddress(<void*>&self.e3JetEtaEtaMoment_value)

        #print "making e3JetEtaPhiMoment"
        self.e3JetEtaPhiMoment_branch = the_tree.GetBranch("e3JetEtaPhiMoment")
        #if not self.e3JetEtaPhiMoment_branch and "e3JetEtaPhiMoment" not in self.complained:
        if not self.e3JetEtaPhiMoment_branch and "e3JetEtaPhiMoment":
            warnings.warn( "EEETree: Expected branch e3JetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetEtaPhiMoment")
        else:
            self.e3JetEtaPhiMoment_branch.SetAddress(<void*>&self.e3JetEtaPhiMoment_value)

        #print "making e3JetEtaPhiSpread"
        self.e3JetEtaPhiSpread_branch = the_tree.GetBranch("e3JetEtaPhiSpread")
        #if not self.e3JetEtaPhiSpread_branch and "e3JetEtaPhiSpread" not in self.complained:
        if not self.e3JetEtaPhiSpread_branch and "e3JetEtaPhiSpread":
            warnings.warn( "EEETree: Expected branch e3JetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetEtaPhiSpread")
        else:
            self.e3JetEtaPhiSpread_branch.SetAddress(<void*>&self.e3JetEtaPhiSpread_value)

        #print "making e3JetPFCISVBtag"
        self.e3JetPFCISVBtag_branch = the_tree.GetBranch("e3JetPFCISVBtag")
        #if not self.e3JetPFCISVBtag_branch and "e3JetPFCISVBtag" not in self.complained:
        if not self.e3JetPFCISVBtag_branch and "e3JetPFCISVBtag":
            warnings.warn( "EEETree: Expected branch e3JetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetPFCISVBtag")
        else:
            self.e3JetPFCISVBtag_branch.SetAddress(<void*>&self.e3JetPFCISVBtag_value)

        #print "making e3JetPartonFlavour"
        self.e3JetPartonFlavour_branch = the_tree.GetBranch("e3JetPartonFlavour")
        #if not self.e3JetPartonFlavour_branch and "e3JetPartonFlavour" not in self.complained:
        if not self.e3JetPartonFlavour_branch and "e3JetPartonFlavour":
            warnings.warn( "EEETree: Expected branch e3JetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetPartonFlavour")
        else:
            self.e3JetPartonFlavour_branch.SetAddress(<void*>&self.e3JetPartonFlavour_value)

        #print "making e3JetPhiPhiMoment"
        self.e3JetPhiPhiMoment_branch = the_tree.GetBranch("e3JetPhiPhiMoment")
        #if not self.e3JetPhiPhiMoment_branch and "e3JetPhiPhiMoment" not in self.complained:
        if not self.e3JetPhiPhiMoment_branch and "e3JetPhiPhiMoment":
            warnings.warn( "EEETree: Expected branch e3JetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetPhiPhiMoment")
        else:
            self.e3JetPhiPhiMoment_branch.SetAddress(<void*>&self.e3JetPhiPhiMoment_value)

        #print "making e3JetPt"
        self.e3JetPt_branch = the_tree.GetBranch("e3JetPt")
        #if not self.e3JetPt_branch and "e3JetPt" not in self.complained:
        if not self.e3JetPt_branch and "e3JetPt":
            warnings.warn( "EEETree: Expected branch e3JetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3JetPt")
        else:
            self.e3JetPt_branch.SetAddress(<void*>&self.e3JetPt_value)

        #print "making e3LowestMll"
        self.e3LowestMll_branch = the_tree.GetBranch("e3LowestMll")
        #if not self.e3LowestMll_branch and "e3LowestMll" not in self.complained:
        if not self.e3LowestMll_branch and "e3LowestMll":
            warnings.warn( "EEETree: Expected branch e3LowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3LowestMll")
        else:
            self.e3LowestMll_branch.SetAddress(<void*>&self.e3LowestMll_value)

        #print "making e3MVANonTrigCategory"
        self.e3MVANonTrigCategory_branch = the_tree.GetBranch("e3MVANonTrigCategory")
        #if not self.e3MVANonTrigCategory_branch and "e3MVANonTrigCategory" not in self.complained:
        if not self.e3MVANonTrigCategory_branch and "e3MVANonTrigCategory":
            warnings.warn( "EEETree: Expected branch e3MVANonTrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVANonTrigCategory")
        else:
            self.e3MVANonTrigCategory_branch.SetAddress(<void*>&self.e3MVANonTrigCategory_value)

        #print "making e3MVANonTrigID"
        self.e3MVANonTrigID_branch = the_tree.GetBranch("e3MVANonTrigID")
        #if not self.e3MVANonTrigID_branch and "e3MVANonTrigID" not in self.complained:
        if not self.e3MVANonTrigID_branch and "e3MVANonTrigID":
            warnings.warn( "EEETree: Expected branch e3MVANonTrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVANonTrigID")
        else:
            self.e3MVANonTrigID_branch.SetAddress(<void*>&self.e3MVANonTrigID_value)

        #print "making e3MVANonTrigWP80"
        self.e3MVANonTrigWP80_branch = the_tree.GetBranch("e3MVANonTrigWP80")
        #if not self.e3MVANonTrigWP80_branch and "e3MVANonTrigWP80" not in self.complained:
        if not self.e3MVANonTrigWP80_branch and "e3MVANonTrigWP80":
            warnings.warn( "EEETree: Expected branch e3MVANonTrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVANonTrigWP80")
        else:
            self.e3MVANonTrigWP80_branch.SetAddress(<void*>&self.e3MVANonTrigWP80_value)

        #print "making e3MVANonTrigWP90"
        self.e3MVANonTrigWP90_branch = the_tree.GetBranch("e3MVANonTrigWP90")
        #if not self.e3MVANonTrigWP90_branch and "e3MVANonTrigWP90" not in self.complained:
        if not self.e3MVANonTrigWP90_branch and "e3MVANonTrigWP90":
            warnings.warn( "EEETree: Expected branch e3MVANonTrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVANonTrigWP90")
        else:
            self.e3MVANonTrigWP90_branch.SetAddress(<void*>&self.e3MVANonTrigWP90_value)

        #print "making e3MVATrigCategory"
        self.e3MVATrigCategory_branch = the_tree.GetBranch("e3MVATrigCategory")
        #if not self.e3MVATrigCategory_branch and "e3MVATrigCategory" not in self.complained:
        if not self.e3MVATrigCategory_branch and "e3MVATrigCategory":
            warnings.warn( "EEETree: Expected branch e3MVATrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVATrigCategory")
        else:
            self.e3MVATrigCategory_branch.SetAddress(<void*>&self.e3MVATrigCategory_value)

        #print "making e3MVATrigID"
        self.e3MVATrigID_branch = the_tree.GetBranch("e3MVATrigID")
        #if not self.e3MVATrigID_branch and "e3MVATrigID" not in self.complained:
        if not self.e3MVATrigID_branch and "e3MVATrigID":
            warnings.warn( "EEETree: Expected branch e3MVATrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVATrigID")
        else:
            self.e3MVATrigID_branch.SetAddress(<void*>&self.e3MVATrigID_value)

        #print "making e3MVATrigWP80"
        self.e3MVATrigWP80_branch = the_tree.GetBranch("e3MVATrigWP80")
        #if not self.e3MVATrigWP80_branch and "e3MVATrigWP80" not in self.complained:
        if not self.e3MVATrigWP80_branch and "e3MVATrigWP80":
            warnings.warn( "EEETree: Expected branch e3MVATrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVATrigWP80")
        else:
            self.e3MVATrigWP80_branch.SetAddress(<void*>&self.e3MVATrigWP80_value)

        #print "making e3MVATrigWP90"
        self.e3MVATrigWP90_branch = the_tree.GetBranch("e3MVATrigWP90")
        #if not self.e3MVATrigWP90_branch and "e3MVATrigWP90" not in self.complained:
        if not self.e3MVATrigWP90_branch and "e3MVATrigWP90":
            warnings.warn( "EEETree: Expected branch e3MVATrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MVATrigWP90")
        else:
            self.e3MVATrigWP90_branch.SetAddress(<void*>&self.e3MVATrigWP90_value)

        #print "making e3Mass"
        self.e3Mass_branch = the_tree.GetBranch("e3Mass")
        #if not self.e3Mass_branch and "e3Mass" not in self.complained:
        if not self.e3Mass_branch and "e3Mass":
            warnings.warn( "EEETree: Expected branch e3Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Mass")
        else:
            self.e3Mass_branch.SetAddress(<void*>&self.e3Mass_value)

        #print "making e3MatchesDoubleE"
        self.e3MatchesDoubleE_branch = the_tree.GetBranch("e3MatchesDoubleE")
        #if not self.e3MatchesDoubleE_branch and "e3MatchesDoubleE" not in self.complained:
        if not self.e3MatchesDoubleE_branch and "e3MatchesDoubleE":
            warnings.warn( "EEETree: Expected branch e3MatchesDoubleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesDoubleE")
        else:
            self.e3MatchesDoubleE_branch.SetAddress(<void*>&self.e3MatchesDoubleE_value)

        #print "making e3MatchesDoubleESingleMu"
        self.e3MatchesDoubleESingleMu_branch = the_tree.GetBranch("e3MatchesDoubleESingleMu")
        #if not self.e3MatchesDoubleESingleMu_branch and "e3MatchesDoubleESingleMu" not in self.complained:
        if not self.e3MatchesDoubleESingleMu_branch and "e3MatchesDoubleESingleMu":
            warnings.warn( "EEETree: Expected branch e3MatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesDoubleESingleMu")
        else:
            self.e3MatchesDoubleESingleMu_branch.SetAddress(<void*>&self.e3MatchesDoubleESingleMu_value)

        #print "making e3MatchesDoubleMuSingleE"
        self.e3MatchesDoubleMuSingleE_branch = the_tree.GetBranch("e3MatchesDoubleMuSingleE")
        #if not self.e3MatchesDoubleMuSingleE_branch and "e3MatchesDoubleMuSingleE" not in self.complained:
        if not self.e3MatchesDoubleMuSingleE_branch and "e3MatchesDoubleMuSingleE":
            warnings.warn( "EEETree: Expected branch e3MatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesDoubleMuSingleE")
        else:
            self.e3MatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.e3MatchesDoubleMuSingleE_value)

        #print "making e3MatchesSingleE"
        self.e3MatchesSingleE_branch = the_tree.GetBranch("e3MatchesSingleE")
        #if not self.e3MatchesSingleE_branch and "e3MatchesSingleE" not in self.complained:
        if not self.e3MatchesSingleE_branch and "e3MatchesSingleE":
            warnings.warn( "EEETree: Expected branch e3MatchesSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesSingleE")
        else:
            self.e3MatchesSingleE_branch.SetAddress(<void*>&self.e3MatchesSingleE_value)

        #print "making e3MatchesSingleESingleMu"
        self.e3MatchesSingleESingleMu_branch = the_tree.GetBranch("e3MatchesSingleESingleMu")
        #if not self.e3MatchesSingleESingleMu_branch and "e3MatchesSingleESingleMu" not in self.complained:
        if not self.e3MatchesSingleESingleMu_branch and "e3MatchesSingleESingleMu":
            warnings.warn( "EEETree: Expected branch e3MatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesSingleESingleMu")
        else:
            self.e3MatchesSingleESingleMu_branch.SetAddress(<void*>&self.e3MatchesSingleESingleMu_value)

        #print "making e3MatchesSingleE_leg1"
        self.e3MatchesSingleE_leg1_branch = the_tree.GetBranch("e3MatchesSingleE_leg1")
        #if not self.e3MatchesSingleE_leg1_branch and "e3MatchesSingleE_leg1" not in self.complained:
        if not self.e3MatchesSingleE_leg1_branch and "e3MatchesSingleE_leg1":
            warnings.warn( "EEETree: Expected branch e3MatchesSingleE_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesSingleE_leg1")
        else:
            self.e3MatchesSingleE_leg1_branch.SetAddress(<void*>&self.e3MatchesSingleE_leg1_value)

        #print "making e3MatchesSingleE_leg2"
        self.e3MatchesSingleE_leg2_branch = the_tree.GetBranch("e3MatchesSingleE_leg2")
        #if not self.e3MatchesSingleE_leg2_branch and "e3MatchesSingleE_leg2" not in self.complained:
        if not self.e3MatchesSingleE_leg2_branch and "e3MatchesSingleE_leg2":
            warnings.warn( "EEETree: Expected branch e3MatchesSingleE_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesSingleE_leg2")
        else:
            self.e3MatchesSingleE_leg2_branch.SetAddress(<void*>&self.e3MatchesSingleE_leg2_value)

        #print "making e3MatchesSingleMuSingleE"
        self.e3MatchesSingleMuSingleE_branch = the_tree.GetBranch("e3MatchesSingleMuSingleE")
        #if not self.e3MatchesSingleMuSingleE_branch and "e3MatchesSingleMuSingleE" not in self.complained:
        if not self.e3MatchesSingleMuSingleE_branch and "e3MatchesSingleMuSingleE":
            warnings.warn( "EEETree: Expected branch e3MatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesSingleMuSingleE")
        else:
            self.e3MatchesSingleMuSingleE_branch.SetAddress(<void*>&self.e3MatchesSingleMuSingleE_value)

        #print "making e3MatchesTripleE"
        self.e3MatchesTripleE_branch = the_tree.GetBranch("e3MatchesTripleE")
        #if not self.e3MatchesTripleE_branch and "e3MatchesTripleE" not in self.complained:
        if not self.e3MatchesTripleE_branch and "e3MatchesTripleE":
            warnings.warn( "EEETree: Expected branch e3MatchesTripleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MatchesTripleE")
        else:
            self.e3MatchesTripleE_branch.SetAddress(<void*>&self.e3MatchesTripleE_value)

        #print "making e3MissingHits"
        self.e3MissingHits_branch = the_tree.GetBranch("e3MissingHits")
        #if not self.e3MissingHits_branch and "e3MissingHits" not in self.complained:
        if not self.e3MissingHits_branch and "e3MissingHits":
            warnings.warn( "EEETree: Expected branch e3MissingHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MissingHits")
        else:
            self.e3MissingHits_branch.SetAddress(<void*>&self.e3MissingHits_value)

        #print "making e3MtToPfMet_ElectronEnDown"
        self.e3MtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("e3MtToPfMet_ElectronEnDown")
        #if not self.e3MtToPfMet_ElectronEnDown_branch and "e3MtToPfMet_ElectronEnDown" not in self.complained:
        if not self.e3MtToPfMet_ElectronEnDown_branch and "e3MtToPfMet_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_ElectronEnDown")
        else:
            self.e3MtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.e3MtToPfMet_ElectronEnDown_value)

        #print "making e3MtToPfMet_ElectronEnUp"
        self.e3MtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("e3MtToPfMet_ElectronEnUp")
        #if not self.e3MtToPfMet_ElectronEnUp_branch and "e3MtToPfMet_ElectronEnUp" not in self.complained:
        if not self.e3MtToPfMet_ElectronEnUp_branch and "e3MtToPfMet_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_ElectronEnUp")
        else:
            self.e3MtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.e3MtToPfMet_ElectronEnUp_value)

        #print "making e3MtToPfMet_JetEnDown"
        self.e3MtToPfMet_JetEnDown_branch = the_tree.GetBranch("e3MtToPfMet_JetEnDown")
        #if not self.e3MtToPfMet_JetEnDown_branch and "e3MtToPfMet_JetEnDown" not in self.complained:
        if not self.e3MtToPfMet_JetEnDown_branch and "e3MtToPfMet_JetEnDown":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_JetEnDown")
        else:
            self.e3MtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.e3MtToPfMet_JetEnDown_value)

        #print "making e3MtToPfMet_JetEnUp"
        self.e3MtToPfMet_JetEnUp_branch = the_tree.GetBranch("e3MtToPfMet_JetEnUp")
        #if not self.e3MtToPfMet_JetEnUp_branch and "e3MtToPfMet_JetEnUp" not in self.complained:
        if not self.e3MtToPfMet_JetEnUp_branch and "e3MtToPfMet_JetEnUp":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_JetEnUp")
        else:
            self.e3MtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.e3MtToPfMet_JetEnUp_value)

        #print "making e3MtToPfMet_JetResDown"
        self.e3MtToPfMet_JetResDown_branch = the_tree.GetBranch("e3MtToPfMet_JetResDown")
        #if not self.e3MtToPfMet_JetResDown_branch and "e3MtToPfMet_JetResDown" not in self.complained:
        if not self.e3MtToPfMet_JetResDown_branch and "e3MtToPfMet_JetResDown":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_JetResDown")
        else:
            self.e3MtToPfMet_JetResDown_branch.SetAddress(<void*>&self.e3MtToPfMet_JetResDown_value)

        #print "making e3MtToPfMet_JetResUp"
        self.e3MtToPfMet_JetResUp_branch = the_tree.GetBranch("e3MtToPfMet_JetResUp")
        #if not self.e3MtToPfMet_JetResUp_branch and "e3MtToPfMet_JetResUp" not in self.complained:
        if not self.e3MtToPfMet_JetResUp_branch and "e3MtToPfMet_JetResUp":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_JetResUp")
        else:
            self.e3MtToPfMet_JetResUp_branch.SetAddress(<void*>&self.e3MtToPfMet_JetResUp_value)

        #print "making e3MtToPfMet_MuonEnDown"
        self.e3MtToPfMet_MuonEnDown_branch = the_tree.GetBranch("e3MtToPfMet_MuonEnDown")
        #if not self.e3MtToPfMet_MuonEnDown_branch and "e3MtToPfMet_MuonEnDown" not in self.complained:
        if not self.e3MtToPfMet_MuonEnDown_branch and "e3MtToPfMet_MuonEnDown":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_MuonEnDown")
        else:
            self.e3MtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.e3MtToPfMet_MuonEnDown_value)

        #print "making e3MtToPfMet_MuonEnUp"
        self.e3MtToPfMet_MuonEnUp_branch = the_tree.GetBranch("e3MtToPfMet_MuonEnUp")
        #if not self.e3MtToPfMet_MuonEnUp_branch and "e3MtToPfMet_MuonEnUp" not in self.complained:
        if not self.e3MtToPfMet_MuonEnUp_branch and "e3MtToPfMet_MuonEnUp":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_MuonEnUp")
        else:
            self.e3MtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.e3MtToPfMet_MuonEnUp_value)

        #print "making e3MtToPfMet_PhotonEnDown"
        self.e3MtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("e3MtToPfMet_PhotonEnDown")
        #if not self.e3MtToPfMet_PhotonEnDown_branch and "e3MtToPfMet_PhotonEnDown" not in self.complained:
        if not self.e3MtToPfMet_PhotonEnDown_branch and "e3MtToPfMet_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_PhotonEnDown")
        else:
            self.e3MtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.e3MtToPfMet_PhotonEnDown_value)

        #print "making e3MtToPfMet_PhotonEnUp"
        self.e3MtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("e3MtToPfMet_PhotonEnUp")
        #if not self.e3MtToPfMet_PhotonEnUp_branch and "e3MtToPfMet_PhotonEnUp" not in self.complained:
        if not self.e3MtToPfMet_PhotonEnUp_branch and "e3MtToPfMet_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_PhotonEnUp")
        else:
            self.e3MtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.e3MtToPfMet_PhotonEnUp_value)

        #print "making e3MtToPfMet_Raw"
        self.e3MtToPfMet_Raw_branch = the_tree.GetBranch("e3MtToPfMet_Raw")
        #if not self.e3MtToPfMet_Raw_branch and "e3MtToPfMet_Raw" not in self.complained:
        if not self.e3MtToPfMet_Raw_branch and "e3MtToPfMet_Raw":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_Raw")
        else:
            self.e3MtToPfMet_Raw_branch.SetAddress(<void*>&self.e3MtToPfMet_Raw_value)

        #print "making e3MtToPfMet_TauEnDown"
        self.e3MtToPfMet_TauEnDown_branch = the_tree.GetBranch("e3MtToPfMet_TauEnDown")
        #if not self.e3MtToPfMet_TauEnDown_branch and "e3MtToPfMet_TauEnDown" not in self.complained:
        if not self.e3MtToPfMet_TauEnDown_branch and "e3MtToPfMet_TauEnDown":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_TauEnDown")
        else:
            self.e3MtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.e3MtToPfMet_TauEnDown_value)

        #print "making e3MtToPfMet_TauEnUp"
        self.e3MtToPfMet_TauEnUp_branch = the_tree.GetBranch("e3MtToPfMet_TauEnUp")
        #if not self.e3MtToPfMet_TauEnUp_branch and "e3MtToPfMet_TauEnUp" not in self.complained:
        if not self.e3MtToPfMet_TauEnUp_branch and "e3MtToPfMet_TauEnUp":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_TauEnUp")
        else:
            self.e3MtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.e3MtToPfMet_TauEnUp_value)

        #print "making e3MtToPfMet_UnclusteredEnDown"
        self.e3MtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("e3MtToPfMet_UnclusteredEnDown")
        #if not self.e3MtToPfMet_UnclusteredEnDown_branch and "e3MtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.e3MtToPfMet_UnclusteredEnDown_branch and "e3MtToPfMet_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_UnclusteredEnDown")
        else:
            self.e3MtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.e3MtToPfMet_UnclusteredEnDown_value)

        #print "making e3MtToPfMet_UnclusteredEnUp"
        self.e3MtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("e3MtToPfMet_UnclusteredEnUp")
        #if not self.e3MtToPfMet_UnclusteredEnUp_branch and "e3MtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.e3MtToPfMet_UnclusteredEnUp_branch and "e3MtToPfMet_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_UnclusteredEnUp")
        else:
            self.e3MtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.e3MtToPfMet_UnclusteredEnUp_value)

        #print "making e3MtToPfMet_type1"
        self.e3MtToPfMet_type1_branch = the_tree.GetBranch("e3MtToPfMet_type1")
        #if not self.e3MtToPfMet_type1_branch and "e3MtToPfMet_type1" not in self.complained:
        if not self.e3MtToPfMet_type1_branch and "e3MtToPfMet_type1":
            warnings.warn( "EEETree: Expected branch e3MtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3MtToPfMet_type1")
        else:
            self.e3MtToPfMet_type1_branch.SetAddress(<void*>&self.e3MtToPfMet_type1_value)

        #print "making e3NearMuonVeto"
        self.e3NearMuonVeto_branch = the_tree.GetBranch("e3NearMuonVeto")
        #if not self.e3NearMuonVeto_branch and "e3NearMuonVeto" not in self.complained:
        if not self.e3NearMuonVeto_branch and "e3NearMuonVeto":
            warnings.warn( "EEETree: Expected branch e3NearMuonVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3NearMuonVeto")
        else:
            self.e3NearMuonVeto_branch.SetAddress(<void*>&self.e3NearMuonVeto_value)

        #print "making e3NearestMuonDR"
        self.e3NearestMuonDR_branch = the_tree.GetBranch("e3NearestMuonDR")
        #if not self.e3NearestMuonDR_branch and "e3NearestMuonDR" not in self.complained:
        if not self.e3NearestMuonDR_branch and "e3NearestMuonDR":
            warnings.warn( "EEETree: Expected branch e3NearestMuonDR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3NearestMuonDR")
        else:
            self.e3NearestMuonDR_branch.SetAddress(<void*>&self.e3NearestMuonDR_value)

        #print "making e3NearestZMass"
        self.e3NearestZMass_branch = the_tree.GetBranch("e3NearestZMass")
        #if not self.e3NearestZMass_branch and "e3NearestZMass" not in self.complained:
        if not self.e3NearestZMass_branch and "e3NearestZMass":
            warnings.warn( "EEETree: Expected branch e3NearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3NearestZMass")
        else:
            self.e3NearestZMass_branch.SetAddress(<void*>&self.e3NearestZMass_value)

        #print "making e3PFChargedIso"
        self.e3PFChargedIso_branch = the_tree.GetBranch("e3PFChargedIso")
        #if not self.e3PFChargedIso_branch and "e3PFChargedIso" not in self.complained:
        if not self.e3PFChargedIso_branch and "e3PFChargedIso":
            warnings.warn( "EEETree: Expected branch e3PFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3PFChargedIso")
        else:
            self.e3PFChargedIso_branch.SetAddress(<void*>&self.e3PFChargedIso_value)

        #print "making e3PFNeutralIso"
        self.e3PFNeutralIso_branch = the_tree.GetBranch("e3PFNeutralIso")
        #if not self.e3PFNeutralIso_branch and "e3PFNeutralIso" not in self.complained:
        if not self.e3PFNeutralIso_branch and "e3PFNeutralIso":
            warnings.warn( "EEETree: Expected branch e3PFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3PFNeutralIso")
        else:
            self.e3PFNeutralIso_branch.SetAddress(<void*>&self.e3PFNeutralIso_value)

        #print "making e3PFPUChargedIso"
        self.e3PFPUChargedIso_branch = the_tree.GetBranch("e3PFPUChargedIso")
        #if not self.e3PFPUChargedIso_branch and "e3PFPUChargedIso" not in self.complained:
        if not self.e3PFPUChargedIso_branch and "e3PFPUChargedIso":
            warnings.warn( "EEETree: Expected branch e3PFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3PFPUChargedIso")
        else:
            self.e3PFPUChargedIso_branch.SetAddress(<void*>&self.e3PFPUChargedIso_value)

        #print "making e3PFPhotonIso"
        self.e3PFPhotonIso_branch = the_tree.GetBranch("e3PFPhotonIso")
        #if not self.e3PFPhotonIso_branch and "e3PFPhotonIso" not in self.complained:
        if not self.e3PFPhotonIso_branch and "e3PFPhotonIso":
            warnings.warn( "EEETree: Expected branch e3PFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3PFPhotonIso")
        else:
            self.e3PFPhotonIso_branch.SetAddress(<void*>&self.e3PFPhotonIso_value)

        #print "making e3PVDXY"
        self.e3PVDXY_branch = the_tree.GetBranch("e3PVDXY")
        #if not self.e3PVDXY_branch and "e3PVDXY" not in self.complained:
        if not self.e3PVDXY_branch and "e3PVDXY":
            warnings.warn( "EEETree: Expected branch e3PVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3PVDXY")
        else:
            self.e3PVDXY_branch.SetAddress(<void*>&self.e3PVDXY_value)

        #print "making e3PVDZ"
        self.e3PVDZ_branch = the_tree.GetBranch("e3PVDZ")
        #if not self.e3PVDZ_branch and "e3PVDZ" not in self.complained:
        if not self.e3PVDZ_branch and "e3PVDZ":
            warnings.warn( "EEETree: Expected branch e3PVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3PVDZ")
        else:
            self.e3PVDZ_branch.SetAddress(<void*>&self.e3PVDZ_value)

        #print "making e3PassesConversionVeto"
        self.e3PassesConversionVeto_branch = the_tree.GetBranch("e3PassesConversionVeto")
        #if not self.e3PassesConversionVeto_branch and "e3PassesConversionVeto" not in self.complained:
        if not self.e3PassesConversionVeto_branch and "e3PassesConversionVeto":
            warnings.warn( "EEETree: Expected branch e3PassesConversionVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3PassesConversionVeto")
        else:
            self.e3PassesConversionVeto_branch.SetAddress(<void*>&self.e3PassesConversionVeto_value)

        #print "making e3Phi"
        self.e3Phi_branch = the_tree.GetBranch("e3Phi")
        #if not self.e3Phi_branch and "e3Phi" not in self.complained:
        if not self.e3Phi_branch and "e3Phi":
            warnings.warn( "EEETree: Expected branch e3Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Phi")
        else:
            self.e3Phi_branch.SetAddress(<void*>&self.e3Phi_value)

        #print "making e3Phi_ElectronEnDown"
        self.e3Phi_ElectronEnDown_branch = the_tree.GetBranch("e3Phi_ElectronEnDown")
        #if not self.e3Phi_ElectronEnDown_branch and "e3Phi_ElectronEnDown" not in self.complained:
        if not self.e3Phi_ElectronEnDown_branch and "e3Phi_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e3Phi_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Phi_ElectronEnDown")
        else:
            self.e3Phi_ElectronEnDown_branch.SetAddress(<void*>&self.e3Phi_ElectronEnDown_value)

        #print "making e3Phi_ElectronEnUp"
        self.e3Phi_ElectronEnUp_branch = the_tree.GetBranch("e3Phi_ElectronEnUp")
        #if not self.e3Phi_ElectronEnUp_branch and "e3Phi_ElectronEnUp" not in self.complained:
        if not self.e3Phi_ElectronEnUp_branch and "e3Phi_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e3Phi_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Phi_ElectronEnUp")
        else:
            self.e3Phi_ElectronEnUp_branch.SetAddress(<void*>&self.e3Phi_ElectronEnUp_value)

        #print "making e3Pt"
        self.e3Pt_branch = the_tree.GetBranch("e3Pt")
        #if not self.e3Pt_branch and "e3Pt" not in self.complained:
        if not self.e3Pt_branch and "e3Pt":
            warnings.warn( "EEETree: Expected branch e3Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Pt")
        else:
            self.e3Pt_branch.SetAddress(<void*>&self.e3Pt_value)

        #print "making e3Pt_ElectronEnDown"
        self.e3Pt_ElectronEnDown_branch = the_tree.GetBranch("e3Pt_ElectronEnDown")
        #if not self.e3Pt_ElectronEnDown_branch and "e3Pt_ElectronEnDown" not in self.complained:
        if not self.e3Pt_ElectronEnDown_branch and "e3Pt_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch e3Pt_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Pt_ElectronEnDown")
        else:
            self.e3Pt_ElectronEnDown_branch.SetAddress(<void*>&self.e3Pt_ElectronEnDown_value)

        #print "making e3Pt_ElectronEnUp"
        self.e3Pt_ElectronEnUp_branch = the_tree.GetBranch("e3Pt_ElectronEnUp")
        #if not self.e3Pt_ElectronEnUp_branch and "e3Pt_ElectronEnUp" not in self.complained:
        if not self.e3Pt_ElectronEnUp_branch and "e3Pt_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch e3Pt_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Pt_ElectronEnUp")
        else:
            self.e3Pt_ElectronEnUp_branch.SetAddress(<void*>&self.e3Pt_ElectronEnUp_value)

        #print "making e3Rank"
        self.e3Rank_branch = the_tree.GetBranch("e3Rank")
        #if not self.e3Rank_branch and "e3Rank" not in self.complained:
        if not self.e3Rank_branch and "e3Rank":
            warnings.warn( "EEETree: Expected branch e3Rank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Rank")
        else:
            self.e3Rank_branch.SetAddress(<void*>&self.e3Rank_value)

        #print "making e3RelIso"
        self.e3RelIso_branch = the_tree.GetBranch("e3RelIso")
        #if not self.e3RelIso_branch and "e3RelIso" not in self.complained:
        if not self.e3RelIso_branch and "e3RelIso":
            warnings.warn( "EEETree: Expected branch e3RelIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3RelIso")
        else:
            self.e3RelIso_branch.SetAddress(<void*>&self.e3RelIso_value)

        #print "making e3RelPFIsoDB"
        self.e3RelPFIsoDB_branch = the_tree.GetBranch("e3RelPFIsoDB")
        #if not self.e3RelPFIsoDB_branch and "e3RelPFIsoDB" not in self.complained:
        if not self.e3RelPFIsoDB_branch and "e3RelPFIsoDB":
            warnings.warn( "EEETree: Expected branch e3RelPFIsoDB does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3RelPFIsoDB")
        else:
            self.e3RelPFIsoDB_branch.SetAddress(<void*>&self.e3RelPFIsoDB_value)

        #print "making e3RelPFIsoRho"
        self.e3RelPFIsoRho_branch = the_tree.GetBranch("e3RelPFIsoRho")
        #if not self.e3RelPFIsoRho_branch and "e3RelPFIsoRho" not in self.complained:
        if not self.e3RelPFIsoRho_branch and "e3RelPFIsoRho":
            warnings.warn( "EEETree: Expected branch e3RelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3RelPFIsoRho")
        else:
            self.e3RelPFIsoRho_branch.SetAddress(<void*>&self.e3RelPFIsoRho_value)

        #print "making e3Rho"
        self.e3Rho_branch = the_tree.GetBranch("e3Rho")
        #if not self.e3Rho_branch and "e3Rho" not in self.complained:
        if not self.e3Rho_branch and "e3Rho":
            warnings.warn( "EEETree: Expected branch e3Rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3Rho")
        else:
            self.e3Rho_branch.SetAddress(<void*>&self.e3Rho_value)

        #print "making e3SCEnergy"
        self.e3SCEnergy_branch = the_tree.GetBranch("e3SCEnergy")
        #if not self.e3SCEnergy_branch and "e3SCEnergy" not in self.complained:
        if not self.e3SCEnergy_branch and "e3SCEnergy":
            warnings.warn( "EEETree: Expected branch e3SCEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SCEnergy")
        else:
            self.e3SCEnergy_branch.SetAddress(<void*>&self.e3SCEnergy_value)

        #print "making e3SCEta"
        self.e3SCEta_branch = the_tree.GetBranch("e3SCEta")
        #if not self.e3SCEta_branch and "e3SCEta" not in self.complained:
        if not self.e3SCEta_branch and "e3SCEta":
            warnings.warn( "EEETree: Expected branch e3SCEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SCEta")
        else:
            self.e3SCEta_branch.SetAddress(<void*>&self.e3SCEta_value)

        #print "making e3SCEtaWidth"
        self.e3SCEtaWidth_branch = the_tree.GetBranch("e3SCEtaWidth")
        #if not self.e3SCEtaWidth_branch and "e3SCEtaWidth" not in self.complained:
        if not self.e3SCEtaWidth_branch and "e3SCEtaWidth":
            warnings.warn( "EEETree: Expected branch e3SCEtaWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SCEtaWidth")
        else:
            self.e3SCEtaWidth_branch.SetAddress(<void*>&self.e3SCEtaWidth_value)

        #print "making e3SCPhi"
        self.e3SCPhi_branch = the_tree.GetBranch("e3SCPhi")
        #if not self.e3SCPhi_branch and "e3SCPhi" not in self.complained:
        if not self.e3SCPhi_branch and "e3SCPhi":
            warnings.warn( "EEETree: Expected branch e3SCPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SCPhi")
        else:
            self.e3SCPhi_branch.SetAddress(<void*>&self.e3SCPhi_value)

        #print "making e3SCPhiWidth"
        self.e3SCPhiWidth_branch = the_tree.GetBranch("e3SCPhiWidth")
        #if not self.e3SCPhiWidth_branch and "e3SCPhiWidth" not in self.complained:
        if not self.e3SCPhiWidth_branch and "e3SCPhiWidth":
            warnings.warn( "EEETree: Expected branch e3SCPhiWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SCPhiWidth")
        else:
            self.e3SCPhiWidth_branch.SetAddress(<void*>&self.e3SCPhiWidth_value)

        #print "making e3SCPreshowerEnergy"
        self.e3SCPreshowerEnergy_branch = the_tree.GetBranch("e3SCPreshowerEnergy")
        #if not self.e3SCPreshowerEnergy_branch and "e3SCPreshowerEnergy" not in self.complained:
        if not self.e3SCPreshowerEnergy_branch and "e3SCPreshowerEnergy":
            warnings.warn( "EEETree: Expected branch e3SCPreshowerEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SCPreshowerEnergy")
        else:
            self.e3SCPreshowerEnergy_branch.SetAddress(<void*>&self.e3SCPreshowerEnergy_value)

        #print "making e3SCRawEnergy"
        self.e3SCRawEnergy_branch = the_tree.GetBranch("e3SCRawEnergy")
        #if not self.e3SCRawEnergy_branch and "e3SCRawEnergy" not in self.complained:
        if not self.e3SCRawEnergy_branch and "e3SCRawEnergy":
            warnings.warn( "EEETree: Expected branch e3SCRawEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SCRawEnergy")
        else:
            self.e3SCRawEnergy_branch.SetAddress(<void*>&self.e3SCRawEnergy_value)

        #print "making e3SIP2D"
        self.e3SIP2D_branch = the_tree.GetBranch("e3SIP2D")
        #if not self.e3SIP2D_branch and "e3SIP2D" not in self.complained:
        if not self.e3SIP2D_branch and "e3SIP2D":
            warnings.warn( "EEETree: Expected branch e3SIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SIP2D")
        else:
            self.e3SIP2D_branch.SetAddress(<void*>&self.e3SIP2D_value)

        #print "making e3SIP3D"
        self.e3SIP3D_branch = the_tree.GetBranch("e3SIP3D")
        #if not self.e3SIP3D_branch and "e3SIP3D" not in self.complained:
        if not self.e3SIP3D_branch and "e3SIP3D":
            warnings.warn( "EEETree: Expected branch e3SIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SIP3D")
        else:
            self.e3SIP3D_branch.SetAddress(<void*>&self.e3SIP3D_value)

        #print "making e3SigmaIEtaIEta"
        self.e3SigmaIEtaIEta_branch = the_tree.GetBranch("e3SigmaIEtaIEta")
        #if not self.e3SigmaIEtaIEta_branch and "e3SigmaIEtaIEta" not in self.complained:
        if not self.e3SigmaIEtaIEta_branch and "e3SigmaIEtaIEta":
            warnings.warn( "EEETree: Expected branch e3SigmaIEtaIEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3SigmaIEtaIEta")
        else:
            self.e3SigmaIEtaIEta_branch.SetAddress(<void*>&self.e3SigmaIEtaIEta_value)

        #print "making e3TrkIsoDR03"
        self.e3TrkIsoDR03_branch = the_tree.GetBranch("e3TrkIsoDR03")
        #if not self.e3TrkIsoDR03_branch and "e3TrkIsoDR03" not in self.complained:
        if not self.e3TrkIsoDR03_branch and "e3TrkIsoDR03":
            warnings.warn( "EEETree: Expected branch e3TrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3TrkIsoDR03")
        else:
            self.e3TrkIsoDR03_branch.SetAddress(<void*>&self.e3TrkIsoDR03_value)

        #print "making e3VZ"
        self.e3VZ_branch = the_tree.GetBranch("e3VZ")
        #if not self.e3VZ_branch and "e3VZ" not in self.complained:
        if not self.e3VZ_branch and "e3VZ":
            warnings.warn( "EEETree: Expected branch e3VZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3VZ")
        else:
            self.e3VZ_branch.SetAddress(<void*>&self.e3VZ_value)

        #print "making e3WWLoose"
        self.e3WWLoose_branch = the_tree.GetBranch("e3WWLoose")
        #if not self.e3WWLoose_branch and "e3WWLoose" not in self.complained:
        if not self.e3WWLoose_branch and "e3WWLoose":
            warnings.warn( "EEETree: Expected branch e3WWLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3WWLoose")
        else:
            self.e3WWLoose_branch.SetAddress(<void*>&self.e3WWLoose_value)

        #print "making e3_e1_collinearmass"
        self.e3_e1_collinearmass_branch = the_tree.GetBranch("e3_e1_collinearmass")
        #if not self.e3_e1_collinearmass_branch and "e3_e1_collinearmass" not in self.complained:
        if not self.e3_e1_collinearmass_branch and "e3_e1_collinearmass":
            warnings.warn( "EEETree: Expected branch e3_e1_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e1_collinearmass")
        else:
            self.e3_e1_collinearmass_branch.SetAddress(<void*>&self.e3_e1_collinearmass_value)

        #print "making e3_e1_collinearmass_JetEnDown"
        self.e3_e1_collinearmass_JetEnDown_branch = the_tree.GetBranch("e3_e1_collinearmass_JetEnDown")
        #if not self.e3_e1_collinearmass_JetEnDown_branch and "e3_e1_collinearmass_JetEnDown" not in self.complained:
        if not self.e3_e1_collinearmass_JetEnDown_branch and "e3_e1_collinearmass_JetEnDown":
            warnings.warn( "EEETree: Expected branch e3_e1_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e1_collinearmass_JetEnDown")
        else:
            self.e3_e1_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.e3_e1_collinearmass_JetEnDown_value)

        #print "making e3_e1_collinearmass_JetEnUp"
        self.e3_e1_collinearmass_JetEnUp_branch = the_tree.GetBranch("e3_e1_collinearmass_JetEnUp")
        #if not self.e3_e1_collinearmass_JetEnUp_branch and "e3_e1_collinearmass_JetEnUp" not in self.complained:
        if not self.e3_e1_collinearmass_JetEnUp_branch and "e3_e1_collinearmass_JetEnUp":
            warnings.warn( "EEETree: Expected branch e3_e1_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e1_collinearmass_JetEnUp")
        else:
            self.e3_e1_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.e3_e1_collinearmass_JetEnUp_value)

        #print "making e3_e1_collinearmass_UnclusteredEnDown"
        self.e3_e1_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("e3_e1_collinearmass_UnclusteredEnDown")
        #if not self.e3_e1_collinearmass_UnclusteredEnDown_branch and "e3_e1_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.e3_e1_collinearmass_UnclusteredEnDown_branch and "e3_e1_collinearmass_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e3_e1_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e1_collinearmass_UnclusteredEnDown")
        else:
            self.e3_e1_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.e3_e1_collinearmass_UnclusteredEnDown_value)

        #print "making e3_e1_collinearmass_UnclusteredEnUp"
        self.e3_e1_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("e3_e1_collinearmass_UnclusteredEnUp")
        #if not self.e3_e1_collinearmass_UnclusteredEnUp_branch and "e3_e1_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.e3_e1_collinearmass_UnclusteredEnUp_branch and "e3_e1_collinearmass_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e3_e1_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e1_collinearmass_UnclusteredEnUp")
        else:
            self.e3_e1_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.e3_e1_collinearmass_UnclusteredEnUp_value)

        #print "making e3_e2_collinearmass"
        self.e3_e2_collinearmass_branch = the_tree.GetBranch("e3_e2_collinearmass")
        #if not self.e3_e2_collinearmass_branch and "e3_e2_collinearmass" not in self.complained:
        if not self.e3_e2_collinearmass_branch and "e3_e2_collinearmass":
            warnings.warn( "EEETree: Expected branch e3_e2_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e2_collinearmass")
        else:
            self.e3_e2_collinearmass_branch.SetAddress(<void*>&self.e3_e2_collinearmass_value)

        #print "making e3_e2_collinearmass_JetEnDown"
        self.e3_e2_collinearmass_JetEnDown_branch = the_tree.GetBranch("e3_e2_collinearmass_JetEnDown")
        #if not self.e3_e2_collinearmass_JetEnDown_branch and "e3_e2_collinearmass_JetEnDown" not in self.complained:
        if not self.e3_e2_collinearmass_JetEnDown_branch and "e3_e2_collinearmass_JetEnDown":
            warnings.warn( "EEETree: Expected branch e3_e2_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e2_collinearmass_JetEnDown")
        else:
            self.e3_e2_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.e3_e2_collinearmass_JetEnDown_value)

        #print "making e3_e2_collinearmass_JetEnUp"
        self.e3_e2_collinearmass_JetEnUp_branch = the_tree.GetBranch("e3_e2_collinearmass_JetEnUp")
        #if not self.e3_e2_collinearmass_JetEnUp_branch and "e3_e2_collinearmass_JetEnUp" not in self.complained:
        if not self.e3_e2_collinearmass_JetEnUp_branch and "e3_e2_collinearmass_JetEnUp":
            warnings.warn( "EEETree: Expected branch e3_e2_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e2_collinearmass_JetEnUp")
        else:
            self.e3_e2_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.e3_e2_collinearmass_JetEnUp_value)

        #print "making e3_e2_collinearmass_UnclusteredEnDown"
        self.e3_e2_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("e3_e2_collinearmass_UnclusteredEnDown")
        #if not self.e3_e2_collinearmass_UnclusteredEnDown_branch and "e3_e2_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.e3_e2_collinearmass_UnclusteredEnDown_branch and "e3_e2_collinearmass_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch e3_e2_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e2_collinearmass_UnclusteredEnDown")
        else:
            self.e3_e2_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.e3_e2_collinearmass_UnclusteredEnDown_value)

        #print "making e3_e2_collinearmass_UnclusteredEnUp"
        self.e3_e2_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("e3_e2_collinearmass_UnclusteredEnUp")
        #if not self.e3_e2_collinearmass_UnclusteredEnUp_branch and "e3_e2_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.e3_e2_collinearmass_UnclusteredEnUp_branch and "e3_e2_collinearmass_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch e3_e2_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3_e2_collinearmass_UnclusteredEnUp")
        else:
            self.e3_e2_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.e3_e2_collinearmass_UnclusteredEnUp_value)

        #print "making e3deltaEtaSuperClusterTrackAtVtx"
        self.e3deltaEtaSuperClusterTrackAtVtx_branch = the_tree.GetBranch("e3deltaEtaSuperClusterTrackAtVtx")
        #if not self.e3deltaEtaSuperClusterTrackAtVtx_branch and "e3deltaEtaSuperClusterTrackAtVtx" not in self.complained:
        if not self.e3deltaEtaSuperClusterTrackAtVtx_branch and "e3deltaEtaSuperClusterTrackAtVtx":
            warnings.warn( "EEETree: Expected branch e3deltaEtaSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3deltaEtaSuperClusterTrackAtVtx")
        else:
            self.e3deltaEtaSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.e3deltaEtaSuperClusterTrackAtVtx_value)

        #print "making e3deltaPhiSuperClusterTrackAtVtx"
        self.e3deltaPhiSuperClusterTrackAtVtx_branch = the_tree.GetBranch("e3deltaPhiSuperClusterTrackAtVtx")
        #if not self.e3deltaPhiSuperClusterTrackAtVtx_branch and "e3deltaPhiSuperClusterTrackAtVtx" not in self.complained:
        if not self.e3deltaPhiSuperClusterTrackAtVtx_branch and "e3deltaPhiSuperClusterTrackAtVtx":
            warnings.warn( "EEETree: Expected branch e3deltaPhiSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3deltaPhiSuperClusterTrackAtVtx")
        else:
            self.e3deltaPhiSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.e3deltaPhiSuperClusterTrackAtVtx_value)

        #print "making e3eSuperClusterOverP"
        self.e3eSuperClusterOverP_branch = the_tree.GetBranch("e3eSuperClusterOverP")
        #if not self.e3eSuperClusterOverP_branch and "e3eSuperClusterOverP" not in self.complained:
        if not self.e3eSuperClusterOverP_branch and "e3eSuperClusterOverP":
            warnings.warn( "EEETree: Expected branch e3eSuperClusterOverP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3eSuperClusterOverP")
        else:
            self.e3eSuperClusterOverP_branch.SetAddress(<void*>&self.e3eSuperClusterOverP_value)

        #print "making e3ecalEnergy"
        self.e3ecalEnergy_branch = the_tree.GetBranch("e3ecalEnergy")
        #if not self.e3ecalEnergy_branch and "e3ecalEnergy" not in self.complained:
        if not self.e3ecalEnergy_branch and "e3ecalEnergy":
            warnings.warn( "EEETree: Expected branch e3ecalEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3ecalEnergy")
        else:
            self.e3ecalEnergy_branch.SetAddress(<void*>&self.e3ecalEnergy_value)

        #print "making e3fBrem"
        self.e3fBrem_branch = the_tree.GetBranch("e3fBrem")
        #if not self.e3fBrem_branch and "e3fBrem" not in self.complained:
        if not self.e3fBrem_branch and "e3fBrem":
            warnings.warn( "EEETree: Expected branch e3fBrem does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3fBrem")
        else:
            self.e3fBrem_branch.SetAddress(<void*>&self.e3fBrem_value)

        #print "making e3trackMomentumAtVtxP"
        self.e3trackMomentumAtVtxP_branch = the_tree.GetBranch("e3trackMomentumAtVtxP")
        #if not self.e3trackMomentumAtVtxP_branch and "e3trackMomentumAtVtxP" not in self.complained:
        if not self.e3trackMomentumAtVtxP_branch and "e3trackMomentumAtVtxP":
            warnings.warn( "EEETree: Expected branch e3trackMomentumAtVtxP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e3trackMomentumAtVtxP")
        else:
            self.e3trackMomentumAtVtxP_branch.SetAddress(<void*>&self.e3trackMomentumAtVtxP_value)

        #print "making eVetoMVAIso"
        self.eVetoMVAIso_branch = the_tree.GetBranch("eVetoMVAIso")
        #if not self.eVetoMVAIso_branch and "eVetoMVAIso" not in self.complained:
        if not self.eVetoMVAIso_branch and "eVetoMVAIso":
            warnings.warn( "EEETree: Expected branch eVetoMVAIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eVetoMVAIso")
        else:
            self.eVetoMVAIso_branch.SetAddress(<void*>&self.eVetoMVAIso_value)

        #print "making eVetoMVAIsoVtx"
        self.eVetoMVAIsoVtx_branch = the_tree.GetBranch("eVetoMVAIsoVtx")
        #if not self.eVetoMVAIsoVtx_branch and "eVetoMVAIsoVtx" not in self.complained:
        if not self.eVetoMVAIsoVtx_branch and "eVetoMVAIsoVtx":
            warnings.warn( "EEETree: Expected branch eVetoMVAIsoVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eVetoMVAIsoVtx")
        else:
            self.eVetoMVAIsoVtx_branch.SetAddress(<void*>&self.eVetoMVAIsoVtx_value)

        #print "making evt"
        self.evt_branch = the_tree.GetBranch("evt")
        #if not self.evt_branch and "evt" not in self.complained:
        if not self.evt_branch and "evt":
            warnings.warn( "EEETree: Expected branch evt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("evt")
        else:
            self.evt_branch.SetAddress(<void*>&self.evt_value)

        #print "making genHTT"
        self.genHTT_branch = the_tree.GetBranch("genHTT")
        #if not self.genHTT_branch and "genHTT" not in self.complained:
        if not self.genHTT_branch and "genHTT":
            warnings.warn( "EEETree: Expected branch genHTT does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("genHTT")
        else:
            self.genHTT_branch.SetAddress(<void*>&self.genHTT_value)

        #print "making isGtautau"
        self.isGtautau_branch = the_tree.GetBranch("isGtautau")
        #if not self.isGtautau_branch and "isGtautau" not in self.complained:
        if not self.isGtautau_branch and "isGtautau":
            warnings.warn( "EEETree: Expected branch isGtautau does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isGtautau")
        else:
            self.isGtautau_branch.SetAddress(<void*>&self.isGtautau_value)

        #print "making isWmunu"
        self.isWmunu_branch = the_tree.GetBranch("isWmunu")
        #if not self.isWmunu_branch and "isWmunu" not in self.complained:
        if not self.isWmunu_branch and "isWmunu":
            warnings.warn( "EEETree: Expected branch isWmunu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isWmunu")
        else:
            self.isWmunu_branch.SetAddress(<void*>&self.isWmunu_value)

        #print "making isWtaunu"
        self.isWtaunu_branch = the_tree.GetBranch("isWtaunu")
        #if not self.isWtaunu_branch and "isWtaunu" not in self.complained:
        if not self.isWtaunu_branch and "isWtaunu":
            warnings.warn( "EEETree: Expected branch isWtaunu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isWtaunu")
        else:
            self.isWtaunu_branch.SetAddress(<void*>&self.isWtaunu_value)

        #print "making isZee"
        self.isZee_branch = the_tree.GetBranch("isZee")
        #if not self.isZee_branch and "isZee" not in self.complained:
        if not self.isZee_branch and "isZee":
            warnings.warn( "EEETree: Expected branch isZee does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZee")
        else:
            self.isZee_branch.SetAddress(<void*>&self.isZee_value)

        #print "making isZmumu"
        self.isZmumu_branch = the_tree.GetBranch("isZmumu")
        #if not self.isZmumu_branch and "isZmumu" not in self.complained:
        if not self.isZmumu_branch and "isZmumu":
            warnings.warn( "EEETree: Expected branch isZmumu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZmumu")
        else:
            self.isZmumu_branch.SetAddress(<void*>&self.isZmumu_value)

        #print "making isZtautau"
        self.isZtautau_branch = the_tree.GetBranch("isZtautau")
        #if not self.isZtautau_branch and "isZtautau" not in self.complained:
        if not self.isZtautau_branch and "isZtautau":
            warnings.warn( "EEETree: Expected branch isZtautau does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZtautau")
        else:
            self.isZtautau_branch.SetAddress(<void*>&self.isZtautau_value)

        #print "making isdata"
        self.isdata_branch = the_tree.GetBranch("isdata")
        #if not self.isdata_branch and "isdata" not in self.complained:
        if not self.isdata_branch and "isdata":
            warnings.warn( "EEETree: Expected branch isdata does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isdata")
        else:
            self.isdata_branch.SetAddress(<void*>&self.isdata_value)

        #print "making jet1BJetCISV"
        self.jet1BJetCISV_branch = the_tree.GetBranch("jet1BJetCISV")
        #if not self.jet1BJetCISV_branch and "jet1BJetCISV" not in self.complained:
        if not self.jet1BJetCISV_branch and "jet1BJetCISV":
            warnings.warn( "EEETree: Expected branch jet1BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1BJetCISV")
        else:
            self.jet1BJetCISV_branch.SetAddress(<void*>&self.jet1BJetCISV_value)

        #print "making jet1Eta"
        self.jet1Eta_branch = the_tree.GetBranch("jet1Eta")
        #if not self.jet1Eta_branch and "jet1Eta" not in self.complained:
        if not self.jet1Eta_branch and "jet1Eta":
            warnings.warn( "EEETree: Expected branch jet1Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1Eta")
        else:
            self.jet1Eta_branch.SetAddress(<void*>&self.jet1Eta_value)

        #print "making jet1IDLoose"
        self.jet1IDLoose_branch = the_tree.GetBranch("jet1IDLoose")
        #if not self.jet1IDLoose_branch and "jet1IDLoose" not in self.complained:
        if not self.jet1IDLoose_branch and "jet1IDLoose":
            warnings.warn( "EEETree: Expected branch jet1IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1IDLoose")
        else:
            self.jet1IDLoose_branch.SetAddress(<void*>&self.jet1IDLoose_value)

        #print "making jet1IDTight"
        self.jet1IDTight_branch = the_tree.GetBranch("jet1IDTight")
        #if not self.jet1IDTight_branch and "jet1IDTight" not in self.complained:
        if not self.jet1IDTight_branch and "jet1IDTight":
            warnings.warn( "EEETree: Expected branch jet1IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1IDTight")
        else:
            self.jet1IDTight_branch.SetAddress(<void*>&self.jet1IDTight_value)

        #print "making jet1IDTightLepVeto"
        self.jet1IDTightLepVeto_branch = the_tree.GetBranch("jet1IDTightLepVeto")
        #if not self.jet1IDTightLepVeto_branch and "jet1IDTightLepVeto" not in self.complained:
        if not self.jet1IDTightLepVeto_branch and "jet1IDTightLepVeto":
            warnings.warn( "EEETree: Expected branch jet1IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1IDTightLepVeto")
        else:
            self.jet1IDTightLepVeto_branch.SetAddress(<void*>&self.jet1IDTightLepVeto_value)

        #print "making jet1PUMVA"
        self.jet1PUMVA_branch = the_tree.GetBranch("jet1PUMVA")
        #if not self.jet1PUMVA_branch and "jet1PUMVA" not in self.complained:
        if not self.jet1PUMVA_branch and "jet1PUMVA":
            warnings.warn( "EEETree: Expected branch jet1PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1PUMVA")
        else:
            self.jet1PUMVA_branch.SetAddress(<void*>&self.jet1PUMVA_value)

        #print "making jet1Phi"
        self.jet1Phi_branch = the_tree.GetBranch("jet1Phi")
        #if not self.jet1Phi_branch and "jet1Phi" not in self.complained:
        if not self.jet1Phi_branch and "jet1Phi":
            warnings.warn( "EEETree: Expected branch jet1Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1Phi")
        else:
            self.jet1Phi_branch.SetAddress(<void*>&self.jet1Phi_value)

        #print "making jet1Pt"
        self.jet1Pt_branch = the_tree.GetBranch("jet1Pt")
        #if not self.jet1Pt_branch and "jet1Pt" not in self.complained:
        if not self.jet1Pt_branch and "jet1Pt":
            warnings.warn( "EEETree: Expected branch jet1Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1Pt")
        else:
            self.jet1Pt_branch.SetAddress(<void*>&self.jet1Pt_value)

        #print "making jet2BJetCISV"
        self.jet2BJetCISV_branch = the_tree.GetBranch("jet2BJetCISV")
        #if not self.jet2BJetCISV_branch and "jet2BJetCISV" not in self.complained:
        if not self.jet2BJetCISV_branch and "jet2BJetCISV":
            warnings.warn( "EEETree: Expected branch jet2BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2BJetCISV")
        else:
            self.jet2BJetCISV_branch.SetAddress(<void*>&self.jet2BJetCISV_value)

        #print "making jet2Eta"
        self.jet2Eta_branch = the_tree.GetBranch("jet2Eta")
        #if not self.jet2Eta_branch and "jet2Eta" not in self.complained:
        if not self.jet2Eta_branch and "jet2Eta":
            warnings.warn( "EEETree: Expected branch jet2Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2Eta")
        else:
            self.jet2Eta_branch.SetAddress(<void*>&self.jet2Eta_value)

        #print "making jet2IDLoose"
        self.jet2IDLoose_branch = the_tree.GetBranch("jet2IDLoose")
        #if not self.jet2IDLoose_branch and "jet2IDLoose" not in self.complained:
        if not self.jet2IDLoose_branch and "jet2IDLoose":
            warnings.warn( "EEETree: Expected branch jet2IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2IDLoose")
        else:
            self.jet2IDLoose_branch.SetAddress(<void*>&self.jet2IDLoose_value)

        #print "making jet2IDTight"
        self.jet2IDTight_branch = the_tree.GetBranch("jet2IDTight")
        #if not self.jet2IDTight_branch and "jet2IDTight" not in self.complained:
        if not self.jet2IDTight_branch and "jet2IDTight":
            warnings.warn( "EEETree: Expected branch jet2IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2IDTight")
        else:
            self.jet2IDTight_branch.SetAddress(<void*>&self.jet2IDTight_value)

        #print "making jet2IDTightLepVeto"
        self.jet2IDTightLepVeto_branch = the_tree.GetBranch("jet2IDTightLepVeto")
        #if not self.jet2IDTightLepVeto_branch and "jet2IDTightLepVeto" not in self.complained:
        if not self.jet2IDTightLepVeto_branch and "jet2IDTightLepVeto":
            warnings.warn( "EEETree: Expected branch jet2IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2IDTightLepVeto")
        else:
            self.jet2IDTightLepVeto_branch.SetAddress(<void*>&self.jet2IDTightLepVeto_value)

        #print "making jet2PUMVA"
        self.jet2PUMVA_branch = the_tree.GetBranch("jet2PUMVA")
        #if not self.jet2PUMVA_branch and "jet2PUMVA" not in self.complained:
        if not self.jet2PUMVA_branch and "jet2PUMVA":
            warnings.warn( "EEETree: Expected branch jet2PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2PUMVA")
        else:
            self.jet2PUMVA_branch.SetAddress(<void*>&self.jet2PUMVA_value)

        #print "making jet2Phi"
        self.jet2Phi_branch = the_tree.GetBranch("jet2Phi")
        #if not self.jet2Phi_branch and "jet2Phi" not in self.complained:
        if not self.jet2Phi_branch and "jet2Phi":
            warnings.warn( "EEETree: Expected branch jet2Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2Phi")
        else:
            self.jet2Phi_branch.SetAddress(<void*>&self.jet2Phi_value)

        #print "making jet2Pt"
        self.jet2Pt_branch = the_tree.GetBranch("jet2Pt")
        #if not self.jet2Pt_branch and "jet2Pt" not in self.complained:
        if not self.jet2Pt_branch and "jet2Pt":
            warnings.warn( "EEETree: Expected branch jet2Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2Pt")
        else:
            self.jet2Pt_branch.SetAddress(<void*>&self.jet2Pt_value)

        #print "making jet3BJetCISV"
        self.jet3BJetCISV_branch = the_tree.GetBranch("jet3BJetCISV")
        #if not self.jet3BJetCISV_branch and "jet3BJetCISV" not in self.complained:
        if not self.jet3BJetCISV_branch and "jet3BJetCISV":
            warnings.warn( "EEETree: Expected branch jet3BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3BJetCISV")
        else:
            self.jet3BJetCISV_branch.SetAddress(<void*>&self.jet3BJetCISV_value)

        #print "making jet3Eta"
        self.jet3Eta_branch = the_tree.GetBranch("jet3Eta")
        #if not self.jet3Eta_branch and "jet3Eta" not in self.complained:
        if not self.jet3Eta_branch and "jet3Eta":
            warnings.warn( "EEETree: Expected branch jet3Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3Eta")
        else:
            self.jet3Eta_branch.SetAddress(<void*>&self.jet3Eta_value)

        #print "making jet3IDLoose"
        self.jet3IDLoose_branch = the_tree.GetBranch("jet3IDLoose")
        #if not self.jet3IDLoose_branch and "jet3IDLoose" not in self.complained:
        if not self.jet3IDLoose_branch and "jet3IDLoose":
            warnings.warn( "EEETree: Expected branch jet3IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3IDLoose")
        else:
            self.jet3IDLoose_branch.SetAddress(<void*>&self.jet3IDLoose_value)

        #print "making jet3IDTight"
        self.jet3IDTight_branch = the_tree.GetBranch("jet3IDTight")
        #if not self.jet3IDTight_branch and "jet3IDTight" not in self.complained:
        if not self.jet3IDTight_branch and "jet3IDTight":
            warnings.warn( "EEETree: Expected branch jet3IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3IDTight")
        else:
            self.jet3IDTight_branch.SetAddress(<void*>&self.jet3IDTight_value)

        #print "making jet3IDTightLepVeto"
        self.jet3IDTightLepVeto_branch = the_tree.GetBranch("jet3IDTightLepVeto")
        #if not self.jet3IDTightLepVeto_branch and "jet3IDTightLepVeto" not in self.complained:
        if not self.jet3IDTightLepVeto_branch and "jet3IDTightLepVeto":
            warnings.warn( "EEETree: Expected branch jet3IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3IDTightLepVeto")
        else:
            self.jet3IDTightLepVeto_branch.SetAddress(<void*>&self.jet3IDTightLepVeto_value)

        #print "making jet3PUMVA"
        self.jet3PUMVA_branch = the_tree.GetBranch("jet3PUMVA")
        #if not self.jet3PUMVA_branch and "jet3PUMVA" not in self.complained:
        if not self.jet3PUMVA_branch and "jet3PUMVA":
            warnings.warn( "EEETree: Expected branch jet3PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3PUMVA")
        else:
            self.jet3PUMVA_branch.SetAddress(<void*>&self.jet3PUMVA_value)

        #print "making jet3Phi"
        self.jet3Phi_branch = the_tree.GetBranch("jet3Phi")
        #if not self.jet3Phi_branch and "jet3Phi" not in self.complained:
        if not self.jet3Phi_branch and "jet3Phi":
            warnings.warn( "EEETree: Expected branch jet3Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3Phi")
        else:
            self.jet3Phi_branch.SetAddress(<void*>&self.jet3Phi_value)

        #print "making jet3Pt"
        self.jet3Pt_branch = the_tree.GetBranch("jet3Pt")
        #if not self.jet3Pt_branch and "jet3Pt" not in self.complained:
        if not self.jet3Pt_branch and "jet3Pt":
            warnings.warn( "EEETree: Expected branch jet3Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3Pt")
        else:
            self.jet3Pt_branch.SetAddress(<void*>&self.jet3Pt_value)

        #print "making jet4BJetCISV"
        self.jet4BJetCISV_branch = the_tree.GetBranch("jet4BJetCISV")
        #if not self.jet4BJetCISV_branch and "jet4BJetCISV" not in self.complained:
        if not self.jet4BJetCISV_branch and "jet4BJetCISV":
            warnings.warn( "EEETree: Expected branch jet4BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4BJetCISV")
        else:
            self.jet4BJetCISV_branch.SetAddress(<void*>&self.jet4BJetCISV_value)

        #print "making jet4Eta"
        self.jet4Eta_branch = the_tree.GetBranch("jet4Eta")
        #if not self.jet4Eta_branch and "jet4Eta" not in self.complained:
        if not self.jet4Eta_branch and "jet4Eta":
            warnings.warn( "EEETree: Expected branch jet4Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4Eta")
        else:
            self.jet4Eta_branch.SetAddress(<void*>&self.jet4Eta_value)

        #print "making jet4IDLoose"
        self.jet4IDLoose_branch = the_tree.GetBranch("jet4IDLoose")
        #if not self.jet4IDLoose_branch and "jet4IDLoose" not in self.complained:
        if not self.jet4IDLoose_branch and "jet4IDLoose":
            warnings.warn( "EEETree: Expected branch jet4IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4IDLoose")
        else:
            self.jet4IDLoose_branch.SetAddress(<void*>&self.jet4IDLoose_value)

        #print "making jet4IDTight"
        self.jet4IDTight_branch = the_tree.GetBranch("jet4IDTight")
        #if not self.jet4IDTight_branch and "jet4IDTight" not in self.complained:
        if not self.jet4IDTight_branch and "jet4IDTight":
            warnings.warn( "EEETree: Expected branch jet4IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4IDTight")
        else:
            self.jet4IDTight_branch.SetAddress(<void*>&self.jet4IDTight_value)

        #print "making jet4IDTightLepVeto"
        self.jet4IDTightLepVeto_branch = the_tree.GetBranch("jet4IDTightLepVeto")
        #if not self.jet4IDTightLepVeto_branch and "jet4IDTightLepVeto" not in self.complained:
        if not self.jet4IDTightLepVeto_branch and "jet4IDTightLepVeto":
            warnings.warn( "EEETree: Expected branch jet4IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4IDTightLepVeto")
        else:
            self.jet4IDTightLepVeto_branch.SetAddress(<void*>&self.jet4IDTightLepVeto_value)

        #print "making jet4PUMVA"
        self.jet4PUMVA_branch = the_tree.GetBranch("jet4PUMVA")
        #if not self.jet4PUMVA_branch and "jet4PUMVA" not in self.complained:
        if not self.jet4PUMVA_branch and "jet4PUMVA":
            warnings.warn( "EEETree: Expected branch jet4PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4PUMVA")
        else:
            self.jet4PUMVA_branch.SetAddress(<void*>&self.jet4PUMVA_value)

        #print "making jet4Phi"
        self.jet4Phi_branch = the_tree.GetBranch("jet4Phi")
        #if not self.jet4Phi_branch and "jet4Phi" not in self.complained:
        if not self.jet4Phi_branch and "jet4Phi":
            warnings.warn( "EEETree: Expected branch jet4Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4Phi")
        else:
            self.jet4Phi_branch.SetAddress(<void*>&self.jet4Phi_value)

        #print "making jet4Pt"
        self.jet4Pt_branch = the_tree.GetBranch("jet4Pt")
        #if not self.jet4Pt_branch and "jet4Pt" not in self.complained:
        if not self.jet4Pt_branch and "jet4Pt":
            warnings.warn( "EEETree: Expected branch jet4Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4Pt")
        else:
            self.jet4Pt_branch.SetAddress(<void*>&self.jet4Pt_value)

        #print "making jet5BJetCISV"
        self.jet5BJetCISV_branch = the_tree.GetBranch("jet5BJetCISV")
        #if not self.jet5BJetCISV_branch and "jet5BJetCISV" not in self.complained:
        if not self.jet5BJetCISV_branch and "jet5BJetCISV":
            warnings.warn( "EEETree: Expected branch jet5BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5BJetCISV")
        else:
            self.jet5BJetCISV_branch.SetAddress(<void*>&self.jet5BJetCISV_value)

        #print "making jet5Eta"
        self.jet5Eta_branch = the_tree.GetBranch("jet5Eta")
        #if not self.jet5Eta_branch and "jet5Eta" not in self.complained:
        if not self.jet5Eta_branch and "jet5Eta":
            warnings.warn( "EEETree: Expected branch jet5Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5Eta")
        else:
            self.jet5Eta_branch.SetAddress(<void*>&self.jet5Eta_value)

        #print "making jet5IDLoose"
        self.jet5IDLoose_branch = the_tree.GetBranch("jet5IDLoose")
        #if not self.jet5IDLoose_branch and "jet5IDLoose" not in self.complained:
        if not self.jet5IDLoose_branch and "jet5IDLoose":
            warnings.warn( "EEETree: Expected branch jet5IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5IDLoose")
        else:
            self.jet5IDLoose_branch.SetAddress(<void*>&self.jet5IDLoose_value)

        #print "making jet5IDTight"
        self.jet5IDTight_branch = the_tree.GetBranch("jet5IDTight")
        #if not self.jet5IDTight_branch and "jet5IDTight" not in self.complained:
        if not self.jet5IDTight_branch and "jet5IDTight":
            warnings.warn( "EEETree: Expected branch jet5IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5IDTight")
        else:
            self.jet5IDTight_branch.SetAddress(<void*>&self.jet5IDTight_value)

        #print "making jet5IDTightLepVeto"
        self.jet5IDTightLepVeto_branch = the_tree.GetBranch("jet5IDTightLepVeto")
        #if not self.jet5IDTightLepVeto_branch and "jet5IDTightLepVeto" not in self.complained:
        if not self.jet5IDTightLepVeto_branch and "jet5IDTightLepVeto":
            warnings.warn( "EEETree: Expected branch jet5IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5IDTightLepVeto")
        else:
            self.jet5IDTightLepVeto_branch.SetAddress(<void*>&self.jet5IDTightLepVeto_value)

        #print "making jet5PUMVA"
        self.jet5PUMVA_branch = the_tree.GetBranch("jet5PUMVA")
        #if not self.jet5PUMVA_branch and "jet5PUMVA" not in self.complained:
        if not self.jet5PUMVA_branch and "jet5PUMVA":
            warnings.warn( "EEETree: Expected branch jet5PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5PUMVA")
        else:
            self.jet5PUMVA_branch.SetAddress(<void*>&self.jet5PUMVA_value)

        #print "making jet5Phi"
        self.jet5Phi_branch = the_tree.GetBranch("jet5Phi")
        #if not self.jet5Phi_branch and "jet5Phi" not in self.complained:
        if not self.jet5Phi_branch and "jet5Phi":
            warnings.warn( "EEETree: Expected branch jet5Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5Phi")
        else:
            self.jet5Phi_branch.SetAddress(<void*>&self.jet5Phi_value)

        #print "making jet5Pt"
        self.jet5Pt_branch = the_tree.GetBranch("jet5Pt")
        #if not self.jet5Pt_branch and "jet5Pt" not in self.complained:
        if not self.jet5Pt_branch and "jet5Pt":
            warnings.warn( "EEETree: Expected branch jet5Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5Pt")
        else:
            self.jet5Pt_branch.SetAddress(<void*>&self.jet5Pt_value)

        #print "making jet6BJetCISV"
        self.jet6BJetCISV_branch = the_tree.GetBranch("jet6BJetCISV")
        #if not self.jet6BJetCISV_branch and "jet6BJetCISV" not in self.complained:
        if not self.jet6BJetCISV_branch and "jet6BJetCISV":
            warnings.warn( "EEETree: Expected branch jet6BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6BJetCISV")
        else:
            self.jet6BJetCISV_branch.SetAddress(<void*>&self.jet6BJetCISV_value)

        #print "making jet6Eta"
        self.jet6Eta_branch = the_tree.GetBranch("jet6Eta")
        #if not self.jet6Eta_branch and "jet6Eta" not in self.complained:
        if not self.jet6Eta_branch and "jet6Eta":
            warnings.warn( "EEETree: Expected branch jet6Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6Eta")
        else:
            self.jet6Eta_branch.SetAddress(<void*>&self.jet6Eta_value)

        #print "making jet6IDLoose"
        self.jet6IDLoose_branch = the_tree.GetBranch("jet6IDLoose")
        #if not self.jet6IDLoose_branch and "jet6IDLoose" not in self.complained:
        if not self.jet6IDLoose_branch and "jet6IDLoose":
            warnings.warn( "EEETree: Expected branch jet6IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6IDLoose")
        else:
            self.jet6IDLoose_branch.SetAddress(<void*>&self.jet6IDLoose_value)

        #print "making jet6IDTight"
        self.jet6IDTight_branch = the_tree.GetBranch("jet6IDTight")
        #if not self.jet6IDTight_branch and "jet6IDTight" not in self.complained:
        if not self.jet6IDTight_branch and "jet6IDTight":
            warnings.warn( "EEETree: Expected branch jet6IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6IDTight")
        else:
            self.jet6IDTight_branch.SetAddress(<void*>&self.jet6IDTight_value)

        #print "making jet6IDTightLepVeto"
        self.jet6IDTightLepVeto_branch = the_tree.GetBranch("jet6IDTightLepVeto")
        #if not self.jet6IDTightLepVeto_branch and "jet6IDTightLepVeto" not in self.complained:
        if not self.jet6IDTightLepVeto_branch and "jet6IDTightLepVeto":
            warnings.warn( "EEETree: Expected branch jet6IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6IDTightLepVeto")
        else:
            self.jet6IDTightLepVeto_branch.SetAddress(<void*>&self.jet6IDTightLepVeto_value)

        #print "making jet6PUMVA"
        self.jet6PUMVA_branch = the_tree.GetBranch("jet6PUMVA")
        #if not self.jet6PUMVA_branch and "jet6PUMVA" not in self.complained:
        if not self.jet6PUMVA_branch and "jet6PUMVA":
            warnings.warn( "EEETree: Expected branch jet6PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6PUMVA")
        else:
            self.jet6PUMVA_branch.SetAddress(<void*>&self.jet6PUMVA_value)

        #print "making jet6Phi"
        self.jet6Phi_branch = the_tree.GetBranch("jet6Phi")
        #if not self.jet6Phi_branch and "jet6Phi" not in self.complained:
        if not self.jet6Phi_branch and "jet6Phi":
            warnings.warn( "EEETree: Expected branch jet6Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6Phi")
        else:
            self.jet6Phi_branch.SetAddress(<void*>&self.jet6Phi_value)

        #print "making jet6Pt"
        self.jet6Pt_branch = the_tree.GetBranch("jet6Pt")
        #if not self.jet6Pt_branch and "jet6Pt" not in self.complained:
        if not self.jet6Pt_branch and "jet6Pt":
            warnings.warn( "EEETree: Expected branch jet6Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6Pt")
        else:
            self.jet6Pt_branch.SetAddress(<void*>&self.jet6Pt_value)

        #print "making jetVeto20"
        self.jetVeto20_branch = the_tree.GetBranch("jetVeto20")
        #if not self.jetVeto20_branch and "jetVeto20" not in self.complained:
        if not self.jetVeto20_branch and "jetVeto20":
            warnings.warn( "EEETree: Expected branch jetVeto20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto20")
        else:
            self.jetVeto20_branch.SetAddress(<void*>&self.jetVeto20_value)

        #print "making jetVeto20_DR05"
        self.jetVeto20_DR05_branch = the_tree.GetBranch("jetVeto20_DR05")
        #if not self.jetVeto20_DR05_branch and "jetVeto20_DR05" not in self.complained:
        if not self.jetVeto20_DR05_branch and "jetVeto20_DR05":
            warnings.warn( "EEETree: Expected branch jetVeto20_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto20_DR05")
        else:
            self.jetVeto20_DR05_branch.SetAddress(<void*>&self.jetVeto20_DR05_value)

        #print "making jetVeto30"
        self.jetVeto30_branch = the_tree.GetBranch("jetVeto30")
        #if not self.jetVeto30_branch and "jetVeto30" not in self.complained:
        if not self.jetVeto30_branch and "jetVeto30":
            warnings.warn( "EEETree: Expected branch jetVeto30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30")
        else:
            self.jetVeto30_branch.SetAddress(<void*>&self.jetVeto30_value)

        #print "making jetVeto30Eta3"
        self.jetVeto30Eta3_branch = the_tree.GetBranch("jetVeto30Eta3")
        #if not self.jetVeto30Eta3_branch and "jetVeto30Eta3" not in self.complained:
        if not self.jetVeto30Eta3_branch and "jetVeto30Eta3":
            warnings.warn( "EEETree: Expected branch jetVeto30Eta3 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3")
        else:
            self.jetVeto30Eta3_branch.SetAddress(<void*>&self.jetVeto30Eta3_value)

        #print "making jetVeto30Eta3_JetEnDown"
        self.jetVeto30Eta3_JetEnDown_branch = the_tree.GetBranch("jetVeto30Eta3_JetEnDown")
        #if not self.jetVeto30Eta3_JetEnDown_branch and "jetVeto30Eta3_JetEnDown" not in self.complained:
        if not self.jetVeto30Eta3_JetEnDown_branch and "jetVeto30Eta3_JetEnDown":
            warnings.warn( "EEETree: Expected branch jetVeto30Eta3_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3_JetEnDown")
        else:
            self.jetVeto30Eta3_JetEnDown_branch.SetAddress(<void*>&self.jetVeto30Eta3_JetEnDown_value)

        #print "making jetVeto30Eta3_JetEnUp"
        self.jetVeto30Eta3_JetEnUp_branch = the_tree.GetBranch("jetVeto30Eta3_JetEnUp")
        #if not self.jetVeto30Eta3_JetEnUp_branch and "jetVeto30Eta3_JetEnUp" not in self.complained:
        if not self.jetVeto30Eta3_JetEnUp_branch and "jetVeto30Eta3_JetEnUp":
            warnings.warn( "EEETree: Expected branch jetVeto30Eta3_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3_JetEnUp")
        else:
            self.jetVeto30Eta3_JetEnUp_branch.SetAddress(<void*>&self.jetVeto30Eta3_JetEnUp_value)

        #print "making jetVeto30_DR05"
        self.jetVeto30_DR05_branch = the_tree.GetBranch("jetVeto30_DR05")
        #if not self.jetVeto30_DR05_branch and "jetVeto30_DR05" not in self.complained:
        if not self.jetVeto30_DR05_branch and "jetVeto30_DR05":
            warnings.warn( "EEETree: Expected branch jetVeto30_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_DR05")
        else:
            self.jetVeto30_DR05_branch.SetAddress(<void*>&self.jetVeto30_DR05_value)

        #print "making jetVeto30_JetEnDown"
        self.jetVeto30_JetEnDown_branch = the_tree.GetBranch("jetVeto30_JetEnDown")
        #if not self.jetVeto30_JetEnDown_branch and "jetVeto30_JetEnDown" not in self.complained:
        if not self.jetVeto30_JetEnDown_branch and "jetVeto30_JetEnDown":
            warnings.warn( "EEETree: Expected branch jetVeto30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_JetEnDown")
        else:
            self.jetVeto30_JetEnDown_branch.SetAddress(<void*>&self.jetVeto30_JetEnDown_value)

        #print "making jetVeto30_JetEnUp"
        self.jetVeto30_JetEnUp_branch = the_tree.GetBranch("jetVeto30_JetEnUp")
        #if not self.jetVeto30_JetEnUp_branch and "jetVeto30_JetEnUp" not in self.complained:
        if not self.jetVeto30_JetEnUp_branch and "jetVeto30_JetEnUp":
            warnings.warn( "EEETree: Expected branch jetVeto30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_JetEnUp")
        else:
            self.jetVeto30_JetEnUp_branch.SetAddress(<void*>&self.jetVeto30_JetEnUp_value)

        #print "making jetVeto40"
        self.jetVeto40_branch = the_tree.GetBranch("jetVeto40")
        #if not self.jetVeto40_branch and "jetVeto40" not in self.complained:
        if not self.jetVeto40_branch and "jetVeto40":
            warnings.warn( "EEETree: Expected branch jetVeto40 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto40")
        else:
            self.jetVeto40_branch.SetAddress(<void*>&self.jetVeto40_value)

        #print "making jetVeto40_DR05"
        self.jetVeto40_DR05_branch = the_tree.GetBranch("jetVeto40_DR05")
        #if not self.jetVeto40_DR05_branch and "jetVeto40_DR05" not in self.complained:
        if not self.jetVeto40_DR05_branch and "jetVeto40_DR05":
            warnings.warn( "EEETree: Expected branch jetVeto40_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto40_DR05")
        else:
            self.jetVeto40_DR05_branch.SetAddress(<void*>&self.jetVeto40_DR05_value)

        #print "making lumi"
        self.lumi_branch = the_tree.GetBranch("lumi")
        #if not self.lumi_branch and "lumi" not in self.complained:
        if not self.lumi_branch and "lumi":
            warnings.warn( "EEETree: Expected branch lumi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("lumi")
        else:
            self.lumi_branch.SetAddress(<void*>&self.lumi_value)

        #print "making muGlbIsoVetoPt10"
        self.muGlbIsoVetoPt10_branch = the_tree.GetBranch("muGlbIsoVetoPt10")
        #if not self.muGlbIsoVetoPt10_branch and "muGlbIsoVetoPt10" not in self.complained:
        if not self.muGlbIsoVetoPt10_branch and "muGlbIsoVetoPt10":
            warnings.warn( "EEETree: Expected branch muGlbIsoVetoPt10 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muGlbIsoVetoPt10")
        else:
            self.muGlbIsoVetoPt10_branch.SetAddress(<void*>&self.muGlbIsoVetoPt10_value)

        #print "making muVetoPt15IsoIdVtx"
        self.muVetoPt15IsoIdVtx_branch = the_tree.GetBranch("muVetoPt15IsoIdVtx")
        #if not self.muVetoPt15IsoIdVtx_branch and "muVetoPt15IsoIdVtx" not in self.complained:
        if not self.muVetoPt15IsoIdVtx_branch and "muVetoPt15IsoIdVtx":
            warnings.warn( "EEETree: Expected branch muVetoPt15IsoIdVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt15IsoIdVtx")
        else:
            self.muVetoPt15IsoIdVtx_branch.SetAddress(<void*>&self.muVetoPt15IsoIdVtx_value)

        #print "making muVetoPt5"
        self.muVetoPt5_branch = the_tree.GetBranch("muVetoPt5")
        #if not self.muVetoPt5_branch and "muVetoPt5" not in self.complained:
        if not self.muVetoPt5_branch and "muVetoPt5":
            warnings.warn( "EEETree: Expected branch muVetoPt5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt5")
        else:
            self.muVetoPt5_branch.SetAddress(<void*>&self.muVetoPt5_value)

        #print "making muVetoPt5IsoIdVtx"
        self.muVetoPt5IsoIdVtx_branch = the_tree.GetBranch("muVetoPt5IsoIdVtx")
        #if not self.muVetoPt5IsoIdVtx_branch and "muVetoPt5IsoIdVtx" not in self.complained:
        if not self.muVetoPt5IsoIdVtx_branch and "muVetoPt5IsoIdVtx":
            warnings.warn( "EEETree: Expected branch muVetoPt5IsoIdVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt5IsoIdVtx")
        else:
            self.muVetoPt5IsoIdVtx_branch.SetAddress(<void*>&self.muVetoPt5IsoIdVtx_value)

        #print "making nTruePU"
        self.nTruePU_branch = the_tree.GetBranch("nTruePU")
        #if not self.nTruePU_branch and "nTruePU" not in self.complained:
        if not self.nTruePU_branch and "nTruePU":
            warnings.warn( "EEETree: Expected branch nTruePU does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("nTruePU")
        else:
            self.nTruePU_branch.SetAddress(<void*>&self.nTruePU_value)

        #print "making nvtx"
        self.nvtx_branch = the_tree.GetBranch("nvtx")
        #if not self.nvtx_branch and "nvtx" not in self.complained:
        if not self.nvtx_branch and "nvtx":
            warnings.warn( "EEETree: Expected branch nvtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("nvtx")
        else:
            self.nvtx_branch.SetAddress(<void*>&self.nvtx_value)

        #print "making processID"
        self.processID_branch = the_tree.GetBranch("processID")
        #if not self.processID_branch and "processID" not in self.complained:
        if not self.processID_branch and "processID":
            warnings.warn( "EEETree: Expected branch processID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("processID")
        else:
            self.processID_branch.SetAddress(<void*>&self.processID_value)

        #print "making pvChi2"
        self.pvChi2_branch = the_tree.GetBranch("pvChi2")
        #if not self.pvChi2_branch and "pvChi2" not in self.complained:
        if not self.pvChi2_branch and "pvChi2":
            warnings.warn( "EEETree: Expected branch pvChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvChi2")
        else:
            self.pvChi2_branch.SetAddress(<void*>&self.pvChi2_value)

        #print "making pvDX"
        self.pvDX_branch = the_tree.GetBranch("pvDX")
        #if not self.pvDX_branch and "pvDX" not in self.complained:
        if not self.pvDX_branch and "pvDX":
            warnings.warn( "EEETree: Expected branch pvDX does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDX")
        else:
            self.pvDX_branch.SetAddress(<void*>&self.pvDX_value)

        #print "making pvDY"
        self.pvDY_branch = the_tree.GetBranch("pvDY")
        #if not self.pvDY_branch and "pvDY" not in self.complained:
        if not self.pvDY_branch and "pvDY":
            warnings.warn( "EEETree: Expected branch pvDY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDY")
        else:
            self.pvDY_branch.SetAddress(<void*>&self.pvDY_value)

        #print "making pvDZ"
        self.pvDZ_branch = the_tree.GetBranch("pvDZ")
        #if not self.pvDZ_branch and "pvDZ" not in self.complained:
        if not self.pvDZ_branch and "pvDZ":
            warnings.warn( "EEETree: Expected branch pvDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDZ")
        else:
            self.pvDZ_branch.SetAddress(<void*>&self.pvDZ_value)

        #print "making pvIsFake"
        self.pvIsFake_branch = the_tree.GetBranch("pvIsFake")
        #if not self.pvIsFake_branch and "pvIsFake" not in self.complained:
        if not self.pvIsFake_branch and "pvIsFake":
            warnings.warn( "EEETree: Expected branch pvIsFake does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvIsFake")
        else:
            self.pvIsFake_branch.SetAddress(<void*>&self.pvIsFake_value)

        #print "making pvIsValid"
        self.pvIsValid_branch = the_tree.GetBranch("pvIsValid")
        #if not self.pvIsValid_branch and "pvIsValid" not in self.complained:
        if not self.pvIsValid_branch and "pvIsValid":
            warnings.warn( "EEETree: Expected branch pvIsValid does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvIsValid")
        else:
            self.pvIsValid_branch.SetAddress(<void*>&self.pvIsValid_value)

        #print "making pvNormChi2"
        self.pvNormChi2_branch = the_tree.GetBranch("pvNormChi2")
        #if not self.pvNormChi2_branch and "pvNormChi2" not in self.complained:
        if not self.pvNormChi2_branch and "pvNormChi2":
            warnings.warn( "EEETree: Expected branch pvNormChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvNormChi2")
        else:
            self.pvNormChi2_branch.SetAddress(<void*>&self.pvNormChi2_value)

        #print "making pvRho"
        self.pvRho_branch = the_tree.GetBranch("pvRho")
        #if not self.pvRho_branch and "pvRho" not in self.complained:
        if not self.pvRho_branch and "pvRho":
            warnings.warn( "EEETree: Expected branch pvRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvRho")
        else:
            self.pvRho_branch.SetAddress(<void*>&self.pvRho_value)

        #print "making pvX"
        self.pvX_branch = the_tree.GetBranch("pvX")
        #if not self.pvX_branch and "pvX" not in self.complained:
        if not self.pvX_branch and "pvX":
            warnings.warn( "EEETree: Expected branch pvX does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvX")
        else:
            self.pvX_branch.SetAddress(<void*>&self.pvX_value)

        #print "making pvY"
        self.pvY_branch = the_tree.GetBranch("pvY")
        #if not self.pvY_branch and "pvY" not in self.complained:
        if not self.pvY_branch and "pvY":
            warnings.warn( "EEETree: Expected branch pvY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvY")
        else:
            self.pvY_branch.SetAddress(<void*>&self.pvY_value)

        #print "making pvZ"
        self.pvZ_branch = the_tree.GetBranch("pvZ")
        #if not self.pvZ_branch and "pvZ" not in self.complained:
        if not self.pvZ_branch and "pvZ":
            warnings.warn( "EEETree: Expected branch pvZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvZ")
        else:
            self.pvZ_branch.SetAddress(<void*>&self.pvZ_value)

        #print "making pvndof"
        self.pvndof_branch = the_tree.GetBranch("pvndof")
        #if not self.pvndof_branch and "pvndof" not in self.complained:
        if not self.pvndof_branch and "pvndof":
            warnings.warn( "EEETree: Expected branch pvndof does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvndof")
        else:
            self.pvndof_branch.SetAddress(<void*>&self.pvndof_value)

        #print "making raw_pfMetEt"
        self.raw_pfMetEt_branch = the_tree.GetBranch("raw_pfMetEt")
        #if not self.raw_pfMetEt_branch and "raw_pfMetEt" not in self.complained:
        if not self.raw_pfMetEt_branch and "raw_pfMetEt":
            warnings.warn( "EEETree: Expected branch raw_pfMetEt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("raw_pfMetEt")
        else:
            self.raw_pfMetEt_branch.SetAddress(<void*>&self.raw_pfMetEt_value)

        #print "making raw_pfMetPhi"
        self.raw_pfMetPhi_branch = the_tree.GetBranch("raw_pfMetPhi")
        #if not self.raw_pfMetPhi_branch and "raw_pfMetPhi" not in self.complained:
        if not self.raw_pfMetPhi_branch and "raw_pfMetPhi":
            warnings.warn( "EEETree: Expected branch raw_pfMetPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("raw_pfMetPhi")
        else:
            self.raw_pfMetPhi_branch.SetAddress(<void*>&self.raw_pfMetPhi_value)

        #print "making recoilDaught"
        self.recoilDaught_branch = the_tree.GetBranch("recoilDaught")
        #if not self.recoilDaught_branch and "recoilDaught" not in self.complained:
        if not self.recoilDaught_branch and "recoilDaught":
            warnings.warn( "EEETree: Expected branch recoilDaught does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("recoilDaught")
        else:
            self.recoilDaught_branch.SetAddress(<void*>&self.recoilDaught_value)

        #print "making recoilWithMet"
        self.recoilWithMet_branch = the_tree.GetBranch("recoilWithMet")
        #if not self.recoilWithMet_branch and "recoilWithMet" not in self.complained:
        if not self.recoilWithMet_branch and "recoilWithMet":
            warnings.warn( "EEETree: Expected branch recoilWithMet does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("recoilWithMet")
        else:
            self.recoilWithMet_branch.SetAddress(<void*>&self.recoilWithMet_value)

        #print "making rho"
        self.rho_branch = the_tree.GetBranch("rho")
        #if not self.rho_branch and "rho" not in self.complained:
        if not self.rho_branch and "rho":
            warnings.warn( "EEETree: Expected branch rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("rho")
        else:
            self.rho_branch.SetAddress(<void*>&self.rho_value)

        #print "making run"
        self.run_branch = the_tree.GetBranch("run")
        #if not self.run_branch and "run" not in self.complained:
        if not self.run_branch and "run":
            warnings.warn( "EEETree: Expected branch run does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("run")
        else:
            self.run_branch.SetAddress(<void*>&self.run_value)

        #print "making singleE17SingleMu8Group"
        self.singleE17SingleMu8Group_branch = the_tree.GetBranch("singleE17SingleMu8Group")
        #if not self.singleE17SingleMu8Group_branch and "singleE17SingleMu8Group" not in self.complained:
        if not self.singleE17SingleMu8Group_branch and "singleE17SingleMu8Group":
            warnings.warn( "EEETree: Expected branch singleE17SingleMu8Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Group")
        else:
            self.singleE17SingleMu8Group_branch.SetAddress(<void*>&self.singleE17SingleMu8Group_value)

        #print "making singleE17SingleMu8Pass"
        self.singleE17SingleMu8Pass_branch = the_tree.GetBranch("singleE17SingleMu8Pass")
        #if not self.singleE17SingleMu8Pass_branch and "singleE17SingleMu8Pass" not in self.complained:
        if not self.singleE17SingleMu8Pass_branch and "singleE17SingleMu8Pass":
            warnings.warn( "EEETree: Expected branch singleE17SingleMu8Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Pass")
        else:
            self.singleE17SingleMu8Pass_branch.SetAddress(<void*>&self.singleE17SingleMu8Pass_value)

        #print "making singleE17SingleMu8Prescale"
        self.singleE17SingleMu8Prescale_branch = the_tree.GetBranch("singleE17SingleMu8Prescale")
        #if not self.singleE17SingleMu8Prescale_branch and "singleE17SingleMu8Prescale" not in self.complained:
        if not self.singleE17SingleMu8Prescale_branch and "singleE17SingleMu8Prescale":
            warnings.warn( "EEETree: Expected branch singleE17SingleMu8Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Prescale")
        else:
            self.singleE17SingleMu8Prescale_branch.SetAddress(<void*>&self.singleE17SingleMu8Prescale_value)

        #print "making singleE22WP75Group"
        self.singleE22WP75Group_branch = the_tree.GetBranch("singleE22WP75Group")
        #if not self.singleE22WP75Group_branch and "singleE22WP75Group" not in self.complained:
        if not self.singleE22WP75Group_branch and "singleE22WP75Group":
            warnings.warn( "EEETree: Expected branch singleE22WP75Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Group")
        else:
            self.singleE22WP75Group_branch.SetAddress(<void*>&self.singleE22WP75Group_value)

        #print "making singleE22WP75Pass"
        self.singleE22WP75Pass_branch = the_tree.GetBranch("singleE22WP75Pass")
        #if not self.singleE22WP75Pass_branch and "singleE22WP75Pass" not in self.complained:
        if not self.singleE22WP75Pass_branch and "singleE22WP75Pass":
            warnings.warn( "EEETree: Expected branch singleE22WP75Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Pass")
        else:
            self.singleE22WP75Pass_branch.SetAddress(<void*>&self.singleE22WP75Pass_value)

        #print "making singleE22WP75Prescale"
        self.singleE22WP75Prescale_branch = the_tree.GetBranch("singleE22WP75Prescale")
        #if not self.singleE22WP75Prescale_branch and "singleE22WP75Prescale" not in self.complained:
        if not self.singleE22WP75Prescale_branch and "singleE22WP75Prescale":
            warnings.warn( "EEETree: Expected branch singleE22WP75Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Prescale")
        else:
            self.singleE22WP75Prescale_branch.SetAddress(<void*>&self.singleE22WP75Prescale_value)

        #print "making singleE22eta2p1LooseGroup"
        self.singleE22eta2p1LooseGroup_branch = the_tree.GetBranch("singleE22eta2p1LooseGroup")
        #if not self.singleE22eta2p1LooseGroup_branch and "singleE22eta2p1LooseGroup" not in self.complained:
        if not self.singleE22eta2p1LooseGroup_branch and "singleE22eta2p1LooseGroup":
            warnings.warn( "EEETree: Expected branch singleE22eta2p1LooseGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LooseGroup")
        else:
            self.singleE22eta2p1LooseGroup_branch.SetAddress(<void*>&self.singleE22eta2p1LooseGroup_value)

        #print "making singleE22eta2p1LoosePass"
        self.singleE22eta2p1LoosePass_branch = the_tree.GetBranch("singleE22eta2p1LoosePass")
        #if not self.singleE22eta2p1LoosePass_branch and "singleE22eta2p1LoosePass" not in self.complained:
        if not self.singleE22eta2p1LoosePass_branch and "singleE22eta2p1LoosePass":
            warnings.warn( "EEETree: Expected branch singleE22eta2p1LoosePass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LoosePass")
        else:
            self.singleE22eta2p1LoosePass_branch.SetAddress(<void*>&self.singleE22eta2p1LoosePass_value)

        #print "making singleE22eta2p1LoosePrescale"
        self.singleE22eta2p1LoosePrescale_branch = the_tree.GetBranch("singleE22eta2p1LoosePrescale")
        #if not self.singleE22eta2p1LoosePrescale_branch and "singleE22eta2p1LoosePrescale" not in self.complained:
        if not self.singleE22eta2p1LoosePrescale_branch and "singleE22eta2p1LoosePrescale":
            warnings.warn( "EEETree: Expected branch singleE22eta2p1LoosePrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LoosePrescale")
        else:
            self.singleE22eta2p1LoosePrescale_branch.SetAddress(<void*>&self.singleE22eta2p1LoosePrescale_value)

        #print "making singleE23SingleMu8Group"
        self.singleE23SingleMu8Group_branch = the_tree.GetBranch("singleE23SingleMu8Group")
        #if not self.singleE23SingleMu8Group_branch and "singleE23SingleMu8Group" not in self.complained:
        if not self.singleE23SingleMu8Group_branch and "singleE23SingleMu8Group":
            warnings.warn( "EEETree: Expected branch singleE23SingleMu8Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Group")
        else:
            self.singleE23SingleMu8Group_branch.SetAddress(<void*>&self.singleE23SingleMu8Group_value)

        #print "making singleE23SingleMu8Pass"
        self.singleE23SingleMu8Pass_branch = the_tree.GetBranch("singleE23SingleMu8Pass")
        #if not self.singleE23SingleMu8Pass_branch and "singleE23SingleMu8Pass" not in self.complained:
        if not self.singleE23SingleMu8Pass_branch and "singleE23SingleMu8Pass":
            warnings.warn( "EEETree: Expected branch singleE23SingleMu8Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Pass")
        else:
            self.singleE23SingleMu8Pass_branch.SetAddress(<void*>&self.singleE23SingleMu8Pass_value)

        #print "making singleE23SingleMu8Prescale"
        self.singleE23SingleMu8Prescale_branch = the_tree.GetBranch("singleE23SingleMu8Prescale")
        #if not self.singleE23SingleMu8Prescale_branch and "singleE23SingleMu8Prescale" not in self.complained:
        if not self.singleE23SingleMu8Prescale_branch and "singleE23SingleMu8Prescale":
            warnings.warn( "EEETree: Expected branch singleE23SingleMu8Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Prescale")
        else:
            self.singleE23SingleMu8Prescale_branch.SetAddress(<void*>&self.singleE23SingleMu8Prescale_value)

        #print "making singleE23WP75Group"
        self.singleE23WP75Group_branch = the_tree.GetBranch("singleE23WP75Group")
        #if not self.singleE23WP75Group_branch and "singleE23WP75Group" not in self.complained:
        if not self.singleE23WP75Group_branch and "singleE23WP75Group":
            warnings.warn( "EEETree: Expected branch singleE23WP75Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Group")
        else:
            self.singleE23WP75Group_branch.SetAddress(<void*>&self.singleE23WP75Group_value)

        #print "making singleE23WP75Pass"
        self.singleE23WP75Pass_branch = the_tree.GetBranch("singleE23WP75Pass")
        #if not self.singleE23WP75Pass_branch and "singleE23WP75Pass" not in self.complained:
        if not self.singleE23WP75Pass_branch and "singleE23WP75Pass":
            warnings.warn( "EEETree: Expected branch singleE23WP75Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Pass")
        else:
            self.singleE23WP75Pass_branch.SetAddress(<void*>&self.singleE23WP75Pass_value)

        #print "making singleE23WP75Prescale"
        self.singleE23WP75Prescale_branch = the_tree.GetBranch("singleE23WP75Prescale")
        #if not self.singleE23WP75Prescale_branch and "singleE23WP75Prescale" not in self.complained:
        if not self.singleE23WP75Prescale_branch and "singleE23WP75Prescale":
            warnings.warn( "EEETree: Expected branch singleE23WP75Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Prescale")
        else:
            self.singleE23WP75Prescale_branch.SetAddress(<void*>&self.singleE23WP75Prescale_value)

        #print "making singleE23WPLooseGroup"
        self.singleE23WPLooseGroup_branch = the_tree.GetBranch("singleE23WPLooseGroup")
        #if not self.singleE23WPLooseGroup_branch and "singleE23WPLooseGroup" not in self.complained:
        if not self.singleE23WPLooseGroup_branch and "singleE23WPLooseGroup":
            warnings.warn( "EEETree: Expected branch singleE23WPLooseGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WPLooseGroup")
        else:
            self.singleE23WPLooseGroup_branch.SetAddress(<void*>&self.singleE23WPLooseGroup_value)

        #print "making singleE23WPLoosePass"
        self.singleE23WPLoosePass_branch = the_tree.GetBranch("singleE23WPLoosePass")
        #if not self.singleE23WPLoosePass_branch and "singleE23WPLoosePass" not in self.complained:
        if not self.singleE23WPLoosePass_branch and "singleE23WPLoosePass":
            warnings.warn( "EEETree: Expected branch singleE23WPLoosePass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WPLoosePass")
        else:
            self.singleE23WPLoosePass_branch.SetAddress(<void*>&self.singleE23WPLoosePass_value)

        #print "making singleE23WPLoosePrescale"
        self.singleE23WPLoosePrescale_branch = the_tree.GetBranch("singleE23WPLoosePrescale")
        #if not self.singleE23WPLoosePrescale_branch and "singleE23WPLoosePrescale" not in self.complained:
        if not self.singleE23WPLoosePrescale_branch and "singleE23WPLoosePrescale":
            warnings.warn( "EEETree: Expected branch singleE23WPLoosePrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WPLoosePrescale")
        else:
            self.singleE23WPLoosePrescale_branch.SetAddress(<void*>&self.singleE23WPLoosePrescale_value)

        #print "making singleEGroup"
        self.singleEGroup_branch = the_tree.GetBranch("singleEGroup")
        #if not self.singleEGroup_branch and "singleEGroup" not in self.complained:
        if not self.singleEGroup_branch and "singleEGroup":
            warnings.warn( "EEETree: Expected branch singleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEGroup")
        else:
            self.singleEGroup_branch.SetAddress(<void*>&self.singleEGroup_value)

        #print "making singleEPass"
        self.singleEPass_branch = the_tree.GetBranch("singleEPass")
        #if not self.singleEPass_branch and "singleEPass" not in self.complained:
        if not self.singleEPass_branch and "singleEPass":
            warnings.warn( "EEETree: Expected branch singleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEPass")
        else:
            self.singleEPass_branch.SetAddress(<void*>&self.singleEPass_value)

        #print "making singleEPrescale"
        self.singleEPrescale_branch = the_tree.GetBranch("singleEPrescale")
        #if not self.singleEPrescale_branch and "singleEPrescale" not in self.complained:
        if not self.singleEPrescale_branch and "singleEPrescale":
            warnings.warn( "EEETree: Expected branch singleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEPrescale")
        else:
            self.singleEPrescale_branch.SetAddress(<void*>&self.singleEPrescale_value)

        #print "making singleESingleMuGroup"
        self.singleESingleMuGroup_branch = the_tree.GetBranch("singleESingleMuGroup")
        #if not self.singleESingleMuGroup_branch and "singleESingleMuGroup" not in self.complained:
        if not self.singleESingleMuGroup_branch and "singleESingleMuGroup":
            warnings.warn( "EEETree: Expected branch singleESingleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuGroup")
        else:
            self.singleESingleMuGroup_branch.SetAddress(<void*>&self.singleESingleMuGroup_value)

        #print "making singleESingleMuPass"
        self.singleESingleMuPass_branch = the_tree.GetBranch("singleESingleMuPass")
        #if not self.singleESingleMuPass_branch and "singleESingleMuPass" not in self.complained:
        if not self.singleESingleMuPass_branch and "singleESingleMuPass":
            warnings.warn( "EEETree: Expected branch singleESingleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuPass")
        else:
            self.singleESingleMuPass_branch.SetAddress(<void*>&self.singleESingleMuPass_value)

        #print "making singleESingleMuPrescale"
        self.singleESingleMuPrescale_branch = the_tree.GetBranch("singleESingleMuPrescale")
        #if not self.singleESingleMuPrescale_branch and "singleESingleMuPrescale" not in self.complained:
        if not self.singleESingleMuPrescale_branch and "singleESingleMuPrescale":
            warnings.warn( "EEETree: Expected branch singleESingleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuPrescale")
        else:
            self.singleESingleMuPrescale_branch.SetAddress(<void*>&self.singleESingleMuPrescale_value)

        #print "making singleE_leg1Group"
        self.singleE_leg1Group_branch = the_tree.GetBranch("singleE_leg1Group")
        #if not self.singleE_leg1Group_branch and "singleE_leg1Group" not in self.complained:
        if not self.singleE_leg1Group_branch and "singleE_leg1Group":
            warnings.warn( "EEETree: Expected branch singleE_leg1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Group")
        else:
            self.singleE_leg1Group_branch.SetAddress(<void*>&self.singleE_leg1Group_value)

        #print "making singleE_leg1Pass"
        self.singleE_leg1Pass_branch = the_tree.GetBranch("singleE_leg1Pass")
        #if not self.singleE_leg1Pass_branch and "singleE_leg1Pass" not in self.complained:
        if not self.singleE_leg1Pass_branch and "singleE_leg1Pass":
            warnings.warn( "EEETree: Expected branch singleE_leg1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Pass")
        else:
            self.singleE_leg1Pass_branch.SetAddress(<void*>&self.singleE_leg1Pass_value)

        #print "making singleE_leg1Prescale"
        self.singleE_leg1Prescale_branch = the_tree.GetBranch("singleE_leg1Prescale")
        #if not self.singleE_leg1Prescale_branch and "singleE_leg1Prescale" not in self.complained:
        if not self.singleE_leg1Prescale_branch and "singleE_leg1Prescale":
            warnings.warn( "EEETree: Expected branch singleE_leg1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Prescale")
        else:
            self.singleE_leg1Prescale_branch.SetAddress(<void*>&self.singleE_leg1Prescale_value)

        #print "making singleE_leg2Group"
        self.singleE_leg2Group_branch = the_tree.GetBranch("singleE_leg2Group")
        #if not self.singleE_leg2Group_branch and "singleE_leg2Group" not in self.complained:
        if not self.singleE_leg2Group_branch and "singleE_leg2Group":
            warnings.warn( "EEETree: Expected branch singleE_leg2Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Group")
        else:
            self.singleE_leg2Group_branch.SetAddress(<void*>&self.singleE_leg2Group_value)

        #print "making singleE_leg2Pass"
        self.singleE_leg2Pass_branch = the_tree.GetBranch("singleE_leg2Pass")
        #if not self.singleE_leg2Pass_branch and "singleE_leg2Pass" not in self.complained:
        if not self.singleE_leg2Pass_branch and "singleE_leg2Pass":
            warnings.warn( "EEETree: Expected branch singleE_leg2Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Pass")
        else:
            self.singleE_leg2Pass_branch.SetAddress(<void*>&self.singleE_leg2Pass_value)

        #print "making singleE_leg2Prescale"
        self.singleE_leg2Prescale_branch = the_tree.GetBranch("singleE_leg2Prescale")
        #if not self.singleE_leg2Prescale_branch and "singleE_leg2Prescale" not in self.complained:
        if not self.singleE_leg2Prescale_branch and "singleE_leg2Prescale":
            warnings.warn( "EEETree: Expected branch singleE_leg2Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Prescale")
        else:
            self.singleE_leg2Prescale_branch.SetAddress(<void*>&self.singleE_leg2Prescale_value)

        #print "making singleIsoMu17eta2p1Group"
        self.singleIsoMu17eta2p1Group_branch = the_tree.GetBranch("singleIsoMu17eta2p1Group")
        #if not self.singleIsoMu17eta2p1Group_branch and "singleIsoMu17eta2p1Group" not in self.complained:
        if not self.singleIsoMu17eta2p1Group_branch and "singleIsoMu17eta2p1Group":
            warnings.warn( "EEETree: Expected branch singleIsoMu17eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Group")
        else:
            self.singleIsoMu17eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Group_value)

        #print "making singleIsoMu17eta2p1Pass"
        self.singleIsoMu17eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu17eta2p1Pass")
        #if not self.singleIsoMu17eta2p1Pass_branch and "singleIsoMu17eta2p1Pass" not in self.complained:
        if not self.singleIsoMu17eta2p1Pass_branch and "singleIsoMu17eta2p1Pass":
            warnings.warn( "EEETree: Expected branch singleIsoMu17eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Pass")
        else:
            self.singleIsoMu17eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Pass_value)

        #print "making singleIsoMu17eta2p1Prescale"
        self.singleIsoMu17eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu17eta2p1Prescale")
        #if not self.singleIsoMu17eta2p1Prescale_branch and "singleIsoMu17eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu17eta2p1Prescale_branch and "singleIsoMu17eta2p1Prescale":
            warnings.warn( "EEETree: Expected branch singleIsoMu17eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Prescale")
        else:
            self.singleIsoMu17eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Prescale_value)

        #print "making singleIsoMu20Group"
        self.singleIsoMu20Group_branch = the_tree.GetBranch("singleIsoMu20Group")
        #if not self.singleIsoMu20Group_branch and "singleIsoMu20Group" not in self.complained:
        if not self.singleIsoMu20Group_branch and "singleIsoMu20Group":
            warnings.warn( "EEETree: Expected branch singleIsoMu20Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Group")
        else:
            self.singleIsoMu20Group_branch.SetAddress(<void*>&self.singleIsoMu20Group_value)

        #print "making singleIsoMu20Pass"
        self.singleIsoMu20Pass_branch = the_tree.GetBranch("singleIsoMu20Pass")
        #if not self.singleIsoMu20Pass_branch and "singleIsoMu20Pass" not in self.complained:
        if not self.singleIsoMu20Pass_branch and "singleIsoMu20Pass":
            warnings.warn( "EEETree: Expected branch singleIsoMu20Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Pass")
        else:
            self.singleIsoMu20Pass_branch.SetAddress(<void*>&self.singleIsoMu20Pass_value)

        #print "making singleIsoMu20Prescale"
        self.singleIsoMu20Prescale_branch = the_tree.GetBranch("singleIsoMu20Prescale")
        #if not self.singleIsoMu20Prescale_branch and "singleIsoMu20Prescale" not in self.complained:
        if not self.singleIsoMu20Prescale_branch and "singleIsoMu20Prescale":
            warnings.warn( "EEETree: Expected branch singleIsoMu20Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Prescale")
        else:
            self.singleIsoMu20Prescale_branch.SetAddress(<void*>&self.singleIsoMu20Prescale_value)

        #print "making singleIsoMu20eta2p1Group"
        self.singleIsoMu20eta2p1Group_branch = the_tree.GetBranch("singleIsoMu20eta2p1Group")
        #if not self.singleIsoMu20eta2p1Group_branch and "singleIsoMu20eta2p1Group" not in self.complained:
        if not self.singleIsoMu20eta2p1Group_branch and "singleIsoMu20eta2p1Group":
            warnings.warn( "EEETree: Expected branch singleIsoMu20eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Group")
        else:
            self.singleIsoMu20eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Group_value)

        #print "making singleIsoMu20eta2p1Pass"
        self.singleIsoMu20eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu20eta2p1Pass")
        #if not self.singleIsoMu20eta2p1Pass_branch and "singleIsoMu20eta2p1Pass" not in self.complained:
        if not self.singleIsoMu20eta2p1Pass_branch and "singleIsoMu20eta2p1Pass":
            warnings.warn( "EEETree: Expected branch singleIsoMu20eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Pass")
        else:
            self.singleIsoMu20eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Pass_value)

        #print "making singleIsoMu20eta2p1Prescale"
        self.singleIsoMu20eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu20eta2p1Prescale")
        #if not self.singleIsoMu20eta2p1Prescale_branch and "singleIsoMu20eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu20eta2p1Prescale_branch and "singleIsoMu20eta2p1Prescale":
            warnings.warn( "EEETree: Expected branch singleIsoMu20eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Prescale")
        else:
            self.singleIsoMu20eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Prescale_value)

        #print "making singleIsoMu24Group"
        self.singleIsoMu24Group_branch = the_tree.GetBranch("singleIsoMu24Group")
        #if not self.singleIsoMu24Group_branch and "singleIsoMu24Group" not in self.complained:
        if not self.singleIsoMu24Group_branch and "singleIsoMu24Group":
            warnings.warn( "EEETree: Expected branch singleIsoMu24Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Group")
        else:
            self.singleIsoMu24Group_branch.SetAddress(<void*>&self.singleIsoMu24Group_value)

        #print "making singleIsoMu24Pass"
        self.singleIsoMu24Pass_branch = the_tree.GetBranch("singleIsoMu24Pass")
        #if not self.singleIsoMu24Pass_branch and "singleIsoMu24Pass" not in self.complained:
        if not self.singleIsoMu24Pass_branch and "singleIsoMu24Pass":
            warnings.warn( "EEETree: Expected branch singleIsoMu24Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Pass")
        else:
            self.singleIsoMu24Pass_branch.SetAddress(<void*>&self.singleIsoMu24Pass_value)

        #print "making singleIsoMu24Prescale"
        self.singleIsoMu24Prescale_branch = the_tree.GetBranch("singleIsoMu24Prescale")
        #if not self.singleIsoMu24Prescale_branch and "singleIsoMu24Prescale" not in self.complained:
        if not self.singleIsoMu24Prescale_branch and "singleIsoMu24Prescale":
            warnings.warn( "EEETree: Expected branch singleIsoMu24Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Prescale")
        else:
            self.singleIsoMu24Prescale_branch.SetAddress(<void*>&self.singleIsoMu24Prescale_value)

        #print "making singleIsoMu24eta2p1Group"
        self.singleIsoMu24eta2p1Group_branch = the_tree.GetBranch("singleIsoMu24eta2p1Group")
        #if not self.singleIsoMu24eta2p1Group_branch and "singleIsoMu24eta2p1Group" not in self.complained:
        if not self.singleIsoMu24eta2p1Group_branch and "singleIsoMu24eta2p1Group":
            warnings.warn( "EEETree: Expected branch singleIsoMu24eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Group")
        else:
            self.singleIsoMu24eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Group_value)

        #print "making singleIsoMu24eta2p1Pass"
        self.singleIsoMu24eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu24eta2p1Pass")
        #if not self.singleIsoMu24eta2p1Pass_branch and "singleIsoMu24eta2p1Pass" not in self.complained:
        if not self.singleIsoMu24eta2p1Pass_branch and "singleIsoMu24eta2p1Pass":
            warnings.warn( "EEETree: Expected branch singleIsoMu24eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Pass")
        else:
            self.singleIsoMu24eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Pass_value)

        #print "making singleIsoMu24eta2p1Prescale"
        self.singleIsoMu24eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu24eta2p1Prescale")
        #if not self.singleIsoMu24eta2p1Prescale_branch and "singleIsoMu24eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu24eta2p1Prescale_branch and "singleIsoMu24eta2p1Prescale":
            warnings.warn( "EEETree: Expected branch singleIsoMu24eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Prescale")
        else:
            self.singleIsoMu24eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Prescale_value)

        #print "making singleIsoMu27Group"
        self.singleIsoMu27Group_branch = the_tree.GetBranch("singleIsoMu27Group")
        #if not self.singleIsoMu27Group_branch and "singleIsoMu27Group" not in self.complained:
        if not self.singleIsoMu27Group_branch and "singleIsoMu27Group":
            warnings.warn( "EEETree: Expected branch singleIsoMu27Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu27Group")
        else:
            self.singleIsoMu27Group_branch.SetAddress(<void*>&self.singleIsoMu27Group_value)

        #print "making singleIsoMu27Pass"
        self.singleIsoMu27Pass_branch = the_tree.GetBranch("singleIsoMu27Pass")
        #if not self.singleIsoMu27Pass_branch and "singleIsoMu27Pass" not in self.complained:
        if not self.singleIsoMu27Pass_branch and "singleIsoMu27Pass":
            warnings.warn( "EEETree: Expected branch singleIsoMu27Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu27Pass")
        else:
            self.singleIsoMu27Pass_branch.SetAddress(<void*>&self.singleIsoMu27Pass_value)

        #print "making singleIsoMu27Prescale"
        self.singleIsoMu27Prescale_branch = the_tree.GetBranch("singleIsoMu27Prescale")
        #if not self.singleIsoMu27Prescale_branch and "singleIsoMu27Prescale" not in self.complained:
        if not self.singleIsoMu27Prescale_branch and "singleIsoMu27Prescale":
            warnings.warn( "EEETree: Expected branch singleIsoMu27Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu27Prescale")
        else:
            self.singleIsoMu27Prescale_branch.SetAddress(<void*>&self.singleIsoMu27Prescale_value)

        #print "making singleIsoTkMu20Group"
        self.singleIsoTkMu20Group_branch = the_tree.GetBranch("singleIsoTkMu20Group")
        #if not self.singleIsoTkMu20Group_branch and "singleIsoTkMu20Group" not in self.complained:
        if not self.singleIsoTkMu20Group_branch and "singleIsoTkMu20Group":
            warnings.warn( "EEETree: Expected branch singleIsoTkMu20Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Group")
        else:
            self.singleIsoTkMu20Group_branch.SetAddress(<void*>&self.singleIsoTkMu20Group_value)

        #print "making singleIsoTkMu20Pass"
        self.singleIsoTkMu20Pass_branch = the_tree.GetBranch("singleIsoTkMu20Pass")
        #if not self.singleIsoTkMu20Pass_branch and "singleIsoTkMu20Pass" not in self.complained:
        if not self.singleIsoTkMu20Pass_branch and "singleIsoTkMu20Pass":
            warnings.warn( "EEETree: Expected branch singleIsoTkMu20Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Pass")
        else:
            self.singleIsoTkMu20Pass_branch.SetAddress(<void*>&self.singleIsoTkMu20Pass_value)

        #print "making singleIsoTkMu20Prescale"
        self.singleIsoTkMu20Prescale_branch = the_tree.GetBranch("singleIsoTkMu20Prescale")
        #if not self.singleIsoTkMu20Prescale_branch and "singleIsoTkMu20Prescale" not in self.complained:
        if not self.singleIsoTkMu20Prescale_branch and "singleIsoTkMu20Prescale":
            warnings.warn( "EEETree: Expected branch singleIsoTkMu20Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Prescale")
        else:
            self.singleIsoTkMu20Prescale_branch.SetAddress(<void*>&self.singleIsoTkMu20Prescale_value)

        #print "making singleMu17SingleE12Group"
        self.singleMu17SingleE12Group_branch = the_tree.GetBranch("singleMu17SingleE12Group")
        #if not self.singleMu17SingleE12Group_branch and "singleMu17SingleE12Group" not in self.complained:
        if not self.singleMu17SingleE12Group_branch and "singleMu17SingleE12Group":
            warnings.warn( "EEETree: Expected branch singleMu17SingleE12Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Group")
        else:
            self.singleMu17SingleE12Group_branch.SetAddress(<void*>&self.singleMu17SingleE12Group_value)

        #print "making singleMu17SingleE12Pass"
        self.singleMu17SingleE12Pass_branch = the_tree.GetBranch("singleMu17SingleE12Pass")
        #if not self.singleMu17SingleE12Pass_branch and "singleMu17SingleE12Pass" not in self.complained:
        if not self.singleMu17SingleE12Pass_branch and "singleMu17SingleE12Pass":
            warnings.warn( "EEETree: Expected branch singleMu17SingleE12Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Pass")
        else:
            self.singleMu17SingleE12Pass_branch.SetAddress(<void*>&self.singleMu17SingleE12Pass_value)

        #print "making singleMu17SingleE12Prescale"
        self.singleMu17SingleE12Prescale_branch = the_tree.GetBranch("singleMu17SingleE12Prescale")
        #if not self.singleMu17SingleE12Prescale_branch and "singleMu17SingleE12Prescale" not in self.complained:
        if not self.singleMu17SingleE12Prescale_branch and "singleMu17SingleE12Prescale":
            warnings.warn( "EEETree: Expected branch singleMu17SingleE12Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Prescale")
        else:
            self.singleMu17SingleE12Prescale_branch.SetAddress(<void*>&self.singleMu17SingleE12Prescale_value)

        #print "making singleMu23SingleE12Group"
        self.singleMu23SingleE12Group_branch = the_tree.GetBranch("singleMu23SingleE12Group")
        #if not self.singleMu23SingleE12Group_branch and "singleMu23SingleE12Group" not in self.complained:
        if not self.singleMu23SingleE12Group_branch and "singleMu23SingleE12Group":
            warnings.warn( "EEETree: Expected branch singleMu23SingleE12Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Group")
        else:
            self.singleMu23SingleE12Group_branch.SetAddress(<void*>&self.singleMu23SingleE12Group_value)

        #print "making singleMu23SingleE12Pass"
        self.singleMu23SingleE12Pass_branch = the_tree.GetBranch("singleMu23SingleE12Pass")
        #if not self.singleMu23SingleE12Pass_branch and "singleMu23SingleE12Pass" not in self.complained:
        if not self.singleMu23SingleE12Pass_branch and "singleMu23SingleE12Pass":
            warnings.warn( "EEETree: Expected branch singleMu23SingleE12Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Pass")
        else:
            self.singleMu23SingleE12Pass_branch.SetAddress(<void*>&self.singleMu23SingleE12Pass_value)

        #print "making singleMu23SingleE12Prescale"
        self.singleMu23SingleE12Prescale_branch = the_tree.GetBranch("singleMu23SingleE12Prescale")
        #if not self.singleMu23SingleE12Prescale_branch and "singleMu23SingleE12Prescale" not in self.complained:
        if not self.singleMu23SingleE12Prescale_branch and "singleMu23SingleE12Prescale":
            warnings.warn( "EEETree: Expected branch singleMu23SingleE12Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Prescale")
        else:
            self.singleMu23SingleE12Prescale_branch.SetAddress(<void*>&self.singleMu23SingleE12Prescale_value)

        #print "making singleMuGroup"
        self.singleMuGroup_branch = the_tree.GetBranch("singleMuGroup")
        #if not self.singleMuGroup_branch and "singleMuGroup" not in self.complained:
        if not self.singleMuGroup_branch and "singleMuGroup":
            warnings.warn( "EEETree: Expected branch singleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuGroup")
        else:
            self.singleMuGroup_branch.SetAddress(<void*>&self.singleMuGroup_value)

        #print "making singleMuPass"
        self.singleMuPass_branch = the_tree.GetBranch("singleMuPass")
        #if not self.singleMuPass_branch and "singleMuPass" not in self.complained:
        if not self.singleMuPass_branch and "singleMuPass":
            warnings.warn( "EEETree: Expected branch singleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuPass")
        else:
            self.singleMuPass_branch.SetAddress(<void*>&self.singleMuPass_value)

        #print "making singleMuPrescale"
        self.singleMuPrescale_branch = the_tree.GetBranch("singleMuPrescale")
        #if not self.singleMuPrescale_branch and "singleMuPrescale" not in self.complained:
        if not self.singleMuPrescale_branch and "singleMuPrescale":
            warnings.warn( "EEETree: Expected branch singleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuPrescale")
        else:
            self.singleMuPrescale_branch.SetAddress(<void*>&self.singleMuPrescale_value)

        #print "making singleMuSingleEGroup"
        self.singleMuSingleEGroup_branch = the_tree.GetBranch("singleMuSingleEGroup")
        #if not self.singleMuSingleEGroup_branch and "singleMuSingleEGroup" not in self.complained:
        if not self.singleMuSingleEGroup_branch and "singleMuSingleEGroup":
            warnings.warn( "EEETree: Expected branch singleMuSingleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEGroup")
        else:
            self.singleMuSingleEGroup_branch.SetAddress(<void*>&self.singleMuSingleEGroup_value)

        #print "making singleMuSingleEPass"
        self.singleMuSingleEPass_branch = the_tree.GetBranch("singleMuSingleEPass")
        #if not self.singleMuSingleEPass_branch and "singleMuSingleEPass" not in self.complained:
        if not self.singleMuSingleEPass_branch and "singleMuSingleEPass":
            warnings.warn( "EEETree: Expected branch singleMuSingleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEPass")
        else:
            self.singleMuSingleEPass_branch.SetAddress(<void*>&self.singleMuSingleEPass_value)

        #print "making singleMuSingleEPrescale"
        self.singleMuSingleEPrescale_branch = the_tree.GetBranch("singleMuSingleEPrescale")
        #if not self.singleMuSingleEPrescale_branch and "singleMuSingleEPrescale" not in self.complained:
        if not self.singleMuSingleEPrescale_branch and "singleMuSingleEPrescale":
            warnings.warn( "EEETree: Expected branch singleMuSingleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEPrescale")
        else:
            self.singleMuSingleEPrescale_branch.SetAddress(<void*>&self.singleMuSingleEPrescale_value)

        #print "making singleMu_leg1Group"
        self.singleMu_leg1Group_branch = the_tree.GetBranch("singleMu_leg1Group")
        #if not self.singleMu_leg1Group_branch and "singleMu_leg1Group" not in self.complained:
        if not self.singleMu_leg1Group_branch and "singleMu_leg1Group":
            warnings.warn( "EEETree: Expected branch singleMu_leg1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Group")
        else:
            self.singleMu_leg1Group_branch.SetAddress(<void*>&self.singleMu_leg1Group_value)

        #print "making singleMu_leg1Pass"
        self.singleMu_leg1Pass_branch = the_tree.GetBranch("singleMu_leg1Pass")
        #if not self.singleMu_leg1Pass_branch and "singleMu_leg1Pass" not in self.complained:
        if not self.singleMu_leg1Pass_branch and "singleMu_leg1Pass":
            warnings.warn( "EEETree: Expected branch singleMu_leg1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Pass")
        else:
            self.singleMu_leg1Pass_branch.SetAddress(<void*>&self.singleMu_leg1Pass_value)

        #print "making singleMu_leg1Prescale"
        self.singleMu_leg1Prescale_branch = the_tree.GetBranch("singleMu_leg1Prescale")
        #if not self.singleMu_leg1Prescale_branch and "singleMu_leg1Prescale" not in self.complained:
        if not self.singleMu_leg1Prescale_branch and "singleMu_leg1Prescale":
            warnings.warn( "EEETree: Expected branch singleMu_leg1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Prescale")
        else:
            self.singleMu_leg1Prescale_branch.SetAddress(<void*>&self.singleMu_leg1Prescale_value)

        #print "making singleMu_leg1_noisoGroup"
        self.singleMu_leg1_noisoGroup_branch = the_tree.GetBranch("singleMu_leg1_noisoGroup")
        #if not self.singleMu_leg1_noisoGroup_branch and "singleMu_leg1_noisoGroup" not in self.complained:
        if not self.singleMu_leg1_noisoGroup_branch and "singleMu_leg1_noisoGroup":
            warnings.warn( "EEETree: Expected branch singleMu_leg1_noisoGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoGroup")
        else:
            self.singleMu_leg1_noisoGroup_branch.SetAddress(<void*>&self.singleMu_leg1_noisoGroup_value)

        #print "making singleMu_leg1_noisoPass"
        self.singleMu_leg1_noisoPass_branch = the_tree.GetBranch("singleMu_leg1_noisoPass")
        #if not self.singleMu_leg1_noisoPass_branch and "singleMu_leg1_noisoPass" not in self.complained:
        if not self.singleMu_leg1_noisoPass_branch and "singleMu_leg1_noisoPass":
            warnings.warn( "EEETree: Expected branch singleMu_leg1_noisoPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoPass")
        else:
            self.singleMu_leg1_noisoPass_branch.SetAddress(<void*>&self.singleMu_leg1_noisoPass_value)

        #print "making singleMu_leg1_noisoPrescale"
        self.singleMu_leg1_noisoPrescale_branch = the_tree.GetBranch("singleMu_leg1_noisoPrescale")
        #if not self.singleMu_leg1_noisoPrescale_branch and "singleMu_leg1_noisoPrescale" not in self.complained:
        if not self.singleMu_leg1_noisoPrescale_branch and "singleMu_leg1_noisoPrescale":
            warnings.warn( "EEETree: Expected branch singleMu_leg1_noisoPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoPrescale")
        else:
            self.singleMu_leg1_noisoPrescale_branch.SetAddress(<void*>&self.singleMu_leg1_noisoPrescale_value)

        #print "making singleMu_leg2Group"
        self.singleMu_leg2Group_branch = the_tree.GetBranch("singleMu_leg2Group")
        #if not self.singleMu_leg2Group_branch and "singleMu_leg2Group" not in self.complained:
        if not self.singleMu_leg2Group_branch and "singleMu_leg2Group":
            warnings.warn( "EEETree: Expected branch singleMu_leg2Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Group")
        else:
            self.singleMu_leg2Group_branch.SetAddress(<void*>&self.singleMu_leg2Group_value)

        #print "making singleMu_leg2Pass"
        self.singleMu_leg2Pass_branch = the_tree.GetBranch("singleMu_leg2Pass")
        #if not self.singleMu_leg2Pass_branch and "singleMu_leg2Pass" not in self.complained:
        if not self.singleMu_leg2Pass_branch and "singleMu_leg2Pass":
            warnings.warn( "EEETree: Expected branch singleMu_leg2Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Pass")
        else:
            self.singleMu_leg2Pass_branch.SetAddress(<void*>&self.singleMu_leg2Pass_value)

        #print "making singleMu_leg2Prescale"
        self.singleMu_leg2Prescale_branch = the_tree.GetBranch("singleMu_leg2Prescale")
        #if not self.singleMu_leg2Prescale_branch and "singleMu_leg2Prescale" not in self.complained:
        if not self.singleMu_leg2Prescale_branch and "singleMu_leg2Prescale":
            warnings.warn( "EEETree: Expected branch singleMu_leg2Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Prescale")
        else:
            self.singleMu_leg2Prescale_branch.SetAddress(<void*>&self.singleMu_leg2Prescale_value)

        #print "making singleMu_leg2_noisoGroup"
        self.singleMu_leg2_noisoGroup_branch = the_tree.GetBranch("singleMu_leg2_noisoGroup")
        #if not self.singleMu_leg2_noisoGroup_branch and "singleMu_leg2_noisoGroup" not in self.complained:
        if not self.singleMu_leg2_noisoGroup_branch and "singleMu_leg2_noisoGroup":
            warnings.warn( "EEETree: Expected branch singleMu_leg2_noisoGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoGroup")
        else:
            self.singleMu_leg2_noisoGroup_branch.SetAddress(<void*>&self.singleMu_leg2_noisoGroup_value)

        #print "making singleMu_leg2_noisoPass"
        self.singleMu_leg2_noisoPass_branch = the_tree.GetBranch("singleMu_leg2_noisoPass")
        #if not self.singleMu_leg2_noisoPass_branch and "singleMu_leg2_noisoPass" not in self.complained:
        if not self.singleMu_leg2_noisoPass_branch and "singleMu_leg2_noisoPass":
            warnings.warn( "EEETree: Expected branch singleMu_leg2_noisoPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoPass")
        else:
            self.singleMu_leg2_noisoPass_branch.SetAddress(<void*>&self.singleMu_leg2_noisoPass_value)

        #print "making singleMu_leg2_noisoPrescale"
        self.singleMu_leg2_noisoPrescale_branch = the_tree.GetBranch("singleMu_leg2_noisoPrescale")
        #if not self.singleMu_leg2_noisoPrescale_branch and "singleMu_leg2_noisoPrescale" not in self.complained:
        if not self.singleMu_leg2_noisoPrescale_branch and "singleMu_leg2_noisoPrescale":
            warnings.warn( "EEETree: Expected branch singleMu_leg2_noisoPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoPrescale")
        else:
            self.singleMu_leg2_noisoPrescale_branch.SetAddress(<void*>&self.singleMu_leg2_noisoPrescale_value)

        #print "making tauVetoPt20Loose3HitsNewDMVtx"
        self.tauVetoPt20Loose3HitsNewDMVtx_branch = the_tree.GetBranch("tauVetoPt20Loose3HitsNewDMVtx")
        #if not self.tauVetoPt20Loose3HitsNewDMVtx_branch and "tauVetoPt20Loose3HitsNewDMVtx" not in self.complained:
        if not self.tauVetoPt20Loose3HitsNewDMVtx_branch and "tauVetoPt20Loose3HitsNewDMVtx":
            warnings.warn( "EEETree: Expected branch tauVetoPt20Loose3HitsNewDMVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20Loose3HitsNewDMVtx")
        else:
            self.tauVetoPt20Loose3HitsNewDMVtx_branch.SetAddress(<void*>&self.tauVetoPt20Loose3HitsNewDMVtx_value)

        #print "making tauVetoPt20Loose3HitsVtx"
        self.tauVetoPt20Loose3HitsVtx_branch = the_tree.GetBranch("tauVetoPt20Loose3HitsVtx")
        #if not self.tauVetoPt20Loose3HitsVtx_branch and "tauVetoPt20Loose3HitsVtx" not in self.complained:
        if not self.tauVetoPt20Loose3HitsVtx_branch and "tauVetoPt20Loose3HitsVtx":
            warnings.warn( "EEETree: Expected branch tauVetoPt20Loose3HitsVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20Loose3HitsVtx")
        else:
            self.tauVetoPt20Loose3HitsVtx_branch.SetAddress(<void*>&self.tauVetoPt20Loose3HitsVtx_value)

        #print "making tauVetoPt20TightMVALTNewDMVtx"
        self.tauVetoPt20TightMVALTNewDMVtx_branch = the_tree.GetBranch("tauVetoPt20TightMVALTNewDMVtx")
        #if not self.tauVetoPt20TightMVALTNewDMVtx_branch and "tauVetoPt20TightMVALTNewDMVtx" not in self.complained:
        if not self.tauVetoPt20TightMVALTNewDMVtx_branch and "tauVetoPt20TightMVALTNewDMVtx":
            warnings.warn( "EEETree: Expected branch tauVetoPt20TightMVALTNewDMVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20TightMVALTNewDMVtx")
        else:
            self.tauVetoPt20TightMVALTNewDMVtx_branch.SetAddress(<void*>&self.tauVetoPt20TightMVALTNewDMVtx_value)

        #print "making tauVetoPt20TightMVALTVtx"
        self.tauVetoPt20TightMVALTVtx_branch = the_tree.GetBranch("tauVetoPt20TightMVALTVtx")
        #if not self.tauVetoPt20TightMVALTVtx_branch and "tauVetoPt20TightMVALTVtx" not in self.complained:
        if not self.tauVetoPt20TightMVALTVtx_branch and "tauVetoPt20TightMVALTVtx":
            warnings.warn( "EEETree: Expected branch tauVetoPt20TightMVALTVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20TightMVALTVtx")
        else:
            self.tauVetoPt20TightMVALTVtx_branch.SetAddress(<void*>&self.tauVetoPt20TightMVALTVtx_value)

        #print "making tripleEGroup"
        self.tripleEGroup_branch = the_tree.GetBranch("tripleEGroup")
        #if not self.tripleEGroup_branch and "tripleEGroup" not in self.complained:
        if not self.tripleEGroup_branch and "tripleEGroup":
            warnings.warn( "EEETree: Expected branch tripleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEGroup")
        else:
            self.tripleEGroup_branch.SetAddress(<void*>&self.tripleEGroup_value)

        #print "making tripleEPass"
        self.tripleEPass_branch = the_tree.GetBranch("tripleEPass")
        #if not self.tripleEPass_branch and "tripleEPass" not in self.complained:
        if not self.tripleEPass_branch and "tripleEPass":
            warnings.warn( "EEETree: Expected branch tripleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEPass")
        else:
            self.tripleEPass_branch.SetAddress(<void*>&self.tripleEPass_value)

        #print "making tripleEPrescale"
        self.tripleEPrescale_branch = the_tree.GetBranch("tripleEPrescale")
        #if not self.tripleEPrescale_branch and "tripleEPrescale" not in self.complained:
        if not self.tripleEPrescale_branch and "tripleEPrescale":
            warnings.warn( "EEETree: Expected branch tripleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEPrescale")
        else:
            self.tripleEPrescale_branch.SetAddress(<void*>&self.tripleEPrescale_value)

        #print "making tripleMuGroup"
        self.tripleMuGroup_branch = the_tree.GetBranch("tripleMuGroup")
        #if not self.tripleMuGroup_branch and "tripleMuGroup" not in self.complained:
        if not self.tripleMuGroup_branch and "tripleMuGroup":
            warnings.warn( "EEETree: Expected branch tripleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuGroup")
        else:
            self.tripleMuGroup_branch.SetAddress(<void*>&self.tripleMuGroup_value)

        #print "making tripleMuPass"
        self.tripleMuPass_branch = the_tree.GetBranch("tripleMuPass")
        #if not self.tripleMuPass_branch and "tripleMuPass" not in self.complained:
        if not self.tripleMuPass_branch and "tripleMuPass":
            warnings.warn( "EEETree: Expected branch tripleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuPass")
        else:
            self.tripleMuPass_branch.SetAddress(<void*>&self.tripleMuPass_value)

        #print "making tripleMuPrescale"
        self.tripleMuPrescale_branch = the_tree.GetBranch("tripleMuPrescale")
        #if not self.tripleMuPrescale_branch and "tripleMuPrescale" not in self.complained:
        if not self.tripleMuPrescale_branch and "tripleMuPrescale":
            warnings.warn( "EEETree: Expected branch tripleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuPrescale")
        else:
            self.tripleMuPrescale_branch.SetAddress(<void*>&self.tripleMuPrescale_value)

        #print "making type1_pfMetEt"
        self.type1_pfMetEt_branch = the_tree.GetBranch("type1_pfMetEt")
        #if not self.type1_pfMetEt_branch and "type1_pfMetEt" not in self.complained:
        if not self.type1_pfMetEt_branch and "type1_pfMetEt":
            warnings.warn( "EEETree: Expected branch type1_pfMetEt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMetEt")
        else:
            self.type1_pfMetEt_branch.SetAddress(<void*>&self.type1_pfMetEt_value)

        #print "making type1_pfMetPhi"
        self.type1_pfMetPhi_branch = the_tree.GetBranch("type1_pfMetPhi")
        #if not self.type1_pfMetPhi_branch and "type1_pfMetPhi" not in self.complained:
        if not self.type1_pfMetPhi_branch and "type1_pfMetPhi":
            warnings.warn( "EEETree: Expected branch type1_pfMetPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMetPhi")
        else:
            self.type1_pfMetPhi_branch.SetAddress(<void*>&self.type1_pfMetPhi_value)

        #print "making type1_pfMet_shiftedPhi_ElectronEnDown"
        self.type1_pfMet_shiftedPhi_ElectronEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_ElectronEnDown")
        #if not self.type1_pfMet_shiftedPhi_ElectronEnDown_branch and "type1_pfMet_shiftedPhi_ElectronEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_ElectronEnDown_branch and "type1_pfMet_shiftedPhi_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_ElectronEnDown")
        else:
            self.type1_pfMet_shiftedPhi_ElectronEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_ElectronEnDown_value)

        #print "making type1_pfMet_shiftedPhi_ElectronEnUp"
        self.type1_pfMet_shiftedPhi_ElectronEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_ElectronEnUp")
        #if not self.type1_pfMet_shiftedPhi_ElectronEnUp_branch and "type1_pfMet_shiftedPhi_ElectronEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_ElectronEnUp_branch and "type1_pfMet_shiftedPhi_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_ElectronEnUp")
        else:
            self.type1_pfMet_shiftedPhi_ElectronEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_ElectronEnUp_value)

        #print "making type1_pfMet_shiftedPhi_JetEnDown"
        self.type1_pfMet_shiftedPhi_JetEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetEnDown")
        #if not self.type1_pfMet_shiftedPhi_JetEnDown_branch and "type1_pfMet_shiftedPhi_JetEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetEnDown_branch and "type1_pfMet_shiftedPhi_JetEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetEnDown")
        else:
            self.type1_pfMet_shiftedPhi_JetEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetEnDown_value)

        #print "making type1_pfMet_shiftedPhi_JetEnUp"
        self.type1_pfMet_shiftedPhi_JetEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetEnUp")
        #if not self.type1_pfMet_shiftedPhi_JetEnUp_branch and "type1_pfMet_shiftedPhi_JetEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetEnUp_branch and "type1_pfMet_shiftedPhi_JetEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetEnUp")
        else:
            self.type1_pfMet_shiftedPhi_JetEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetEnUp_value)

        #print "making type1_pfMet_shiftedPhi_JetResDown"
        self.type1_pfMet_shiftedPhi_JetResDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetResDown")
        #if not self.type1_pfMet_shiftedPhi_JetResDown_branch and "type1_pfMet_shiftedPhi_JetResDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetResDown_branch and "type1_pfMet_shiftedPhi_JetResDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetResDown")
        else:
            self.type1_pfMet_shiftedPhi_JetResDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetResDown_value)

        #print "making type1_pfMet_shiftedPhi_JetResUp"
        self.type1_pfMet_shiftedPhi_JetResUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetResUp")
        #if not self.type1_pfMet_shiftedPhi_JetResUp_branch and "type1_pfMet_shiftedPhi_JetResUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetResUp_branch and "type1_pfMet_shiftedPhi_JetResUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetResUp")
        else:
            self.type1_pfMet_shiftedPhi_JetResUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetResUp_value)

        #print "making type1_pfMet_shiftedPhi_MuonEnDown"
        self.type1_pfMet_shiftedPhi_MuonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_MuonEnDown")
        #if not self.type1_pfMet_shiftedPhi_MuonEnDown_branch and "type1_pfMet_shiftedPhi_MuonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_MuonEnDown_branch and "type1_pfMet_shiftedPhi_MuonEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_MuonEnDown")
        else:
            self.type1_pfMet_shiftedPhi_MuonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_MuonEnDown_value)

        #print "making type1_pfMet_shiftedPhi_MuonEnUp"
        self.type1_pfMet_shiftedPhi_MuonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_MuonEnUp")
        #if not self.type1_pfMet_shiftedPhi_MuonEnUp_branch and "type1_pfMet_shiftedPhi_MuonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_MuonEnUp_branch and "type1_pfMet_shiftedPhi_MuonEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_MuonEnUp")
        else:
            self.type1_pfMet_shiftedPhi_MuonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_MuonEnUp_value)

        #print "making type1_pfMet_shiftedPhi_PhotonEnDown"
        self.type1_pfMet_shiftedPhi_PhotonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_PhotonEnDown")
        #if not self.type1_pfMet_shiftedPhi_PhotonEnDown_branch and "type1_pfMet_shiftedPhi_PhotonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_PhotonEnDown_branch and "type1_pfMet_shiftedPhi_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_PhotonEnDown")
        else:
            self.type1_pfMet_shiftedPhi_PhotonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_PhotonEnDown_value)

        #print "making type1_pfMet_shiftedPhi_PhotonEnUp"
        self.type1_pfMet_shiftedPhi_PhotonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_PhotonEnUp")
        #if not self.type1_pfMet_shiftedPhi_PhotonEnUp_branch and "type1_pfMet_shiftedPhi_PhotonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_PhotonEnUp_branch and "type1_pfMet_shiftedPhi_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_PhotonEnUp")
        else:
            self.type1_pfMet_shiftedPhi_PhotonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_PhotonEnUp_value)

        #print "making type1_pfMet_shiftedPhi_TauEnDown"
        self.type1_pfMet_shiftedPhi_TauEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_TauEnDown")
        #if not self.type1_pfMet_shiftedPhi_TauEnDown_branch and "type1_pfMet_shiftedPhi_TauEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_TauEnDown_branch and "type1_pfMet_shiftedPhi_TauEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_TauEnDown")
        else:
            self.type1_pfMet_shiftedPhi_TauEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_TauEnDown_value)

        #print "making type1_pfMet_shiftedPhi_TauEnUp"
        self.type1_pfMet_shiftedPhi_TauEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_TauEnUp")
        #if not self.type1_pfMet_shiftedPhi_TauEnUp_branch and "type1_pfMet_shiftedPhi_TauEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_TauEnUp_branch and "type1_pfMet_shiftedPhi_TauEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_TauEnUp")
        else:
            self.type1_pfMet_shiftedPhi_TauEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_TauEnUp_value)

        #print "making type1_pfMet_shiftedPhi_UnclusteredEnDown"
        self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_UnclusteredEnDown")
        #if not self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch and "type1_pfMet_shiftedPhi_UnclusteredEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch and "type1_pfMet_shiftedPhi_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_UnclusteredEnDown")
        else:
            self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_UnclusteredEnDown_value)

        #print "making type1_pfMet_shiftedPhi_UnclusteredEnUp"
        self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_UnclusteredEnUp")
        #if not self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch and "type1_pfMet_shiftedPhi_UnclusteredEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch and "type1_pfMet_shiftedPhi_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPhi_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_UnclusteredEnUp")
        else:
            self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_UnclusteredEnUp_value)

        #print "making type1_pfMet_shiftedPt_ElectronEnDown"
        self.type1_pfMet_shiftedPt_ElectronEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_ElectronEnDown")
        #if not self.type1_pfMet_shiftedPt_ElectronEnDown_branch and "type1_pfMet_shiftedPt_ElectronEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_ElectronEnDown_branch and "type1_pfMet_shiftedPt_ElectronEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_ElectronEnDown")
        else:
            self.type1_pfMet_shiftedPt_ElectronEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_ElectronEnDown_value)

        #print "making type1_pfMet_shiftedPt_ElectronEnUp"
        self.type1_pfMet_shiftedPt_ElectronEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_ElectronEnUp")
        #if not self.type1_pfMet_shiftedPt_ElectronEnUp_branch and "type1_pfMet_shiftedPt_ElectronEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_ElectronEnUp_branch and "type1_pfMet_shiftedPt_ElectronEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_ElectronEnUp")
        else:
            self.type1_pfMet_shiftedPt_ElectronEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_ElectronEnUp_value)

        #print "making type1_pfMet_shiftedPt_JetEnDown"
        self.type1_pfMet_shiftedPt_JetEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetEnDown")
        #if not self.type1_pfMet_shiftedPt_JetEnDown_branch and "type1_pfMet_shiftedPt_JetEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetEnDown_branch and "type1_pfMet_shiftedPt_JetEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetEnDown")
        else:
            self.type1_pfMet_shiftedPt_JetEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetEnDown_value)

        #print "making type1_pfMet_shiftedPt_JetEnUp"
        self.type1_pfMet_shiftedPt_JetEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetEnUp")
        #if not self.type1_pfMet_shiftedPt_JetEnUp_branch and "type1_pfMet_shiftedPt_JetEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetEnUp_branch and "type1_pfMet_shiftedPt_JetEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetEnUp")
        else:
            self.type1_pfMet_shiftedPt_JetEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetEnUp_value)

        #print "making type1_pfMet_shiftedPt_JetResDown"
        self.type1_pfMet_shiftedPt_JetResDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetResDown")
        #if not self.type1_pfMet_shiftedPt_JetResDown_branch and "type1_pfMet_shiftedPt_JetResDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetResDown_branch and "type1_pfMet_shiftedPt_JetResDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetResDown")
        else:
            self.type1_pfMet_shiftedPt_JetResDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetResDown_value)

        #print "making type1_pfMet_shiftedPt_JetResUp"
        self.type1_pfMet_shiftedPt_JetResUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetResUp")
        #if not self.type1_pfMet_shiftedPt_JetResUp_branch and "type1_pfMet_shiftedPt_JetResUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetResUp_branch and "type1_pfMet_shiftedPt_JetResUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetResUp")
        else:
            self.type1_pfMet_shiftedPt_JetResUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetResUp_value)

        #print "making type1_pfMet_shiftedPt_MuonEnDown"
        self.type1_pfMet_shiftedPt_MuonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_MuonEnDown")
        #if not self.type1_pfMet_shiftedPt_MuonEnDown_branch and "type1_pfMet_shiftedPt_MuonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_MuonEnDown_branch and "type1_pfMet_shiftedPt_MuonEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_MuonEnDown")
        else:
            self.type1_pfMet_shiftedPt_MuonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_MuonEnDown_value)

        #print "making type1_pfMet_shiftedPt_MuonEnUp"
        self.type1_pfMet_shiftedPt_MuonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_MuonEnUp")
        #if not self.type1_pfMet_shiftedPt_MuonEnUp_branch and "type1_pfMet_shiftedPt_MuonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_MuonEnUp_branch and "type1_pfMet_shiftedPt_MuonEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_MuonEnUp")
        else:
            self.type1_pfMet_shiftedPt_MuonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_MuonEnUp_value)

        #print "making type1_pfMet_shiftedPt_PhotonEnDown"
        self.type1_pfMet_shiftedPt_PhotonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_PhotonEnDown")
        #if not self.type1_pfMet_shiftedPt_PhotonEnDown_branch and "type1_pfMet_shiftedPt_PhotonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_PhotonEnDown_branch and "type1_pfMet_shiftedPt_PhotonEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_PhotonEnDown")
        else:
            self.type1_pfMet_shiftedPt_PhotonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_PhotonEnDown_value)

        #print "making type1_pfMet_shiftedPt_PhotonEnUp"
        self.type1_pfMet_shiftedPt_PhotonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_PhotonEnUp")
        #if not self.type1_pfMet_shiftedPt_PhotonEnUp_branch and "type1_pfMet_shiftedPt_PhotonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_PhotonEnUp_branch and "type1_pfMet_shiftedPt_PhotonEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_PhotonEnUp")
        else:
            self.type1_pfMet_shiftedPt_PhotonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_PhotonEnUp_value)

        #print "making type1_pfMet_shiftedPt_TauEnDown"
        self.type1_pfMet_shiftedPt_TauEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_TauEnDown")
        #if not self.type1_pfMet_shiftedPt_TauEnDown_branch and "type1_pfMet_shiftedPt_TauEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_TauEnDown_branch and "type1_pfMet_shiftedPt_TauEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_TauEnDown")
        else:
            self.type1_pfMet_shiftedPt_TauEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_TauEnDown_value)

        #print "making type1_pfMet_shiftedPt_TauEnUp"
        self.type1_pfMet_shiftedPt_TauEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_TauEnUp")
        #if not self.type1_pfMet_shiftedPt_TauEnUp_branch and "type1_pfMet_shiftedPt_TauEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_TauEnUp_branch and "type1_pfMet_shiftedPt_TauEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_TauEnUp")
        else:
            self.type1_pfMet_shiftedPt_TauEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_TauEnUp_value)

        #print "making type1_pfMet_shiftedPt_UnclusteredEnDown"
        self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_UnclusteredEnDown")
        #if not self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch and "type1_pfMet_shiftedPt_UnclusteredEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch and "type1_pfMet_shiftedPt_UnclusteredEnDown":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_UnclusteredEnDown")
        else:
            self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_UnclusteredEnDown_value)

        #print "making type1_pfMet_shiftedPt_UnclusteredEnUp"
        self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_UnclusteredEnUp")
        #if not self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch and "type1_pfMet_shiftedPt_UnclusteredEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch and "type1_pfMet_shiftedPt_UnclusteredEnUp":
            warnings.warn( "EEETree: Expected branch type1_pfMet_shiftedPt_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_UnclusteredEnUp")
        else:
            self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_UnclusteredEnUp_value)

        #print "making vbfDeta"
        self.vbfDeta_branch = the_tree.GetBranch("vbfDeta")
        #if not self.vbfDeta_branch and "vbfDeta" not in self.complained:
        if not self.vbfDeta_branch and "vbfDeta":
            warnings.warn( "EEETree: Expected branch vbfDeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta")
        else:
            self.vbfDeta_branch.SetAddress(<void*>&self.vbfDeta_value)

        #print "making vbfDeta_JetEnDown"
        self.vbfDeta_JetEnDown_branch = the_tree.GetBranch("vbfDeta_JetEnDown")
        #if not self.vbfDeta_JetEnDown_branch and "vbfDeta_JetEnDown" not in self.complained:
        if not self.vbfDeta_JetEnDown_branch and "vbfDeta_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfDeta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta_JetEnDown")
        else:
            self.vbfDeta_JetEnDown_branch.SetAddress(<void*>&self.vbfDeta_JetEnDown_value)

        #print "making vbfDeta_JetEnUp"
        self.vbfDeta_JetEnUp_branch = the_tree.GetBranch("vbfDeta_JetEnUp")
        #if not self.vbfDeta_JetEnUp_branch and "vbfDeta_JetEnUp" not in self.complained:
        if not self.vbfDeta_JetEnUp_branch and "vbfDeta_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfDeta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta_JetEnUp")
        else:
            self.vbfDeta_JetEnUp_branch.SetAddress(<void*>&self.vbfDeta_JetEnUp_value)

        #print "making vbfDijetrap"
        self.vbfDijetrap_branch = the_tree.GetBranch("vbfDijetrap")
        #if not self.vbfDijetrap_branch and "vbfDijetrap" not in self.complained:
        if not self.vbfDijetrap_branch and "vbfDijetrap":
            warnings.warn( "EEETree: Expected branch vbfDijetrap does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap")
        else:
            self.vbfDijetrap_branch.SetAddress(<void*>&self.vbfDijetrap_value)

        #print "making vbfDijetrap_JetEnDown"
        self.vbfDijetrap_JetEnDown_branch = the_tree.GetBranch("vbfDijetrap_JetEnDown")
        #if not self.vbfDijetrap_JetEnDown_branch and "vbfDijetrap_JetEnDown" not in self.complained:
        if not self.vbfDijetrap_JetEnDown_branch and "vbfDijetrap_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfDijetrap_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap_JetEnDown")
        else:
            self.vbfDijetrap_JetEnDown_branch.SetAddress(<void*>&self.vbfDijetrap_JetEnDown_value)

        #print "making vbfDijetrap_JetEnUp"
        self.vbfDijetrap_JetEnUp_branch = the_tree.GetBranch("vbfDijetrap_JetEnUp")
        #if not self.vbfDijetrap_JetEnUp_branch and "vbfDijetrap_JetEnUp" not in self.complained:
        if not self.vbfDijetrap_JetEnUp_branch and "vbfDijetrap_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfDijetrap_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap_JetEnUp")
        else:
            self.vbfDijetrap_JetEnUp_branch.SetAddress(<void*>&self.vbfDijetrap_JetEnUp_value)

        #print "making vbfDphi"
        self.vbfDphi_branch = the_tree.GetBranch("vbfDphi")
        #if not self.vbfDphi_branch and "vbfDphi" not in self.complained:
        if not self.vbfDphi_branch and "vbfDphi":
            warnings.warn( "EEETree: Expected branch vbfDphi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi")
        else:
            self.vbfDphi_branch.SetAddress(<void*>&self.vbfDphi_value)

        #print "making vbfDphi_JetEnDown"
        self.vbfDphi_JetEnDown_branch = the_tree.GetBranch("vbfDphi_JetEnDown")
        #if not self.vbfDphi_JetEnDown_branch and "vbfDphi_JetEnDown" not in self.complained:
        if not self.vbfDphi_JetEnDown_branch and "vbfDphi_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfDphi_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi_JetEnDown")
        else:
            self.vbfDphi_JetEnDown_branch.SetAddress(<void*>&self.vbfDphi_JetEnDown_value)

        #print "making vbfDphi_JetEnUp"
        self.vbfDphi_JetEnUp_branch = the_tree.GetBranch("vbfDphi_JetEnUp")
        #if not self.vbfDphi_JetEnUp_branch and "vbfDphi_JetEnUp" not in self.complained:
        if not self.vbfDphi_JetEnUp_branch and "vbfDphi_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfDphi_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi_JetEnUp")
        else:
            self.vbfDphi_JetEnUp_branch.SetAddress(<void*>&self.vbfDphi_JetEnUp_value)

        #print "making vbfDphihj"
        self.vbfDphihj_branch = the_tree.GetBranch("vbfDphihj")
        #if not self.vbfDphihj_branch and "vbfDphihj" not in self.complained:
        if not self.vbfDphihj_branch and "vbfDphihj":
            warnings.warn( "EEETree: Expected branch vbfDphihj does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj")
        else:
            self.vbfDphihj_branch.SetAddress(<void*>&self.vbfDphihj_value)

        #print "making vbfDphihj_JetEnDown"
        self.vbfDphihj_JetEnDown_branch = the_tree.GetBranch("vbfDphihj_JetEnDown")
        #if not self.vbfDphihj_JetEnDown_branch and "vbfDphihj_JetEnDown" not in self.complained:
        if not self.vbfDphihj_JetEnDown_branch and "vbfDphihj_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfDphihj_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj_JetEnDown")
        else:
            self.vbfDphihj_JetEnDown_branch.SetAddress(<void*>&self.vbfDphihj_JetEnDown_value)

        #print "making vbfDphihj_JetEnUp"
        self.vbfDphihj_JetEnUp_branch = the_tree.GetBranch("vbfDphihj_JetEnUp")
        #if not self.vbfDphihj_JetEnUp_branch and "vbfDphihj_JetEnUp" not in self.complained:
        if not self.vbfDphihj_JetEnUp_branch and "vbfDphihj_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfDphihj_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj_JetEnUp")
        else:
            self.vbfDphihj_JetEnUp_branch.SetAddress(<void*>&self.vbfDphihj_JetEnUp_value)

        #print "making vbfDphihjnomet"
        self.vbfDphihjnomet_branch = the_tree.GetBranch("vbfDphihjnomet")
        #if not self.vbfDphihjnomet_branch and "vbfDphihjnomet" not in self.complained:
        if not self.vbfDphihjnomet_branch and "vbfDphihjnomet":
            warnings.warn( "EEETree: Expected branch vbfDphihjnomet does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet")
        else:
            self.vbfDphihjnomet_branch.SetAddress(<void*>&self.vbfDphihjnomet_value)

        #print "making vbfDphihjnomet_JetEnDown"
        self.vbfDphihjnomet_JetEnDown_branch = the_tree.GetBranch("vbfDphihjnomet_JetEnDown")
        #if not self.vbfDphihjnomet_JetEnDown_branch and "vbfDphihjnomet_JetEnDown" not in self.complained:
        if not self.vbfDphihjnomet_JetEnDown_branch and "vbfDphihjnomet_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfDphihjnomet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet_JetEnDown")
        else:
            self.vbfDphihjnomet_JetEnDown_branch.SetAddress(<void*>&self.vbfDphihjnomet_JetEnDown_value)

        #print "making vbfDphihjnomet_JetEnUp"
        self.vbfDphihjnomet_JetEnUp_branch = the_tree.GetBranch("vbfDphihjnomet_JetEnUp")
        #if not self.vbfDphihjnomet_JetEnUp_branch and "vbfDphihjnomet_JetEnUp" not in self.complained:
        if not self.vbfDphihjnomet_JetEnUp_branch and "vbfDphihjnomet_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfDphihjnomet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet_JetEnUp")
        else:
            self.vbfDphihjnomet_JetEnUp_branch.SetAddress(<void*>&self.vbfDphihjnomet_JetEnUp_value)

        #print "making vbfHrap"
        self.vbfHrap_branch = the_tree.GetBranch("vbfHrap")
        #if not self.vbfHrap_branch and "vbfHrap" not in self.complained:
        if not self.vbfHrap_branch and "vbfHrap":
            warnings.warn( "EEETree: Expected branch vbfHrap does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap")
        else:
            self.vbfHrap_branch.SetAddress(<void*>&self.vbfHrap_value)

        #print "making vbfHrap_JetEnDown"
        self.vbfHrap_JetEnDown_branch = the_tree.GetBranch("vbfHrap_JetEnDown")
        #if not self.vbfHrap_JetEnDown_branch and "vbfHrap_JetEnDown" not in self.complained:
        if not self.vbfHrap_JetEnDown_branch and "vbfHrap_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfHrap_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap_JetEnDown")
        else:
            self.vbfHrap_JetEnDown_branch.SetAddress(<void*>&self.vbfHrap_JetEnDown_value)

        #print "making vbfHrap_JetEnUp"
        self.vbfHrap_JetEnUp_branch = the_tree.GetBranch("vbfHrap_JetEnUp")
        #if not self.vbfHrap_JetEnUp_branch and "vbfHrap_JetEnUp" not in self.complained:
        if not self.vbfHrap_JetEnUp_branch and "vbfHrap_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfHrap_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap_JetEnUp")
        else:
            self.vbfHrap_JetEnUp_branch.SetAddress(<void*>&self.vbfHrap_JetEnUp_value)

        #print "making vbfJetVeto20"
        self.vbfJetVeto20_branch = the_tree.GetBranch("vbfJetVeto20")
        #if not self.vbfJetVeto20_branch and "vbfJetVeto20" not in self.complained:
        if not self.vbfJetVeto20_branch and "vbfJetVeto20":
            warnings.warn( "EEETree: Expected branch vbfJetVeto20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20")
        else:
            self.vbfJetVeto20_branch.SetAddress(<void*>&self.vbfJetVeto20_value)

        #print "making vbfJetVeto20_JetEnDown"
        self.vbfJetVeto20_JetEnDown_branch = the_tree.GetBranch("vbfJetVeto20_JetEnDown")
        #if not self.vbfJetVeto20_JetEnDown_branch and "vbfJetVeto20_JetEnDown" not in self.complained:
        if not self.vbfJetVeto20_JetEnDown_branch and "vbfJetVeto20_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfJetVeto20_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20_JetEnDown")
        else:
            self.vbfJetVeto20_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVeto20_JetEnDown_value)

        #print "making vbfJetVeto20_JetEnUp"
        self.vbfJetVeto20_JetEnUp_branch = the_tree.GetBranch("vbfJetVeto20_JetEnUp")
        #if not self.vbfJetVeto20_JetEnUp_branch and "vbfJetVeto20_JetEnUp" not in self.complained:
        if not self.vbfJetVeto20_JetEnUp_branch and "vbfJetVeto20_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfJetVeto20_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20_JetEnUp")
        else:
            self.vbfJetVeto20_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVeto20_JetEnUp_value)

        #print "making vbfJetVeto30"
        self.vbfJetVeto30_branch = the_tree.GetBranch("vbfJetVeto30")
        #if not self.vbfJetVeto30_branch and "vbfJetVeto30" not in self.complained:
        if not self.vbfJetVeto30_branch and "vbfJetVeto30":
            warnings.warn( "EEETree: Expected branch vbfJetVeto30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30")
        else:
            self.vbfJetVeto30_branch.SetAddress(<void*>&self.vbfJetVeto30_value)

        #print "making vbfJetVeto30_JetEnDown"
        self.vbfJetVeto30_JetEnDown_branch = the_tree.GetBranch("vbfJetVeto30_JetEnDown")
        #if not self.vbfJetVeto30_JetEnDown_branch and "vbfJetVeto30_JetEnDown" not in self.complained:
        if not self.vbfJetVeto30_JetEnDown_branch and "vbfJetVeto30_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfJetVeto30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30_JetEnDown")
        else:
            self.vbfJetVeto30_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVeto30_JetEnDown_value)

        #print "making vbfJetVeto30_JetEnUp"
        self.vbfJetVeto30_JetEnUp_branch = the_tree.GetBranch("vbfJetVeto30_JetEnUp")
        #if not self.vbfJetVeto30_JetEnUp_branch and "vbfJetVeto30_JetEnUp" not in self.complained:
        if not self.vbfJetVeto30_JetEnUp_branch and "vbfJetVeto30_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfJetVeto30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30_JetEnUp")
        else:
            self.vbfJetVeto30_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVeto30_JetEnUp_value)

        #print "making vbfJetVetoTight20"
        self.vbfJetVetoTight20_branch = the_tree.GetBranch("vbfJetVetoTight20")
        #if not self.vbfJetVetoTight20_branch and "vbfJetVetoTight20" not in self.complained:
        if not self.vbfJetVetoTight20_branch and "vbfJetVetoTight20":
            warnings.warn( "EEETree: Expected branch vbfJetVetoTight20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20")
        else:
            self.vbfJetVetoTight20_branch.SetAddress(<void*>&self.vbfJetVetoTight20_value)

        #print "making vbfJetVetoTight20_JetEnDown"
        self.vbfJetVetoTight20_JetEnDown_branch = the_tree.GetBranch("vbfJetVetoTight20_JetEnDown")
        #if not self.vbfJetVetoTight20_JetEnDown_branch and "vbfJetVetoTight20_JetEnDown" not in self.complained:
        if not self.vbfJetVetoTight20_JetEnDown_branch and "vbfJetVetoTight20_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfJetVetoTight20_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20_JetEnDown")
        else:
            self.vbfJetVetoTight20_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVetoTight20_JetEnDown_value)

        #print "making vbfJetVetoTight20_JetEnUp"
        self.vbfJetVetoTight20_JetEnUp_branch = the_tree.GetBranch("vbfJetVetoTight20_JetEnUp")
        #if not self.vbfJetVetoTight20_JetEnUp_branch and "vbfJetVetoTight20_JetEnUp" not in self.complained:
        if not self.vbfJetVetoTight20_JetEnUp_branch and "vbfJetVetoTight20_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfJetVetoTight20_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20_JetEnUp")
        else:
            self.vbfJetVetoTight20_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVetoTight20_JetEnUp_value)

        #print "making vbfJetVetoTight30"
        self.vbfJetVetoTight30_branch = the_tree.GetBranch("vbfJetVetoTight30")
        #if not self.vbfJetVetoTight30_branch and "vbfJetVetoTight30" not in self.complained:
        if not self.vbfJetVetoTight30_branch and "vbfJetVetoTight30":
            warnings.warn( "EEETree: Expected branch vbfJetVetoTight30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30")
        else:
            self.vbfJetVetoTight30_branch.SetAddress(<void*>&self.vbfJetVetoTight30_value)

        #print "making vbfJetVetoTight30_JetEnDown"
        self.vbfJetVetoTight30_JetEnDown_branch = the_tree.GetBranch("vbfJetVetoTight30_JetEnDown")
        #if not self.vbfJetVetoTight30_JetEnDown_branch and "vbfJetVetoTight30_JetEnDown" not in self.complained:
        if not self.vbfJetVetoTight30_JetEnDown_branch and "vbfJetVetoTight30_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfJetVetoTight30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30_JetEnDown")
        else:
            self.vbfJetVetoTight30_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVetoTight30_JetEnDown_value)

        #print "making vbfJetVetoTight30_JetEnUp"
        self.vbfJetVetoTight30_JetEnUp_branch = the_tree.GetBranch("vbfJetVetoTight30_JetEnUp")
        #if not self.vbfJetVetoTight30_JetEnUp_branch and "vbfJetVetoTight30_JetEnUp" not in self.complained:
        if not self.vbfJetVetoTight30_JetEnUp_branch and "vbfJetVetoTight30_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfJetVetoTight30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30_JetEnUp")
        else:
            self.vbfJetVetoTight30_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVetoTight30_JetEnUp_value)

        #print "making vbfMVA"
        self.vbfMVA_branch = the_tree.GetBranch("vbfMVA")
        #if not self.vbfMVA_branch and "vbfMVA" not in self.complained:
        if not self.vbfMVA_branch and "vbfMVA":
            warnings.warn( "EEETree: Expected branch vbfMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA")
        else:
            self.vbfMVA_branch.SetAddress(<void*>&self.vbfMVA_value)

        #print "making vbfMVA_JetEnDown"
        self.vbfMVA_JetEnDown_branch = the_tree.GetBranch("vbfMVA_JetEnDown")
        #if not self.vbfMVA_JetEnDown_branch and "vbfMVA_JetEnDown" not in self.complained:
        if not self.vbfMVA_JetEnDown_branch and "vbfMVA_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfMVA_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA_JetEnDown")
        else:
            self.vbfMVA_JetEnDown_branch.SetAddress(<void*>&self.vbfMVA_JetEnDown_value)

        #print "making vbfMVA_JetEnUp"
        self.vbfMVA_JetEnUp_branch = the_tree.GetBranch("vbfMVA_JetEnUp")
        #if not self.vbfMVA_JetEnUp_branch and "vbfMVA_JetEnUp" not in self.complained:
        if not self.vbfMVA_JetEnUp_branch and "vbfMVA_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfMVA_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA_JetEnUp")
        else:
            self.vbfMVA_JetEnUp_branch.SetAddress(<void*>&self.vbfMVA_JetEnUp_value)

        #print "making vbfMass"
        self.vbfMass_branch = the_tree.GetBranch("vbfMass")
        #if not self.vbfMass_branch and "vbfMass" not in self.complained:
        if not self.vbfMass_branch and "vbfMass":
            warnings.warn( "EEETree: Expected branch vbfMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass")
        else:
            self.vbfMass_branch.SetAddress(<void*>&self.vbfMass_value)

        #print "making vbfMass_JetEnDown"
        self.vbfMass_JetEnDown_branch = the_tree.GetBranch("vbfMass_JetEnDown")
        #if not self.vbfMass_JetEnDown_branch and "vbfMass_JetEnDown" not in self.complained:
        if not self.vbfMass_JetEnDown_branch and "vbfMass_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfMass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass_JetEnDown")
        else:
            self.vbfMass_JetEnDown_branch.SetAddress(<void*>&self.vbfMass_JetEnDown_value)

        #print "making vbfMass_JetEnUp"
        self.vbfMass_JetEnUp_branch = the_tree.GetBranch("vbfMass_JetEnUp")
        #if not self.vbfMass_JetEnUp_branch and "vbfMass_JetEnUp" not in self.complained:
        if not self.vbfMass_JetEnUp_branch and "vbfMass_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfMass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass_JetEnUp")
        else:
            self.vbfMass_JetEnUp_branch.SetAddress(<void*>&self.vbfMass_JetEnUp_value)

        #print "making vbfNJets"
        self.vbfNJets_branch = the_tree.GetBranch("vbfNJets")
        #if not self.vbfNJets_branch and "vbfNJets" not in self.complained:
        if not self.vbfNJets_branch and "vbfNJets":
            warnings.warn( "EEETree: Expected branch vbfNJets does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets")
        else:
            self.vbfNJets_branch.SetAddress(<void*>&self.vbfNJets_value)

        #print "making vbfNJets_JetEnDown"
        self.vbfNJets_JetEnDown_branch = the_tree.GetBranch("vbfNJets_JetEnDown")
        #if not self.vbfNJets_JetEnDown_branch and "vbfNJets_JetEnDown" not in self.complained:
        if not self.vbfNJets_JetEnDown_branch and "vbfNJets_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfNJets_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets_JetEnDown")
        else:
            self.vbfNJets_JetEnDown_branch.SetAddress(<void*>&self.vbfNJets_JetEnDown_value)

        #print "making vbfNJets_JetEnUp"
        self.vbfNJets_JetEnUp_branch = the_tree.GetBranch("vbfNJets_JetEnUp")
        #if not self.vbfNJets_JetEnUp_branch and "vbfNJets_JetEnUp" not in self.complained:
        if not self.vbfNJets_JetEnUp_branch and "vbfNJets_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfNJets_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets_JetEnUp")
        else:
            self.vbfNJets_JetEnUp_branch.SetAddress(<void*>&self.vbfNJets_JetEnUp_value)

        #print "making vbfVispt"
        self.vbfVispt_branch = the_tree.GetBranch("vbfVispt")
        #if not self.vbfVispt_branch and "vbfVispt" not in self.complained:
        if not self.vbfVispt_branch and "vbfVispt":
            warnings.warn( "EEETree: Expected branch vbfVispt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt")
        else:
            self.vbfVispt_branch.SetAddress(<void*>&self.vbfVispt_value)

        #print "making vbfVispt_JetEnDown"
        self.vbfVispt_JetEnDown_branch = the_tree.GetBranch("vbfVispt_JetEnDown")
        #if not self.vbfVispt_JetEnDown_branch and "vbfVispt_JetEnDown" not in self.complained:
        if not self.vbfVispt_JetEnDown_branch and "vbfVispt_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfVispt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt_JetEnDown")
        else:
            self.vbfVispt_JetEnDown_branch.SetAddress(<void*>&self.vbfVispt_JetEnDown_value)

        #print "making vbfVispt_JetEnUp"
        self.vbfVispt_JetEnUp_branch = the_tree.GetBranch("vbfVispt_JetEnUp")
        #if not self.vbfVispt_JetEnUp_branch and "vbfVispt_JetEnUp" not in self.complained:
        if not self.vbfVispt_JetEnUp_branch and "vbfVispt_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfVispt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt_JetEnUp")
        else:
            self.vbfVispt_JetEnUp_branch.SetAddress(<void*>&self.vbfVispt_JetEnUp_value)

        #print "making vbfdijetpt"
        self.vbfdijetpt_branch = the_tree.GetBranch("vbfdijetpt")
        #if not self.vbfdijetpt_branch and "vbfdijetpt" not in self.complained:
        if not self.vbfdijetpt_branch and "vbfdijetpt":
            warnings.warn( "EEETree: Expected branch vbfdijetpt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt")
        else:
            self.vbfdijetpt_branch.SetAddress(<void*>&self.vbfdijetpt_value)

        #print "making vbfdijetpt_JetEnDown"
        self.vbfdijetpt_JetEnDown_branch = the_tree.GetBranch("vbfdijetpt_JetEnDown")
        #if not self.vbfdijetpt_JetEnDown_branch and "vbfdijetpt_JetEnDown" not in self.complained:
        if not self.vbfdijetpt_JetEnDown_branch and "vbfdijetpt_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfdijetpt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt_JetEnDown")
        else:
            self.vbfdijetpt_JetEnDown_branch.SetAddress(<void*>&self.vbfdijetpt_JetEnDown_value)

        #print "making vbfdijetpt_JetEnUp"
        self.vbfdijetpt_JetEnUp_branch = the_tree.GetBranch("vbfdijetpt_JetEnUp")
        #if not self.vbfdijetpt_JetEnUp_branch and "vbfdijetpt_JetEnUp" not in self.complained:
        if not self.vbfdijetpt_JetEnUp_branch and "vbfdijetpt_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfdijetpt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt_JetEnUp")
        else:
            self.vbfdijetpt_JetEnUp_branch.SetAddress(<void*>&self.vbfdijetpt_JetEnUp_value)

        #print "making vbfditaupt"
        self.vbfditaupt_branch = the_tree.GetBranch("vbfditaupt")
        #if not self.vbfditaupt_branch and "vbfditaupt" not in self.complained:
        if not self.vbfditaupt_branch and "vbfditaupt":
            warnings.warn( "EEETree: Expected branch vbfditaupt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt")
        else:
            self.vbfditaupt_branch.SetAddress(<void*>&self.vbfditaupt_value)

        #print "making vbfditaupt_JetEnDown"
        self.vbfditaupt_JetEnDown_branch = the_tree.GetBranch("vbfditaupt_JetEnDown")
        #if not self.vbfditaupt_JetEnDown_branch and "vbfditaupt_JetEnDown" not in self.complained:
        if not self.vbfditaupt_JetEnDown_branch and "vbfditaupt_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfditaupt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt_JetEnDown")
        else:
            self.vbfditaupt_JetEnDown_branch.SetAddress(<void*>&self.vbfditaupt_JetEnDown_value)

        #print "making vbfditaupt_JetEnUp"
        self.vbfditaupt_JetEnUp_branch = the_tree.GetBranch("vbfditaupt_JetEnUp")
        #if not self.vbfditaupt_JetEnUp_branch and "vbfditaupt_JetEnUp" not in self.complained:
        if not self.vbfditaupt_JetEnUp_branch and "vbfditaupt_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfditaupt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt_JetEnUp")
        else:
            self.vbfditaupt_JetEnUp_branch.SetAddress(<void*>&self.vbfditaupt_JetEnUp_value)

        #print "making vbfj1eta"
        self.vbfj1eta_branch = the_tree.GetBranch("vbfj1eta")
        #if not self.vbfj1eta_branch and "vbfj1eta" not in self.complained:
        if not self.vbfj1eta_branch and "vbfj1eta":
            warnings.warn( "EEETree: Expected branch vbfj1eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta")
        else:
            self.vbfj1eta_branch.SetAddress(<void*>&self.vbfj1eta_value)

        #print "making vbfj1eta_JetEnDown"
        self.vbfj1eta_JetEnDown_branch = the_tree.GetBranch("vbfj1eta_JetEnDown")
        #if not self.vbfj1eta_JetEnDown_branch and "vbfj1eta_JetEnDown" not in self.complained:
        if not self.vbfj1eta_JetEnDown_branch and "vbfj1eta_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfj1eta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta_JetEnDown")
        else:
            self.vbfj1eta_JetEnDown_branch.SetAddress(<void*>&self.vbfj1eta_JetEnDown_value)

        #print "making vbfj1eta_JetEnUp"
        self.vbfj1eta_JetEnUp_branch = the_tree.GetBranch("vbfj1eta_JetEnUp")
        #if not self.vbfj1eta_JetEnUp_branch and "vbfj1eta_JetEnUp" not in self.complained:
        if not self.vbfj1eta_JetEnUp_branch and "vbfj1eta_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfj1eta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta_JetEnUp")
        else:
            self.vbfj1eta_JetEnUp_branch.SetAddress(<void*>&self.vbfj1eta_JetEnUp_value)

        #print "making vbfj1pt"
        self.vbfj1pt_branch = the_tree.GetBranch("vbfj1pt")
        #if not self.vbfj1pt_branch and "vbfj1pt" not in self.complained:
        if not self.vbfj1pt_branch and "vbfj1pt":
            warnings.warn( "EEETree: Expected branch vbfj1pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt")
        else:
            self.vbfj1pt_branch.SetAddress(<void*>&self.vbfj1pt_value)

        #print "making vbfj1pt_JetEnDown"
        self.vbfj1pt_JetEnDown_branch = the_tree.GetBranch("vbfj1pt_JetEnDown")
        #if not self.vbfj1pt_JetEnDown_branch and "vbfj1pt_JetEnDown" not in self.complained:
        if not self.vbfj1pt_JetEnDown_branch and "vbfj1pt_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfj1pt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt_JetEnDown")
        else:
            self.vbfj1pt_JetEnDown_branch.SetAddress(<void*>&self.vbfj1pt_JetEnDown_value)

        #print "making vbfj1pt_JetEnUp"
        self.vbfj1pt_JetEnUp_branch = the_tree.GetBranch("vbfj1pt_JetEnUp")
        #if not self.vbfj1pt_JetEnUp_branch and "vbfj1pt_JetEnUp" not in self.complained:
        if not self.vbfj1pt_JetEnUp_branch and "vbfj1pt_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfj1pt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt_JetEnUp")
        else:
            self.vbfj1pt_JetEnUp_branch.SetAddress(<void*>&self.vbfj1pt_JetEnUp_value)

        #print "making vbfj2eta"
        self.vbfj2eta_branch = the_tree.GetBranch("vbfj2eta")
        #if not self.vbfj2eta_branch and "vbfj2eta" not in self.complained:
        if not self.vbfj2eta_branch and "vbfj2eta":
            warnings.warn( "EEETree: Expected branch vbfj2eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta")
        else:
            self.vbfj2eta_branch.SetAddress(<void*>&self.vbfj2eta_value)

        #print "making vbfj2eta_JetEnDown"
        self.vbfj2eta_JetEnDown_branch = the_tree.GetBranch("vbfj2eta_JetEnDown")
        #if not self.vbfj2eta_JetEnDown_branch and "vbfj2eta_JetEnDown" not in self.complained:
        if not self.vbfj2eta_JetEnDown_branch and "vbfj2eta_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfj2eta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta_JetEnDown")
        else:
            self.vbfj2eta_JetEnDown_branch.SetAddress(<void*>&self.vbfj2eta_JetEnDown_value)

        #print "making vbfj2eta_JetEnUp"
        self.vbfj2eta_JetEnUp_branch = the_tree.GetBranch("vbfj2eta_JetEnUp")
        #if not self.vbfj2eta_JetEnUp_branch and "vbfj2eta_JetEnUp" not in self.complained:
        if not self.vbfj2eta_JetEnUp_branch and "vbfj2eta_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfj2eta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta_JetEnUp")
        else:
            self.vbfj2eta_JetEnUp_branch.SetAddress(<void*>&self.vbfj2eta_JetEnUp_value)

        #print "making vbfj2pt"
        self.vbfj2pt_branch = the_tree.GetBranch("vbfj2pt")
        #if not self.vbfj2pt_branch and "vbfj2pt" not in self.complained:
        if not self.vbfj2pt_branch and "vbfj2pt":
            warnings.warn( "EEETree: Expected branch vbfj2pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt")
        else:
            self.vbfj2pt_branch.SetAddress(<void*>&self.vbfj2pt_value)

        #print "making vbfj2pt_JetEnDown"
        self.vbfj2pt_JetEnDown_branch = the_tree.GetBranch("vbfj2pt_JetEnDown")
        #if not self.vbfj2pt_JetEnDown_branch and "vbfj2pt_JetEnDown" not in self.complained:
        if not self.vbfj2pt_JetEnDown_branch and "vbfj2pt_JetEnDown":
            warnings.warn( "EEETree: Expected branch vbfj2pt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt_JetEnDown")
        else:
            self.vbfj2pt_JetEnDown_branch.SetAddress(<void*>&self.vbfj2pt_JetEnDown_value)

        #print "making vbfj2pt_JetEnUp"
        self.vbfj2pt_JetEnUp_branch = the_tree.GetBranch("vbfj2pt_JetEnUp")
        #if not self.vbfj2pt_JetEnUp_branch and "vbfj2pt_JetEnUp" not in self.complained:
        if not self.vbfj2pt_JetEnUp_branch and "vbfj2pt_JetEnUp":
            warnings.warn( "EEETree: Expected branch vbfj2pt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt_JetEnUp")
        else:
            self.vbfj2pt_JetEnUp_branch.SetAddress(<void*>&self.vbfj2pt_JetEnUp_value)

        #print "making idx"
        self.idx_branch = the_tree.GetBranch("idx")
        #if not self.idx_branch and "idx" not in self.complained:
        if not self.idx_branch and "idx":
            warnings.warn( "EEETree: Expected branch idx does not exist!"                " It will crash if you try and use it!",Warning)
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

    property e1AbsEta:
        def __get__(self):
            self.e1AbsEta_branch.GetEntry(self.localentry, 0)
            return self.e1AbsEta_value

    property e1CBIDLoose:
        def __get__(self):
            self.e1CBIDLoose_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDLoose_value

    property e1CBIDLooseNoIso:
        def __get__(self):
            self.e1CBIDLooseNoIso_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDLooseNoIso_value

    property e1CBIDMedium:
        def __get__(self):
            self.e1CBIDMedium_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDMedium_value

    property e1CBIDMediumNoIso:
        def __get__(self):
            self.e1CBIDMediumNoIso_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDMediumNoIso_value

    property e1CBIDTight:
        def __get__(self):
            self.e1CBIDTight_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDTight_value

    property e1CBIDTightNoIso:
        def __get__(self):
            self.e1CBIDTightNoIso_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDTightNoIso_value

    property e1CBIDVeto:
        def __get__(self):
            self.e1CBIDVeto_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDVeto_value

    property e1CBIDVetoNoIso:
        def __get__(self):
            self.e1CBIDVetoNoIso_branch.GetEntry(self.localentry, 0)
            return self.e1CBIDVetoNoIso_value

    property e1Charge:
        def __get__(self):
            self.e1Charge_branch.GetEntry(self.localentry, 0)
            return self.e1Charge_value

    property e1ChargeIdLoose:
        def __get__(self):
            self.e1ChargeIdLoose_branch.GetEntry(self.localentry, 0)
            return self.e1ChargeIdLoose_value

    property e1ChargeIdMed:
        def __get__(self):
            self.e1ChargeIdMed_branch.GetEntry(self.localentry, 0)
            return self.e1ChargeIdMed_value

    property e1ChargeIdTight:
        def __get__(self):
            self.e1ChargeIdTight_branch.GetEntry(self.localentry, 0)
            return self.e1ChargeIdTight_value

    property e1ComesFromHiggs:
        def __get__(self):
            self.e1ComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.e1ComesFromHiggs_value

    property e1DPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.e1DPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_ElectronEnDown_value

    property e1DPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.e1DPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_ElectronEnUp_value

    property e1DPhiToPfMet_JetEnDown:
        def __get__(self):
            self.e1DPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_JetEnDown_value

    property e1DPhiToPfMet_JetEnUp:
        def __get__(self):
            self.e1DPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_JetEnUp_value

    property e1DPhiToPfMet_JetResDown:
        def __get__(self):
            self.e1DPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_JetResDown_value

    property e1DPhiToPfMet_JetResUp:
        def __get__(self):
            self.e1DPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_JetResUp_value

    property e1DPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.e1DPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_MuonEnDown_value

    property e1DPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.e1DPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_MuonEnUp_value

    property e1DPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.e1DPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_PhotonEnDown_value

    property e1DPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.e1DPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_PhotonEnUp_value

    property e1DPhiToPfMet_TauEnDown:
        def __get__(self):
            self.e1DPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_TauEnDown_value

    property e1DPhiToPfMet_TauEnUp:
        def __get__(self):
            self.e1DPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_TauEnUp_value

    property e1DPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.e1DPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_UnclusteredEnDown_value

    property e1DPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.e1DPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_UnclusteredEnUp_value

    property e1DPhiToPfMet_type1:
        def __get__(self):
            self.e1DPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.e1DPhiToPfMet_type1_value

    property e1E1x5:
        def __get__(self):
            self.e1E1x5_branch.GetEntry(self.localentry, 0)
            return self.e1E1x5_value

    property e1E2x5Max:
        def __get__(self):
            self.e1E2x5Max_branch.GetEntry(self.localentry, 0)
            return self.e1E2x5Max_value

    property e1E5x5:
        def __get__(self):
            self.e1E5x5_branch.GetEntry(self.localentry, 0)
            return self.e1E5x5_value

    property e1EcalIsoDR03:
        def __get__(self):
            self.e1EcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e1EcalIsoDR03_value

    property e1EffectiveArea2012Data:
        def __get__(self):
            self.e1EffectiveArea2012Data_branch.GetEntry(self.localentry, 0)
            return self.e1EffectiveArea2012Data_value

    property e1EffectiveAreaSpring15:
        def __get__(self):
            self.e1EffectiveAreaSpring15_branch.GetEntry(self.localentry, 0)
            return self.e1EffectiveAreaSpring15_value

    property e1EnergyError:
        def __get__(self):
            self.e1EnergyError_branch.GetEntry(self.localentry, 0)
            return self.e1EnergyError_value

    property e1Eta:
        def __get__(self):
            self.e1Eta_branch.GetEntry(self.localentry, 0)
            return self.e1Eta_value

    property e1Eta_ElectronEnDown:
        def __get__(self):
            self.e1Eta_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1Eta_ElectronEnDown_value

    property e1Eta_ElectronEnUp:
        def __get__(self):
            self.e1Eta_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1Eta_ElectronEnUp_value

    property e1GenCharge:
        def __get__(self):
            self.e1GenCharge_branch.GetEntry(self.localentry, 0)
            return self.e1GenCharge_value

    property e1GenEnergy:
        def __get__(self):
            self.e1GenEnergy_branch.GetEntry(self.localentry, 0)
            return self.e1GenEnergy_value

    property e1GenEta:
        def __get__(self):
            self.e1GenEta_branch.GetEntry(self.localentry, 0)
            return self.e1GenEta_value

    property e1GenMotherPdgId:
        def __get__(self):
            self.e1GenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.e1GenMotherPdgId_value

    property e1GenParticle:
        def __get__(self):
            self.e1GenParticle_branch.GetEntry(self.localentry, 0)
            return self.e1GenParticle_value

    property e1GenPdgId:
        def __get__(self):
            self.e1GenPdgId_branch.GetEntry(self.localentry, 0)
            return self.e1GenPdgId_value

    property e1GenPhi:
        def __get__(self):
            self.e1GenPhi_branch.GetEntry(self.localentry, 0)
            return self.e1GenPhi_value

    property e1GenPrompt:
        def __get__(self):
            self.e1GenPrompt_branch.GetEntry(self.localentry, 0)
            return self.e1GenPrompt_value

    property e1GenPromptTauDecay:
        def __get__(self):
            self.e1GenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.e1GenPromptTauDecay_value

    property e1GenPt:
        def __get__(self):
            self.e1GenPt_branch.GetEntry(self.localentry, 0)
            return self.e1GenPt_value

    property e1GenTauDecay:
        def __get__(self):
            self.e1GenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.e1GenTauDecay_value

    property e1GenVZ:
        def __get__(self):
            self.e1GenVZ_branch.GetEntry(self.localentry, 0)
            return self.e1GenVZ_value

    property e1GenVtxPVMatch:
        def __get__(self):
            self.e1GenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.e1GenVtxPVMatch_value

    property e1HadronicDepth1OverEm:
        def __get__(self):
            self.e1HadronicDepth1OverEm_branch.GetEntry(self.localentry, 0)
            return self.e1HadronicDepth1OverEm_value

    property e1HadronicDepth2OverEm:
        def __get__(self):
            self.e1HadronicDepth2OverEm_branch.GetEntry(self.localentry, 0)
            return self.e1HadronicDepth2OverEm_value

    property e1HadronicOverEM:
        def __get__(self):
            self.e1HadronicOverEM_branch.GetEntry(self.localentry, 0)
            return self.e1HadronicOverEM_value

    property e1HcalIsoDR03:
        def __get__(self):
            self.e1HcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e1HcalIsoDR03_value

    property e1IP3D:
        def __get__(self):
            self.e1IP3D_branch.GetEntry(self.localentry, 0)
            return self.e1IP3D_value

    property e1IP3DErr:
        def __get__(self):
            self.e1IP3DErr_branch.GetEntry(self.localentry, 0)
            return self.e1IP3DErr_value

    property e1JetArea:
        def __get__(self):
            self.e1JetArea_branch.GetEntry(self.localentry, 0)
            return self.e1JetArea_value

    property e1JetBtag:
        def __get__(self):
            self.e1JetBtag_branch.GetEntry(self.localentry, 0)
            return self.e1JetBtag_value

    property e1JetEtaEtaMoment:
        def __get__(self):
            self.e1JetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.e1JetEtaEtaMoment_value

    property e1JetEtaPhiMoment:
        def __get__(self):
            self.e1JetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.e1JetEtaPhiMoment_value

    property e1JetEtaPhiSpread:
        def __get__(self):
            self.e1JetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.e1JetEtaPhiSpread_value

    property e1JetPFCISVBtag:
        def __get__(self):
            self.e1JetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.e1JetPFCISVBtag_value

    property e1JetPartonFlavour:
        def __get__(self):
            self.e1JetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.e1JetPartonFlavour_value

    property e1JetPhiPhiMoment:
        def __get__(self):
            self.e1JetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.e1JetPhiPhiMoment_value

    property e1JetPt:
        def __get__(self):
            self.e1JetPt_branch.GetEntry(self.localentry, 0)
            return self.e1JetPt_value

    property e1LowestMll:
        def __get__(self):
            self.e1LowestMll_branch.GetEntry(self.localentry, 0)
            return self.e1LowestMll_value

    property e1MVANonTrigCategory:
        def __get__(self):
            self.e1MVANonTrigCategory_branch.GetEntry(self.localentry, 0)
            return self.e1MVANonTrigCategory_value

    property e1MVANonTrigID:
        def __get__(self):
            self.e1MVANonTrigID_branch.GetEntry(self.localentry, 0)
            return self.e1MVANonTrigID_value

    property e1MVANonTrigWP80:
        def __get__(self):
            self.e1MVANonTrigWP80_branch.GetEntry(self.localentry, 0)
            return self.e1MVANonTrigWP80_value

    property e1MVANonTrigWP90:
        def __get__(self):
            self.e1MVANonTrigWP90_branch.GetEntry(self.localentry, 0)
            return self.e1MVANonTrigWP90_value

    property e1MVATrigCategory:
        def __get__(self):
            self.e1MVATrigCategory_branch.GetEntry(self.localentry, 0)
            return self.e1MVATrigCategory_value

    property e1MVATrigID:
        def __get__(self):
            self.e1MVATrigID_branch.GetEntry(self.localentry, 0)
            return self.e1MVATrigID_value

    property e1MVATrigWP80:
        def __get__(self):
            self.e1MVATrigWP80_branch.GetEntry(self.localentry, 0)
            return self.e1MVATrigWP80_value

    property e1MVATrigWP90:
        def __get__(self):
            self.e1MVATrigWP90_branch.GetEntry(self.localentry, 0)
            return self.e1MVATrigWP90_value

    property e1Mass:
        def __get__(self):
            self.e1Mass_branch.GetEntry(self.localentry, 0)
            return self.e1Mass_value

    property e1MatchesDoubleE:
        def __get__(self):
            self.e1MatchesDoubleE_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesDoubleE_value

    property e1MatchesDoubleESingleMu:
        def __get__(self):
            self.e1MatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesDoubleESingleMu_value

    property e1MatchesDoubleMuSingleE:
        def __get__(self):
            self.e1MatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesDoubleMuSingleE_value

    property e1MatchesSingleE:
        def __get__(self):
            self.e1MatchesSingleE_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesSingleE_value

    property e1MatchesSingleESingleMu:
        def __get__(self):
            self.e1MatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesSingleESingleMu_value

    property e1MatchesSingleE_leg1:
        def __get__(self):
            self.e1MatchesSingleE_leg1_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesSingleE_leg1_value

    property e1MatchesSingleE_leg2:
        def __get__(self):
            self.e1MatchesSingleE_leg2_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesSingleE_leg2_value

    property e1MatchesSingleMuSingleE:
        def __get__(self):
            self.e1MatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesSingleMuSingleE_value

    property e1MatchesTripleE:
        def __get__(self):
            self.e1MatchesTripleE_branch.GetEntry(self.localentry, 0)
            return self.e1MatchesTripleE_value

    property e1MissingHits:
        def __get__(self):
            self.e1MissingHits_branch.GetEntry(self.localentry, 0)
            return self.e1MissingHits_value

    property e1MtToPfMet_ElectronEnDown:
        def __get__(self):
            self.e1MtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_ElectronEnDown_value

    property e1MtToPfMet_ElectronEnUp:
        def __get__(self):
            self.e1MtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_ElectronEnUp_value

    property e1MtToPfMet_JetEnDown:
        def __get__(self):
            self.e1MtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_JetEnDown_value

    property e1MtToPfMet_JetEnUp:
        def __get__(self):
            self.e1MtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_JetEnUp_value

    property e1MtToPfMet_JetResDown:
        def __get__(self):
            self.e1MtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_JetResDown_value

    property e1MtToPfMet_JetResUp:
        def __get__(self):
            self.e1MtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_JetResUp_value

    property e1MtToPfMet_MuonEnDown:
        def __get__(self):
            self.e1MtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_MuonEnDown_value

    property e1MtToPfMet_MuonEnUp:
        def __get__(self):
            self.e1MtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_MuonEnUp_value

    property e1MtToPfMet_PhotonEnDown:
        def __get__(self):
            self.e1MtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_PhotonEnDown_value

    property e1MtToPfMet_PhotonEnUp:
        def __get__(self):
            self.e1MtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_PhotonEnUp_value

    property e1MtToPfMet_Raw:
        def __get__(self):
            self.e1MtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_Raw_value

    property e1MtToPfMet_TauEnDown:
        def __get__(self):
            self.e1MtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_TauEnDown_value

    property e1MtToPfMet_TauEnUp:
        def __get__(self):
            self.e1MtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_TauEnUp_value

    property e1MtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.e1MtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_UnclusteredEnDown_value

    property e1MtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.e1MtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_UnclusteredEnUp_value

    property e1MtToPfMet_type1:
        def __get__(self):
            self.e1MtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.e1MtToPfMet_type1_value

    property e1NearMuonVeto:
        def __get__(self):
            self.e1NearMuonVeto_branch.GetEntry(self.localentry, 0)
            return self.e1NearMuonVeto_value

    property e1NearestMuonDR:
        def __get__(self):
            self.e1NearestMuonDR_branch.GetEntry(self.localentry, 0)
            return self.e1NearestMuonDR_value

    property e1NearestZMass:
        def __get__(self):
            self.e1NearestZMass_branch.GetEntry(self.localentry, 0)
            return self.e1NearestZMass_value

    property e1PFChargedIso:
        def __get__(self):
            self.e1PFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.e1PFChargedIso_value

    property e1PFNeutralIso:
        def __get__(self):
            self.e1PFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.e1PFNeutralIso_value

    property e1PFPUChargedIso:
        def __get__(self):
            self.e1PFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.e1PFPUChargedIso_value

    property e1PFPhotonIso:
        def __get__(self):
            self.e1PFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.e1PFPhotonIso_value

    property e1PVDXY:
        def __get__(self):
            self.e1PVDXY_branch.GetEntry(self.localentry, 0)
            return self.e1PVDXY_value

    property e1PVDZ:
        def __get__(self):
            self.e1PVDZ_branch.GetEntry(self.localentry, 0)
            return self.e1PVDZ_value

    property e1PassesConversionVeto:
        def __get__(self):
            self.e1PassesConversionVeto_branch.GetEntry(self.localentry, 0)
            return self.e1PassesConversionVeto_value

    property e1Phi:
        def __get__(self):
            self.e1Phi_branch.GetEntry(self.localentry, 0)
            return self.e1Phi_value

    property e1Phi_ElectronEnDown:
        def __get__(self):
            self.e1Phi_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1Phi_ElectronEnDown_value

    property e1Phi_ElectronEnUp:
        def __get__(self):
            self.e1Phi_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1Phi_ElectronEnUp_value

    property e1Pt:
        def __get__(self):
            self.e1Pt_branch.GetEntry(self.localentry, 0)
            return self.e1Pt_value

    property e1Pt_ElectronEnDown:
        def __get__(self):
            self.e1Pt_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1Pt_ElectronEnDown_value

    property e1Pt_ElectronEnUp:
        def __get__(self):
            self.e1Pt_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1Pt_ElectronEnUp_value

    property e1Rank:
        def __get__(self):
            self.e1Rank_branch.GetEntry(self.localentry, 0)
            return self.e1Rank_value

    property e1RelIso:
        def __get__(self):
            self.e1RelIso_branch.GetEntry(self.localentry, 0)
            return self.e1RelIso_value

    property e1RelPFIsoDB:
        def __get__(self):
            self.e1RelPFIsoDB_branch.GetEntry(self.localentry, 0)
            return self.e1RelPFIsoDB_value

    property e1RelPFIsoRho:
        def __get__(self):
            self.e1RelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.e1RelPFIsoRho_value

    property e1Rho:
        def __get__(self):
            self.e1Rho_branch.GetEntry(self.localentry, 0)
            return self.e1Rho_value

    property e1SCEnergy:
        def __get__(self):
            self.e1SCEnergy_branch.GetEntry(self.localentry, 0)
            return self.e1SCEnergy_value

    property e1SCEta:
        def __get__(self):
            self.e1SCEta_branch.GetEntry(self.localentry, 0)
            return self.e1SCEta_value

    property e1SCEtaWidth:
        def __get__(self):
            self.e1SCEtaWidth_branch.GetEntry(self.localentry, 0)
            return self.e1SCEtaWidth_value

    property e1SCPhi:
        def __get__(self):
            self.e1SCPhi_branch.GetEntry(self.localentry, 0)
            return self.e1SCPhi_value

    property e1SCPhiWidth:
        def __get__(self):
            self.e1SCPhiWidth_branch.GetEntry(self.localentry, 0)
            return self.e1SCPhiWidth_value

    property e1SCPreshowerEnergy:
        def __get__(self):
            self.e1SCPreshowerEnergy_branch.GetEntry(self.localentry, 0)
            return self.e1SCPreshowerEnergy_value

    property e1SCRawEnergy:
        def __get__(self):
            self.e1SCRawEnergy_branch.GetEntry(self.localentry, 0)
            return self.e1SCRawEnergy_value

    property e1SIP2D:
        def __get__(self):
            self.e1SIP2D_branch.GetEntry(self.localentry, 0)
            return self.e1SIP2D_value

    property e1SIP3D:
        def __get__(self):
            self.e1SIP3D_branch.GetEntry(self.localentry, 0)
            return self.e1SIP3D_value

    property e1SigmaIEtaIEta:
        def __get__(self):
            self.e1SigmaIEtaIEta_branch.GetEntry(self.localentry, 0)
            return self.e1SigmaIEtaIEta_value

    property e1TrkIsoDR03:
        def __get__(self):
            self.e1TrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e1TrkIsoDR03_value

    property e1VZ:
        def __get__(self):
            self.e1VZ_branch.GetEntry(self.localentry, 0)
            return self.e1VZ_value

    property e1WWLoose:
        def __get__(self):
            self.e1WWLoose_branch.GetEntry(self.localentry, 0)
            return self.e1WWLoose_value

    property e1_e2_CosThetaStar:
        def __get__(self):
            self.e1_e2_CosThetaStar_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_CosThetaStar_value

    property e1_e2_DPhi:
        def __get__(self):
            self.e1_e2_DPhi_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_DPhi_value

    property e1_e2_DR:
        def __get__(self):
            self.e1_e2_DR_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_DR_value

    property e1_e2_Eta:
        def __get__(self):
            self.e1_e2_Eta_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_Eta_value

    property e1_e2_Mass:
        def __get__(self):
            self.e1_e2_Mass_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_Mass_value

    property e1_e2_Mt:
        def __get__(self):
            self.e1_e2_Mt_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_Mt_value

    property e1_e2_PZeta:
        def __get__(self):
            self.e1_e2_PZeta_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_PZeta_value

    property e1_e2_PZetaVis:
        def __get__(self):
            self.e1_e2_PZetaVis_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_PZetaVis_value

    property e1_e2_Phi:
        def __get__(self):
            self.e1_e2_Phi_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_Phi_value

    property e1_e2_Pt:
        def __get__(self):
            self.e1_e2_Pt_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_Pt_value

    property e1_e2_SS:
        def __get__(self):
            self.e1_e2_SS_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_SS_value

    property e1_e2_ToMETDPhi_Ty1:
        def __get__(self):
            self.e1_e2_ToMETDPhi_Ty1_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_ToMETDPhi_Ty1_value

    property e1_e2_collinearmass:
        def __get__(self):
            self.e1_e2_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_collinearmass_value

    property e1_e2_collinearmass_JetEnDown:
        def __get__(self):
            self.e1_e2_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_collinearmass_JetEnDown_value

    property e1_e2_collinearmass_JetEnUp:
        def __get__(self):
            self.e1_e2_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_collinearmass_JetEnUp_value

    property e1_e2_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.e1_e2_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_collinearmass_UnclusteredEnDown_value

    property e1_e2_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.e1_e2_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1_e2_collinearmass_UnclusteredEnUp_value

    property e1_e3_CosThetaStar:
        def __get__(self):
            self.e1_e3_CosThetaStar_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_CosThetaStar_value

    property e1_e3_DPhi:
        def __get__(self):
            self.e1_e3_DPhi_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_DPhi_value

    property e1_e3_DR:
        def __get__(self):
            self.e1_e3_DR_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_DR_value

    property e1_e3_Eta:
        def __get__(self):
            self.e1_e3_Eta_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_Eta_value

    property e1_e3_Mass:
        def __get__(self):
            self.e1_e3_Mass_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_Mass_value

    property e1_e3_Mt:
        def __get__(self):
            self.e1_e3_Mt_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_Mt_value

    property e1_e3_PZeta:
        def __get__(self):
            self.e1_e3_PZeta_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_PZeta_value

    property e1_e3_PZetaVis:
        def __get__(self):
            self.e1_e3_PZetaVis_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_PZetaVis_value

    property e1_e3_Phi:
        def __get__(self):
            self.e1_e3_Phi_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_Phi_value

    property e1_e3_Pt:
        def __get__(self):
            self.e1_e3_Pt_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_Pt_value

    property e1_e3_SS:
        def __get__(self):
            self.e1_e3_SS_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_SS_value

    property e1_e3_ToMETDPhi_Ty1:
        def __get__(self):
            self.e1_e3_ToMETDPhi_Ty1_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_ToMETDPhi_Ty1_value

    property e1_e3_collinearmass:
        def __get__(self):
            self.e1_e3_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_collinearmass_value

    property e1_e3_collinearmass_JetEnDown:
        def __get__(self):
            self.e1_e3_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_collinearmass_JetEnDown_value

    property e1_e3_collinearmass_JetEnUp:
        def __get__(self):
            self.e1_e3_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_collinearmass_JetEnUp_value

    property e1_e3_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.e1_e3_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_collinearmass_UnclusteredEnDown_value

    property e1_e3_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.e1_e3_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e1_e3_collinearmass_UnclusteredEnUp_value

    property e1deltaEtaSuperClusterTrackAtVtx:
        def __get__(self):
            self.e1deltaEtaSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.e1deltaEtaSuperClusterTrackAtVtx_value

    property e1deltaPhiSuperClusterTrackAtVtx:
        def __get__(self):
            self.e1deltaPhiSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.e1deltaPhiSuperClusterTrackAtVtx_value

    property e1eSuperClusterOverP:
        def __get__(self):
            self.e1eSuperClusterOverP_branch.GetEntry(self.localentry, 0)
            return self.e1eSuperClusterOverP_value

    property e1ecalEnergy:
        def __get__(self):
            self.e1ecalEnergy_branch.GetEntry(self.localentry, 0)
            return self.e1ecalEnergy_value

    property e1fBrem:
        def __get__(self):
            self.e1fBrem_branch.GetEntry(self.localentry, 0)
            return self.e1fBrem_value

    property e1trackMomentumAtVtxP:
        def __get__(self):
            self.e1trackMomentumAtVtxP_branch.GetEntry(self.localentry, 0)
            return self.e1trackMomentumAtVtxP_value

    property e2AbsEta:
        def __get__(self):
            self.e2AbsEta_branch.GetEntry(self.localentry, 0)
            return self.e2AbsEta_value

    property e2CBIDLoose:
        def __get__(self):
            self.e2CBIDLoose_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDLoose_value

    property e2CBIDLooseNoIso:
        def __get__(self):
            self.e2CBIDLooseNoIso_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDLooseNoIso_value

    property e2CBIDMedium:
        def __get__(self):
            self.e2CBIDMedium_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDMedium_value

    property e2CBIDMediumNoIso:
        def __get__(self):
            self.e2CBIDMediumNoIso_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDMediumNoIso_value

    property e2CBIDTight:
        def __get__(self):
            self.e2CBIDTight_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDTight_value

    property e2CBIDTightNoIso:
        def __get__(self):
            self.e2CBIDTightNoIso_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDTightNoIso_value

    property e2CBIDVeto:
        def __get__(self):
            self.e2CBIDVeto_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDVeto_value

    property e2CBIDVetoNoIso:
        def __get__(self):
            self.e2CBIDVetoNoIso_branch.GetEntry(self.localentry, 0)
            return self.e2CBIDVetoNoIso_value

    property e2Charge:
        def __get__(self):
            self.e2Charge_branch.GetEntry(self.localentry, 0)
            return self.e2Charge_value

    property e2ChargeIdLoose:
        def __get__(self):
            self.e2ChargeIdLoose_branch.GetEntry(self.localentry, 0)
            return self.e2ChargeIdLoose_value

    property e2ChargeIdMed:
        def __get__(self):
            self.e2ChargeIdMed_branch.GetEntry(self.localentry, 0)
            return self.e2ChargeIdMed_value

    property e2ChargeIdTight:
        def __get__(self):
            self.e2ChargeIdTight_branch.GetEntry(self.localentry, 0)
            return self.e2ChargeIdTight_value

    property e2ComesFromHiggs:
        def __get__(self):
            self.e2ComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.e2ComesFromHiggs_value

    property e2DPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.e2DPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_ElectronEnDown_value

    property e2DPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.e2DPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_ElectronEnUp_value

    property e2DPhiToPfMet_JetEnDown:
        def __get__(self):
            self.e2DPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_JetEnDown_value

    property e2DPhiToPfMet_JetEnUp:
        def __get__(self):
            self.e2DPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_JetEnUp_value

    property e2DPhiToPfMet_JetResDown:
        def __get__(self):
            self.e2DPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_JetResDown_value

    property e2DPhiToPfMet_JetResUp:
        def __get__(self):
            self.e2DPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_JetResUp_value

    property e2DPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.e2DPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_MuonEnDown_value

    property e2DPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.e2DPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_MuonEnUp_value

    property e2DPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.e2DPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_PhotonEnDown_value

    property e2DPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.e2DPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_PhotonEnUp_value

    property e2DPhiToPfMet_TauEnDown:
        def __get__(self):
            self.e2DPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_TauEnDown_value

    property e2DPhiToPfMet_TauEnUp:
        def __get__(self):
            self.e2DPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_TauEnUp_value

    property e2DPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.e2DPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_UnclusteredEnDown_value

    property e2DPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.e2DPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_UnclusteredEnUp_value

    property e2DPhiToPfMet_type1:
        def __get__(self):
            self.e2DPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.e2DPhiToPfMet_type1_value

    property e2E1x5:
        def __get__(self):
            self.e2E1x5_branch.GetEntry(self.localentry, 0)
            return self.e2E1x5_value

    property e2E2x5Max:
        def __get__(self):
            self.e2E2x5Max_branch.GetEntry(self.localentry, 0)
            return self.e2E2x5Max_value

    property e2E5x5:
        def __get__(self):
            self.e2E5x5_branch.GetEntry(self.localentry, 0)
            return self.e2E5x5_value

    property e2EcalIsoDR03:
        def __get__(self):
            self.e2EcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e2EcalIsoDR03_value

    property e2EffectiveArea2012Data:
        def __get__(self):
            self.e2EffectiveArea2012Data_branch.GetEntry(self.localentry, 0)
            return self.e2EffectiveArea2012Data_value

    property e2EffectiveAreaSpring15:
        def __get__(self):
            self.e2EffectiveAreaSpring15_branch.GetEntry(self.localentry, 0)
            return self.e2EffectiveAreaSpring15_value

    property e2EnergyError:
        def __get__(self):
            self.e2EnergyError_branch.GetEntry(self.localentry, 0)
            return self.e2EnergyError_value

    property e2Eta:
        def __get__(self):
            self.e2Eta_branch.GetEntry(self.localentry, 0)
            return self.e2Eta_value

    property e2Eta_ElectronEnDown:
        def __get__(self):
            self.e2Eta_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2Eta_ElectronEnDown_value

    property e2Eta_ElectronEnUp:
        def __get__(self):
            self.e2Eta_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2Eta_ElectronEnUp_value

    property e2GenCharge:
        def __get__(self):
            self.e2GenCharge_branch.GetEntry(self.localentry, 0)
            return self.e2GenCharge_value

    property e2GenEnergy:
        def __get__(self):
            self.e2GenEnergy_branch.GetEntry(self.localentry, 0)
            return self.e2GenEnergy_value

    property e2GenEta:
        def __get__(self):
            self.e2GenEta_branch.GetEntry(self.localentry, 0)
            return self.e2GenEta_value

    property e2GenMotherPdgId:
        def __get__(self):
            self.e2GenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.e2GenMotherPdgId_value

    property e2GenParticle:
        def __get__(self):
            self.e2GenParticle_branch.GetEntry(self.localentry, 0)
            return self.e2GenParticle_value

    property e2GenPdgId:
        def __get__(self):
            self.e2GenPdgId_branch.GetEntry(self.localentry, 0)
            return self.e2GenPdgId_value

    property e2GenPhi:
        def __get__(self):
            self.e2GenPhi_branch.GetEntry(self.localentry, 0)
            return self.e2GenPhi_value

    property e2GenPrompt:
        def __get__(self):
            self.e2GenPrompt_branch.GetEntry(self.localentry, 0)
            return self.e2GenPrompt_value

    property e2GenPromptTauDecay:
        def __get__(self):
            self.e2GenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.e2GenPromptTauDecay_value

    property e2GenPt:
        def __get__(self):
            self.e2GenPt_branch.GetEntry(self.localentry, 0)
            return self.e2GenPt_value

    property e2GenTauDecay:
        def __get__(self):
            self.e2GenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.e2GenTauDecay_value

    property e2GenVZ:
        def __get__(self):
            self.e2GenVZ_branch.GetEntry(self.localentry, 0)
            return self.e2GenVZ_value

    property e2GenVtxPVMatch:
        def __get__(self):
            self.e2GenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.e2GenVtxPVMatch_value

    property e2HadronicDepth1OverEm:
        def __get__(self):
            self.e2HadronicDepth1OverEm_branch.GetEntry(self.localentry, 0)
            return self.e2HadronicDepth1OverEm_value

    property e2HadronicDepth2OverEm:
        def __get__(self):
            self.e2HadronicDepth2OverEm_branch.GetEntry(self.localentry, 0)
            return self.e2HadronicDepth2OverEm_value

    property e2HadronicOverEM:
        def __get__(self):
            self.e2HadronicOverEM_branch.GetEntry(self.localentry, 0)
            return self.e2HadronicOverEM_value

    property e2HcalIsoDR03:
        def __get__(self):
            self.e2HcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e2HcalIsoDR03_value

    property e2IP3D:
        def __get__(self):
            self.e2IP3D_branch.GetEntry(self.localentry, 0)
            return self.e2IP3D_value

    property e2IP3DErr:
        def __get__(self):
            self.e2IP3DErr_branch.GetEntry(self.localentry, 0)
            return self.e2IP3DErr_value

    property e2JetArea:
        def __get__(self):
            self.e2JetArea_branch.GetEntry(self.localentry, 0)
            return self.e2JetArea_value

    property e2JetBtag:
        def __get__(self):
            self.e2JetBtag_branch.GetEntry(self.localentry, 0)
            return self.e2JetBtag_value

    property e2JetEtaEtaMoment:
        def __get__(self):
            self.e2JetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.e2JetEtaEtaMoment_value

    property e2JetEtaPhiMoment:
        def __get__(self):
            self.e2JetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.e2JetEtaPhiMoment_value

    property e2JetEtaPhiSpread:
        def __get__(self):
            self.e2JetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.e2JetEtaPhiSpread_value

    property e2JetPFCISVBtag:
        def __get__(self):
            self.e2JetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.e2JetPFCISVBtag_value

    property e2JetPartonFlavour:
        def __get__(self):
            self.e2JetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.e2JetPartonFlavour_value

    property e2JetPhiPhiMoment:
        def __get__(self):
            self.e2JetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.e2JetPhiPhiMoment_value

    property e2JetPt:
        def __get__(self):
            self.e2JetPt_branch.GetEntry(self.localentry, 0)
            return self.e2JetPt_value

    property e2LowestMll:
        def __get__(self):
            self.e2LowestMll_branch.GetEntry(self.localentry, 0)
            return self.e2LowestMll_value

    property e2MVANonTrigCategory:
        def __get__(self):
            self.e2MVANonTrigCategory_branch.GetEntry(self.localentry, 0)
            return self.e2MVANonTrigCategory_value

    property e2MVANonTrigID:
        def __get__(self):
            self.e2MVANonTrigID_branch.GetEntry(self.localentry, 0)
            return self.e2MVANonTrigID_value

    property e2MVANonTrigWP80:
        def __get__(self):
            self.e2MVANonTrigWP80_branch.GetEntry(self.localentry, 0)
            return self.e2MVANonTrigWP80_value

    property e2MVANonTrigWP90:
        def __get__(self):
            self.e2MVANonTrigWP90_branch.GetEntry(self.localentry, 0)
            return self.e2MVANonTrigWP90_value

    property e2MVATrigCategory:
        def __get__(self):
            self.e2MVATrigCategory_branch.GetEntry(self.localentry, 0)
            return self.e2MVATrigCategory_value

    property e2MVATrigID:
        def __get__(self):
            self.e2MVATrigID_branch.GetEntry(self.localentry, 0)
            return self.e2MVATrigID_value

    property e2MVATrigWP80:
        def __get__(self):
            self.e2MVATrigWP80_branch.GetEntry(self.localentry, 0)
            return self.e2MVATrigWP80_value

    property e2MVATrigWP90:
        def __get__(self):
            self.e2MVATrigWP90_branch.GetEntry(self.localentry, 0)
            return self.e2MVATrigWP90_value

    property e2Mass:
        def __get__(self):
            self.e2Mass_branch.GetEntry(self.localentry, 0)
            return self.e2Mass_value

    property e2MatchesDoubleE:
        def __get__(self):
            self.e2MatchesDoubleE_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesDoubleE_value

    property e2MatchesDoubleESingleMu:
        def __get__(self):
            self.e2MatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesDoubleESingleMu_value

    property e2MatchesDoubleMuSingleE:
        def __get__(self):
            self.e2MatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesDoubleMuSingleE_value

    property e2MatchesSingleE:
        def __get__(self):
            self.e2MatchesSingleE_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesSingleE_value

    property e2MatchesSingleESingleMu:
        def __get__(self):
            self.e2MatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesSingleESingleMu_value

    property e2MatchesSingleE_leg1:
        def __get__(self):
            self.e2MatchesSingleE_leg1_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesSingleE_leg1_value

    property e2MatchesSingleE_leg2:
        def __get__(self):
            self.e2MatchesSingleE_leg2_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesSingleE_leg2_value

    property e2MatchesSingleMuSingleE:
        def __get__(self):
            self.e2MatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesSingleMuSingleE_value

    property e2MatchesTripleE:
        def __get__(self):
            self.e2MatchesTripleE_branch.GetEntry(self.localentry, 0)
            return self.e2MatchesTripleE_value

    property e2MissingHits:
        def __get__(self):
            self.e2MissingHits_branch.GetEntry(self.localentry, 0)
            return self.e2MissingHits_value

    property e2MtToPfMet_ElectronEnDown:
        def __get__(self):
            self.e2MtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_ElectronEnDown_value

    property e2MtToPfMet_ElectronEnUp:
        def __get__(self):
            self.e2MtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_ElectronEnUp_value

    property e2MtToPfMet_JetEnDown:
        def __get__(self):
            self.e2MtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_JetEnDown_value

    property e2MtToPfMet_JetEnUp:
        def __get__(self):
            self.e2MtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_JetEnUp_value

    property e2MtToPfMet_JetResDown:
        def __get__(self):
            self.e2MtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_JetResDown_value

    property e2MtToPfMet_JetResUp:
        def __get__(self):
            self.e2MtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_JetResUp_value

    property e2MtToPfMet_MuonEnDown:
        def __get__(self):
            self.e2MtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_MuonEnDown_value

    property e2MtToPfMet_MuonEnUp:
        def __get__(self):
            self.e2MtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_MuonEnUp_value

    property e2MtToPfMet_PhotonEnDown:
        def __get__(self):
            self.e2MtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_PhotonEnDown_value

    property e2MtToPfMet_PhotonEnUp:
        def __get__(self):
            self.e2MtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_PhotonEnUp_value

    property e2MtToPfMet_Raw:
        def __get__(self):
            self.e2MtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_Raw_value

    property e2MtToPfMet_TauEnDown:
        def __get__(self):
            self.e2MtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_TauEnDown_value

    property e2MtToPfMet_TauEnUp:
        def __get__(self):
            self.e2MtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_TauEnUp_value

    property e2MtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.e2MtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_UnclusteredEnDown_value

    property e2MtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.e2MtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_UnclusteredEnUp_value

    property e2MtToPfMet_type1:
        def __get__(self):
            self.e2MtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.e2MtToPfMet_type1_value

    property e2NearMuonVeto:
        def __get__(self):
            self.e2NearMuonVeto_branch.GetEntry(self.localentry, 0)
            return self.e2NearMuonVeto_value

    property e2NearestMuonDR:
        def __get__(self):
            self.e2NearestMuonDR_branch.GetEntry(self.localentry, 0)
            return self.e2NearestMuonDR_value

    property e2NearestZMass:
        def __get__(self):
            self.e2NearestZMass_branch.GetEntry(self.localentry, 0)
            return self.e2NearestZMass_value

    property e2PFChargedIso:
        def __get__(self):
            self.e2PFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.e2PFChargedIso_value

    property e2PFNeutralIso:
        def __get__(self):
            self.e2PFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.e2PFNeutralIso_value

    property e2PFPUChargedIso:
        def __get__(self):
            self.e2PFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.e2PFPUChargedIso_value

    property e2PFPhotonIso:
        def __get__(self):
            self.e2PFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.e2PFPhotonIso_value

    property e2PVDXY:
        def __get__(self):
            self.e2PVDXY_branch.GetEntry(self.localentry, 0)
            return self.e2PVDXY_value

    property e2PVDZ:
        def __get__(self):
            self.e2PVDZ_branch.GetEntry(self.localentry, 0)
            return self.e2PVDZ_value

    property e2PassesConversionVeto:
        def __get__(self):
            self.e2PassesConversionVeto_branch.GetEntry(self.localentry, 0)
            return self.e2PassesConversionVeto_value

    property e2Phi:
        def __get__(self):
            self.e2Phi_branch.GetEntry(self.localentry, 0)
            return self.e2Phi_value

    property e2Phi_ElectronEnDown:
        def __get__(self):
            self.e2Phi_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2Phi_ElectronEnDown_value

    property e2Phi_ElectronEnUp:
        def __get__(self):
            self.e2Phi_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2Phi_ElectronEnUp_value

    property e2Pt:
        def __get__(self):
            self.e2Pt_branch.GetEntry(self.localentry, 0)
            return self.e2Pt_value

    property e2Pt_ElectronEnDown:
        def __get__(self):
            self.e2Pt_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2Pt_ElectronEnDown_value

    property e2Pt_ElectronEnUp:
        def __get__(self):
            self.e2Pt_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2Pt_ElectronEnUp_value

    property e2Rank:
        def __get__(self):
            self.e2Rank_branch.GetEntry(self.localentry, 0)
            return self.e2Rank_value

    property e2RelIso:
        def __get__(self):
            self.e2RelIso_branch.GetEntry(self.localentry, 0)
            return self.e2RelIso_value

    property e2RelPFIsoDB:
        def __get__(self):
            self.e2RelPFIsoDB_branch.GetEntry(self.localentry, 0)
            return self.e2RelPFIsoDB_value

    property e2RelPFIsoRho:
        def __get__(self):
            self.e2RelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.e2RelPFIsoRho_value

    property e2Rho:
        def __get__(self):
            self.e2Rho_branch.GetEntry(self.localentry, 0)
            return self.e2Rho_value

    property e2SCEnergy:
        def __get__(self):
            self.e2SCEnergy_branch.GetEntry(self.localentry, 0)
            return self.e2SCEnergy_value

    property e2SCEta:
        def __get__(self):
            self.e2SCEta_branch.GetEntry(self.localentry, 0)
            return self.e2SCEta_value

    property e2SCEtaWidth:
        def __get__(self):
            self.e2SCEtaWidth_branch.GetEntry(self.localentry, 0)
            return self.e2SCEtaWidth_value

    property e2SCPhi:
        def __get__(self):
            self.e2SCPhi_branch.GetEntry(self.localentry, 0)
            return self.e2SCPhi_value

    property e2SCPhiWidth:
        def __get__(self):
            self.e2SCPhiWidth_branch.GetEntry(self.localentry, 0)
            return self.e2SCPhiWidth_value

    property e2SCPreshowerEnergy:
        def __get__(self):
            self.e2SCPreshowerEnergy_branch.GetEntry(self.localentry, 0)
            return self.e2SCPreshowerEnergy_value

    property e2SCRawEnergy:
        def __get__(self):
            self.e2SCRawEnergy_branch.GetEntry(self.localentry, 0)
            return self.e2SCRawEnergy_value

    property e2SIP2D:
        def __get__(self):
            self.e2SIP2D_branch.GetEntry(self.localentry, 0)
            return self.e2SIP2D_value

    property e2SIP3D:
        def __get__(self):
            self.e2SIP3D_branch.GetEntry(self.localentry, 0)
            return self.e2SIP3D_value

    property e2SigmaIEtaIEta:
        def __get__(self):
            self.e2SigmaIEtaIEta_branch.GetEntry(self.localentry, 0)
            return self.e2SigmaIEtaIEta_value

    property e2TrkIsoDR03:
        def __get__(self):
            self.e2TrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e2TrkIsoDR03_value

    property e2VZ:
        def __get__(self):
            self.e2VZ_branch.GetEntry(self.localentry, 0)
            return self.e2VZ_value

    property e2WWLoose:
        def __get__(self):
            self.e2WWLoose_branch.GetEntry(self.localentry, 0)
            return self.e2WWLoose_value

    property e2_e1_collinearmass:
        def __get__(self):
            self.e2_e1_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.e2_e1_collinearmass_value

    property e2_e1_collinearmass_JetEnDown:
        def __get__(self):
            self.e2_e1_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2_e1_collinearmass_JetEnDown_value

    property e2_e1_collinearmass_JetEnUp:
        def __get__(self):
            self.e2_e1_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2_e1_collinearmass_JetEnUp_value

    property e2_e1_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.e2_e1_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2_e1_collinearmass_UnclusteredEnDown_value

    property e2_e1_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.e2_e1_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2_e1_collinearmass_UnclusteredEnUp_value

    property e2_e3_CosThetaStar:
        def __get__(self):
            self.e2_e3_CosThetaStar_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_CosThetaStar_value

    property e2_e3_DPhi:
        def __get__(self):
            self.e2_e3_DPhi_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_DPhi_value

    property e2_e3_DR:
        def __get__(self):
            self.e2_e3_DR_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_DR_value

    property e2_e3_Eta:
        def __get__(self):
            self.e2_e3_Eta_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_Eta_value

    property e2_e3_Mass:
        def __get__(self):
            self.e2_e3_Mass_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_Mass_value

    property e2_e3_Mt:
        def __get__(self):
            self.e2_e3_Mt_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_Mt_value

    property e2_e3_PZeta:
        def __get__(self):
            self.e2_e3_PZeta_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_PZeta_value

    property e2_e3_PZetaVis:
        def __get__(self):
            self.e2_e3_PZetaVis_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_PZetaVis_value

    property e2_e3_Phi:
        def __get__(self):
            self.e2_e3_Phi_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_Phi_value

    property e2_e3_Pt:
        def __get__(self):
            self.e2_e3_Pt_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_Pt_value

    property e2_e3_SS:
        def __get__(self):
            self.e2_e3_SS_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_SS_value

    property e2_e3_ToMETDPhi_Ty1:
        def __get__(self):
            self.e2_e3_ToMETDPhi_Ty1_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_ToMETDPhi_Ty1_value

    property e2_e3_collinearmass:
        def __get__(self):
            self.e2_e3_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_collinearmass_value

    property e2_e3_collinearmass_JetEnDown:
        def __get__(self):
            self.e2_e3_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_collinearmass_JetEnDown_value

    property e2_e3_collinearmass_JetEnUp:
        def __get__(self):
            self.e2_e3_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_collinearmass_JetEnUp_value

    property e2_e3_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.e2_e3_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_collinearmass_UnclusteredEnDown_value

    property e2_e3_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.e2_e3_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e2_e3_collinearmass_UnclusteredEnUp_value

    property e2deltaEtaSuperClusterTrackAtVtx:
        def __get__(self):
            self.e2deltaEtaSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.e2deltaEtaSuperClusterTrackAtVtx_value

    property e2deltaPhiSuperClusterTrackAtVtx:
        def __get__(self):
            self.e2deltaPhiSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.e2deltaPhiSuperClusterTrackAtVtx_value

    property e2eSuperClusterOverP:
        def __get__(self):
            self.e2eSuperClusterOverP_branch.GetEntry(self.localentry, 0)
            return self.e2eSuperClusterOverP_value

    property e2ecalEnergy:
        def __get__(self):
            self.e2ecalEnergy_branch.GetEntry(self.localentry, 0)
            return self.e2ecalEnergy_value

    property e2fBrem:
        def __get__(self):
            self.e2fBrem_branch.GetEntry(self.localentry, 0)
            return self.e2fBrem_value

    property e2trackMomentumAtVtxP:
        def __get__(self):
            self.e2trackMomentumAtVtxP_branch.GetEntry(self.localentry, 0)
            return self.e2trackMomentumAtVtxP_value

    property e3AbsEta:
        def __get__(self):
            self.e3AbsEta_branch.GetEntry(self.localentry, 0)
            return self.e3AbsEta_value

    property e3CBIDLoose:
        def __get__(self):
            self.e3CBIDLoose_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDLoose_value

    property e3CBIDLooseNoIso:
        def __get__(self):
            self.e3CBIDLooseNoIso_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDLooseNoIso_value

    property e3CBIDMedium:
        def __get__(self):
            self.e3CBIDMedium_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDMedium_value

    property e3CBIDMediumNoIso:
        def __get__(self):
            self.e3CBIDMediumNoIso_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDMediumNoIso_value

    property e3CBIDTight:
        def __get__(self):
            self.e3CBIDTight_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDTight_value

    property e3CBIDTightNoIso:
        def __get__(self):
            self.e3CBIDTightNoIso_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDTightNoIso_value

    property e3CBIDVeto:
        def __get__(self):
            self.e3CBIDVeto_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDVeto_value

    property e3CBIDVetoNoIso:
        def __get__(self):
            self.e3CBIDVetoNoIso_branch.GetEntry(self.localentry, 0)
            return self.e3CBIDVetoNoIso_value

    property e3Charge:
        def __get__(self):
            self.e3Charge_branch.GetEntry(self.localentry, 0)
            return self.e3Charge_value

    property e3ChargeIdLoose:
        def __get__(self):
            self.e3ChargeIdLoose_branch.GetEntry(self.localentry, 0)
            return self.e3ChargeIdLoose_value

    property e3ChargeIdMed:
        def __get__(self):
            self.e3ChargeIdMed_branch.GetEntry(self.localentry, 0)
            return self.e3ChargeIdMed_value

    property e3ChargeIdTight:
        def __get__(self):
            self.e3ChargeIdTight_branch.GetEntry(self.localentry, 0)
            return self.e3ChargeIdTight_value

    property e3ComesFromHiggs:
        def __get__(self):
            self.e3ComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.e3ComesFromHiggs_value

    property e3DPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.e3DPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_ElectronEnDown_value

    property e3DPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.e3DPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_ElectronEnUp_value

    property e3DPhiToPfMet_JetEnDown:
        def __get__(self):
            self.e3DPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_JetEnDown_value

    property e3DPhiToPfMet_JetEnUp:
        def __get__(self):
            self.e3DPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_JetEnUp_value

    property e3DPhiToPfMet_JetResDown:
        def __get__(self):
            self.e3DPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_JetResDown_value

    property e3DPhiToPfMet_JetResUp:
        def __get__(self):
            self.e3DPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_JetResUp_value

    property e3DPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.e3DPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_MuonEnDown_value

    property e3DPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.e3DPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_MuonEnUp_value

    property e3DPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.e3DPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_PhotonEnDown_value

    property e3DPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.e3DPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_PhotonEnUp_value

    property e3DPhiToPfMet_TauEnDown:
        def __get__(self):
            self.e3DPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_TauEnDown_value

    property e3DPhiToPfMet_TauEnUp:
        def __get__(self):
            self.e3DPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_TauEnUp_value

    property e3DPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.e3DPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_UnclusteredEnDown_value

    property e3DPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.e3DPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_UnclusteredEnUp_value

    property e3DPhiToPfMet_type1:
        def __get__(self):
            self.e3DPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.e3DPhiToPfMet_type1_value

    property e3E1x5:
        def __get__(self):
            self.e3E1x5_branch.GetEntry(self.localentry, 0)
            return self.e3E1x5_value

    property e3E2x5Max:
        def __get__(self):
            self.e3E2x5Max_branch.GetEntry(self.localentry, 0)
            return self.e3E2x5Max_value

    property e3E5x5:
        def __get__(self):
            self.e3E5x5_branch.GetEntry(self.localentry, 0)
            return self.e3E5x5_value

    property e3EcalIsoDR03:
        def __get__(self):
            self.e3EcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e3EcalIsoDR03_value

    property e3EffectiveArea2012Data:
        def __get__(self):
            self.e3EffectiveArea2012Data_branch.GetEntry(self.localentry, 0)
            return self.e3EffectiveArea2012Data_value

    property e3EffectiveAreaSpring15:
        def __get__(self):
            self.e3EffectiveAreaSpring15_branch.GetEntry(self.localentry, 0)
            return self.e3EffectiveAreaSpring15_value

    property e3EnergyError:
        def __get__(self):
            self.e3EnergyError_branch.GetEntry(self.localentry, 0)
            return self.e3EnergyError_value

    property e3Eta:
        def __get__(self):
            self.e3Eta_branch.GetEntry(self.localentry, 0)
            return self.e3Eta_value

    property e3Eta_ElectronEnDown:
        def __get__(self):
            self.e3Eta_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3Eta_ElectronEnDown_value

    property e3Eta_ElectronEnUp:
        def __get__(self):
            self.e3Eta_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3Eta_ElectronEnUp_value

    property e3GenCharge:
        def __get__(self):
            self.e3GenCharge_branch.GetEntry(self.localentry, 0)
            return self.e3GenCharge_value

    property e3GenEnergy:
        def __get__(self):
            self.e3GenEnergy_branch.GetEntry(self.localentry, 0)
            return self.e3GenEnergy_value

    property e3GenEta:
        def __get__(self):
            self.e3GenEta_branch.GetEntry(self.localentry, 0)
            return self.e3GenEta_value

    property e3GenMotherPdgId:
        def __get__(self):
            self.e3GenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.e3GenMotherPdgId_value

    property e3GenParticle:
        def __get__(self):
            self.e3GenParticle_branch.GetEntry(self.localentry, 0)
            return self.e3GenParticle_value

    property e3GenPdgId:
        def __get__(self):
            self.e3GenPdgId_branch.GetEntry(self.localentry, 0)
            return self.e3GenPdgId_value

    property e3GenPhi:
        def __get__(self):
            self.e3GenPhi_branch.GetEntry(self.localentry, 0)
            return self.e3GenPhi_value

    property e3GenPrompt:
        def __get__(self):
            self.e3GenPrompt_branch.GetEntry(self.localentry, 0)
            return self.e3GenPrompt_value

    property e3GenPromptTauDecay:
        def __get__(self):
            self.e3GenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.e3GenPromptTauDecay_value

    property e3GenPt:
        def __get__(self):
            self.e3GenPt_branch.GetEntry(self.localentry, 0)
            return self.e3GenPt_value

    property e3GenTauDecay:
        def __get__(self):
            self.e3GenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.e3GenTauDecay_value

    property e3GenVZ:
        def __get__(self):
            self.e3GenVZ_branch.GetEntry(self.localentry, 0)
            return self.e3GenVZ_value

    property e3GenVtxPVMatch:
        def __get__(self):
            self.e3GenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.e3GenVtxPVMatch_value

    property e3HadronicDepth1OverEm:
        def __get__(self):
            self.e3HadronicDepth1OverEm_branch.GetEntry(self.localentry, 0)
            return self.e3HadronicDepth1OverEm_value

    property e3HadronicDepth2OverEm:
        def __get__(self):
            self.e3HadronicDepth2OverEm_branch.GetEntry(self.localentry, 0)
            return self.e3HadronicDepth2OverEm_value

    property e3HadronicOverEM:
        def __get__(self):
            self.e3HadronicOverEM_branch.GetEntry(self.localentry, 0)
            return self.e3HadronicOverEM_value

    property e3HcalIsoDR03:
        def __get__(self):
            self.e3HcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e3HcalIsoDR03_value

    property e3IP3D:
        def __get__(self):
            self.e3IP3D_branch.GetEntry(self.localentry, 0)
            return self.e3IP3D_value

    property e3IP3DErr:
        def __get__(self):
            self.e3IP3DErr_branch.GetEntry(self.localentry, 0)
            return self.e3IP3DErr_value

    property e3JetArea:
        def __get__(self):
            self.e3JetArea_branch.GetEntry(self.localentry, 0)
            return self.e3JetArea_value

    property e3JetBtag:
        def __get__(self):
            self.e3JetBtag_branch.GetEntry(self.localentry, 0)
            return self.e3JetBtag_value

    property e3JetEtaEtaMoment:
        def __get__(self):
            self.e3JetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.e3JetEtaEtaMoment_value

    property e3JetEtaPhiMoment:
        def __get__(self):
            self.e3JetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.e3JetEtaPhiMoment_value

    property e3JetEtaPhiSpread:
        def __get__(self):
            self.e3JetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.e3JetEtaPhiSpread_value

    property e3JetPFCISVBtag:
        def __get__(self):
            self.e3JetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.e3JetPFCISVBtag_value

    property e3JetPartonFlavour:
        def __get__(self):
            self.e3JetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.e3JetPartonFlavour_value

    property e3JetPhiPhiMoment:
        def __get__(self):
            self.e3JetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.e3JetPhiPhiMoment_value

    property e3JetPt:
        def __get__(self):
            self.e3JetPt_branch.GetEntry(self.localentry, 0)
            return self.e3JetPt_value

    property e3LowestMll:
        def __get__(self):
            self.e3LowestMll_branch.GetEntry(self.localentry, 0)
            return self.e3LowestMll_value

    property e3MVANonTrigCategory:
        def __get__(self):
            self.e3MVANonTrigCategory_branch.GetEntry(self.localentry, 0)
            return self.e3MVANonTrigCategory_value

    property e3MVANonTrigID:
        def __get__(self):
            self.e3MVANonTrigID_branch.GetEntry(self.localentry, 0)
            return self.e3MVANonTrigID_value

    property e3MVANonTrigWP80:
        def __get__(self):
            self.e3MVANonTrigWP80_branch.GetEntry(self.localentry, 0)
            return self.e3MVANonTrigWP80_value

    property e3MVANonTrigWP90:
        def __get__(self):
            self.e3MVANonTrigWP90_branch.GetEntry(self.localentry, 0)
            return self.e3MVANonTrigWP90_value

    property e3MVATrigCategory:
        def __get__(self):
            self.e3MVATrigCategory_branch.GetEntry(self.localentry, 0)
            return self.e3MVATrigCategory_value

    property e3MVATrigID:
        def __get__(self):
            self.e3MVATrigID_branch.GetEntry(self.localentry, 0)
            return self.e3MVATrigID_value

    property e3MVATrigWP80:
        def __get__(self):
            self.e3MVATrigWP80_branch.GetEntry(self.localentry, 0)
            return self.e3MVATrigWP80_value

    property e3MVATrigWP90:
        def __get__(self):
            self.e3MVATrigWP90_branch.GetEntry(self.localentry, 0)
            return self.e3MVATrigWP90_value

    property e3Mass:
        def __get__(self):
            self.e3Mass_branch.GetEntry(self.localentry, 0)
            return self.e3Mass_value

    property e3MatchesDoubleE:
        def __get__(self):
            self.e3MatchesDoubleE_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesDoubleE_value

    property e3MatchesDoubleESingleMu:
        def __get__(self):
            self.e3MatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesDoubleESingleMu_value

    property e3MatchesDoubleMuSingleE:
        def __get__(self):
            self.e3MatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesDoubleMuSingleE_value

    property e3MatchesSingleE:
        def __get__(self):
            self.e3MatchesSingleE_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesSingleE_value

    property e3MatchesSingleESingleMu:
        def __get__(self):
            self.e3MatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesSingleESingleMu_value

    property e3MatchesSingleE_leg1:
        def __get__(self):
            self.e3MatchesSingleE_leg1_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesSingleE_leg1_value

    property e3MatchesSingleE_leg2:
        def __get__(self):
            self.e3MatchesSingleE_leg2_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesSingleE_leg2_value

    property e3MatchesSingleMuSingleE:
        def __get__(self):
            self.e3MatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesSingleMuSingleE_value

    property e3MatchesTripleE:
        def __get__(self):
            self.e3MatchesTripleE_branch.GetEntry(self.localentry, 0)
            return self.e3MatchesTripleE_value

    property e3MissingHits:
        def __get__(self):
            self.e3MissingHits_branch.GetEntry(self.localentry, 0)
            return self.e3MissingHits_value

    property e3MtToPfMet_ElectronEnDown:
        def __get__(self):
            self.e3MtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_ElectronEnDown_value

    property e3MtToPfMet_ElectronEnUp:
        def __get__(self):
            self.e3MtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_ElectronEnUp_value

    property e3MtToPfMet_JetEnDown:
        def __get__(self):
            self.e3MtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_JetEnDown_value

    property e3MtToPfMet_JetEnUp:
        def __get__(self):
            self.e3MtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_JetEnUp_value

    property e3MtToPfMet_JetResDown:
        def __get__(self):
            self.e3MtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_JetResDown_value

    property e3MtToPfMet_JetResUp:
        def __get__(self):
            self.e3MtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_JetResUp_value

    property e3MtToPfMet_MuonEnDown:
        def __get__(self):
            self.e3MtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_MuonEnDown_value

    property e3MtToPfMet_MuonEnUp:
        def __get__(self):
            self.e3MtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_MuonEnUp_value

    property e3MtToPfMet_PhotonEnDown:
        def __get__(self):
            self.e3MtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_PhotonEnDown_value

    property e3MtToPfMet_PhotonEnUp:
        def __get__(self):
            self.e3MtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_PhotonEnUp_value

    property e3MtToPfMet_Raw:
        def __get__(self):
            self.e3MtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_Raw_value

    property e3MtToPfMet_TauEnDown:
        def __get__(self):
            self.e3MtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_TauEnDown_value

    property e3MtToPfMet_TauEnUp:
        def __get__(self):
            self.e3MtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_TauEnUp_value

    property e3MtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.e3MtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_UnclusteredEnDown_value

    property e3MtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.e3MtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_UnclusteredEnUp_value

    property e3MtToPfMet_type1:
        def __get__(self):
            self.e3MtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.e3MtToPfMet_type1_value

    property e3NearMuonVeto:
        def __get__(self):
            self.e3NearMuonVeto_branch.GetEntry(self.localentry, 0)
            return self.e3NearMuonVeto_value

    property e3NearestMuonDR:
        def __get__(self):
            self.e3NearestMuonDR_branch.GetEntry(self.localentry, 0)
            return self.e3NearestMuonDR_value

    property e3NearestZMass:
        def __get__(self):
            self.e3NearestZMass_branch.GetEntry(self.localentry, 0)
            return self.e3NearestZMass_value

    property e3PFChargedIso:
        def __get__(self):
            self.e3PFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.e3PFChargedIso_value

    property e3PFNeutralIso:
        def __get__(self):
            self.e3PFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.e3PFNeutralIso_value

    property e3PFPUChargedIso:
        def __get__(self):
            self.e3PFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.e3PFPUChargedIso_value

    property e3PFPhotonIso:
        def __get__(self):
            self.e3PFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.e3PFPhotonIso_value

    property e3PVDXY:
        def __get__(self):
            self.e3PVDXY_branch.GetEntry(self.localentry, 0)
            return self.e3PVDXY_value

    property e3PVDZ:
        def __get__(self):
            self.e3PVDZ_branch.GetEntry(self.localentry, 0)
            return self.e3PVDZ_value

    property e3PassesConversionVeto:
        def __get__(self):
            self.e3PassesConversionVeto_branch.GetEntry(self.localentry, 0)
            return self.e3PassesConversionVeto_value

    property e3Phi:
        def __get__(self):
            self.e3Phi_branch.GetEntry(self.localentry, 0)
            return self.e3Phi_value

    property e3Phi_ElectronEnDown:
        def __get__(self):
            self.e3Phi_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3Phi_ElectronEnDown_value

    property e3Phi_ElectronEnUp:
        def __get__(self):
            self.e3Phi_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3Phi_ElectronEnUp_value

    property e3Pt:
        def __get__(self):
            self.e3Pt_branch.GetEntry(self.localentry, 0)
            return self.e3Pt_value

    property e3Pt_ElectronEnDown:
        def __get__(self):
            self.e3Pt_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3Pt_ElectronEnDown_value

    property e3Pt_ElectronEnUp:
        def __get__(self):
            self.e3Pt_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3Pt_ElectronEnUp_value

    property e3Rank:
        def __get__(self):
            self.e3Rank_branch.GetEntry(self.localentry, 0)
            return self.e3Rank_value

    property e3RelIso:
        def __get__(self):
            self.e3RelIso_branch.GetEntry(self.localentry, 0)
            return self.e3RelIso_value

    property e3RelPFIsoDB:
        def __get__(self):
            self.e3RelPFIsoDB_branch.GetEntry(self.localentry, 0)
            return self.e3RelPFIsoDB_value

    property e3RelPFIsoRho:
        def __get__(self):
            self.e3RelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.e3RelPFIsoRho_value

    property e3Rho:
        def __get__(self):
            self.e3Rho_branch.GetEntry(self.localentry, 0)
            return self.e3Rho_value

    property e3SCEnergy:
        def __get__(self):
            self.e3SCEnergy_branch.GetEntry(self.localentry, 0)
            return self.e3SCEnergy_value

    property e3SCEta:
        def __get__(self):
            self.e3SCEta_branch.GetEntry(self.localentry, 0)
            return self.e3SCEta_value

    property e3SCEtaWidth:
        def __get__(self):
            self.e3SCEtaWidth_branch.GetEntry(self.localentry, 0)
            return self.e3SCEtaWidth_value

    property e3SCPhi:
        def __get__(self):
            self.e3SCPhi_branch.GetEntry(self.localentry, 0)
            return self.e3SCPhi_value

    property e3SCPhiWidth:
        def __get__(self):
            self.e3SCPhiWidth_branch.GetEntry(self.localentry, 0)
            return self.e3SCPhiWidth_value

    property e3SCPreshowerEnergy:
        def __get__(self):
            self.e3SCPreshowerEnergy_branch.GetEntry(self.localentry, 0)
            return self.e3SCPreshowerEnergy_value

    property e3SCRawEnergy:
        def __get__(self):
            self.e3SCRawEnergy_branch.GetEntry(self.localentry, 0)
            return self.e3SCRawEnergy_value

    property e3SIP2D:
        def __get__(self):
            self.e3SIP2D_branch.GetEntry(self.localentry, 0)
            return self.e3SIP2D_value

    property e3SIP3D:
        def __get__(self):
            self.e3SIP3D_branch.GetEntry(self.localentry, 0)
            return self.e3SIP3D_value

    property e3SigmaIEtaIEta:
        def __get__(self):
            self.e3SigmaIEtaIEta_branch.GetEntry(self.localentry, 0)
            return self.e3SigmaIEtaIEta_value

    property e3TrkIsoDR03:
        def __get__(self):
            self.e3TrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.e3TrkIsoDR03_value

    property e3VZ:
        def __get__(self):
            self.e3VZ_branch.GetEntry(self.localentry, 0)
            return self.e3VZ_value

    property e3WWLoose:
        def __get__(self):
            self.e3WWLoose_branch.GetEntry(self.localentry, 0)
            return self.e3WWLoose_value

    property e3_e1_collinearmass:
        def __get__(self):
            self.e3_e1_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.e3_e1_collinearmass_value

    property e3_e1_collinearmass_JetEnDown:
        def __get__(self):
            self.e3_e1_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3_e1_collinearmass_JetEnDown_value

    property e3_e1_collinearmass_JetEnUp:
        def __get__(self):
            self.e3_e1_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3_e1_collinearmass_JetEnUp_value

    property e3_e1_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.e3_e1_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3_e1_collinearmass_UnclusteredEnDown_value

    property e3_e1_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.e3_e1_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3_e1_collinearmass_UnclusteredEnUp_value

    property e3_e2_collinearmass:
        def __get__(self):
            self.e3_e2_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.e3_e2_collinearmass_value

    property e3_e2_collinearmass_JetEnDown:
        def __get__(self):
            self.e3_e2_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3_e2_collinearmass_JetEnDown_value

    property e3_e2_collinearmass_JetEnUp:
        def __get__(self):
            self.e3_e2_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3_e2_collinearmass_JetEnUp_value

    property e3_e2_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.e3_e2_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e3_e2_collinearmass_UnclusteredEnDown_value

    property e3_e2_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.e3_e2_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e3_e2_collinearmass_UnclusteredEnUp_value

    property e3deltaEtaSuperClusterTrackAtVtx:
        def __get__(self):
            self.e3deltaEtaSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.e3deltaEtaSuperClusterTrackAtVtx_value

    property e3deltaPhiSuperClusterTrackAtVtx:
        def __get__(self):
            self.e3deltaPhiSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.e3deltaPhiSuperClusterTrackAtVtx_value

    property e3eSuperClusterOverP:
        def __get__(self):
            self.e3eSuperClusterOverP_branch.GetEntry(self.localentry, 0)
            return self.e3eSuperClusterOverP_value

    property e3ecalEnergy:
        def __get__(self):
            self.e3ecalEnergy_branch.GetEntry(self.localentry, 0)
            return self.e3ecalEnergy_value

    property e3fBrem:
        def __get__(self):
            self.e3fBrem_branch.GetEntry(self.localentry, 0)
            return self.e3fBrem_value

    property e3trackMomentumAtVtxP:
        def __get__(self):
            self.e3trackMomentumAtVtxP_branch.GetEntry(self.localentry, 0)
            return self.e3trackMomentumAtVtxP_value

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

    property jet1BJetCISV:
        def __get__(self):
            self.jet1BJetCISV_branch.GetEntry(self.localentry, 0)
            return self.jet1BJetCISV_value

    property jet1Eta:
        def __get__(self):
            self.jet1Eta_branch.GetEntry(self.localentry, 0)
            return self.jet1Eta_value

    property jet1IDLoose:
        def __get__(self):
            self.jet1IDLoose_branch.GetEntry(self.localentry, 0)
            return self.jet1IDLoose_value

    property jet1IDTight:
        def __get__(self):
            self.jet1IDTight_branch.GetEntry(self.localentry, 0)
            return self.jet1IDTight_value

    property jet1IDTightLepVeto:
        def __get__(self):
            self.jet1IDTightLepVeto_branch.GetEntry(self.localentry, 0)
            return self.jet1IDTightLepVeto_value

    property jet1PUMVA:
        def __get__(self):
            self.jet1PUMVA_branch.GetEntry(self.localentry, 0)
            return self.jet1PUMVA_value

    property jet1Phi:
        def __get__(self):
            self.jet1Phi_branch.GetEntry(self.localentry, 0)
            return self.jet1Phi_value

    property jet1Pt:
        def __get__(self):
            self.jet1Pt_branch.GetEntry(self.localentry, 0)
            return self.jet1Pt_value

    property jet2BJetCISV:
        def __get__(self):
            self.jet2BJetCISV_branch.GetEntry(self.localentry, 0)
            return self.jet2BJetCISV_value

    property jet2Eta:
        def __get__(self):
            self.jet2Eta_branch.GetEntry(self.localentry, 0)
            return self.jet2Eta_value

    property jet2IDLoose:
        def __get__(self):
            self.jet2IDLoose_branch.GetEntry(self.localentry, 0)
            return self.jet2IDLoose_value

    property jet2IDTight:
        def __get__(self):
            self.jet2IDTight_branch.GetEntry(self.localentry, 0)
            return self.jet2IDTight_value

    property jet2IDTightLepVeto:
        def __get__(self):
            self.jet2IDTightLepVeto_branch.GetEntry(self.localentry, 0)
            return self.jet2IDTightLepVeto_value

    property jet2PUMVA:
        def __get__(self):
            self.jet2PUMVA_branch.GetEntry(self.localentry, 0)
            return self.jet2PUMVA_value

    property jet2Phi:
        def __get__(self):
            self.jet2Phi_branch.GetEntry(self.localentry, 0)
            return self.jet2Phi_value

    property jet2Pt:
        def __get__(self):
            self.jet2Pt_branch.GetEntry(self.localentry, 0)
            return self.jet2Pt_value

    property jet3BJetCISV:
        def __get__(self):
            self.jet3BJetCISV_branch.GetEntry(self.localentry, 0)
            return self.jet3BJetCISV_value

    property jet3Eta:
        def __get__(self):
            self.jet3Eta_branch.GetEntry(self.localentry, 0)
            return self.jet3Eta_value

    property jet3IDLoose:
        def __get__(self):
            self.jet3IDLoose_branch.GetEntry(self.localentry, 0)
            return self.jet3IDLoose_value

    property jet3IDTight:
        def __get__(self):
            self.jet3IDTight_branch.GetEntry(self.localentry, 0)
            return self.jet3IDTight_value

    property jet3IDTightLepVeto:
        def __get__(self):
            self.jet3IDTightLepVeto_branch.GetEntry(self.localentry, 0)
            return self.jet3IDTightLepVeto_value

    property jet3PUMVA:
        def __get__(self):
            self.jet3PUMVA_branch.GetEntry(self.localentry, 0)
            return self.jet3PUMVA_value

    property jet3Phi:
        def __get__(self):
            self.jet3Phi_branch.GetEntry(self.localentry, 0)
            return self.jet3Phi_value

    property jet3Pt:
        def __get__(self):
            self.jet3Pt_branch.GetEntry(self.localentry, 0)
            return self.jet3Pt_value

    property jet4BJetCISV:
        def __get__(self):
            self.jet4BJetCISV_branch.GetEntry(self.localentry, 0)
            return self.jet4BJetCISV_value

    property jet4Eta:
        def __get__(self):
            self.jet4Eta_branch.GetEntry(self.localentry, 0)
            return self.jet4Eta_value

    property jet4IDLoose:
        def __get__(self):
            self.jet4IDLoose_branch.GetEntry(self.localentry, 0)
            return self.jet4IDLoose_value

    property jet4IDTight:
        def __get__(self):
            self.jet4IDTight_branch.GetEntry(self.localentry, 0)
            return self.jet4IDTight_value

    property jet4IDTightLepVeto:
        def __get__(self):
            self.jet4IDTightLepVeto_branch.GetEntry(self.localentry, 0)
            return self.jet4IDTightLepVeto_value

    property jet4PUMVA:
        def __get__(self):
            self.jet4PUMVA_branch.GetEntry(self.localentry, 0)
            return self.jet4PUMVA_value

    property jet4Phi:
        def __get__(self):
            self.jet4Phi_branch.GetEntry(self.localentry, 0)
            return self.jet4Phi_value

    property jet4Pt:
        def __get__(self):
            self.jet4Pt_branch.GetEntry(self.localentry, 0)
            return self.jet4Pt_value

    property jet5BJetCISV:
        def __get__(self):
            self.jet5BJetCISV_branch.GetEntry(self.localentry, 0)
            return self.jet5BJetCISV_value

    property jet5Eta:
        def __get__(self):
            self.jet5Eta_branch.GetEntry(self.localentry, 0)
            return self.jet5Eta_value

    property jet5IDLoose:
        def __get__(self):
            self.jet5IDLoose_branch.GetEntry(self.localentry, 0)
            return self.jet5IDLoose_value

    property jet5IDTight:
        def __get__(self):
            self.jet5IDTight_branch.GetEntry(self.localentry, 0)
            return self.jet5IDTight_value

    property jet5IDTightLepVeto:
        def __get__(self):
            self.jet5IDTightLepVeto_branch.GetEntry(self.localentry, 0)
            return self.jet5IDTightLepVeto_value

    property jet5PUMVA:
        def __get__(self):
            self.jet5PUMVA_branch.GetEntry(self.localentry, 0)
            return self.jet5PUMVA_value

    property jet5Phi:
        def __get__(self):
            self.jet5Phi_branch.GetEntry(self.localentry, 0)
            return self.jet5Phi_value

    property jet5Pt:
        def __get__(self):
            self.jet5Pt_branch.GetEntry(self.localentry, 0)
            return self.jet5Pt_value

    property jet6BJetCISV:
        def __get__(self):
            self.jet6BJetCISV_branch.GetEntry(self.localentry, 0)
            return self.jet6BJetCISV_value

    property jet6Eta:
        def __get__(self):
            self.jet6Eta_branch.GetEntry(self.localentry, 0)
            return self.jet6Eta_value

    property jet6IDLoose:
        def __get__(self):
            self.jet6IDLoose_branch.GetEntry(self.localentry, 0)
            return self.jet6IDLoose_value

    property jet6IDTight:
        def __get__(self):
            self.jet6IDTight_branch.GetEntry(self.localentry, 0)
            return self.jet6IDTight_value

    property jet6IDTightLepVeto:
        def __get__(self):
            self.jet6IDTightLepVeto_branch.GetEntry(self.localentry, 0)
            return self.jet6IDTightLepVeto_value

    property jet6PUMVA:
        def __get__(self):
            self.jet6PUMVA_branch.GetEntry(self.localentry, 0)
            return self.jet6PUMVA_value

    property jet6Phi:
        def __get__(self):
            self.jet6Phi_branch.GetEntry(self.localentry, 0)
            return self.jet6Phi_value

    property jet6Pt:
        def __get__(self):
            self.jet6Pt_branch.GetEntry(self.localentry, 0)
            return self.jet6Pt_value

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

    property singleE23WPLooseGroup:
        def __get__(self):
            self.singleE23WPLooseGroup_branch.GetEntry(self.localentry, 0)
            return self.singleE23WPLooseGroup_value

    property singleE23WPLoosePass:
        def __get__(self):
            self.singleE23WPLoosePass_branch.GetEntry(self.localentry, 0)
            return self.singleE23WPLoosePass_value

    property singleE23WPLoosePrescale:
        def __get__(self):
            self.singleE23WPLoosePrescale_branch.GetEntry(self.localentry, 0)
            return self.singleE23WPLoosePrescale_value

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

    property singleIsoMu27Group:
        def __get__(self):
            self.singleIsoMu27Group_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu27Group_value

    property singleIsoMu27Pass:
        def __get__(self):
            self.singleIsoMu27Pass_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu27Pass_value

    property singleIsoMu27Prescale:
        def __get__(self):
            self.singleIsoMu27Prescale_branch.GetEntry(self.localentry, 0)
            return self.singleIsoMu27Prescale_value

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


