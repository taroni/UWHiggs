#This module provides additional electron ID's starting from MVA's raw values
from FinalStateAnalysis.PlotTools.decorators import memo
@memo
def getVar(name, var):
    return name+var

#LEPTON ID-ISO
def summer_2016_eid_WP80(row, name):
    mva_output = getattr(row, getVar(name, 'MVANonTrigWP80')) #was eMVATrigNoIP
    pT    = getattr(row, getVar(name, 'Pt'))
    abseta= getattr(row, getVar(name, 'AbsEta'))
    if pT < 10    and abseta < 0.8:
        return ( mva_output > 0.287435 )
    elif pT < 10  and 0.8 < abseta < 1.479:
        return ( mva_output > 0.221846 )
    elif pT < 10  and abseta > 1.479:
        return ( mva_output > -0.303263 )
    elif pT > 10  and abseta < 0.8:
        return ( mva_output > 0.967083 )
    elif pT > 10  and 0.8 < abseta < 1.479:
        return ( mva_output > 0.929117 )
    elif pT > 10  and abseta > 1.479:
        return ( mva_output > 0.726311 )
    return False

def summer_2016_eid_WP90(row, name):
    mva_output = getattr(row, getVar(name, 'MVANonTrigWP90'))
    pT    = getattr(row, getVar(name, 'Pt'))
    abseta= getattr(row, getVar(name, 'AbsEta'))
    if pT < 10    and abseta < 0.8:
        return ( mva_output > -0.483 )
    elif pT < 10  and 0.8 < abseta < 1.479:
        return ( mva_output > -0.267 )
    elif pT < 10  and abseta > 1.479:
        return ( mva_output > -0.323 )
    elif pT > 10  and abseta < 0.8:
        return ( mva_output > 0.933 )
    elif pT > 10  and 0.8 < abseta < 1.479:
        return ( mva_output > 0.825 )
    elif pT > 10  and abseta > 1.479:
        return ( mva_output > 0.337 )


    return False

            
#ID MVA cut value (tight lepton) 0.913 0.964 0.899
#Isolation cut value (tight lepton) 0.105 0.178 0.150
#ID MVA cut value (loose lepton) 0.877 0.811 0.707
#Isolation cut value (loose lepton) 0.426 0.481 0.390

electronIds = {
    'eid16Tight' : summer_2016_eid_WP80,
    'eid16Loose' : summer_2016_eid_WP90,
}
