import array
from RecoLuminosity.LumiDB import argparse
from FinalStateAnalysis.PlotTools.RebinView import RebinView
import rootpy.plotting as plotting
import logging
import sys
import rootpy.utils  as rootpy
import ROOT
ROOT.gROOT.SetBatch(True)

infile = ROOT.TFile.Open("results/LFVtrilepton_oct31/mmefakerate_fits/e_os_eSuperLoose_eTight_eAbsEta_vs_ePt.corrected_inputs.root")

num = infile.Get("numerator")
den = infile.Get("denominator")

eff  = ROOT.TEfficiency(num, den)

c= ROOT.TCanvas()

if num.IsA() == 'TH2' :
    eff.Draw("COLZ")
else :
    eff.Draw()

c.SaveAs("Eff.pdf")

