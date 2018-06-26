# python plotShapes.py filename.root
import ROOT

import sys
import os
from os import listdir
from os.path import isfile, join


ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)
ROOT.gStyle.SetHistLineWidth(2)
ROOT.gROOT.ForceStyle()

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
        
    histolist=[histodir.GetListOfKeys().At(i).GetName() for  i in range(0,len(histodir.GetListOfKeys())) if 'Up' in histodir.GetListOfKeys().At(i).GetName() and 'Down' not in histodir.GetListOfKeys().At(i).GetName()]
    #print histolist
    if not os.path.exists(outdir+'/'+mydir):
        os.makedirs(outdir+'/'+mydir)


    legend  = ROOT.TLegend(0.65,0.85, 0.8, 0.7)
    
    for histo in histolist:
        hmax = 0
        legend.Clear()
        #print mydir,  histo[:histo.find('_')], histo, histo.rindex('Up'), histo[:histo.rindex('Up')]+'Down'
        h_center=histodir.Get( histo[:histo.find('_')])
        h_Up = histodir.Get(histo)
        h_Down = histodir.Get( histo[:histo.rfind('Up')]+'Down')
        #print h_center.GetName(), h_Up.GetName(), h_Down.GetName()
        h_center.Scale(1./h_center.Integral())
        h_center.Draw('HIST')
        h_center.SetFillColor(0)
        h_center.SetLineColor(1)

        h_center.GetXaxis().SetTitle('M_{col} [GeV]')
        h_center.GetYaxis().SetTitle('a. u.')
        
        h_Up.Scale(1./h_Up.Integral())
        h_Up.Draw('SAMESHIST')
        h_Up.SetFillColor(0)
        h_Up.SetLineColor(2)
        h_Down.Scale(1./h_Down.Integral())
        h_Down.Draw('SAMESHIST')
        h_Down.SetFillColor(0)
        h_Down.SetLineColor(4)

        if h_center.GetBinContent(h_center.GetMaximumBin()) > hmax:
            hmax=h_center.GetBinContent(h_center.GetMaximumBin())
        if h_Up.GetBinContent(h_Up.GetMaximumBin()) > hmax:
            hmax=h_Up.GetBinContent(h_Up.GetMaximumBin()) 
        if h_Down.GetBinContent(h_Down.GetMaximumBin()) > hmax:
            hmax=h_Up.GetBinContent(h_Down.GetMaximumBin()) 

        h_center.GetYaxis().SetRangeUser(0, 1.2*hmax)
            
        legend.AddEntry(h_center, 'Central', 'l')
        legend.AddEntry(h_Up, 'Up', 'l')
        legend.AddEntry(h_Down, 'Down', 'l')

        legend.Draw()
        

        canvas.Update()

        canvas.SaveAs(outdir+'/'+mydir+'/'+histo.replace('Up', '.png'))
        canvas.SaveAs(outdir+'/'+mydir+'/'+histo.replace('Up', '.pdf'))

        del h_center
        del h_Up
        del h_Down
