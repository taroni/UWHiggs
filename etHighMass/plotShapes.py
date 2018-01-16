# python plotShapes.py filename.root
import ROOT

import sys
import os
from os import listdir
from os.path import isfile, join


ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)


mypath = 'plots/LFV_Mar15_mc/ETauAnalyzer/shapes/'

outdir = 'plots/LFV_Mar15_mc/ETauAnalyzer/shapes/figures'

if not os.path.exists(outdir):
    os.makedirs(outdir)


infile = ROOT.TFile.Open(mypath+sys.argv[1])
print mypath+sys.argv[1], infile

listdir = ['0jet', '1jet']

canvas= ROOT.TCanvas()
canvas.Draw()

for mydir in listdir:
    histodir = infile.Get(mydir)
    #print histodir, histodir.GetListOfKeys()
    histolist=[]
    #for i in range(0,len(histodir.GetListOfKeys())):
    #    print histodir.GetListOfKeys().At(i).GetName()
        
    histolist=[histodir.GetListOfKeys().At(i).GetName() for  i in range(0,len(histodir.GetListOfKeys())) if 'Up' in histodir.GetListOfKeys().At(i).GetName() ]
    #print histolist
    if not os.path.exists(outdir+'/'+mydir):
        os.makedirs(outdir+'/'+mydir)


    legend  = ROOT.TLegend(0.65,0.85, 0.85, 0.6)
    
    for histo in histolist:
        legend.Clear()
        
        h_center=histodir.Get( histo[:histo.find('_')])
        h_Up = histodir.Get(histo)
        h_Down = histodir.Get(histo.replace('Up', 'Down'))

        h_center.Scale(1./h_center.Integral())
        h_center.Draw('HIST')
        h_center.SetFillColor(0)
        h_center.SetLineColor(1)
        h_Up.Scale(1./h_Up.Integral())
        h_Up.Draw('SAMESHIST')
        h_Up.SetFillColor(0)
        h_Up.SetLineColor(2)
        h_Down.Scale(1./h_Down.Integral())
        h_Down.Draw('SAMESHIST')
        h_Down.SetFillColor(0)
        h_Down.SetLineColor(4)

        
        legend.AddEntry(h_center, 'central', 'l')
        legend.AddEntry(h_Up, 'Up', 'l')
        legend.AddEntry(h_Down, 'Down', 'l')

        legend.Draw()
        

        canvas.Update()

        canvas.SaveAs(outdir+'/'+mydir+'/'+histo.replace('Up', '.png'))
        canvas.SaveAs(outdir+'/'+mydir+'/'+histo.replace('Up', '.pdf'))
