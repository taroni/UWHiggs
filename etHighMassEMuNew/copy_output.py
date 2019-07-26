#!/usr/bin/python

import os 
import sys

import os.path
jobid = os.environ['jobid']
d='/nfs_scratch/taroni'
inputlist = [o for o in os.listdir(d) if os.path.isdir(os.path.join(d,o)) and sys.argv[1] in o ]
print inputlist 




for n,job in enumerate(inputlist):
    sample = job[job.find("EMAnalyzer"):]
    sample = sample[sample.find("-")+1:]
    analyzer = job[job.find("SimpleEMAnalyzer"):]
    analyzer = analyzer[:analyzer.find("-")]
    cmd = "hadd -f results/fromNab/%s/%s.root /hdfs/store/user/taroni/MegaJob_%s/*.root" %(analyzer, sample, job)
    #print cmd
    os.system(cmd)


    
    #print job, os.path.exists(job+'/FinalMerged')
    #lastmergename=[]
    #if os.path.exists(d+'/'+job+'/analy'):
    #    lastmergename.extend([o for o in os.listdir(d+'/'+job+'/FinalMerged') if os.path.isdir(os.path.join(d+'/'+job+'/FinalMerged',o))])
    #    
    #else :
    #    lastmergename.extend([o for o in os.listdir(d+'/'+job+'/analyze') if os.path.isdir(os.path.join(d+'/'+job+'/analyze',o))])
    ###tofind = sys.argv[1].replace('*','')
    ##tofind = sys.argv[1]
    ##samplename = job[job.find(tofind)+len(tofind)+1:]
    ###print samplename
    ###print d+'/'+job, '/hdfs/store/user/taroni/MegaJob_'+inputlist[n]+'/'+lastmergename[0]+'.root'
    ##
    ##command = "cp /hdfs/store/user/taroni/MegaJob_%s/%s.root results/%s/%s/%s.root" %(inputlist[n],lastmergename[0],jobid,tofind, samplename)
    ##os.system(command)

    
