#!/usr/bin/python
import sys
import os
import subprocess

from os import listdir
from os.path import isfile, join
for i in range(1, 21):
    if i == 2: continue 

    dirname='inputs/run2_%sfb/' %str(i)
    if not os.path.exists(dirname):
        os.makedirs(dirname)

    olddir = 'inputs/run2/'
    onlyfiles = [f for f in listdir(olddir) if isfile(join(olddir, f)) and 'lumicalc.sum' in f]

    for f in onlyfiles:
        
        newf = open (join(dirname, f), 'w')
        oldf = open (join(olddir, f), 'r')
        if 'data' in f:
            lumi = float(oldf.readline())
            print lumi, lumi*i*1000./2110.
            newf.write(str(lumi*i*1000./2110.))
            
        else:
            lumi = oldf.readline()
            newf.write(lumi)
        newf.close()
        oldf.close()

    os.system("cp -r results/run2 results/run2_%sfb" %i )

    
