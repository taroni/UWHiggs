import ROOT
import sys
import optimizer

jobid = os.environ['jobid']

filename='h_collmass_pfmet.root'

channel='et'
sign=['os']
jets = ['le1', '0', '1']
massRanges=[ 'LowMass', 'HighMass']

for tuple_path in itertools.product(sign,  massRanges):
    name=os.path.join(*tuple_path)
    foldernames.append(name)
    path = list(tuple_path)
    for region in optimizer.regions[name[-1]]:
        foldernames.append(
            os.path.join(os.path.join(*path), region)
        )
inputdir = 'plots/%s/ETauAnalyzer_16Nov/%s/' % (jobid, channel)

for folder in foldernames:
    path=inputdir+folder
    outputfile= ROOT.TFile(path+'/h_collmass_limits.root')
    dir0=outputfile.mkdir(channel+'_0jet')
    dir0->cd()
    inputfile0 = ROOT.TFile.Open(path+'/0/'+filename)
    canvas0 = inputfile0.Get('adsf')
    
    

    
    
