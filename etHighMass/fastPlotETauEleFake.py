## To plot
##python fastPlotETau.py -m  "" -m "LowMass HighMass" -j "le1 0 1" 

import rootpy.plotting.views as views

from FinalStateAnalysis.PlotTools.BlindView      import BlindView
from FinalStateAnalysis.PlotTools.PoissonView    import PoissonView
from FinalStateAnalysis.PlotTools.MedianView     import MedianView
from FinalStateAnalysis.PlotTools.ProjectionView import ProjectionView
#from FinalStateAnalysis.PlotTools.FixedIntegralView import FixedIntegralView
from FinalStateAnalysis.PlotTools.RebinView  import RebinView
from FinalStateAnalysis.MetaData.data_styles import data_styles, colors
from FinalStateAnalysis.PlotTools.decorators import memo
from FinalStateAnalysis.MetaData.datacommon  import br_w_leptons, br_z_leptons
from FinalStateAnalysis.PlotTools.SubtractionView      import SubtractionView, PositiveView
from optparse import OptionParser
import os
import itertools
import ROOT
import glob
import math
import logging
import pdb
import array
from fnmatch import fnmatch
from yellowhiggs import xs, br, xsbr
from BasePlotterEleFake import BasePlotter
import optimizer
from argparse import ArgumentParser

DEBUG = True

parser = ArgumentParser(description=__doc__)
parser.add_argument('--no-plots', dest='no_plots', action='store_true',
                    default=False, help='Does not print plots')
parser.add_argument('--no-shapes', dest='no_shapes', action='store_true',
                    default=False, help='Does not create shapes for limit computation')
parser.add_argument('-s','--signdir', dest='signDirs', type=str, action='append', help='sign directory', required=True)
parser.add_argument('-m','--massdir', dest='massDirs', type=str, action='append', help='mass directory', required=True)
parser.add_argument('-j','--jetdir', dest='jetDirs', type=str, action='append', help='jet directory', required=True)

args = parser.parse_args()
#print [item for i in range(0, len(args.jetDirs)) for item in args.jetDirs[i].split(' ') ],  [item for i in range(0, len(args.massDirs)) for item in args.massDirs[i].split(' ')]

ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)
jobid = os.environ['jobid']
files = []
lumifiles = []
channel = 'et'
period = '13TeV'
sqrts = 13

mc_samples = [
    'WWTo*', 'ZZ*','WZ*', 'GluGluHToTauTau_M125*', 'ttHJet*', 'ST_*', 'TT_*', 'VBFHToTauTau_M125*', 'WG*',   'WminusHToTauTau_M125*', 'WplusHToTauTau_M125*', 'ZHToTauTau_M125*',#'EWK*', 
    #'WJetsToLNu*','W1JetsToLNu*','W2JetsToLNu*','W3JetsToLNu*','W4JetsToLNu*',
    'DYJetsToLL_M-50*','DY1JetsToLL_M-50*','DY2JetsToLL_M-50*','DY3JetsToLL_M-50*','DY4JetsToLL_M-50*', 'DY1JetsToLL_M-10to50*', 'DY2JetsToLL_M-10to50*', 'DYJetsToLL_M-10to50*',
    'DYJetsToTT_M-50*','DY1JetsToTT_M-50*','DY2JetsToTT_M-50*','DY3JetsToTT_M-50*','DY4JetsToTT_M-50*'
    ]
for x in mc_samples:
    files.extend(glob.glob('results/%s/ETauAnalyzerEleFake/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))
    
outputdir = 'plots/%s/ETauAnalyzerEleFake/%s/' % (jobid, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)


col_vis_mass_binning=array.array('d',(range(0,190,20)+range(200,480,30)+range(500,600,50)+range(600,700,100)+range(700,1000, 300)))
met_vars_binning=array.array('d',(range(0,190,20)+range(200,580,40)+range(600,1000,100)))
pt_vars_binning=array.array('d',(range(0,190,20)+range(200,500,40)+range(500,1000,100)))


    
histoname = [('ePt', 'e p_{T} (GeV)', pt_vars_binning, False ),
             ('ePhi','e #phi',1, False ) ,('eEta','e #eta',1, False),
             ('tPt','#tau p_{T} (GeV)',pt_vars_binning, False) ,
             ('tPhi','#tau #phi',1, False), ('tEta','#tau #eta',1, False),
             ('e_t_DPhi','#Delta#phi(e,#tau)',1, True), ('e_t_DR','#DeltaR(e,#tau)',1, True), ('e_t_Mass', 'e-#tau Visible Mass (GeV)',col_vis_mass_binning, False),
             ('met', 'type1PF MET (GeV)', met_vars_binning, False) ,
             ("h_collmass_pfmet", "M_{coll}", col_vis_mass_binning, False),
             ("visfrac", "x_{vis}", 5, False),
#             ('ePFMET_DeltaPhi','#Delta#phi(e, MET)', 1, True),
             ('eMtToPfMet_type1','M_{T}(e,MET) (GeV) ',5, False),
             #('tPFMET_DeltaPhi','#Delta#phi(#tau, MET)',2, False),
             ('tMtToPfMet_type1','M_{T}(#tau, MET) (GeV)',5, False),
             ('e_t_PZeta', 'e_t_PZeta', 1, True), ('e_t_PZetaLess0p85PZetaVis', 'e_t_PZetaLess0p85PZetaVis', 1, True), ('e_t_PZetaVis', 'e_t_PZetaVis', 1, False),
             ("jetVeto30", "Number of jets, p_{T}>30", 1, False)
]

            
foldernames=[]
sign=[item for i in range(0, len(args.signDirs)) for item in args.signDirs[i].split(' ') ]
jets = [item for i in range(0, len(args.jetDirs)) for item in args.jetDirs[i].split(' ') ]
massRanges = [item for i in range(0, len(args.massDirs)) for item in args.massDirs[i].split(' ')]
for tuple_path in itertools.product(sign,  massRanges, jets):
    name=os.path.join(*tuple_path)
    foldernames.append(name)
    path = list(tuple_path)
    if DEBUG: print name

blind   = 'blind' not in os.environ 
if 'blind' in os.environ:
    blind = os.environ['blind']
print 'blind?', blind
blind_region = [-1000, 1000] if bool(blind) else None

print blind_region

def remove_name_entry(dictionary):
    return dict( [ i for i in dictionary.iteritems() if i[0] != 'name'] )

plotter = BasePlotter(blind_region, -1, False)  #(blind_region, forcelumi, use_embedded)
plotter.files=files
plotter.lumifiles=lumifiles
plotter.outputdir = outputdir

print 'plotting samples', filter(lambda x : 'JetsToTT' in x , mc_samples ), filter(lambda x : 'JetsToLL' in x , mc_samples )

EWKDiboson = views.StyleView(views.SumView( 
*[ plotter.get_view(regex) for regex in \
   filter(lambda x : x.startswith('WW') or x.startswith('WZ') or x.startswith('ZZ') or x.startswith('WG'), mc_samples )]), **remove_name_entry(data_styles['WW*']))
TT = views.StyleView(views.SumView( 
    *[ plotter.get_view(regex) for regex in \
       filter(lambda x : x.startswith('TT'), mc_samples )]), **remove_name_entry(data_styles['TT_*']))
ST = views.StyleView(views.SumView( 
    *[ plotter.get_view(regex) for regex in \
       filter(lambda x :  x.startswith('ST_'), mc_samples )]), **remove_name_entry(data_styles['ST_*']))
#TT = views.StyleView(views.SumView( 
#    *[ plotter.get_view(regex) for regex in \
#       filter(lambda x : x.startswith('TT_') or x.startswith('ST_'), mc_samples )]), **remove_name_entry(data_styles['TT_*']))
SMH = views.StyleView(views.SumView( 
    *[ plotter.get_view(regex) for regex in \
       filter(lambda x : x.startswith('VBFHToTauTau_M125') or x.startswith('GluGluHToTauTau_M125') or x.startswith('WminusHToTauTau_M12') or x.startswith('WplusHToTauTau_M125') or  x.startswith('ZHToTauTau_M125') or  x.startswith('VBFHToWW')  or  x.startswith('GluGluHToWW')  or x.startswith('ttH*'), mc_samples )]), **remove_name_entry(data_styles['GluGluHToTauTau_M125*']))
DYTT   = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : 'JetsToTT' in x , mc_samples )]), **remove_name_entry(data_styles['DYJetsToTT*']))

DY   = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : 'JetsToLL' in x , mc_samples )]), **remove_name_entry(data_styles['DYJetsToLL*']))

Wjets = views.StyleView(views.SumView( 
    *[ plotter.get_view(regex) for regex in \
       filter(lambda x : 'JetsToLNu' in x , mc_samples )]), **remove_name_entry(data_styles['W*JetsToLNu*']))

plotter.views['EWKDiboson']={'view' : EWKDiboson }
plotter.views['Wjets']={'view' : Wjets }
plotter.views['DY']={'view' : DY }
plotter.views['DYTT']={'view' : DYTT }
plotter.views['SMH']={'view' : SMH }
plotter.views['TT']={'view' : TT }
plotter.views['ST']={'view' : ST }


new_mc_samples = ['DYTT','EWKDiboson', 'TT', 'ST', 'SMH', 'DY' #,'EWK'
                  #                  'Wjets'
]

plotter.mc_samples = new_mc_samples
for foldername in foldernames:
    if DEBUG: print foldername
    if not os.path.exists(outputdir+foldername):
        os.makedirs(outputdir+foldername)


    for n,h in enumerate(histoname) :
        plotter.pad.SetLogy(True)
        if 'DeltaPhi' in h[0] or 'ePhi' in h[0] or 'eEta' in h[0] or 'tPhi' in h[0] or 'tEta' in h[0]: plotter.pad.SetLogy(False)
        #print foldername
        if 'collmass' in h[0] or len(foldername) <= len('os/le1/HighMass') :
            xrange=None
            if 'PZeta' in h[0] :  xrange=[-150, 150] 
            plotter.plot_with_bkg_uncert(foldername, h[0], h[2], h[1],
                                         leftside=h[3], xrange=xrange, show_ratio=True, ratio_range=.5, 
                                         sort=True, obj=['e'],  plot_data=True)
                                            
            if 'collmass' not in h[0]:
                plotter.save(foldername+'/'+h[0])
            else:
                plotter.save(foldername+'/'+h[0], dotroot=True)
