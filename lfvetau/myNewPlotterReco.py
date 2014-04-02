import rootpy.plotting.views as views
from FinalStateAnalysis.PlotTools.Plotter        import Plotter
from FinalStateAnalysis.PlotTools.BlindView      import BlindView
from FinalStateAnalysis.PlotTools.PoissonView    import PoissonView
from FinalStateAnalysis.PlotTools.MedianView     import MedianView
from FinalStateAnalysis.PlotTools.ProjectionView import ProjectionView
#from FinalStateAnalysis.PlotTools.FixedIntegralView import FixedIntegralView
from FinalStateAnalysis.PlotTools.RebinView  import RebinView
from FinalStateAnalysis.MetaData.data_styles import data_styles, colors
from FinalStateAnalysis.PlotTools.decorators import memo
from FinalStateAnalysis.MetaData.datacommon  import br_w_leptons, br_z_leptons
from optparse import OptionParser
import os
import ROOT
import glob
import math
import logging
from fnmatch import fnmatch
from yellowhiggs import xs, br, xsbr

ROOT.gROOT.SetBatch()
jobid = os.environ['jobid']
print jobid
mc_samples = [
    'ggHiggsToETau',
    'vbfHiggsToETau',
#    'GluGluToHToTauTau_M-125_8TeV-powheg-pythia6',
#    'VBF_HToTauTau_M-125_8TeV-powheg-pythia6',
    'Zjets_M50',
#    'TTJets*',
#    'T_t*',
#    'Tbar_t*', 
#    'WplusJets_madgraph',
#    'WWJets*',
#    'WZJets*',
#    'ZZJets*',
]

files = []
lumifiles = []
channel = 'et'
for x in mc_samples:
    files.extend(glob.glob('results/%s/LFVHETauAnalyzer/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))


period = '8TeV'
sqrts = 7 if '7TeV' in jobid else 8

def remove_name_entry(dictionary):
    return dict( [ i for i in dictionary.iteritems() if i[0] != 'name'] )

##print filter(lambda x : x.startswith('WW') or x.startswith('WZ') or x.startswith('ZZ') or x.startswith('WG'), mc_samples )

#sign = ['os', 'ss']
#process = ['gg', 'vbf']
#ptcut = [0, 40]
sign = ['os']
process = ['gg']
ptcut = [0]

foldername = 'os/gg/ept0'

outputdir = 'plots/%s/LFVHETauAnalyzer/%s/' % (jobid, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)

plotter = Plotter(files, lumifiles, outputdir) 




EWKDiboson = views.StyleView(
    views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('WW') or x.startswith('WZ') or x.startswith('ZZ') or x.startswith('WG'), mc_samples )]
    ), **remove_name_entry(data_styles['WW*'])
)
Wplus = views.StyleView(views.SumView(  *[ plotter.get_view(regex) for regex in filter(lambda x :  x.startswith('Wplus'), mc_samples )]), **remove_name_entry(data_styles['Wplus*Jets*']))
DY = views.StyleView(views.SumView( *[ plotter.get_view(regex) for regex in filter(lambda x :  x.endswith('jets_M50'), mc_samples )]), **remove_name_entry(data_styles['Z*jets*']))
singleT = views.StyleView(views.SumView(  *[ plotter.get_view(regex) for regex in  filter(lambda x : x.startswith('T_') or x.startswith('Tbar_'), mc_samples)]), **remove_name_entry(data_styles['T*_t*']))



#plotter.views['EWKDiboson']={'view' : EWKDiboson }
#plotter.views['Wplus']={'view' : Wplus }
#plotter.views['DY']={'view' : DY }
#plotter.views['singleT']={'view' : singleT }


new_mc_samples = filter( lambda x : not x.startswith('T_') and not x.startswith('Tbar_') and not  x.endswith('jets_M50') and not x.startswith('Wplus') and not  x.startswith('WW') and not x.startswith('WZ') and not  x.startswith('ZZ') and not x.startswith('WG') and not x.endswith('HiggsToETau'), mc_samples)

new_sigsamples= filter(lambda x: x.endswith('HiggsToETau'), mc_samples)

print new_sigsamples 
new_mc_samples.extend(['EWKDiboson', 'Wplus', 'singleT', 'DY'])
print new_mc_samples

    #plotter.plot('GluGluToHToTauTau_M-125_8TeV-powheg-pythia6', 'os/gg/ept0/ePt', ' ',rebin=1, xaxis='p_{T} (GeV)')
    #plotter.save('ePt')
 
#histoname = ['tPt','tPhi','tEta','ePt','ePhi','eEta','et_DeltaPhi','et_DeltaR','tPFMET_DeltaPhi','tPFMET_Mt','tMVAMET_DeltaPhi','tMVAMET_Mt','ePFMET_DeltaPhi','ePFMET_Mt','eMVAMET_DeltaPhi','eMVAMET_Mt','jetN_20','jetN_30']
#axistitle = ['#tau p_{T} (GeV)','#tau #phi','#tau #eta', 'e p_{T} (GeV)','e #phi','e #eta','e-#tau #Delta#phi','e-#tau #DeltaR','#tau-PFMET #Delta#phi','#tau-PFMET M_{T} (GeV) ','#tau-MVAMET #Delta#phi','#tau-MVAMET M_{T} (GeV)','e-PFMET #Delta#phi','e-PFMET M_{T} (GeV)','e-MVAMET #Delta#phi','e-MVAMET #M_{T} (GeV)','Number of jets','Number of jets']

histoname = ['tPt']
axistitle = ['#tau p_{T} (GeV)']
rebins = [5,5,2,5,5,2,1, 1, 2, 5,  2, 5, 2, 5, 2, 5,1,1]

#plotter.mc_samples = new_mc_samples
plotter.mc_samples = mc_samples
for i in sign :
    for j in process:
        for k in ptcut : 
            foldername = i+'/'+j+'/ept'+str(k)


            for n,h in enumerate(histoname) :
                plotter.canvas.SetLogy(True)
                plotter.plot_mc(foldername, 'ggHiggsToETau',h, rebin=rebins[n], xaxis= axistitle[n], leftside=False, show_ratio=False, rescale=1)
                if not os.path.exists(outputdir+foldername):
                    os.makedirs(outputdir+foldername)

                plotter.save(foldername+'/mc_'+h)
