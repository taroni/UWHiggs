import os
from sys import argv, stdout, stderr
import ROOT
import sys
import copy
ROOT.gROOT.SetStyle("Plain")
cat_now=['0','1','2']   #category names in analyzer                                                                                        
syst_names_now=['jetup','jetdown','tup','tdown','uup','udown']      #sysfolder names in analyzer                                              
histos={}
file=ROOT.TFile('LFVHEMuAnalyzerMVA/data_obs.root')
for sign in ['os','ss']:
    for j in range(2):
        for i in range(3):
            if j==0:
                hist_path="allfakes/"+sign+"/gg/"+cat_now[i]+"/h_collmass_pfmet"
            else:
                hist_path="allfakes/"+sign+"/gg/"+cat_now[i]+"/selected/nosys/h_collmass_pfmet"
            histo=file.Get(hist_path)
            new_histo=copy.copy(histo)
            new_key=hist_path.split('/',1)[1]
            new_key=new_key[:-17]
            new_key="subtracted/"+new_key
            histos[new_key]=new_histo



        for i in range(3):
            if j==0:
                hist_path="allfakesUp/"+sign+"/gg/"+cat_now[i]+"/h_collmass_pfmet"
            else:
                hist_path="allfakesUp/"+sign+"/gg/"+cat_now[i]+"/selected/nosys/h_collmass_pfmet"
            histo=file.Get(hist_path)
            new_histo=copy.copy(histo)
            new_key=hist_path.split('/',1)[1]
            new_key=new_key[:-17]
            new_key="subtractedup/"+new_key
            histos[new_key]=new_histo



        for i in range(3):
            if j==0:
                hist_path="allfakesDown/"+sign+"/gg/"+cat_now[i]+"/h_collmass_pfmet"
            else:
                hist_path="allfakesDown/"+sign+"/gg/"+cat_now[i]+"/selected/nosys/h_collmass_pfmet"
            histo=file.Get(hist_path)
            new_histo=copy.copy(histo)
            new_key=hist_path.split('/',1)[1]
            new_key=new_key[:-17]
            new_key="subtracteddown/"+new_key
            histos[new_key]=new_histo


for i in range(3):
    for k in range(len(syst_names_now)):
        hist_path="allfakesUp/os/gg/"+cat_now[i]+"/selected/"+syst_names_now[k]+"/h_collmass_pfmet"
        histo_sys=file.Get(hist_path)
        new_histo_sys=copy.copy(histo_sys)
        new_key=hist_path.split('/',1)[1]
        new_key=new_key[:-17]
        new_key="subtractedup/"+new_key
        histos[new_key]=new_histo_sys


for i in range(3):
    for k in range(len(syst_names_now)):
        hist_path="allfakes/os/gg/"+cat_now[i]+"/selected/"+syst_names_now[k]+"/h_collmass_pfmet"
        histo_sys=file.Get(hist_path)
        new_histo_sys=copy.copy(histo_sys)
        new_key=hist_path.split('/',1)[1]
        new_key=new_key[:-17]
        new_key="subtracted/"+new_key
        histos[new_key]=new_histo_sys


for i in range(3):
    for k in range(len(syst_names_now)):
        hist_path="allfakesDown/os/gg/"+cat_now[i]+"/selected/"+syst_names_now[k]+"/h_collmass_pfmet"
        histo_sys=file.Get(hist_path)
        new_histo_sys=copy.copy(histo_sys)
        new_key=hist_path.split('/',1)[1]
        new_key=new_key[:-17]
        new_key="subtracteddown/"+new_key
        histos[new_key]=new_histo_sys
outputfile=ROOT.TFile("FAKES.root","recreate")
outputfile.cd()
for key in histos.keys():
    print key
    dir0 = outputfile.mkdir(key);
    dir0.Cd('FAKES.root:/'+key);
#    print dir0
    print histos[key]
    histos[key].Write()
outputfile.Close()
