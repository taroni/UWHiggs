import ROOT

filelist = ["results/LFVtrilepton_oct31/MMEAnalyzer/DYJetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8.root",
"results/LFVtrilepton_oct31/MMEAnalyzer/DY1JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8.root",
"results/LFVtrilepton_oct31/MMEAnalyzer/DY2JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8.root",
"results/LFVtrilepton_oct31/MMEAnalyzer/DY3JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8.root",
"results/LFVtrilepton_oct31/MMEAnalyzer/DY4JetsToLL_M-50_TuneCUETP8M1_13TeV-madgraphMLM-pythia8.root"]

dirlist = ['eSSuperLoose', 'eSuperLoose', 'eVLoose', 'eTight', 'eVTight']

totnum = []
totden = []

i=0
for filename in filelist:
    myfile = ROOT.TFile.Open(filename, "READ")
    for n,mydir in enumerate(dirlist):
        
        hden = myfile.Get('os/'+mydir+'/eEta')
        den = hden.Integral()
        if len(totden) <=n :
            totden.append(den)
        else:
            totden[n]+=den

        hnum = myfile.Get('os/'+mydir+'/eGenPdgId')
        num = hnum.Integral()
        if len(totnum) <=n :
            totnum.append(num)
        else:
            totnum[n]+=num
            
        efraction = num/den
 
        print '%d, %s, %.2f, %.2f, %.2f' %(i, mydir, num, den, efraction)
    i=i+1
    print '--------------'

    myfile.Close()


print '++++++++++'
den=0
num=0
for n, jets in enumerate(totden):
    den=jets
    num=totnum[n]
    efraction=num/den 
    print '%s, %.2f, %.2f, %.2f' %(dirlist[n], num, den, efraction)
    
