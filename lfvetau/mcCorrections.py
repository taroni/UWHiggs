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

def get_electron_corrections(row,*args):
    'makes corrections to iso and id of electrons'
    ret = 1.
    for arg in args:
        abseta = abs(getattr(row, '%sEta' % arg))
        pt     = getattr(row, '%sPt'  % arg)
        ret   *= correct_e(pt,abseta)
    return ret

