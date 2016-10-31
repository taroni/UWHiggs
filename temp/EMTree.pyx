

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

cdef class EMTree:
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

    cdef TBranch* eAbsEta_branch
    cdef float eAbsEta_value

    cdef TBranch* eCBIDLoose_branch
    cdef float eCBIDLoose_value

    cdef TBranch* eCBIDLooseNoIso_branch
    cdef float eCBIDLooseNoIso_value

    cdef TBranch* eCBIDMedium_branch
    cdef float eCBIDMedium_value

    cdef TBranch* eCBIDMediumNoIso_branch
    cdef float eCBIDMediumNoIso_value

    cdef TBranch* eCBIDTight_branch
    cdef float eCBIDTight_value

    cdef TBranch* eCBIDTightNoIso_branch
    cdef float eCBIDTightNoIso_value

    cdef TBranch* eCBIDVeto_branch
    cdef float eCBIDVeto_value

    cdef TBranch* eCBIDVetoNoIso_branch
    cdef float eCBIDVetoNoIso_value

    cdef TBranch* eCharge_branch
    cdef float eCharge_value

    cdef TBranch* eChargeIdLoose_branch
    cdef float eChargeIdLoose_value

    cdef TBranch* eChargeIdMed_branch
    cdef float eChargeIdMed_value

    cdef TBranch* eChargeIdTight_branch
    cdef float eChargeIdTight_value

    cdef TBranch* eComesFromHiggs_branch
    cdef float eComesFromHiggs_value

    cdef TBranch* eDPhiToPfMet_ElectronEnDown_branch
    cdef float eDPhiToPfMet_ElectronEnDown_value

    cdef TBranch* eDPhiToPfMet_ElectronEnUp_branch
    cdef float eDPhiToPfMet_ElectronEnUp_value

    cdef TBranch* eDPhiToPfMet_JetEnDown_branch
    cdef float eDPhiToPfMet_JetEnDown_value

    cdef TBranch* eDPhiToPfMet_JetEnUp_branch
    cdef float eDPhiToPfMet_JetEnUp_value

    cdef TBranch* eDPhiToPfMet_JetResDown_branch
    cdef float eDPhiToPfMet_JetResDown_value

    cdef TBranch* eDPhiToPfMet_JetResUp_branch
    cdef float eDPhiToPfMet_JetResUp_value

    cdef TBranch* eDPhiToPfMet_MuonEnDown_branch
    cdef float eDPhiToPfMet_MuonEnDown_value

    cdef TBranch* eDPhiToPfMet_MuonEnUp_branch
    cdef float eDPhiToPfMet_MuonEnUp_value

    cdef TBranch* eDPhiToPfMet_PhotonEnDown_branch
    cdef float eDPhiToPfMet_PhotonEnDown_value

    cdef TBranch* eDPhiToPfMet_PhotonEnUp_branch
    cdef float eDPhiToPfMet_PhotonEnUp_value

    cdef TBranch* eDPhiToPfMet_TauEnDown_branch
    cdef float eDPhiToPfMet_TauEnDown_value

    cdef TBranch* eDPhiToPfMet_TauEnUp_branch
    cdef float eDPhiToPfMet_TauEnUp_value

    cdef TBranch* eDPhiToPfMet_UnclusteredEnDown_branch
    cdef float eDPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* eDPhiToPfMet_UnclusteredEnUp_branch
    cdef float eDPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* eDPhiToPfMet_type1_branch
    cdef float eDPhiToPfMet_type1_value

    cdef TBranch* eE1x5_branch
    cdef float eE1x5_value

    cdef TBranch* eE2x5Max_branch
    cdef float eE2x5Max_value

    cdef TBranch* eE5x5_branch
    cdef float eE5x5_value

    cdef TBranch* eEcalIsoDR03_branch
    cdef float eEcalIsoDR03_value

    cdef TBranch* eEffectiveArea2012Data_branch
    cdef float eEffectiveArea2012Data_value

    cdef TBranch* eEffectiveAreaSpring15_branch
    cdef float eEffectiveAreaSpring15_value

    cdef TBranch* eEnergyError_branch
    cdef float eEnergyError_value

    cdef TBranch* eEta_branch
    cdef float eEta_value

    cdef TBranch* eEta_ElectronEnDown_branch
    cdef float eEta_ElectronEnDown_value

    cdef TBranch* eEta_ElectronEnUp_branch
    cdef float eEta_ElectronEnUp_value

    cdef TBranch* eGenCharge_branch
    cdef float eGenCharge_value

    cdef TBranch* eGenEnergy_branch
    cdef float eGenEnergy_value

    cdef TBranch* eGenEta_branch
    cdef float eGenEta_value

    cdef TBranch* eGenMotherPdgId_branch
    cdef float eGenMotherPdgId_value

    cdef TBranch* eGenParticle_branch
    cdef float eGenParticle_value

    cdef TBranch* eGenPdgId_branch
    cdef float eGenPdgId_value

    cdef TBranch* eGenPhi_branch
    cdef float eGenPhi_value

    cdef TBranch* eGenPrompt_branch
    cdef float eGenPrompt_value

    cdef TBranch* eGenPromptTauDecay_branch
    cdef float eGenPromptTauDecay_value

    cdef TBranch* eGenPt_branch
    cdef float eGenPt_value

    cdef TBranch* eGenTauDecay_branch
    cdef float eGenTauDecay_value

    cdef TBranch* eGenVZ_branch
    cdef float eGenVZ_value

    cdef TBranch* eGenVtxPVMatch_branch
    cdef float eGenVtxPVMatch_value

    cdef TBranch* eHadronicDepth1OverEm_branch
    cdef float eHadronicDepth1OverEm_value

    cdef TBranch* eHadronicDepth2OverEm_branch
    cdef float eHadronicDepth2OverEm_value

    cdef TBranch* eHadronicOverEM_branch
    cdef float eHadronicOverEM_value

    cdef TBranch* eHcalIsoDR03_branch
    cdef float eHcalIsoDR03_value

    cdef TBranch* eIP3D_branch
    cdef float eIP3D_value

    cdef TBranch* eIP3DErr_branch
    cdef float eIP3DErr_value

    cdef TBranch* eJetArea_branch
    cdef float eJetArea_value

    cdef TBranch* eJetBtag_branch
    cdef float eJetBtag_value

    cdef TBranch* eJetEtaEtaMoment_branch
    cdef float eJetEtaEtaMoment_value

    cdef TBranch* eJetEtaPhiMoment_branch
    cdef float eJetEtaPhiMoment_value

    cdef TBranch* eJetEtaPhiSpread_branch
    cdef float eJetEtaPhiSpread_value

    cdef TBranch* eJetPFCISVBtag_branch
    cdef float eJetPFCISVBtag_value

    cdef TBranch* eJetPartonFlavour_branch
    cdef float eJetPartonFlavour_value

    cdef TBranch* eJetPhiPhiMoment_branch
    cdef float eJetPhiPhiMoment_value

    cdef TBranch* eJetPt_branch
    cdef float eJetPt_value

    cdef TBranch* eLowestMll_branch
    cdef float eLowestMll_value

    cdef TBranch* eMVANonTrigCategory_branch
    cdef float eMVANonTrigCategory_value

    cdef TBranch* eMVANonTrigID_branch
    cdef float eMVANonTrigID_value

    cdef TBranch* eMVANonTrigWP80_branch
    cdef float eMVANonTrigWP80_value

    cdef TBranch* eMVANonTrigWP90_branch
    cdef float eMVANonTrigWP90_value

    cdef TBranch* eMVATrigCategory_branch
    cdef float eMVATrigCategory_value

    cdef TBranch* eMVATrigID_branch
    cdef float eMVATrigID_value

    cdef TBranch* eMVATrigWP80_branch
    cdef float eMVATrigWP80_value

    cdef TBranch* eMVATrigWP90_branch
    cdef float eMVATrigWP90_value

    cdef TBranch* eMass_branch
    cdef float eMass_value

    cdef TBranch* eMatchesDoubleE_branch
    cdef float eMatchesDoubleE_value

    cdef TBranch* eMatchesDoubleESingleMu_branch
    cdef float eMatchesDoubleESingleMu_value

    cdef TBranch* eMatchesDoubleMuSingleE_branch
    cdef float eMatchesDoubleMuSingleE_value

    cdef TBranch* eMatchesSingleE_branch
    cdef float eMatchesSingleE_value

    cdef TBranch* eMatchesSingleESingleMu_branch
    cdef float eMatchesSingleESingleMu_value

    cdef TBranch* eMatchesSingleE_leg1_branch
    cdef float eMatchesSingleE_leg1_value

    cdef TBranch* eMatchesSingleE_leg2_branch
    cdef float eMatchesSingleE_leg2_value

    cdef TBranch* eMatchesSingleMuSingleE_branch
    cdef float eMatchesSingleMuSingleE_value

    cdef TBranch* eMatchesTripleE_branch
    cdef float eMatchesTripleE_value

    cdef TBranch* eMissingHits_branch
    cdef float eMissingHits_value

    cdef TBranch* eMtToPfMet_ElectronEnDown_branch
    cdef float eMtToPfMet_ElectronEnDown_value

    cdef TBranch* eMtToPfMet_ElectronEnUp_branch
    cdef float eMtToPfMet_ElectronEnUp_value

    cdef TBranch* eMtToPfMet_JetEnDown_branch
    cdef float eMtToPfMet_JetEnDown_value

    cdef TBranch* eMtToPfMet_JetEnUp_branch
    cdef float eMtToPfMet_JetEnUp_value

    cdef TBranch* eMtToPfMet_JetResDown_branch
    cdef float eMtToPfMet_JetResDown_value

    cdef TBranch* eMtToPfMet_JetResUp_branch
    cdef float eMtToPfMet_JetResUp_value

    cdef TBranch* eMtToPfMet_MuonEnDown_branch
    cdef float eMtToPfMet_MuonEnDown_value

    cdef TBranch* eMtToPfMet_MuonEnUp_branch
    cdef float eMtToPfMet_MuonEnUp_value

    cdef TBranch* eMtToPfMet_PhotonEnDown_branch
    cdef float eMtToPfMet_PhotonEnDown_value

    cdef TBranch* eMtToPfMet_PhotonEnUp_branch
    cdef float eMtToPfMet_PhotonEnUp_value

    cdef TBranch* eMtToPfMet_Raw_branch
    cdef float eMtToPfMet_Raw_value

    cdef TBranch* eMtToPfMet_TauEnDown_branch
    cdef float eMtToPfMet_TauEnDown_value

    cdef TBranch* eMtToPfMet_TauEnUp_branch
    cdef float eMtToPfMet_TauEnUp_value

    cdef TBranch* eMtToPfMet_UnclusteredEnDown_branch
    cdef float eMtToPfMet_UnclusteredEnDown_value

    cdef TBranch* eMtToPfMet_UnclusteredEnUp_branch
    cdef float eMtToPfMet_UnclusteredEnUp_value

    cdef TBranch* eMtToPfMet_type1_branch
    cdef float eMtToPfMet_type1_value

    cdef TBranch* eNearMuonVeto_branch
    cdef float eNearMuonVeto_value

    cdef TBranch* eNearestMuonDR_branch
    cdef float eNearestMuonDR_value

    cdef TBranch* eNearestZMass_branch
    cdef float eNearestZMass_value

    cdef TBranch* ePFChargedIso_branch
    cdef float ePFChargedIso_value

    cdef TBranch* ePFNeutralIso_branch
    cdef float ePFNeutralIso_value

    cdef TBranch* ePFPUChargedIso_branch
    cdef float ePFPUChargedIso_value

    cdef TBranch* ePFPhotonIso_branch
    cdef float ePFPhotonIso_value

    cdef TBranch* ePVDXY_branch
    cdef float ePVDXY_value

    cdef TBranch* ePVDZ_branch
    cdef float ePVDZ_value

    cdef TBranch* ePassesConversionVeto_branch
    cdef float ePassesConversionVeto_value

    cdef TBranch* ePhi_branch
    cdef float ePhi_value

    cdef TBranch* ePhi_ElectronEnDown_branch
    cdef float ePhi_ElectronEnDown_value

    cdef TBranch* ePhi_ElectronEnUp_branch
    cdef float ePhi_ElectronEnUp_value

    cdef TBranch* ePt_branch
    cdef float ePt_value

    cdef TBranch* ePt_ElectronEnDown_branch
    cdef float ePt_ElectronEnDown_value

    cdef TBranch* ePt_ElectronEnUp_branch
    cdef float ePt_ElectronEnUp_value

    cdef TBranch* eRank_branch
    cdef float eRank_value

    cdef TBranch* eRelIso_branch
    cdef float eRelIso_value

    cdef TBranch* eRelPFIsoDB_branch
    cdef float eRelPFIsoDB_value

    cdef TBranch* eRelPFIsoRho_branch
    cdef float eRelPFIsoRho_value

    cdef TBranch* eRho_branch
    cdef float eRho_value

    cdef TBranch* eSCEnergy_branch
    cdef float eSCEnergy_value

    cdef TBranch* eSCEta_branch
    cdef float eSCEta_value

    cdef TBranch* eSCEtaWidth_branch
    cdef float eSCEtaWidth_value

    cdef TBranch* eSCPhi_branch
    cdef float eSCPhi_value

    cdef TBranch* eSCPhiWidth_branch
    cdef float eSCPhiWidth_value

    cdef TBranch* eSCPreshowerEnergy_branch
    cdef float eSCPreshowerEnergy_value

    cdef TBranch* eSCRawEnergy_branch
    cdef float eSCRawEnergy_value

    cdef TBranch* eSIP2D_branch
    cdef float eSIP2D_value

    cdef TBranch* eSIP3D_branch
    cdef float eSIP3D_value

    cdef TBranch* eSigmaIEtaIEta_branch
    cdef float eSigmaIEtaIEta_value

    cdef TBranch* eTrkIsoDR03_branch
    cdef float eTrkIsoDR03_value

    cdef TBranch* eVZ_branch
    cdef float eVZ_value

    cdef TBranch* eVetoMVAIso_branch
    cdef float eVetoMVAIso_value

    cdef TBranch* eVetoMVAIsoVtx_branch
    cdef float eVetoMVAIsoVtx_value

    cdef TBranch* eWWLoose_branch
    cdef float eWWLoose_value

    cdef TBranch* e_m_CosThetaStar_branch
    cdef float e_m_CosThetaStar_value

    cdef TBranch* e_m_DPhi_branch
    cdef float e_m_DPhi_value

    cdef TBranch* e_m_DR_branch
    cdef float e_m_DR_value

    cdef TBranch* e_m_Eta_branch
    cdef float e_m_Eta_value

    cdef TBranch* e_m_Mass_branch
    cdef float e_m_Mass_value

    cdef TBranch* e_m_Mt_branch
    cdef float e_m_Mt_value

    cdef TBranch* e_m_PZeta_branch
    cdef float e_m_PZeta_value

    cdef TBranch* e_m_PZetaVis_branch
    cdef float e_m_PZetaVis_value

    cdef TBranch* e_m_Phi_branch
    cdef float e_m_Phi_value

    cdef TBranch* e_m_Pt_branch
    cdef float e_m_Pt_value

    cdef TBranch* e_m_SS_branch
    cdef float e_m_SS_value

    cdef TBranch* e_m_ToMETDPhi_Ty1_branch
    cdef float e_m_ToMETDPhi_Ty1_value

    cdef TBranch* e_m_collinearmass_branch
    cdef float e_m_collinearmass_value

    cdef TBranch* e_m_collinearmass_JetEnDown_branch
    cdef float e_m_collinearmass_JetEnDown_value

    cdef TBranch* e_m_collinearmass_JetEnUp_branch
    cdef float e_m_collinearmass_JetEnUp_value

    cdef TBranch* e_m_collinearmass_UnclusteredEnDown_branch
    cdef float e_m_collinearmass_UnclusteredEnDown_value

    cdef TBranch* e_m_collinearmass_UnclusteredEnUp_branch
    cdef float e_m_collinearmass_UnclusteredEnUp_value

    cdef TBranch* edeltaEtaSuperClusterTrackAtVtx_branch
    cdef float edeltaEtaSuperClusterTrackAtVtx_value

    cdef TBranch* edeltaPhiSuperClusterTrackAtVtx_branch
    cdef float edeltaPhiSuperClusterTrackAtVtx_value

    cdef TBranch* eeSuperClusterOverP_branch
    cdef float eeSuperClusterOverP_value

    cdef TBranch* eecalEnergy_branch
    cdef float eecalEnergy_value

    cdef TBranch* efBrem_branch
    cdef float efBrem_value

    cdef TBranch* etrackMomentumAtVtxP_branch
    cdef float etrackMomentumAtVtxP_value

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

    cdef TBranch* mAbsEta_branch
    cdef float mAbsEta_value

    cdef TBranch* mBestTrackType_branch
    cdef float mBestTrackType_value

    cdef TBranch* mCharge_branch
    cdef float mCharge_value

    cdef TBranch* mComesFromHiggs_branch
    cdef float mComesFromHiggs_value

    cdef TBranch* mDPhiToPfMet_ElectronEnDown_branch
    cdef float mDPhiToPfMet_ElectronEnDown_value

    cdef TBranch* mDPhiToPfMet_ElectronEnUp_branch
    cdef float mDPhiToPfMet_ElectronEnUp_value

    cdef TBranch* mDPhiToPfMet_JetEnDown_branch
    cdef float mDPhiToPfMet_JetEnDown_value

    cdef TBranch* mDPhiToPfMet_JetEnUp_branch
    cdef float mDPhiToPfMet_JetEnUp_value

    cdef TBranch* mDPhiToPfMet_JetResDown_branch
    cdef float mDPhiToPfMet_JetResDown_value

    cdef TBranch* mDPhiToPfMet_JetResUp_branch
    cdef float mDPhiToPfMet_JetResUp_value

    cdef TBranch* mDPhiToPfMet_MuonEnDown_branch
    cdef float mDPhiToPfMet_MuonEnDown_value

    cdef TBranch* mDPhiToPfMet_MuonEnUp_branch
    cdef float mDPhiToPfMet_MuonEnUp_value

    cdef TBranch* mDPhiToPfMet_PhotonEnDown_branch
    cdef float mDPhiToPfMet_PhotonEnDown_value

    cdef TBranch* mDPhiToPfMet_PhotonEnUp_branch
    cdef float mDPhiToPfMet_PhotonEnUp_value

    cdef TBranch* mDPhiToPfMet_TauEnDown_branch
    cdef float mDPhiToPfMet_TauEnDown_value

    cdef TBranch* mDPhiToPfMet_TauEnUp_branch
    cdef float mDPhiToPfMet_TauEnUp_value

    cdef TBranch* mDPhiToPfMet_UnclusteredEnDown_branch
    cdef float mDPhiToPfMet_UnclusteredEnDown_value

    cdef TBranch* mDPhiToPfMet_UnclusteredEnUp_branch
    cdef float mDPhiToPfMet_UnclusteredEnUp_value

    cdef TBranch* mDPhiToPfMet_type1_branch
    cdef float mDPhiToPfMet_type1_value

    cdef TBranch* mEcalIsoDR03_branch
    cdef float mEcalIsoDR03_value

    cdef TBranch* mEffectiveArea2011_branch
    cdef float mEffectiveArea2011_value

    cdef TBranch* mEffectiveArea2012_branch
    cdef float mEffectiveArea2012_value

    cdef TBranch* mEta_branch
    cdef float mEta_value

    cdef TBranch* mEta_MuonEnDown_branch
    cdef float mEta_MuonEnDown_value

    cdef TBranch* mEta_MuonEnUp_branch
    cdef float mEta_MuonEnUp_value

    cdef TBranch* mGenCharge_branch
    cdef float mGenCharge_value

    cdef TBranch* mGenEnergy_branch
    cdef float mGenEnergy_value

    cdef TBranch* mGenEta_branch
    cdef float mGenEta_value

    cdef TBranch* mGenMotherPdgId_branch
    cdef float mGenMotherPdgId_value

    cdef TBranch* mGenParticle_branch
    cdef float mGenParticle_value

    cdef TBranch* mGenPdgId_branch
    cdef float mGenPdgId_value

    cdef TBranch* mGenPhi_branch
    cdef float mGenPhi_value

    cdef TBranch* mGenPrompt_branch
    cdef float mGenPrompt_value

    cdef TBranch* mGenPromptTauDecay_branch
    cdef float mGenPromptTauDecay_value

    cdef TBranch* mGenPt_branch
    cdef float mGenPt_value

    cdef TBranch* mGenTauDecay_branch
    cdef float mGenTauDecay_value

    cdef TBranch* mGenVZ_branch
    cdef float mGenVZ_value

    cdef TBranch* mGenVtxPVMatch_branch
    cdef float mGenVtxPVMatch_value

    cdef TBranch* mHcalIsoDR03_branch
    cdef float mHcalIsoDR03_value

    cdef TBranch* mIP3D_branch
    cdef float mIP3D_value

    cdef TBranch* mIP3DErr_branch
    cdef float mIP3DErr_value

    cdef TBranch* mIsGlobal_branch
    cdef float mIsGlobal_value

    cdef TBranch* mIsPFMuon_branch
    cdef float mIsPFMuon_value

    cdef TBranch* mIsTracker_branch
    cdef float mIsTracker_value

    cdef TBranch* mJetArea_branch
    cdef float mJetArea_value

    cdef TBranch* mJetBtag_branch
    cdef float mJetBtag_value

    cdef TBranch* mJetEtaEtaMoment_branch
    cdef float mJetEtaEtaMoment_value

    cdef TBranch* mJetEtaPhiMoment_branch
    cdef float mJetEtaPhiMoment_value

    cdef TBranch* mJetEtaPhiSpread_branch
    cdef float mJetEtaPhiSpread_value

    cdef TBranch* mJetPFCISVBtag_branch
    cdef float mJetPFCISVBtag_value

    cdef TBranch* mJetPartonFlavour_branch
    cdef float mJetPartonFlavour_value

    cdef TBranch* mJetPhiPhiMoment_branch
    cdef float mJetPhiPhiMoment_value

    cdef TBranch* mJetPt_branch
    cdef float mJetPt_value

    cdef TBranch* mLowestMll_branch
    cdef float mLowestMll_value

    cdef TBranch* mMass_branch
    cdef float mMass_value

    cdef TBranch* mMatchedStations_branch
    cdef float mMatchedStations_value

    cdef TBranch* mMatchesDoubleESingleMu_branch
    cdef float mMatchesDoubleESingleMu_value

    cdef TBranch* mMatchesDoubleMu_branch
    cdef float mMatchesDoubleMu_value

    cdef TBranch* mMatchesDoubleMuSingleE_branch
    cdef float mMatchesDoubleMuSingleE_value

    cdef TBranch* mMatchesSingleESingleMu_branch
    cdef float mMatchesSingleESingleMu_value

    cdef TBranch* mMatchesSingleMu_branch
    cdef float mMatchesSingleMu_value

    cdef TBranch* mMatchesSingleMuIso20_branch
    cdef float mMatchesSingleMuIso20_value

    cdef TBranch* mMatchesSingleMuIsoTk20_branch
    cdef float mMatchesSingleMuIsoTk20_value

    cdef TBranch* mMatchesSingleMuSingleE_branch
    cdef float mMatchesSingleMuSingleE_value

    cdef TBranch* mMatchesSingleMu_leg1_branch
    cdef float mMatchesSingleMu_leg1_value

    cdef TBranch* mMatchesSingleMu_leg1_noiso_branch
    cdef float mMatchesSingleMu_leg1_noiso_value

    cdef TBranch* mMatchesSingleMu_leg2_branch
    cdef float mMatchesSingleMu_leg2_value

    cdef TBranch* mMatchesSingleMu_leg2_noiso_branch
    cdef float mMatchesSingleMu_leg2_noiso_value

    cdef TBranch* mMatchesTripleMu_branch
    cdef float mMatchesTripleMu_value

    cdef TBranch* mMtToPfMet_ElectronEnDown_branch
    cdef float mMtToPfMet_ElectronEnDown_value

    cdef TBranch* mMtToPfMet_ElectronEnUp_branch
    cdef float mMtToPfMet_ElectronEnUp_value

    cdef TBranch* mMtToPfMet_JetEnDown_branch
    cdef float mMtToPfMet_JetEnDown_value

    cdef TBranch* mMtToPfMet_JetEnUp_branch
    cdef float mMtToPfMet_JetEnUp_value

    cdef TBranch* mMtToPfMet_JetResDown_branch
    cdef float mMtToPfMet_JetResDown_value

    cdef TBranch* mMtToPfMet_JetResUp_branch
    cdef float mMtToPfMet_JetResUp_value

    cdef TBranch* mMtToPfMet_MuonEnDown_branch
    cdef float mMtToPfMet_MuonEnDown_value

    cdef TBranch* mMtToPfMet_MuonEnUp_branch
    cdef float mMtToPfMet_MuonEnUp_value

    cdef TBranch* mMtToPfMet_PhotonEnDown_branch
    cdef float mMtToPfMet_PhotonEnDown_value

    cdef TBranch* mMtToPfMet_PhotonEnUp_branch
    cdef float mMtToPfMet_PhotonEnUp_value

    cdef TBranch* mMtToPfMet_Raw_branch
    cdef float mMtToPfMet_Raw_value

    cdef TBranch* mMtToPfMet_TauEnDown_branch
    cdef float mMtToPfMet_TauEnDown_value

    cdef TBranch* mMtToPfMet_TauEnUp_branch
    cdef float mMtToPfMet_TauEnUp_value

    cdef TBranch* mMtToPfMet_UnclusteredEnDown_branch
    cdef float mMtToPfMet_UnclusteredEnDown_value

    cdef TBranch* mMtToPfMet_UnclusteredEnUp_branch
    cdef float mMtToPfMet_UnclusteredEnUp_value

    cdef TBranch* mMtToPfMet_type1_branch
    cdef float mMtToPfMet_type1_value

    cdef TBranch* mMuonHits_branch
    cdef float mMuonHits_value

    cdef TBranch* mNearestZMass_branch
    cdef float mNearestZMass_value

    cdef TBranch* mNormTrkChi2_branch
    cdef float mNormTrkChi2_value

    cdef TBranch* mPFChargedHadronIsoR04_branch
    cdef float mPFChargedHadronIsoR04_value

    cdef TBranch* mPFChargedIso_branch
    cdef float mPFChargedIso_value

    cdef TBranch* mPFIDLoose_branch
    cdef float mPFIDLoose_value

    cdef TBranch* mPFIDMedium_branch
    cdef float mPFIDMedium_value

    cdef TBranch* mPFIDTight_branch
    cdef float mPFIDTight_value

    cdef TBranch* mPFNeutralHadronIsoR04_branch
    cdef float mPFNeutralHadronIsoR04_value

    cdef TBranch* mPFNeutralIso_branch
    cdef float mPFNeutralIso_value

    cdef TBranch* mPFPUChargedIso_branch
    cdef float mPFPUChargedIso_value

    cdef TBranch* mPFPhotonIso_branch
    cdef float mPFPhotonIso_value

    cdef TBranch* mPFPhotonIsoR04_branch
    cdef float mPFPhotonIsoR04_value

    cdef TBranch* mPFPileupIsoR04_branch
    cdef float mPFPileupIsoR04_value

    cdef TBranch* mPVDXY_branch
    cdef float mPVDXY_value

    cdef TBranch* mPVDZ_branch
    cdef float mPVDZ_value

    cdef TBranch* mPhi_branch
    cdef float mPhi_value

    cdef TBranch* mPhi_MuonEnDown_branch
    cdef float mPhi_MuonEnDown_value

    cdef TBranch* mPhi_MuonEnUp_branch
    cdef float mPhi_MuonEnUp_value

    cdef TBranch* mPixHits_branch
    cdef float mPixHits_value

    cdef TBranch* mPt_branch
    cdef float mPt_value

    cdef TBranch* mPt_MuonEnDown_branch
    cdef float mPt_MuonEnDown_value

    cdef TBranch* mPt_MuonEnUp_branch
    cdef float mPt_MuonEnUp_value

    cdef TBranch* mRank_branch
    cdef float mRank_value

    cdef TBranch* mRelPFIsoDBDefault_branch
    cdef float mRelPFIsoDBDefault_value

    cdef TBranch* mRelPFIsoDBDefaultR04_branch
    cdef float mRelPFIsoDBDefaultR04_value

    cdef TBranch* mRelPFIsoRho_branch
    cdef float mRelPFIsoRho_value

    cdef TBranch* mRho_branch
    cdef float mRho_value

    cdef TBranch* mSIP2D_branch
    cdef float mSIP2D_value

    cdef TBranch* mSIP3D_branch
    cdef float mSIP3D_value

    cdef TBranch* mTkLayersWithMeasurement_branch
    cdef float mTkLayersWithMeasurement_value

    cdef TBranch* mTrkIsoDR03_branch
    cdef float mTrkIsoDR03_value

    cdef TBranch* mTypeCode_branch
    cdef int mTypeCode_value

    cdef TBranch* mVZ_branch
    cdef float mVZ_value

    cdef TBranch* m_e_collinearmass_branch
    cdef float m_e_collinearmass_value

    cdef TBranch* m_e_collinearmass_JetEnDown_branch
    cdef float m_e_collinearmass_JetEnDown_value

    cdef TBranch* m_e_collinearmass_JetEnUp_branch
    cdef float m_e_collinearmass_JetEnUp_value

    cdef TBranch* m_e_collinearmass_UnclusteredEnDown_branch
    cdef float m_e_collinearmass_UnclusteredEnDown_value

    cdef TBranch* m_e_collinearmass_UnclusteredEnUp_branch
    cdef float m_e_collinearmass_UnclusteredEnUp_value

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
            warnings.warn( "EMTree: Expected branch EmbPtWeight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("EmbPtWeight")
        else:
            self.EmbPtWeight_branch.SetAddress(<void*>&self.EmbPtWeight_value)

        #print "making Eta"
        self.Eta_branch = the_tree.GetBranch("Eta")
        #if not self.Eta_branch and "Eta" not in self.complained:
        if not self.Eta_branch and "Eta":
            warnings.warn( "EMTree: Expected branch Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Eta")
        else:
            self.Eta_branch.SetAddress(<void*>&self.Eta_value)

        #print "making GenWeight"
        self.GenWeight_branch = the_tree.GetBranch("GenWeight")
        #if not self.GenWeight_branch and "GenWeight" not in self.complained:
        if not self.GenWeight_branch and "GenWeight":
            warnings.warn( "EMTree: Expected branch GenWeight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("GenWeight")
        else:
            self.GenWeight_branch.SetAddress(<void*>&self.GenWeight_value)

        #print "making Ht"
        self.Ht_branch = the_tree.GetBranch("Ht")
        #if not self.Ht_branch and "Ht" not in self.complained:
        if not self.Ht_branch and "Ht":
            warnings.warn( "EMTree: Expected branch Ht does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Ht")
        else:
            self.Ht_branch.SetAddress(<void*>&self.Ht_value)

        #print "making LT"
        self.LT_branch = the_tree.GetBranch("LT")
        #if not self.LT_branch and "LT" not in self.complained:
        if not self.LT_branch and "LT":
            warnings.warn( "EMTree: Expected branch LT does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("LT")
        else:
            self.LT_branch.SetAddress(<void*>&self.LT_value)

        #print "making Mass"
        self.Mass_branch = the_tree.GetBranch("Mass")
        #if not self.Mass_branch and "Mass" not in self.complained:
        if not self.Mass_branch and "Mass":
            warnings.warn( "EMTree: Expected branch Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Mass")
        else:
            self.Mass_branch.SetAddress(<void*>&self.Mass_value)

        #print "making MassError"
        self.MassError_branch = the_tree.GetBranch("MassError")
        #if not self.MassError_branch and "MassError" not in self.complained:
        if not self.MassError_branch and "MassError":
            warnings.warn( "EMTree: Expected branch MassError does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassError")
        else:
            self.MassError_branch.SetAddress(<void*>&self.MassError_value)

        #print "making MassErrord1"
        self.MassErrord1_branch = the_tree.GetBranch("MassErrord1")
        #if not self.MassErrord1_branch and "MassErrord1" not in self.complained:
        if not self.MassErrord1_branch and "MassErrord1":
            warnings.warn( "EMTree: Expected branch MassErrord1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord1")
        else:
            self.MassErrord1_branch.SetAddress(<void*>&self.MassErrord1_value)

        #print "making MassErrord2"
        self.MassErrord2_branch = the_tree.GetBranch("MassErrord2")
        #if not self.MassErrord2_branch and "MassErrord2" not in self.complained:
        if not self.MassErrord2_branch and "MassErrord2":
            warnings.warn( "EMTree: Expected branch MassErrord2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord2")
        else:
            self.MassErrord2_branch.SetAddress(<void*>&self.MassErrord2_value)

        #print "making MassErrord3"
        self.MassErrord3_branch = the_tree.GetBranch("MassErrord3")
        #if not self.MassErrord3_branch and "MassErrord3" not in self.complained:
        if not self.MassErrord3_branch and "MassErrord3":
            warnings.warn( "EMTree: Expected branch MassErrord3 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord3")
        else:
            self.MassErrord3_branch.SetAddress(<void*>&self.MassErrord3_value)

        #print "making MassErrord4"
        self.MassErrord4_branch = the_tree.GetBranch("MassErrord4")
        #if not self.MassErrord4_branch and "MassErrord4" not in self.complained:
        if not self.MassErrord4_branch and "MassErrord4":
            warnings.warn( "EMTree: Expected branch MassErrord4 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("MassErrord4")
        else:
            self.MassErrord4_branch.SetAddress(<void*>&self.MassErrord4_value)

        #print "making Mt"
        self.Mt_branch = the_tree.GetBranch("Mt")
        #if not self.Mt_branch and "Mt" not in self.complained:
        if not self.Mt_branch and "Mt":
            warnings.warn( "EMTree: Expected branch Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Mt")
        else:
            self.Mt_branch.SetAddress(<void*>&self.Mt_value)

        #print "making NUP"
        self.NUP_branch = the_tree.GetBranch("NUP")
        #if not self.NUP_branch and "NUP" not in self.complained:
        if not self.NUP_branch and "NUP":
            warnings.warn( "EMTree: Expected branch NUP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("NUP")
        else:
            self.NUP_branch.SetAddress(<void*>&self.NUP_value)

        #print "making Phi"
        self.Phi_branch = the_tree.GetBranch("Phi")
        #if not self.Phi_branch and "Phi" not in self.complained:
        if not self.Phi_branch and "Phi":
            warnings.warn( "EMTree: Expected branch Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Phi")
        else:
            self.Phi_branch.SetAddress(<void*>&self.Phi_value)

        #print "making Pt"
        self.Pt_branch = the_tree.GetBranch("Pt")
        #if not self.Pt_branch and "Pt" not in self.complained:
        if not self.Pt_branch and "Pt":
            warnings.warn( "EMTree: Expected branch Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("Pt")
        else:
            self.Pt_branch.SetAddress(<void*>&self.Pt_value)

        #print "making bjetCISVVeto20Loose"
        self.bjetCISVVeto20Loose_branch = the_tree.GetBranch("bjetCISVVeto20Loose")
        #if not self.bjetCISVVeto20Loose_branch and "bjetCISVVeto20Loose" not in self.complained:
        if not self.bjetCISVVeto20Loose_branch and "bjetCISVVeto20Loose":
            warnings.warn( "EMTree: Expected branch bjetCISVVeto20Loose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Loose")
        else:
            self.bjetCISVVeto20Loose_branch.SetAddress(<void*>&self.bjetCISVVeto20Loose_value)

        #print "making bjetCISVVeto20Medium"
        self.bjetCISVVeto20Medium_branch = the_tree.GetBranch("bjetCISVVeto20Medium")
        #if not self.bjetCISVVeto20Medium_branch and "bjetCISVVeto20Medium" not in self.complained:
        if not self.bjetCISVVeto20Medium_branch and "bjetCISVVeto20Medium":
            warnings.warn( "EMTree: Expected branch bjetCISVVeto20Medium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Medium")
        else:
            self.bjetCISVVeto20Medium_branch.SetAddress(<void*>&self.bjetCISVVeto20Medium_value)

        #print "making bjetCISVVeto20Tight"
        self.bjetCISVVeto20Tight_branch = the_tree.GetBranch("bjetCISVVeto20Tight")
        #if not self.bjetCISVVeto20Tight_branch and "bjetCISVVeto20Tight" not in self.complained:
        if not self.bjetCISVVeto20Tight_branch and "bjetCISVVeto20Tight":
            warnings.warn( "EMTree: Expected branch bjetCISVVeto20Tight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto20Tight")
        else:
            self.bjetCISVVeto20Tight_branch.SetAddress(<void*>&self.bjetCISVVeto20Tight_value)

        #print "making bjetCISVVeto30Loose"
        self.bjetCISVVeto30Loose_branch = the_tree.GetBranch("bjetCISVVeto30Loose")
        #if not self.bjetCISVVeto30Loose_branch and "bjetCISVVeto30Loose" not in self.complained:
        if not self.bjetCISVVeto30Loose_branch and "bjetCISVVeto30Loose":
            warnings.warn( "EMTree: Expected branch bjetCISVVeto30Loose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Loose")
        else:
            self.bjetCISVVeto30Loose_branch.SetAddress(<void*>&self.bjetCISVVeto30Loose_value)

        #print "making bjetCISVVeto30Medium"
        self.bjetCISVVeto30Medium_branch = the_tree.GetBranch("bjetCISVVeto30Medium")
        #if not self.bjetCISVVeto30Medium_branch and "bjetCISVVeto30Medium" not in self.complained:
        if not self.bjetCISVVeto30Medium_branch and "bjetCISVVeto30Medium":
            warnings.warn( "EMTree: Expected branch bjetCISVVeto30Medium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Medium")
        else:
            self.bjetCISVVeto30Medium_branch.SetAddress(<void*>&self.bjetCISVVeto30Medium_value)

        #print "making bjetCISVVeto30Tight"
        self.bjetCISVVeto30Tight_branch = the_tree.GetBranch("bjetCISVVeto30Tight")
        #if not self.bjetCISVVeto30Tight_branch and "bjetCISVVeto30Tight" not in self.complained:
        if not self.bjetCISVVeto30Tight_branch and "bjetCISVVeto30Tight":
            warnings.warn( "EMTree: Expected branch bjetCISVVeto30Tight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("bjetCISVVeto30Tight")
        else:
            self.bjetCISVVeto30Tight_branch.SetAddress(<void*>&self.bjetCISVVeto30Tight_value)

        #print "making charge"
        self.charge_branch = the_tree.GetBranch("charge")
        #if not self.charge_branch and "charge" not in self.complained:
        if not self.charge_branch and "charge":
            warnings.warn( "EMTree: Expected branch charge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("charge")
        else:
            self.charge_branch.SetAddress(<void*>&self.charge_value)

        #print "making doubleEGroup"
        self.doubleEGroup_branch = the_tree.GetBranch("doubleEGroup")
        #if not self.doubleEGroup_branch and "doubleEGroup" not in self.complained:
        if not self.doubleEGroup_branch and "doubleEGroup":
            warnings.warn( "EMTree: Expected branch doubleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEGroup")
        else:
            self.doubleEGroup_branch.SetAddress(<void*>&self.doubleEGroup_value)

        #print "making doubleEPass"
        self.doubleEPass_branch = the_tree.GetBranch("doubleEPass")
        #if not self.doubleEPass_branch and "doubleEPass" not in self.complained:
        if not self.doubleEPass_branch and "doubleEPass":
            warnings.warn( "EMTree: Expected branch doubleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEPass")
        else:
            self.doubleEPass_branch.SetAddress(<void*>&self.doubleEPass_value)

        #print "making doubleEPrescale"
        self.doubleEPrescale_branch = the_tree.GetBranch("doubleEPrescale")
        #if not self.doubleEPrescale_branch and "doubleEPrescale" not in self.complained:
        if not self.doubleEPrescale_branch and "doubleEPrescale":
            warnings.warn( "EMTree: Expected branch doubleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleEPrescale")
        else:
            self.doubleEPrescale_branch.SetAddress(<void*>&self.doubleEPrescale_value)

        #print "making doubleESingleMuGroup"
        self.doubleESingleMuGroup_branch = the_tree.GetBranch("doubleESingleMuGroup")
        #if not self.doubleESingleMuGroup_branch and "doubleESingleMuGroup" not in self.complained:
        if not self.doubleESingleMuGroup_branch and "doubleESingleMuGroup":
            warnings.warn( "EMTree: Expected branch doubleESingleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuGroup")
        else:
            self.doubleESingleMuGroup_branch.SetAddress(<void*>&self.doubleESingleMuGroup_value)

        #print "making doubleESingleMuPass"
        self.doubleESingleMuPass_branch = the_tree.GetBranch("doubleESingleMuPass")
        #if not self.doubleESingleMuPass_branch and "doubleESingleMuPass" not in self.complained:
        if not self.doubleESingleMuPass_branch and "doubleESingleMuPass":
            warnings.warn( "EMTree: Expected branch doubleESingleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuPass")
        else:
            self.doubleESingleMuPass_branch.SetAddress(<void*>&self.doubleESingleMuPass_value)

        #print "making doubleESingleMuPrescale"
        self.doubleESingleMuPrescale_branch = the_tree.GetBranch("doubleESingleMuPrescale")
        #if not self.doubleESingleMuPrescale_branch and "doubleESingleMuPrescale" not in self.complained:
        if not self.doubleESingleMuPrescale_branch and "doubleESingleMuPrescale":
            warnings.warn( "EMTree: Expected branch doubleESingleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleESingleMuPrescale")
        else:
            self.doubleESingleMuPrescale_branch.SetAddress(<void*>&self.doubleESingleMuPrescale_value)

        #print "making doubleMuGroup"
        self.doubleMuGroup_branch = the_tree.GetBranch("doubleMuGroup")
        #if not self.doubleMuGroup_branch and "doubleMuGroup" not in self.complained:
        if not self.doubleMuGroup_branch and "doubleMuGroup":
            warnings.warn( "EMTree: Expected branch doubleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuGroup")
        else:
            self.doubleMuGroup_branch.SetAddress(<void*>&self.doubleMuGroup_value)

        #print "making doubleMuPass"
        self.doubleMuPass_branch = the_tree.GetBranch("doubleMuPass")
        #if not self.doubleMuPass_branch and "doubleMuPass" not in self.complained:
        if not self.doubleMuPass_branch and "doubleMuPass":
            warnings.warn( "EMTree: Expected branch doubleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuPass")
        else:
            self.doubleMuPass_branch.SetAddress(<void*>&self.doubleMuPass_value)

        #print "making doubleMuPrescale"
        self.doubleMuPrescale_branch = the_tree.GetBranch("doubleMuPrescale")
        #if not self.doubleMuPrescale_branch and "doubleMuPrescale" not in self.complained:
        if not self.doubleMuPrescale_branch and "doubleMuPrescale":
            warnings.warn( "EMTree: Expected branch doubleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuPrescale")
        else:
            self.doubleMuPrescale_branch.SetAddress(<void*>&self.doubleMuPrescale_value)

        #print "making doubleMuSingleEGroup"
        self.doubleMuSingleEGroup_branch = the_tree.GetBranch("doubleMuSingleEGroup")
        #if not self.doubleMuSingleEGroup_branch and "doubleMuSingleEGroup" not in self.complained:
        if not self.doubleMuSingleEGroup_branch and "doubleMuSingleEGroup":
            warnings.warn( "EMTree: Expected branch doubleMuSingleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEGroup")
        else:
            self.doubleMuSingleEGroup_branch.SetAddress(<void*>&self.doubleMuSingleEGroup_value)

        #print "making doubleMuSingleEPass"
        self.doubleMuSingleEPass_branch = the_tree.GetBranch("doubleMuSingleEPass")
        #if not self.doubleMuSingleEPass_branch and "doubleMuSingleEPass" not in self.complained:
        if not self.doubleMuSingleEPass_branch and "doubleMuSingleEPass":
            warnings.warn( "EMTree: Expected branch doubleMuSingleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEPass")
        else:
            self.doubleMuSingleEPass_branch.SetAddress(<void*>&self.doubleMuSingleEPass_value)

        #print "making doubleMuSingleEPrescale"
        self.doubleMuSingleEPrescale_branch = the_tree.GetBranch("doubleMuSingleEPrescale")
        #if not self.doubleMuSingleEPrescale_branch and "doubleMuSingleEPrescale" not in self.complained:
        if not self.doubleMuSingleEPrescale_branch and "doubleMuSingleEPrescale":
            warnings.warn( "EMTree: Expected branch doubleMuSingleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleMuSingleEPrescale")
        else:
            self.doubleMuSingleEPrescale_branch.SetAddress(<void*>&self.doubleMuSingleEPrescale_value)

        #print "making doubleTau35Group"
        self.doubleTau35Group_branch = the_tree.GetBranch("doubleTau35Group")
        #if not self.doubleTau35Group_branch and "doubleTau35Group" not in self.complained:
        if not self.doubleTau35Group_branch and "doubleTau35Group":
            warnings.warn( "EMTree: Expected branch doubleTau35Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Group")
        else:
            self.doubleTau35Group_branch.SetAddress(<void*>&self.doubleTau35Group_value)

        #print "making doubleTau35Pass"
        self.doubleTau35Pass_branch = the_tree.GetBranch("doubleTau35Pass")
        #if not self.doubleTau35Pass_branch and "doubleTau35Pass" not in self.complained:
        if not self.doubleTau35Pass_branch and "doubleTau35Pass":
            warnings.warn( "EMTree: Expected branch doubleTau35Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Pass")
        else:
            self.doubleTau35Pass_branch.SetAddress(<void*>&self.doubleTau35Pass_value)

        #print "making doubleTau35Prescale"
        self.doubleTau35Prescale_branch = the_tree.GetBranch("doubleTau35Prescale")
        #if not self.doubleTau35Prescale_branch and "doubleTau35Prescale" not in self.complained:
        if not self.doubleTau35Prescale_branch and "doubleTau35Prescale":
            warnings.warn( "EMTree: Expected branch doubleTau35Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau35Prescale")
        else:
            self.doubleTau35Prescale_branch.SetAddress(<void*>&self.doubleTau35Prescale_value)

        #print "making doubleTau40Group"
        self.doubleTau40Group_branch = the_tree.GetBranch("doubleTau40Group")
        #if not self.doubleTau40Group_branch and "doubleTau40Group" not in self.complained:
        if not self.doubleTau40Group_branch and "doubleTau40Group":
            warnings.warn( "EMTree: Expected branch doubleTau40Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Group")
        else:
            self.doubleTau40Group_branch.SetAddress(<void*>&self.doubleTau40Group_value)

        #print "making doubleTau40Pass"
        self.doubleTau40Pass_branch = the_tree.GetBranch("doubleTau40Pass")
        #if not self.doubleTau40Pass_branch and "doubleTau40Pass" not in self.complained:
        if not self.doubleTau40Pass_branch and "doubleTau40Pass":
            warnings.warn( "EMTree: Expected branch doubleTau40Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Pass")
        else:
            self.doubleTau40Pass_branch.SetAddress(<void*>&self.doubleTau40Pass_value)

        #print "making doubleTau40Prescale"
        self.doubleTau40Prescale_branch = the_tree.GetBranch("doubleTau40Prescale")
        #if not self.doubleTau40Prescale_branch and "doubleTau40Prescale" not in self.complained:
        if not self.doubleTau40Prescale_branch and "doubleTau40Prescale":
            warnings.warn( "EMTree: Expected branch doubleTau40Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("doubleTau40Prescale")
        else:
            self.doubleTau40Prescale_branch.SetAddress(<void*>&self.doubleTau40Prescale_value)

        #print "making eAbsEta"
        self.eAbsEta_branch = the_tree.GetBranch("eAbsEta")
        #if not self.eAbsEta_branch and "eAbsEta" not in self.complained:
        if not self.eAbsEta_branch and "eAbsEta":
            warnings.warn( "EMTree: Expected branch eAbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eAbsEta")
        else:
            self.eAbsEta_branch.SetAddress(<void*>&self.eAbsEta_value)

        #print "making eCBIDLoose"
        self.eCBIDLoose_branch = the_tree.GetBranch("eCBIDLoose")
        #if not self.eCBIDLoose_branch and "eCBIDLoose" not in self.complained:
        if not self.eCBIDLoose_branch and "eCBIDLoose":
            warnings.warn( "EMTree: Expected branch eCBIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDLoose")
        else:
            self.eCBIDLoose_branch.SetAddress(<void*>&self.eCBIDLoose_value)

        #print "making eCBIDLooseNoIso"
        self.eCBIDLooseNoIso_branch = the_tree.GetBranch("eCBIDLooseNoIso")
        #if not self.eCBIDLooseNoIso_branch and "eCBIDLooseNoIso" not in self.complained:
        if not self.eCBIDLooseNoIso_branch and "eCBIDLooseNoIso":
            warnings.warn( "EMTree: Expected branch eCBIDLooseNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDLooseNoIso")
        else:
            self.eCBIDLooseNoIso_branch.SetAddress(<void*>&self.eCBIDLooseNoIso_value)

        #print "making eCBIDMedium"
        self.eCBIDMedium_branch = the_tree.GetBranch("eCBIDMedium")
        #if not self.eCBIDMedium_branch and "eCBIDMedium" not in self.complained:
        if not self.eCBIDMedium_branch and "eCBIDMedium":
            warnings.warn( "EMTree: Expected branch eCBIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDMedium")
        else:
            self.eCBIDMedium_branch.SetAddress(<void*>&self.eCBIDMedium_value)

        #print "making eCBIDMediumNoIso"
        self.eCBIDMediumNoIso_branch = the_tree.GetBranch("eCBIDMediumNoIso")
        #if not self.eCBIDMediumNoIso_branch and "eCBIDMediumNoIso" not in self.complained:
        if not self.eCBIDMediumNoIso_branch and "eCBIDMediumNoIso":
            warnings.warn( "EMTree: Expected branch eCBIDMediumNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDMediumNoIso")
        else:
            self.eCBIDMediumNoIso_branch.SetAddress(<void*>&self.eCBIDMediumNoIso_value)

        #print "making eCBIDTight"
        self.eCBIDTight_branch = the_tree.GetBranch("eCBIDTight")
        #if not self.eCBIDTight_branch and "eCBIDTight" not in self.complained:
        if not self.eCBIDTight_branch and "eCBIDTight":
            warnings.warn( "EMTree: Expected branch eCBIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDTight")
        else:
            self.eCBIDTight_branch.SetAddress(<void*>&self.eCBIDTight_value)

        #print "making eCBIDTightNoIso"
        self.eCBIDTightNoIso_branch = the_tree.GetBranch("eCBIDTightNoIso")
        #if not self.eCBIDTightNoIso_branch and "eCBIDTightNoIso" not in self.complained:
        if not self.eCBIDTightNoIso_branch and "eCBIDTightNoIso":
            warnings.warn( "EMTree: Expected branch eCBIDTightNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDTightNoIso")
        else:
            self.eCBIDTightNoIso_branch.SetAddress(<void*>&self.eCBIDTightNoIso_value)

        #print "making eCBIDVeto"
        self.eCBIDVeto_branch = the_tree.GetBranch("eCBIDVeto")
        #if not self.eCBIDVeto_branch and "eCBIDVeto" not in self.complained:
        if not self.eCBIDVeto_branch and "eCBIDVeto":
            warnings.warn( "EMTree: Expected branch eCBIDVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDVeto")
        else:
            self.eCBIDVeto_branch.SetAddress(<void*>&self.eCBIDVeto_value)

        #print "making eCBIDVetoNoIso"
        self.eCBIDVetoNoIso_branch = the_tree.GetBranch("eCBIDVetoNoIso")
        #if not self.eCBIDVetoNoIso_branch and "eCBIDVetoNoIso" not in self.complained:
        if not self.eCBIDVetoNoIso_branch and "eCBIDVetoNoIso":
            warnings.warn( "EMTree: Expected branch eCBIDVetoNoIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCBIDVetoNoIso")
        else:
            self.eCBIDVetoNoIso_branch.SetAddress(<void*>&self.eCBIDVetoNoIso_value)

        #print "making eCharge"
        self.eCharge_branch = the_tree.GetBranch("eCharge")
        #if not self.eCharge_branch and "eCharge" not in self.complained:
        if not self.eCharge_branch and "eCharge":
            warnings.warn( "EMTree: Expected branch eCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eCharge")
        else:
            self.eCharge_branch.SetAddress(<void*>&self.eCharge_value)

        #print "making eChargeIdLoose"
        self.eChargeIdLoose_branch = the_tree.GetBranch("eChargeIdLoose")
        #if not self.eChargeIdLoose_branch and "eChargeIdLoose" not in self.complained:
        if not self.eChargeIdLoose_branch and "eChargeIdLoose":
            warnings.warn( "EMTree: Expected branch eChargeIdLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eChargeIdLoose")
        else:
            self.eChargeIdLoose_branch.SetAddress(<void*>&self.eChargeIdLoose_value)

        #print "making eChargeIdMed"
        self.eChargeIdMed_branch = the_tree.GetBranch("eChargeIdMed")
        #if not self.eChargeIdMed_branch and "eChargeIdMed" not in self.complained:
        if not self.eChargeIdMed_branch and "eChargeIdMed":
            warnings.warn( "EMTree: Expected branch eChargeIdMed does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eChargeIdMed")
        else:
            self.eChargeIdMed_branch.SetAddress(<void*>&self.eChargeIdMed_value)

        #print "making eChargeIdTight"
        self.eChargeIdTight_branch = the_tree.GetBranch("eChargeIdTight")
        #if not self.eChargeIdTight_branch and "eChargeIdTight" not in self.complained:
        if not self.eChargeIdTight_branch and "eChargeIdTight":
            warnings.warn( "EMTree: Expected branch eChargeIdTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eChargeIdTight")
        else:
            self.eChargeIdTight_branch.SetAddress(<void*>&self.eChargeIdTight_value)

        #print "making eComesFromHiggs"
        self.eComesFromHiggs_branch = the_tree.GetBranch("eComesFromHiggs")
        #if not self.eComesFromHiggs_branch and "eComesFromHiggs" not in self.complained:
        if not self.eComesFromHiggs_branch and "eComesFromHiggs":
            warnings.warn( "EMTree: Expected branch eComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eComesFromHiggs")
        else:
            self.eComesFromHiggs_branch.SetAddress(<void*>&self.eComesFromHiggs_value)

        #print "making eDPhiToPfMet_ElectronEnDown"
        self.eDPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("eDPhiToPfMet_ElectronEnDown")
        #if not self.eDPhiToPfMet_ElectronEnDown_branch and "eDPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.eDPhiToPfMet_ElectronEnDown_branch and "eDPhiToPfMet_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_ElectronEnDown")
        else:
            self.eDPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.eDPhiToPfMet_ElectronEnDown_value)

        #print "making eDPhiToPfMet_ElectronEnUp"
        self.eDPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("eDPhiToPfMet_ElectronEnUp")
        #if not self.eDPhiToPfMet_ElectronEnUp_branch and "eDPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.eDPhiToPfMet_ElectronEnUp_branch and "eDPhiToPfMet_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_ElectronEnUp")
        else:
            self.eDPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.eDPhiToPfMet_ElectronEnUp_value)

        #print "making eDPhiToPfMet_JetEnDown"
        self.eDPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("eDPhiToPfMet_JetEnDown")
        #if not self.eDPhiToPfMet_JetEnDown_branch and "eDPhiToPfMet_JetEnDown" not in self.complained:
        if not self.eDPhiToPfMet_JetEnDown_branch and "eDPhiToPfMet_JetEnDown":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_JetEnDown")
        else:
            self.eDPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.eDPhiToPfMet_JetEnDown_value)

        #print "making eDPhiToPfMet_JetEnUp"
        self.eDPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("eDPhiToPfMet_JetEnUp")
        #if not self.eDPhiToPfMet_JetEnUp_branch and "eDPhiToPfMet_JetEnUp" not in self.complained:
        if not self.eDPhiToPfMet_JetEnUp_branch and "eDPhiToPfMet_JetEnUp":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_JetEnUp")
        else:
            self.eDPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.eDPhiToPfMet_JetEnUp_value)

        #print "making eDPhiToPfMet_JetResDown"
        self.eDPhiToPfMet_JetResDown_branch = the_tree.GetBranch("eDPhiToPfMet_JetResDown")
        #if not self.eDPhiToPfMet_JetResDown_branch and "eDPhiToPfMet_JetResDown" not in self.complained:
        if not self.eDPhiToPfMet_JetResDown_branch and "eDPhiToPfMet_JetResDown":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_JetResDown")
        else:
            self.eDPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.eDPhiToPfMet_JetResDown_value)

        #print "making eDPhiToPfMet_JetResUp"
        self.eDPhiToPfMet_JetResUp_branch = the_tree.GetBranch("eDPhiToPfMet_JetResUp")
        #if not self.eDPhiToPfMet_JetResUp_branch and "eDPhiToPfMet_JetResUp" not in self.complained:
        if not self.eDPhiToPfMet_JetResUp_branch and "eDPhiToPfMet_JetResUp":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_JetResUp")
        else:
            self.eDPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.eDPhiToPfMet_JetResUp_value)

        #print "making eDPhiToPfMet_MuonEnDown"
        self.eDPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("eDPhiToPfMet_MuonEnDown")
        #if not self.eDPhiToPfMet_MuonEnDown_branch and "eDPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.eDPhiToPfMet_MuonEnDown_branch and "eDPhiToPfMet_MuonEnDown":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_MuonEnDown")
        else:
            self.eDPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.eDPhiToPfMet_MuonEnDown_value)

        #print "making eDPhiToPfMet_MuonEnUp"
        self.eDPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("eDPhiToPfMet_MuonEnUp")
        #if not self.eDPhiToPfMet_MuonEnUp_branch and "eDPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.eDPhiToPfMet_MuonEnUp_branch and "eDPhiToPfMet_MuonEnUp":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_MuonEnUp")
        else:
            self.eDPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.eDPhiToPfMet_MuonEnUp_value)

        #print "making eDPhiToPfMet_PhotonEnDown"
        self.eDPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("eDPhiToPfMet_PhotonEnDown")
        #if not self.eDPhiToPfMet_PhotonEnDown_branch and "eDPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.eDPhiToPfMet_PhotonEnDown_branch and "eDPhiToPfMet_PhotonEnDown":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_PhotonEnDown")
        else:
            self.eDPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.eDPhiToPfMet_PhotonEnDown_value)

        #print "making eDPhiToPfMet_PhotonEnUp"
        self.eDPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("eDPhiToPfMet_PhotonEnUp")
        #if not self.eDPhiToPfMet_PhotonEnUp_branch and "eDPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.eDPhiToPfMet_PhotonEnUp_branch and "eDPhiToPfMet_PhotonEnUp":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_PhotonEnUp")
        else:
            self.eDPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.eDPhiToPfMet_PhotonEnUp_value)

        #print "making eDPhiToPfMet_TauEnDown"
        self.eDPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("eDPhiToPfMet_TauEnDown")
        #if not self.eDPhiToPfMet_TauEnDown_branch and "eDPhiToPfMet_TauEnDown" not in self.complained:
        if not self.eDPhiToPfMet_TauEnDown_branch and "eDPhiToPfMet_TauEnDown":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_TauEnDown")
        else:
            self.eDPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.eDPhiToPfMet_TauEnDown_value)

        #print "making eDPhiToPfMet_TauEnUp"
        self.eDPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("eDPhiToPfMet_TauEnUp")
        #if not self.eDPhiToPfMet_TauEnUp_branch and "eDPhiToPfMet_TauEnUp" not in self.complained:
        if not self.eDPhiToPfMet_TauEnUp_branch and "eDPhiToPfMet_TauEnUp":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_TauEnUp")
        else:
            self.eDPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.eDPhiToPfMet_TauEnUp_value)

        #print "making eDPhiToPfMet_UnclusteredEnDown"
        self.eDPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("eDPhiToPfMet_UnclusteredEnDown")
        #if not self.eDPhiToPfMet_UnclusteredEnDown_branch and "eDPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.eDPhiToPfMet_UnclusteredEnDown_branch and "eDPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_UnclusteredEnDown")
        else:
            self.eDPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.eDPhiToPfMet_UnclusteredEnDown_value)

        #print "making eDPhiToPfMet_UnclusteredEnUp"
        self.eDPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("eDPhiToPfMet_UnclusteredEnUp")
        #if not self.eDPhiToPfMet_UnclusteredEnUp_branch and "eDPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.eDPhiToPfMet_UnclusteredEnUp_branch and "eDPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_UnclusteredEnUp")
        else:
            self.eDPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.eDPhiToPfMet_UnclusteredEnUp_value)

        #print "making eDPhiToPfMet_type1"
        self.eDPhiToPfMet_type1_branch = the_tree.GetBranch("eDPhiToPfMet_type1")
        #if not self.eDPhiToPfMet_type1_branch and "eDPhiToPfMet_type1" not in self.complained:
        if not self.eDPhiToPfMet_type1_branch and "eDPhiToPfMet_type1":
            warnings.warn( "EMTree: Expected branch eDPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eDPhiToPfMet_type1")
        else:
            self.eDPhiToPfMet_type1_branch.SetAddress(<void*>&self.eDPhiToPfMet_type1_value)

        #print "making eE1x5"
        self.eE1x5_branch = the_tree.GetBranch("eE1x5")
        #if not self.eE1x5_branch and "eE1x5" not in self.complained:
        if not self.eE1x5_branch and "eE1x5":
            warnings.warn( "EMTree: Expected branch eE1x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eE1x5")
        else:
            self.eE1x5_branch.SetAddress(<void*>&self.eE1x5_value)

        #print "making eE2x5Max"
        self.eE2x5Max_branch = the_tree.GetBranch("eE2x5Max")
        #if not self.eE2x5Max_branch and "eE2x5Max" not in self.complained:
        if not self.eE2x5Max_branch and "eE2x5Max":
            warnings.warn( "EMTree: Expected branch eE2x5Max does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eE2x5Max")
        else:
            self.eE2x5Max_branch.SetAddress(<void*>&self.eE2x5Max_value)

        #print "making eE5x5"
        self.eE5x5_branch = the_tree.GetBranch("eE5x5")
        #if not self.eE5x5_branch and "eE5x5" not in self.complained:
        if not self.eE5x5_branch and "eE5x5":
            warnings.warn( "EMTree: Expected branch eE5x5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eE5x5")
        else:
            self.eE5x5_branch.SetAddress(<void*>&self.eE5x5_value)

        #print "making eEcalIsoDR03"
        self.eEcalIsoDR03_branch = the_tree.GetBranch("eEcalIsoDR03")
        #if not self.eEcalIsoDR03_branch and "eEcalIsoDR03" not in self.complained:
        if not self.eEcalIsoDR03_branch and "eEcalIsoDR03":
            warnings.warn( "EMTree: Expected branch eEcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eEcalIsoDR03")
        else:
            self.eEcalIsoDR03_branch.SetAddress(<void*>&self.eEcalIsoDR03_value)

        #print "making eEffectiveArea2012Data"
        self.eEffectiveArea2012Data_branch = the_tree.GetBranch("eEffectiveArea2012Data")
        #if not self.eEffectiveArea2012Data_branch and "eEffectiveArea2012Data" not in self.complained:
        if not self.eEffectiveArea2012Data_branch and "eEffectiveArea2012Data":
            warnings.warn( "EMTree: Expected branch eEffectiveArea2012Data does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eEffectiveArea2012Data")
        else:
            self.eEffectiveArea2012Data_branch.SetAddress(<void*>&self.eEffectiveArea2012Data_value)

        #print "making eEffectiveAreaSpring15"
        self.eEffectiveAreaSpring15_branch = the_tree.GetBranch("eEffectiveAreaSpring15")
        #if not self.eEffectiveAreaSpring15_branch and "eEffectiveAreaSpring15" not in self.complained:
        if not self.eEffectiveAreaSpring15_branch and "eEffectiveAreaSpring15":
            warnings.warn( "EMTree: Expected branch eEffectiveAreaSpring15 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eEffectiveAreaSpring15")
        else:
            self.eEffectiveAreaSpring15_branch.SetAddress(<void*>&self.eEffectiveAreaSpring15_value)

        #print "making eEnergyError"
        self.eEnergyError_branch = the_tree.GetBranch("eEnergyError")
        #if not self.eEnergyError_branch and "eEnergyError" not in self.complained:
        if not self.eEnergyError_branch and "eEnergyError":
            warnings.warn( "EMTree: Expected branch eEnergyError does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eEnergyError")
        else:
            self.eEnergyError_branch.SetAddress(<void*>&self.eEnergyError_value)

        #print "making eEta"
        self.eEta_branch = the_tree.GetBranch("eEta")
        #if not self.eEta_branch and "eEta" not in self.complained:
        if not self.eEta_branch and "eEta":
            warnings.warn( "EMTree: Expected branch eEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eEta")
        else:
            self.eEta_branch.SetAddress(<void*>&self.eEta_value)

        #print "making eEta_ElectronEnDown"
        self.eEta_ElectronEnDown_branch = the_tree.GetBranch("eEta_ElectronEnDown")
        #if not self.eEta_ElectronEnDown_branch and "eEta_ElectronEnDown" not in self.complained:
        if not self.eEta_ElectronEnDown_branch and "eEta_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch eEta_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eEta_ElectronEnDown")
        else:
            self.eEta_ElectronEnDown_branch.SetAddress(<void*>&self.eEta_ElectronEnDown_value)

        #print "making eEta_ElectronEnUp"
        self.eEta_ElectronEnUp_branch = the_tree.GetBranch("eEta_ElectronEnUp")
        #if not self.eEta_ElectronEnUp_branch and "eEta_ElectronEnUp" not in self.complained:
        if not self.eEta_ElectronEnUp_branch and "eEta_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch eEta_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eEta_ElectronEnUp")
        else:
            self.eEta_ElectronEnUp_branch.SetAddress(<void*>&self.eEta_ElectronEnUp_value)

        #print "making eGenCharge"
        self.eGenCharge_branch = the_tree.GetBranch("eGenCharge")
        #if not self.eGenCharge_branch and "eGenCharge" not in self.complained:
        if not self.eGenCharge_branch and "eGenCharge":
            warnings.warn( "EMTree: Expected branch eGenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenCharge")
        else:
            self.eGenCharge_branch.SetAddress(<void*>&self.eGenCharge_value)

        #print "making eGenEnergy"
        self.eGenEnergy_branch = the_tree.GetBranch("eGenEnergy")
        #if not self.eGenEnergy_branch and "eGenEnergy" not in self.complained:
        if not self.eGenEnergy_branch and "eGenEnergy":
            warnings.warn( "EMTree: Expected branch eGenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenEnergy")
        else:
            self.eGenEnergy_branch.SetAddress(<void*>&self.eGenEnergy_value)

        #print "making eGenEta"
        self.eGenEta_branch = the_tree.GetBranch("eGenEta")
        #if not self.eGenEta_branch and "eGenEta" not in self.complained:
        if not self.eGenEta_branch and "eGenEta":
            warnings.warn( "EMTree: Expected branch eGenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenEta")
        else:
            self.eGenEta_branch.SetAddress(<void*>&self.eGenEta_value)

        #print "making eGenMotherPdgId"
        self.eGenMotherPdgId_branch = the_tree.GetBranch("eGenMotherPdgId")
        #if not self.eGenMotherPdgId_branch and "eGenMotherPdgId" not in self.complained:
        if not self.eGenMotherPdgId_branch and "eGenMotherPdgId":
            warnings.warn( "EMTree: Expected branch eGenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenMotherPdgId")
        else:
            self.eGenMotherPdgId_branch.SetAddress(<void*>&self.eGenMotherPdgId_value)

        #print "making eGenParticle"
        self.eGenParticle_branch = the_tree.GetBranch("eGenParticle")
        #if not self.eGenParticle_branch and "eGenParticle" not in self.complained:
        if not self.eGenParticle_branch and "eGenParticle":
            warnings.warn( "EMTree: Expected branch eGenParticle does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenParticle")
        else:
            self.eGenParticle_branch.SetAddress(<void*>&self.eGenParticle_value)

        #print "making eGenPdgId"
        self.eGenPdgId_branch = the_tree.GetBranch("eGenPdgId")
        #if not self.eGenPdgId_branch and "eGenPdgId" not in self.complained:
        if not self.eGenPdgId_branch and "eGenPdgId":
            warnings.warn( "EMTree: Expected branch eGenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenPdgId")
        else:
            self.eGenPdgId_branch.SetAddress(<void*>&self.eGenPdgId_value)

        #print "making eGenPhi"
        self.eGenPhi_branch = the_tree.GetBranch("eGenPhi")
        #if not self.eGenPhi_branch and "eGenPhi" not in self.complained:
        if not self.eGenPhi_branch and "eGenPhi":
            warnings.warn( "EMTree: Expected branch eGenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenPhi")
        else:
            self.eGenPhi_branch.SetAddress(<void*>&self.eGenPhi_value)

        #print "making eGenPrompt"
        self.eGenPrompt_branch = the_tree.GetBranch("eGenPrompt")
        #if not self.eGenPrompt_branch and "eGenPrompt" not in self.complained:
        if not self.eGenPrompt_branch and "eGenPrompt":
            warnings.warn( "EMTree: Expected branch eGenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenPrompt")
        else:
            self.eGenPrompt_branch.SetAddress(<void*>&self.eGenPrompt_value)

        #print "making eGenPromptTauDecay"
        self.eGenPromptTauDecay_branch = the_tree.GetBranch("eGenPromptTauDecay")
        #if not self.eGenPromptTauDecay_branch and "eGenPromptTauDecay" not in self.complained:
        if not self.eGenPromptTauDecay_branch and "eGenPromptTauDecay":
            warnings.warn( "EMTree: Expected branch eGenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenPromptTauDecay")
        else:
            self.eGenPromptTauDecay_branch.SetAddress(<void*>&self.eGenPromptTauDecay_value)

        #print "making eGenPt"
        self.eGenPt_branch = the_tree.GetBranch("eGenPt")
        #if not self.eGenPt_branch and "eGenPt" not in self.complained:
        if not self.eGenPt_branch and "eGenPt":
            warnings.warn( "EMTree: Expected branch eGenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenPt")
        else:
            self.eGenPt_branch.SetAddress(<void*>&self.eGenPt_value)

        #print "making eGenTauDecay"
        self.eGenTauDecay_branch = the_tree.GetBranch("eGenTauDecay")
        #if not self.eGenTauDecay_branch and "eGenTauDecay" not in self.complained:
        if not self.eGenTauDecay_branch and "eGenTauDecay":
            warnings.warn( "EMTree: Expected branch eGenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenTauDecay")
        else:
            self.eGenTauDecay_branch.SetAddress(<void*>&self.eGenTauDecay_value)

        #print "making eGenVZ"
        self.eGenVZ_branch = the_tree.GetBranch("eGenVZ")
        #if not self.eGenVZ_branch and "eGenVZ" not in self.complained:
        if not self.eGenVZ_branch and "eGenVZ":
            warnings.warn( "EMTree: Expected branch eGenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenVZ")
        else:
            self.eGenVZ_branch.SetAddress(<void*>&self.eGenVZ_value)

        #print "making eGenVtxPVMatch"
        self.eGenVtxPVMatch_branch = the_tree.GetBranch("eGenVtxPVMatch")
        #if not self.eGenVtxPVMatch_branch and "eGenVtxPVMatch" not in self.complained:
        if not self.eGenVtxPVMatch_branch and "eGenVtxPVMatch":
            warnings.warn( "EMTree: Expected branch eGenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eGenVtxPVMatch")
        else:
            self.eGenVtxPVMatch_branch.SetAddress(<void*>&self.eGenVtxPVMatch_value)

        #print "making eHadronicDepth1OverEm"
        self.eHadronicDepth1OverEm_branch = the_tree.GetBranch("eHadronicDepth1OverEm")
        #if not self.eHadronicDepth1OverEm_branch and "eHadronicDepth1OverEm" not in self.complained:
        if not self.eHadronicDepth1OverEm_branch and "eHadronicDepth1OverEm":
            warnings.warn( "EMTree: Expected branch eHadronicDepth1OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eHadronicDepth1OverEm")
        else:
            self.eHadronicDepth1OverEm_branch.SetAddress(<void*>&self.eHadronicDepth1OverEm_value)

        #print "making eHadronicDepth2OverEm"
        self.eHadronicDepth2OverEm_branch = the_tree.GetBranch("eHadronicDepth2OverEm")
        #if not self.eHadronicDepth2OverEm_branch and "eHadronicDepth2OverEm" not in self.complained:
        if not self.eHadronicDepth2OverEm_branch and "eHadronicDepth2OverEm":
            warnings.warn( "EMTree: Expected branch eHadronicDepth2OverEm does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eHadronicDepth2OverEm")
        else:
            self.eHadronicDepth2OverEm_branch.SetAddress(<void*>&self.eHadronicDepth2OverEm_value)

        #print "making eHadronicOverEM"
        self.eHadronicOverEM_branch = the_tree.GetBranch("eHadronicOverEM")
        #if not self.eHadronicOverEM_branch and "eHadronicOverEM" not in self.complained:
        if not self.eHadronicOverEM_branch and "eHadronicOverEM":
            warnings.warn( "EMTree: Expected branch eHadronicOverEM does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eHadronicOverEM")
        else:
            self.eHadronicOverEM_branch.SetAddress(<void*>&self.eHadronicOverEM_value)

        #print "making eHcalIsoDR03"
        self.eHcalIsoDR03_branch = the_tree.GetBranch("eHcalIsoDR03")
        #if not self.eHcalIsoDR03_branch and "eHcalIsoDR03" not in self.complained:
        if not self.eHcalIsoDR03_branch and "eHcalIsoDR03":
            warnings.warn( "EMTree: Expected branch eHcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eHcalIsoDR03")
        else:
            self.eHcalIsoDR03_branch.SetAddress(<void*>&self.eHcalIsoDR03_value)

        #print "making eIP3D"
        self.eIP3D_branch = the_tree.GetBranch("eIP3D")
        #if not self.eIP3D_branch and "eIP3D" not in self.complained:
        if not self.eIP3D_branch and "eIP3D":
            warnings.warn( "EMTree: Expected branch eIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eIP3D")
        else:
            self.eIP3D_branch.SetAddress(<void*>&self.eIP3D_value)

        #print "making eIP3DErr"
        self.eIP3DErr_branch = the_tree.GetBranch("eIP3DErr")
        #if not self.eIP3DErr_branch and "eIP3DErr" not in self.complained:
        if not self.eIP3DErr_branch and "eIP3DErr":
            warnings.warn( "EMTree: Expected branch eIP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eIP3DErr")
        else:
            self.eIP3DErr_branch.SetAddress(<void*>&self.eIP3DErr_value)

        #print "making eJetArea"
        self.eJetArea_branch = the_tree.GetBranch("eJetArea")
        #if not self.eJetArea_branch and "eJetArea" not in self.complained:
        if not self.eJetArea_branch and "eJetArea":
            warnings.warn( "EMTree: Expected branch eJetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetArea")
        else:
            self.eJetArea_branch.SetAddress(<void*>&self.eJetArea_value)

        #print "making eJetBtag"
        self.eJetBtag_branch = the_tree.GetBranch("eJetBtag")
        #if not self.eJetBtag_branch and "eJetBtag" not in self.complained:
        if not self.eJetBtag_branch and "eJetBtag":
            warnings.warn( "EMTree: Expected branch eJetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetBtag")
        else:
            self.eJetBtag_branch.SetAddress(<void*>&self.eJetBtag_value)

        #print "making eJetEtaEtaMoment"
        self.eJetEtaEtaMoment_branch = the_tree.GetBranch("eJetEtaEtaMoment")
        #if not self.eJetEtaEtaMoment_branch and "eJetEtaEtaMoment" not in self.complained:
        if not self.eJetEtaEtaMoment_branch and "eJetEtaEtaMoment":
            warnings.warn( "EMTree: Expected branch eJetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetEtaEtaMoment")
        else:
            self.eJetEtaEtaMoment_branch.SetAddress(<void*>&self.eJetEtaEtaMoment_value)

        #print "making eJetEtaPhiMoment"
        self.eJetEtaPhiMoment_branch = the_tree.GetBranch("eJetEtaPhiMoment")
        #if not self.eJetEtaPhiMoment_branch and "eJetEtaPhiMoment" not in self.complained:
        if not self.eJetEtaPhiMoment_branch and "eJetEtaPhiMoment":
            warnings.warn( "EMTree: Expected branch eJetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetEtaPhiMoment")
        else:
            self.eJetEtaPhiMoment_branch.SetAddress(<void*>&self.eJetEtaPhiMoment_value)

        #print "making eJetEtaPhiSpread"
        self.eJetEtaPhiSpread_branch = the_tree.GetBranch("eJetEtaPhiSpread")
        #if not self.eJetEtaPhiSpread_branch and "eJetEtaPhiSpread" not in self.complained:
        if not self.eJetEtaPhiSpread_branch and "eJetEtaPhiSpread":
            warnings.warn( "EMTree: Expected branch eJetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetEtaPhiSpread")
        else:
            self.eJetEtaPhiSpread_branch.SetAddress(<void*>&self.eJetEtaPhiSpread_value)

        #print "making eJetPFCISVBtag"
        self.eJetPFCISVBtag_branch = the_tree.GetBranch("eJetPFCISVBtag")
        #if not self.eJetPFCISVBtag_branch and "eJetPFCISVBtag" not in self.complained:
        if not self.eJetPFCISVBtag_branch and "eJetPFCISVBtag":
            warnings.warn( "EMTree: Expected branch eJetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetPFCISVBtag")
        else:
            self.eJetPFCISVBtag_branch.SetAddress(<void*>&self.eJetPFCISVBtag_value)

        #print "making eJetPartonFlavour"
        self.eJetPartonFlavour_branch = the_tree.GetBranch("eJetPartonFlavour")
        #if not self.eJetPartonFlavour_branch and "eJetPartonFlavour" not in self.complained:
        if not self.eJetPartonFlavour_branch and "eJetPartonFlavour":
            warnings.warn( "EMTree: Expected branch eJetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetPartonFlavour")
        else:
            self.eJetPartonFlavour_branch.SetAddress(<void*>&self.eJetPartonFlavour_value)

        #print "making eJetPhiPhiMoment"
        self.eJetPhiPhiMoment_branch = the_tree.GetBranch("eJetPhiPhiMoment")
        #if not self.eJetPhiPhiMoment_branch and "eJetPhiPhiMoment" not in self.complained:
        if not self.eJetPhiPhiMoment_branch and "eJetPhiPhiMoment":
            warnings.warn( "EMTree: Expected branch eJetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetPhiPhiMoment")
        else:
            self.eJetPhiPhiMoment_branch.SetAddress(<void*>&self.eJetPhiPhiMoment_value)

        #print "making eJetPt"
        self.eJetPt_branch = the_tree.GetBranch("eJetPt")
        #if not self.eJetPt_branch and "eJetPt" not in self.complained:
        if not self.eJetPt_branch and "eJetPt":
            warnings.warn( "EMTree: Expected branch eJetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eJetPt")
        else:
            self.eJetPt_branch.SetAddress(<void*>&self.eJetPt_value)

        #print "making eLowestMll"
        self.eLowestMll_branch = the_tree.GetBranch("eLowestMll")
        #if not self.eLowestMll_branch and "eLowestMll" not in self.complained:
        if not self.eLowestMll_branch and "eLowestMll":
            warnings.warn( "EMTree: Expected branch eLowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eLowestMll")
        else:
            self.eLowestMll_branch.SetAddress(<void*>&self.eLowestMll_value)

        #print "making eMVANonTrigCategory"
        self.eMVANonTrigCategory_branch = the_tree.GetBranch("eMVANonTrigCategory")
        #if not self.eMVANonTrigCategory_branch and "eMVANonTrigCategory" not in self.complained:
        if not self.eMVANonTrigCategory_branch and "eMVANonTrigCategory":
            warnings.warn( "EMTree: Expected branch eMVANonTrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVANonTrigCategory")
        else:
            self.eMVANonTrigCategory_branch.SetAddress(<void*>&self.eMVANonTrigCategory_value)

        #print "making eMVANonTrigID"
        self.eMVANonTrigID_branch = the_tree.GetBranch("eMVANonTrigID")
        #if not self.eMVANonTrigID_branch and "eMVANonTrigID" not in self.complained:
        if not self.eMVANonTrigID_branch and "eMVANonTrigID":
            warnings.warn( "EMTree: Expected branch eMVANonTrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVANonTrigID")
        else:
            self.eMVANonTrigID_branch.SetAddress(<void*>&self.eMVANonTrigID_value)

        #print "making eMVANonTrigWP80"
        self.eMVANonTrigWP80_branch = the_tree.GetBranch("eMVANonTrigWP80")
        #if not self.eMVANonTrigWP80_branch and "eMVANonTrigWP80" not in self.complained:
        if not self.eMVANonTrigWP80_branch and "eMVANonTrigWP80":
            warnings.warn( "EMTree: Expected branch eMVANonTrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVANonTrigWP80")
        else:
            self.eMVANonTrigWP80_branch.SetAddress(<void*>&self.eMVANonTrigWP80_value)

        #print "making eMVANonTrigWP90"
        self.eMVANonTrigWP90_branch = the_tree.GetBranch("eMVANonTrigWP90")
        #if not self.eMVANonTrigWP90_branch and "eMVANonTrigWP90" not in self.complained:
        if not self.eMVANonTrigWP90_branch and "eMVANonTrigWP90":
            warnings.warn( "EMTree: Expected branch eMVANonTrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVANonTrigWP90")
        else:
            self.eMVANonTrigWP90_branch.SetAddress(<void*>&self.eMVANonTrigWP90_value)

        #print "making eMVATrigCategory"
        self.eMVATrigCategory_branch = the_tree.GetBranch("eMVATrigCategory")
        #if not self.eMVATrigCategory_branch and "eMVATrigCategory" not in self.complained:
        if not self.eMVATrigCategory_branch and "eMVATrigCategory":
            warnings.warn( "EMTree: Expected branch eMVATrigCategory does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVATrigCategory")
        else:
            self.eMVATrigCategory_branch.SetAddress(<void*>&self.eMVATrigCategory_value)

        #print "making eMVATrigID"
        self.eMVATrigID_branch = the_tree.GetBranch("eMVATrigID")
        #if not self.eMVATrigID_branch and "eMVATrigID" not in self.complained:
        if not self.eMVATrigID_branch and "eMVATrigID":
            warnings.warn( "EMTree: Expected branch eMVATrigID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVATrigID")
        else:
            self.eMVATrigID_branch.SetAddress(<void*>&self.eMVATrigID_value)

        #print "making eMVATrigWP80"
        self.eMVATrigWP80_branch = the_tree.GetBranch("eMVATrigWP80")
        #if not self.eMVATrigWP80_branch and "eMVATrigWP80" not in self.complained:
        if not self.eMVATrigWP80_branch and "eMVATrigWP80":
            warnings.warn( "EMTree: Expected branch eMVATrigWP80 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVATrigWP80")
        else:
            self.eMVATrigWP80_branch.SetAddress(<void*>&self.eMVATrigWP80_value)

        #print "making eMVATrigWP90"
        self.eMVATrigWP90_branch = the_tree.GetBranch("eMVATrigWP90")
        #if not self.eMVATrigWP90_branch and "eMVATrigWP90" not in self.complained:
        if not self.eMVATrigWP90_branch and "eMVATrigWP90":
            warnings.warn( "EMTree: Expected branch eMVATrigWP90 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMVATrigWP90")
        else:
            self.eMVATrigWP90_branch.SetAddress(<void*>&self.eMVATrigWP90_value)

        #print "making eMass"
        self.eMass_branch = the_tree.GetBranch("eMass")
        #if not self.eMass_branch and "eMass" not in self.complained:
        if not self.eMass_branch and "eMass":
            warnings.warn( "EMTree: Expected branch eMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMass")
        else:
            self.eMass_branch.SetAddress(<void*>&self.eMass_value)

        #print "making eMatchesDoubleE"
        self.eMatchesDoubleE_branch = the_tree.GetBranch("eMatchesDoubleE")
        #if not self.eMatchesDoubleE_branch and "eMatchesDoubleE" not in self.complained:
        if not self.eMatchesDoubleE_branch and "eMatchesDoubleE":
            warnings.warn( "EMTree: Expected branch eMatchesDoubleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesDoubleE")
        else:
            self.eMatchesDoubleE_branch.SetAddress(<void*>&self.eMatchesDoubleE_value)

        #print "making eMatchesDoubleESingleMu"
        self.eMatchesDoubleESingleMu_branch = the_tree.GetBranch("eMatchesDoubleESingleMu")
        #if not self.eMatchesDoubleESingleMu_branch and "eMatchesDoubleESingleMu" not in self.complained:
        if not self.eMatchesDoubleESingleMu_branch and "eMatchesDoubleESingleMu":
            warnings.warn( "EMTree: Expected branch eMatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesDoubleESingleMu")
        else:
            self.eMatchesDoubleESingleMu_branch.SetAddress(<void*>&self.eMatchesDoubleESingleMu_value)

        #print "making eMatchesDoubleMuSingleE"
        self.eMatchesDoubleMuSingleE_branch = the_tree.GetBranch("eMatchesDoubleMuSingleE")
        #if not self.eMatchesDoubleMuSingleE_branch and "eMatchesDoubleMuSingleE" not in self.complained:
        if not self.eMatchesDoubleMuSingleE_branch and "eMatchesDoubleMuSingleE":
            warnings.warn( "EMTree: Expected branch eMatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesDoubleMuSingleE")
        else:
            self.eMatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.eMatchesDoubleMuSingleE_value)

        #print "making eMatchesSingleE"
        self.eMatchesSingleE_branch = the_tree.GetBranch("eMatchesSingleE")
        #if not self.eMatchesSingleE_branch and "eMatchesSingleE" not in self.complained:
        if not self.eMatchesSingleE_branch and "eMatchesSingleE":
            warnings.warn( "EMTree: Expected branch eMatchesSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesSingleE")
        else:
            self.eMatchesSingleE_branch.SetAddress(<void*>&self.eMatchesSingleE_value)

        #print "making eMatchesSingleESingleMu"
        self.eMatchesSingleESingleMu_branch = the_tree.GetBranch("eMatchesSingleESingleMu")
        #if not self.eMatchesSingleESingleMu_branch and "eMatchesSingleESingleMu" not in self.complained:
        if not self.eMatchesSingleESingleMu_branch and "eMatchesSingleESingleMu":
            warnings.warn( "EMTree: Expected branch eMatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesSingleESingleMu")
        else:
            self.eMatchesSingleESingleMu_branch.SetAddress(<void*>&self.eMatchesSingleESingleMu_value)

        #print "making eMatchesSingleE_leg1"
        self.eMatchesSingleE_leg1_branch = the_tree.GetBranch("eMatchesSingleE_leg1")
        #if not self.eMatchesSingleE_leg1_branch and "eMatchesSingleE_leg1" not in self.complained:
        if not self.eMatchesSingleE_leg1_branch and "eMatchesSingleE_leg1":
            warnings.warn( "EMTree: Expected branch eMatchesSingleE_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesSingleE_leg1")
        else:
            self.eMatchesSingleE_leg1_branch.SetAddress(<void*>&self.eMatchesSingleE_leg1_value)

        #print "making eMatchesSingleE_leg2"
        self.eMatchesSingleE_leg2_branch = the_tree.GetBranch("eMatchesSingleE_leg2")
        #if not self.eMatchesSingleE_leg2_branch and "eMatchesSingleE_leg2" not in self.complained:
        if not self.eMatchesSingleE_leg2_branch and "eMatchesSingleE_leg2":
            warnings.warn( "EMTree: Expected branch eMatchesSingleE_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesSingleE_leg2")
        else:
            self.eMatchesSingleE_leg2_branch.SetAddress(<void*>&self.eMatchesSingleE_leg2_value)

        #print "making eMatchesSingleMuSingleE"
        self.eMatchesSingleMuSingleE_branch = the_tree.GetBranch("eMatchesSingleMuSingleE")
        #if not self.eMatchesSingleMuSingleE_branch and "eMatchesSingleMuSingleE" not in self.complained:
        if not self.eMatchesSingleMuSingleE_branch and "eMatchesSingleMuSingleE":
            warnings.warn( "EMTree: Expected branch eMatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesSingleMuSingleE")
        else:
            self.eMatchesSingleMuSingleE_branch.SetAddress(<void*>&self.eMatchesSingleMuSingleE_value)

        #print "making eMatchesTripleE"
        self.eMatchesTripleE_branch = the_tree.GetBranch("eMatchesTripleE")
        #if not self.eMatchesTripleE_branch and "eMatchesTripleE" not in self.complained:
        if not self.eMatchesTripleE_branch and "eMatchesTripleE":
            warnings.warn( "EMTree: Expected branch eMatchesTripleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMatchesTripleE")
        else:
            self.eMatchesTripleE_branch.SetAddress(<void*>&self.eMatchesTripleE_value)

        #print "making eMissingHits"
        self.eMissingHits_branch = the_tree.GetBranch("eMissingHits")
        #if not self.eMissingHits_branch and "eMissingHits" not in self.complained:
        if not self.eMissingHits_branch and "eMissingHits":
            warnings.warn( "EMTree: Expected branch eMissingHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMissingHits")
        else:
            self.eMissingHits_branch.SetAddress(<void*>&self.eMissingHits_value)

        #print "making eMtToPfMet_ElectronEnDown"
        self.eMtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("eMtToPfMet_ElectronEnDown")
        #if not self.eMtToPfMet_ElectronEnDown_branch and "eMtToPfMet_ElectronEnDown" not in self.complained:
        if not self.eMtToPfMet_ElectronEnDown_branch and "eMtToPfMet_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_ElectronEnDown")
        else:
            self.eMtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.eMtToPfMet_ElectronEnDown_value)

        #print "making eMtToPfMet_ElectronEnUp"
        self.eMtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("eMtToPfMet_ElectronEnUp")
        #if not self.eMtToPfMet_ElectronEnUp_branch and "eMtToPfMet_ElectronEnUp" not in self.complained:
        if not self.eMtToPfMet_ElectronEnUp_branch and "eMtToPfMet_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_ElectronEnUp")
        else:
            self.eMtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.eMtToPfMet_ElectronEnUp_value)

        #print "making eMtToPfMet_JetEnDown"
        self.eMtToPfMet_JetEnDown_branch = the_tree.GetBranch("eMtToPfMet_JetEnDown")
        #if not self.eMtToPfMet_JetEnDown_branch and "eMtToPfMet_JetEnDown" not in self.complained:
        if not self.eMtToPfMet_JetEnDown_branch and "eMtToPfMet_JetEnDown":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_JetEnDown")
        else:
            self.eMtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.eMtToPfMet_JetEnDown_value)

        #print "making eMtToPfMet_JetEnUp"
        self.eMtToPfMet_JetEnUp_branch = the_tree.GetBranch("eMtToPfMet_JetEnUp")
        #if not self.eMtToPfMet_JetEnUp_branch and "eMtToPfMet_JetEnUp" not in self.complained:
        if not self.eMtToPfMet_JetEnUp_branch and "eMtToPfMet_JetEnUp":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_JetEnUp")
        else:
            self.eMtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.eMtToPfMet_JetEnUp_value)

        #print "making eMtToPfMet_JetResDown"
        self.eMtToPfMet_JetResDown_branch = the_tree.GetBranch("eMtToPfMet_JetResDown")
        #if not self.eMtToPfMet_JetResDown_branch and "eMtToPfMet_JetResDown" not in self.complained:
        if not self.eMtToPfMet_JetResDown_branch and "eMtToPfMet_JetResDown":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_JetResDown")
        else:
            self.eMtToPfMet_JetResDown_branch.SetAddress(<void*>&self.eMtToPfMet_JetResDown_value)

        #print "making eMtToPfMet_JetResUp"
        self.eMtToPfMet_JetResUp_branch = the_tree.GetBranch("eMtToPfMet_JetResUp")
        #if not self.eMtToPfMet_JetResUp_branch and "eMtToPfMet_JetResUp" not in self.complained:
        if not self.eMtToPfMet_JetResUp_branch and "eMtToPfMet_JetResUp":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_JetResUp")
        else:
            self.eMtToPfMet_JetResUp_branch.SetAddress(<void*>&self.eMtToPfMet_JetResUp_value)

        #print "making eMtToPfMet_MuonEnDown"
        self.eMtToPfMet_MuonEnDown_branch = the_tree.GetBranch("eMtToPfMet_MuonEnDown")
        #if not self.eMtToPfMet_MuonEnDown_branch and "eMtToPfMet_MuonEnDown" not in self.complained:
        if not self.eMtToPfMet_MuonEnDown_branch and "eMtToPfMet_MuonEnDown":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_MuonEnDown")
        else:
            self.eMtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.eMtToPfMet_MuonEnDown_value)

        #print "making eMtToPfMet_MuonEnUp"
        self.eMtToPfMet_MuonEnUp_branch = the_tree.GetBranch("eMtToPfMet_MuonEnUp")
        #if not self.eMtToPfMet_MuonEnUp_branch and "eMtToPfMet_MuonEnUp" not in self.complained:
        if not self.eMtToPfMet_MuonEnUp_branch and "eMtToPfMet_MuonEnUp":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_MuonEnUp")
        else:
            self.eMtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.eMtToPfMet_MuonEnUp_value)

        #print "making eMtToPfMet_PhotonEnDown"
        self.eMtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("eMtToPfMet_PhotonEnDown")
        #if not self.eMtToPfMet_PhotonEnDown_branch and "eMtToPfMet_PhotonEnDown" not in self.complained:
        if not self.eMtToPfMet_PhotonEnDown_branch and "eMtToPfMet_PhotonEnDown":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_PhotonEnDown")
        else:
            self.eMtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.eMtToPfMet_PhotonEnDown_value)

        #print "making eMtToPfMet_PhotonEnUp"
        self.eMtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("eMtToPfMet_PhotonEnUp")
        #if not self.eMtToPfMet_PhotonEnUp_branch and "eMtToPfMet_PhotonEnUp" not in self.complained:
        if not self.eMtToPfMet_PhotonEnUp_branch and "eMtToPfMet_PhotonEnUp":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_PhotonEnUp")
        else:
            self.eMtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.eMtToPfMet_PhotonEnUp_value)

        #print "making eMtToPfMet_Raw"
        self.eMtToPfMet_Raw_branch = the_tree.GetBranch("eMtToPfMet_Raw")
        #if not self.eMtToPfMet_Raw_branch and "eMtToPfMet_Raw" not in self.complained:
        if not self.eMtToPfMet_Raw_branch and "eMtToPfMet_Raw":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_Raw")
        else:
            self.eMtToPfMet_Raw_branch.SetAddress(<void*>&self.eMtToPfMet_Raw_value)

        #print "making eMtToPfMet_TauEnDown"
        self.eMtToPfMet_TauEnDown_branch = the_tree.GetBranch("eMtToPfMet_TauEnDown")
        #if not self.eMtToPfMet_TauEnDown_branch and "eMtToPfMet_TauEnDown" not in self.complained:
        if not self.eMtToPfMet_TauEnDown_branch and "eMtToPfMet_TauEnDown":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_TauEnDown")
        else:
            self.eMtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.eMtToPfMet_TauEnDown_value)

        #print "making eMtToPfMet_TauEnUp"
        self.eMtToPfMet_TauEnUp_branch = the_tree.GetBranch("eMtToPfMet_TauEnUp")
        #if not self.eMtToPfMet_TauEnUp_branch and "eMtToPfMet_TauEnUp" not in self.complained:
        if not self.eMtToPfMet_TauEnUp_branch and "eMtToPfMet_TauEnUp":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_TauEnUp")
        else:
            self.eMtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.eMtToPfMet_TauEnUp_value)

        #print "making eMtToPfMet_UnclusteredEnDown"
        self.eMtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("eMtToPfMet_UnclusteredEnDown")
        #if not self.eMtToPfMet_UnclusteredEnDown_branch and "eMtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.eMtToPfMet_UnclusteredEnDown_branch and "eMtToPfMet_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_UnclusteredEnDown")
        else:
            self.eMtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.eMtToPfMet_UnclusteredEnDown_value)

        #print "making eMtToPfMet_UnclusteredEnUp"
        self.eMtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("eMtToPfMet_UnclusteredEnUp")
        #if not self.eMtToPfMet_UnclusteredEnUp_branch and "eMtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.eMtToPfMet_UnclusteredEnUp_branch and "eMtToPfMet_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_UnclusteredEnUp")
        else:
            self.eMtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.eMtToPfMet_UnclusteredEnUp_value)

        #print "making eMtToPfMet_type1"
        self.eMtToPfMet_type1_branch = the_tree.GetBranch("eMtToPfMet_type1")
        #if not self.eMtToPfMet_type1_branch and "eMtToPfMet_type1" not in self.complained:
        if not self.eMtToPfMet_type1_branch and "eMtToPfMet_type1":
            warnings.warn( "EMTree: Expected branch eMtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eMtToPfMet_type1")
        else:
            self.eMtToPfMet_type1_branch.SetAddress(<void*>&self.eMtToPfMet_type1_value)

        #print "making eNearMuonVeto"
        self.eNearMuonVeto_branch = the_tree.GetBranch("eNearMuonVeto")
        #if not self.eNearMuonVeto_branch and "eNearMuonVeto" not in self.complained:
        if not self.eNearMuonVeto_branch and "eNearMuonVeto":
            warnings.warn( "EMTree: Expected branch eNearMuonVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eNearMuonVeto")
        else:
            self.eNearMuonVeto_branch.SetAddress(<void*>&self.eNearMuonVeto_value)

        #print "making eNearestMuonDR"
        self.eNearestMuonDR_branch = the_tree.GetBranch("eNearestMuonDR")
        #if not self.eNearestMuonDR_branch and "eNearestMuonDR" not in self.complained:
        if not self.eNearestMuonDR_branch and "eNearestMuonDR":
            warnings.warn( "EMTree: Expected branch eNearestMuonDR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eNearestMuonDR")
        else:
            self.eNearestMuonDR_branch.SetAddress(<void*>&self.eNearestMuonDR_value)

        #print "making eNearestZMass"
        self.eNearestZMass_branch = the_tree.GetBranch("eNearestZMass")
        #if not self.eNearestZMass_branch and "eNearestZMass" not in self.complained:
        if not self.eNearestZMass_branch and "eNearestZMass":
            warnings.warn( "EMTree: Expected branch eNearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eNearestZMass")
        else:
            self.eNearestZMass_branch.SetAddress(<void*>&self.eNearestZMass_value)

        #print "making ePFChargedIso"
        self.ePFChargedIso_branch = the_tree.GetBranch("ePFChargedIso")
        #if not self.ePFChargedIso_branch and "ePFChargedIso" not in self.complained:
        if not self.ePFChargedIso_branch and "ePFChargedIso":
            warnings.warn( "EMTree: Expected branch ePFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePFChargedIso")
        else:
            self.ePFChargedIso_branch.SetAddress(<void*>&self.ePFChargedIso_value)

        #print "making ePFNeutralIso"
        self.ePFNeutralIso_branch = the_tree.GetBranch("ePFNeutralIso")
        #if not self.ePFNeutralIso_branch and "ePFNeutralIso" not in self.complained:
        if not self.ePFNeutralIso_branch and "ePFNeutralIso":
            warnings.warn( "EMTree: Expected branch ePFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePFNeutralIso")
        else:
            self.ePFNeutralIso_branch.SetAddress(<void*>&self.ePFNeutralIso_value)

        #print "making ePFPUChargedIso"
        self.ePFPUChargedIso_branch = the_tree.GetBranch("ePFPUChargedIso")
        #if not self.ePFPUChargedIso_branch and "ePFPUChargedIso" not in self.complained:
        if not self.ePFPUChargedIso_branch and "ePFPUChargedIso":
            warnings.warn( "EMTree: Expected branch ePFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePFPUChargedIso")
        else:
            self.ePFPUChargedIso_branch.SetAddress(<void*>&self.ePFPUChargedIso_value)

        #print "making ePFPhotonIso"
        self.ePFPhotonIso_branch = the_tree.GetBranch("ePFPhotonIso")
        #if not self.ePFPhotonIso_branch and "ePFPhotonIso" not in self.complained:
        if not self.ePFPhotonIso_branch and "ePFPhotonIso":
            warnings.warn( "EMTree: Expected branch ePFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePFPhotonIso")
        else:
            self.ePFPhotonIso_branch.SetAddress(<void*>&self.ePFPhotonIso_value)

        #print "making ePVDXY"
        self.ePVDXY_branch = the_tree.GetBranch("ePVDXY")
        #if not self.ePVDXY_branch and "ePVDXY" not in self.complained:
        if not self.ePVDXY_branch and "ePVDXY":
            warnings.warn( "EMTree: Expected branch ePVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePVDXY")
        else:
            self.ePVDXY_branch.SetAddress(<void*>&self.ePVDXY_value)

        #print "making ePVDZ"
        self.ePVDZ_branch = the_tree.GetBranch("ePVDZ")
        #if not self.ePVDZ_branch and "ePVDZ" not in self.complained:
        if not self.ePVDZ_branch and "ePVDZ":
            warnings.warn( "EMTree: Expected branch ePVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePVDZ")
        else:
            self.ePVDZ_branch.SetAddress(<void*>&self.ePVDZ_value)

        #print "making ePassesConversionVeto"
        self.ePassesConversionVeto_branch = the_tree.GetBranch("ePassesConversionVeto")
        #if not self.ePassesConversionVeto_branch and "ePassesConversionVeto" not in self.complained:
        if not self.ePassesConversionVeto_branch and "ePassesConversionVeto":
            warnings.warn( "EMTree: Expected branch ePassesConversionVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePassesConversionVeto")
        else:
            self.ePassesConversionVeto_branch.SetAddress(<void*>&self.ePassesConversionVeto_value)

        #print "making ePhi"
        self.ePhi_branch = the_tree.GetBranch("ePhi")
        #if not self.ePhi_branch and "ePhi" not in self.complained:
        if not self.ePhi_branch and "ePhi":
            warnings.warn( "EMTree: Expected branch ePhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePhi")
        else:
            self.ePhi_branch.SetAddress(<void*>&self.ePhi_value)

        #print "making ePhi_ElectronEnDown"
        self.ePhi_ElectronEnDown_branch = the_tree.GetBranch("ePhi_ElectronEnDown")
        #if not self.ePhi_ElectronEnDown_branch and "ePhi_ElectronEnDown" not in self.complained:
        if not self.ePhi_ElectronEnDown_branch and "ePhi_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch ePhi_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePhi_ElectronEnDown")
        else:
            self.ePhi_ElectronEnDown_branch.SetAddress(<void*>&self.ePhi_ElectronEnDown_value)

        #print "making ePhi_ElectronEnUp"
        self.ePhi_ElectronEnUp_branch = the_tree.GetBranch("ePhi_ElectronEnUp")
        #if not self.ePhi_ElectronEnUp_branch and "ePhi_ElectronEnUp" not in self.complained:
        if not self.ePhi_ElectronEnUp_branch and "ePhi_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch ePhi_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePhi_ElectronEnUp")
        else:
            self.ePhi_ElectronEnUp_branch.SetAddress(<void*>&self.ePhi_ElectronEnUp_value)

        #print "making ePt"
        self.ePt_branch = the_tree.GetBranch("ePt")
        #if not self.ePt_branch and "ePt" not in self.complained:
        if not self.ePt_branch and "ePt":
            warnings.warn( "EMTree: Expected branch ePt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePt")
        else:
            self.ePt_branch.SetAddress(<void*>&self.ePt_value)

        #print "making ePt_ElectronEnDown"
        self.ePt_ElectronEnDown_branch = the_tree.GetBranch("ePt_ElectronEnDown")
        #if not self.ePt_ElectronEnDown_branch and "ePt_ElectronEnDown" not in self.complained:
        if not self.ePt_ElectronEnDown_branch and "ePt_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch ePt_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePt_ElectronEnDown")
        else:
            self.ePt_ElectronEnDown_branch.SetAddress(<void*>&self.ePt_ElectronEnDown_value)

        #print "making ePt_ElectronEnUp"
        self.ePt_ElectronEnUp_branch = the_tree.GetBranch("ePt_ElectronEnUp")
        #if not self.ePt_ElectronEnUp_branch and "ePt_ElectronEnUp" not in self.complained:
        if not self.ePt_ElectronEnUp_branch and "ePt_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch ePt_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("ePt_ElectronEnUp")
        else:
            self.ePt_ElectronEnUp_branch.SetAddress(<void*>&self.ePt_ElectronEnUp_value)

        #print "making eRank"
        self.eRank_branch = the_tree.GetBranch("eRank")
        #if not self.eRank_branch and "eRank" not in self.complained:
        if not self.eRank_branch and "eRank":
            warnings.warn( "EMTree: Expected branch eRank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eRank")
        else:
            self.eRank_branch.SetAddress(<void*>&self.eRank_value)

        #print "making eRelIso"
        self.eRelIso_branch = the_tree.GetBranch("eRelIso")
        #if not self.eRelIso_branch and "eRelIso" not in self.complained:
        if not self.eRelIso_branch and "eRelIso":
            warnings.warn( "EMTree: Expected branch eRelIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eRelIso")
        else:
            self.eRelIso_branch.SetAddress(<void*>&self.eRelIso_value)

        #print "making eRelPFIsoDB"
        self.eRelPFIsoDB_branch = the_tree.GetBranch("eRelPFIsoDB")
        #if not self.eRelPFIsoDB_branch and "eRelPFIsoDB" not in self.complained:
        if not self.eRelPFIsoDB_branch and "eRelPFIsoDB":
            warnings.warn( "EMTree: Expected branch eRelPFIsoDB does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eRelPFIsoDB")
        else:
            self.eRelPFIsoDB_branch.SetAddress(<void*>&self.eRelPFIsoDB_value)

        #print "making eRelPFIsoRho"
        self.eRelPFIsoRho_branch = the_tree.GetBranch("eRelPFIsoRho")
        #if not self.eRelPFIsoRho_branch and "eRelPFIsoRho" not in self.complained:
        if not self.eRelPFIsoRho_branch and "eRelPFIsoRho":
            warnings.warn( "EMTree: Expected branch eRelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eRelPFIsoRho")
        else:
            self.eRelPFIsoRho_branch.SetAddress(<void*>&self.eRelPFIsoRho_value)

        #print "making eRho"
        self.eRho_branch = the_tree.GetBranch("eRho")
        #if not self.eRho_branch and "eRho" not in self.complained:
        if not self.eRho_branch and "eRho":
            warnings.warn( "EMTree: Expected branch eRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eRho")
        else:
            self.eRho_branch.SetAddress(<void*>&self.eRho_value)

        #print "making eSCEnergy"
        self.eSCEnergy_branch = the_tree.GetBranch("eSCEnergy")
        #if not self.eSCEnergy_branch and "eSCEnergy" not in self.complained:
        if not self.eSCEnergy_branch and "eSCEnergy":
            warnings.warn( "EMTree: Expected branch eSCEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSCEnergy")
        else:
            self.eSCEnergy_branch.SetAddress(<void*>&self.eSCEnergy_value)

        #print "making eSCEta"
        self.eSCEta_branch = the_tree.GetBranch("eSCEta")
        #if not self.eSCEta_branch and "eSCEta" not in self.complained:
        if not self.eSCEta_branch and "eSCEta":
            warnings.warn( "EMTree: Expected branch eSCEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSCEta")
        else:
            self.eSCEta_branch.SetAddress(<void*>&self.eSCEta_value)

        #print "making eSCEtaWidth"
        self.eSCEtaWidth_branch = the_tree.GetBranch("eSCEtaWidth")
        #if not self.eSCEtaWidth_branch and "eSCEtaWidth" not in self.complained:
        if not self.eSCEtaWidth_branch and "eSCEtaWidth":
            warnings.warn( "EMTree: Expected branch eSCEtaWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSCEtaWidth")
        else:
            self.eSCEtaWidth_branch.SetAddress(<void*>&self.eSCEtaWidth_value)

        #print "making eSCPhi"
        self.eSCPhi_branch = the_tree.GetBranch("eSCPhi")
        #if not self.eSCPhi_branch and "eSCPhi" not in self.complained:
        if not self.eSCPhi_branch and "eSCPhi":
            warnings.warn( "EMTree: Expected branch eSCPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSCPhi")
        else:
            self.eSCPhi_branch.SetAddress(<void*>&self.eSCPhi_value)

        #print "making eSCPhiWidth"
        self.eSCPhiWidth_branch = the_tree.GetBranch("eSCPhiWidth")
        #if not self.eSCPhiWidth_branch and "eSCPhiWidth" not in self.complained:
        if not self.eSCPhiWidth_branch and "eSCPhiWidth":
            warnings.warn( "EMTree: Expected branch eSCPhiWidth does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSCPhiWidth")
        else:
            self.eSCPhiWidth_branch.SetAddress(<void*>&self.eSCPhiWidth_value)

        #print "making eSCPreshowerEnergy"
        self.eSCPreshowerEnergy_branch = the_tree.GetBranch("eSCPreshowerEnergy")
        #if not self.eSCPreshowerEnergy_branch and "eSCPreshowerEnergy" not in self.complained:
        if not self.eSCPreshowerEnergy_branch and "eSCPreshowerEnergy":
            warnings.warn( "EMTree: Expected branch eSCPreshowerEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSCPreshowerEnergy")
        else:
            self.eSCPreshowerEnergy_branch.SetAddress(<void*>&self.eSCPreshowerEnergy_value)

        #print "making eSCRawEnergy"
        self.eSCRawEnergy_branch = the_tree.GetBranch("eSCRawEnergy")
        #if not self.eSCRawEnergy_branch and "eSCRawEnergy" not in self.complained:
        if not self.eSCRawEnergy_branch and "eSCRawEnergy":
            warnings.warn( "EMTree: Expected branch eSCRawEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSCRawEnergy")
        else:
            self.eSCRawEnergy_branch.SetAddress(<void*>&self.eSCRawEnergy_value)

        #print "making eSIP2D"
        self.eSIP2D_branch = the_tree.GetBranch("eSIP2D")
        #if not self.eSIP2D_branch and "eSIP2D" not in self.complained:
        if not self.eSIP2D_branch and "eSIP2D":
            warnings.warn( "EMTree: Expected branch eSIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSIP2D")
        else:
            self.eSIP2D_branch.SetAddress(<void*>&self.eSIP2D_value)

        #print "making eSIP3D"
        self.eSIP3D_branch = the_tree.GetBranch("eSIP3D")
        #if not self.eSIP3D_branch and "eSIP3D" not in self.complained:
        if not self.eSIP3D_branch and "eSIP3D":
            warnings.warn( "EMTree: Expected branch eSIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSIP3D")
        else:
            self.eSIP3D_branch.SetAddress(<void*>&self.eSIP3D_value)

        #print "making eSigmaIEtaIEta"
        self.eSigmaIEtaIEta_branch = the_tree.GetBranch("eSigmaIEtaIEta")
        #if not self.eSigmaIEtaIEta_branch and "eSigmaIEtaIEta" not in self.complained:
        if not self.eSigmaIEtaIEta_branch and "eSigmaIEtaIEta":
            warnings.warn( "EMTree: Expected branch eSigmaIEtaIEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eSigmaIEtaIEta")
        else:
            self.eSigmaIEtaIEta_branch.SetAddress(<void*>&self.eSigmaIEtaIEta_value)

        #print "making eTrkIsoDR03"
        self.eTrkIsoDR03_branch = the_tree.GetBranch("eTrkIsoDR03")
        #if not self.eTrkIsoDR03_branch and "eTrkIsoDR03" not in self.complained:
        if not self.eTrkIsoDR03_branch and "eTrkIsoDR03":
            warnings.warn( "EMTree: Expected branch eTrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eTrkIsoDR03")
        else:
            self.eTrkIsoDR03_branch.SetAddress(<void*>&self.eTrkIsoDR03_value)

        #print "making eVZ"
        self.eVZ_branch = the_tree.GetBranch("eVZ")
        #if not self.eVZ_branch and "eVZ" not in self.complained:
        if not self.eVZ_branch and "eVZ":
            warnings.warn( "EMTree: Expected branch eVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eVZ")
        else:
            self.eVZ_branch.SetAddress(<void*>&self.eVZ_value)

        #print "making eVetoMVAIso"
        self.eVetoMVAIso_branch = the_tree.GetBranch("eVetoMVAIso")
        #if not self.eVetoMVAIso_branch and "eVetoMVAIso" not in self.complained:
        if not self.eVetoMVAIso_branch and "eVetoMVAIso":
            warnings.warn( "EMTree: Expected branch eVetoMVAIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eVetoMVAIso")
        else:
            self.eVetoMVAIso_branch.SetAddress(<void*>&self.eVetoMVAIso_value)

        #print "making eVetoMVAIsoVtx"
        self.eVetoMVAIsoVtx_branch = the_tree.GetBranch("eVetoMVAIsoVtx")
        #if not self.eVetoMVAIsoVtx_branch and "eVetoMVAIsoVtx" not in self.complained:
        if not self.eVetoMVAIsoVtx_branch and "eVetoMVAIsoVtx":
            warnings.warn( "EMTree: Expected branch eVetoMVAIsoVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eVetoMVAIsoVtx")
        else:
            self.eVetoMVAIsoVtx_branch.SetAddress(<void*>&self.eVetoMVAIsoVtx_value)

        #print "making eWWLoose"
        self.eWWLoose_branch = the_tree.GetBranch("eWWLoose")
        #if not self.eWWLoose_branch and "eWWLoose" not in self.complained:
        if not self.eWWLoose_branch and "eWWLoose":
            warnings.warn( "EMTree: Expected branch eWWLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eWWLoose")
        else:
            self.eWWLoose_branch.SetAddress(<void*>&self.eWWLoose_value)

        #print "making e_m_CosThetaStar"
        self.e_m_CosThetaStar_branch = the_tree.GetBranch("e_m_CosThetaStar")
        #if not self.e_m_CosThetaStar_branch and "e_m_CosThetaStar" not in self.complained:
        if not self.e_m_CosThetaStar_branch and "e_m_CosThetaStar":
            warnings.warn( "EMTree: Expected branch e_m_CosThetaStar does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_CosThetaStar")
        else:
            self.e_m_CosThetaStar_branch.SetAddress(<void*>&self.e_m_CosThetaStar_value)

        #print "making e_m_DPhi"
        self.e_m_DPhi_branch = the_tree.GetBranch("e_m_DPhi")
        #if not self.e_m_DPhi_branch and "e_m_DPhi" not in self.complained:
        if not self.e_m_DPhi_branch and "e_m_DPhi":
            warnings.warn( "EMTree: Expected branch e_m_DPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_DPhi")
        else:
            self.e_m_DPhi_branch.SetAddress(<void*>&self.e_m_DPhi_value)

        #print "making e_m_DR"
        self.e_m_DR_branch = the_tree.GetBranch("e_m_DR")
        #if not self.e_m_DR_branch and "e_m_DR" not in self.complained:
        if not self.e_m_DR_branch and "e_m_DR":
            warnings.warn( "EMTree: Expected branch e_m_DR does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_DR")
        else:
            self.e_m_DR_branch.SetAddress(<void*>&self.e_m_DR_value)

        #print "making e_m_Eta"
        self.e_m_Eta_branch = the_tree.GetBranch("e_m_Eta")
        #if not self.e_m_Eta_branch and "e_m_Eta" not in self.complained:
        if not self.e_m_Eta_branch and "e_m_Eta":
            warnings.warn( "EMTree: Expected branch e_m_Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_Eta")
        else:
            self.e_m_Eta_branch.SetAddress(<void*>&self.e_m_Eta_value)

        #print "making e_m_Mass"
        self.e_m_Mass_branch = the_tree.GetBranch("e_m_Mass")
        #if not self.e_m_Mass_branch and "e_m_Mass" not in self.complained:
        if not self.e_m_Mass_branch and "e_m_Mass":
            warnings.warn( "EMTree: Expected branch e_m_Mass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_Mass")
        else:
            self.e_m_Mass_branch.SetAddress(<void*>&self.e_m_Mass_value)

        #print "making e_m_Mt"
        self.e_m_Mt_branch = the_tree.GetBranch("e_m_Mt")
        #if not self.e_m_Mt_branch and "e_m_Mt" not in self.complained:
        if not self.e_m_Mt_branch and "e_m_Mt":
            warnings.warn( "EMTree: Expected branch e_m_Mt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_Mt")
        else:
            self.e_m_Mt_branch.SetAddress(<void*>&self.e_m_Mt_value)

        #print "making e_m_PZeta"
        self.e_m_PZeta_branch = the_tree.GetBranch("e_m_PZeta")
        #if not self.e_m_PZeta_branch and "e_m_PZeta" not in self.complained:
        if not self.e_m_PZeta_branch and "e_m_PZeta":
            warnings.warn( "EMTree: Expected branch e_m_PZeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_PZeta")
        else:
            self.e_m_PZeta_branch.SetAddress(<void*>&self.e_m_PZeta_value)

        #print "making e_m_PZetaVis"
        self.e_m_PZetaVis_branch = the_tree.GetBranch("e_m_PZetaVis")
        #if not self.e_m_PZetaVis_branch and "e_m_PZetaVis" not in self.complained:
        if not self.e_m_PZetaVis_branch and "e_m_PZetaVis":
            warnings.warn( "EMTree: Expected branch e_m_PZetaVis does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_PZetaVis")
        else:
            self.e_m_PZetaVis_branch.SetAddress(<void*>&self.e_m_PZetaVis_value)

        #print "making e_m_Phi"
        self.e_m_Phi_branch = the_tree.GetBranch("e_m_Phi")
        #if not self.e_m_Phi_branch and "e_m_Phi" not in self.complained:
        if not self.e_m_Phi_branch and "e_m_Phi":
            warnings.warn( "EMTree: Expected branch e_m_Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_Phi")
        else:
            self.e_m_Phi_branch.SetAddress(<void*>&self.e_m_Phi_value)

        #print "making e_m_Pt"
        self.e_m_Pt_branch = the_tree.GetBranch("e_m_Pt")
        #if not self.e_m_Pt_branch and "e_m_Pt" not in self.complained:
        if not self.e_m_Pt_branch and "e_m_Pt":
            warnings.warn( "EMTree: Expected branch e_m_Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_Pt")
        else:
            self.e_m_Pt_branch.SetAddress(<void*>&self.e_m_Pt_value)

        #print "making e_m_SS"
        self.e_m_SS_branch = the_tree.GetBranch("e_m_SS")
        #if not self.e_m_SS_branch and "e_m_SS" not in self.complained:
        if not self.e_m_SS_branch and "e_m_SS":
            warnings.warn( "EMTree: Expected branch e_m_SS does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_SS")
        else:
            self.e_m_SS_branch.SetAddress(<void*>&self.e_m_SS_value)

        #print "making e_m_ToMETDPhi_Ty1"
        self.e_m_ToMETDPhi_Ty1_branch = the_tree.GetBranch("e_m_ToMETDPhi_Ty1")
        #if not self.e_m_ToMETDPhi_Ty1_branch and "e_m_ToMETDPhi_Ty1" not in self.complained:
        if not self.e_m_ToMETDPhi_Ty1_branch and "e_m_ToMETDPhi_Ty1":
            warnings.warn( "EMTree: Expected branch e_m_ToMETDPhi_Ty1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_ToMETDPhi_Ty1")
        else:
            self.e_m_ToMETDPhi_Ty1_branch.SetAddress(<void*>&self.e_m_ToMETDPhi_Ty1_value)

        #print "making e_m_collinearmass"
        self.e_m_collinearmass_branch = the_tree.GetBranch("e_m_collinearmass")
        #if not self.e_m_collinearmass_branch and "e_m_collinearmass" not in self.complained:
        if not self.e_m_collinearmass_branch and "e_m_collinearmass":
            warnings.warn( "EMTree: Expected branch e_m_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_collinearmass")
        else:
            self.e_m_collinearmass_branch.SetAddress(<void*>&self.e_m_collinearmass_value)

        #print "making e_m_collinearmass_JetEnDown"
        self.e_m_collinearmass_JetEnDown_branch = the_tree.GetBranch("e_m_collinearmass_JetEnDown")
        #if not self.e_m_collinearmass_JetEnDown_branch and "e_m_collinearmass_JetEnDown" not in self.complained:
        if not self.e_m_collinearmass_JetEnDown_branch and "e_m_collinearmass_JetEnDown":
            warnings.warn( "EMTree: Expected branch e_m_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_collinearmass_JetEnDown")
        else:
            self.e_m_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.e_m_collinearmass_JetEnDown_value)

        #print "making e_m_collinearmass_JetEnUp"
        self.e_m_collinearmass_JetEnUp_branch = the_tree.GetBranch("e_m_collinearmass_JetEnUp")
        #if not self.e_m_collinearmass_JetEnUp_branch and "e_m_collinearmass_JetEnUp" not in self.complained:
        if not self.e_m_collinearmass_JetEnUp_branch and "e_m_collinearmass_JetEnUp":
            warnings.warn( "EMTree: Expected branch e_m_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_collinearmass_JetEnUp")
        else:
            self.e_m_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.e_m_collinearmass_JetEnUp_value)

        #print "making e_m_collinearmass_UnclusteredEnDown"
        self.e_m_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("e_m_collinearmass_UnclusteredEnDown")
        #if not self.e_m_collinearmass_UnclusteredEnDown_branch and "e_m_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.e_m_collinearmass_UnclusteredEnDown_branch and "e_m_collinearmass_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch e_m_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_collinearmass_UnclusteredEnDown")
        else:
            self.e_m_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.e_m_collinearmass_UnclusteredEnDown_value)

        #print "making e_m_collinearmass_UnclusteredEnUp"
        self.e_m_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("e_m_collinearmass_UnclusteredEnUp")
        #if not self.e_m_collinearmass_UnclusteredEnUp_branch and "e_m_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.e_m_collinearmass_UnclusteredEnUp_branch and "e_m_collinearmass_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch e_m_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("e_m_collinearmass_UnclusteredEnUp")
        else:
            self.e_m_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.e_m_collinearmass_UnclusteredEnUp_value)

        #print "making edeltaEtaSuperClusterTrackAtVtx"
        self.edeltaEtaSuperClusterTrackAtVtx_branch = the_tree.GetBranch("edeltaEtaSuperClusterTrackAtVtx")
        #if not self.edeltaEtaSuperClusterTrackAtVtx_branch and "edeltaEtaSuperClusterTrackAtVtx" not in self.complained:
        if not self.edeltaEtaSuperClusterTrackAtVtx_branch and "edeltaEtaSuperClusterTrackAtVtx":
            warnings.warn( "EMTree: Expected branch edeltaEtaSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("edeltaEtaSuperClusterTrackAtVtx")
        else:
            self.edeltaEtaSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.edeltaEtaSuperClusterTrackAtVtx_value)

        #print "making edeltaPhiSuperClusterTrackAtVtx"
        self.edeltaPhiSuperClusterTrackAtVtx_branch = the_tree.GetBranch("edeltaPhiSuperClusterTrackAtVtx")
        #if not self.edeltaPhiSuperClusterTrackAtVtx_branch and "edeltaPhiSuperClusterTrackAtVtx" not in self.complained:
        if not self.edeltaPhiSuperClusterTrackAtVtx_branch and "edeltaPhiSuperClusterTrackAtVtx":
            warnings.warn( "EMTree: Expected branch edeltaPhiSuperClusterTrackAtVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("edeltaPhiSuperClusterTrackAtVtx")
        else:
            self.edeltaPhiSuperClusterTrackAtVtx_branch.SetAddress(<void*>&self.edeltaPhiSuperClusterTrackAtVtx_value)

        #print "making eeSuperClusterOverP"
        self.eeSuperClusterOverP_branch = the_tree.GetBranch("eeSuperClusterOverP")
        #if not self.eeSuperClusterOverP_branch and "eeSuperClusterOverP" not in self.complained:
        if not self.eeSuperClusterOverP_branch and "eeSuperClusterOverP":
            warnings.warn( "EMTree: Expected branch eeSuperClusterOverP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eeSuperClusterOverP")
        else:
            self.eeSuperClusterOverP_branch.SetAddress(<void*>&self.eeSuperClusterOverP_value)

        #print "making eecalEnergy"
        self.eecalEnergy_branch = the_tree.GetBranch("eecalEnergy")
        #if not self.eecalEnergy_branch and "eecalEnergy" not in self.complained:
        if not self.eecalEnergy_branch and "eecalEnergy":
            warnings.warn( "EMTree: Expected branch eecalEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("eecalEnergy")
        else:
            self.eecalEnergy_branch.SetAddress(<void*>&self.eecalEnergy_value)

        #print "making efBrem"
        self.efBrem_branch = the_tree.GetBranch("efBrem")
        #if not self.efBrem_branch and "efBrem" not in self.complained:
        if not self.efBrem_branch and "efBrem":
            warnings.warn( "EMTree: Expected branch efBrem does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("efBrem")
        else:
            self.efBrem_branch.SetAddress(<void*>&self.efBrem_value)

        #print "making etrackMomentumAtVtxP"
        self.etrackMomentumAtVtxP_branch = the_tree.GetBranch("etrackMomentumAtVtxP")
        #if not self.etrackMomentumAtVtxP_branch and "etrackMomentumAtVtxP" not in self.complained:
        if not self.etrackMomentumAtVtxP_branch and "etrackMomentumAtVtxP":
            warnings.warn( "EMTree: Expected branch etrackMomentumAtVtxP does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("etrackMomentumAtVtxP")
        else:
            self.etrackMomentumAtVtxP_branch.SetAddress(<void*>&self.etrackMomentumAtVtxP_value)

        #print "making evt"
        self.evt_branch = the_tree.GetBranch("evt")
        #if not self.evt_branch and "evt" not in self.complained:
        if not self.evt_branch and "evt":
            warnings.warn( "EMTree: Expected branch evt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("evt")
        else:
            self.evt_branch.SetAddress(<void*>&self.evt_value)

        #print "making genHTT"
        self.genHTT_branch = the_tree.GetBranch("genHTT")
        #if not self.genHTT_branch and "genHTT" not in self.complained:
        if not self.genHTT_branch and "genHTT":
            warnings.warn( "EMTree: Expected branch genHTT does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("genHTT")
        else:
            self.genHTT_branch.SetAddress(<void*>&self.genHTT_value)

        #print "making isGtautau"
        self.isGtautau_branch = the_tree.GetBranch("isGtautau")
        #if not self.isGtautau_branch and "isGtautau" not in self.complained:
        if not self.isGtautau_branch and "isGtautau":
            warnings.warn( "EMTree: Expected branch isGtautau does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isGtautau")
        else:
            self.isGtautau_branch.SetAddress(<void*>&self.isGtautau_value)

        #print "making isWmunu"
        self.isWmunu_branch = the_tree.GetBranch("isWmunu")
        #if not self.isWmunu_branch and "isWmunu" not in self.complained:
        if not self.isWmunu_branch and "isWmunu":
            warnings.warn( "EMTree: Expected branch isWmunu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isWmunu")
        else:
            self.isWmunu_branch.SetAddress(<void*>&self.isWmunu_value)

        #print "making isWtaunu"
        self.isWtaunu_branch = the_tree.GetBranch("isWtaunu")
        #if not self.isWtaunu_branch and "isWtaunu" not in self.complained:
        if not self.isWtaunu_branch and "isWtaunu":
            warnings.warn( "EMTree: Expected branch isWtaunu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isWtaunu")
        else:
            self.isWtaunu_branch.SetAddress(<void*>&self.isWtaunu_value)

        #print "making isZee"
        self.isZee_branch = the_tree.GetBranch("isZee")
        #if not self.isZee_branch and "isZee" not in self.complained:
        if not self.isZee_branch and "isZee":
            warnings.warn( "EMTree: Expected branch isZee does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZee")
        else:
            self.isZee_branch.SetAddress(<void*>&self.isZee_value)

        #print "making isZmumu"
        self.isZmumu_branch = the_tree.GetBranch("isZmumu")
        #if not self.isZmumu_branch and "isZmumu" not in self.complained:
        if not self.isZmumu_branch and "isZmumu":
            warnings.warn( "EMTree: Expected branch isZmumu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZmumu")
        else:
            self.isZmumu_branch.SetAddress(<void*>&self.isZmumu_value)

        #print "making isZtautau"
        self.isZtautau_branch = the_tree.GetBranch("isZtautau")
        #if not self.isZtautau_branch and "isZtautau" not in self.complained:
        if not self.isZtautau_branch and "isZtautau":
            warnings.warn( "EMTree: Expected branch isZtautau does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isZtautau")
        else:
            self.isZtautau_branch.SetAddress(<void*>&self.isZtautau_value)

        #print "making isdata"
        self.isdata_branch = the_tree.GetBranch("isdata")
        #if not self.isdata_branch and "isdata" not in self.complained:
        if not self.isdata_branch and "isdata":
            warnings.warn( "EMTree: Expected branch isdata does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("isdata")
        else:
            self.isdata_branch.SetAddress(<void*>&self.isdata_value)

        #print "making jet1BJetCISV"
        self.jet1BJetCISV_branch = the_tree.GetBranch("jet1BJetCISV")
        #if not self.jet1BJetCISV_branch and "jet1BJetCISV" not in self.complained:
        if not self.jet1BJetCISV_branch and "jet1BJetCISV":
            warnings.warn( "EMTree: Expected branch jet1BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1BJetCISV")
        else:
            self.jet1BJetCISV_branch.SetAddress(<void*>&self.jet1BJetCISV_value)

        #print "making jet1Eta"
        self.jet1Eta_branch = the_tree.GetBranch("jet1Eta")
        #if not self.jet1Eta_branch and "jet1Eta" not in self.complained:
        if not self.jet1Eta_branch and "jet1Eta":
            warnings.warn( "EMTree: Expected branch jet1Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1Eta")
        else:
            self.jet1Eta_branch.SetAddress(<void*>&self.jet1Eta_value)

        #print "making jet1IDLoose"
        self.jet1IDLoose_branch = the_tree.GetBranch("jet1IDLoose")
        #if not self.jet1IDLoose_branch and "jet1IDLoose" not in self.complained:
        if not self.jet1IDLoose_branch and "jet1IDLoose":
            warnings.warn( "EMTree: Expected branch jet1IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1IDLoose")
        else:
            self.jet1IDLoose_branch.SetAddress(<void*>&self.jet1IDLoose_value)

        #print "making jet1IDTight"
        self.jet1IDTight_branch = the_tree.GetBranch("jet1IDTight")
        #if not self.jet1IDTight_branch and "jet1IDTight" not in self.complained:
        if not self.jet1IDTight_branch and "jet1IDTight":
            warnings.warn( "EMTree: Expected branch jet1IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1IDTight")
        else:
            self.jet1IDTight_branch.SetAddress(<void*>&self.jet1IDTight_value)

        #print "making jet1IDTightLepVeto"
        self.jet1IDTightLepVeto_branch = the_tree.GetBranch("jet1IDTightLepVeto")
        #if not self.jet1IDTightLepVeto_branch and "jet1IDTightLepVeto" not in self.complained:
        if not self.jet1IDTightLepVeto_branch and "jet1IDTightLepVeto":
            warnings.warn( "EMTree: Expected branch jet1IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1IDTightLepVeto")
        else:
            self.jet1IDTightLepVeto_branch.SetAddress(<void*>&self.jet1IDTightLepVeto_value)

        #print "making jet1PUMVA"
        self.jet1PUMVA_branch = the_tree.GetBranch("jet1PUMVA")
        #if not self.jet1PUMVA_branch and "jet1PUMVA" not in self.complained:
        if not self.jet1PUMVA_branch and "jet1PUMVA":
            warnings.warn( "EMTree: Expected branch jet1PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1PUMVA")
        else:
            self.jet1PUMVA_branch.SetAddress(<void*>&self.jet1PUMVA_value)

        #print "making jet1Phi"
        self.jet1Phi_branch = the_tree.GetBranch("jet1Phi")
        #if not self.jet1Phi_branch and "jet1Phi" not in self.complained:
        if not self.jet1Phi_branch and "jet1Phi":
            warnings.warn( "EMTree: Expected branch jet1Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1Phi")
        else:
            self.jet1Phi_branch.SetAddress(<void*>&self.jet1Phi_value)

        #print "making jet1Pt"
        self.jet1Pt_branch = the_tree.GetBranch("jet1Pt")
        #if not self.jet1Pt_branch and "jet1Pt" not in self.complained:
        if not self.jet1Pt_branch and "jet1Pt":
            warnings.warn( "EMTree: Expected branch jet1Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet1Pt")
        else:
            self.jet1Pt_branch.SetAddress(<void*>&self.jet1Pt_value)

        #print "making jet2BJetCISV"
        self.jet2BJetCISV_branch = the_tree.GetBranch("jet2BJetCISV")
        #if not self.jet2BJetCISV_branch and "jet2BJetCISV" not in self.complained:
        if not self.jet2BJetCISV_branch and "jet2BJetCISV":
            warnings.warn( "EMTree: Expected branch jet2BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2BJetCISV")
        else:
            self.jet2BJetCISV_branch.SetAddress(<void*>&self.jet2BJetCISV_value)

        #print "making jet2Eta"
        self.jet2Eta_branch = the_tree.GetBranch("jet2Eta")
        #if not self.jet2Eta_branch and "jet2Eta" not in self.complained:
        if not self.jet2Eta_branch and "jet2Eta":
            warnings.warn( "EMTree: Expected branch jet2Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2Eta")
        else:
            self.jet2Eta_branch.SetAddress(<void*>&self.jet2Eta_value)

        #print "making jet2IDLoose"
        self.jet2IDLoose_branch = the_tree.GetBranch("jet2IDLoose")
        #if not self.jet2IDLoose_branch and "jet2IDLoose" not in self.complained:
        if not self.jet2IDLoose_branch and "jet2IDLoose":
            warnings.warn( "EMTree: Expected branch jet2IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2IDLoose")
        else:
            self.jet2IDLoose_branch.SetAddress(<void*>&self.jet2IDLoose_value)

        #print "making jet2IDTight"
        self.jet2IDTight_branch = the_tree.GetBranch("jet2IDTight")
        #if not self.jet2IDTight_branch and "jet2IDTight" not in self.complained:
        if not self.jet2IDTight_branch and "jet2IDTight":
            warnings.warn( "EMTree: Expected branch jet2IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2IDTight")
        else:
            self.jet2IDTight_branch.SetAddress(<void*>&self.jet2IDTight_value)

        #print "making jet2IDTightLepVeto"
        self.jet2IDTightLepVeto_branch = the_tree.GetBranch("jet2IDTightLepVeto")
        #if not self.jet2IDTightLepVeto_branch and "jet2IDTightLepVeto" not in self.complained:
        if not self.jet2IDTightLepVeto_branch and "jet2IDTightLepVeto":
            warnings.warn( "EMTree: Expected branch jet2IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2IDTightLepVeto")
        else:
            self.jet2IDTightLepVeto_branch.SetAddress(<void*>&self.jet2IDTightLepVeto_value)

        #print "making jet2PUMVA"
        self.jet2PUMVA_branch = the_tree.GetBranch("jet2PUMVA")
        #if not self.jet2PUMVA_branch and "jet2PUMVA" not in self.complained:
        if not self.jet2PUMVA_branch and "jet2PUMVA":
            warnings.warn( "EMTree: Expected branch jet2PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2PUMVA")
        else:
            self.jet2PUMVA_branch.SetAddress(<void*>&self.jet2PUMVA_value)

        #print "making jet2Phi"
        self.jet2Phi_branch = the_tree.GetBranch("jet2Phi")
        #if not self.jet2Phi_branch and "jet2Phi" not in self.complained:
        if not self.jet2Phi_branch and "jet2Phi":
            warnings.warn( "EMTree: Expected branch jet2Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2Phi")
        else:
            self.jet2Phi_branch.SetAddress(<void*>&self.jet2Phi_value)

        #print "making jet2Pt"
        self.jet2Pt_branch = the_tree.GetBranch("jet2Pt")
        #if not self.jet2Pt_branch and "jet2Pt" not in self.complained:
        if not self.jet2Pt_branch and "jet2Pt":
            warnings.warn( "EMTree: Expected branch jet2Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet2Pt")
        else:
            self.jet2Pt_branch.SetAddress(<void*>&self.jet2Pt_value)

        #print "making jet3BJetCISV"
        self.jet3BJetCISV_branch = the_tree.GetBranch("jet3BJetCISV")
        #if not self.jet3BJetCISV_branch and "jet3BJetCISV" not in self.complained:
        if not self.jet3BJetCISV_branch and "jet3BJetCISV":
            warnings.warn( "EMTree: Expected branch jet3BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3BJetCISV")
        else:
            self.jet3BJetCISV_branch.SetAddress(<void*>&self.jet3BJetCISV_value)

        #print "making jet3Eta"
        self.jet3Eta_branch = the_tree.GetBranch("jet3Eta")
        #if not self.jet3Eta_branch and "jet3Eta" not in self.complained:
        if not self.jet3Eta_branch and "jet3Eta":
            warnings.warn( "EMTree: Expected branch jet3Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3Eta")
        else:
            self.jet3Eta_branch.SetAddress(<void*>&self.jet3Eta_value)

        #print "making jet3IDLoose"
        self.jet3IDLoose_branch = the_tree.GetBranch("jet3IDLoose")
        #if not self.jet3IDLoose_branch and "jet3IDLoose" not in self.complained:
        if not self.jet3IDLoose_branch and "jet3IDLoose":
            warnings.warn( "EMTree: Expected branch jet3IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3IDLoose")
        else:
            self.jet3IDLoose_branch.SetAddress(<void*>&self.jet3IDLoose_value)

        #print "making jet3IDTight"
        self.jet3IDTight_branch = the_tree.GetBranch("jet3IDTight")
        #if not self.jet3IDTight_branch and "jet3IDTight" not in self.complained:
        if not self.jet3IDTight_branch and "jet3IDTight":
            warnings.warn( "EMTree: Expected branch jet3IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3IDTight")
        else:
            self.jet3IDTight_branch.SetAddress(<void*>&self.jet3IDTight_value)

        #print "making jet3IDTightLepVeto"
        self.jet3IDTightLepVeto_branch = the_tree.GetBranch("jet3IDTightLepVeto")
        #if not self.jet3IDTightLepVeto_branch and "jet3IDTightLepVeto" not in self.complained:
        if not self.jet3IDTightLepVeto_branch and "jet3IDTightLepVeto":
            warnings.warn( "EMTree: Expected branch jet3IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3IDTightLepVeto")
        else:
            self.jet3IDTightLepVeto_branch.SetAddress(<void*>&self.jet3IDTightLepVeto_value)

        #print "making jet3PUMVA"
        self.jet3PUMVA_branch = the_tree.GetBranch("jet3PUMVA")
        #if not self.jet3PUMVA_branch and "jet3PUMVA" not in self.complained:
        if not self.jet3PUMVA_branch and "jet3PUMVA":
            warnings.warn( "EMTree: Expected branch jet3PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3PUMVA")
        else:
            self.jet3PUMVA_branch.SetAddress(<void*>&self.jet3PUMVA_value)

        #print "making jet3Phi"
        self.jet3Phi_branch = the_tree.GetBranch("jet3Phi")
        #if not self.jet3Phi_branch and "jet3Phi" not in self.complained:
        if not self.jet3Phi_branch and "jet3Phi":
            warnings.warn( "EMTree: Expected branch jet3Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3Phi")
        else:
            self.jet3Phi_branch.SetAddress(<void*>&self.jet3Phi_value)

        #print "making jet3Pt"
        self.jet3Pt_branch = the_tree.GetBranch("jet3Pt")
        #if not self.jet3Pt_branch and "jet3Pt" not in self.complained:
        if not self.jet3Pt_branch and "jet3Pt":
            warnings.warn( "EMTree: Expected branch jet3Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet3Pt")
        else:
            self.jet3Pt_branch.SetAddress(<void*>&self.jet3Pt_value)

        #print "making jet4BJetCISV"
        self.jet4BJetCISV_branch = the_tree.GetBranch("jet4BJetCISV")
        #if not self.jet4BJetCISV_branch and "jet4BJetCISV" not in self.complained:
        if not self.jet4BJetCISV_branch and "jet4BJetCISV":
            warnings.warn( "EMTree: Expected branch jet4BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4BJetCISV")
        else:
            self.jet4BJetCISV_branch.SetAddress(<void*>&self.jet4BJetCISV_value)

        #print "making jet4Eta"
        self.jet4Eta_branch = the_tree.GetBranch("jet4Eta")
        #if not self.jet4Eta_branch and "jet4Eta" not in self.complained:
        if not self.jet4Eta_branch and "jet4Eta":
            warnings.warn( "EMTree: Expected branch jet4Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4Eta")
        else:
            self.jet4Eta_branch.SetAddress(<void*>&self.jet4Eta_value)

        #print "making jet4IDLoose"
        self.jet4IDLoose_branch = the_tree.GetBranch("jet4IDLoose")
        #if not self.jet4IDLoose_branch and "jet4IDLoose" not in self.complained:
        if not self.jet4IDLoose_branch and "jet4IDLoose":
            warnings.warn( "EMTree: Expected branch jet4IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4IDLoose")
        else:
            self.jet4IDLoose_branch.SetAddress(<void*>&self.jet4IDLoose_value)

        #print "making jet4IDTight"
        self.jet4IDTight_branch = the_tree.GetBranch("jet4IDTight")
        #if not self.jet4IDTight_branch and "jet4IDTight" not in self.complained:
        if not self.jet4IDTight_branch and "jet4IDTight":
            warnings.warn( "EMTree: Expected branch jet4IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4IDTight")
        else:
            self.jet4IDTight_branch.SetAddress(<void*>&self.jet4IDTight_value)

        #print "making jet4IDTightLepVeto"
        self.jet4IDTightLepVeto_branch = the_tree.GetBranch("jet4IDTightLepVeto")
        #if not self.jet4IDTightLepVeto_branch and "jet4IDTightLepVeto" not in self.complained:
        if not self.jet4IDTightLepVeto_branch and "jet4IDTightLepVeto":
            warnings.warn( "EMTree: Expected branch jet4IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4IDTightLepVeto")
        else:
            self.jet4IDTightLepVeto_branch.SetAddress(<void*>&self.jet4IDTightLepVeto_value)

        #print "making jet4PUMVA"
        self.jet4PUMVA_branch = the_tree.GetBranch("jet4PUMVA")
        #if not self.jet4PUMVA_branch and "jet4PUMVA" not in self.complained:
        if not self.jet4PUMVA_branch and "jet4PUMVA":
            warnings.warn( "EMTree: Expected branch jet4PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4PUMVA")
        else:
            self.jet4PUMVA_branch.SetAddress(<void*>&self.jet4PUMVA_value)

        #print "making jet4Phi"
        self.jet4Phi_branch = the_tree.GetBranch("jet4Phi")
        #if not self.jet4Phi_branch and "jet4Phi" not in self.complained:
        if not self.jet4Phi_branch and "jet4Phi":
            warnings.warn( "EMTree: Expected branch jet4Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4Phi")
        else:
            self.jet4Phi_branch.SetAddress(<void*>&self.jet4Phi_value)

        #print "making jet4Pt"
        self.jet4Pt_branch = the_tree.GetBranch("jet4Pt")
        #if not self.jet4Pt_branch and "jet4Pt" not in self.complained:
        if not self.jet4Pt_branch and "jet4Pt":
            warnings.warn( "EMTree: Expected branch jet4Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet4Pt")
        else:
            self.jet4Pt_branch.SetAddress(<void*>&self.jet4Pt_value)

        #print "making jet5BJetCISV"
        self.jet5BJetCISV_branch = the_tree.GetBranch("jet5BJetCISV")
        #if not self.jet5BJetCISV_branch and "jet5BJetCISV" not in self.complained:
        if not self.jet5BJetCISV_branch and "jet5BJetCISV":
            warnings.warn( "EMTree: Expected branch jet5BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5BJetCISV")
        else:
            self.jet5BJetCISV_branch.SetAddress(<void*>&self.jet5BJetCISV_value)

        #print "making jet5Eta"
        self.jet5Eta_branch = the_tree.GetBranch("jet5Eta")
        #if not self.jet5Eta_branch and "jet5Eta" not in self.complained:
        if not self.jet5Eta_branch and "jet5Eta":
            warnings.warn( "EMTree: Expected branch jet5Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5Eta")
        else:
            self.jet5Eta_branch.SetAddress(<void*>&self.jet5Eta_value)

        #print "making jet5IDLoose"
        self.jet5IDLoose_branch = the_tree.GetBranch("jet5IDLoose")
        #if not self.jet5IDLoose_branch and "jet5IDLoose" not in self.complained:
        if not self.jet5IDLoose_branch and "jet5IDLoose":
            warnings.warn( "EMTree: Expected branch jet5IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5IDLoose")
        else:
            self.jet5IDLoose_branch.SetAddress(<void*>&self.jet5IDLoose_value)

        #print "making jet5IDTight"
        self.jet5IDTight_branch = the_tree.GetBranch("jet5IDTight")
        #if not self.jet5IDTight_branch and "jet5IDTight" not in self.complained:
        if not self.jet5IDTight_branch and "jet5IDTight":
            warnings.warn( "EMTree: Expected branch jet5IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5IDTight")
        else:
            self.jet5IDTight_branch.SetAddress(<void*>&self.jet5IDTight_value)

        #print "making jet5IDTightLepVeto"
        self.jet5IDTightLepVeto_branch = the_tree.GetBranch("jet5IDTightLepVeto")
        #if not self.jet5IDTightLepVeto_branch and "jet5IDTightLepVeto" not in self.complained:
        if not self.jet5IDTightLepVeto_branch and "jet5IDTightLepVeto":
            warnings.warn( "EMTree: Expected branch jet5IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5IDTightLepVeto")
        else:
            self.jet5IDTightLepVeto_branch.SetAddress(<void*>&self.jet5IDTightLepVeto_value)

        #print "making jet5PUMVA"
        self.jet5PUMVA_branch = the_tree.GetBranch("jet5PUMVA")
        #if not self.jet5PUMVA_branch and "jet5PUMVA" not in self.complained:
        if not self.jet5PUMVA_branch and "jet5PUMVA":
            warnings.warn( "EMTree: Expected branch jet5PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5PUMVA")
        else:
            self.jet5PUMVA_branch.SetAddress(<void*>&self.jet5PUMVA_value)

        #print "making jet5Phi"
        self.jet5Phi_branch = the_tree.GetBranch("jet5Phi")
        #if not self.jet5Phi_branch and "jet5Phi" not in self.complained:
        if not self.jet5Phi_branch and "jet5Phi":
            warnings.warn( "EMTree: Expected branch jet5Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5Phi")
        else:
            self.jet5Phi_branch.SetAddress(<void*>&self.jet5Phi_value)

        #print "making jet5Pt"
        self.jet5Pt_branch = the_tree.GetBranch("jet5Pt")
        #if not self.jet5Pt_branch and "jet5Pt" not in self.complained:
        if not self.jet5Pt_branch and "jet5Pt":
            warnings.warn( "EMTree: Expected branch jet5Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet5Pt")
        else:
            self.jet5Pt_branch.SetAddress(<void*>&self.jet5Pt_value)

        #print "making jet6BJetCISV"
        self.jet6BJetCISV_branch = the_tree.GetBranch("jet6BJetCISV")
        #if not self.jet6BJetCISV_branch and "jet6BJetCISV" not in self.complained:
        if not self.jet6BJetCISV_branch and "jet6BJetCISV":
            warnings.warn( "EMTree: Expected branch jet6BJetCISV does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6BJetCISV")
        else:
            self.jet6BJetCISV_branch.SetAddress(<void*>&self.jet6BJetCISV_value)

        #print "making jet6Eta"
        self.jet6Eta_branch = the_tree.GetBranch("jet6Eta")
        #if not self.jet6Eta_branch and "jet6Eta" not in self.complained:
        if not self.jet6Eta_branch and "jet6Eta":
            warnings.warn( "EMTree: Expected branch jet6Eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6Eta")
        else:
            self.jet6Eta_branch.SetAddress(<void*>&self.jet6Eta_value)

        #print "making jet6IDLoose"
        self.jet6IDLoose_branch = the_tree.GetBranch("jet6IDLoose")
        #if not self.jet6IDLoose_branch and "jet6IDLoose" not in self.complained:
        if not self.jet6IDLoose_branch and "jet6IDLoose":
            warnings.warn( "EMTree: Expected branch jet6IDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6IDLoose")
        else:
            self.jet6IDLoose_branch.SetAddress(<void*>&self.jet6IDLoose_value)

        #print "making jet6IDTight"
        self.jet6IDTight_branch = the_tree.GetBranch("jet6IDTight")
        #if not self.jet6IDTight_branch and "jet6IDTight" not in self.complained:
        if not self.jet6IDTight_branch and "jet6IDTight":
            warnings.warn( "EMTree: Expected branch jet6IDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6IDTight")
        else:
            self.jet6IDTight_branch.SetAddress(<void*>&self.jet6IDTight_value)

        #print "making jet6IDTightLepVeto"
        self.jet6IDTightLepVeto_branch = the_tree.GetBranch("jet6IDTightLepVeto")
        #if not self.jet6IDTightLepVeto_branch and "jet6IDTightLepVeto" not in self.complained:
        if not self.jet6IDTightLepVeto_branch and "jet6IDTightLepVeto":
            warnings.warn( "EMTree: Expected branch jet6IDTightLepVeto does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6IDTightLepVeto")
        else:
            self.jet6IDTightLepVeto_branch.SetAddress(<void*>&self.jet6IDTightLepVeto_value)

        #print "making jet6PUMVA"
        self.jet6PUMVA_branch = the_tree.GetBranch("jet6PUMVA")
        #if not self.jet6PUMVA_branch and "jet6PUMVA" not in self.complained:
        if not self.jet6PUMVA_branch and "jet6PUMVA":
            warnings.warn( "EMTree: Expected branch jet6PUMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6PUMVA")
        else:
            self.jet6PUMVA_branch.SetAddress(<void*>&self.jet6PUMVA_value)

        #print "making jet6Phi"
        self.jet6Phi_branch = the_tree.GetBranch("jet6Phi")
        #if not self.jet6Phi_branch and "jet6Phi" not in self.complained:
        if not self.jet6Phi_branch and "jet6Phi":
            warnings.warn( "EMTree: Expected branch jet6Phi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6Phi")
        else:
            self.jet6Phi_branch.SetAddress(<void*>&self.jet6Phi_value)

        #print "making jet6Pt"
        self.jet6Pt_branch = the_tree.GetBranch("jet6Pt")
        #if not self.jet6Pt_branch and "jet6Pt" not in self.complained:
        if not self.jet6Pt_branch and "jet6Pt":
            warnings.warn( "EMTree: Expected branch jet6Pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jet6Pt")
        else:
            self.jet6Pt_branch.SetAddress(<void*>&self.jet6Pt_value)

        #print "making jetVeto20"
        self.jetVeto20_branch = the_tree.GetBranch("jetVeto20")
        #if not self.jetVeto20_branch and "jetVeto20" not in self.complained:
        if not self.jetVeto20_branch and "jetVeto20":
            warnings.warn( "EMTree: Expected branch jetVeto20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto20")
        else:
            self.jetVeto20_branch.SetAddress(<void*>&self.jetVeto20_value)

        #print "making jetVeto20_DR05"
        self.jetVeto20_DR05_branch = the_tree.GetBranch("jetVeto20_DR05")
        #if not self.jetVeto20_DR05_branch and "jetVeto20_DR05" not in self.complained:
        if not self.jetVeto20_DR05_branch and "jetVeto20_DR05":
            warnings.warn( "EMTree: Expected branch jetVeto20_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto20_DR05")
        else:
            self.jetVeto20_DR05_branch.SetAddress(<void*>&self.jetVeto20_DR05_value)

        #print "making jetVeto30"
        self.jetVeto30_branch = the_tree.GetBranch("jetVeto30")
        #if not self.jetVeto30_branch and "jetVeto30" not in self.complained:
        if not self.jetVeto30_branch and "jetVeto30":
            warnings.warn( "EMTree: Expected branch jetVeto30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30")
        else:
            self.jetVeto30_branch.SetAddress(<void*>&self.jetVeto30_value)

        #print "making jetVeto30Eta3"
        self.jetVeto30Eta3_branch = the_tree.GetBranch("jetVeto30Eta3")
        #if not self.jetVeto30Eta3_branch and "jetVeto30Eta3" not in self.complained:
        if not self.jetVeto30Eta3_branch and "jetVeto30Eta3":
            warnings.warn( "EMTree: Expected branch jetVeto30Eta3 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3")
        else:
            self.jetVeto30Eta3_branch.SetAddress(<void*>&self.jetVeto30Eta3_value)

        #print "making jetVeto30Eta3_JetEnDown"
        self.jetVeto30Eta3_JetEnDown_branch = the_tree.GetBranch("jetVeto30Eta3_JetEnDown")
        #if not self.jetVeto30Eta3_JetEnDown_branch and "jetVeto30Eta3_JetEnDown" not in self.complained:
        if not self.jetVeto30Eta3_JetEnDown_branch and "jetVeto30Eta3_JetEnDown":
            warnings.warn( "EMTree: Expected branch jetVeto30Eta3_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3_JetEnDown")
        else:
            self.jetVeto30Eta3_JetEnDown_branch.SetAddress(<void*>&self.jetVeto30Eta3_JetEnDown_value)

        #print "making jetVeto30Eta3_JetEnUp"
        self.jetVeto30Eta3_JetEnUp_branch = the_tree.GetBranch("jetVeto30Eta3_JetEnUp")
        #if not self.jetVeto30Eta3_JetEnUp_branch and "jetVeto30Eta3_JetEnUp" not in self.complained:
        if not self.jetVeto30Eta3_JetEnUp_branch and "jetVeto30Eta3_JetEnUp":
            warnings.warn( "EMTree: Expected branch jetVeto30Eta3_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30Eta3_JetEnUp")
        else:
            self.jetVeto30Eta3_JetEnUp_branch.SetAddress(<void*>&self.jetVeto30Eta3_JetEnUp_value)

        #print "making jetVeto30_DR05"
        self.jetVeto30_DR05_branch = the_tree.GetBranch("jetVeto30_DR05")
        #if not self.jetVeto30_DR05_branch and "jetVeto30_DR05" not in self.complained:
        if not self.jetVeto30_DR05_branch and "jetVeto30_DR05":
            warnings.warn( "EMTree: Expected branch jetVeto30_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_DR05")
        else:
            self.jetVeto30_DR05_branch.SetAddress(<void*>&self.jetVeto30_DR05_value)

        #print "making jetVeto30_JetEnDown"
        self.jetVeto30_JetEnDown_branch = the_tree.GetBranch("jetVeto30_JetEnDown")
        #if not self.jetVeto30_JetEnDown_branch and "jetVeto30_JetEnDown" not in self.complained:
        if not self.jetVeto30_JetEnDown_branch and "jetVeto30_JetEnDown":
            warnings.warn( "EMTree: Expected branch jetVeto30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_JetEnDown")
        else:
            self.jetVeto30_JetEnDown_branch.SetAddress(<void*>&self.jetVeto30_JetEnDown_value)

        #print "making jetVeto30_JetEnUp"
        self.jetVeto30_JetEnUp_branch = the_tree.GetBranch("jetVeto30_JetEnUp")
        #if not self.jetVeto30_JetEnUp_branch and "jetVeto30_JetEnUp" not in self.complained:
        if not self.jetVeto30_JetEnUp_branch and "jetVeto30_JetEnUp":
            warnings.warn( "EMTree: Expected branch jetVeto30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto30_JetEnUp")
        else:
            self.jetVeto30_JetEnUp_branch.SetAddress(<void*>&self.jetVeto30_JetEnUp_value)

        #print "making jetVeto40"
        self.jetVeto40_branch = the_tree.GetBranch("jetVeto40")
        #if not self.jetVeto40_branch and "jetVeto40" not in self.complained:
        if not self.jetVeto40_branch and "jetVeto40":
            warnings.warn( "EMTree: Expected branch jetVeto40 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto40")
        else:
            self.jetVeto40_branch.SetAddress(<void*>&self.jetVeto40_value)

        #print "making jetVeto40_DR05"
        self.jetVeto40_DR05_branch = the_tree.GetBranch("jetVeto40_DR05")
        #if not self.jetVeto40_DR05_branch and "jetVeto40_DR05" not in self.complained:
        if not self.jetVeto40_DR05_branch and "jetVeto40_DR05":
            warnings.warn( "EMTree: Expected branch jetVeto40_DR05 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("jetVeto40_DR05")
        else:
            self.jetVeto40_DR05_branch.SetAddress(<void*>&self.jetVeto40_DR05_value)

        #print "making lumi"
        self.lumi_branch = the_tree.GetBranch("lumi")
        #if not self.lumi_branch and "lumi" not in self.complained:
        if not self.lumi_branch and "lumi":
            warnings.warn( "EMTree: Expected branch lumi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("lumi")
        else:
            self.lumi_branch.SetAddress(<void*>&self.lumi_value)

        #print "making mAbsEta"
        self.mAbsEta_branch = the_tree.GetBranch("mAbsEta")
        #if not self.mAbsEta_branch and "mAbsEta" not in self.complained:
        if not self.mAbsEta_branch and "mAbsEta":
            warnings.warn( "EMTree: Expected branch mAbsEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mAbsEta")
        else:
            self.mAbsEta_branch.SetAddress(<void*>&self.mAbsEta_value)

        #print "making mBestTrackType"
        self.mBestTrackType_branch = the_tree.GetBranch("mBestTrackType")
        #if not self.mBestTrackType_branch and "mBestTrackType" not in self.complained:
        if not self.mBestTrackType_branch and "mBestTrackType":
            warnings.warn( "EMTree: Expected branch mBestTrackType does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mBestTrackType")
        else:
            self.mBestTrackType_branch.SetAddress(<void*>&self.mBestTrackType_value)

        #print "making mCharge"
        self.mCharge_branch = the_tree.GetBranch("mCharge")
        #if not self.mCharge_branch and "mCharge" not in self.complained:
        if not self.mCharge_branch and "mCharge":
            warnings.warn( "EMTree: Expected branch mCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mCharge")
        else:
            self.mCharge_branch.SetAddress(<void*>&self.mCharge_value)

        #print "making mComesFromHiggs"
        self.mComesFromHiggs_branch = the_tree.GetBranch("mComesFromHiggs")
        #if not self.mComesFromHiggs_branch and "mComesFromHiggs" not in self.complained:
        if not self.mComesFromHiggs_branch and "mComesFromHiggs":
            warnings.warn( "EMTree: Expected branch mComesFromHiggs does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mComesFromHiggs")
        else:
            self.mComesFromHiggs_branch.SetAddress(<void*>&self.mComesFromHiggs_value)

        #print "making mDPhiToPfMet_ElectronEnDown"
        self.mDPhiToPfMet_ElectronEnDown_branch = the_tree.GetBranch("mDPhiToPfMet_ElectronEnDown")
        #if not self.mDPhiToPfMet_ElectronEnDown_branch and "mDPhiToPfMet_ElectronEnDown" not in self.complained:
        if not self.mDPhiToPfMet_ElectronEnDown_branch and "mDPhiToPfMet_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_ElectronEnDown")
        else:
            self.mDPhiToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.mDPhiToPfMet_ElectronEnDown_value)

        #print "making mDPhiToPfMet_ElectronEnUp"
        self.mDPhiToPfMet_ElectronEnUp_branch = the_tree.GetBranch("mDPhiToPfMet_ElectronEnUp")
        #if not self.mDPhiToPfMet_ElectronEnUp_branch and "mDPhiToPfMet_ElectronEnUp" not in self.complained:
        if not self.mDPhiToPfMet_ElectronEnUp_branch and "mDPhiToPfMet_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_ElectronEnUp")
        else:
            self.mDPhiToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.mDPhiToPfMet_ElectronEnUp_value)

        #print "making mDPhiToPfMet_JetEnDown"
        self.mDPhiToPfMet_JetEnDown_branch = the_tree.GetBranch("mDPhiToPfMet_JetEnDown")
        #if not self.mDPhiToPfMet_JetEnDown_branch and "mDPhiToPfMet_JetEnDown" not in self.complained:
        if not self.mDPhiToPfMet_JetEnDown_branch and "mDPhiToPfMet_JetEnDown":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_JetEnDown")
        else:
            self.mDPhiToPfMet_JetEnDown_branch.SetAddress(<void*>&self.mDPhiToPfMet_JetEnDown_value)

        #print "making mDPhiToPfMet_JetEnUp"
        self.mDPhiToPfMet_JetEnUp_branch = the_tree.GetBranch("mDPhiToPfMet_JetEnUp")
        #if not self.mDPhiToPfMet_JetEnUp_branch and "mDPhiToPfMet_JetEnUp" not in self.complained:
        if not self.mDPhiToPfMet_JetEnUp_branch and "mDPhiToPfMet_JetEnUp":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_JetEnUp")
        else:
            self.mDPhiToPfMet_JetEnUp_branch.SetAddress(<void*>&self.mDPhiToPfMet_JetEnUp_value)

        #print "making mDPhiToPfMet_JetResDown"
        self.mDPhiToPfMet_JetResDown_branch = the_tree.GetBranch("mDPhiToPfMet_JetResDown")
        #if not self.mDPhiToPfMet_JetResDown_branch and "mDPhiToPfMet_JetResDown" not in self.complained:
        if not self.mDPhiToPfMet_JetResDown_branch and "mDPhiToPfMet_JetResDown":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_JetResDown")
        else:
            self.mDPhiToPfMet_JetResDown_branch.SetAddress(<void*>&self.mDPhiToPfMet_JetResDown_value)

        #print "making mDPhiToPfMet_JetResUp"
        self.mDPhiToPfMet_JetResUp_branch = the_tree.GetBranch("mDPhiToPfMet_JetResUp")
        #if not self.mDPhiToPfMet_JetResUp_branch and "mDPhiToPfMet_JetResUp" not in self.complained:
        if not self.mDPhiToPfMet_JetResUp_branch and "mDPhiToPfMet_JetResUp":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_JetResUp")
        else:
            self.mDPhiToPfMet_JetResUp_branch.SetAddress(<void*>&self.mDPhiToPfMet_JetResUp_value)

        #print "making mDPhiToPfMet_MuonEnDown"
        self.mDPhiToPfMet_MuonEnDown_branch = the_tree.GetBranch("mDPhiToPfMet_MuonEnDown")
        #if not self.mDPhiToPfMet_MuonEnDown_branch and "mDPhiToPfMet_MuonEnDown" not in self.complained:
        if not self.mDPhiToPfMet_MuonEnDown_branch and "mDPhiToPfMet_MuonEnDown":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_MuonEnDown")
        else:
            self.mDPhiToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.mDPhiToPfMet_MuonEnDown_value)

        #print "making mDPhiToPfMet_MuonEnUp"
        self.mDPhiToPfMet_MuonEnUp_branch = the_tree.GetBranch("mDPhiToPfMet_MuonEnUp")
        #if not self.mDPhiToPfMet_MuonEnUp_branch and "mDPhiToPfMet_MuonEnUp" not in self.complained:
        if not self.mDPhiToPfMet_MuonEnUp_branch and "mDPhiToPfMet_MuonEnUp":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_MuonEnUp")
        else:
            self.mDPhiToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.mDPhiToPfMet_MuonEnUp_value)

        #print "making mDPhiToPfMet_PhotonEnDown"
        self.mDPhiToPfMet_PhotonEnDown_branch = the_tree.GetBranch("mDPhiToPfMet_PhotonEnDown")
        #if not self.mDPhiToPfMet_PhotonEnDown_branch and "mDPhiToPfMet_PhotonEnDown" not in self.complained:
        if not self.mDPhiToPfMet_PhotonEnDown_branch and "mDPhiToPfMet_PhotonEnDown":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_PhotonEnDown")
        else:
            self.mDPhiToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.mDPhiToPfMet_PhotonEnDown_value)

        #print "making mDPhiToPfMet_PhotonEnUp"
        self.mDPhiToPfMet_PhotonEnUp_branch = the_tree.GetBranch("mDPhiToPfMet_PhotonEnUp")
        #if not self.mDPhiToPfMet_PhotonEnUp_branch and "mDPhiToPfMet_PhotonEnUp" not in self.complained:
        if not self.mDPhiToPfMet_PhotonEnUp_branch and "mDPhiToPfMet_PhotonEnUp":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_PhotonEnUp")
        else:
            self.mDPhiToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.mDPhiToPfMet_PhotonEnUp_value)

        #print "making mDPhiToPfMet_TauEnDown"
        self.mDPhiToPfMet_TauEnDown_branch = the_tree.GetBranch("mDPhiToPfMet_TauEnDown")
        #if not self.mDPhiToPfMet_TauEnDown_branch and "mDPhiToPfMet_TauEnDown" not in self.complained:
        if not self.mDPhiToPfMet_TauEnDown_branch and "mDPhiToPfMet_TauEnDown":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_TauEnDown")
        else:
            self.mDPhiToPfMet_TauEnDown_branch.SetAddress(<void*>&self.mDPhiToPfMet_TauEnDown_value)

        #print "making mDPhiToPfMet_TauEnUp"
        self.mDPhiToPfMet_TauEnUp_branch = the_tree.GetBranch("mDPhiToPfMet_TauEnUp")
        #if not self.mDPhiToPfMet_TauEnUp_branch and "mDPhiToPfMet_TauEnUp" not in self.complained:
        if not self.mDPhiToPfMet_TauEnUp_branch and "mDPhiToPfMet_TauEnUp":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_TauEnUp")
        else:
            self.mDPhiToPfMet_TauEnUp_branch.SetAddress(<void*>&self.mDPhiToPfMet_TauEnUp_value)

        #print "making mDPhiToPfMet_UnclusteredEnDown"
        self.mDPhiToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("mDPhiToPfMet_UnclusteredEnDown")
        #if not self.mDPhiToPfMet_UnclusteredEnDown_branch and "mDPhiToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.mDPhiToPfMet_UnclusteredEnDown_branch and "mDPhiToPfMet_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_UnclusteredEnDown")
        else:
            self.mDPhiToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.mDPhiToPfMet_UnclusteredEnDown_value)

        #print "making mDPhiToPfMet_UnclusteredEnUp"
        self.mDPhiToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("mDPhiToPfMet_UnclusteredEnUp")
        #if not self.mDPhiToPfMet_UnclusteredEnUp_branch and "mDPhiToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.mDPhiToPfMet_UnclusteredEnUp_branch and "mDPhiToPfMet_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_UnclusteredEnUp")
        else:
            self.mDPhiToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.mDPhiToPfMet_UnclusteredEnUp_value)

        #print "making mDPhiToPfMet_type1"
        self.mDPhiToPfMet_type1_branch = the_tree.GetBranch("mDPhiToPfMet_type1")
        #if not self.mDPhiToPfMet_type1_branch and "mDPhiToPfMet_type1" not in self.complained:
        if not self.mDPhiToPfMet_type1_branch and "mDPhiToPfMet_type1":
            warnings.warn( "EMTree: Expected branch mDPhiToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mDPhiToPfMet_type1")
        else:
            self.mDPhiToPfMet_type1_branch.SetAddress(<void*>&self.mDPhiToPfMet_type1_value)

        #print "making mEcalIsoDR03"
        self.mEcalIsoDR03_branch = the_tree.GetBranch("mEcalIsoDR03")
        #if not self.mEcalIsoDR03_branch and "mEcalIsoDR03" not in self.complained:
        if not self.mEcalIsoDR03_branch and "mEcalIsoDR03":
            warnings.warn( "EMTree: Expected branch mEcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mEcalIsoDR03")
        else:
            self.mEcalIsoDR03_branch.SetAddress(<void*>&self.mEcalIsoDR03_value)

        #print "making mEffectiveArea2011"
        self.mEffectiveArea2011_branch = the_tree.GetBranch("mEffectiveArea2011")
        #if not self.mEffectiveArea2011_branch and "mEffectiveArea2011" not in self.complained:
        if not self.mEffectiveArea2011_branch and "mEffectiveArea2011":
            warnings.warn( "EMTree: Expected branch mEffectiveArea2011 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mEffectiveArea2011")
        else:
            self.mEffectiveArea2011_branch.SetAddress(<void*>&self.mEffectiveArea2011_value)

        #print "making mEffectiveArea2012"
        self.mEffectiveArea2012_branch = the_tree.GetBranch("mEffectiveArea2012")
        #if not self.mEffectiveArea2012_branch and "mEffectiveArea2012" not in self.complained:
        if not self.mEffectiveArea2012_branch and "mEffectiveArea2012":
            warnings.warn( "EMTree: Expected branch mEffectiveArea2012 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mEffectiveArea2012")
        else:
            self.mEffectiveArea2012_branch.SetAddress(<void*>&self.mEffectiveArea2012_value)

        #print "making mEta"
        self.mEta_branch = the_tree.GetBranch("mEta")
        #if not self.mEta_branch and "mEta" not in self.complained:
        if not self.mEta_branch and "mEta":
            warnings.warn( "EMTree: Expected branch mEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mEta")
        else:
            self.mEta_branch.SetAddress(<void*>&self.mEta_value)

        #print "making mEta_MuonEnDown"
        self.mEta_MuonEnDown_branch = the_tree.GetBranch("mEta_MuonEnDown")
        #if not self.mEta_MuonEnDown_branch and "mEta_MuonEnDown" not in self.complained:
        if not self.mEta_MuonEnDown_branch and "mEta_MuonEnDown":
            warnings.warn( "EMTree: Expected branch mEta_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mEta_MuonEnDown")
        else:
            self.mEta_MuonEnDown_branch.SetAddress(<void*>&self.mEta_MuonEnDown_value)

        #print "making mEta_MuonEnUp"
        self.mEta_MuonEnUp_branch = the_tree.GetBranch("mEta_MuonEnUp")
        #if not self.mEta_MuonEnUp_branch and "mEta_MuonEnUp" not in self.complained:
        if not self.mEta_MuonEnUp_branch and "mEta_MuonEnUp":
            warnings.warn( "EMTree: Expected branch mEta_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mEta_MuonEnUp")
        else:
            self.mEta_MuonEnUp_branch.SetAddress(<void*>&self.mEta_MuonEnUp_value)

        #print "making mGenCharge"
        self.mGenCharge_branch = the_tree.GetBranch("mGenCharge")
        #if not self.mGenCharge_branch and "mGenCharge" not in self.complained:
        if not self.mGenCharge_branch and "mGenCharge":
            warnings.warn( "EMTree: Expected branch mGenCharge does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenCharge")
        else:
            self.mGenCharge_branch.SetAddress(<void*>&self.mGenCharge_value)

        #print "making mGenEnergy"
        self.mGenEnergy_branch = the_tree.GetBranch("mGenEnergy")
        #if not self.mGenEnergy_branch and "mGenEnergy" not in self.complained:
        if not self.mGenEnergy_branch and "mGenEnergy":
            warnings.warn( "EMTree: Expected branch mGenEnergy does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenEnergy")
        else:
            self.mGenEnergy_branch.SetAddress(<void*>&self.mGenEnergy_value)

        #print "making mGenEta"
        self.mGenEta_branch = the_tree.GetBranch("mGenEta")
        #if not self.mGenEta_branch and "mGenEta" not in self.complained:
        if not self.mGenEta_branch and "mGenEta":
            warnings.warn( "EMTree: Expected branch mGenEta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenEta")
        else:
            self.mGenEta_branch.SetAddress(<void*>&self.mGenEta_value)

        #print "making mGenMotherPdgId"
        self.mGenMotherPdgId_branch = the_tree.GetBranch("mGenMotherPdgId")
        #if not self.mGenMotherPdgId_branch and "mGenMotherPdgId" not in self.complained:
        if not self.mGenMotherPdgId_branch and "mGenMotherPdgId":
            warnings.warn( "EMTree: Expected branch mGenMotherPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenMotherPdgId")
        else:
            self.mGenMotherPdgId_branch.SetAddress(<void*>&self.mGenMotherPdgId_value)

        #print "making mGenParticle"
        self.mGenParticle_branch = the_tree.GetBranch("mGenParticle")
        #if not self.mGenParticle_branch and "mGenParticle" not in self.complained:
        if not self.mGenParticle_branch and "mGenParticle":
            warnings.warn( "EMTree: Expected branch mGenParticle does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenParticle")
        else:
            self.mGenParticle_branch.SetAddress(<void*>&self.mGenParticle_value)

        #print "making mGenPdgId"
        self.mGenPdgId_branch = the_tree.GetBranch("mGenPdgId")
        #if not self.mGenPdgId_branch and "mGenPdgId" not in self.complained:
        if not self.mGenPdgId_branch and "mGenPdgId":
            warnings.warn( "EMTree: Expected branch mGenPdgId does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenPdgId")
        else:
            self.mGenPdgId_branch.SetAddress(<void*>&self.mGenPdgId_value)

        #print "making mGenPhi"
        self.mGenPhi_branch = the_tree.GetBranch("mGenPhi")
        #if not self.mGenPhi_branch and "mGenPhi" not in self.complained:
        if not self.mGenPhi_branch and "mGenPhi":
            warnings.warn( "EMTree: Expected branch mGenPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenPhi")
        else:
            self.mGenPhi_branch.SetAddress(<void*>&self.mGenPhi_value)

        #print "making mGenPrompt"
        self.mGenPrompt_branch = the_tree.GetBranch("mGenPrompt")
        #if not self.mGenPrompt_branch and "mGenPrompt" not in self.complained:
        if not self.mGenPrompt_branch and "mGenPrompt":
            warnings.warn( "EMTree: Expected branch mGenPrompt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenPrompt")
        else:
            self.mGenPrompt_branch.SetAddress(<void*>&self.mGenPrompt_value)

        #print "making mGenPromptTauDecay"
        self.mGenPromptTauDecay_branch = the_tree.GetBranch("mGenPromptTauDecay")
        #if not self.mGenPromptTauDecay_branch and "mGenPromptTauDecay" not in self.complained:
        if not self.mGenPromptTauDecay_branch and "mGenPromptTauDecay":
            warnings.warn( "EMTree: Expected branch mGenPromptTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenPromptTauDecay")
        else:
            self.mGenPromptTauDecay_branch.SetAddress(<void*>&self.mGenPromptTauDecay_value)

        #print "making mGenPt"
        self.mGenPt_branch = the_tree.GetBranch("mGenPt")
        #if not self.mGenPt_branch and "mGenPt" not in self.complained:
        if not self.mGenPt_branch and "mGenPt":
            warnings.warn( "EMTree: Expected branch mGenPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenPt")
        else:
            self.mGenPt_branch.SetAddress(<void*>&self.mGenPt_value)

        #print "making mGenTauDecay"
        self.mGenTauDecay_branch = the_tree.GetBranch("mGenTauDecay")
        #if not self.mGenTauDecay_branch and "mGenTauDecay" not in self.complained:
        if not self.mGenTauDecay_branch and "mGenTauDecay":
            warnings.warn( "EMTree: Expected branch mGenTauDecay does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenTauDecay")
        else:
            self.mGenTauDecay_branch.SetAddress(<void*>&self.mGenTauDecay_value)

        #print "making mGenVZ"
        self.mGenVZ_branch = the_tree.GetBranch("mGenVZ")
        #if not self.mGenVZ_branch and "mGenVZ" not in self.complained:
        if not self.mGenVZ_branch and "mGenVZ":
            warnings.warn( "EMTree: Expected branch mGenVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenVZ")
        else:
            self.mGenVZ_branch.SetAddress(<void*>&self.mGenVZ_value)

        #print "making mGenVtxPVMatch"
        self.mGenVtxPVMatch_branch = the_tree.GetBranch("mGenVtxPVMatch")
        #if not self.mGenVtxPVMatch_branch and "mGenVtxPVMatch" not in self.complained:
        if not self.mGenVtxPVMatch_branch and "mGenVtxPVMatch":
            warnings.warn( "EMTree: Expected branch mGenVtxPVMatch does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mGenVtxPVMatch")
        else:
            self.mGenVtxPVMatch_branch.SetAddress(<void*>&self.mGenVtxPVMatch_value)

        #print "making mHcalIsoDR03"
        self.mHcalIsoDR03_branch = the_tree.GetBranch("mHcalIsoDR03")
        #if not self.mHcalIsoDR03_branch and "mHcalIsoDR03" not in self.complained:
        if not self.mHcalIsoDR03_branch and "mHcalIsoDR03":
            warnings.warn( "EMTree: Expected branch mHcalIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mHcalIsoDR03")
        else:
            self.mHcalIsoDR03_branch.SetAddress(<void*>&self.mHcalIsoDR03_value)

        #print "making mIP3D"
        self.mIP3D_branch = the_tree.GetBranch("mIP3D")
        #if not self.mIP3D_branch and "mIP3D" not in self.complained:
        if not self.mIP3D_branch and "mIP3D":
            warnings.warn( "EMTree: Expected branch mIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mIP3D")
        else:
            self.mIP3D_branch.SetAddress(<void*>&self.mIP3D_value)

        #print "making mIP3DErr"
        self.mIP3DErr_branch = the_tree.GetBranch("mIP3DErr")
        #if not self.mIP3DErr_branch and "mIP3DErr" not in self.complained:
        if not self.mIP3DErr_branch and "mIP3DErr":
            warnings.warn( "EMTree: Expected branch mIP3DErr does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mIP3DErr")
        else:
            self.mIP3DErr_branch.SetAddress(<void*>&self.mIP3DErr_value)

        #print "making mIsGlobal"
        self.mIsGlobal_branch = the_tree.GetBranch("mIsGlobal")
        #if not self.mIsGlobal_branch and "mIsGlobal" not in self.complained:
        if not self.mIsGlobal_branch and "mIsGlobal":
            warnings.warn( "EMTree: Expected branch mIsGlobal does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mIsGlobal")
        else:
            self.mIsGlobal_branch.SetAddress(<void*>&self.mIsGlobal_value)

        #print "making mIsPFMuon"
        self.mIsPFMuon_branch = the_tree.GetBranch("mIsPFMuon")
        #if not self.mIsPFMuon_branch and "mIsPFMuon" not in self.complained:
        if not self.mIsPFMuon_branch and "mIsPFMuon":
            warnings.warn( "EMTree: Expected branch mIsPFMuon does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mIsPFMuon")
        else:
            self.mIsPFMuon_branch.SetAddress(<void*>&self.mIsPFMuon_value)

        #print "making mIsTracker"
        self.mIsTracker_branch = the_tree.GetBranch("mIsTracker")
        #if not self.mIsTracker_branch and "mIsTracker" not in self.complained:
        if not self.mIsTracker_branch and "mIsTracker":
            warnings.warn( "EMTree: Expected branch mIsTracker does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mIsTracker")
        else:
            self.mIsTracker_branch.SetAddress(<void*>&self.mIsTracker_value)

        #print "making mJetArea"
        self.mJetArea_branch = the_tree.GetBranch("mJetArea")
        #if not self.mJetArea_branch and "mJetArea" not in self.complained:
        if not self.mJetArea_branch and "mJetArea":
            warnings.warn( "EMTree: Expected branch mJetArea does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetArea")
        else:
            self.mJetArea_branch.SetAddress(<void*>&self.mJetArea_value)

        #print "making mJetBtag"
        self.mJetBtag_branch = the_tree.GetBranch("mJetBtag")
        #if not self.mJetBtag_branch and "mJetBtag" not in self.complained:
        if not self.mJetBtag_branch and "mJetBtag":
            warnings.warn( "EMTree: Expected branch mJetBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetBtag")
        else:
            self.mJetBtag_branch.SetAddress(<void*>&self.mJetBtag_value)

        #print "making mJetEtaEtaMoment"
        self.mJetEtaEtaMoment_branch = the_tree.GetBranch("mJetEtaEtaMoment")
        #if not self.mJetEtaEtaMoment_branch and "mJetEtaEtaMoment" not in self.complained:
        if not self.mJetEtaEtaMoment_branch and "mJetEtaEtaMoment":
            warnings.warn( "EMTree: Expected branch mJetEtaEtaMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetEtaEtaMoment")
        else:
            self.mJetEtaEtaMoment_branch.SetAddress(<void*>&self.mJetEtaEtaMoment_value)

        #print "making mJetEtaPhiMoment"
        self.mJetEtaPhiMoment_branch = the_tree.GetBranch("mJetEtaPhiMoment")
        #if not self.mJetEtaPhiMoment_branch and "mJetEtaPhiMoment" not in self.complained:
        if not self.mJetEtaPhiMoment_branch and "mJetEtaPhiMoment":
            warnings.warn( "EMTree: Expected branch mJetEtaPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetEtaPhiMoment")
        else:
            self.mJetEtaPhiMoment_branch.SetAddress(<void*>&self.mJetEtaPhiMoment_value)

        #print "making mJetEtaPhiSpread"
        self.mJetEtaPhiSpread_branch = the_tree.GetBranch("mJetEtaPhiSpread")
        #if not self.mJetEtaPhiSpread_branch and "mJetEtaPhiSpread" not in self.complained:
        if not self.mJetEtaPhiSpread_branch and "mJetEtaPhiSpread":
            warnings.warn( "EMTree: Expected branch mJetEtaPhiSpread does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetEtaPhiSpread")
        else:
            self.mJetEtaPhiSpread_branch.SetAddress(<void*>&self.mJetEtaPhiSpread_value)

        #print "making mJetPFCISVBtag"
        self.mJetPFCISVBtag_branch = the_tree.GetBranch("mJetPFCISVBtag")
        #if not self.mJetPFCISVBtag_branch and "mJetPFCISVBtag" not in self.complained:
        if not self.mJetPFCISVBtag_branch and "mJetPFCISVBtag":
            warnings.warn( "EMTree: Expected branch mJetPFCISVBtag does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetPFCISVBtag")
        else:
            self.mJetPFCISVBtag_branch.SetAddress(<void*>&self.mJetPFCISVBtag_value)

        #print "making mJetPartonFlavour"
        self.mJetPartonFlavour_branch = the_tree.GetBranch("mJetPartonFlavour")
        #if not self.mJetPartonFlavour_branch and "mJetPartonFlavour" not in self.complained:
        if not self.mJetPartonFlavour_branch and "mJetPartonFlavour":
            warnings.warn( "EMTree: Expected branch mJetPartonFlavour does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetPartonFlavour")
        else:
            self.mJetPartonFlavour_branch.SetAddress(<void*>&self.mJetPartonFlavour_value)

        #print "making mJetPhiPhiMoment"
        self.mJetPhiPhiMoment_branch = the_tree.GetBranch("mJetPhiPhiMoment")
        #if not self.mJetPhiPhiMoment_branch and "mJetPhiPhiMoment" not in self.complained:
        if not self.mJetPhiPhiMoment_branch and "mJetPhiPhiMoment":
            warnings.warn( "EMTree: Expected branch mJetPhiPhiMoment does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetPhiPhiMoment")
        else:
            self.mJetPhiPhiMoment_branch.SetAddress(<void*>&self.mJetPhiPhiMoment_value)

        #print "making mJetPt"
        self.mJetPt_branch = the_tree.GetBranch("mJetPt")
        #if not self.mJetPt_branch and "mJetPt" not in self.complained:
        if not self.mJetPt_branch and "mJetPt":
            warnings.warn( "EMTree: Expected branch mJetPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mJetPt")
        else:
            self.mJetPt_branch.SetAddress(<void*>&self.mJetPt_value)

        #print "making mLowestMll"
        self.mLowestMll_branch = the_tree.GetBranch("mLowestMll")
        #if not self.mLowestMll_branch and "mLowestMll" not in self.complained:
        if not self.mLowestMll_branch and "mLowestMll":
            warnings.warn( "EMTree: Expected branch mLowestMll does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mLowestMll")
        else:
            self.mLowestMll_branch.SetAddress(<void*>&self.mLowestMll_value)

        #print "making mMass"
        self.mMass_branch = the_tree.GetBranch("mMass")
        #if not self.mMass_branch and "mMass" not in self.complained:
        if not self.mMass_branch and "mMass":
            warnings.warn( "EMTree: Expected branch mMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMass")
        else:
            self.mMass_branch.SetAddress(<void*>&self.mMass_value)

        #print "making mMatchedStations"
        self.mMatchedStations_branch = the_tree.GetBranch("mMatchedStations")
        #if not self.mMatchedStations_branch and "mMatchedStations" not in self.complained:
        if not self.mMatchedStations_branch and "mMatchedStations":
            warnings.warn( "EMTree: Expected branch mMatchedStations does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchedStations")
        else:
            self.mMatchedStations_branch.SetAddress(<void*>&self.mMatchedStations_value)

        #print "making mMatchesDoubleESingleMu"
        self.mMatchesDoubleESingleMu_branch = the_tree.GetBranch("mMatchesDoubleESingleMu")
        #if not self.mMatchesDoubleESingleMu_branch and "mMatchesDoubleESingleMu" not in self.complained:
        if not self.mMatchesDoubleESingleMu_branch and "mMatchesDoubleESingleMu":
            warnings.warn( "EMTree: Expected branch mMatchesDoubleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesDoubleESingleMu")
        else:
            self.mMatchesDoubleESingleMu_branch.SetAddress(<void*>&self.mMatchesDoubleESingleMu_value)

        #print "making mMatchesDoubleMu"
        self.mMatchesDoubleMu_branch = the_tree.GetBranch("mMatchesDoubleMu")
        #if not self.mMatchesDoubleMu_branch and "mMatchesDoubleMu" not in self.complained:
        if not self.mMatchesDoubleMu_branch and "mMatchesDoubleMu":
            warnings.warn( "EMTree: Expected branch mMatchesDoubleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesDoubleMu")
        else:
            self.mMatchesDoubleMu_branch.SetAddress(<void*>&self.mMatchesDoubleMu_value)

        #print "making mMatchesDoubleMuSingleE"
        self.mMatchesDoubleMuSingleE_branch = the_tree.GetBranch("mMatchesDoubleMuSingleE")
        #if not self.mMatchesDoubleMuSingleE_branch and "mMatchesDoubleMuSingleE" not in self.complained:
        if not self.mMatchesDoubleMuSingleE_branch and "mMatchesDoubleMuSingleE":
            warnings.warn( "EMTree: Expected branch mMatchesDoubleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesDoubleMuSingleE")
        else:
            self.mMatchesDoubleMuSingleE_branch.SetAddress(<void*>&self.mMatchesDoubleMuSingleE_value)

        #print "making mMatchesSingleESingleMu"
        self.mMatchesSingleESingleMu_branch = the_tree.GetBranch("mMatchesSingleESingleMu")
        #if not self.mMatchesSingleESingleMu_branch and "mMatchesSingleESingleMu" not in self.complained:
        if not self.mMatchesSingleESingleMu_branch and "mMatchesSingleESingleMu":
            warnings.warn( "EMTree: Expected branch mMatchesSingleESingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleESingleMu")
        else:
            self.mMatchesSingleESingleMu_branch.SetAddress(<void*>&self.mMatchesSingleESingleMu_value)

        #print "making mMatchesSingleMu"
        self.mMatchesSingleMu_branch = the_tree.GetBranch("mMatchesSingleMu")
        #if not self.mMatchesSingleMu_branch and "mMatchesSingleMu" not in self.complained:
        if not self.mMatchesSingleMu_branch and "mMatchesSingleMu":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMu")
        else:
            self.mMatchesSingleMu_branch.SetAddress(<void*>&self.mMatchesSingleMu_value)

        #print "making mMatchesSingleMuIso20"
        self.mMatchesSingleMuIso20_branch = the_tree.GetBranch("mMatchesSingleMuIso20")
        #if not self.mMatchesSingleMuIso20_branch and "mMatchesSingleMuIso20" not in self.complained:
        if not self.mMatchesSingleMuIso20_branch and "mMatchesSingleMuIso20":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMuIso20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMuIso20")
        else:
            self.mMatchesSingleMuIso20_branch.SetAddress(<void*>&self.mMatchesSingleMuIso20_value)

        #print "making mMatchesSingleMuIsoTk20"
        self.mMatchesSingleMuIsoTk20_branch = the_tree.GetBranch("mMatchesSingleMuIsoTk20")
        #if not self.mMatchesSingleMuIsoTk20_branch and "mMatchesSingleMuIsoTk20" not in self.complained:
        if not self.mMatchesSingleMuIsoTk20_branch and "mMatchesSingleMuIsoTk20":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMuIsoTk20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMuIsoTk20")
        else:
            self.mMatchesSingleMuIsoTk20_branch.SetAddress(<void*>&self.mMatchesSingleMuIsoTk20_value)

        #print "making mMatchesSingleMuSingleE"
        self.mMatchesSingleMuSingleE_branch = the_tree.GetBranch("mMatchesSingleMuSingleE")
        #if not self.mMatchesSingleMuSingleE_branch and "mMatchesSingleMuSingleE" not in self.complained:
        if not self.mMatchesSingleMuSingleE_branch and "mMatchesSingleMuSingleE":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMuSingleE does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMuSingleE")
        else:
            self.mMatchesSingleMuSingleE_branch.SetAddress(<void*>&self.mMatchesSingleMuSingleE_value)

        #print "making mMatchesSingleMu_leg1"
        self.mMatchesSingleMu_leg1_branch = the_tree.GetBranch("mMatchesSingleMu_leg1")
        #if not self.mMatchesSingleMu_leg1_branch and "mMatchesSingleMu_leg1" not in self.complained:
        if not self.mMatchesSingleMu_leg1_branch and "mMatchesSingleMu_leg1":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMu_leg1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMu_leg1")
        else:
            self.mMatchesSingleMu_leg1_branch.SetAddress(<void*>&self.mMatchesSingleMu_leg1_value)

        #print "making mMatchesSingleMu_leg1_noiso"
        self.mMatchesSingleMu_leg1_noiso_branch = the_tree.GetBranch("mMatchesSingleMu_leg1_noiso")
        #if not self.mMatchesSingleMu_leg1_noiso_branch and "mMatchesSingleMu_leg1_noiso" not in self.complained:
        if not self.mMatchesSingleMu_leg1_noiso_branch and "mMatchesSingleMu_leg1_noiso":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMu_leg1_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMu_leg1_noiso")
        else:
            self.mMatchesSingleMu_leg1_noiso_branch.SetAddress(<void*>&self.mMatchesSingleMu_leg1_noiso_value)

        #print "making mMatchesSingleMu_leg2"
        self.mMatchesSingleMu_leg2_branch = the_tree.GetBranch("mMatchesSingleMu_leg2")
        #if not self.mMatchesSingleMu_leg2_branch and "mMatchesSingleMu_leg2" not in self.complained:
        if not self.mMatchesSingleMu_leg2_branch and "mMatchesSingleMu_leg2":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMu_leg2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMu_leg2")
        else:
            self.mMatchesSingleMu_leg2_branch.SetAddress(<void*>&self.mMatchesSingleMu_leg2_value)

        #print "making mMatchesSingleMu_leg2_noiso"
        self.mMatchesSingleMu_leg2_noiso_branch = the_tree.GetBranch("mMatchesSingleMu_leg2_noiso")
        #if not self.mMatchesSingleMu_leg2_noiso_branch and "mMatchesSingleMu_leg2_noiso" not in self.complained:
        if not self.mMatchesSingleMu_leg2_noiso_branch and "mMatchesSingleMu_leg2_noiso":
            warnings.warn( "EMTree: Expected branch mMatchesSingleMu_leg2_noiso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesSingleMu_leg2_noiso")
        else:
            self.mMatchesSingleMu_leg2_noiso_branch.SetAddress(<void*>&self.mMatchesSingleMu_leg2_noiso_value)

        #print "making mMatchesTripleMu"
        self.mMatchesTripleMu_branch = the_tree.GetBranch("mMatchesTripleMu")
        #if not self.mMatchesTripleMu_branch and "mMatchesTripleMu" not in self.complained:
        if not self.mMatchesTripleMu_branch and "mMatchesTripleMu":
            warnings.warn( "EMTree: Expected branch mMatchesTripleMu does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMatchesTripleMu")
        else:
            self.mMatchesTripleMu_branch.SetAddress(<void*>&self.mMatchesTripleMu_value)

        #print "making mMtToPfMet_ElectronEnDown"
        self.mMtToPfMet_ElectronEnDown_branch = the_tree.GetBranch("mMtToPfMet_ElectronEnDown")
        #if not self.mMtToPfMet_ElectronEnDown_branch and "mMtToPfMet_ElectronEnDown" not in self.complained:
        if not self.mMtToPfMet_ElectronEnDown_branch and "mMtToPfMet_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_ElectronEnDown")
        else:
            self.mMtToPfMet_ElectronEnDown_branch.SetAddress(<void*>&self.mMtToPfMet_ElectronEnDown_value)

        #print "making mMtToPfMet_ElectronEnUp"
        self.mMtToPfMet_ElectronEnUp_branch = the_tree.GetBranch("mMtToPfMet_ElectronEnUp")
        #if not self.mMtToPfMet_ElectronEnUp_branch and "mMtToPfMet_ElectronEnUp" not in self.complained:
        if not self.mMtToPfMet_ElectronEnUp_branch and "mMtToPfMet_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_ElectronEnUp")
        else:
            self.mMtToPfMet_ElectronEnUp_branch.SetAddress(<void*>&self.mMtToPfMet_ElectronEnUp_value)

        #print "making mMtToPfMet_JetEnDown"
        self.mMtToPfMet_JetEnDown_branch = the_tree.GetBranch("mMtToPfMet_JetEnDown")
        #if not self.mMtToPfMet_JetEnDown_branch and "mMtToPfMet_JetEnDown" not in self.complained:
        if not self.mMtToPfMet_JetEnDown_branch and "mMtToPfMet_JetEnDown":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_JetEnDown")
        else:
            self.mMtToPfMet_JetEnDown_branch.SetAddress(<void*>&self.mMtToPfMet_JetEnDown_value)

        #print "making mMtToPfMet_JetEnUp"
        self.mMtToPfMet_JetEnUp_branch = the_tree.GetBranch("mMtToPfMet_JetEnUp")
        #if not self.mMtToPfMet_JetEnUp_branch and "mMtToPfMet_JetEnUp" not in self.complained:
        if not self.mMtToPfMet_JetEnUp_branch and "mMtToPfMet_JetEnUp":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_JetEnUp")
        else:
            self.mMtToPfMet_JetEnUp_branch.SetAddress(<void*>&self.mMtToPfMet_JetEnUp_value)

        #print "making mMtToPfMet_JetResDown"
        self.mMtToPfMet_JetResDown_branch = the_tree.GetBranch("mMtToPfMet_JetResDown")
        #if not self.mMtToPfMet_JetResDown_branch and "mMtToPfMet_JetResDown" not in self.complained:
        if not self.mMtToPfMet_JetResDown_branch and "mMtToPfMet_JetResDown":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_JetResDown")
        else:
            self.mMtToPfMet_JetResDown_branch.SetAddress(<void*>&self.mMtToPfMet_JetResDown_value)

        #print "making mMtToPfMet_JetResUp"
        self.mMtToPfMet_JetResUp_branch = the_tree.GetBranch("mMtToPfMet_JetResUp")
        #if not self.mMtToPfMet_JetResUp_branch and "mMtToPfMet_JetResUp" not in self.complained:
        if not self.mMtToPfMet_JetResUp_branch and "mMtToPfMet_JetResUp":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_JetResUp")
        else:
            self.mMtToPfMet_JetResUp_branch.SetAddress(<void*>&self.mMtToPfMet_JetResUp_value)

        #print "making mMtToPfMet_MuonEnDown"
        self.mMtToPfMet_MuonEnDown_branch = the_tree.GetBranch("mMtToPfMet_MuonEnDown")
        #if not self.mMtToPfMet_MuonEnDown_branch and "mMtToPfMet_MuonEnDown" not in self.complained:
        if not self.mMtToPfMet_MuonEnDown_branch and "mMtToPfMet_MuonEnDown":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_MuonEnDown")
        else:
            self.mMtToPfMet_MuonEnDown_branch.SetAddress(<void*>&self.mMtToPfMet_MuonEnDown_value)

        #print "making mMtToPfMet_MuonEnUp"
        self.mMtToPfMet_MuonEnUp_branch = the_tree.GetBranch("mMtToPfMet_MuonEnUp")
        #if not self.mMtToPfMet_MuonEnUp_branch and "mMtToPfMet_MuonEnUp" not in self.complained:
        if not self.mMtToPfMet_MuonEnUp_branch and "mMtToPfMet_MuonEnUp":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_MuonEnUp")
        else:
            self.mMtToPfMet_MuonEnUp_branch.SetAddress(<void*>&self.mMtToPfMet_MuonEnUp_value)

        #print "making mMtToPfMet_PhotonEnDown"
        self.mMtToPfMet_PhotonEnDown_branch = the_tree.GetBranch("mMtToPfMet_PhotonEnDown")
        #if not self.mMtToPfMet_PhotonEnDown_branch and "mMtToPfMet_PhotonEnDown" not in self.complained:
        if not self.mMtToPfMet_PhotonEnDown_branch and "mMtToPfMet_PhotonEnDown":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_PhotonEnDown")
        else:
            self.mMtToPfMet_PhotonEnDown_branch.SetAddress(<void*>&self.mMtToPfMet_PhotonEnDown_value)

        #print "making mMtToPfMet_PhotonEnUp"
        self.mMtToPfMet_PhotonEnUp_branch = the_tree.GetBranch("mMtToPfMet_PhotonEnUp")
        #if not self.mMtToPfMet_PhotonEnUp_branch and "mMtToPfMet_PhotonEnUp" not in self.complained:
        if not self.mMtToPfMet_PhotonEnUp_branch and "mMtToPfMet_PhotonEnUp":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_PhotonEnUp")
        else:
            self.mMtToPfMet_PhotonEnUp_branch.SetAddress(<void*>&self.mMtToPfMet_PhotonEnUp_value)

        #print "making mMtToPfMet_Raw"
        self.mMtToPfMet_Raw_branch = the_tree.GetBranch("mMtToPfMet_Raw")
        #if not self.mMtToPfMet_Raw_branch and "mMtToPfMet_Raw" not in self.complained:
        if not self.mMtToPfMet_Raw_branch and "mMtToPfMet_Raw":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_Raw does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_Raw")
        else:
            self.mMtToPfMet_Raw_branch.SetAddress(<void*>&self.mMtToPfMet_Raw_value)

        #print "making mMtToPfMet_TauEnDown"
        self.mMtToPfMet_TauEnDown_branch = the_tree.GetBranch("mMtToPfMet_TauEnDown")
        #if not self.mMtToPfMet_TauEnDown_branch and "mMtToPfMet_TauEnDown" not in self.complained:
        if not self.mMtToPfMet_TauEnDown_branch and "mMtToPfMet_TauEnDown":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_TauEnDown")
        else:
            self.mMtToPfMet_TauEnDown_branch.SetAddress(<void*>&self.mMtToPfMet_TauEnDown_value)

        #print "making mMtToPfMet_TauEnUp"
        self.mMtToPfMet_TauEnUp_branch = the_tree.GetBranch("mMtToPfMet_TauEnUp")
        #if not self.mMtToPfMet_TauEnUp_branch and "mMtToPfMet_TauEnUp" not in self.complained:
        if not self.mMtToPfMet_TauEnUp_branch and "mMtToPfMet_TauEnUp":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_TauEnUp")
        else:
            self.mMtToPfMet_TauEnUp_branch.SetAddress(<void*>&self.mMtToPfMet_TauEnUp_value)

        #print "making mMtToPfMet_UnclusteredEnDown"
        self.mMtToPfMet_UnclusteredEnDown_branch = the_tree.GetBranch("mMtToPfMet_UnclusteredEnDown")
        #if not self.mMtToPfMet_UnclusteredEnDown_branch and "mMtToPfMet_UnclusteredEnDown" not in self.complained:
        if not self.mMtToPfMet_UnclusteredEnDown_branch and "mMtToPfMet_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_UnclusteredEnDown")
        else:
            self.mMtToPfMet_UnclusteredEnDown_branch.SetAddress(<void*>&self.mMtToPfMet_UnclusteredEnDown_value)

        #print "making mMtToPfMet_UnclusteredEnUp"
        self.mMtToPfMet_UnclusteredEnUp_branch = the_tree.GetBranch("mMtToPfMet_UnclusteredEnUp")
        #if not self.mMtToPfMet_UnclusteredEnUp_branch and "mMtToPfMet_UnclusteredEnUp" not in self.complained:
        if not self.mMtToPfMet_UnclusteredEnUp_branch and "mMtToPfMet_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_UnclusteredEnUp")
        else:
            self.mMtToPfMet_UnclusteredEnUp_branch.SetAddress(<void*>&self.mMtToPfMet_UnclusteredEnUp_value)

        #print "making mMtToPfMet_type1"
        self.mMtToPfMet_type1_branch = the_tree.GetBranch("mMtToPfMet_type1")
        #if not self.mMtToPfMet_type1_branch and "mMtToPfMet_type1" not in self.complained:
        if not self.mMtToPfMet_type1_branch and "mMtToPfMet_type1":
            warnings.warn( "EMTree: Expected branch mMtToPfMet_type1 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMtToPfMet_type1")
        else:
            self.mMtToPfMet_type1_branch.SetAddress(<void*>&self.mMtToPfMet_type1_value)

        #print "making mMuonHits"
        self.mMuonHits_branch = the_tree.GetBranch("mMuonHits")
        #if not self.mMuonHits_branch and "mMuonHits" not in self.complained:
        if not self.mMuonHits_branch and "mMuonHits":
            warnings.warn( "EMTree: Expected branch mMuonHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mMuonHits")
        else:
            self.mMuonHits_branch.SetAddress(<void*>&self.mMuonHits_value)

        #print "making mNearestZMass"
        self.mNearestZMass_branch = the_tree.GetBranch("mNearestZMass")
        #if not self.mNearestZMass_branch and "mNearestZMass" not in self.complained:
        if not self.mNearestZMass_branch and "mNearestZMass":
            warnings.warn( "EMTree: Expected branch mNearestZMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mNearestZMass")
        else:
            self.mNearestZMass_branch.SetAddress(<void*>&self.mNearestZMass_value)

        #print "making mNormTrkChi2"
        self.mNormTrkChi2_branch = the_tree.GetBranch("mNormTrkChi2")
        #if not self.mNormTrkChi2_branch and "mNormTrkChi2" not in self.complained:
        if not self.mNormTrkChi2_branch and "mNormTrkChi2":
            warnings.warn( "EMTree: Expected branch mNormTrkChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mNormTrkChi2")
        else:
            self.mNormTrkChi2_branch.SetAddress(<void*>&self.mNormTrkChi2_value)

        #print "making mPFChargedHadronIsoR04"
        self.mPFChargedHadronIsoR04_branch = the_tree.GetBranch("mPFChargedHadronIsoR04")
        #if not self.mPFChargedHadronIsoR04_branch and "mPFChargedHadronIsoR04" not in self.complained:
        if not self.mPFChargedHadronIsoR04_branch and "mPFChargedHadronIsoR04":
            warnings.warn( "EMTree: Expected branch mPFChargedHadronIsoR04 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFChargedHadronIsoR04")
        else:
            self.mPFChargedHadronIsoR04_branch.SetAddress(<void*>&self.mPFChargedHadronIsoR04_value)

        #print "making mPFChargedIso"
        self.mPFChargedIso_branch = the_tree.GetBranch("mPFChargedIso")
        #if not self.mPFChargedIso_branch and "mPFChargedIso" not in self.complained:
        if not self.mPFChargedIso_branch and "mPFChargedIso":
            warnings.warn( "EMTree: Expected branch mPFChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFChargedIso")
        else:
            self.mPFChargedIso_branch.SetAddress(<void*>&self.mPFChargedIso_value)

        #print "making mPFIDLoose"
        self.mPFIDLoose_branch = the_tree.GetBranch("mPFIDLoose")
        #if not self.mPFIDLoose_branch and "mPFIDLoose" not in self.complained:
        if not self.mPFIDLoose_branch and "mPFIDLoose":
            warnings.warn( "EMTree: Expected branch mPFIDLoose does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFIDLoose")
        else:
            self.mPFIDLoose_branch.SetAddress(<void*>&self.mPFIDLoose_value)

        #print "making mPFIDMedium"
        self.mPFIDMedium_branch = the_tree.GetBranch("mPFIDMedium")
        #if not self.mPFIDMedium_branch and "mPFIDMedium" not in self.complained:
        if not self.mPFIDMedium_branch and "mPFIDMedium":
            warnings.warn( "EMTree: Expected branch mPFIDMedium does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFIDMedium")
        else:
            self.mPFIDMedium_branch.SetAddress(<void*>&self.mPFIDMedium_value)

        #print "making mPFIDTight"
        self.mPFIDTight_branch = the_tree.GetBranch("mPFIDTight")
        #if not self.mPFIDTight_branch and "mPFIDTight" not in self.complained:
        if not self.mPFIDTight_branch and "mPFIDTight":
            warnings.warn( "EMTree: Expected branch mPFIDTight does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFIDTight")
        else:
            self.mPFIDTight_branch.SetAddress(<void*>&self.mPFIDTight_value)

        #print "making mPFNeutralHadronIsoR04"
        self.mPFNeutralHadronIsoR04_branch = the_tree.GetBranch("mPFNeutralHadronIsoR04")
        #if not self.mPFNeutralHadronIsoR04_branch and "mPFNeutralHadronIsoR04" not in self.complained:
        if not self.mPFNeutralHadronIsoR04_branch and "mPFNeutralHadronIsoR04":
            warnings.warn( "EMTree: Expected branch mPFNeutralHadronIsoR04 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFNeutralHadronIsoR04")
        else:
            self.mPFNeutralHadronIsoR04_branch.SetAddress(<void*>&self.mPFNeutralHadronIsoR04_value)

        #print "making mPFNeutralIso"
        self.mPFNeutralIso_branch = the_tree.GetBranch("mPFNeutralIso")
        #if not self.mPFNeutralIso_branch and "mPFNeutralIso" not in self.complained:
        if not self.mPFNeutralIso_branch and "mPFNeutralIso":
            warnings.warn( "EMTree: Expected branch mPFNeutralIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFNeutralIso")
        else:
            self.mPFNeutralIso_branch.SetAddress(<void*>&self.mPFNeutralIso_value)

        #print "making mPFPUChargedIso"
        self.mPFPUChargedIso_branch = the_tree.GetBranch("mPFPUChargedIso")
        #if not self.mPFPUChargedIso_branch and "mPFPUChargedIso" not in self.complained:
        if not self.mPFPUChargedIso_branch and "mPFPUChargedIso":
            warnings.warn( "EMTree: Expected branch mPFPUChargedIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFPUChargedIso")
        else:
            self.mPFPUChargedIso_branch.SetAddress(<void*>&self.mPFPUChargedIso_value)

        #print "making mPFPhotonIso"
        self.mPFPhotonIso_branch = the_tree.GetBranch("mPFPhotonIso")
        #if not self.mPFPhotonIso_branch and "mPFPhotonIso" not in self.complained:
        if not self.mPFPhotonIso_branch and "mPFPhotonIso":
            warnings.warn( "EMTree: Expected branch mPFPhotonIso does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFPhotonIso")
        else:
            self.mPFPhotonIso_branch.SetAddress(<void*>&self.mPFPhotonIso_value)

        #print "making mPFPhotonIsoR04"
        self.mPFPhotonIsoR04_branch = the_tree.GetBranch("mPFPhotonIsoR04")
        #if not self.mPFPhotonIsoR04_branch and "mPFPhotonIsoR04" not in self.complained:
        if not self.mPFPhotonIsoR04_branch and "mPFPhotonIsoR04":
            warnings.warn( "EMTree: Expected branch mPFPhotonIsoR04 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFPhotonIsoR04")
        else:
            self.mPFPhotonIsoR04_branch.SetAddress(<void*>&self.mPFPhotonIsoR04_value)

        #print "making mPFPileupIsoR04"
        self.mPFPileupIsoR04_branch = the_tree.GetBranch("mPFPileupIsoR04")
        #if not self.mPFPileupIsoR04_branch and "mPFPileupIsoR04" not in self.complained:
        if not self.mPFPileupIsoR04_branch and "mPFPileupIsoR04":
            warnings.warn( "EMTree: Expected branch mPFPileupIsoR04 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPFPileupIsoR04")
        else:
            self.mPFPileupIsoR04_branch.SetAddress(<void*>&self.mPFPileupIsoR04_value)

        #print "making mPVDXY"
        self.mPVDXY_branch = the_tree.GetBranch("mPVDXY")
        #if not self.mPVDXY_branch and "mPVDXY" not in self.complained:
        if not self.mPVDXY_branch and "mPVDXY":
            warnings.warn( "EMTree: Expected branch mPVDXY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPVDXY")
        else:
            self.mPVDXY_branch.SetAddress(<void*>&self.mPVDXY_value)

        #print "making mPVDZ"
        self.mPVDZ_branch = the_tree.GetBranch("mPVDZ")
        #if not self.mPVDZ_branch and "mPVDZ" not in self.complained:
        if not self.mPVDZ_branch and "mPVDZ":
            warnings.warn( "EMTree: Expected branch mPVDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPVDZ")
        else:
            self.mPVDZ_branch.SetAddress(<void*>&self.mPVDZ_value)

        #print "making mPhi"
        self.mPhi_branch = the_tree.GetBranch("mPhi")
        #if not self.mPhi_branch and "mPhi" not in self.complained:
        if not self.mPhi_branch and "mPhi":
            warnings.warn( "EMTree: Expected branch mPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPhi")
        else:
            self.mPhi_branch.SetAddress(<void*>&self.mPhi_value)

        #print "making mPhi_MuonEnDown"
        self.mPhi_MuonEnDown_branch = the_tree.GetBranch("mPhi_MuonEnDown")
        #if not self.mPhi_MuonEnDown_branch and "mPhi_MuonEnDown" not in self.complained:
        if not self.mPhi_MuonEnDown_branch and "mPhi_MuonEnDown":
            warnings.warn( "EMTree: Expected branch mPhi_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPhi_MuonEnDown")
        else:
            self.mPhi_MuonEnDown_branch.SetAddress(<void*>&self.mPhi_MuonEnDown_value)

        #print "making mPhi_MuonEnUp"
        self.mPhi_MuonEnUp_branch = the_tree.GetBranch("mPhi_MuonEnUp")
        #if not self.mPhi_MuonEnUp_branch and "mPhi_MuonEnUp" not in self.complained:
        if not self.mPhi_MuonEnUp_branch and "mPhi_MuonEnUp":
            warnings.warn( "EMTree: Expected branch mPhi_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPhi_MuonEnUp")
        else:
            self.mPhi_MuonEnUp_branch.SetAddress(<void*>&self.mPhi_MuonEnUp_value)

        #print "making mPixHits"
        self.mPixHits_branch = the_tree.GetBranch("mPixHits")
        #if not self.mPixHits_branch and "mPixHits" not in self.complained:
        if not self.mPixHits_branch and "mPixHits":
            warnings.warn( "EMTree: Expected branch mPixHits does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPixHits")
        else:
            self.mPixHits_branch.SetAddress(<void*>&self.mPixHits_value)

        #print "making mPt"
        self.mPt_branch = the_tree.GetBranch("mPt")
        #if not self.mPt_branch and "mPt" not in self.complained:
        if not self.mPt_branch and "mPt":
            warnings.warn( "EMTree: Expected branch mPt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPt")
        else:
            self.mPt_branch.SetAddress(<void*>&self.mPt_value)

        #print "making mPt_MuonEnDown"
        self.mPt_MuonEnDown_branch = the_tree.GetBranch("mPt_MuonEnDown")
        #if not self.mPt_MuonEnDown_branch and "mPt_MuonEnDown" not in self.complained:
        if not self.mPt_MuonEnDown_branch and "mPt_MuonEnDown":
            warnings.warn( "EMTree: Expected branch mPt_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPt_MuonEnDown")
        else:
            self.mPt_MuonEnDown_branch.SetAddress(<void*>&self.mPt_MuonEnDown_value)

        #print "making mPt_MuonEnUp"
        self.mPt_MuonEnUp_branch = the_tree.GetBranch("mPt_MuonEnUp")
        #if not self.mPt_MuonEnUp_branch and "mPt_MuonEnUp" not in self.complained:
        if not self.mPt_MuonEnUp_branch and "mPt_MuonEnUp":
            warnings.warn( "EMTree: Expected branch mPt_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mPt_MuonEnUp")
        else:
            self.mPt_MuonEnUp_branch.SetAddress(<void*>&self.mPt_MuonEnUp_value)

        #print "making mRank"
        self.mRank_branch = the_tree.GetBranch("mRank")
        #if not self.mRank_branch and "mRank" not in self.complained:
        if not self.mRank_branch and "mRank":
            warnings.warn( "EMTree: Expected branch mRank does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mRank")
        else:
            self.mRank_branch.SetAddress(<void*>&self.mRank_value)

        #print "making mRelPFIsoDBDefault"
        self.mRelPFIsoDBDefault_branch = the_tree.GetBranch("mRelPFIsoDBDefault")
        #if not self.mRelPFIsoDBDefault_branch and "mRelPFIsoDBDefault" not in self.complained:
        if not self.mRelPFIsoDBDefault_branch and "mRelPFIsoDBDefault":
            warnings.warn( "EMTree: Expected branch mRelPFIsoDBDefault does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mRelPFIsoDBDefault")
        else:
            self.mRelPFIsoDBDefault_branch.SetAddress(<void*>&self.mRelPFIsoDBDefault_value)

        #print "making mRelPFIsoDBDefaultR04"
        self.mRelPFIsoDBDefaultR04_branch = the_tree.GetBranch("mRelPFIsoDBDefaultR04")
        #if not self.mRelPFIsoDBDefaultR04_branch and "mRelPFIsoDBDefaultR04" not in self.complained:
        if not self.mRelPFIsoDBDefaultR04_branch and "mRelPFIsoDBDefaultR04":
            warnings.warn( "EMTree: Expected branch mRelPFIsoDBDefaultR04 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mRelPFIsoDBDefaultR04")
        else:
            self.mRelPFIsoDBDefaultR04_branch.SetAddress(<void*>&self.mRelPFIsoDBDefaultR04_value)

        #print "making mRelPFIsoRho"
        self.mRelPFIsoRho_branch = the_tree.GetBranch("mRelPFIsoRho")
        #if not self.mRelPFIsoRho_branch and "mRelPFIsoRho" not in self.complained:
        if not self.mRelPFIsoRho_branch and "mRelPFIsoRho":
            warnings.warn( "EMTree: Expected branch mRelPFIsoRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mRelPFIsoRho")
        else:
            self.mRelPFIsoRho_branch.SetAddress(<void*>&self.mRelPFIsoRho_value)

        #print "making mRho"
        self.mRho_branch = the_tree.GetBranch("mRho")
        #if not self.mRho_branch and "mRho" not in self.complained:
        if not self.mRho_branch and "mRho":
            warnings.warn( "EMTree: Expected branch mRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mRho")
        else:
            self.mRho_branch.SetAddress(<void*>&self.mRho_value)

        #print "making mSIP2D"
        self.mSIP2D_branch = the_tree.GetBranch("mSIP2D")
        #if not self.mSIP2D_branch and "mSIP2D" not in self.complained:
        if not self.mSIP2D_branch and "mSIP2D":
            warnings.warn( "EMTree: Expected branch mSIP2D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mSIP2D")
        else:
            self.mSIP2D_branch.SetAddress(<void*>&self.mSIP2D_value)

        #print "making mSIP3D"
        self.mSIP3D_branch = the_tree.GetBranch("mSIP3D")
        #if not self.mSIP3D_branch and "mSIP3D" not in self.complained:
        if not self.mSIP3D_branch and "mSIP3D":
            warnings.warn( "EMTree: Expected branch mSIP3D does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mSIP3D")
        else:
            self.mSIP3D_branch.SetAddress(<void*>&self.mSIP3D_value)

        #print "making mTkLayersWithMeasurement"
        self.mTkLayersWithMeasurement_branch = the_tree.GetBranch("mTkLayersWithMeasurement")
        #if not self.mTkLayersWithMeasurement_branch and "mTkLayersWithMeasurement" not in self.complained:
        if not self.mTkLayersWithMeasurement_branch and "mTkLayersWithMeasurement":
            warnings.warn( "EMTree: Expected branch mTkLayersWithMeasurement does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mTkLayersWithMeasurement")
        else:
            self.mTkLayersWithMeasurement_branch.SetAddress(<void*>&self.mTkLayersWithMeasurement_value)

        #print "making mTrkIsoDR03"
        self.mTrkIsoDR03_branch = the_tree.GetBranch("mTrkIsoDR03")
        #if not self.mTrkIsoDR03_branch and "mTrkIsoDR03" not in self.complained:
        if not self.mTrkIsoDR03_branch and "mTrkIsoDR03":
            warnings.warn( "EMTree: Expected branch mTrkIsoDR03 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mTrkIsoDR03")
        else:
            self.mTrkIsoDR03_branch.SetAddress(<void*>&self.mTrkIsoDR03_value)

        #print "making mTypeCode"
        self.mTypeCode_branch = the_tree.GetBranch("mTypeCode")
        #if not self.mTypeCode_branch and "mTypeCode" not in self.complained:
        if not self.mTypeCode_branch and "mTypeCode":
            warnings.warn( "EMTree: Expected branch mTypeCode does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mTypeCode")
        else:
            self.mTypeCode_branch.SetAddress(<void*>&self.mTypeCode_value)

        #print "making mVZ"
        self.mVZ_branch = the_tree.GetBranch("mVZ")
        #if not self.mVZ_branch and "mVZ" not in self.complained:
        if not self.mVZ_branch and "mVZ":
            warnings.warn( "EMTree: Expected branch mVZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("mVZ")
        else:
            self.mVZ_branch.SetAddress(<void*>&self.mVZ_value)

        #print "making m_e_collinearmass"
        self.m_e_collinearmass_branch = the_tree.GetBranch("m_e_collinearmass")
        #if not self.m_e_collinearmass_branch and "m_e_collinearmass" not in self.complained:
        if not self.m_e_collinearmass_branch and "m_e_collinearmass":
            warnings.warn( "EMTree: Expected branch m_e_collinearmass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m_e_collinearmass")
        else:
            self.m_e_collinearmass_branch.SetAddress(<void*>&self.m_e_collinearmass_value)

        #print "making m_e_collinearmass_JetEnDown"
        self.m_e_collinearmass_JetEnDown_branch = the_tree.GetBranch("m_e_collinearmass_JetEnDown")
        #if not self.m_e_collinearmass_JetEnDown_branch and "m_e_collinearmass_JetEnDown" not in self.complained:
        if not self.m_e_collinearmass_JetEnDown_branch and "m_e_collinearmass_JetEnDown":
            warnings.warn( "EMTree: Expected branch m_e_collinearmass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m_e_collinearmass_JetEnDown")
        else:
            self.m_e_collinearmass_JetEnDown_branch.SetAddress(<void*>&self.m_e_collinearmass_JetEnDown_value)

        #print "making m_e_collinearmass_JetEnUp"
        self.m_e_collinearmass_JetEnUp_branch = the_tree.GetBranch("m_e_collinearmass_JetEnUp")
        #if not self.m_e_collinearmass_JetEnUp_branch and "m_e_collinearmass_JetEnUp" not in self.complained:
        if not self.m_e_collinearmass_JetEnUp_branch and "m_e_collinearmass_JetEnUp":
            warnings.warn( "EMTree: Expected branch m_e_collinearmass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m_e_collinearmass_JetEnUp")
        else:
            self.m_e_collinearmass_JetEnUp_branch.SetAddress(<void*>&self.m_e_collinearmass_JetEnUp_value)

        #print "making m_e_collinearmass_UnclusteredEnDown"
        self.m_e_collinearmass_UnclusteredEnDown_branch = the_tree.GetBranch("m_e_collinearmass_UnclusteredEnDown")
        #if not self.m_e_collinearmass_UnclusteredEnDown_branch and "m_e_collinearmass_UnclusteredEnDown" not in self.complained:
        if not self.m_e_collinearmass_UnclusteredEnDown_branch and "m_e_collinearmass_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch m_e_collinearmass_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m_e_collinearmass_UnclusteredEnDown")
        else:
            self.m_e_collinearmass_UnclusteredEnDown_branch.SetAddress(<void*>&self.m_e_collinearmass_UnclusteredEnDown_value)

        #print "making m_e_collinearmass_UnclusteredEnUp"
        self.m_e_collinearmass_UnclusteredEnUp_branch = the_tree.GetBranch("m_e_collinearmass_UnclusteredEnUp")
        #if not self.m_e_collinearmass_UnclusteredEnUp_branch and "m_e_collinearmass_UnclusteredEnUp" not in self.complained:
        if not self.m_e_collinearmass_UnclusteredEnUp_branch and "m_e_collinearmass_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch m_e_collinearmass_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("m_e_collinearmass_UnclusteredEnUp")
        else:
            self.m_e_collinearmass_UnclusteredEnUp_branch.SetAddress(<void*>&self.m_e_collinearmass_UnclusteredEnUp_value)

        #print "making muGlbIsoVetoPt10"
        self.muGlbIsoVetoPt10_branch = the_tree.GetBranch("muGlbIsoVetoPt10")
        #if not self.muGlbIsoVetoPt10_branch and "muGlbIsoVetoPt10" not in self.complained:
        if not self.muGlbIsoVetoPt10_branch and "muGlbIsoVetoPt10":
            warnings.warn( "EMTree: Expected branch muGlbIsoVetoPt10 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muGlbIsoVetoPt10")
        else:
            self.muGlbIsoVetoPt10_branch.SetAddress(<void*>&self.muGlbIsoVetoPt10_value)

        #print "making muVetoPt15IsoIdVtx"
        self.muVetoPt15IsoIdVtx_branch = the_tree.GetBranch("muVetoPt15IsoIdVtx")
        #if not self.muVetoPt15IsoIdVtx_branch and "muVetoPt15IsoIdVtx" not in self.complained:
        if not self.muVetoPt15IsoIdVtx_branch and "muVetoPt15IsoIdVtx":
            warnings.warn( "EMTree: Expected branch muVetoPt15IsoIdVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt15IsoIdVtx")
        else:
            self.muVetoPt15IsoIdVtx_branch.SetAddress(<void*>&self.muVetoPt15IsoIdVtx_value)

        #print "making muVetoPt5"
        self.muVetoPt5_branch = the_tree.GetBranch("muVetoPt5")
        #if not self.muVetoPt5_branch and "muVetoPt5" not in self.complained:
        if not self.muVetoPt5_branch and "muVetoPt5":
            warnings.warn( "EMTree: Expected branch muVetoPt5 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt5")
        else:
            self.muVetoPt5_branch.SetAddress(<void*>&self.muVetoPt5_value)

        #print "making muVetoPt5IsoIdVtx"
        self.muVetoPt5IsoIdVtx_branch = the_tree.GetBranch("muVetoPt5IsoIdVtx")
        #if not self.muVetoPt5IsoIdVtx_branch and "muVetoPt5IsoIdVtx" not in self.complained:
        if not self.muVetoPt5IsoIdVtx_branch and "muVetoPt5IsoIdVtx":
            warnings.warn( "EMTree: Expected branch muVetoPt5IsoIdVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("muVetoPt5IsoIdVtx")
        else:
            self.muVetoPt5IsoIdVtx_branch.SetAddress(<void*>&self.muVetoPt5IsoIdVtx_value)

        #print "making nTruePU"
        self.nTruePU_branch = the_tree.GetBranch("nTruePU")
        #if not self.nTruePU_branch and "nTruePU" not in self.complained:
        if not self.nTruePU_branch and "nTruePU":
            warnings.warn( "EMTree: Expected branch nTruePU does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("nTruePU")
        else:
            self.nTruePU_branch.SetAddress(<void*>&self.nTruePU_value)

        #print "making nvtx"
        self.nvtx_branch = the_tree.GetBranch("nvtx")
        #if not self.nvtx_branch and "nvtx" not in self.complained:
        if not self.nvtx_branch and "nvtx":
            warnings.warn( "EMTree: Expected branch nvtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("nvtx")
        else:
            self.nvtx_branch.SetAddress(<void*>&self.nvtx_value)

        #print "making processID"
        self.processID_branch = the_tree.GetBranch("processID")
        #if not self.processID_branch and "processID" not in self.complained:
        if not self.processID_branch and "processID":
            warnings.warn( "EMTree: Expected branch processID does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("processID")
        else:
            self.processID_branch.SetAddress(<void*>&self.processID_value)

        #print "making pvChi2"
        self.pvChi2_branch = the_tree.GetBranch("pvChi2")
        #if not self.pvChi2_branch and "pvChi2" not in self.complained:
        if not self.pvChi2_branch and "pvChi2":
            warnings.warn( "EMTree: Expected branch pvChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvChi2")
        else:
            self.pvChi2_branch.SetAddress(<void*>&self.pvChi2_value)

        #print "making pvDX"
        self.pvDX_branch = the_tree.GetBranch("pvDX")
        #if not self.pvDX_branch and "pvDX" not in self.complained:
        if not self.pvDX_branch and "pvDX":
            warnings.warn( "EMTree: Expected branch pvDX does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDX")
        else:
            self.pvDX_branch.SetAddress(<void*>&self.pvDX_value)

        #print "making pvDY"
        self.pvDY_branch = the_tree.GetBranch("pvDY")
        #if not self.pvDY_branch and "pvDY" not in self.complained:
        if not self.pvDY_branch and "pvDY":
            warnings.warn( "EMTree: Expected branch pvDY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDY")
        else:
            self.pvDY_branch.SetAddress(<void*>&self.pvDY_value)

        #print "making pvDZ"
        self.pvDZ_branch = the_tree.GetBranch("pvDZ")
        #if not self.pvDZ_branch and "pvDZ" not in self.complained:
        if not self.pvDZ_branch and "pvDZ":
            warnings.warn( "EMTree: Expected branch pvDZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvDZ")
        else:
            self.pvDZ_branch.SetAddress(<void*>&self.pvDZ_value)

        #print "making pvIsFake"
        self.pvIsFake_branch = the_tree.GetBranch("pvIsFake")
        #if not self.pvIsFake_branch and "pvIsFake" not in self.complained:
        if not self.pvIsFake_branch and "pvIsFake":
            warnings.warn( "EMTree: Expected branch pvIsFake does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvIsFake")
        else:
            self.pvIsFake_branch.SetAddress(<void*>&self.pvIsFake_value)

        #print "making pvIsValid"
        self.pvIsValid_branch = the_tree.GetBranch("pvIsValid")
        #if not self.pvIsValid_branch and "pvIsValid" not in self.complained:
        if not self.pvIsValid_branch and "pvIsValid":
            warnings.warn( "EMTree: Expected branch pvIsValid does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvIsValid")
        else:
            self.pvIsValid_branch.SetAddress(<void*>&self.pvIsValid_value)

        #print "making pvNormChi2"
        self.pvNormChi2_branch = the_tree.GetBranch("pvNormChi2")
        #if not self.pvNormChi2_branch and "pvNormChi2" not in self.complained:
        if not self.pvNormChi2_branch and "pvNormChi2":
            warnings.warn( "EMTree: Expected branch pvNormChi2 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvNormChi2")
        else:
            self.pvNormChi2_branch.SetAddress(<void*>&self.pvNormChi2_value)

        #print "making pvRho"
        self.pvRho_branch = the_tree.GetBranch("pvRho")
        #if not self.pvRho_branch and "pvRho" not in self.complained:
        if not self.pvRho_branch and "pvRho":
            warnings.warn( "EMTree: Expected branch pvRho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvRho")
        else:
            self.pvRho_branch.SetAddress(<void*>&self.pvRho_value)

        #print "making pvX"
        self.pvX_branch = the_tree.GetBranch("pvX")
        #if not self.pvX_branch and "pvX" not in self.complained:
        if not self.pvX_branch and "pvX":
            warnings.warn( "EMTree: Expected branch pvX does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvX")
        else:
            self.pvX_branch.SetAddress(<void*>&self.pvX_value)

        #print "making pvY"
        self.pvY_branch = the_tree.GetBranch("pvY")
        #if not self.pvY_branch and "pvY" not in self.complained:
        if not self.pvY_branch and "pvY":
            warnings.warn( "EMTree: Expected branch pvY does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvY")
        else:
            self.pvY_branch.SetAddress(<void*>&self.pvY_value)

        #print "making pvZ"
        self.pvZ_branch = the_tree.GetBranch("pvZ")
        #if not self.pvZ_branch and "pvZ" not in self.complained:
        if not self.pvZ_branch and "pvZ":
            warnings.warn( "EMTree: Expected branch pvZ does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvZ")
        else:
            self.pvZ_branch.SetAddress(<void*>&self.pvZ_value)

        #print "making pvndof"
        self.pvndof_branch = the_tree.GetBranch("pvndof")
        #if not self.pvndof_branch and "pvndof" not in self.complained:
        if not self.pvndof_branch and "pvndof":
            warnings.warn( "EMTree: Expected branch pvndof does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("pvndof")
        else:
            self.pvndof_branch.SetAddress(<void*>&self.pvndof_value)

        #print "making raw_pfMetEt"
        self.raw_pfMetEt_branch = the_tree.GetBranch("raw_pfMetEt")
        #if not self.raw_pfMetEt_branch and "raw_pfMetEt" not in self.complained:
        if not self.raw_pfMetEt_branch and "raw_pfMetEt":
            warnings.warn( "EMTree: Expected branch raw_pfMetEt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("raw_pfMetEt")
        else:
            self.raw_pfMetEt_branch.SetAddress(<void*>&self.raw_pfMetEt_value)

        #print "making raw_pfMetPhi"
        self.raw_pfMetPhi_branch = the_tree.GetBranch("raw_pfMetPhi")
        #if not self.raw_pfMetPhi_branch and "raw_pfMetPhi" not in self.complained:
        if not self.raw_pfMetPhi_branch and "raw_pfMetPhi":
            warnings.warn( "EMTree: Expected branch raw_pfMetPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("raw_pfMetPhi")
        else:
            self.raw_pfMetPhi_branch.SetAddress(<void*>&self.raw_pfMetPhi_value)

        #print "making recoilDaught"
        self.recoilDaught_branch = the_tree.GetBranch("recoilDaught")
        #if not self.recoilDaught_branch and "recoilDaught" not in self.complained:
        if not self.recoilDaught_branch and "recoilDaught":
            warnings.warn( "EMTree: Expected branch recoilDaught does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("recoilDaught")
        else:
            self.recoilDaught_branch.SetAddress(<void*>&self.recoilDaught_value)

        #print "making recoilWithMet"
        self.recoilWithMet_branch = the_tree.GetBranch("recoilWithMet")
        #if not self.recoilWithMet_branch and "recoilWithMet" not in self.complained:
        if not self.recoilWithMet_branch and "recoilWithMet":
            warnings.warn( "EMTree: Expected branch recoilWithMet does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("recoilWithMet")
        else:
            self.recoilWithMet_branch.SetAddress(<void*>&self.recoilWithMet_value)

        #print "making rho"
        self.rho_branch = the_tree.GetBranch("rho")
        #if not self.rho_branch and "rho" not in self.complained:
        if not self.rho_branch and "rho":
            warnings.warn( "EMTree: Expected branch rho does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("rho")
        else:
            self.rho_branch.SetAddress(<void*>&self.rho_value)

        #print "making run"
        self.run_branch = the_tree.GetBranch("run")
        #if not self.run_branch and "run" not in self.complained:
        if not self.run_branch and "run":
            warnings.warn( "EMTree: Expected branch run does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("run")
        else:
            self.run_branch.SetAddress(<void*>&self.run_value)

        #print "making singleE17SingleMu8Group"
        self.singleE17SingleMu8Group_branch = the_tree.GetBranch("singleE17SingleMu8Group")
        #if not self.singleE17SingleMu8Group_branch and "singleE17SingleMu8Group" not in self.complained:
        if not self.singleE17SingleMu8Group_branch and "singleE17SingleMu8Group":
            warnings.warn( "EMTree: Expected branch singleE17SingleMu8Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Group")
        else:
            self.singleE17SingleMu8Group_branch.SetAddress(<void*>&self.singleE17SingleMu8Group_value)

        #print "making singleE17SingleMu8Pass"
        self.singleE17SingleMu8Pass_branch = the_tree.GetBranch("singleE17SingleMu8Pass")
        #if not self.singleE17SingleMu8Pass_branch and "singleE17SingleMu8Pass" not in self.complained:
        if not self.singleE17SingleMu8Pass_branch and "singleE17SingleMu8Pass":
            warnings.warn( "EMTree: Expected branch singleE17SingleMu8Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Pass")
        else:
            self.singleE17SingleMu8Pass_branch.SetAddress(<void*>&self.singleE17SingleMu8Pass_value)

        #print "making singleE17SingleMu8Prescale"
        self.singleE17SingleMu8Prescale_branch = the_tree.GetBranch("singleE17SingleMu8Prescale")
        #if not self.singleE17SingleMu8Prescale_branch and "singleE17SingleMu8Prescale" not in self.complained:
        if not self.singleE17SingleMu8Prescale_branch and "singleE17SingleMu8Prescale":
            warnings.warn( "EMTree: Expected branch singleE17SingleMu8Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE17SingleMu8Prescale")
        else:
            self.singleE17SingleMu8Prescale_branch.SetAddress(<void*>&self.singleE17SingleMu8Prescale_value)

        #print "making singleE22WP75Group"
        self.singleE22WP75Group_branch = the_tree.GetBranch("singleE22WP75Group")
        #if not self.singleE22WP75Group_branch and "singleE22WP75Group" not in self.complained:
        if not self.singleE22WP75Group_branch and "singleE22WP75Group":
            warnings.warn( "EMTree: Expected branch singleE22WP75Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Group")
        else:
            self.singleE22WP75Group_branch.SetAddress(<void*>&self.singleE22WP75Group_value)

        #print "making singleE22WP75Pass"
        self.singleE22WP75Pass_branch = the_tree.GetBranch("singleE22WP75Pass")
        #if not self.singleE22WP75Pass_branch and "singleE22WP75Pass" not in self.complained:
        if not self.singleE22WP75Pass_branch and "singleE22WP75Pass":
            warnings.warn( "EMTree: Expected branch singleE22WP75Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Pass")
        else:
            self.singleE22WP75Pass_branch.SetAddress(<void*>&self.singleE22WP75Pass_value)

        #print "making singleE22WP75Prescale"
        self.singleE22WP75Prescale_branch = the_tree.GetBranch("singleE22WP75Prescale")
        #if not self.singleE22WP75Prescale_branch and "singleE22WP75Prescale" not in self.complained:
        if not self.singleE22WP75Prescale_branch and "singleE22WP75Prescale":
            warnings.warn( "EMTree: Expected branch singleE22WP75Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22WP75Prescale")
        else:
            self.singleE22WP75Prescale_branch.SetAddress(<void*>&self.singleE22WP75Prescale_value)

        #print "making singleE22eta2p1LooseGroup"
        self.singleE22eta2p1LooseGroup_branch = the_tree.GetBranch("singleE22eta2p1LooseGroup")
        #if not self.singleE22eta2p1LooseGroup_branch and "singleE22eta2p1LooseGroup" not in self.complained:
        if not self.singleE22eta2p1LooseGroup_branch and "singleE22eta2p1LooseGroup":
            warnings.warn( "EMTree: Expected branch singleE22eta2p1LooseGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LooseGroup")
        else:
            self.singleE22eta2p1LooseGroup_branch.SetAddress(<void*>&self.singleE22eta2p1LooseGroup_value)

        #print "making singleE22eta2p1LoosePass"
        self.singleE22eta2p1LoosePass_branch = the_tree.GetBranch("singleE22eta2p1LoosePass")
        #if not self.singleE22eta2p1LoosePass_branch and "singleE22eta2p1LoosePass" not in self.complained:
        if not self.singleE22eta2p1LoosePass_branch and "singleE22eta2p1LoosePass":
            warnings.warn( "EMTree: Expected branch singleE22eta2p1LoosePass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LoosePass")
        else:
            self.singleE22eta2p1LoosePass_branch.SetAddress(<void*>&self.singleE22eta2p1LoosePass_value)

        #print "making singleE22eta2p1LoosePrescale"
        self.singleE22eta2p1LoosePrescale_branch = the_tree.GetBranch("singleE22eta2p1LoosePrescale")
        #if not self.singleE22eta2p1LoosePrescale_branch and "singleE22eta2p1LoosePrescale" not in self.complained:
        if not self.singleE22eta2p1LoosePrescale_branch and "singleE22eta2p1LoosePrescale":
            warnings.warn( "EMTree: Expected branch singleE22eta2p1LoosePrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE22eta2p1LoosePrescale")
        else:
            self.singleE22eta2p1LoosePrescale_branch.SetAddress(<void*>&self.singleE22eta2p1LoosePrescale_value)

        #print "making singleE23SingleMu8Group"
        self.singleE23SingleMu8Group_branch = the_tree.GetBranch("singleE23SingleMu8Group")
        #if not self.singleE23SingleMu8Group_branch and "singleE23SingleMu8Group" not in self.complained:
        if not self.singleE23SingleMu8Group_branch and "singleE23SingleMu8Group":
            warnings.warn( "EMTree: Expected branch singleE23SingleMu8Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Group")
        else:
            self.singleE23SingleMu8Group_branch.SetAddress(<void*>&self.singleE23SingleMu8Group_value)

        #print "making singleE23SingleMu8Pass"
        self.singleE23SingleMu8Pass_branch = the_tree.GetBranch("singleE23SingleMu8Pass")
        #if not self.singleE23SingleMu8Pass_branch and "singleE23SingleMu8Pass" not in self.complained:
        if not self.singleE23SingleMu8Pass_branch and "singleE23SingleMu8Pass":
            warnings.warn( "EMTree: Expected branch singleE23SingleMu8Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Pass")
        else:
            self.singleE23SingleMu8Pass_branch.SetAddress(<void*>&self.singleE23SingleMu8Pass_value)

        #print "making singleE23SingleMu8Prescale"
        self.singleE23SingleMu8Prescale_branch = the_tree.GetBranch("singleE23SingleMu8Prescale")
        #if not self.singleE23SingleMu8Prescale_branch and "singleE23SingleMu8Prescale" not in self.complained:
        if not self.singleE23SingleMu8Prescale_branch and "singleE23SingleMu8Prescale":
            warnings.warn( "EMTree: Expected branch singleE23SingleMu8Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23SingleMu8Prescale")
        else:
            self.singleE23SingleMu8Prescale_branch.SetAddress(<void*>&self.singleE23SingleMu8Prescale_value)

        #print "making singleE23WP75Group"
        self.singleE23WP75Group_branch = the_tree.GetBranch("singleE23WP75Group")
        #if not self.singleE23WP75Group_branch and "singleE23WP75Group" not in self.complained:
        if not self.singleE23WP75Group_branch and "singleE23WP75Group":
            warnings.warn( "EMTree: Expected branch singleE23WP75Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Group")
        else:
            self.singleE23WP75Group_branch.SetAddress(<void*>&self.singleE23WP75Group_value)

        #print "making singleE23WP75Pass"
        self.singleE23WP75Pass_branch = the_tree.GetBranch("singleE23WP75Pass")
        #if not self.singleE23WP75Pass_branch and "singleE23WP75Pass" not in self.complained:
        if not self.singleE23WP75Pass_branch and "singleE23WP75Pass":
            warnings.warn( "EMTree: Expected branch singleE23WP75Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Pass")
        else:
            self.singleE23WP75Pass_branch.SetAddress(<void*>&self.singleE23WP75Pass_value)

        #print "making singleE23WP75Prescale"
        self.singleE23WP75Prescale_branch = the_tree.GetBranch("singleE23WP75Prescale")
        #if not self.singleE23WP75Prescale_branch and "singleE23WP75Prescale" not in self.complained:
        if not self.singleE23WP75Prescale_branch and "singleE23WP75Prescale":
            warnings.warn( "EMTree: Expected branch singleE23WP75Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WP75Prescale")
        else:
            self.singleE23WP75Prescale_branch.SetAddress(<void*>&self.singleE23WP75Prescale_value)

        #print "making singleE23WPLooseGroup"
        self.singleE23WPLooseGroup_branch = the_tree.GetBranch("singleE23WPLooseGroup")
        #if not self.singleE23WPLooseGroup_branch and "singleE23WPLooseGroup" not in self.complained:
        if not self.singleE23WPLooseGroup_branch and "singleE23WPLooseGroup":
            warnings.warn( "EMTree: Expected branch singleE23WPLooseGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WPLooseGroup")
        else:
            self.singleE23WPLooseGroup_branch.SetAddress(<void*>&self.singleE23WPLooseGroup_value)

        #print "making singleE23WPLoosePass"
        self.singleE23WPLoosePass_branch = the_tree.GetBranch("singleE23WPLoosePass")
        #if not self.singleE23WPLoosePass_branch and "singleE23WPLoosePass" not in self.complained:
        if not self.singleE23WPLoosePass_branch and "singleE23WPLoosePass":
            warnings.warn( "EMTree: Expected branch singleE23WPLoosePass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WPLoosePass")
        else:
            self.singleE23WPLoosePass_branch.SetAddress(<void*>&self.singleE23WPLoosePass_value)

        #print "making singleE23WPLoosePrescale"
        self.singleE23WPLoosePrescale_branch = the_tree.GetBranch("singleE23WPLoosePrescale")
        #if not self.singleE23WPLoosePrescale_branch and "singleE23WPLoosePrescale" not in self.complained:
        if not self.singleE23WPLoosePrescale_branch and "singleE23WPLoosePrescale":
            warnings.warn( "EMTree: Expected branch singleE23WPLoosePrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE23WPLoosePrescale")
        else:
            self.singleE23WPLoosePrescale_branch.SetAddress(<void*>&self.singleE23WPLoosePrescale_value)

        #print "making singleEGroup"
        self.singleEGroup_branch = the_tree.GetBranch("singleEGroup")
        #if not self.singleEGroup_branch and "singleEGroup" not in self.complained:
        if not self.singleEGroup_branch and "singleEGroup":
            warnings.warn( "EMTree: Expected branch singleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEGroup")
        else:
            self.singleEGroup_branch.SetAddress(<void*>&self.singleEGroup_value)

        #print "making singleEPass"
        self.singleEPass_branch = the_tree.GetBranch("singleEPass")
        #if not self.singleEPass_branch and "singleEPass" not in self.complained:
        if not self.singleEPass_branch and "singleEPass":
            warnings.warn( "EMTree: Expected branch singleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEPass")
        else:
            self.singleEPass_branch.SetAddress(<void*>&self.singleEPass_value)

        #print "making singleEPrescale"
        self.singleEPrescale_branch = the_tree.GetBranch("singleEPrescale")
        #if not self.singleEPrescale_branch and "singleEPrescale" not in self.complained:
        if not self.singleEPrescale_branch and "singleEPrescale":
            warnings.warn( "EMTree: Expected branch singleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleEPrescale")
        else:
            self.singleEPrescale_branch.SetAddress(<void*>&self.singleEPrescale_value)

        #print "making singleESingleMuGroup"
        self.singleESingleMuGroup_branch = the_tree.GetBranch("singleESingleMuGroup")
        #if not self.singleESingleMuGroup_branch and "singleESingleMuGroup" not in self.complained:
        if not self.singleESingleMuGroup_branch and "singleESingleMuGroup":
            warnings.warn( "EMTree: Expected branch singleESingleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuGroup")
        else:
            self.singleESingleMuGroup_branch.SetAddress(<void*>&self.singleESingleMuGroup_value)

        #print "making singleESingleMuPass"
        self.singleESingleMuPass_branch = the_tree.GetBranch("singleESingleMuPass")
        #if not self.singleESingleMuPass_branch and "singleESingleMuPass" not in self.complained:
        if not self.singleESingleMuPass_branch and "singleESingleMuPass":
            warnings.warn( "EMTree: Expected branch singleESingleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuPass")
        else:
            self.singleESingleMuPass_branch.SetAddress(<void*>&self.singleESingleMuPass_value)

        #print "making singleESingleMuPrescale"
        self.singleESingleMuPrescale_branch = the_tree.GetBranch("singleESingleMuPrescale")
        #if not self.singleESingleMuPrescale_branch and "singleESingleMuPrescale" not in self.complained:
        if not self.singleESingleMuPrescale_branch and "singleESingleMuPrescale":
            warnings.warn( "EMTree: Expected branch singleESingleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleESingleMuPrescale")
        else:
            self.singleESingleMuPrescale_branch.SetAddress(<void*>&self.singleESingleMuPrescale_value)

        #print "making singleE_leg1Group"
        self.singleE_leg1Group_branch = the_tree.GetBranch("singleE_leg1Group")
        #if not self.singleE_leg1Group_branch and "singleE_leg1Group" not in self.complained:
        if not self.singleE_leg1Group_branch and "singleE_leg1Group":
            warnings.warn( "EMTree: Expected branch singleE_leg1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Group")
        else:
            self.singleE_leg1Group_branch.SetAddress(<void*>&self.singleE_leg1Group_value)

        #print "making singleE_leg1Pass"
        self.singleE_leg1Pass_branch = the_tree.GetBranch("singleE_leg1Pass")
        #if not self.singleE_leg1Pass_branch and "singleE_leg1Pass" not in self.complained:
        if not self.singleE_leg1Pass_branch and "singleE_leg1Pass":
            warnings.warn( "EMTree: Expected branch singleE_leg1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Pass")
        else:
            self.singleE_leg1Pass_branch.SetAddress(<void*>&self.singleE_leg1Pass_value)

        #print "making singleE_leg1Prescale"
        self.singleE_leg1Prescale_branch = the_tree.GetBranch("singleE_leg1Prescale")
        #if not self.singleE_leg1Prescale_branch and "singleE_leg1Prescale" not in self.complained:
        if not self.singleE_leg1Prescale_branch and "singleE_leg1Prescale":
            warnings.warn( "EMTree: Expected branch singleE_leg1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg1Prescale")
        else:
            self.singleE_leg1Prescale_branch.SetAddress(<void*>&self.singleE_leg1Prescale_value)

        #print "making singleE_leg2Group"
        self.singleE_leg2Group_branch = the_tree.GetBranch("singleE_leg2Group")
        #if not self.singleE_leg2Group_branch and "singleE_leg2Group" not in self.complained:
        if not self.singleE_leg2Group_branch and "singleE_leg2Group":
            warnings.warn( "EMTree: Expected branch singleE_leg2Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Group")
        else:
            self.singleE_leg2Group_branch.SetAddress(<void*>&self.singleE_leg2Group_value)

        #print "making singleE_leg2Pass"
        self.singleE_leg2Pass_branch = the_tree.GetBranch("singleE_leg2Pass")
        #if not self.singleE_leg2Pass_branch and "singleE_leg2Pass" not in self.complained:
        if not self.singleE_leg2Pass_branch and "singleE_leg2Pass":
            warnings.warn( "EMTree: Expected branch singleE_leg2Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Pass")
        else:
            self.singleE_leg2Pass_branch.SetAddress(<void*>&self.singleE_leg2Pass_value)

        #print "making singleE_leg2Prescale"
        self.singleE_leg2Prescale_branch = the_tree.GetBranch("singleE_leg2Prescale")
        #if not self.singleE_leg2Prescale_branch and "singleE_leg2Prescale" not in self.complained:
        if not self.singleE_leg2Prescale_branch and "singleE_leg2Prescale":
            warnings.warn( "EMTree: Expected branch singleE_leg2Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleE_leg2Prescale")
        else:
            self.singleE_leg2Prescale_branch.SetAddress(<void*>&self.singleE_leg2Prescale_value)

        #print "making singleIsoMu17eta2p1Group"
        self.singleIsoMu17eta2p1Group_branch = the_tree.GetBranch("singleIsoMu17eta2p1Group")
        #if not self.singleIsoMu17eta2p1Group_branch and "singleIsoMu17eta2p1Group" not in self.complained:
        if not self.singleIsoMu17eta2p1Group_branch and "singleIsoMu17eta2p1Group":
            warnings.warn( "EMTree: Expected branch singleIsoMu17eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Group")
        else:
            self.singleIsoMu17eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Group_value)

        #print "making singleIsoMu17eta2p1Pass"
        self.singleIsoMu17eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu17eta2p1Pass")
        #if not self.singleIsoMu17eta2p1Pass_branch and "singleIsoMu17eta2p1Pass" not in self.complained:
        if not self.singleIsoMu17eta2p1Pass_branch and "singleIsoMu17eta2p1Pass":
            warnings.warn( "EMTree: Expected branch singleIsoMu17eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Pass")
        else:
            self.singleIsoMu17eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Pass_value)

        #print "making singleIsoMu17eta2p1Prescale"
        self.singleIsoMu17eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu17eta2p1Prescale")
        #if not self.singleIsoMu17eta2p1Prescale_branch and "singleIsoMu17eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu17eta2p1Prescale_branch and "singleIsoMu17eta2p1Prescale":
            warnings.warn( "EMTree: Expected branch singleIsoMu17eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu17eta2p1Prescale")
        else:
            self.singleIsoMu17eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu17eta2p1Prescale_value)

        #print "making singleIsoMu20Group"
        self.singleIsoMu20Group_branch = the_tree.GetBranch("singleIsoMu20Group")
        #if not self.singleIsoMu20Group_branch and "singleIsoMu20Group" not in self.complained:
        if not self.singleIsoMu20Group_branch and "singleIsoMu20Group":
            warnings.warn( "EMTree: Expected branch singleIsoMu20Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Group")
        else:
            self.singleIsoMu20Group_branch.SetAddress(<void*>&self.singleIsoMu20Group_value)

        #print "making singleIsoMu20Pass"
        self.singleIsoMu20Pass_branch = the_tree.GetBranch("singleIsoMu20Pass")
        #if not self.singleIsoMu20Pass_branch and "singleIsoMu20Pass" not in self.complained:
        if not self.singleIsoMu20Pass_branch and "singleIsoMu20Pass":
            warnings.warn( "EMTree: Expected branch singleIsoMu20Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Pass")
        else:
            self.singleIsoMu20Pass_branch.SetAddress(<void*>&self.singleIsoMu20Pass_value)

        #print "making singleIsoMu20Prescale"
        self.singleIsoMu20Prescale_branch = the_tree.GetBranch("singleIsoMu20Prescale")
        #if not self.singleIsoMu20Prescale_branch and "singleIsoMu20Prescale" not in self.complained:
        if not self.singleIsoMu20Prescale_branch and "singleIsoMu20Prescale":
            warnings.warn( "EMTree: Expected branch singleIsoMu20Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20Prescale")
        else:
            self.singleIsoMu20Prescale_branch.SetAddress(<void*>&self.singleIsoMu20Prescale_value)

        #print "making singleIsoMu20eta2p1Group"
        self.singleIsoMu20eta2p1Group_branch = the_tree.GetBranch("singleIsoMu20eta2p1Group")
        #if not self.singleIsoMu20eta2p1Group_branch and "singleIsoMu20eta2p1Group" not in self.complained:
        if not self.singleIsoMu20eta2p1Group_branch and "singleIsoMu20eta2p1Group":
            warnings.warn( "EMTree: Expected branch singleIsoMu20eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Group")
        else:
            self.singleIsoMu20eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Group_value)

        #print "making singleIsoMu20eta2p1Pass"
        self.singleIsoMu20eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu20eta2p1Pass")
        #if not self.singleIsoMu20eta2p1Pass_branch and "singleIsoMu20eta2p1Pass" not in self.complained:
        if not self.singleIsoMu20eta2p1Pass_branch and "singleIsoMu20eta2p1Pass":
            warnings.warn( "EMTree: Expected branch singleIsoMu20eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Pass")
        else:
            self.singleIsoMu20eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Pass_value)

        #print "making singleIsoMu20eta2p1Prescale"
        self.singleIsoMu20eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu20eta2p1Prescale")
        #if not self.singleIsoMu20eta2p1Prescale_branch and "singleIsoMu20eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu20eta2p1Prescale_branch and "singleIsoMu20eta2p1Prescale":
            warnings.warn( "EMTree: Expected branch singleIsoMu20eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu20eta2p1Prescale")
        else:
            self.singleIsoMu20eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu20eta2p1Prescale_value)

        #print "making singleIsoMu24Group"
        self.singleIsoMu24Group_branch = the_tree.GetBranch("singleIsoMu24Group")
        #if not self.singleIsoMu24Group_branch and "singleIsoMu24Group" not in self.complained:
        if not self.singleIsoMu24Group_branch and "singleIsoMu24Group":
            warnings.warn( "EMTree: Expected branch singleIsoMu24Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Group")
        else:
            self.singleIsoMu24Group_branch.SetAddress(<void*>&self.singleIsoMu24Group_value)

        #print "making singleIsoMu24Pass"
        self.singleIsoMu24Pass_branch = the_tree.GetBranch("singleIsoMu24Pass")
        #if not self.singleIsoMu24Pass_branch and "singleIsoMu24Pass" not in self.complained:
        if not self.singleIsoMu24Pass_branch and "singleIsoMu24Pass":
            warnings.warn( "EMTree: Expected branch singleIsoMu24Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Pass")
        else:
            self.singleIsoMu24Pass_branch.SetAddress(<void*>&self.singleIsoMu24Pass_value)

        #print "making singleIsoMu24Prescale"
        self.singleIsoMu24Prescale_branch = the_tree.GetBranch("singleIsoMu24Prescale")
        #if not self.singleIsoMu24Prescale_branch and "singleIsoMu24Prescale" not in self.complained:
        if not self.singleIsoMu24Prescale_branch and "singleIsoMu24Prescale":
            warnings.warn( "EMTree: Expected branch singleIsoMu24Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24Prescale")
        else:
            self.singleIsoMu24Prescale_branch.SetAddress(<void*>&self.singleIsoMu24Prescale_value)

        #print "making singleIsoMu24eta2p1Group"
        self.singleIsoMu24eta2p1Group_branch = the_tree.GetBranch("singleIsoMu24eta2p1Group")
        #if not self.singleIsoMu24eta2p1Group_branch and "singleIsoMu24eta2p1Group" not in self.complained:
        if not self.singleIsoMu24eta2p1Group_branch and "singleIsoMu24eta2p1Group":
            warnings.warn( "EMTree: Expected branch singleIsoMu24eta2p1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Group")
        else:
            self.singleIsoMu24eta2p1Group_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Group_value)

        #print "making singleIsoMu24eta2p1Pass"
        self.singleIsoMu24eta2p1Pass_branch = the_tree.GetBranch("singleIsoMu24eta2p1Pass")
        #if not self.singleIsoMu24eta2p1Pass_branch and "singleIsoMu24eta2p1Pass" not in self.complained:
        if not self.singleIsoMu24eta2p1Pass_branch and "singleIsoMu24eta2p1Pass":
            warnings.warn( "EMTree: Expected branch singleIsoMu24eta2p1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Pass")
        else:
            self.singleIsoMu24eta2p1Pass_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Pass_value)

        #print "making singleIsoMu24eta2p1Prescale"
        self.singleIsoMu24eta2p1Prescale_branch = the_tree.GetBranch("singleIsoMu24eta2p1Prescale")
        #if not self.singleIsoMu24eta2p1Prescale_branch and "singleIsoMu24eta2p1Prescale" not in self.complained:
        if not self.singleIsoMu24eta2p1Prescale_branch and "singleIsoMu24eta2p1Prescale":
            warnings.warn( "EMTree: Expected branch singleIsoMu24eta2p1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu24eta2p1Prescale")
        else:
            self.singleIsoMu24eta2p1Prescale_branch.SetAddress(<void*>&self.singleIsoMu24eta2p1Prescale_value)

        #print "making singleIsoMu27Group"
        self.singleIsoMu27Group_branch = the_tree.GetBranch("singleIsoMu27Group")
        #if not self.singleIsoMu27Group_branch and "singleIsoMu27Group" not in self.complained:
        if not self.singleIsoMu27Group_branch and "singleIsoMu27Group":
            warnings.warn( "EMTree: Expected branch singleIsoMu27Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu27Group")
        else:
            self.singleIsoMu27Group_branch.SetAddress(<void*>&self.singleIsoMu27Group_value)

        #print "making singleIsoMu27Pass"
        self.singleIsoMu27Pass_branch = the_tree.GetBranch("singleIsoMu27Pass")
        #if not self.singleIsoMu27Pass_branch and "singleIsoMu27Pass" not in self.complained:
        if not self.singleIsoMu27Pass_branch and "singleIsoMu27Pass":
            warnings.warn( "EMTree: Expected branch singleIsoMu27Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu27Pass")
        else:
            self.singleIsoMu27Pass_branch.SetAddress(<void*>&self.singleIsoMu27Pass_value)

        #print "making singleIsoMu27Prescale"
        self.singleIsoMu27Prescale_branch = the_tree.GetBranch("singleIsoMu27Prescale")
        #if not self.singleIsoMu27Prescale_branch and "singleIsoMu27Prescale" not in self.complained:
        if not self.singleIsoMu27Prescale_branch and "singleIsoMu27Prescale":
            warnings.warn( "EMTree: Expected branch singleIsoMu27Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoMu27Prescale")
        else:
            self.singleIsoMu27Prescale_branch.SetAddress(<void*>&self.singleIsoMu27Prescale_value)

        #print "making singleIsoTkMu20Group"
        self.singleIsoTkMu20Group_branch = the_tree.GetBranch("singleIsoTkMu20Group")
        #if not self.singleIsoTkMu20Group_branch and "singleIsoTkMu20Group" not in self.complained:
        if not self.singleIsoTkMu20Group_branch and "singleIsoTkMu20Group":
            warnings.warn( "EMTree: Expected branch singleIsoTkMu20Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Group")
        else:
            self.singleIsoTkMu20Group_branch.SetAddress(<void*>&self.singleIsoTkMu20Group_value)

        #print "making singleIsoTkMu20Pass"
        self.singleIsoTkMu20Pass_branch = the_tree.GetBranch("singleIsoTkMu20Pass")
        #if not self.singleIsoTkMu20Pass_branch and "singleIsoTkMu20Pass" not in self.complained:
        if not self.singleIsoTkMu20Pass_branch and "singleIsoTkMu20Pass":
            warnings.warn( "EMTree: Expected branch singleIsoTkMu20Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Pass")
        else:
            self.singleIsoTkMu20Pass_branch.SetAddress(<void*>&self.singleIsoTkMu20Pass_value)

        #print "making singleIsoTkMu20Prescale"
        self.singleIsoTkMu20Prescale_branch = the_tree.GetBranch("singleIsoTkMu20Prescale")
        #if not self.singleIsoTkMu20Prescale_branch and "singleIsoTkMu20Prescale" not in self.complained:
        if not self.singleIsoTkMu20Prescale_branch and "singleIsoTkMu20Prescale":
            warnings.warn( "EMTree: Expected branch singleIsoTkMu20Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleIsoTkMu20Prescale")
        else:
            self.singleIsoTkMu20Prescale_branch.SetAddress(<void*>&self.singleIsoTkMu20Prescale_value)

        #print "making singleMu17SingleE12Group"
        self.singleMu17SingleE12Group_branch = the_tree.GetBranch("singleMu17SingleE12Group")
        #if not self.singleMu17SingleE12Group_branch and "singleMu17SingleE12Group" not in self.complained:
        if not self.singleMu17SingleE12Group_branch and "singleMu17SingleE12Group":
            warnings.warn( "EMTree: Expected branch singleMu17SingleE12Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Group")
        else:
            self.singleMu17SingleE12Group_branch.SetAddress(<void*>&self.singleMu17SingleE12Group_value)

        #print "making singleMu17SingleE12Pass"
        self.singleMu17SingleE12Pass_branch = the_tree.GetBranch("singleMu17SingleE12Pass")
        #if not self.singleMu17SingleE12Pass_branch and "singleMu17SingleE12Pass" not in self.complained:
        if not self.singleMu17SingleE12Pass_branch and "singleMu17SingleE12Pass":
            warnings.warn( "EMTree: Expected branch singleMu17SingleE12Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Pass")
        else:
            self.singleMu17SingleE12Pass_branch.SetAddress(<void*>&self.singleMu17SingleE12Pass_value)

        #print "making singleMu17SingleE12Prescale"
        self.singleMu17SingleE12Prescale_branch = the_tree.GetBranch("singleMu17SingleE12Prescale")
        #if not self.singleMu17SingleE12Prescale_branch and "singleMu17SingleE12Prescale" not in self.complained:
        if not self.singleMu17SingleE12Prescale_branch and "singleMu17SingleE12Prescale":
            warnings.warn( "EMTree: Expected branch singleMu17SingleE12Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu17SingleE12Prescale")
        else:
            self.singleMu17SingleE12Prescale_branch.SetAddress(<void*>&self.singleMu17SingleE12Prescale_value)

        #print "making singleMu23SingleE12Group"
        self.singleMu23SingleE12Group_branch = the_tree.GetBranch("singleMu23SingleE12Group")
        #if not self.singleMu23SingleE12Group_branch and "singleMu23SingleE12Group" not in self.complained:
        if not self.singleMu23SingleE12Group_branch and "singleMu23SingleE12Group":
            warnings.warn( "EMTree: Expected branch singleMu23SingleE12Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Group")
        else:
            self.singleMu23SingleE12Group_branch.SetAddress(<void*>&self.singleMu23SingleE12Group_value)

        #print "making singleMu23SingleE12Pass"
        self.singleMu23SingleE12Pass_branch = the_tree.GetBranch("singleMu23SingleE12Pass")
        #if not self.singleMu23SingleE12Pass_branch and "singleMu23SingleE12Pass" not in self.complained:
        if not self.singleMu23SingleE12Pass_branch and "singleMu23SingleE12Pass":
            warnings.warn( "EMTree: Expected branch singleMu23SingleE12Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Pass")
        else:
            self.singleMu23SingleE12Pass_branch.SetAddress(<void*>&self.singleMu23SingleE12Pass_value)

        #print "making singleMu23SingleE12Prescale"
        self.singleMu23SingleE12Prescale_branch = the_tree.GetBranch("singleMu23SingleE12Prescale")
        #if not self.singleMu23SingleE12Prescale_branch and "singleMu23SingleE12Prescale" not in self.complained:
        if not self.singleMu23SingleE12Prescale_branch and "singleMu23SingleE12Prescale":
            warnings.warn( "EMTree: Expected branch singleMu23SingleE12Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu23SingleE12Prescale")
        else:
            self.singleMu23SingleE12Prescale_branch.SetAddress(<void*>&self.singleMu23SingleE12Prescale_value)

        #print "making singleMuGroup"
        self.singleMuGroup_branch = the_tree.GetBranch("singleMuGroup")
        #if not self.singleMuGroup_branch and "singleMuGroup" not in self.complained:
        if not self.singleMuGroup_branch and "singleMuGroup":
            warnings.warn( "EMTree: Expected branch singleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuGroup")
        else:
            self.singleMuGroup_branch.SetAddress(<void*>&self.singleMuGroup_value)

        #print "making singleMuPass"
        self.singleMuPass_branch = the_tree.GetBranch("singleMuPass")
        #if not self.singleMuPass_branch and "singleMuPass" not in self.complained:
        if not self.singleMuPass_branch and "singleMuPass":
            warnings.warn( "EMTree: Expected branch singleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuPass")
        else:
            self.singleMuPass_branch.SetAddress(<void*>&self.singleMuPass_value)

        #print "making singleMuPrescale"
        self.singleMuPrescale_branch = the_tree.GetBranch("singleMuPrescale")
        #if not self.singleMuPrescale_branch and "singleMuPrescale" not in self.complained:
        if not self.singleMuPrescale_branch and "singleMuPrescale":
            warnings.warn( "EMTree: Expected branch singleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuPrescale")
        else:
            self.singleMuPrescale_branch.SetAddress(<void*>&self.singleMuPrescale_value)

        #print "making singleMuSingleEGroup"
        self.singleMuSingleEGroup_branch = the_tree.GetBranch("singleMuSingleEGroup")
        #if not self.singleMuSingleEGroup_branch and "singleMuSingleEGroup" not in self.complained:
        if not self.singleMuSingleEGroup_branch and "singleMuSingleEGroup":
            warnings.warn( "EMTree: Expected branch singleMuSingleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEGroup")
        else:
            self.singleMuSingleEGroup_branch.SetAddress(<void*>&self.singleMuSingleEGroup_value)

        #print "making singleMuSingleEPass"
        self.singleMuSingleEPass_branch = the_tree.GetBranch("singleMuSingleEPass")
        #if not self.singleMuSingleEPass_branch and "singleMuSingleEPass" not in self.complained:
        if not self.singleMuSingleEPass_branch and "singleMuSingleEPass":
            warnings.warn( "EMTree: Expected branch singleMuSingleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEPass")
        else:
            self.singleMuSingleEPass_branch.SetAddress(<void*>&self.singleMuSingleEPass_value)

        #print "making singleMuSingleEPrescale"
        self.singleMuSingleEPrescale_branch = the_tree.GetBranch("singleMuSingleEPrescale")
        #if not self.singleMuSingleEPrescale_branch and "singleMuSingleEPrescale" not in self.complained:
        if not self.singleMuSingleEPrescale_branch and "singleMuSingleEPrescale":
            warnings.warn( "EMTree: Expected branch singleMuSingleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMuSingleEPrescale")
        else:
            self.singleMuSingleEPrescale_branch.SetAddress(<void*>&self.singleMuSingleEPrescale_value)

        #print "making singleMu_leg1Group"
        self.singleMu_leg1Group_branch = the_tree.GetBranch("singleMu_leg1Group")
        #if not self.singleMu_leg1Group_branch and "singleMu_leg1Group" not in self.complained:
        if not self.singleMu_leg1Group_branch and "singleMu_leg1Group":
            warnings.warn( "EMTree: Expected branch singleMu_leg1Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Group")
        else:
            self.singleMu_leg1Group_branch.SetAddress(<void*>&self.singleMu_leg1Group_value)

        #print "making singleMu_leg1Pass"
        self.singleMu_leg1Pass_branch = the_tree.GetBranch("singleMu_leg1Pass")
        #if not self.singleMu_leg1Pass_branch and "singleMu_leg1Pass" not in self.complained:
        if not self.singleMu_leg1Pass_branch and "singleMu_leg1Pass":
            warnings.warn( "EMTree: Expected branch singleMu_leg1Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Pass")
        else:
            self.singleMu_leg1Pass_branch.SetAddress(<void*>&self.singleMu_leg1Pass_value)

        #print "making singleMu_leg1Prescale"
        self.singleMu_leg1Prescale_branch = the_tree.GetBranch("singleMu_leg1Prescale")
        #if not self.singleMu_leg1Prescale_branch and "singleMu_leg1Prescale" not in self.complained:
        if not self.singleMu_leg1Prescale_branch and "singleMu_leg1Prescale":
            warnings.warn( "EMTree: Expected branch singleMu_leg1Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1Prescale")
        else:
            self.singleMu_leg1Prescale_branch.SetAddress(<void*>&self.singleMu_leg1Prescale_value)

        #print "making singleMu_leg1_noisoGroup"
        self.singleMu_leg1_noisoGroup_branch = the_tree.GetBranch("singleMu_leg1_noisoGroup")
        #if not self.singleMu_leg1_noisoGroup_branch and "singleMu_leg1_noisoGroup" not in self.complained:
        if not self.singleMu_leg1_noisoGroup_branch and "singleMu_leg1_noisoGroup":
            warnings.warn( "EMTree: Expected branch singleMu_leg1_noisoGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoGroup")
        else:
            self.singleMu_leg1_noisoGroup_branch.SetAddress(<void*>&self.singleMu_leg1_noisoGroup_value)

        #print "making singleMu_leg1_noisoPass"
        self.singleMu_leg1_noisoPass_branch = the_tree.GetBranch("singleMu_leg1_noisoPass")
        #if not self.singleMu_leg1_noisoPass_branch and "singleMu_leg1_noisoPass" not in self.complained:
        if not self.singleMu_leg1_noisoPass_branch and "singleMu_leg1_noisoPass":
            warnings.warn( "EMTree: Expected branch singleMu_leg1_noisoPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoPass")
        else:
            self.singleMu_leg1_noisoPass_branch.SetAddress(<void*>&self.singleMu_leg1_noisoPass_value)

        #print "making singleMu_leg1_noisoPrescale"
        self.singleMu_leg1_noisoPrescale_branch = the_tree.GetBranch("singleMu_leg1_noisoPrescale")
        #if not self.singleMu_leg1_noisoPrescale_branch and "singleMu_leg1_noisoPrescale" not in self.complained:
        if not self.singleMu_leg1_noisoPrescale_branch and "singleMu_leg1_noisoPrescale":
            warnings.warn( "EMTree: Expected branch singleMu_leg1_noisoPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg1_noisoPrescale")
        else:
            self.singleMu_leg1_noisoPrescale_branch.SetAddress(<void*>&self.singleMu_leg1_noisoPrescale_value)

        #print "making singleMu_leg2Group"
        self.singleMu_leg2Group_branch = the_tree.GetBranch("singleMu_leg2Group")
        #if not self.singleMu_leg2Group_branch and "singleMu_leg2Group" not in self.complained:
        if not self.singleMu_leg2Group_branch and "singleMu_leg2Group":
            warnings.warn( "EMTree: Expected branch singleMu_leg2Group does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Group")
        else:
            self.singleMu_leg2Group_branch.SetAddress(<void*>&self.singleMu_leg2Group_value)

        #print "making singleMu_leg2Pass"
        self.singleMu_leg2Pass_branch = the_tree.GetBranch("singleMu_leg2Pass")
        #if not self.singleMu_leg2Pass_branch and "singleMu_leg2Pass" not in self.complained:
        if not self.singleMu_leg2Pass_branch and "singleMu_leg2Pass":
            warnings.warn( "EMTree: Expected branch singleMu_leg2Pass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Pass")
        else:
            self.singleMu_leg2Pass_branch.SetAddress(<void*>&self.singleMu_leg2Pass_value)

        #print "making singleMu_leg2Prescale"
        self.singleMu_leg2Prescale_branch = the_tree.GetBranch("singleMu_leg2Prescale")
        #if not self.singleMu_leg2Prescale_branch and "singleMu_leg2Prescale" not in self.complained:
        if not self.singleMu_leg2Prescale_branch and "singleMu_leg2Prescale":
            warnings.warn( "EMTree: Expected branch singleMu_leg2Prescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2Prescale")
        else:
            self.singleMu_leg2Prescale_branch.SetAddress(<void*>&self.singleMu_leg2Prescale_value)

        #print "making singleMu_leg2_noisoGroup"
        self.singleMu_leg2_noisoGroup_branch = the_tree.GetBranch("singleMu_leg2_noisoGroup")
        #if not self.singleMu_leg2_noisoGroup_branch and "singleMu_leg2_noisoGroup" not in self.complained:
        if not self.singleMu_leg2_noisoGroup_branch and "singleMu_leg2_noisoGroup":
            warnings.warn( "EMTree: Expected branch singleMu_leg2_noisoGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoGroup")
        else:
            self.singleMu_leg2_noisoGroup_branch.SetAddress(<void*>&self.singleMu_leg2_noisoGroup_value)

        #print "making singleMu_leg2_noisoPass"
        self.singleMu_leg2_noisoPass_branch = the_tree.GetBranch("singleMu_leg2_noisoPass")
        #if not self.singleMu_leg2_noisoPass_branch and "singleMu_leg2_noisoPass" not in self.complained:
        if not self.singleMu_leg2_noisoPass_branch and "singleMu_leg2_noisoPass":
            warnings.warn( "EMTree: Expected branch singleMu_leg2_noisoPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoPass")
        else:
            self.singleMu_leg2_noisoPass_branch.SetAddress(<void*>&self.singleMu_leg2_noisoPass_value)

        #print "making singleMu_leg2_noisoPrescale"
        self.singleMu_leg2_noisoPrescale_branch = the_tree.GetBranch("singleMu_leg2_noisoPrescale")
        #if not self.singleMu_leg2_noisoPrescale_branch and "singleMu_leg2_noisoPrescale" not in self.complained:
        if not self.singleMu_leg2_noisoPrescale_branch and "singleMu_leg2_noisoPrescale":
            warnings.warn( "EMTree: Expected branch singleMu_leg2_noisoPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("singleMu_leg2_noisoPrescale")
        else:
            self.singleMu_leg2_noisoPrescale_branch.SetAddress(<void*>&self.singleMu_leg2_noisoPrescale_value)

        #print "making tauVetoPt20Loose3HitsNewDMVtx"
        self.tauVetoPt20Loose3HitsNewDMVtx_branch = the_tree.GetBranch("tauVetoPt20Loose3HitsNewDMVtx")
        #if not self.tauVetoPt20Loose3HitsNewDMVtx_branch and "tauVetoPt20Loose3HitsNewDMVtx" not in self.complained:
        if not self.tauVetoPt20Loose3HitsNewDMVtx_branch and "tauVetoPt20Loose3HitsNewDMVtx":
            warnings.warn( "EMTree: Expected branch tauVetoPt20Loose3HitsNewDMVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20Loose3HitsNewDMVtx")
        else:
            self.tauVetoPt20Loose3HitsNewDMVtx_branch.SetAddress(<void*>&self.tauVetoPt20Loose3HitsNewDMVtx_value)

        #print "making tauVetoPt20Loose3HitsVtx"
        self.tauVetoPt20Loose3HitsVtx_branch = the_tree.GetBranch("tauVetoPt20Loose3HitsVtx")
        #if not self.tauVetoPt20Loose3HitsVtx_branch and "tauVetoPt20Loose3HitsVtx" not in self.complained:
        if not self.tauVetoPt20Loose3HitsVtx_branch and "tauVetoPt20Loose3HitsVtx":
            warnings.warn( "EMTree: Expected branch tauVetoPt20Loose3HitsVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20Loose3HitsVtx")
        else:
            self.tauVetoPt20Loose3HitsVtx_branch.SetAddress(<void*>&self.tauVetoPt20Loose3HitsVtx_value)

        #print "making tauVetoPt20TightMVALTNewDMVtx"
        self.tauVetoPt20TightMVALTNewDMVtx_branch = the_tree.GetBranch("tauVetoPt20TightMVALTNewDMVtx")
        #if not self.tauVetoPt20TightMVALTNewDMVtx_branch and "tauVetoPt20TightMVALTNewDMVtx" not in self.complained:
        if not self.tauVetoPt20TightMVALTNewDMVtx_branch and "tauVetoPt20TightMVALTNewDMVtx":
            warnings.warn( "EMTree: Expected branch tauVetoPt20TightMVALTNewDMVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20TightMVALTNewDMVtx")
        else:
            self.tauVetoPt20TightMVALTNewDMVtx_branch.SetAddress(<void*>&self.tauVetoPt20TightMVALTNewDMVtx_value)

        #print "making tauVetoPt20TightMVALTVtx"
        self.tauVetoPt20TightMVALTVtx_branch = the_tree.GetBranch("tauVetoPt20TightMVALTVtx")
        #if not self.tauVetoPt20TightMVALTVtx_branch and "tauVetoPt20TightMVALTVtx" not in self.complained:
        if not self.tauVetoPt20TightMVALTVtx_branch and "tauVetoPt20TightMVALTVtx":
            warnings.warn( "EMTree: Expected branch tauVetoPt20TightMVALTVtx does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tauVetoPt20TightMVALTVtx")
        else:
            self.tauVetoPt20TightMVALTVtx_branch.SetAddress(<void*>&self.tauVetoPt20TightMVALTVtx_value)

        #print "making tripleEGroup"
        self.tripleEGroup_branch = the_tree.GetBranch("tripleEGroup")
        #if not self.tripleEGroup_branch and "tripleEGroup" not in self.complained:
        if not self.tripleEGroup_branch and "tripleEGroup":
            warnings.warn( "EMTree: Expected branch tripleEGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEGroup")
        else:
            self.tripleEGroup_branch.SetAddress(<void*>&self.tripleEGroup_value)

        #print "making tripleEPass"
        self.tripleEPass_branch = the_tree.GetBranch("tripleEPass")
        #if not self.tripleEPass_branch and "tripleEPass" not in self.complained:
        if not self.tripleEPass_branch and "tripleEPass":
            warnings.warn( "EMTree: Expected branch tripleEPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEPass")
        else:
            self.tripleEPass_branch.SetAddress(<void*>&self.tripleEPass_value)

        #print "making tripleEPrescale"
        self.tripleEPrescale_branch = the_tree.GetBranch("tripleEPrescale")
        #if not self.tripleEPrescale_branch and "tripleEPrescale" not in self.complained:
        if not self.tripleEPrescale_branch and "tripleEPrescale":
            warnings.warn( "EMTree: Expected branch tripleEPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleEPrescale")
        else:
            self.tripleEPrescale_branch.SetAddress(<void*>&self.tripleEPrescale_value)

        #print "making tripleMuGroup"
        self.tripleMuGroup_branch = the_tree.GetBranch("tripleMuGroup")
        #if not self.tripleMuGroup_branch and "tripleMuGroup" not in self.complained:
        if not self.tripleMuGroup_branch and "tripleMuGroup":
            warnings.warn( "EMTree: Expected branch tripleMuGroup does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuGroup")
        else:
            self.tripleMuGroup_branch.SetAddress(<void*>&self.tripleMuGroup_value)

        #print "making tripleMuPass"
        self.tripleMuPass_branch = the_tree.GetBranch("tripleMuPass")
        #if not self.tripleMuPass_branch and "tripleMuPass" not in self.complained:
        if not self.tripleMuPass_branch and "tripleMuPass":
            warnings.warn( "EMTree: Expected branch tripleMuPass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuPass")
        else:
            self.tripleMuPass_branch.SetAddress(<void*>&self.tripleMuPass_value)

        #print "making tripleMuPrescale"
        self.tripleMuPrescale_branch = the_tree.GetBranch("tripleMuPrescale")
        #if not self.tripleMuPrescale_branch and "tripleMuPrescale" not in self.complained:
        if not self.tripleMuPrescale_branch and "tripleMuPrescale":
            warnings.warn( "EMTree: Expected branch tripleMuPrescale does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("tripleMuPrescale")
        else:
            self.tripleMuPrescale_branch.SetAddress(<void*>&self.tripleMuPrescale_value)

        #print "making type1_pfMetEt"
        self.type1_pfMetEt_branch = the_tree.GetBranch("type1_pfMetEt")
        #if not self.type1_pfMetEt_branch and "type1_pfMetEt" not in self.complained:
        if not self.type1_pfMetEt_branch and "type1_pfMetEt":
            warnings.warn( "EMTree: Expected branch type1_pfMetEt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMetEt")
        else:
            self.type1_pfMetEt_branch.SetAddress(<void*>&self.type1_pfMetEt_value)

        #print "making type1_pfMetPhi"
        self.type1_pfMetPhi_branch = the_tree.GetBranch("type1_pfMetPhi")
        #if not self.type1_pfMetPhi_branch and "type1_pfMetPhi" not in self.complained:
        if not self.type1_pfMetPhi_branch and "type1_pfMetPhi":
            warnings.warn( "EMTree: Expected branch type1_pfMetPhi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMetPhi")
        else:
            self.type1_pfMetPhi_branch.SetAddress(<void*>&self.type1_pfMetPhi_value)

        #print "making type1_pfMet_shiftedPhi_ElectronEnDown"
        self.type1_pfMet_shiftedPhi_ElectronEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_ElectronEnDown")
        #if not self.type1_pfMet_shiftedPhi_ElectronEnDown_branch and "type1_pfMet_shiftedPhi_ElectronEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_ElectronEnDown_branch and "type1_pfMet_shiftedPhi_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_ElectronEnDown")
        else:
            self.type1_pfMet_shiftedPhi_ElectronEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_ElectronEnDown_value)

        #print "making type1_pfMet_shiftedPhi_ElectronEnUp"
        self.type1_pfMet_shiftedPhi_ElectronEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_ElectronEnUp")
        #if not self.type1_pfMet_shiftedPhi_ElectronEnUp_branch and "type1_pfMet_shiftedPhi_ElectronEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_ElectronEnUp_branch and "type1_pfMet_shiftedPhi_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_ElectronEnUp")
        else:
            self.type1_pfMet_shiftedPhi_ElectronEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_ElectronEnUp_value)

        #print "making type1_pfMet_shiftedPhi_JetEnDown"
        self.type1_pfMet_shiftedPhi_JetEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetEnDown")
        #if not self.type1_pfMet_shiftedPhi_JetEnDown_branch and "type1_pfMet_shiftedPhi_JetEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetEnDown_branch and "type1_pfMet_shiftedPhi_JetEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetEnDown")
        else:
            self.type1_pfMet_shiftedPhi_JetEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetEnDown_value)

        #print "making type1_pfMet_shiftedPhi_JetEnUp"
        self.type1_pfMet_shiftedPhi_JetEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetEnUp")
        #if not self.type1_pfMet_shiftedPhi_JetEnUp_branch and "type1_pfMet_shiftedPhi_JetEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetEnUp_branch and "type1_pfMet_shiftedPhi_JetEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetEnUp")
        else:
            self.type1_pfMet_shiftedPhi_JetEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetEnUp_value)

        #print "making type1_pfMet_shiftedPhi_JetResDown"
        self.type1_pfMet_shiftedPhi_JetResDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetResDown")
        #if not self.type1_pfMet_shiftedPhi_JetResDown_branch and "type1_pfMet_shiftedPhi_JetResDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetResDown_branch and "type1_pfMet_shiftedPhi_JetResDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetResDown")
        else:
            self.type1_pfMet_shiftedPhi_JetResDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetResDown_value)

        #print "making type1_pfMet_shiftedPhi_JetResUp"
        self.type1_pfMet_shiftedPhi_JetResUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_JetResUp")
        #if not self.type1_pfMet_shiftedPhi_JetResUp_branch and "type1_pfMet_shiftedPhi_JetResUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_JetResUp_branch and "type1_pfMet_shiftedPhi_JetResUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_JetResUp")
        else:
            self.type1_pfMet_shiftedPhi_JetResUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_JetResUp_value)

        #print "making type1_pfMet_shiftedPhi_MuonEnDown"
        self.type1_pfMet_shiftedPhi_MuonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_MuonEnDown")
        #if not self.type1_pfMet_shiftedPhi_MuonEnDown_branch and "type1_pfMet_shiftedPhi_MuonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_MuonEnDown_branch and "type1_pfMet_shiftedPhi_MuonEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_MuonEnDown")
        else:
            self.type1_pfMet_shiftedPhi_MuonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_MuonEnDown_value)

        #print "making type1_pfMet_shiftedPhi_MuonEnUp"
        self.type1_pfMet_shiftedPhi_MuonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_MuonEnUp")
        #if not self.type1_pfMet_shiftedPhi_MuonEnUp_branch and "type1_pfMet_shiftedPhi_MuonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_MuonEnUp_branch and "type1_pfMet_shiftedPhi_MuonEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_MuonEnUp")
        else:
            self.type1_pfMet_shiftedPhi_MuonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_MuonEnUp_value)

        #print "making type1_pfMet_shiftedPhi_PhotonEnDown"
        self.type1_pfMet_shiftedPhi_PhotonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_PhotonEnDown")
        #if not self.type1_pfMet_shiftedPhi_PhotonEnDown_branch and "type1_pfMet_shiftedPhi_PhotonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_PhotonEnDown_branch and "type1_pfMet_shiftedPhi_PhotonEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_PhotonEnDown")
        else:
            self.type1_pfMet_shiftedPhi_PhotonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_PhotonEnDown_value)

        #print "making type1_pfMet_shiftedPhi_PhotonEnUp"
        self.type1_pfMet_shiftedPhi_PhotonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_PhotonEnUp")
        #if not self.type1_pfMet_shiftedPhi_PhotonEnUp_branch and "type1_pfMet_shiftedPhi_PhotonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_PhotonEnUp_branch and "type1_pfMet_shiftedPhi_PhotonEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_PhotonEnUp")
        else:
            self.type1_pfMet_shiftedPhi_PhotonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_PhotonEnUp_value)

        #print "making type1_pfMet_shiftedPhi_TauEnDown"
        self.type1_pfMet_shiftedPhi_TauEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_TauEnDown")
        #if not self.type1_pfMet_shiftedPhi_TauEnDown_branch and "type1_pfMet_shiftedPhi_TauEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_TauEnDown_branch and "type1_pfMet_shiftedPhi_TauEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_TauEnDown")
        else:
            self.type1_pfMet_shiftedPhi_TauEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_TauEnDown_value)

        #print "making type1_pfMet_shiftedPhi_TauEnUp"
        self.type1_pfMet_shiftedPhi_TauEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_TauEnUp")
        #if not self.type1_pfMet_shiftedPhi_TauEnUp_branch and "type1_pfMet_shiftedPhi_TauEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_TauEnUp_branch and "type1_pfMet_shiftedPhi_TauEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_TauEnUp")
        else:
            self.type1_pfMet_shiftedPhi_TauEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_TauEnUp_value)

        #print "making type1_pfMet_shiftedPhi_UnclusteredEnDown"
        self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_UnclusteredEnDown")
        #if not self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch and "type1_pfMet_shiftedPhi_UnclusteredEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch and "type1_pfMet_shiftedPhi_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_UnclusteredEnDown")
        else:
            self.type1_pfMet_shiftedPhi_UnclusteredEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_UnclusteredEnDown_value)

        #print "making type1_pfMet_shiftedPhi_UnclusteredEnUp"
        self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPhi_UnclusteredEnUp")
        #if not self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch and "type1_pfMet_shiftedPhi_UnclusteredEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch and "type1_pfMet_shiftedPhi_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPhi_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPhi_UnclusteredEnUp")
        else:
            self.type1_pfMet_shiftedPhi_UnclusteredEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPhi_UnclusteredEnUp_value)

        #print "making type1_pfMet_shiftedPt_ElectronEnDown"
        self.type1_pfMet_shiftedPt_ElectronEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_ElectronEnDown")
        #if not self.type1_pfMet_shiftedPt_ElectronEnDown_branch and "type1_pfMet_shiftedPt_ElectronEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_ElectronEnDown_branch and "type1_pfMet_shiftedPt_ElectronEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_ElectronEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_ElectronEnDown")
        else:
            self.type1_pfMet_shiftedPt_ElectronEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_ElectronEnDown_value)

        #print "making type1_pfMet_shiftedPt_ElectronEnUp"
        self.type1_pfMet_shiftedPt_ElectronEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_ElectronEnUp")
        #if not self.type1_pfMet_shiftedPt_ElectronEnUp_branch and "type1_pfMet_shiftedPt_ElectronEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_ElectronEnUp_branch and "type1_pfMet_shiftedPt_ElectronEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_ElectronEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_ElectronEnUp")
        else:
            self.type1_pfMet_shiftedPt_ElectronEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_ElectronEnUp_value)

        #print "making type1_pfMet_shiftedPt_JetEnDown"
        self.type1_pfMet_shiftedPt_JetEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetEnDown")
        #if not self.type1_pfMet_shiftedPt_JetEnDown_branch and "type1_pfMet_shiftedPt_JetEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetEnDown_branch and "type1_pfMet_shiftedPt_JetEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetEnDown")
        else:
            self.type1_pfMet_shiftedPt_JetEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetEnDown_value)

        #print "making type1_pfMet_shiftedPt_JetEnUp"
        self.type1_pfMet_shiftedPt_JetEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetEnUp")
        #if not self.type1_pfMet_shiftedPt_JetEnUp_branch and "type1_pfMet_shiftedPt_JetEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetEnUp_branch and "type1_pfMet_shiftedPt_JetEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetEnUp")
        else:
            self.type1_pfMet_shiftedPt_JetEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetEnUp_value)

        #print "making type1_pfMet_shiftedPt_JetResDown"
        self.type1_pfMet_shiftedPt_JetResDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetResDown")
        #if not self.type1_pfMet_shiftedPt_JetResDown_branch and "type1_pfMet_shiftedPt_JetResDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetResDown_branch and "type1_pfMet_shiftedPt_JetResDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_JetResDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetResDown")
        else:
            self.type1_pfMet_shiftedPt_JetResDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetResDown_value)

        #print "making type1_pfMet_shiftedPt_JetResUp"
        self.type1_pfMet_shiftedPt_JetResUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_JetResUp")
        #if not self.type1_pfMet_shiftedPt_JetResUp_branch and "type1_pfMet_shiftedPt_JetResUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_JetResUp_branch and "type1_pfMet_shiftedPt_JetResUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_JetResUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_JetResUp")
        else:
            self.type1_pfMet_shiftedPt_JetResUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_JetResUp_value)

        #print "making type1_pfMet_shiftedPt_MuonEnDown"
        self.type1_pfMet_shiftedPt_MuonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_MuonEnDown")
        #if not self.type1_pfMet_shiftedPt_MuonEnDown_branch and "type1_pfMet_shiftedPt_MuonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_MuonEnDown_branch and "type1_pfMet_shiftedPt_MuonEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_MuonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_MuonEnDown")
        else:
            self.type1_pfMet_shiftedPt_MuonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_MuonEnDown_value)

        #print "making type1_pfMet_shiftedPt_MuonEnUp"
        self.type1_pfMet_shiftedPt_MuonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_MuonEnUp")
        #if not self.type1_pfMet_shiftedPt_MuonEnUp_branch and "type1_pfMet_shiftedPt_MuonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_MuonEnUp_branch and "type1_pfMet_shiftedPt_MuonEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_MuonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_MuonEnUp")
        else:
            self.type1_pfMet_shiftedPt_MuonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_MuonEnUp_value)

        #print "making type1_pfMet_shiftedPt_PhotonEnDown"
        self.type1_pfMet_shiftedPt_PhotonEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_PhotonEnDown")
        #if not self.type1_pfMet_shiftedPt_PhotonEnDown_branch and "type1_pfMet_shiftedPt_PhotonEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_PhotonEnDown_branch and "type1_pfMet_shiftedPt_PhotonEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_PhotonEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_PhotonEnDown")
        else:
            self.type1_pfMet_shiftedPt_PhotonEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_PhotonEnDown_value)

        #print "making type1_pfMet_shiftedPt_PhotonEnUp"
        self.type1_pfMet_shiftedPt_PhotonEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_PhotonEnUp")
        #if not self.type1_pfMet_shiftedPt_PhotonEnUp_branch and "type1_pfMet_shiftedPt_PhotonEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_PhotonEnUp_branch and "type1_pfMet_shiftedPt_PhotonEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_PhotonEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_PhotonEnUp")
        else:
            self.type1_pfMet_shiftedPt_PhotonEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_PhotonEnUp_value)

        #print "making type1_pfMet_shiftedPt_TauEnDown"
        self.type1_pfMet_shiftedPt_TauEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_TauEnDown")
        #if not self.type1_pfMet_shiftedPt_TauEnDown_branch and "type1_pfMet_shiftedPt_TauEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_TauEnDown_branch and "type1_pfMet_shiftedPt_TauEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_TauEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_TauEnDown")
        else:
            self.type1_pfMet_shiftedPt_TauEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_TauEnDown_value)

        #print "making type1_pfMet_shiftedPt_TauEnUp"
        self.type1_pfMet_shiftedPt_TauEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_TauEnUp")
        #if not self.type1_pfMet_shiftedPt_TauEnUp_branch and "type1_pfMet_shiftedPt_TauEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_TauEnUp_branch and "type1_pfMet_shiftedPt_TauEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_TauEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_TauEnUp")
        else:
            self.type1_pfMet_shiftedPt_TauEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_TauEnUp_value)

        #print "making type1_pfMet_shiftedPt_UnclusteredEnDown"
        self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_UnclusteredEnDown")
        #if not self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch and "type1_pfMet_shiftedPt_UnclusteredEnDown" not in self.complained:
        if not self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch and "type1_pfMet_shiftedPt_UnclusteredEnDown":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_UnclusteredEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_UnclusteredEnDown")
        else:
            self.type1_pfMet_shiftedPt_UnclusteredEnDown_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_UnclusteredEnDown_value)

        #print "making type1_pfMet_shiftedPt_UnclusteredEnUp"
        self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch = the_tree.GetBranch("type1_pfMet_shiftedPt_UnclusteredEnUp")
        #if not self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch and "type1_pfMet_shiftedPt_UnclusteredEnUp" not in self.complained:
        if not self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch and "type1_pfMet_shiftedPt_UnclusteredEnUp":
            warnings.warn( "EMTree: Expected branch type1_pfMet_shiftedPt_UnclusteredEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("type1_pfMet_shiftedPt_UnclusteredEnUp")
        else:
            self.type1_pfMet_shiftedPt_UnclusteredEnUp_branch.SetAddress(<void*>&self.type1_pfMet_shiftedPt_UnclusteredEnUp_value)

        #print "making vbfDeta"
        self.vbfDeta_branch = the_tree.GetBranch("vbfDeta")
        #if not self.vbfDeta_branch and "vbfDeta" not in self.complained:
        if not self.vbfDeta_branch and "vbfDeta":
            warnings.warn( "EMTree: Expected branch vbfDeta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta")
        else:
            self.vbfDeta_branch.SetAddress(<void*>&self.vbfDeta_value)

        #print "making vbfDeta_JetEnDown"
        self.vbfDeta_JetEnDown_branch = the_tree.GetBranch("vbfDeta_JetEnDown")
        #if not self.vbfDeta_JetEnDown_branch and "vbfDeta_JetEnDown" not in self.complained:
        if not self.vbfDeta_JetEnDown_branch and "vbfDeta_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfDeta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta_JetEnDown")
        else:
            self.vbfDeta_JetEnDown_branch.SetAddress(<void*>&self.vbfDeta_JetEnDown_value)

        #print "making vbfDeta_JetEnUp"
        self.vbfDeta_JetEnUp_branch = the_tree.GetBranch("vbfDeta_JetEnUp")
        #if not self.vbfDeta_JetEnUp_branch and "vbfDeta_JetEnUp" not in self.complained:
        if not self.vbfDeta_JetEnUp_branch and "vbfDeta_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfDeta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDeta_JetEnUp")
        else:
            self.vbfDeta_JetEnUp_branch.SetAddress(<void*>&self.vbfDeta_JetEnUp_value)

        #print "making vbfDijetrap"
        self.vbfDijetrap_branch = the_tree.GetBranch("vbfDijetrap")
        #if not self.vbfDijetrap_branch and "vbfDijetrap" not in self.complained:
        if not self.vbfDijetrap_branch and "vbfDijetrap":
            warnings.warn( "EMTree: Expected branch vbfDijetrap does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap")
        else:
            self.vbfDijetrap_branch.SetAddress(<void*>&self.vbfDijetrap_value)

        #print "making vbfDijetrap_JetEnDown"
        self.vbfDijetrap_JetEnDown_branch = the_tree.GetBranch("vbfDijetrap_JetEnDown")
        #if not self.vbfDijetrap_JetEnDown_branch and "vbfDijetrap_JetEnDown" not in self.complained:
        if not self.vbfDijetrap_JetEnDown_branch and "vbfDijetrap_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfDijetrap_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap_JetEnDown")
        else:
            self.vbfDijetrap_JetEnDown_branch.SetAddress(<void*>&self.vbfDijetrap_JetEnDown_value)

        #print "making vbfDijetrap_JetEnUp"
        self.vbfDijetrap_JetEnUp_branch = the_tree.GetBranch("vbfDijetrap_JetEnUp")
        #if not self.vbfDijetrap_JetEnUp_branch and "vbfDijetrap_JetEnUp" not in self.complained:
        if not self.vbfDijetrap_JetEnUp_branch and "vbfDijetrap_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfDijetrap_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDijetrap_JetEnUp")
        else:
            self.vbfDijetrap_JetEnUp_branch.SetAddress(<void*>&self.vbfDijetrap_JetEnUp_value)

        #print "making vbfDphi"
        self.vbfDphi_branch = the_tree.GetBranch("vbfDphi")
        #if not self.vbfDphi_branch and "vbfDphi" not in self.complained:
        if not self.vbfDphi_branch and "vbfDphi":
            warnings.warn( "EMTree: Expected branch vbfDphi does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi")
        else:
            self.vbfDphi_branch.SetAddress(<void*>&self.vbfDphi_value)

        #print "making vbfDphi_JetEnDown"
        self.vbfDphi_JetEnDown_branch = the_tree.GetBranch("vbfDphi_JetEnDown")
        #if not self.vbfDphi_JetEnDown_branch and "vbfDphi_JetEnDown" not in self.complained:
        if not self.vbfDphi_JetEnDown_branch and "vbfDphi_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfDphi_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi_JetEnDown")
        else:
            self.vbfDphi_JetEnDown_branch.SetAddress(<void*>&self.vbfDphi_JetEnDown_value)

        #print "making vbfDphi_JetEnUp"
        self.vbfDphi_JetEnUp_branch = the_tree.GetBranch("vbfDphi_JetEnUp")
        #if not self.vbfDphi_JetEnUp_branch and "vbfDphi_JetEnUp" not in self.complained:
        if not self.vbfDphi_JetEnUp_branch and "vbfDphi_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfDphi_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphi_JetEnUp")
        else:
            self.vbfDphi_JetEnUp_branch.SetAddress(<void*>&self.vbfDphi_JetEnUp_value)

        #print "making vbfDphihj"
        self.vbfDphihj_branch = the_tree.GetBranch("vbfDphihj")
        #if not self.vbfDphihj_branch and "vbfDphihj" not in self.complained:
        if not self.vbfDphihj_branch and "vbfDphihj":
            warnings.warn( "EMTree: Expected branch vbfDphihj does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj")
        else:
            self.vbfDphihj_branch.SetAddress(<void*>&self.vbfDphihj_value)

        #print "making vbfDphihj_JetEnDown"
        self.vbfDphihj_JetEnDown_branch = the_tree.GetBranch("vbfDphihj_JetEnDown")
        #if not self.vbfDphihj_JetEnDown_branch and "vbfDphihj_JetEnDown" not in self.complained:
        if not self.vbfDphihj_JetEnDown_branch and "vbfDphihj_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfDphihj_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj_JetEnDown")
        else:
            self.vbfDphihj_JetEnDown_branch.SetAddress(<void*>&self.vbfDphihj_JetEnDown_value)

        #print "making vbfDphihj_JetEnUp"
        self.vbfDphihj_JetEnUp_branch = the_tree.GetBranch("vbfDphihj_JetEnUp")
        #if not self.vbfDphihj_JetEnUp_branch and "vbfDphihj_JetEnUp" not in self.complained:
        if not self.vbfDphihj_JetEnUp_branch and "vbfDphihj_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfDphihj_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihj_JetEnUp")
        else:
            self.vbfDphihj_JetEnUp_branch.SetAddress(<void*>&self.vbfDphihj_JetEnUp_value)

        #print "making vbfDphihjnomet"
        self.vbfDphihjnomet_branch = the_tree.GetBranch("vbfDphihjnomet")
        #if not self.vbfDphihjnomet_branch and "vbfDphihjnomet" not in self.complained:
        if not self.vbfDphihjnomet_branch and "vbfDphihjnomet":
            warnings.warn( "EMTree: Expected branch vbfDphihjnomet does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet")
        else:
            self.vbfDphihjnomet_branch.SetAddress(<void*>&self.vbfDphihjnomet_value)

        #print "making vbfDphihjnomet_JetEnDown"
        self.vbfDphihjnomet_JetEnDown_branch = the_tree.GetBranch("vbfDphihjnomet_JetEnDown")
        #if not self.vbfDphihjnomet_JetEnDown_branch and "vbfDphihjnomet_JetEnDown" not in self.complained:
        if not self.vbfDphihjnomet_JetEnDown_branch and "vbfDphihjnomet_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfDphihjnomet_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet_JetEnDown")
        else:
            self.vbfDphihjnomet_JetEnDown_branch.SetAddress(<void*>&self.vbfDphihjnomet_JetEnDown_value)

        #print "making vbfDphihjnomet_JetEnUp"
        self.vbfDphihjnomet_JetEnUp_branch = the_tree.GetBranch("vbfDphihjnomet_JetEnUp")
        #if not self.vbfDphihjnomet_JetEnUp_branch and "vbfDphihjnomet_JetEnUp" not in self.complained:
        if not self.vbfDphihjnomet_JetEnUp_branch and "vbfDphihjnomet_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfDphihjnomet_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfDphihjnomet_JetEnUp")
        else:
            self.vbfDphihjnomet_JetEnUp_branch.SetAddress(<void*>&self.vbfDphihjnomet_JetEnUp_value)

        #print "making vbfHrap"
        self.vbfHrap_branch = the_tree.GetBranch("vbfHrap")
        #if not self.vbfHrap_branch and "vbfHrap" not in self.complained:
        if not self.vbfHrap_branch and "vbfHrap":
            warnings.warn( "EMTree: Expected branch vbfHrap does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap")
        else:
            self.vbfHrap_branch.SetAddress(<void*>&self.vbfHrap_value)

        #print "making vbfHrap_JetEnDown"
        self.vbfHrap_JetEnDown_branch = the_tree.GetBranch("vbfHrap_JetEnDown")
        #if not self.vbfHrap_JetEnDown_branch and "vbfHrap_JetEnDown" not in self.complained:
        if not self.vbfHrap_JetEnDown_branch and "vbfHrap_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfHrap_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap_JetEnDown")
        else:
            self.vbfHrap_JetEnDown_branch.SetAddress(<void*>&self.vbfHrap_JetEnDown_value)

        #print "making vbfHrap_JetEnUp"
        self.vbfHrap_JetEnUp_branch = the_tree.GetBranch("vbfHrap_JetEnUp")
        #if not self.vbfHrap_JetEnUp_branch and "vbfHrap_JetEnUp" not in self.complained:
        if not self.vbfHrap_JetEnUp_branch and "vbfHrap_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfHrap_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfHrap_JetEnUp")
        else:
            self.vbfHrap_JetEnUp_branch.SetAddress(<void*>&self.vbfHrap_JetEnUp_value)

        #print "making vbfJetVeto20"
        self.vbfJetVeto20_branch = the_tree.GetBranch("vbfJetVeto20")
        #if not self.vbfJetVeto20_branch and "vbfJetVeto20" not in self.complained:
        if not self.vbfJetVeto20_branch and "vbfJetVeto20":
            warnings.warn( "EMTree: Expected branch vbfJetVeto20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20")
        else:
            self.vbfJetVeto20_branch.SetAddress(<void*>&self.vbfJetVeto20_value)

        #print "making vbfJetVeto20_JetEnDown"
        self.vbfJetVeto20_JetEnDown_branch = the_tree.GetBranch("vbfJetVeto20_JetEnDown")
        #if not self.vbfJetVeto20_JetEnDown_branch and "vbfJetVeto20_JetEnDown" not in self.complained:
        if not self.vbfJetVeto20_JetEnDown_branch and "vbfJetVeto20_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfJetVeto20_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20_JetEnDown")
        else:
            self.vbfJetVeto20_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVeto20_JetEnDown_value)

        #print "making vbfJetVeto20_JetEnUp"
        self.vbfJetVeto20_JetEnUp_branch = the_tree.GetBranch("vbfJetVeto20_JetEnUp")
        #if not self.vbfJetVeto20_JetEnUp_branch and "vbfJetVeto20_JetEnUp" not in self.complained:
        if not self.vbfJetVeto20_JetEnUp_branch and "vbfJetVeto20_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfJetVeto20_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto20_JetEnUp")
        else:
            self.vbfJetVeto20_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVeto20_JetEnUp_value)

        #print "making vbfJetVeto30"
        self.vbfJetVeto30_branch = the_tree.GetBranch("vbfJetVeto30")
        #if not self.vbfJetVeto30_branch and "vbfJetVeto30" not in self.complained:
        if not self.vbfJetVeto30_branch and "vbfJetVeto30":
            warnings.warn( "EMTree: Expected branch vbfJetVeto30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30")
        else:
            self.vbfJetVeto30_branch.SetAddress(<void*>&self.vbfJetVeto30_value)

        #print "making vbfJetVeto30_JetEnDown"
        self.vbfJetVeto30_JetEnDown_branch = the_tree.GetBranch("vbfJetVeto30_JetEnDown")
        #if not self.vbfJetVeto30_JetEnDown_branch and "vbfJetVeto30_JetEnDown" not in self.complained:
        if not self.vbfJetVeto30_JetEnDown_branch and "vbfJetVeto30_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfJetVeto30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30_JetEnDown")
        else:
            self.vbfJetVeto30_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVeto30_JetEnDown_value)

        #print "making vbfJetVeto30_JetEnUp"
        self.vbfJetVeto30_JetEnUp_branch = the_tree.GetBranch("vbfJetVeto30_JetEnUp")
        #if not self.vbfJetVeto30_JetEnUp_branch and "vbfJetVeto30_JetEnUp" not in self.complained:
        if not self.vbfJetVeto30_JetEnUp_branch and "vbfJetVeto30_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfJetVeto30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVeto30_JetEnUp")
        else:
            self.vbfJetVeto30_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVeto30_JetEnUp_value)

        #print "making vbfJetVetoTight20"
        self.vbfJetVetoTight20_branch = the_tree.GetBranch("vbfJetVetoTight20")
        #if not self.vbfJetVetoTight20_branch and "vbfJetVetoTight20" not in self.complained:
        if not self.vbfJetVetoTight20_branch and "vbfJetVetoTight20":
            warnings.warn( "EMTree: Expected branch vbfJetVetoTight20 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20")
        else:
            self.vbfJetVetoTight20_branch.SetAddress(<void*>&self.vbfJetVetoTight20_value)

        #print "making vbfJetVetoTight20_JetEnDown"
        self.vbfJetVetoTight20_JetEnDown_branch = the_tree.GetBranch("vbfJetVetoTight20_JetEnDown")
        #if not self.vbfJetVetoTight20_JetEnDown_branch and "vbfJetVetoTight20_JetEnDown" not in self.complained:
        if not self.vbfJetVetoTight20_JetEnDown_branch and "vbfJetVetoTight20_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfJetVetoTight20_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20_JetEnDown")
        else:
            self.vbfJetVetoTight20_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVetoTight20_JetEnDown_value)

        #print "making vbfJetVetoTight20_JetEnUp"
        self.vbfJetVetoTight20_JetEnUp_branch = the_tree.GetBranch("vbfJetVetoTight20_JetEnUp")
        #if not self.vbfJetVetoTight20_JetEnUp_branch and "vbfJetVetoTight20_JetEnUp" not in self.complained:
        if not self.vbfJetVetoTight20_JetEnUp_branch and "vbfJetVetoTight20_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfJetVetoTight20_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight20_JetEnUp")
        else:
            self.vbfJetVetoTight20_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVetoTight20_JetEnUp_value)

        #print "making vbfJetVetoTight30"
        self.vbfJetVetoTight30_branch = the_tree.GetBranch("vbfJetVetoTight30")
        #if not self.vbfJetVetoTight30_branch and "vbfJetVetoTight30" not in self.complained:
        if not self.vbfJetVetoTight30_branch and "vbfJetVetoTight30":
            warnings.warn( "EMTree: Expected branch vbfJetVetoTight30 does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30")
        else:
            self.vbfJetVetoTight30_branch.SetAddress(<void*>&self.vbfJetVetoTight30_value)

        #print "making vbfJetVetoTight30_JetEnDown"
        self.vbfJetVetoTight30_JetEnDown_branch = the_tree.GetBranch("vbfJetVetoTight30_JetEnDown")
        #if not self.vbfJetVetoTight30_JetEnDown_branch and "vbfJetVetoTight30_JetEnDown" not in self.complained:
        if not self.vbfJetVetoTight30_JetEnDown_branch and "vbfJetVetoTight30_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfJetVetoTight30_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30_JetEnDown")
        else:
            self.vbfJetVetoTight30_JetEnDown_branch.SetAddress(<void*>&self.vbfJetVetoTight30_JetEnDown_value)

        #print "making vbfJetVetoTight30_JetEnUp"
        self.vbfJetVetoTight30_JetEnUp_branch = the_tree.GetBranch("vbfJetVetoTight30_JetEnUp")
        #if not self.vbfJetVetoTight30_JetEnUp_branch and "vbfJetVetoTight30_JetEnUp" not in self.complained:
        if not self.vbfJetVetoTight30_JetEnUp_branch and "vbfJetVetoTight30_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfJetVetoTight30_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfJetVetoTight30_JetEnUp")
        else:
            self.vbfJetVetoTight30_JetEnUp_branch.SetAddress(<void*>&self.vbfJetVetoTight30_JetEnUp_value)

        #print "making vbfMVA"
        self.vbfMVA_branch = the_tree.GetBranch("vbfMVA")
        #if not self.vbfMVA_branch and "vbfMVA" not in self.complained:
        if not self.vbfMVA_branch and "vbfMVA":
            warnings.warn( "EMTree: Expected branch vbfMVA does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA")
        else:
            self.vbfMVA_branch.SetAddress(<void*>&self.vbfMVA_value)

        #print "making vbfMVA_JetEnDown"
        self.vbfMVA_JetEnDown_branch = the_tree.GetBranch("vbfMVA_JetEnDown")
        #if not self.vbfMVA_JetEnDown_branch and "vbfMVA_JetEnDown" not in self.complained:
        if not self.vbfMVA_JetEnDown_branch and "vbfMVA_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfMVA_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA_JetEnDown")
        else:
            self.vbfMVA_JetEnDown_branch.SetAddress(<void*>&self.vbfMVA_JetEnDown_value)

        #print "making vbfMVA_JetEnUp"
        self.vbfMVA_JetEnUp_branch = the_tree.GetBranch("vbfMVA_JetEnUp")
        #if not self.vbfMVA_JetEnUp_branch and "vbfMVA_JetEnUp" not in self.complained:
        if not self.vbfMVA_JetEnUp_branch and "vbfMVA_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfMVA_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMVA_JetEnUp")
        else:
            self.vbfMVA_JetEnUp_branch.SetAddress(<void*>&self.vbfMVA_JetEnUp_value)

        #print "making vbfMass"
        self.vbfMass_branch = the_tree.GetBranch("vbfMass")
        #if not self.vbfMass_branch and "vbfMass" not in self.complained:
        if not self.vbfMass_branch and "vbfMass":
            warnings.warn( "EMTree: Expected branch vbfMass does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass")
        else:
            self.vbfMass_branch.SetAddress(<void*>&self.vbfMass_value)

        #print "making vbfMass_JetEnDown"
        self.vbfMass_JetEnDown_branch = the_tree.GetBranch("vbfMass_JetEnDown")
        #if not self.vbfMass_JetEnDown_branch and "vbfMass_JetEnDown" not in self.complained:
        if not self.vbfMass_JetEnDown_branch and "vbfMass_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfMass_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass_JetEnDown")
        else:
            self.vbfMass_JetEnDown_branch.SetAddress(<void*>&self.vbfMass_JetEnDown_value)

        #print "making vbfMass_JetEnUp"
        self.vbfMass_JetEnUp_branch = the_tree.GetBranch("vbfMass_JetEnUp")
        #if not self.vbfMass_JetEnUp_branch and "vbfMass_JetEnUp" not in self.complained:
        if not self.vbfMass_JetEnUp_branch and "vbfMass_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfMass_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfMass_JetEnUp")
        else:
            self.vbfMass_JetEnUp_branch.SetAddress(<void*>&self.vbfMass_JetEnUp_value)

        #print "making vbfNJets"
        self.vbfNJets_branch = the_tree.GetBranch("vbfNJets")
        #if not self.vbfNJets_branch and "vbfNJets" not in self.complained:
        if not self.vbfNJets_branch and "vbfNJets":
            warnings.warn( "EMTree: Expected branch vbfNJets does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets")
        else:
            self.vbfNJets_branch.SetAddress(<void*>&self.vbfNJets_value)

        #print "making vbfNJets_JetEnDown"
        self.vbfNJets_JetEnDown_branch = the_tree.GetBranch("vbfNJets_JetEnDown")
        #if not self.vbfNJets_JetEnDown_branch and "vbfNJets_JetEnDown" not in self.complained:
        if not self.vbfNJets_JetEnDown_branch and "vbfNJets_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfNJets_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets_JetEnDown")
        else:
            self.vbfNJets_JetEnDown_branch.SetAddress(<void*>&self.vbfNJets_JetEnDown_value)

        #print "making vbfNJets_JetEnUp"
        self.vbfNJets_JetEnUp_branch = the_tree.GetBranch("vbfNJets_JetEnUp")
        #if not self.vbfNJets_JetEnUp_branch and "vbfNJets_JetEnUp" not in self.complained:
        if not self.vbfNJets_JetEnUp_branch and "vbfNJets_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfNJets_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfNJets_JetEnUp")
        else:
            self.vbfNJets_JetEnUp_branch.SetAddress(<void*>&self.vbfNJets_JetEnUp_value)

        #print "making vbfVispt"
        self.vbfVispt_branch = the_tree.GetBranch("vbfVispt")
        #if not self.vbfVispt_branch and "vbfVispt" not in self.complained:
        if not self.vbfVispt_branch and "vbfVispt":
            warnings.warn( "EMTree: Expected branch vbfVispt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt")
        else:
            self.vbfVispt_branch.SetAddress(<void*>&self.vbfVispt_value)

        #print "making vbfVispt_JetEnDown"
        self.vbfVispt_JetEnDown_branch = the_tree.GetBranch("vbfVispt_JetEnDown")
        #if not self.vbfVispt_JetEnDown_branch and "vbfVispt_JetEnDown" not in self.complained:
        if not self.vbfVispt_JetEnDown_branch and "vbfVispt_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfVispt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt_JetEnDown")
        else:
            self.vbfVispt_JetEnDown_branch.SetAddress(<void*>&self.vbfVispt_JetEnDown_value)

        #print "making vbfVispt_JetEnUp"
        self.vbfVispt_JetEnUp_branch = the_tree.GetBranch("vbfVispt_JetEnUp")
        #if not self.vbfVispt_JetEnUp_branch and "vbfVispt_JetEnUp" not in self.complained:
        if not self.vbfVispt_JetEnUp_branch and "vbfVispt_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfVispt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfVispt_JetEnUp")
        else:
            self.vbfVispt_JetEnUp_branch.SetAddress(<void*>&self.vbfVispt_JetEnUp_value)

        #print "making vbfdijetpt"
        self.vbfdijetpt_branch = the_tree.GetBranch("vbfdijetpt")
        #if not self.vbfdijetpt_branch and "vbfdijetpt" not in self.complained:
        if not self.vbfdijetpt_branch and "vbfdijetpt":
            warnings.warn( "EMTree: Expected branch vbfdijetpt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt")
        else:
            self.vbfdijetpt_branch.SetAddress(<void*>&self.vbfdijetpt_value)

        #print "making vbfdijetpt_JetEnDown"
        self.vbfdijetpt_JetEnDown_branch = the_tree.GetBranch("vbfdijetpt_JetEnDown")
        #if not self.vbfdijetpt_JetEnDown_branch and "vbfdijetpt_JetEnDown" not in self.complained:
        if not self.vbfdijetpt_JetEnDown_branch and "vbfdijetpt_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfdijetpt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt_JetEnDown")
        else:
            self.vbfdijetpt_JetEnDown_branch.SetAddress(<void*>&self.vbfdijetpt_JetEnDown_value)

        #print "making vbfdijetpt_JetEnUp"
        self.vbfdijetpt_JetEnUp_branch = the_tree.GetBranch("vbfdijetpt_JetEnUp")
        #if not self.vbfdijetpt_JetEnUp_branch and "vbfdijetpt_JetEnUp" not in self.complained:
        if not self.vbfdijetpt_JetEnUp_branch and "vbfdijetpt_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfdijetpt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfdijetpt_JetEnUp")
        else:
            self.vbfdijetpt_JetEnUp_branch.SetAddress(<void*>&self.vbfdijetpt_JetEnUp_value)

        #print "making vbfditaupt"
        self.vbfditaupt_branch = the_tree.GetBranch("vbfditaupt")
        #if not self.vbfditaupt_branch and "vbfditaupt" not in self.complained:
        if not self.vbfditaupt_branch and "vbfditaupt":
            warnings.warn( "EMTree: Expected branch vbfditaupt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt")
        else:
            self.vbfditaupt_branch.SetAddress(<void*>&self.vbfditaupt_value)

        #print "making vbfditaupt_JetEnDown"
        self.vbfditaupt_JetEnDown_branch = the_tree.GetBranch("vbfditaupt_JetEnDown")
        #if not self.vbfditaupt_JetEnDown_branch and "vbfditaupt_JetEnDown" not in self.complained:
        if not self.vbfditaupt_JetEnDown_branch and "vbfditaupt_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfditaupt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt_JetEnDown")
        else:
            self.vbfditaupt_JetEnDown_branch.SetAddress(<void*>&self.vbfditaupt_JetEnDown_value)

        #print "making vbfditaupt_JetEnUp"
        self.vbfditaupt_JetEnUp_branch = the_tree.GetBranch("vbfditaupt_JetEnUp")
        #if not self.vbfditaupt_JetEnUp_branch and "vbfditaupt_JetEnUp" not in self.complained:
        if not self.vbfditaupt_JetEnUp_branch and "vbfditaupt_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfditaupt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfditaupt_JetEnUp")
        else:
            self.vbfditaupt_JetEnUp_branch.SetAddress(<void*>&self.vbfditaupt_JetEnUp_value)

        #print "making vbfj1eta"
        self.vbfj1eta_branch = the_tree.GetBranch("vbfj1eta")
        #if not self.vbfj1eta_branch and "vbfj1eta" not in self.complained:
        if not self.vbfj1eta_branch and "vbfj1eta":
            warnings.warn( "EMTree: Expected branch vbfj1eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta")
        else:
            self.vbfj1eta_branch.SetAddress(<void*>&self.vbfj1eta_value)

        #print "making vbfj1eta_JetEnDown"
        self.vbfj1eta_JetEnDown_branch = the_tree.GetBranch("vbfj1eta_JetEnDown")
        #if not self.vbfj1eta_JetEnDown_branch and "vbfj1eta_JetEnDown" not in self.complained:
        if not self.vbfj1eta_JetEnDown_branch and "vbfj1eta_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfj1eta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta_JetEnDown")
        else:
            self.vbfj1eta_JetEnDown_branch.SetAddress(<void*>&self.vbfj1eta_JetEnDown_value)

        #print "making vbfj1eta_JetEnUp"
        self.vbfj1eta_JetEnUp_branch = the_tree.GetBranch("vbfj1eta_JetEnUp")
        #if not self.vbfj1eta_JetEnUp_branch and "vbfj1eta_JetEnUp" not in self.complained:
        if not self.vbfj1eta_JetEnUp_branch and "vbfj1eta_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfj1eta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1eta_JetEnUp")
        else:
            self.vbfj1eta_JetEnUp_branch.SetAddress(<void*>&self.vbfj1eta_JetEnUp_value)

        #print "making vbfj1pt"
        self.vbfj1pt_branch = the_tree.GetBranch("vbfj1pt")
        #if not self.vbfj1pt_branch and "vbfj1pt" not in self.complained:
        if not self.vbfj1pt_branch and "vbfj1pt":
            warnings.warn( "EMTree: Expected branch vbfj1pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt")
        else:
            self.vbfj1pt_branch.SetAddress(<void*>&self.vbfj1pt_value)

        #print "making vbfj1pt_JetEnDown"
        self.vbfj1pt_JetEnDown_branch = the_tree.GetBranch("vbfj1pt_JetEnDown")
        #if not self.vbfj1pt_JetEnDown_branch and "vbfj1pt_JetEnDown" not in self.complained:
        if not self.vbfj1pt_JetEnDown_branch and "vbfj1pt_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfj1pt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt_JetEnDown")
        else:
            self.vbfj1pt_JetEnDown_branch.SetAddress(<void*>&self.vbfj1pt_JetEnDown_value)

        #print "making vbfj1pt_JetEnUp"
        self.vbfj1pt_JetEnUp_branch = the_tree.GetBranch("vbfj1pt_JetEnUp")
        #if not self.vbfj1pt_JetEnUp_branch and "vbfj1pt_JetEnUp" not in self.complained:
        if not self.vbfj1pt_JetEnUp_branch and "vbfj1pt_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfj1pt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj1pt_JetEnUp")
        else:
            self.vbfj1pt_JetEnUp_branch.SetAddress(<void*>&self.vbfj1pt_JetEnUp_value)

        #print "making vbfj2eta"
        self.vbfj2eta_branch = the_tree.GetBranch("vbfj2eta")
        #if not self.vbfj2eta_branch and "vbfj2eta" not in self.complained:
        if not self.vbfj2eta_branch and "vbfj2eta":
            warnings.warn( "EMTree: Expected branch vbfj2eta does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta")
        else:
            self.vbfj2eta_branch.SetAddress(<void*>&self.vbfj2eta_value)

        #print "making vbfj2eta_JetEnDown"
        self.vbfj2eta_JetEnDown_branch = the_tree.GetBranch("vbfj2eta_JetEnDown")
        #if not self.vbfj2eta_JetEnDown_branch and "vbfj2eta_JetEnDown" not in self.complained:
        if not self.vbfj2eta_JetEnDown_branch and "vbfj2eta_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfj2eta_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta_JetEnDown")
        else:
            self.vbfj2eta_JetEnDown_branch.SetAddress(<void*>&self.vbfj2eta_JetEnDown_value)

        #print "making vbfj2eta_JetEnUp"
        self.vbfj2eta_JetEnUp_branch = the_tree.GetBranch("vbfj2eta_JetEnUp")
        #if not self.vbfj2eta_JetEnUp_branch and "vbfj2eta_JetEnUp" not in self.complained:
        if not self.vbfj2eta_JetEnUp_branch and "vbfj2eta_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfj2eta_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2eta_JetEnUp")
        else:
            self.vbfj2eta_JetEnUp_branch.SetAddress(<void*>&self.vbfj2eta_JetEnUp_value)

        #print "making vbfj2pt"
        self.vbfj2pt_branch = the_tree.GetBranch("vbfj2pt")
        #if not self.vbfj2pt_branch and "vbfj2pt" not in self.complained:
        if not self.vbfj2pt_branch and "vbfj2pt":
            warnings.warn( "EMTree: Expected branch vbfj2pt does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt")
        else:
            self.vbfj2pt_branch.SetAddress(<void*>&self.vbfj2pt_value)

        #print "making vbfj2pt_JetEnDown"
        self.vbfj2pt_JetEnDown_branch = the_tree.GetBranch("vbfj2pt_JetEnDown")
        #if not self.vbfj2pt_JetEnDown_branch and "vbfj2pt_JetEnDown" not in self.complained:
        if not self.vbfj2pt_JetEnDown_branch and "vbfj2pt_JetEnDown":
            warnings.warn( "EMTree: Expected branch vbfj2pt_JetEnDown does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt_JetEnDown")
        else:
            self.vbfj2pt_JetEnDown_branch.SetAddress(<void*>&self.vbfj2pt_JetEnDown_value)

        #print "making vbfj2pt_JetEnUp"
        self.vbfj2pt_JetEnUp_branch = the_tree.GetBranch("vbfj2pt_JetEnUp")
        #if not self.vbfj2pt_JetEnUp_branch and "vbfj2pt_JetEnUp" not in self.complained:
        if not self.vbfj2pt_JetEnUp_branch and "vbfj2pt_JetEnUp":
            warnings.warn( "EMTree: Expected branch vbfj2pt_JetEnUp does not exist!"                " It will crash if you try and use it!",Warning)
            #self.complained.add("vbfj2pt_JetEnUp")
        else:
            self.vbfj2pt_JetEnUp_branch.SetAddress(<void*>&self.vbfj2pt_JetEnUp_value)

        #print "making idx"
        self.idx_branch = the_tree.GetBranch("idx")
        #if not self.idx_branch and "idx" not in self.complained:
        if not self.idx_branch and "idx":
            warnings.warn( "EMTree: Expected branch idx does not exist!"                " It will crash if you try and use it!",Warning)
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

    property eAbsEta:
        def __get__(self):
            self.eAbsEta_branch.GetEntry(self.localentry, 0)
            return self.eAbsEta_value

    property eCBIDLoose:
        def __get__(self):
            self.eCBIDLoose_branch.GetEntry(self.localentry, 0)
            return self.eCBIDLoose_value

    property eCBIDLooseNoIso:
        def __get__(self):
            self.eCBIDLooseNoIso_branch.GetEntry(self.localentry, 0)
            return self.eCBIDLooseNoIso_value

    property eCBIDMedium:
        def __get__(self):
            self.eCBIDMedium_branch.GetEntry(self.localentry, 0)
            return self.eCBIDMedium_value

    property eCBIDMediumNoIso:
        def __get__(self):
            self.eCBIDMediumNoIso_branch.GetEntry(self.localentry, 0)
            return self.eCBIDMediumNoIso_value

    property eCBIDTight:
        def __get__(self):
            self.eCBIDTight_branch.GetEntry(self.localentry, 0)
            return self.eCBIDTight_value

    property eCBIDTightNoIso:
        def __get__(self):
            self.eCBIDTightNoIso_branch.GetEntry(self.localentry, 0)
            return self.eCBIDTightNoIso_value

    property eCBIDVeto:
        def __get__(self):
            self.eCBIDVeto_branch.GetEntry(self.localentry, 0)
            return self.eCBIDVeto_value

    property eCBIDVetoNoIso:
        def __get__(self):
            self.eCBIDVetoNoIso_branch.GetEntry(self.localentry, 0)
            return self.eCBIDVetoNoIso_value

    property eCharge:
        def __get__(self):
            self.eCharge_branch.GetEntry(self.localentry, 0)
            return self.eCharge_value

    property eChargeIdLoose:
        def __get__(self):
            self.eChargeIdLoose_branch.GetEntry(self.localentry, 0)
            return self.eChargeIdLoose_value

    property eChargeIdMed:
        def __get__(self):
            self.eChargeIdMed_branch.GetEntry(self.localentry, 0)
            return self.eChargeIdMed_value

    property eChargeIdTight:
        def __get__(self):
            self.eChargeIdTight_branch.GetEntry(self.localentry, 0)
            return self.eChargeIdTight_value

    property eComesFromHiggs:
        def __get__(self):
            self.eComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.eComesFromHiggs_value

    property eDPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.eDPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_ElectronEnDown_value

    property eDPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.eDPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_ElectronEnUp_value

    property eDPhiToPfMet_JetEnDown:
        def __get__(self):
            self.eDPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_JetEnDown_value

    property eDPhiToPfMet_JetEnUp:
        def __get__(self):
            self.eDPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_JetEnUp_value

    property eDPhiToPfMet_JetResDown:
        def __get__(self):
            self.eDPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_JetResDown_value

    property eDPhiToPfMet_JetResUp:
        def __get__(self):
            self.eDPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_JetResUp_value

    property eDPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.eDPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_MuonEnDown_value

    property eDPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.eDPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_MuonEnUp_value

    property eDPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.eDPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_PhotonEnDown_value

    property eDPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.eDPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_PhotonEnUp_value

    property eDPhiToPfMet_TauEnDown:
        def __get__(self):
            self.eDPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_TauEnDown_value

    property eDPhiToPfMet_TauEnUp:
        def __get__(self):
            self.eDPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_TauEnUp_value

    property eDPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.eDPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_UnclusteredEnDown_value

    property eDPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.eDPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_UnclusteredEnUp_value

    property eDPhiToPfMet_type1:
        def __get__(self):
            self.eDPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.eDPhiToPfMet_type1_value

    property eE1x5:
        def __get__(self):
            self.eE1x5_branch.GetEntry(self.localentry, 0)
            return self.eE1x5_value

    property eE2x5Max:
        def __get__(self):
            self.eE2x5Max_branch.GetEntry(self.localentry, 0)
            return self.eE2x5Max_value

    property eE5x5:
        def __get__(self):
            self.eE5x5_branch.GetEntry(self.localentry, 0)
            return self.eE5x5_value

    property eEcalIsoDR03:
        def __get__(self):
            self.eEcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.eEcalIsoDR03_value

    property eEffectiveArea2012Data:
        def __get__(self):
            self.eEffectiveArea2012Data_branch.GetEntry(self.localentry, 0)
            return self.eEffectiveArea2012Data_value

    property eEffectiveAreaSpring15:
        def __get__(self):
            self.eEffectiveAreaSpring15_branch.GetEntry(self.localentry, 0)
            return self.eEffectiveAreaSpring15_value

    property eEnergyError:
        def __get__(self):
            self.eEnergyError_branch.GetEntry(self.localentry, 0)
            return self.eEnergyError_value

    property eEta:
        def __get__(self):
            self.eEta_branch.GetEntry(self.localentry, 0)
            return self.eEta_value

    property eEta_ElectronEnDown:
        def __get__(self):
            self.eEta_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.eEta_ElectronEnDown_value

    property eEta_ElectronEnUp:
        def __get__(self):
            self.eEta_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.eEta_ElectronEnUp_value

    property eGenCharge:
        def __get__(self):
            self.eGenCharge_branch.GetEntry(self.localentry, 0)
            return self.eGenCharge_value

    property eGenEnergy:
        def __get__(self):
            self.eGenEnergy_branch.GetEntry(self.localentry, 0)
            return self.eGenEnergy_value

    property eGenEta:
        def __get__(self):
            self.eGenEta_branch.GetEntry(self.localentry, 0)
            return self.eGenEta_value

    property eGenMotherPdgId:
        def __get__(self):
            self.eGenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.eGenMotherPdgId_value

    property eGenParticle:
        def __get__(self):
            self.eGenParticle_branch.GetEntry(self.localentry, 0)
            return self.eGenParticle_value

    property eGenPdgId:
        def __get__(self):
            self.eGenPdgId_branch.GetEntry(self.localentry, 0)
            return self.eGenPdgId_value

    property eGenPhi:
        def __get__(self):
            self.eGenPhi_branch.GetEntry(self.localentry, 0)
            return self.eGenPhi_value

    property eGenPrompt:
        def __get__(self):
            self.eGenPrompt_branch.GetEntry(self.localentry, 0)
            return self.eGenPrompt_value

    property eGenPromptTauDecay:
        def __get__(self):
            self.eGenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.eGenPromptTauDecay_value

    property eGenPt:
        def __get__(self):
            self.eGenPt_branch.GetEntry(self.localentry, 0)
            return self.eGenPt_value

    property eGenTauDecay:
        def __get__(self):
            self.eGenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.eGenTauDecay_value

    property eGenVZ:
        def __get__(self):
            self.eGenVZ_branch.GetEntry(self.localentry, 0)
            return self.eGenVZ_value

    property eGenVtxPVMatch:
        def __get__(self):
            self.eGenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.eGenVtxPVMatch_value

    property eHadronicDepth1OverEm:
        def __get__(self):
            self.eHadronicDepth1OverEm_branch.GetEntry(self.localentry, 0)
            return self.eHadronicDepth1OverEm_value

    property eHadronicDepth2OverEm:
        def __get__(self):
            self.eHadronicDepth2OverEm_branch.GetEntry(self.localentry, 0)
            return self.eHadronicDepth2OverEm_value

    property eHadronicOverEM:
        def __get__(self):
            self.eHadronicOverEM_branch.GetEntry(self.localentry, 0)
            return self.eHadronicOverEM_value

    property eHcalIsoDR03:
        def __get__(self):
            self.eHcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.eHcalIsoDR03_value

    property eIP3D:
        def __get__(self):
            self.eIP3D_branch.GetEntry(self.localentry, 0)
            return self.eIP3D_value

    property eIP3DErr:
        def __get__(self):
            self.eIP3DErr_branch.GetEntry(self.localentry, 0)
            return self.eIP3DErr_value

    property eJetArea:
        def __get__(self):
            self.eJetArea_branch.GetEntry(self.localentry, 0)
            return self.eJetArea_value

    property eJetBtag:
        def __get__(self):
            self.eJetBtag_branch.GetEntry(self.localentry, 0)
            return self.eJetBtag_value

    property eJetEtaEtaMoment:
        def __get__(self):
            self.eJetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.eJetEtaEtaMoment_value

    property eJetEtaPhiMoment:
        def __get__(self):
            self.eJetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.eJetEtaPhiMoment_value

    property eJetEtaPhiSpread:
        def __get__(self):
            self.eJetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.eJetEtaPhiSpread_value

    property eJetPFCISVBtag:
        def __get__(self):
            self.eJetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.eJetPFCISVBtag_value

    property eJetPartonFlavour:
        def __get__(self):
            self.eJetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.eJetPartonFlavour_value

    property eJetPhiPhiMoment:
        def __get__(self):
            self.eJetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.eJetPhiPhiMoment_value

    property eJetPt:
        def __get__(self):
            self.eJetPt_branch.GetEntry(self.localentry, 0)
            return self.eJetPt_value

    property eLowestMll:
        def __get__(self):
            self.eLowestMll_branch.GetEntry(self.localentry, 0)
            return self.eLowestMll_value

    property eMVANonTrigCategory:
        def __get__(self):
            self.eMVANonTrigCategory_branch.GetEntry(self.localentry, 0)
            return self.eMVANonTrigCategory_value

    property eMVANonTrigID:
        def __get__(self):
            self.eMVANonTrigID_branch.GetEntry(self.localentry, 0)
            return self.eMVANonTrigID_value

    property eMVANonTrigWP80:
        def __get__(self):
            self.eMVANonTrigWP80_branch.GetEntry(self.localentry, 0)
            return self.eMVANonTrigWP80_value

    property eMVANonTrigWP90:
        def __get__(self):
            self.eMVANonTrigWP90_branch.GetEntry(self.localentry, 0)
            return self.eMVANonTrigWP90_value

    property eMVATrigCategory:
        def __get__(self):
            self.eMVATrigCategory_branch.GetEntry(self.localentry, 0)
            return self.eMVATrigCategory_value

    property eMVATrigID:
        def __get__(self):
            self.eMVATrigID_branch.GetEntry(self.localentry, 0)
            return self.eMVATrigID_value

    property eMVATrigWP80:
        def __get__(self):
            self.eMVATrigWP80_branch.GetEntry(self.localentry, 0)
            return self.eMVATrigWP80_value

    property eMVATrigWP90:
        def __get__(self):
            self.eMVATrigWP90_branch.GetEntry(self.localentry, 0)
            return self.eMVATrigWP90_value

    property eMass:
        def __get__(self):
            self.eMass_branch.GetEntry(self.localentry, 0)
            return self.eMass_value

    property eMatchesDoubleE:
        def __get__(self):
            self.eMatchesDoubleE_branch.GetEntry(self.localentry, 0)
            return self.eMatchesDoubleE_value

    property eMatchesDoubleESingleMu:
        def __get__(self):
            self.eMatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.eMatchesDoubleESingleMu_value

    property eMatchesDoubleMuSingleE:
        def __get__(self):
            self.eMatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.eMatchesDoubleMuSingleE_value

    property eMatchesSingleE:
        def __get__(self):
            self.eMatchesSingleE_branch.GetEntry(self.localentry, 0)
            return self.eMatchesSingleE_value

    property eMatchesSingleESingleMu:
        def __get__(self):
            self.eMatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.eMatchesSingleESingleMu_value

    property eMatchesSingleE_leg1:
        def __get__(self):
            self.eMatchesSingleE_leg1_branch.GetEntry(self.localentry, 0)
            return self.eMatchesSingleE_leg1_value

    property eMatchesSingleE_leg2:
        def __get__(self):
            self.eMatchesSingleE_leg2_branch.GetEntry(self.localentry, 0)
            return self.eMatchesSingleE_leg2_value

    property eMatchesSingleMuSingleE:
        def __get__(self):
            self.eMatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.eMatchesSingleMuSingleE_value

    property eMatchesTripleE:
        def __get__(self):
            self.eMatchesTripleE_branch.GetEntry(self.localentry, 0)
            return self.eMatchesTripleE_value

    property eMissingHits:
        def __get__(self):
            self.eMissingHits_branch.GetEntry(self.localentry, 0)
            return self.eMissingHits_value

    property eMtToPfMet_ElectronEnDown:
        def __get__(self):
            self.eMtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_ElectronEnDown_value

    property eMtToPfMet_ElectronEnUp:
        def __get__(self):
            self.eMtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_ElectronEnUp_value

    property eMtToPfMet_JetEnDown:
        def __get__(self):
            self.eMtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_JetEnDown_value

    property eMtToPfMet_JetEnUp:
        def __get__(self):
            self.eMtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_JetEnUp_value

    property eMtToPfMet_JetResDown:
        def __get__(self):
            self.eMtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_JetResDown_value

    property eMtToPfMet_JetResUp:
        def __get__(self):
            self.eMtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_JetResUp_value

    property eMtToPfMet_MuonEnDown:
        def __get__(self):
            self.eMtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_MuonEnDown_value

    property eMtToPfMet_MuonEnUp:
        def __get__(self):
            self.eMtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_MuonEnUp_value

    property eMtToPfMet_PhotonEnDown:
        def __get__(self):
            self.eMtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_PhotonEnDown_value

    property eMtToPfMet_PhotonEnUp:
        def __get__(self):
            self.eMtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_PhotonEnUp_value

    property eMtToPfMet_Raw:
        def __get__(self):
            self.eMtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_Raw_value

    property eMtToPfMet_TauEnDown:
        def __get__(self):
            self.eMtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_TauEnDown_value

    property eMtToPfMet_TauEnUp:
        def __get__(self):
            self.eMtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_TauEnUp_value

    property eMtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.eMtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_UnclusteredEnDown_value

    property eMtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.eMtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_UnclusteredEnUp_value

    property eMtToPfMet_type1:
        def __get__(self):
            self.eMtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.eMtToPfMet_type1_value

    property eNearMuonVeto:
        def __get__(self):
            self.eNearMuonVeto_branch.GetEntry(self.localentry, 0)
            return self.eNearMuonVeto_value

    property eNearestMuonDR:
        def __get__(self):
            self.eNearestMuonDR_branch.GetEntry(self.localentry, 0)
            return self.eNearestMuonDR_value

    property eNearestZMass:
        def __get__(self):
            self.eNearestZMass_branch.GetEntry(self.localentry, 0)
            return self.eNearestZMass_value

    property ePFChargedIso:
        def __get__(self):
            self.ePFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.ePFChargedIso_value

    property ePFNeutralIso:
        def __get__(self):
            self.ePFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.ePFNeutralIso_value

    property ePFPUChargedIso:
        def __get__(self):
            self.ePFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.ePFPUChargedIso_value

    property ePFPhotonIso:
        def __get__(self):
            self.ePFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.ePFPhotonIso_value

    property ePVDXY:
        def __get__(self):
            self.ePVDXY_branch.GetEntry(self.localentry, 0)
            return self.ePVDXY_value

    property ePVDZ:
        def __get__(self):
            self.ePVDZ_branch.GetEntry(self.localentry, 0)
            return self.ePVDZ_value

    property ePassesConversionVeto:
        def __get__(self):
            self.ePassesConversionVeto_branch.GetEntry(self.localentry, 0)
            return self.ePassesConversionVeto_value

    property ePhi:
        def __get__(self):
            self.ePhi_branch.GetEntry(self.localentry, 0)
            return self.ePhi_value

    property ePhi_ElectronEnDown:
        def __get__(self):
            self.ePhi_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.ePhi_ElectronEnDown_value

    property ePhi_ElectronEnUp:
        def __get__(self):
            self.ePhi_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.ePhi_ElectronEnUp_value

    property ePt:
        def __get__(self):
            self.ePt_branch.GetEntry(self.localentry, 0)
            return self.ePt_value

    property ePt_ElectronEnDown:
        def __get__(self):
            self.ePt_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.ePt_ElectronEnDown_value

    property ePt_ElectronEnUp:
        def __get__(self):
            self.ePt_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.ePt_ElectronEnUp_value

    property eRank:
        def __get__(self):
            self.eRank_branch.GetEntry(self.localentry, 0)
            return self.eRank_value

    property eRelIso:
        def __get__(self):
            self.eRelIso_branch.GetEntry(self.localentry, 0)
            return self.eRelIso_value

    property eRelPFIsoDB:
        def __get__(self):
            self.eRelPFIsoDB_branch.GetEntry(self.localentry, 0)
            return self.eRelPFIsoDB_value

    property eRelPFIsoRho:
        def __get__(self):
            self.eRelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.eRelPFIsoRho_value

    property eRho:
        def __get__(self):
            self.eRho_branch.GetEntry(self.localentry, 0)
            return self.eRho_value

    property eSCEnergy:
        def __get__(self):
            self.eSCEnergy_branch.GetEntry(self.localentry, 0)
            return self.eSCEnergy_value

    property eSCEta:
        def __get__(self):
            self.eSCEta_branch.GetEntry(self.localentry, 0)
            return self.eSCEta_value

    property eSCEtaWidth:
        def __get__(self):
            self.eSCEtaWidth_branch.GetEntry(self.localentry, 0)
            return self.eSCEtaWidth_value

    property eSCPhi:
        def __get__(self):
            self.eSCPhi_branch.GetEntry(self.localentry, 0)
            return self.eSCPhi_value

    property eSCPhiWidth:
        def __get__(self):
            self.eSCPhiWidth_branch.GetEntry(self.localentry, 0)
            return self.eSCPhiWidth_value

    property eSCPreshowerEnergy:
        def __get__(self):
            self.eSCPreshowerEnergy_branch.GetEntry(self.localentry, 0)
            return self.eSCPreshowerEnergy_value

    property eSCRawEnergy:
        def __get__(self):
            self.eSCRawEnergy_branch.GetEntry(self.localentry, 0)
            return self.eSCRawEnergy_value

    property eSIP2D:
        def __get__(self):
            self.eSIP2D_branch.GetEntry(self.localentry, 0)
            return self.eSIP2D_value

    property eSIP3D:
        def __get__(self):
            self.eSIP3D_branch.GetEntry(self.localentry, 0)
            return self.eSIP3D_value

    property eSigmaIEtaIEta:
        def __get__(self):
            self.eSigmaIEtaIEta_branch.GetEntry(self.localentry, 0)
            return self.eSigmaIEtaIEta_value

    property eTrkIsoDR03:
        def __get__(self):
            self.eTrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.eTrkIsoDR03_value

    property eVZ:
        def __get__(self):
            self.eVZ_branch.GetEntry(self.localentry, 0)
            return self.eVZ_value

    property eVetoMVAIso:
        def __get__(self):
            self.eVetoMVAIso_branch.GetEntry(self.localentry, 0)
            return self.eVetoMVAIso_value

    property eVetoMVAIsoVtx:
        def __get__(self):
            self.eVetoMVAIsoVtx_branch.GetEntry(self.localentry, 0)
            return self.eVetoMVAIsoVtx_value

    property eWWLoose:
        def __get__(self):
            self.eWWLoose_branch.GetEntry(self.localentry, 0)
            return self.eWWLoose_value

    property e_m_CosThetaStar:
        def __get__(self):
            self.e_m_CosThetaStar_branch.GetEntry(self.localentry, 0)
            return self.e_m_CosThetaStar_value

    property e_m_DPhi:
        def __get__(self):
            self.e_m_DPhi_branch.GetEntry(self.localentry, 0)
            return self.e_m_DPhi_value

    property e_m_DR:
        def __get__(self):
            self.e_m_DR_branch.GetEntry(self.localentry, 0)
            return self.e_m_DR_value

    property e_m_Eta:
        def __get__(self):
            self.e_m_Eta_branch.GetEntry(self.localentry, 0)
            return self.e_m_Eta_value

    property e_m_Mass:
        def __get__(self):
            self.e_m_Mass_branch.GetEntry(self.localentry, 0)
            return self.e_m_Mass_value

    property e_m_Mt:
        def __get__(self):
            self.e_m_Mt_branch.GetEntry(self.localentry, 0)
            return self.e_m_Mt_value

    property e_m_PZeta:
        def __get__(self):
            self.e_m_PZeta_branch.GetEntry(self.localentry, 0)
            return self.e_m_PZeta_value

    property e_m_PZetaVis:
        def __get__(self):
            self.e_m_PZetaVis_branch.GetEntry(self.localentry, 0)
            return self.e_m_PZetaVis_value

    property e_m_Phi:
        def __get__(self):
            self.e_m_Phi_branch.GetEntry(self.localentry, 0)
            return self.e_m_Phi_value

    property e_m_Pt:
        def __get__(self):
            self.e_m_Pt_branch.GetEntry(self.localentry, 0)
            return self.e_m_Pt_value

    property e_m_SS:
        def __get__(self):
            self.e_m_SS_branch.GetEntry(self.localentry, 0)
            return self.e_m_SS_value

    property e_m_ToMETDPhi_Ty1:
        def __get__(self):
            self.e_m_ToMETDPhi_Ty1_branch.GetEntry(self.localentry, 0)
            return self.e_m_ToMETDPhi_Ty1_value

    property e_m_collinearmass:
        def __get__(self):
            self.e_m_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.e_m_collinearmass_value

    property e_m_collinearmass_JetEnDown:
        def __get__(self):
            self.e_m_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.e_m_collinearmass_JetEnDown_value

    property e_m_collinearmass_JetEnUp:
        def __get__(self):
            self.e_m_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.e_m_collinearmass_JetEnUp_value

    property e_m_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.e_m_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.e_m_collinearmass_UnclusteredEnDown_value

    property e_m_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.e_m_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.e_m_collinearmass_UnclusteredEnUp_value

    property edeltaEtaSuperClusterTrackAtVtx:
        def __get__(self):
            self.edeltaEtaSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.edeltaEtaSuperClusterTrackAtVtx_value

    property edeltaPhiSuperClusterTrackAtVtx:
        def __get__(self):
            self.edeltaPhiSuperClusterTrackAtVtx_branch.GetEntry(self.localentry, 0)
            return self.edeltaPhiSuperClusterTrackAtVtx_value

    property eeSuperClusterOverP:
        def __get__(self):
            self.eeSuperClusterOverP_branch.GetEntry(self.localentry, 0)
            return self.eeSuperClusterOverP_value

    property eecalEnergy:
        def __get__(self):
            self.eecalEnergy_branch.GetEntry(self.localentry, 0)
            return self.eecalEnergy_value

    property efBrem:
        def __get__(self):
            self.efBrem_branch.GetEntry(self.localentry, 0)
            return self.efBrem_value

    property etrackMomentumAtVtxP:
        def __get__(self):
            self.etrackMomentumAtVtxP_branch.GetEntry(self.localentry, 0)
            return self.etrackMomentumAtVtxP_value

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

    property mAbsEta:
        def __get__(self):
            self.mAbsEta_branch.GetEntry(self.localentry, 0)
            return self.mAbsEta_value

    property mBestTrackType:
        def __get__(self):
            self.mBestTrackType_branch.GetEntry(self.localentry, 0)
            return self.mBestTrackType_value

    property mCharge:
        def __get__(self):
            self.mCharge_branch.GetEntry(self.localentry, 0)
            return self.mCharge_value

    property mComesFromHiggs:
        def __get__(self):
            self.mComesFromHiggs_branch.GetEntry(self.localentry, 0)
            return self.mComesFromHiggs_value

    property mDPhiToPfMet_ElectronEnDown:
        def __get__(self):
            self.mDPhiToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_ElectronEnDown_value

    property mDPhiToPfMet_ElectronEnUp:
        def __get__(self):
            self.mDPhiToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_ElectronEnUp_value

    property mDPhiToPfMet_JetEnDown:
        def __get__(self):
            self.mDPhiToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_JetEnDown_value

    property mDPhiToPfMet_JetEnUp:
        def __get__(self):
            self.mDPhiToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_JetEnUp_value

    property mDPhiToPfMet_JetResDown:
        def __get__(self):
            self.mDPhiToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_JetResDown_value

    property mDPhiToPfMet_JetResUp:
        def __get__(self):
            self.mDPhiToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_JetResUp_value

    property mDPhiToPfMet_MuonEnDown:
        def __get__(self):
            self.mDPhiToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_MuonEnDown_value

    property mDPhiToPfMet_MuonEnUp:
        def __get__(self):
            self.mDPhiToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_MuonEnUp_value

    property mDPhiToPfMet_PhotonEnDown:
        def __get__(self):
            self.mDPhiToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_PhotonEnDown_value

    property mDPhiToPfMet_PhotonEnUp:
        def __get__(self):
            self.mDPhiToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_PhotonEnUp_value

    property mDPhiToPfMet_TauEnDown:
        def __get__(self):
            self.mDPhiToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_TauEnDown_value

    property mDPhiToPfMet_TauEnUp:
        def __get__(self):
            self.mDPhiToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_TauEnUp_value

    property mDPhiToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.mDPhiToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_UnclusteredEnDown_value

    property mDPhiToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.mDPhiToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_UnclusteredEnUp_value

    property mDPhiToPfMet_type1:
        def __get__(self):
            self.mDPhiToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.mDPhiToPfMet_type1_value

    property mEcalIsoDR03:
        def __get__(self):
            self.mEcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.mEcalIsoDR03_value

    property mEffectiveArea2011:
        def __get__(self):
            self.mEffectiveArea2011_branch.GetEntry(self.localentry, 0)
            return self.mEffectiveArea2011_value

    property mEffectiveArea2012:
        def __get__(self):
            self.mEffectiveArea2012_branch.GetEntry(self.localentry, 0)
            return self.mEffectiveArea2012_value

    property mEta:
        def __get__(self):
            self.mEta_branch.GetEntry(self.localentry, 0)
            return self.mEta_value

    property mEta_MuonEnDown:
        def __get__(self):
            self.mEta_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.mEta_MuonEnDown_value

    property mEta_MuonEnUp:
        def __get__(self):
            self.mEta_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.mEta_MuonEnUp_value

    property mGenCharge:
        def __get__(self):
            self.mGenCharge_branch.GetEntry(self.localentry, 0)
            return self.mGenCharge_value

    property mGenEnergy:
        def __get__(self):
            self.mGenEnergy_branch.GetEntry(self.localentry, 0)
            return self.mGenEnergy_value

    property mGenEta:
        def __get__(self):
            self.mGenEta_branch.GetEntry(self.localentry, 0)
            return self.mGenEta_value

    property mGenMotherPdgId:
        def __get__(self):
            self.mGenMotherPdgId_branch.GetEntry(self.localentry, 0)
            return self.mGenMotherPdgId_value

    property mGenParticle:
        def __get__(self):
            self.mGenParticle_branch.GetEntry(self.localentry, 0)
            return self.mGenParticle_value

    property mGenPdgId:
        def __get__(self):
            self.mGenPdgId_branch.GetEntry(self.localentry, 0)
            return self.mGenPdgId_value

    property mGenPhi:
        def __get__(self):
            self.mGenPhi_branch.GetEntry(self.localentry, 0)
            return self.mGenPhi_value

    property mGenPrompt:
        def __get__(self):
            self.mGenPrompt_branch.GetEntry(self.localentry, 0)
            return self.mGenPrompt_value

    property mGenPromptTauDecay:
        def __get__(self):
            self.mGenPromptTauDecay_branch.GetEntry(self.localentry, 0)
            return self.mGenPromptTauDecay_value

    property mGenPt:
        def __get__(self):
            self.mGenPt_branch.GetEntry(self.localentry, 0)
            return self.mGenPt_value

    property mGenTauDecay:
        def __get__(self):
            self.mGenTauDecay_branch.GetEntry(self.localentry, 0)
            return self.mGenTauDecay_value

    property mGenVZ:
        def __get__(self):
            self.mGenVZ_branch.GetEntry(self.localentry, 0)
            return self.mGenVZ_value

    property mGenVtxPVMatch:
        def __get__(self):
            self.mGenVtxPVMatch_branch.GetEntry(self.localentry, 0)
            return self.mGenVtxPVMatch_value

    property mHcalIsoDR03:
        def __get__(self):
            self.mHcalIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.mHcalIsoDR03_value

    property mIP3D:
        def __get__(self):
            self.mIP3D_branch.GetEntry(self.localentry, 0)
            return self.mIP3D_value

    property mIP3DErr:
        def __get__(self):
            self.mIP3DErr_branch.GetEntry(self.localentry, 0)
            return self.mIP3DErr_value

    property mIsGlobal:
        def __get__(self):
            self.mIsGlobal_branch.GetEntry(self.localentry, 0)
            return self.mIsGlobal_value

    property mIsPFMuon:
        def __get__(self):
            self.mIsPFMuon_branch.GetEntry(self.localentry, 0)
            return self.mIsPFMuon_value

    property mIsTracker:
        def __get__(self):
            self.mIsTracker_branch.GetEntry(self.localentry, 0)
            return self.mIsTracker_value

    property mJetArea:
        def __get__(self):
            self.mJetArea_branch.GetEntry(self.localentry, 0)
            return self.mJetArea_value

    property mJetBtag:
        def __get__(self):
            self.mJetBtag_branch.GetEntry(self.localentry, 0)
            return self.mJetBtag_value

    property mJetEtaEtaMoment:
        def __get__(self):
            self.mJetEtaEtaMoment_branch.GetEntry(self.localentry, 0)
            return self.mJetEtaEtaMoment_value

    property mJetEtaPhiMoment:
        def __get__(self):
            self.mJetEtaPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.mJetEtaPhiMoment_value

    property mJetEtaPhiSpread:
        def __get__(self):
            self.mJetEtaPhiSpread_branch.GetEntry(self.localentry, 0)
            return self.mJetEtaPhiSpread_value

    property mJetPFCISVBtag:
        def __get__(self):
            self.mJetPFCISVBtag_branch.GetEntry(self.localentry, 0)
            return self.mJetPFCISVBtag_value

    property mJetPartonFlavour:
        def __get__(self):
            self.mJetPartonFlavour_branch.GetEntry(self.localentry, 0)
            return self.mJetPartonFlavour_value

    property mJetPhiPhiMoment:
        def __get__(self):
            self.mJetPhiPhiMoment_branch.GetEntry(self.localentry, 0)
            return self.mJetPhiPhiMoment_value

    property mJetPt:
        def __get__(self):
            self.mJetPt_branch.GetEntry(self.localentry, 0)
            return self.mJetPt_value

    property mLowestMll:
        def __get__(self):
            self.mLowestMll_branch.GetEntry(self.localentry, 0)
            return self.mLowestMll_value

    property mMass:
        def __get__(self):
            self.mMass_branch.GetEntry(self.localentry, 0)
            return self.mMass_value

    property mMatchedStations:
        def __get__(self):
            self.mMatchedStations_branch.GetEntry(self.localentry, 0)
            return self.mMatchedStations_value

    property mMatchesDoubleESingleMu:
        def __get__(self):
            self.mMatchesDoubleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.mMatchesDoubleESingleMu_value

    property mMatchesDoubleMu:
        def __get__(self):
            self.mMatchesDoubleMu_branch.GetEntry(self.localentry, 0)
            return self.mMatchesDoubleMu_value

    property mMatchesDoubleMuSingleE:
        def __get__(self):
            self.mMatchesDoubleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.mMatchesDoubleMuSingleE_value

    property mMatchesSingleESingleMu:
        def __get__(self):
            self.mMatchesSingleESingleMu_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleESingleMu_value

    property mMatchesSingleMu:
        def __get__(self):
            self.mMatchesSingleMu_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMu_value

    property mMatchesSingleMuIso20:
        def __get__(self):
            self.mMatchesSingleMuIso20_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMuIso20_value

    property mMatchesSingleMuIsoTk20:
        def __get__(self):
            self.mMatchesSingleMuIsoTk20_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMuIsoTk20_value

    property mMatchesSingleMuSingleE:
        def __get__(self):
            self.mMatchesSingleMuSingleE_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMuSingleE_value

    property mMatchesSingleMu_leg1:
        def __get__(self):
            self.mMatchesSingleMu_leg1_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMu_leg1_value

    property mMatchesSingleMu_leg1_noiso:
        def __get__(self):
            self.mMatchesSingleMu_leg1_noiso_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMu_leg1_noiso_value

    property mMatchesSingleMu_leg2:
        def __get__(self):
            self.mMatchesSingleMu_leg2_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMu_leg2_value

    property mMatchesSingleMu_leg2_noiso:
        def __get__(self):
            self.mMatchesSingleMu_leg2_noiso_branch.GetEntry(self.localentry, 0)
            return self.mMatchesSingleMu_leg2_noiso_value

    property mMatchesTripleMu:
        def __get__(self):
            self.mMatchesTripleMu_branch.GetEntry(self.localentry, 0)
            return self.mMatchesTripleMu_value

    property mMtToPfMet_ElectronEnDown:
        def __get__(self):
            self.mMtToPfMet_ElectronEnDown_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_ElectronEnDown_value

    property mMtToPfMet_ElectronEnUp:
        def __get__(self):
            self.mMtToPfMet_ElectronEnUp_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_ElectronEnUp_value

    property mMtToPfMet_JetEnDown:
        def __get__(self):
            self.mMtToPfMet_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_JetEnDown_value

    property mMtToPfMet_JetEnUp:
        def __get__(self):
            self.mMtToPfMet_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_JetEnUp_value

    property mMtToPfMet_JetResDown:
        def __get__(self):
            self.mMtToPfMet_JetResDown_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_JetResDown_value

    property mMtToPfMet_JetResUp:
        def __get__(self):
            self.mMtToPfMet_JetResUp_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_JetResUp_value

    property mMtToPfMet_MuonEnDown:
        def __get__(self):
            self.mMtToPfMet_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_MuonEnDown_value

    property mMtToPfMet_MuonEnUp:
        def __get__(self):
            self.mMtToPfMet_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_MuonEnUp_value

    property mMtToPfMet_PhotonEnDown:
        def __get__(self):
            self.mMtToPfMet_PhotonEnDown_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_PhotonEnDown_value

    property mMtToPfMet_PhotonEnUp:
        def __get__(self):
            self.mMtToPfMet_PhotonEnUp_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_PhotonEnUp_value

    property mMtToPfMet_Raw:
        def __get__(self):
            self.mMtToPfMet_Raw_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_Raw_value

    property mMtToPfMet_TauEnDown:
        def __get__(self):
            self.mMtToPfMet_TauEnDown_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_TauEnDown_value

    property mMtToPfMet_TauEnUp:
        def __get__(self):
            self.mMtToPfMet_TauEnUp_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_TauEnUp_value

    property mMtToPfMet_UnclusteredEnDown:
        def __get__(self):
            self.mMtToPfMet_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_UnclusteredEnDown_value

    property mMtToPfMet_UnclusteredEnUp:
        def __get__(self):
            self.mMtToPfMet_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_UnclusteredEnUp_value

    property mMtToPfMet_type1:
        def __get__(self):
            self.mMtToPfMet_type1_branch.GetEntry(self.localentry, 0)
            return self.mMtToPfMet_type1_value

    property mMuonHits:
        def __get__(self):
            self.mMuonHits_branch.GetEntry(self.localentry, 0)
            return self.mMuonHits_value

    property mNearestZMass:
        def __get__(self):
            self.mNearestZMass_branch.GetEntry(self.localentry, 0)
            return self.mNearestZMass_value

    property mNormTrkChi2:
        def __get__(self):
            self.mNormTrkChi2_branch.GetEntry(self.localentry, 0)
            return self.mNormTrkChi2_value

    property mPFChargedHadronIsoR04:
        def __get__(self):
            self.mPFChargedHadronIsoR04_branch.GetEntry(self.localentry, 0)
            return self.mPFChargedHadronIsoR04_value

    property mPFChargedIso:
        def __get__(self):
            self.mPFChargedIso_branch.GetEntry(self.localentry, 0)
            return self.mPFChargedIso_value

    property mPFIDLoose:
        def __get__(self):
            self.mPFIDLoose_branch.GetEntry(self.localentry, 0)
            return self.mPFIDLoose_value

    property mPFIDMedium:
        def __get__(self):
            self.mPFIDMedium_branch.GetEntry(self.localentry, 0)
            return self.mPFIDMedium_value

    property mPFIDTight:
        def __get__(self):
            self.mPFIDTight_branch.GetEntry(self.localentry, 0)
            return self.mPFIDTight_value

    property mPFNeutralHadronIsoR04:
        def __get__(self):
            self.mPFNeutralHadronIsoR04_branch.GetEntry(self.localentry, 0)
            return self.mPFNeutralHadronIsoR04_value

    property mPFNeutralIso:
        def __get__(self):
            self.mPFNeutralIso_branch.GetEntry(self.localentry, 0)
            return self.mPFNeutralIso_value

    property mPFPUChargedIso:
        def __get__(self):
            self.mPFPUChargedIso_branch.GetEntry(self.localentry, 0)
            return self.mPFPUChargedIso_value

    property mPFPhotonIso:
        def __get__(self):
            self.mPFPhotonIso_branch.GetEntry(self.localentry, 0)
            return self.mPFPhotonIso_value

    property mPFPhotonIsoR04:
        def __get__(self):
            self.mPFPhotonIsoR04_branch.GetEntry(self.localentry, 0)
            return self.mPFPhotonIsoR04_value

    property mPFPileupIsoR04:
        def __get__(self):
            self.mPFPileupIsoR04_branch.GetEntry(self.localentry, 0)
            return self.mPFPileupIsoR04_value

    property mPVDXY:
        def __get__(self):
            self.mPVDXY_branch.GetEntry(self.localentry, 0)
            return self.mPVDXY_value

    property mPVDZ:
        def __get__(self):
            self.mPVDZ_branch.GetEntry(self.localentry, 0)
            return self.mPVDZ_value

    property mPhi:
        def __get__(self):
            self.mPhi_branch.GetEntry(self.localentry, 0)
            return self.mPhi_value

    property mPhi_MuonEnDown:
        def __get__(self):
            self.mPhi_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.mPhi_MuonEnDown_value

    property mPhi_MuonEnUp:
        def __get__(self):
            self.mPhi_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.mPhi_MuonEnUp_value

    property mPixHits:
        def __get__(self):
            self.mPixHits_branch.GetEntry(self.localentry, 0)
            return self.mPixHits_value

    property mPt:
        def __get__(self):
            self.mPt_branch.GetEntry(self.localentry, 0)
            return self.mPt_value

    property mPt_MuonEnDown:
        def __get__(self):
            self.mPt_MuonEnDown_branch.GetEntry(self.localentry, 0)
            return self.mPt_MuonEnDown_value

    property mPt_MuonEnUp:
        def __get__(self):
            self.mPt_MuonEnUp_branch.GetEntry(self.localentry, 0)
            return self.mPt_MuonEnUp_value

    property mRank:
        def __get__(self):
            self.mRank_branch.GetEntry(self.localentry, 0)
            return self.mRank_value

    property mRelPFIsoDBDefault:
        def __get__(self):
            self.mRelPFIsoDBDefault_branch.GetEntry(self.localentry, 0)
            return self.mRelPFIsoDBDefault_value

    property mRelPFIsoDBDefaultR04:
        def __get__(self):
            self.mRelPFIsoDBDefaultR04_branch.GetEntry(self.localentry, 0)
            return self.mRelPFIsoDBDefaultR04_value

    property mRelPFIsoRho:
        def __get__(self):
            self.mRelPFIsoRho_branch.GetEntry(self.localentry, 0)
            return self.mRelPFIsoRho_value

    property mRho:
        def __get__(self):
            self.mRho_branch.GetEntry(self.localentry, 0)
            return self.mRho_value

    property mSIP2D:
        def __get__(self):
            self.mSIP2D_branch.GetEntry(self.localentry, 0)
            return self.mSIP2D_value

    property mSIP3D:
        def __get__(self):
            self.mSIP3D_branch.GetEntry(self.localentry, 0)
            return self.mSIP3D_value

    property mTkLayersWithMeasurement:
        def __get__(self):
            self.mTkLayersWithMeasurement_branch.GetEntry(self.localentry, 0)
            return self.mTkLayersWithMeasurement_value

    property mTrkIsoDR03:
        def __get__(self):
            self.mTrkIsoDR03_branch.GetEntry(self.localentry, 0)
            return self.mTrkIsoDR03_value

    property mTypeCode:
        def __get__(self):
            self.mTypeCode_branch.GetEntry(self.localentry, 0)
            return self.mTypeCode_value

    property mVZ:
        def __get__(self):
            self.mVZ_branch.GetEntry(self.localentry, 0)
            return self.mVZ_value

    property m_e_collinearmass:
        def __get__(self):
            self.m_e_collinearmass_branch.GetEntry(self.localentry, 0)
            return self.m_e_collinearmass_value

    property m_e_collinearmass_JetEnDown:
        def __get__(self):
            self.m_e_collinearmass_JetEnDown_branch.GetEntry(self.localentry, 0)
            return self.m_e_collinearmass_JetEnDown_value

    property m_e_collinearmass_JetEnUp:
        def __get__(self):
            self.m_e_collinearmass_JetEnUp_branch.GetEntry(self.localentry, 0)
            return self.m_e_collinearmass_JetEnUp_value

    property m_e_collinearmass_UnclusteredEnDown:
        def __get__(self):
            self.m_e_collinearmass_UnclusteredEnDown_branch.GetEntry(self.localentry, 0)
            return self.m_e_collinearmass_UnclusteredEnDown_value

    property m_e_collinearmass_UnclusteredEnUp:
        def __get__(self):
            self.m_e_collinearmass_UnclusteredEnUp_branch.GetEntry(self.localentry, 0)
            return self.m_e_collinearmass_UnclusteredEnUp_value

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


