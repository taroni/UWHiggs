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
import ROOT
import glob
import math
import logging
import pdb
import array
from fnmatch import fnmatch
from yellowhiggs import xs, br, xsbr

from BasePlotter import BasePlotter

ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)

jobid = os.environ['jobid']

mc_samples = ['ggM300ETau','ggM450ETau','ggM600ETau','ggM750ETau','ggM900ETau']

files = []
lumifiles = []
channel = 'signalMC'
for x in mc_samples:
    files.extend(glob.glob('results/%s/ETauAnalyzer/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))

period = '13TeV'
sqrts = 13

def remove_name_entry(dictionary):
    return dict( [ i for i in dictionary.iteritems() if i[0] != 'name'] )


sign = ['os']
jets = [0, 1]
outputdir = 'plots/%s/ETauAnalyzer/%s/' % (jobid, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)

plotter = BasePlotter(None, 1000, False) 
plotter.outputdir = outputdir
histoname = [('ePt', 'e p_{T} (GeV)', 1), ('ePhi','e #phi',1) ,('eEta','e #eta',1),
             ('tPt','#tau p_{T} (GeV)',1) ,('tPhi','#tau #phi',1), ('tEta','#tau #eta',1),
             ('e_t_DPhi','#Delta#phi(e,#tau)',1), ('e_t_DR','#DeltaR(e,#tau)',1), ('e_t_Mass', 'e-#tau Visible Mass (GeV)',1),
             ('type1_pfMetEt', 'type1PF MET (GeV)', 1) , 
             ('ePFMET_DeltaPhi','#Delta#phi(e, MET)', 1),  ('eMtToPfMet_type1','M_{T}(e,MET) (GeV) ',1),
             ('tPFMET_DeltaPhi','#Delta#phi(#tau, MET)',2),('tMtToPfMet_type1','M_{T}(#tau, MET) (GeV)',1),
             ('e_t_PZeta', 'e_t_PZeta', 1), ('e_t_PZetaLess0p85PZetaVis', 'e_t_PZetaLess0p85PZetaVis', 1), ('e_t_PZetaVis', 'e_t_PZetaVis', 1),
             ("jetVeto30", "Number of jets, p_{T}>30", 1)
]

plotter.mc_samples = mc_samples

foldernames=['os/le1', 'os/0', 'os/1']

for foldername in foldernames:
    for n,h in enumerate(histoname) :
        plotter.pad.SetLogy(False)
        print foldername
        plotter.simple_mcSignal(foldername, h[0], rebin=h[2], xaxis=h[1], leftside=False,  sort=True, forceLumi=1000)
        
        if not os.path.exists(outputdir+foldername):
            os.makedirs(outputdir+foldername)
            
        plotter.save(foldername+'/'+h[0])

