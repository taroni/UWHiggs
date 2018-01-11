import ROOT
import sys
import os

from os import listdir
from os.path import isfile, join
mypath = 'plots/LFV_Mar15_mc/ETauAnalyzer'
onlyfiles = [f for f in listdir(mypath) if (isfile(join(mypath, f)) and '.0.root' in f) ]

if not os.path.exists(mypath+'/shapes'):
    os.makedirs(mypath+'/shapes')
    
for filename in onlyfiles:
    outfile  =  filename[:filename.find('.0.root')]+'.root'
    cmd="hadd %s/shapes/%s %s/%s %s/%s" %(mypath, outfile, mypath, filename, mypath,  filename.replace('.0.root', '.1.root'))
    os.system(cmd)
    cmd="cp %s %s/shapes/." %(filename.replace('.0.root', '.le1.root'), mypath)

