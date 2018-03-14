from rootpy.io import root_open
import ROOT
import sys
import os
from math import pow, sqrt

DEBUG=False

def muIdIso0p2(pt, abseta):
    value=0.
    filename = os.path.join(os.environ['fsa'], 'TagAndProbe/data/Muon_IdIso_IsoLt0p2_2016BtoH_eff_update1407.root')
    input_file= root_open(filename)
    if  not input_file:
               sys.stderr.write("Can't open file: %s\n" % filename)

    if pt>=999:pt=999

    if abseta<0.9:
        gr1 = input_file.Get("ZMassEtaLt0p9_Data")        
        npoint1=gr1.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr1.GetPoint(n, xval, yval)
            xevalp = gr1.GetErrorXhigh(n)
            xevalm = gr1.GetErrorXlow(n)
            yeval = gr1.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
        
    elif abseta>0.9 and abseta< 1.2:
        gr2 = input_file.Get("ZMassEta0p9to1p2_Data")
        npoint1=gr2.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr2.GetPoint(n, xval, yval)
            xevalp = gr2.GetErrorXhigh(n)
            xevalm = gr2.GetErrorXlow(n)
            yeval = gr2.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    elif abseta>1.2 and abseta< 2.1:
        gr3 = input_file.Get("ZMassEta1p2to2p1_Data")
        npoint1=gr3.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr3.GetPoint(n, xval, yval)
            xevalp = gr3.GetErrorXhigh(n)
            xevalm = gr3.GetErrorXlow(n)
            yeval = gr3.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
    elif  abseta> 2.1:
        
        gr4 = input_file.Get("ZMassEtaGt2p1_Data")
        npoint1=gr4.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr4.GetPoint(n, xval, yval)
            xevalp = gr4.GetErrorXhigh(n)
            xevalm = gr4.GetErrorXlow(n)
            yeval = gr4.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    input_file.Close()
    return value

def muIdIsoAntiIso0p15to0p25(pt, abseta):
    value=0.
    filename = os.path.join(os.environ['fsa'], 'TagAndProbe/data/Muon_antiisolated_0p15to0p25_IdIso_eff.root')
    input_file= root_open(filename)
    if  not input_file:
               sys.stderr.write("Can't open file: %s\n" % filename)

    if pt>=999:pt=999

    if abseta<0.9:
        gr1 = input_file.Get("ZMassEtaLt0p9_Data")        
        npoint1=gr1.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr1.GetPoint(n, xval, yval)
            xevalp = gr1.GetErrorXhigh(n)
            xevalm = gr1.GetErrorXlow(n)
            yeval = gr1.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
        
    elif abseta>0.9 and abseta< 1.2:
        gr2 = input_file.Get("ZMassEta0p9to1p2_Data")
        npoint1=gr2.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr2.GetPoint(n, xval, yval)
            xevalp = gr2.GetErrorXhigh(n)
            xevalm = gr2.GetErrorXlow(n)
            yeval = gr2.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    elif abseta>1.2 and abseta< 2.1:
        gr3 = input_file.Get("ZMassEta1p2to2p1_Data")
        npoint1=gr3.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr3.GetPoint(n, xval, yval)
            xevalp = gr3.GetErrorXhigh(n)
            xevalm = gr3.GetErrorXlow(n)
            yeval = gr3.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
    elif  abseta> 2.1:
        
        gr4 = input_file.Get("ZMassEtaGt2p1_Data")
        npoint1=gr4.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr4.GetPoint(n, xval, yval)
            xevalp = gr4.GetErrorXhigh(n)
            xevalm = gr4.GetErrorXlow(n)
            yeval = gr4.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    input_file.Close()
    return value

def mc_muIdIso0p2(pt, abseta):
    value=0.
    filename = os.path.join(os.environ['fsa'], 'TagAndProbe/data/Muon_IdIso_IsoLt0p2_2016BtoH_eff_update1407.root')
    input_file= root_open(filename)
    if  not input_file:
               sys.stderr.write("Can't open file: %s\n" % filename)

    if pt>=999:pt=999

    if abseta<0.9:
        gr1 = input_file.Get("ZMassEtaLt0p9_MC")        
        npoint1=gr1.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr1.GetPoint(n, xval, yval)
            xevalp = gr1.GetErrorXhigh(n)
            xevalm = gr1.GetErrorXlow(n)
            yeval = gr1.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
        
    elif abseta>0.9 and abseta< 1.2:
        gr2 = input_file.Get("ZMassEta0p9to1p2_MC")
        npoint1=gr2.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr2.GetPoint(n, xval, yval)
            xevalp = gr2.GetErrorXhigh(n)
            xevalm = gr2.GetErrorXlow(n)
            yeval = gr2.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    elif abseta>1.2 and abseta< 2.1:
        gr3 = input_file.Get("ZMassEta1p2to2p1_MC")
        npoint1=gr3.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr3.GetPoint(n, xval, yval)
            xevalp = gr3.GetErrorXhigh(n)
            xevalm = gr3.GetErrorXlow(n)
            yeval = gr3.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
    elif  abseta> 2.1:
        
        gr4 = input_file.Get("ZMassEtaGt2p1_MC")
        npoint1=gr4.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr4.GetPoint(n, xval, yval)
            xevalp = gr4.GetErrorXhigh(n)
            xevalm = gr4.GetErrorXlow(n)
            yeval = gr4.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    input_file.Close()
    return value

def mc_muIdIsoAntiIso0p15to0p25(pt, abseta):
    value=0.
    filename = os.path.join(os.environ['fsa'], 'TagAndProbe/data/Muon_antiisolated_0p15to0p25_IdIso_eff.root')
    input_file= root_open(filename)
    if  not input_file:
               sys.stderr.write("Can't open file: %s\n" % filename)

    if pt>=999:pt=999

    if abseta<0.9:
        gr1 = input_file.Get("ZMassEtaLt0p9_MC")        
        npoint1=gr1.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr1.GetPoint(n, xval, yval)
            xevalp = gr1.GetErrorXhigh(n)
            xevalm = gr1.GetErrorXlow(n)
            yeval = gr1.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
        
    elif abseta>0.9 and abseta< 1.2:
        gr2 = input_file.Get("ZMassEta0p9to1p2_MC")
        npoint1=gr2.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr2.GetPoint(n, xval, yval)
            xevalp = gr2.GetErrorXhigh(n)
            xevalm = gr2.GetErrorXlow(n)
            yeval = gr2.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    elif abseta>1.2 and abseta< 2.1:
        gr3 = input_file.Get("ZMassEta1p2to2p1_MC")
        npoint1=gr3.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr3.GetPoint(n, xval, yval)
            xevalp = gr3.GetErrorXhigh(n)
            xevalm = gr3.GetErrorXlow(n)
            yeval = gr3.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval
    elif  abseta> 2.1:
        
        gr4 = input_file.Get("ZMassEtaGt2p1_MC")
        npoint1=gr4.GetN()
        eff1 = []
        for n in range(0, npoint1):
            xval = ROOT.Double(0)
            yval = ROOT.Double(0)
            gr4.GetPoint(n, xval, yval)
            xevalp = gr4.GetErrorXhigh(n)
            xevalm = gr4.GetErrorXlow(n)
            yeval = gr4.GetErrorY(n)
            if pt > xval-xevalm and pt < xval+xevalp:
                value=yval

    input_file.Close()
    return value

def muTrackingSF(eta): ##Att it needs the eta
    value=0.
    filename = os.path.join(os.environ['fsa'], 'TagAndProbe/data/trackingSF.root')
    input_file= root_open(filename)
    if  not input_file:
               sys.stderr.write("Can't open file: %s\n" % filename)
  
    gr1 = input_file.Get("effTrackingMu")
    yval = gr1.GetBinContent(gr1.FindBin(eta))
    value=yval

    return value
