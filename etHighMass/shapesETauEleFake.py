
import rootpy.plotting.views as views
from FinalStateAnalysis.PlotTools.BlindView      import BlindView
from FinalStateAnalysis.PlotTools.PoissonView    import PoissonView
from FinalStateAnalysis.PlotTools.MedianView     import MedianView
from FinalStateAnalysis.PlotTools.ProjectionView import ProjectionView
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

parser = ArgumentParser(description=__doc__)
parser.add_argument('--no-plots', dest='no_plots', action='store_true',
                    default=False, help='Does not print plots')
parser.add_argument('--no-shapes', dest='no_shapes', action='store_true',
                    default=False, help='Does not create shapes for limit computation')
parser.add_argument('-m','--massdir', dest='massDirs', type=str, action='append', help='mass directory', required=True)
parser.add_argument('-j','--jetdir', dest='jetDirs', type=str, action='append', help='jet directory', required=True)

parser.add_argument('--optimization', dest='optimization', action='store_true',
                    default=False, help='Does not create shapes for optimization')

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
    'WWTo*', 'ZZ*','WZ*', 'GluGluHToTauTau_M125*', 'ttHJet*', 'ST_*', 'TT_*', 'VBFHToTauTau_M125*', 'WG*',   'WminusHToTauTau_M125*', 'WplusHToTauTau_M125*', 'ZHToTauTau_M125*',
    'DYJetsToLL_M-50*','DY1JetsToLL_M-50*','DY2JetsToLL_M-50*','DY3JetsToLL_M-50*','DY4JetsToLL_M-50*', 'DY1JetsToLL_M-10to50*', 'DY2JetsToLL_M-10to50*', 'DYJetsToLL_M-10to50*', 'DYJetsToTT*', 'DY1JetsToTT*', 'DY2JetsToTT*', 'DY3JetsToTT*', 'DY4JetsToTT*']


for x in mc_samples:
    files.extend(glob.glob('results/%s/ETauAnalyzerEleFake/%s.root' % (jobid, x)))
    lumifiles.extend(glob.glob('inputs/%s/%s.lumicalc.sum' % (jobid, x)))
    
outputdir = 'plots/%s/ETauAnalyzerEleFake/%s/' % (jobid, channel)
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
          filter(lambda x : x.startswith('DY') and 'JetsToLL' in x , mc_samples )]), **remove_name_entry(data_styles['DYJetsToLL*']))
DYTT   = views.StyleView(views.SumView( 
        *[ plotter.get_view(regex) for regex in \
          filter(lambda x : x.startswith('DY') and   'JetsToTT' in x , mc_samples )]), **remove_name_entry(data_styles['DYJetsToTT*']))
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

new_mc_samples = ['EWKDiboson', 'TT', 'ST', 'SMH', 'DY', 'DYTT'#,'EWK'
]

#col_vis_mass_binning=array.array('d',(range(0,190,20)+range(200,480,30)+range(500,1000,50)))
col_vis_mass_binning=array.array('d',(range(0,190,20)+range(200,480,30)+range(500,600,50)+range(600,700,100)+range(700,1300,300)))

plotter.mc_samples = new_mc_samples

sign=['os']
#jets = ['le1', '0', '1']


massRanges = [item for i in range(0, len(args.massDirs)) for item in args.massDirs[i].split(' ')]
jets =  [item for i in range(0, len(args.jetDirs)) for item in args.jetDirs[i].split(' ')]

for mass in massRanges:
    signal_region = 'os/'+mass+'/%s/%s'
    #jets_names = [
    #    ('le1', 'le1' , col_vis_mass_binning), 
    #    ('0'  , '0jet', col_vis_mass_binning),
    #    ('1'  , '1jet', col_vis_mass_binning)
    #]
    jets_names = {
        'le1': ('le1', col_vis_mass_binning),
        '0'  : ('0jet', col_vis_mass_binning),
        '1'  : ('1jet', col_vis_mass_binning)
    }
    
    pjoin = os.path.join
    for njets in jets:
        cat_name = jets_names[njets][0]
        rebin = jets_names[njets][1]
        #output_path = plotter.base_out_dir
        output_path=outputdir
        #for njets, cat_name, rebin in jets_names:
        if not args.optimization:

            tfile = ROOT.TFile(pjoin(output_path, 'shapes_%s.%s.root' %(mass,njets)), 'recreate')
            output_dir = tfile.mkdir(cat_name)
            unc_conf_lines, unc_vals_lines = plotter.write_shapes_with_syst( 
                'os/'+mass+'/%s' % (njets), 'h_collmass_pfmet', output_dir, rebin=rebin,
                br_strenght=1)
            logging.warning('shape file %s created' % tfile.GetName()) 
            tfile.Close()
        if args.optimization:
            opt_folder =[ region for region in optimizer.regions[njets]]
            for region in opt_folder:
                tfile = ROOT.TFile(pjoin(output_path, 'shapes_%s%s.%s.root' %(mass,region,njets)), 'recreate')
                output_dir = tfile.mkdir(cat_name)
                #print njets, region
                unc_conf_lines, unc_vals_lines = plotter.write_shapes( 
                    signal_region % (njets,region), 'h_collmass_pfmet', output_dir, rebin=rebin,
                    br_strenght=1)
                logging.warning('shape file %s created' % tfile.GetName()) 
                tfile.Close()
        
