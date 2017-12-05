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
from argparse import ArgumentParser

parser = ArgumentParser(description=__doc__)
parser.add_argument('--no-plots', dest='no_plots', action='store_true',
                    default=False, help='Does not print plots')
parser.add_argument('--no-shapes', dest='no_shapes', action='store_true',
                    default=False, help='Does not create shapes for limit computation')
args = parser.parse_args()

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
    'DYJetsToLL_M-50*','DY1JetsToLL_M-50*','DY2JetsToLL_M-50*','DY3JetsToLL_M-50*','DY4JetsToLL_M-50*', 'DY1JetsToLL_M-10to50*', 'DY2JetsToLL_M-10to50*', 'DYJetsToLL_M-10to50*'
]
for x in mc_samples:
    files.extend(glob.glob('results/%s/ETauAnalyzer/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))
    
outputdir = 'plots/%s/ETauAnalyzer/%s/' % (jobid, channel)
if not os.path.exists(outputdir):
    os.makedirs(outputdir)

blind   = 'blind' not in os.environ or os.environ['blind'] == True or os.environ['blind']== 'YES'
print 'blind?', blind
blind_region = [-1000, 1000] if bool(blind) else None
print blind_region
plotter = BasePlotter(blind_region, -1, False)  #(blind_region, forcelumi, use_embedded)
plotter.files=files
plotter.lumifiles=lumifiles
plotter.outputdir = outputdir


def remove_name_entry(dictionary):
    return dict( [ i for i in dictionary.iteritems() if i[0] != 'name'] )

EWKDiboson = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('WW') or x.startswith('WZ') or x.startswith('ZZ') or x.startswith('WG'), mc_samples )]), **remove_name_entry(data_styles['WW*']))
#EWK = views.StyleView(views.SumView( 
#        *[ plotter.get_view(regex) for regex in \
#           filter(lambda x : x.startswith('EWK'),  mc_samples )]), **remove_name_entry(data_styles['WW*']))
TT = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('TT_'), mc_samples )]), **remove_name_entry(data_styles['TT_*']))
ST = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x :  x.startswith('ST_'), mc_samples )]), **remove_name_entry(data_styles['TT_*']))
TT = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('TT_') or x.startswith('ST_'), mc_samples )]), **remove_name_entry(data_styles['TT_*']))
SMH = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('VBFHToTauTau_M125') or x.startswith('GluGluHToTauTau_M125') or x.startswith('WminusHToTauTau_M12') or x.startswith('WplusHToTauTau_M125') or  x.startswith('ZHToTauTau_M125') or  x.startswith('VBFHToWW')  or  x.startswith('GluGluHToWW')  or x.startswith('ttH*'), mc_samples )]), **remove_name_entry(data_styles['GluGluHToTauTau_M125*']))
DY   = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('DY') , mc_samples )]), **remove_name_entry(data_styles['DY*']))
Wjets = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : 'JetsToLNu' in x , mc_samples )]), **remove_name_entry(data_styles['W*JetsToLNu*']))

plotter.views['EWKDiboson']={'view' : EWKDiboson }
#plotter.views['EWK']={'view':EWK}
plotter.views['Wjets']={'view' : Wjets }
plotter.views['DY']={'view' : DY }
plotter.views['SMH']={'view' : SMH }
#plotter.views['TOP']={'view' : TOP }
plotter.views['TT']={'view' : TT }
plotter.views['ST']={'view' : ST }


new_mc_samples = ['EWKDiboson', 'TT', 'ST', 'SMH', 'DY'#,'EWK'
#                  'Wjets'
]


histoname = [('ePt', 'e p_{T} (GeV)', 1, False ),
             ('ePhi','e #phi',1, False ) ,('eEta','e #eta',1, False),
             ('tPt','#tau p_{T} (GeV)',1, False) ,
             ('tPhi','#tau #phi',1, False), ('tEta','#tau #eta',1, False),
             ('e_t_DPhi','#Delta#phi(e,#tau)',1, True), ('e_t_DR','#DeltaR(e,#tau)',1, True), ('e_t_Mass', 'e-#tau Visible Mass (GeV)',1, False),
             ('type1_pfMetEt', 'type1PF MET (GeV)', 1, False) ,
             ("h_collmass_pfmet", "M_{coll}", 1, False),
             ('ePFMET_DeltaPhi','#Delta#phi(e, MET)', 1, True),  ('eMtToPfMet_type1','M_{T}(e,MET) (GeV) ',1, False),
             ('tPFMET_DeltaPhi','#Delta#phi(#tau, MET)',2, False),('tMtToPfMet_type1','M_{T}(#tau, MET) (GeV)',1, False),
             ('e_t_PZeta', 'e_t_PZeta', 1, True), ('e_t_PZetaLess0p85PZetaVis', 'e_t_PZetaLess0p85PZetaVis', 1, True), ('e_t_PZetaVis', 'e_t_PZetaVis', 1, False),
             ("jetVeto30", "Number of jets, p_{T}>30", 1, False)
]



plotter.mc_samples = new_mc_samples
foldernames=[]
sign=['os']
jets = ['le1', '0', '1']

#foldernames=['os/le1', 'os/0', 'os/1', 'os/le1/LowMass', 'os/0/LowMass', 'os/1/LowMass', 'os/le1/HighMass', 'os/0/HighMass', 'os/1/HighMass']
#foldernames=['os/le1', 'os/0', 'os/1','ss/le1', 'ss/0', 'ss/1', ]
massRanges=[ '','LowMass', 'HighMass']
for tuple_path in itertools.product(sign,  massRanges, jets):
    name=os.path.join(*tuple_path)
    foldernames.append(name)
    path = list(tuple_path)
    #for region in optimizer.regions[name[-1]]:
    #    foldernames.append(
    #        os.path.join(os.path.join(*path), region)
    #    )

if not args.no_plots:
    for foldername in foldernames:
        for n,h in enumerate(histoname) :
            plotter.pad.SetLogy(True)
            if 'DeltaPhi' in h[0] or 'ePhi' in h[0] or 'eEta' in h[0] or 'tPhi' in h[0] or 'tEta' in h[0]: plotter.pad.SetLogy(False)
            #print foldername
            if 'collmass' in h[0] or len(foldername) <= len('os/le1/HighMass') :
                #plotter.simpleplot_mc( foldername, ['GluGlu_LFV_HToETau_M200*', 'ggM300ETau', 'ggM450ETau', 'ggM600ETau', 'ggM750ETau', 'ggM900ETau'], h[0], rebin=h[2], xaxis=h[1], leftside=h[3], xrange=None, preprocess=None, sort=True,forceLumi=-1, inflateSig=[1,1,1,1,1,1])
                plotter.plot_with_bkg_uncert(foldername, h[0], h[2], h[1],
                                             leftside=h[3], show_ratio=False, ratio_range=.5, 
                                             sort=True, obj=['e'],  plot_data=True)
                
                if not os.path.exists(outputdir+foldername):
                    os.makedirs(outputdir+foldername)
            
                if 'collmass' not in h[0]:
                    plotter.save(foldername+'/'+h[0])
                else:
                    plotter.save(foldername+'/'+h[0], dotroot=True)

if not args.no_shapes:
    massRanges = ["HighMass"]
    for mass in massRanges:
        signal_region = 'os/'+mass+'/%s/%s'
        jets_names = [
            ('le1', 'le1', 1), 
            ('0', '0jet', 1),
            ('1', '1jet', 1)
        ]
        opt_folder =[ region for region in optimizer.regions[name[-1]] ]

        pjoin = os.path.join
        for njets, cat_name, rebin in jets_names:
            for region in opt_folder:
                output_path = plotter.base_out_dir
                tfile = ROOT.TFile(pjoin(output_path, 'shapes_%s%s.%s.root' %(mass,region,njets)), 'recreate')
                output_dir = tfile.mkdir(cat_name)
                unc_conf_lines, unc_vals_lines = plotter.write_shapes( 
                    signal_region % (njets,region), 'h_collmass_pfmet', output_dir, rebin=rebin,
                    br_strenght=1, last=1000)
                logging.warning('shape file %s created' % tfile.GetName()) 
                tfile.Close()
                #with open(pjoin(output_path, 'unc.%s.conf' % njets), 'w') as conf:
                #    conf.write('\n'.join(unc_conf_lines))
                #with open(pjoin(output_path, 'unc.%s.vals' % njets), 'w') as vals:
                #    vals.write('\n'.join(unc_vals_lines))
                
                #with open(pjoin(output_path,'.shapes_timestamp'),'w') as stamp:
                #    stamp.write('no use')
