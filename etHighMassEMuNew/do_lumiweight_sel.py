import array
import os
from sys import argv, stdout, stderr
import ROOT
import sys
import copy
import argparse
ROOT.gROOT.SetStyle("Plain")
#ROOT.gROOT.SetBatch(True)
#ROOT.gStyle.SetOptStat(0)

parser = argparse.ArgumentParser(
    "Compute QCD from same sign shape and using a OS/SS SF ")
parser.add_argument(
    "--doSyst",
    action="store_true",
    help="if set , will calculate QCD histograms for all shape systematics")
parser.add_argument(
    "--aType",
    type=str,
    action="store",
    dest="analyzer_type",
    default="cut_based",
    help="type of analyzer: cut_based, BDT, neural_net")
parser.add_argument(
    "--region",
    type=str,
    action="store",
    dest="region",
    default="os",
    help="region of space: oppositesign-os,samesign-ss,anti-isolated os/ss etc")
parser.add_argument(
    "--aName",
    type=str,
    action="store",
    dest="analyzer_name",
    default="highmass",
    help="Which channel to run over? (et, mt, em, me)")
parser.add_argument(
    "--lumi",
    action="store",
    type=int,
    dest="Lumi",
    default=35862, #full 2016 dataset luminosity 
    help="luminosity in picobarns")
parser.add_argument(
    "--jobid",
    type=str,
    action="store",
    dest="jobid",
    default="LFV_Mar15_mc", #last production of 2016 ntuples
    help="Current condor jobid")
parser.add_argument(
    "--oDir",
    action="store",
    dest="outputdir",
    default="preprocessed_inputs",
    help="Provide the relative path to the target input file")
parser.add_argument(
    "--numCategories",
    type=int,
    action="store",
    dest="numCategories",
    default=3,
    help="category nameis in analyzer")
args = parser.parse_args()




lumidict2={}
lumidict={}
lumidict3={}

lumidict['data_obs']=args.Lumi

lumidict['Diboson']=1.0
lumidict['WG']=1.0
lumidict['W']=1.0
lumidict['T']=1.0/0.886
lumidict['TT']=1.0/0.886
lumidict['TT_DD']=1.0
lumidict['WJETSMC']=1.0
lumidict['DY']=1.0
lumidict['Zothers']=1.0
lumidict['ZTauTau']=1.0
lumidict['SMH']=1.0
#lumidict['ggH_htt']=1.0
#lumidict['qqH_htt']=1.0
#lumidict['ggH_hww']=1.0
#lumidict['qqH_hww']=1.0
lumidict['LFV200']=1.0
lumidict['LFV300']=1.0
lumidict['LFV450']=1.0
lumidict['LFV600']=1.0
lumidict['LFV750']=1.0
lumidict['LFV900']=1.0



lumidict['QCD_mc']=1.0


lumidict['QCD']=args.Lumi


lumidict2['data_obs']=args.Lumi
lumidict2['Diboson']=1.49334492783e-05
lumidict2['TT']=1.08709111195e-05
lumidict2['TT_DD']=1.08709111195e-05
lumidict2['WJETSMC']=3e-04
lumidict2['DY']=2.1e-05
lumidict2['Zothers']=2.1e-05
lumidict2['ZTauTau']=2.1e-05
lumidict2['SMH']=2.07e-06
#lumidict2['ggH_htt']=2.07e-06
#lumidict2['qqH_htt']=4.2e-08
#lumidict2['ggH_hww']=2.07e-06
#lumidict2['qqH_hww']=4.2e-08
lumidict2['LFV200']=1.694e-06
lumidict2['LFV300']=1.33345743863e-07 
lumidict2['LFV450']=4.65541809702e-08
lumidict2['LFV600']=2.04664734848e-08 
lumidict2['LFV750']=9.93800000005e-09
lumidict2['LFV900']=5.37000000001e-09 
lumidict2['QCD_mc']=0.013699241892

lumidict2['WG']=1.56725042226e-06
lumidict2['W']=1.56725042226e-06
lumidict2['T']=5.23465826064e-06
lumidict2['QCD']=float(1.0)/float(args.Lumi)

lumidict3['LFV200']=6.94444444444e-05/1e-05
lumidict3['LFV300']=3.65124744869e-06/2.11932656279e-06
lumidict3['LFV450']=6.43521348821e-06/2.07168013259e-06
lumidict3['LFV600']=5.99010434762e-06/2.08706396016e-06
lumidict3['LFV750']=6.1508180588e-06/2.08449717759e-06
lumidict3['LFV900']=4.89888697288e-06/2.08517523813e-06

if 'SimpleEMAnalyzer450' in args.analyzer_name:
   lumidict3['LFV200']=1.0
   lumidict3['LFV300']=1.0
   lumidict3['LFV450']=3.6615953571e-06/2.07168013259e-06
   lumidict3['LFV600']=4.6469265228e-06/2.08706396016e-06
   lumidict3['LFV750']=5.33617929562e-06/2.08449717759e-06
   lumidict3['LFV900']=4.89888697288e-06/2.08517523813e-06

col_vis_mass_binning=array.array('d',(range(0,190,20)+range(200,480,30)+range(500,990,50)+range(1000,1520,100)))
#met_vars_binning=array.array('d',(range(0,190,20)+range(200,580,40)+range(600,1010,100)))
#pt_vars_binning=array.array('d',(range(0,190,20)+range(200,500,40)))



variable_list=[
   ('BDT_value', 'BDT_value', 1),
   ('h_collmass_pfmet', 'M_{coll}(e#mu) (GeV)', col_vis_mass_binning),
   ('h_vismass', 'M_{vis} (GeV)', col_vis_mass_binning),
   ]


if args.numCategories==3:
   category_names=["etaumu_0jet_selected","etaumu_1jet_selected","etaum_2jet_selected"]
elif args.numCategories==2:
   category_names=["etaumu_01jet_selected","etaumu_rest_selected"]
else:
   print "number of categories must be 1 or 2"
   exit


if not os.path.exists(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selection"):
   os.makedirs(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selection")
if not os.path.exists(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selection/"+args.region):
   os.makedirs(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selection/"+args.region)


for var in variable_list:
   histos={}
   for i_cat in range(len(category_names)):
      histos[category_names[i_cat]]=[]
      for filename in os.listdir("Simple"+args.analyzer_name+str(args.Lumi)):
         if "FAKES" in filename or "ETau" in filename or "QCD_with_shapes" in filename:continue
         if args.region=='ss' and 'QCD' in filename:continue
         file=ROOT.TFile("Simple"+args.analyzer_name+str(args.Lumi)+'/'+filename)
         new_title=filename.split('.')[0]
         hist_path=args.region+"/"+str(i_cat)+"/selected/nosys/"+var[0]
         histo=file.Get(hist_path)
        # print histo.GetNbinsX()

         binning=var[2]

         if not histo:
            continue
         if new_title!='QCD':
            try:
               histo.Rebin(binning*2)
            except TypeError:
               histo=histo.Rebin(len(binning)-1,"",binning)
            except:
               print "Please fix your binning"


         if 'data' not in filename and 'QCD'!=filename and 'TT_DD' not in filename:
            histo.Scale(lumidict['data_obs']/lumidict[new_title])      
         if 'data' in filename:
            histo.SetBinErrorOption(ROOT.TH1.kPoisson)

         if 'LFV' in filename:
            histo.Scale(lumidict3[new_title])

         lowBound=0
         highBound=histo.GetNbinsX()
         for bin in range(1,highBound):
            if histo.GetBinContent(bin) != 0:
#            print histo.GetBinContent(bin),bin
               lowBound = bin
               break
         for bin in range(histo.GetNbinsX(),lowBound,-1):
            if histo.GetBinContent(bin) != 0:
               highBound = bin
               break
         for j in range(lowBound, highBound+1):
            if lowBound==0:continue
            if (histo.GetBinContent(j)<=0) and "data" not in filename and "LFV" not in filename:
            #if (histo.GetBinContent(j)<=0) and "data" not in filename:
               histo.SetBinContent(j,0.001*float((lumidict['data_obs'])*float(lumidict2[new_title])))
               histo.SetBinError(j,1.8*float((lumidict['data_obs'])*float(lumidict2[new_title])))
             #            print "found neg bin  ",j

         histo.SetTitle(new_title)
         histo.SetName(new_title)
         new_histo=copy.copy(histo)
         histos[category_names[i_cat]].append(new_histo)


   if not histo:
      print "couldn't find histo for ",var[0]
      continue

   
   outputfile=ROOT.TFile(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selection/"+args.region+"/"+var[0]+".root","recreate")

#   print outputfile
   outputfile.cd()
   for key in histos.keys():
      dir0 = outputfile.mkdir(key);
  # print dir
      dir0.cd();
         #   print key
      for histo in histos[key]:
 #     if "_" not in histo.GetName():
  #       print histo.GetName()
   #      print histo.GetBinContent(15)
    #     print histo.GetBinError(15)
         histo.Write()
   outputfile.Close()


