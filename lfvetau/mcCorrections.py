import os
import glob
import FinalStateAnalysis.TagAndProbe.HetauCorrection as HetauCorrection
import FinalStateAnalysis.TagAndProbe.PileupWeight as PileupWeight

is7TeV = bool('7TeV' in os.environ['jobid'])
pu_distributions  = {
    'singlee'  : glob.glob(os.path.join( 'inputs', os.environ['jobid'], 'data_SingleElectron*pu.root'))}
mc_pu_tag                  = 'S6' if is7TeV else 'S10'


def make_puCorrector(dataset, kind=None):
    'makes PU reweighting according to the pu distribution of the reference data and the MC, MC distribution can be forced'
    if not kind:
        kind = mc_pu_tag
    if dataset in pu_distributions:
        return PileupWeight.PileupWeight( 'S6' if is7TeV else 'S10', *(pu_distributions[dataset]))
    else:
        raise KeyError('dataset not present. Please check the spelling or add it to mcCorrectors.py')

##put here the trigger correction as in https://github.com/mverzett/UWHiggs/blob/WH_At_Paper/wh/mcCorrectors.py

correct_e = HetauCorrection.correct_hamburg_e
correct_eid13_mva = HetauCorrection.correct_eid13_mva
correct_eiso13_mva = HetauCorrection.correct_eiso13_mva
correct_eid_mva = HetauCorrection.scale_eleId_hww
correct_eReco_mva = HetauCorrection.scale_elereco_hww
correct_eIso_mva = HetauCorrection.scale_eleIso_hww
correct_trigger_mva = HetauCorrection.single_ele_wp80

def get_electron_corrections(row,*args):
    'makes corrections to iso and id of electrons'
    ret = 1.
    for arg in args:
        abseta = abs(getattr(row, '%sEta' % arg))
        pt     = getattr(row, '%sPt'  % arg)
        ret   *= correct_e(pt,abseta)
    return ret

def get_electronId_corrections_MVA(row, *args):
    ret = 1.
    for arg in args:
        eta  = getattr(row, '%sEta' % arg)
        pt   = getattr(row, '%sPt'  % arg)
        ret *= correct_eid_mva(pt,eta)[0]
    return ret
def get_electronReco_corrections_MVA(row, *args):
    ret = 1.
    for arg in args:
        eta  = getattr(row, '%sEta' % arg)
        pt   = getattr(row, '%sPt'  % arg)
        ret *= correct_eReco_mva(pt,eta)[0]
    return ret
def get_electronIso_corrections_MVA(row, *args):
    ret = 1.
    for arg in args:
        eta  = getattr(row, '%sEta' % arg)
        pt   = getattr(row, '%sPt'  % arg)
        ret *= correct_eIso_mva(pt,eta)[0]
    return ret

def get_trigger_corrections_MVA(row, *args):
    ret = 1.
    for arg in args:
        eta  = getattr(row, '%sEta' % arg)
        pt   = getattr(row, '%sPt'  % arg)
        ret *= correct_trigger_mva(pt,eta)[0]
    return ret
        
def get_electronId_corrections13_MVA(row, *args):
    ret = 1.
    for arg in args:
        eta  = getattr(row, '%sEta' % arg)
        pt   = getattr(row, '%sPt'  % arg)
        ret *= correct_eid13_mva(pt,eta)
    return ret
def get_electronIso_corrections13_MVA(row, *args):
    ret = 1.
    for arg in args:
        eta  = getattr(row, '%sEta' % arg)
        pt   = getattr(row, '%sPt'  % arg)
        ret *= correct_eiso13_mva(pt,eta)
    return ret
