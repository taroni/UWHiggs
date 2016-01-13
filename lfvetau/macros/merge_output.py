#!/usr/bin/python

import os 
import sys

import os.path

d='/nfs_scratch/taroni'
inputlist = [o for o in os.listdir(d) if os.path.isdir(os.path.join(d,o)) and sys.argv[1] in o ]
print inputlist 

jobid = os.environ['jobid']



for n,job in enumerate(inputlist): 
    #print job, os.path.exists(job+'/FinalMerged')
    lastmergename=[]
    lastmergename.extend([o for o in os.listdir(d+'/'+job+'/analyze') if os.path.isdir(os.path.join(d+'/'+job+'/analyze',o))])
    #tofind = sys.argv[1].replace('*','')
    tofind = sys.argv[1]
    samplename = job[job.find(tofind)+len(tofind)+1:]
    #print samplename
    #print d+'/'+job, '/hdfs/store/user/taroni/MegaJob_'+inputlist[n]+'/'+lastmergename[0]+'.root'
    
    command = "hadd -f results/%s/%s/%s.root /hdfs/store/user/taroni/MegaJob_%s/%s.root" %(jobid, tofind, samplename,inputlist[n],lastmergename[0])
    os.system(command)

