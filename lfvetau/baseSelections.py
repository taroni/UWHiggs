from FinalStateAnalysis.PlotTools.decorators import memo
from FinalStateAnalysis.Utilities.struct import struct
from electronids import electronIds

@memo
def getVar(name, var):
    return name+var

@memo
def splitEid(label):
    return label.split('_')[-1], label.split('_')[0] 

#OBJECT SELECTION
def muSelection(row, name):
    if getattr( row, getVar(name,'Pt')) < 30:       return False
    if getattr( row, getVar(name,'AbsEta')) > 2.3:  return False
    if not getattr( row, getVar(name,'PixHits')):   return False
    if getattr( row, getVar(name,'JetPFCISVBtag')) > 0.8: return False
    if abs(getattr( row, getVar(name,'PVDZ'))) > 0.2: return False
    return True

def eSelection(row, name):
    eAbsEta = getattr( row, getVar(name,'AbsEta'))
    ept = getattr( row, getVar(name,'Pt')) ##put here ees_minus when available 
    if ept:
        if ept < 24 : return False 
    else:
        if getattr( row, getVar(name,'Pt')) < 24:   return False #was 20

    if eAbsEta > 2.1:      return False
    if getattr( row, getVar(name,'MissingHits')):       return False
    if not  getattr( row, getVar(name,'PassesConversionVeto')):     return False
#    if getattr( row, getVar(name,'HasConversion')):     return False
    if eAbsEta > 1.4442 and eAbsEta < 1.566: return False
    if not getattr( row, getVar(name,'ChargeIdTight')): return False
    if getattr( row, getVar(name,'JetPFCISVBtag')) > 0.8:  return False
    if abs(getattr( row, getVar(name,'PVDZ'))) > 0.2:     return False
    return True

def eLowPtSelection(row, name):
    eAbsEta = getattr( row, getVar(name,'AbsEta'))
    ept = getattr( row, getVar(name,'Pt_ees_minus'))
    if ept:
        if ept < 20:           return False 
    else:
        if getattr( row, getVar(name,'Pt')) < 20:   return False 

    if eAbsEta > 2.3:      return False
    if getattr( row, getVar(name,'MissingHits')):       return False
    if not  getattr( row, getVar(name,'PassesConversionVeto')):     return False
    if eAbsEta > 1.4442 and eAbsEta < 1.566: return False
    if not getattr( row, getVar(name,'ChargeIdLoose')): return False
    if getattr( row, getVar(name,'JetCSVBtag')) > 0.8:  return False
    if abs(getattr( row, getVar(name,'DZ'))) > 0.2:     return False
    return True
    
def tauSelection(row, name):
    tpt = getattr( row, getVar(name,'Pt'))# put here Pt_tes_minus when available
    if tpt:
        if tpt < 20:           return False 
    else:
        if getattr( row, getVar(name,'Pt')) < 20:          return False
    if getattr( row, getVar(name,'AbsEta')) > 2.3:     return False
    if abs(getattr( row, getVar(name,'PVDZ'))) > 0.2:    return False
    if getattr(row, getVar(name, 'DecayModeFinding')) < 0.5 : return False
    if getattr( row, getVar(name, 'MuonIdIsoVtxOverlap')): return False
    if getattr( row, getVar(name, 'ElecOverlap')): return False # change to tCiCLooseElecOverlap 

    return True


#VETOS
def vetos(row):
    if row.muVetoPt5IsoIdVtx: return False
    if row.eVetoMVAIsoVtx:    return False
    if row.eVetoCicTightIso:   return False # change it to loose
    if row.tauVetoPt20:        return False
    
    return True

def lepton_id_iso(row, name, label): #label in the format eidtype_isotype
    'One function to rule them all'
    LEPTON_ID = False
    isolabel, eidlabel = splitEid(label) #memoizes to be faster!
    if name[0] == 'e':
        LEPTON_ID = electronIds[eidlabel](row, name)
    else:
        LEPTON_ID = getattr(row, getVar(name, 'PFIDTight'))
    if not LEPTON_ID:
        return False
    RelPFIsoDB   = getattr(row, getVar(name, 'RelPFIsoDBDefault'))
    AbsEta       = getattr(row, getVar(name, 'AbsEta'))
    if isolabel == 'idiso01':
        return bool( RelPFIsoDB < 0.10 )
    if isolabel == 'idiso02':
        return bool( RelPFIsoDB < 0.20 )
    if isolabel == 'idiso025':
        return bool( RelPFIsoDB < 0.25 )
    if isolabel == 'idiso05':
        return bool( RelPFIsoDB < 0.5 )
        
        

def control_region_ee(row):
    '''Figure out what control region we are in. Shared among two codes, to avoid mismatching copied here'''
    if  row.e1_e2_SS and lepton_id_iso(row, 'e1', 'eid12Medium_h2taucuts') and row.e1MtToMET > 30: 
        return 'wjets'
    elif row.e1_e2_SS and row.e1RelPFIsoDB > 0.3 and row.type1_pfMetEt < 25: #and row.metSignificance < 3: #
        return 'qcd'
    elif lepton_id_iso(row,'e1', 'eid12Medium_h2taucuts') and lepton_id_iso(row,'e2', 'eid12Medium_h2taucuts') \
        and not any([ row.muVetoPt5IsoIdVtx,
                      row.tauVetoPt20Loose3HitsVtx,
                      row.eVetoMVAIsoVtx,
                      ]):
        return 'zee'
    else:
        return None


