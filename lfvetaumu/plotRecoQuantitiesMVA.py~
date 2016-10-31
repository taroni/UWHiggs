#from mauro plotters

#Set logging before anything to override rootpy very verbose defaults
import sys
import logging
logging.basicConfig(stream=sys.stderr, level=logging.INFO)

import os
import ROOT
from pdb import set_trace
from FinalStateAnalysis.PlotTools.MegaBase import make_dirs
from FinalStateAnalysis.MetaData.data_styles import data_styles
from FinalStateAnalysis.PlotTools.BlindView import BlindView,  blind_in_range
from FinalStateAnalysis.PlotTools.SubtractionView      import SubtractionView, PositiveView
import itertools
import glob
import sys
from BasePlotter import BasePlotter
from argparse import ArgumentParser

parser = ArgumentParser(description=__doc__)
parser.add_argument('--no-plots', dest='no_plots', action='store_true',
                    default=False, help='Does not print plots')
parser.add_argument('--no-shapes', dest='no_shapes', action='store_true',
                    default=False, help='Does not create shapes for limit computation')
args = parser.parse_args()

#jobid='MiniAODSIMv2-Spring15-25ns_LFV_October13'
jobid = os.environ['jobid']

#jobid = 'MCntuples_3March' 
channel = 'em'
import rootpy.plotting.views as views
        
ROOT.gROOT.SetStyle("Plain")
ROOT.gROOT.SetBatch(True)
ROOT.gStyle.SetOptStat(0)

print "\nPlotting %s for %s\n" % (channel, jobid)

#check if blind
blind   = 'blind' not in os.environ or os.environ['blind'] == 'YES'
print 'blind?', blind
blind_region=[100, 150] if blind else None
#blind_region=[100, 200] if blind else None

embedded = False
files=    glob.glob('results/%s/LFVHETauMuAnalyzer/*.root' % (jobid))
outputdir = 'plots/%s/lfvetaumu/' % (jobid)
plotter = BasePlotter(files, outputdir, blind_region, use_embedded=embedded)

print "break 1"
if not args.no_plots:
   signs = ['os']
   jets = ['0',
      '1',
      '2'
   ]
   processtype = ['gg']
   threshold = ['ept30']
   
   histo_info = [
      ('h_collmass_pfmet', 'M_{coll}(e#mu) (GeV)', 1),##,
      ('mPt', 'p_{T}(#mu) (GeV)', 1), 
      ('mEta', '#eta(#mu)', 1),  
      ('mPhi', '#phi(#mu)', 1), 
      ('ePt', 'p_{T}(e) (GeV)', 1), 
      ('eEta', '#eta(e)', 1),  
      ('ePhi', '#phi(e)', 1), 
      ('em_DeltaPhi', 'e#mu #Delta#phi', 1), 
      ('em_DeltaR', 'e#mu #Delta R', 1),
      ('h_vismass', 'M_{vis} (GeV)', 1),
      ('jetN_30', 'number of jets (p_{T} > 30 GeV)', 1)  
   #   ('type1_pfMetEt', 'pfMet', 1)      
   ]
   
   logging.debug("Starting plotting")
   for sign,  njet in itertools.product(signs,  jets):
      path = os.path.join(sign,'gg/ept30',njet)
      print path
#      plotter.set_subdir(os.path.join('embedded',path)) if embedded else plotter.set_subdir(path)
      if not os.path.exists(outputdir+path):
         os.makedirs(outputdir+path)
         os.makedirs(outputdir+path+'/selected')

      for var, xlabel, rebin in histo_info:
         logging.debug("Plotting %s/%s" % (path, var) )
         plotter.pad.SetLogy(False)
         ## if int(njet)==2: 
         ##   if 'collmass' in var or 'Mass' in var: 
         ##      rebin=rebin
         ##   elif not 'Eta' in var and not 'jet' in var: 
         ##       rebin = rebin*2
         plotter.plot_mc_vs_data_witherrors(path, var, rebin, xlabel,
                                      leftside=False, xrange=(0.,300.), show_ratio=True, ratio_range=1., 
                                      sort=True)
        
            
         plotter.save(path+"/"+var,dotroot=True)
         
     # plotter.set_subdir(os.path.join('embedded', path+'/selected'))if embedded else plotter.set_subdir(path+'/selected')

      for var, xlabel, rebin in histo_info:
         ##if int(njet)==1: 
         ##   if not 'Eta' in var and not 'jet' in var: rebin = rebin
         ##if int(njet) ==2: 
         ##   if 'collmass' in var or 'Mass' in var: rebin=rebin
         ##   if 'Pt' in var or 'Mt' in var or 'pfMet' in var : rebin=rebin*4         
             
         logging.debug("Plotting %s/%s" % (path, var) )
         plotter.pad.SetLogy(False)
         plotter.plot_mc_vs_data_witherrors(path+'/selected', var, rebin, xlabel,
                                      leftside=False, xrange=(0.,300.), show_ratio=True, ratio_range=1., 
                                      sort=True)
      
         plotter.save(path+"/selected/"+var,dotroot=True)


print "break 2"

#make shapes for limit setting
if not args.no_shapes:
   signal_region = 'os/%s/selected'
   ##signal_region = 'os/gg/ept30/%s'
   jets_names = [
           ('0', 'gg0emu'  , 1),
           ('1', 'boostemu', 1),#was 2
           ('2', 'vbfemu'  , 1),#was 5
   ]
   pjoin = os.path.join
   for njets, cat_name, rebin in jets_names:
      output_path = plotter.base_out_dir
      tfile = ROOT.TFile(pjoin(output_path, 'shapes.%s.root' % njets), 'recreate')
      output_dir = tfile.mkdir(cat_name)
      unc_conf_lines, unc_vals_lines = plotter.write_shapes( 
         signal_region % njets, 'h_collmass_pfmet', output_dir, rebin=rebin,
         br_strenght=1, last=300)
      logging.warning('shape file %s created' % tfile.GetName()) 
      tfile.Close()
      with open(pjoin(output_path, 'unc.%s.conf' % njets), 'w') as conf:
         conf.write('\n'.join(unc_conf_lines))
      with open(pjoin(output_path, 'unc.%s.vals' % njets), 'w') as vals:
         vals.write('\n'.join(unc_vals_lines))

   with open(pjoin(output_path,'.shapes_timestamp'),'w') as stamp:
      stamp.write('no use')

