import rootpy.plotting.views as views
#from FinalStateAnalysis.PlotTools.SimplePlotter        import SimplePlotter
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
import sys
logging.basicConfig(stream=sys.stderr, level=logging.WARNING)
from fnmatch import fnmatch
from yellowhiggs import xs, br, xsbr

ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)

jobid = os.environ['jobid']

print jobid
mc_samples = [
    'DYJetsToLL_M*',
    'DY1JetsToLL_M*',
    'DY2JetsToLL_M*',
    'DY3JetsToLL_M*',
    'DY4JetsToLL_M*',
    'TT_TuneCUETP8M1_13TeV-powheg-pythia8',
#    'TT_TuneCUETP8M1_13TeV-powheg-pythia8-evtgen',
    'ST_tW_top*',
    'ST_tW_antitop*',
    'ST_t-channel_top*',
    'ST_t-channel_antitop*',
    'WJetsToLNu*',
    'W1JetsToLNu*',
    'W2JetsToLNu*',
    'W3JetsToLNu*',
    'W4JetsToLNu*',
    'WWTo*',
    'WZTo*',
    'ZZTo*',
    'data*'
]

files = []
lumifiles = []
channel = 'eet'
for x in mc_samples:
    #print x
    files.extend(glob.glob('results/%s/MMEAnalyzer/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))
    


period = '13TeV'
sqrts = 13

def remove_name_entry(dictionary):
    return dict( [ i for i in dictionary.iteritems() if i[0] != 'name'] )

#sign = ['ss','os']
sign = ['os']
eiso = ['eSSuperLoose','eSuperLoose', 'eVLoose', 'eLoose', 'eTight', 'eVTight']
region = ['', 'eB', 'eE']
met = ['', 'Met30']
outputdir = 'plots/%s/MMEAnalyzer/%s/' % (jobid, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)

plotter = Plotter(files, lumifiles, outputdir) 

EWKDiboson = views.StyleView(
    views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('WW') or x.startswith('WZ') or x.startswith('ZZ') or x.startswith('WG'), mc_samples )]
#          filter(lambda x : x.startswith('WZ') , mc_samples )]
    ), **remove_name_entry(data_styles['WW*'#,'WZ*', 'WG*', 'ZZ*'
])
)
Wplus = views.StyleView(views.SumView(  *[ plotter.get_view(regex) for regex in filter(lambda x :  'JetsToLNu' in x, mc_samples )]), **remove_name_entry(data_styles['W*JetsToLNu*']))
DYLL = views.StyleView(views.SumView( *[ plotter.get_view(regex) for regex in filter(lambda x :  x.startswith('DY') , mc_samples )]), **remove_name_entry(data_styles['DY*']))
singleT = views.StyleView(views.SumView(  *[ plotter.get_view(regex) for regex in  filter(lambda x : x.startswith('ST_'), mc_samples)]), **remove_name_entry(data_styles['ST*']))
TT = views.StyleView(views.SumView(  *[ plotter.get_view(regex) for regex in  filter(lambda x : x.startswith('TT'), mc_samples)]), **remove_name_entry(data_styles['TT*']))
#SMH = views.StyleView(views.SumView( *[ plotter.get_view(regex) for regex in filter(lambda x : 'HToTauTau' in x , mc_samples)]), **remove_name_entry(data_styles['GluGluToHToTauTau*']))


plotter.views['EWKDiboson']={'view' : EWKDiboson }
plotter.views['Wplus']={'view' : Wplus }
plotter.views['DYLL']={'view' : DYLL }
plotter.views['singleT']={'view' : singleT }
plotter.views['TT']={'view' : TT }
#plotter.views['SMH']={'view' : SMH }

new_mc_samples = []
new_mc_samples.extend(['EWKDiboson', 'singleT','Wplus', 'DYLL' , 'TT'
])

histoname = [('m1Pt','m1 p_{T} (GeV)', 2),('m1Phi','m1 #phi',2),('m1Eta','m1 #eta',1),('m2Pt','m2 p_{T} (GeV)',2),('m2Phi','m2 #phi',2),('m2Eta','m2 #eta',1),
             ('m1_m2_Mass', 'm1-m2 Inv Mass (GeV)',1), ('ePt','e p_{T} (GeV)',2), ('ePhi','e #phi',2),('eEta','e #eta',5),('eAbsEta','e |#eta|',5),
             ( 'jetVeto30', 'Number of jets, p_{T}>30', 1),( 'jetVeto20', 'Number of jets, p_{T}>20', 1), ('eGenPdgId', 'e Gen pdgID', 1) , ('nvtx', 'number of vertices', 2), ('nTruePU', 'true pileup', 1), ('type1_pfMetEt', 'type1 MET', 1) ]
plotter.mc_samples = new_mc_samples

#print plotter.mc_samples

for i in eiso :
    for s in sign :
        for r in region :
            for m in met :
                foldername = s+'/'+i+'/'+r + '/' + m
                if not os.path.exists(outputdir+foldername):
                    os.makedirs(outputdir+foldername)

                for h in histoname:
                    print h

                    plotter.plot_mc_vs_data(foldername,h[0], rebin=h[2], xaxis=h[1], leftside=False, show_ratio=True, ratio_range=0.5, sort=True)
                    plotter.save(foldername+'/'+h[0])
            
##        jets=0
##        while jets <  4 :
##            foldername = s+'/'+i+'/'+str(int(jets))
##            if not os.path.exists(outputdir+foldername):
##                os.makedirs(outputdir+foldername)
##            for h in histoname:
##               
##                plotter.plot_mc_vs_data(foldername,h[0], rebin=h[2], xaxis=h[1], leftside=False, show_ratio=True, ratio_range=0.5, sort=True)
##                plotter.save(foldername+'/'+h[0])
##
                
##            jets+=1

            
