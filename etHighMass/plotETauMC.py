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
from BasePlotter import BasePlotter
import optimizer

ROOT.gROOT.SetBatch()
ROOT.gStyle.SetOptStat(0)
ROOT.gStyle.SetOptTitle(0)
jobid = os.environ['jobid']
files = []
lumifiles = []
channel = 'et'
period = '13TeV'
sqrts = 13
sign = ['os']
jets = ['le1', '0', '1']

mc_samples = [#'ggM300ETau','ggM450ETau','ggM600ETau','ggM750ETau','ggM900ETau',
              'WWTo*', 'ZZ*','WZ*', 'GluGluHToTauTau_M125*', 'ttHJet*', 'ST_*', 'TT_*', 'VBFHToTauTau_M125*', 'WG*',   'WminusHToTauTau_M125*', 'WplusHToTauTau_M125*', 'ZHToTauTau_M125*','EWK*'
#    'WJetsToLNu*','W1JetsToLNu*','W2JetsToLNu*','W3JetsToLNu*','W4JetsToLNu*',
    'DYJetsToLL*','DY1JetsToLL*','DY2JetsToLL*','DY3JetsToLL*','DY4JetsToLL*', 'data_MuonEG*'
]
for x in mc_samples:
    files.extend(glob.glob('results/%s/ETauAnalyzer/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))
    
outputdir = 'plots/%s/ETauAnalyzer/%s/' % (jobid, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)

plotter = BasePlotter(None, -1, False)  #(blind_region, forcelumi, use_embedded)
plotter.files=files
plotter.lumifiles=lumifiles
plotter.outputdir = outputdir


def remove_name_entry(dictionary):
    return dict( [ i for i in dictionary.iteritems() if i[0] != 'name'] )

EWKDiboson = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('WW') or x.startswith('WZ') or x.startswith('ZZ') or x.startswith('WG'), mc_samples )]), **remove_name_entry(data_styles['WW*']))
TOP = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('TT_') or x.startswith('ST_'), mc_samples )]), **remove_name_entry(data_styles['TT_*']))
SMH = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('VBFHToTauTau_M125') or x.startswith('GluGluHToTauTau_M125') or x.startswith('WminusHToTauTau_M12') or x.startswith('WplusHToTauTau_M125') or  x.startswith('ZHToTauTau_M125') or  x.startswith('VBFHToWW')  or  x.startswith('GluGluHToWW')  or x.startswith('ttH*'), mc_samples )]), **remove_name_entry(data_styles['GluGluHToTauTau_M125*']))
DY   = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('DY') , mc_samples )]), **remove_name_entry(data_styles['DY*']))
#Wjets = views.StyleView(views.SumView( 
#        *[ plotter.get_view(regex) for regex in \
#          filter(lambda x : 'JetsToLNu' in x , mc_samples )]), **remove_name_entry(data_styles['W*JetsToLNu*']))

plotter.views['EWKDiboson']={'view' : EWKDiboson }
#plotter.views['Wjets']={'view' : Wjets }
plotter.views['DY']={'view' : DY }
plotter.views['SMH']={'view' : SMH }
plotter.views['TOP']={'view' : TOP }


new_mc_samples = ['EWKDiboson', 'TOP', 'SMH', 'DY',
#                  'Wjets'
]


histoname = [('ePt', 'e p_{T} (GeV)', 1, False ), ('ePhi','e #phi',1, False ) ,('eEta','e #eta',1, False),
             ('tPt','#tau p_{T} (GeV)',1, False) ,('tPhi','#tau #phi',1, False), ('tEta','#tau #eta',1, False),
             ('e_t_DPhi','#Delta#phi(e,#tau)',1, True), ('e_t_DR','#DeltaR(e,#tau)',1, True), ('e_t_Mass', 'e-#tau Visible Mass (GeV)',1, False),
             ('type1_pfMetEt', 'type1PF MET (GeV)', 1, False) , ("h_collmass_pfmet", "M_{coll}", 1, False),
             ('ePFMET_DeltaPhi','#Delta#phi(e, MET)', 1, True),  ('eMtToPfMet_type1','M_{T}(e,MET) (GeV) ',1, False),
             ('tPFMET_DeltaPhi','#Delta#phi(#tau, MET)',2, False),('tMtToPfMet_type1','M_{T}(#tau, MET) (GeV)',1, False),
             ('e_t_PZeta', 'e_t_PZeta', 1, True), ('e_t_PZetaLess0p85PZetaVis', 'e_t_PZetaLess0p85PZetaVis', 1, True), ('e_t_PZetaVis', 'e_t_PZetaVis', 1, False),
             ("jetVeto30", "Number of jets, p_{T}>30", 1, False)
]



plotter.mc_samples = new_mc_samples

#foldernames=['os/le1', 'os/0', 'os/1', 'os/le1/LowMass', 'os/0/LowMass', 'os/1/LowMass', 'os/le1/HighMass', 'os/0/HighMass', 'os/1/HighMass']
foldernames=['os/le1', 'os/0', 'os/1']
massRanges=['LowMass', 'HighMass']
for tuple_path in itertools.product(sign,  massRanges, jets):
    name=os.path.join(*tuple_path)
    foldernames.append(name)
    path = list(tuple_path)
    for region in optimizer.regions[name[-1]]:
        foldernames.append(
            os.path.join(os.path.join(*path), region)
        )


for foldername in foldernames:
    for n,h in enumerate(histoname) :
        plotter.pad.SetLogy(False)
        #print foldername
        if 'collmass' in h[0] or len(foldername) <= len('os/le1/HighMass') :
            plotter.simpleplot_mc( foldername, ['GluGlu_LFV_HToETau_M200*', 'ggM300ETau', 'ggM450ETau', 'ggM600ETau', 'ggM750ETau', 'ggM900ETau'], h[0], rebin=h[2], xaxis=h[1],
                                   leftside=h[3], xrange=None, preprocess=None, sort=True,forceLumi=-1, inflateSig=[50,1,1,1,1,1])
 
            
            if not os.path.exists(outputdir+foldername):
                os.makedirs(outputdir+foldername)
            
            if 'collmass' not in h[0]:
                plotter.save(foldername+'/'+h[0])
            else:
                plotter.save(foldername+'/'+h[0], dotroot=True)
