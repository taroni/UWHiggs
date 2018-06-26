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
lumidict['LFV200']=590318.772137
lumidict['LFV300']=7160060.69803
lumidict['LFV450']=20986956.5217
lumidict['LFV600']=47866333.6663
lumidict['LFV750']=96544978.869
lumidict['LFV900']=178613035.382
#lumidict['LFV200']=1.0
#lumidict['LFV300']=1.0
#lumidict['LFV450']=1.0
#lumidict['LFV600']=1.0
#lumidict['LFV750']=1.0
#lumidict['LFV900']=1.0
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


col_vis_mass_binning=array.array('d',(range(0,190,20)+range(200,480,30)+range(500,990,50)+range(1000,1520,100)))
#met_vars_binning=array.array('d',(range(0,190,20)+range(200,580,40)+range(600,1010,100)))
#pt_vars_binning=array.array('d',(range(0,190,20)+range(200,500,40)))

dirDict={
   'nosys'         : '',
   #'uup'           : 'PU_UncertaintyUp',
   #'udown'         : 'PU_UncertaintyDown',
   'chargeduesdown': 'uesChargedDown',
   'chargeduesup'  : 'uesChargedUp',
   'ecaluesdown'   : 'uesEcalDown', 
   'ecaluesup'     : 'uesEcalUp',
   'hcaluesdown'   : 'uesHcalDown',
   'hcaluesup'     : 'uesHcalUp', 
   'hfuesdown'     : 'uesHFDown', 
   'hfuesup'       : 'uesHFUp', 
   'mesup'         : 'MESUp', 
   'mesdown'       : 'MESDown', 
   'eesup'         : 'EESUp',
   'eesdown'       : 'EESDown',
   'eresrhoup'     : 'EESRhoUp', 
   'eresrhodown'   : 'EESRhoDown', 
   #'eresphidown'  ; : 'EESPhiDown',
   'puup'          : 'PU_UncertaintyUp',
   'pudown'        : 'PU_UncertaintyDown',
   'jes_JetAbsoluteFlavMapDown': 'jesAbsoluteFlavMapDown', 
   'jes_JetAbsoluteMPFBiasDown': 'jesAbsoluteMPFBiasDown',
   'jes_JetAbsoluteScaleDown'  : 'jesAbsoluteScaleDown', 
   'jes_JetAbsoluteStatDown'   : 'jesAbsoluteStatDown',
   'jes_JetFlavorQCDDown'      : 'jesFlavorQCDDown',
   'jes_JetFragmentationDown'  :'jesFragmentationDown',
   'jes_JetPileUpDataMCDown'   :'jesPileUpDataMCDown',
   'jes_JetPileUpPtBBDown' :	'jesPileUpPtBBDown',
   'jes_JetPileUpPtEC1Down' :	'jesPileUpPtEC1Down',
   'jes_JetPileUpPtEC2Down' :	'jesPileUpPtEC2Down',
   'jes_JetPileUpPtHFDown' :	'jesPileUpPtHFDown',
   'jes_JetPileUpPtRefDown' :	'jesPileUpPtRefDown',
   'jes_JetRelativeBalDown' :	'jesRelativeBalDown',
   'jes_JetRelativeFSRDown' :	'jesRelativeFSRDown',
   'jes_JetRelativeJEREC1Down' :'jesRelativeJEREC1Down',
   'jes_JetRelativeJEREC2Down' :'jesRelativeJEREC2Down',
   'jes_JetRelativeJERHFDown' :	'jesRelativeJERHFDown',
   'jes_JetRelativePtBBDown' :	'jesRelativePtBBDown',
   'jes_JetRelativePtEC1Down' :	'jesRelativePtEC1Down',
   'jes_JetRelativePtEC2Down' :	'jesRelativePtEC2Down',
   'jes_JetRelativePtHFDown' :	'jesRelativePtHFDown',
   'jes_JetRelativeStatECDown' :'jesRelativeStatECDown',
   'jes_JetRelativeStatFSRDown':'jesRelativeStatFSRDown',
   'jes_JetRelativeStatHFDown' :'jesRelativeStatHFDown',
   'jes_JetSinglePionECALDown' :'jesSinglePionECALDown',
   'jes_JetSinglePionHCALDown' :'jesSinglePionHCALDown',
   'jes_JetTimePtEtaDown' :	'jesTimePtEtaDown',
   'jes_JetAbsoluteFlavMapUp' :	'jesAbsoluteFlavMapUp',
   'jes_JetAbsoluteMPFBiasUp' :	'jesAbsoluteMPFBiasUp',
   'jes_JetAbsoluteScaleUp' :	'jesAbsoluteScaleUp',
   'jes_JetAbsoluteStatUp' :	'jesAbsoluteStatUp',
   'jes_JetFlavorQCDUp'     :	'jesFlavorQCDUp',
   'jes_JetFragmentationUp' :	'jesFragmentationUp',
   'jes_JetPileUpDataMCUp' :	'jesPileUpDataMCUp',
   'jes_JetPileUpPtBBUp'  :	'jesPileUpPtBBUp',
   'jes_JetPileUpPtEC1Up' :	'jesPileUpPtEC1Up',
   'jes_JetPileUpPtEC2Up' :	'jesPileUpPtEC2Up',
   'jes_JetPileUpPtHFUp'  :	'jesPileUpPtHFUp',
   'jes_JetPileUpPtRefUp' :	'jesPileUpPtRefUp',
   'jes_JetRelativeBalUp' :	'jesRelativeBalUp',
   'jes_JetRelativeFSRUp' :	'jesRelativeFSRUp',
   'jes_JetRelativeJEREC1Up' :	'jesRelativeJEREC1Up',
   'jes_JetRelativeJEREC2Up' :	'jesRelativeJEREC2Up',
   'jes_JetRelativeJERHFUp' :	'jesRelativeJERHFUp',
   'jes_JetRelativePtBBUp' :	'jesRelativePtBBUp',
   'jes_JetRelativePtEC1Up' :	'jesRelativePtEC1Up',
   'jes_JetRelativePtEC2Up' :	'jesRelativePtEC2Up',
   'jes_JetRelativePtHFUp' :	'jesRelativePtHFUp',
   'jes_JetRelativeStatECUp' :	'jesRelativeStatECUp',
   'jes_JetRelativeStatFSRUp' :	'jesRelativeStatFSRUp',
   'jes_JetRelativeStatHFUp' :	'jesRelativeStatHFUp',
   'jes_JetSinglePionECALUp' :	'jesSinglePionECALUp',
   'jes_JetSinglePionHCALUp' :	'jesSinglePionHCALUp',
   'jes_JetTimePtEtaUp'   :	'jesTimePtEtaUp'

   }

filenameDict={
   'data_obs': 'data_obs',
   'Diboson': 'EWKDiboson',
   'TT' : 'ttbar', 
   'WJETSMC':  'WJets',
   'DY' : 'DY', 
   'Zothers' : 'DY', 
   'ZTauTau' : 'DYTT', 
   'ggH_htt': 'SMH', 
   'qqH_htt': 'SMH', 
   'ggH_hww': 'SMH',
   'qqH_hww': 'SMH', 
   'LFV200' : 'LFV200', 
   'LFV300' : 'LFV300', 
   'LFV450' : 'LFV450', 
   'LFV600' : 'LFV600',  
   'LFV750' : 'LFV750',
   'LFV900' : 'LFV900',  
   'QCD_mc' : 'QCDmc',
   'WG' : 'WG',
   'W' : 'W', 
   'T' : 'singlet', 
   'QCD': 'QCD'
   }

var=('h_collmass_pfmet', 'M_{coll}(e#mu) (GeV)', col_vis_mass_binning)


if args.numCategories==3:
   category_names=["etaumu_0jet_selected","etaumu_1jet_selected"]#,"etaum_2jet_selected"]
elif args.numCategories==2:
   category_names=["etaumu_01jet_selected","etaumu_rest_selected"]
else:
   print "number of categories must be 1 or 2"
   exit

   

if not os.path.exists(args.outputdir+"/"+args.analyzer_name+str(args.Lumi)+"/selection"):
   os.makedirs(args.outputdir+"/"+args.analyzer_name+str(args.Lumi)+"/selection")
if not os.path.exists(args.outputdir+"/"+args.analyzer_name+str(args.Lumi)+"/selection/"+args.region):
   os.makedirs(args.outputdir+"/"+args.analyzer_name+str(args.Lumi)+"/selection/"+args.region)

outputfile=ROOT.TFile(args.outputdir+"/"+args.analyzer_name+str(args.Lumi)+"/selection/"+args.region+"/shapes.root","recreate")
print 'outputfile', args.outputdir+"/"+args.analyzer_name+str(args.Lumi)+"/selection/"+args.region+"/shapes.root"
histos={}
for i_cat in range(len(category_names)):
   histos[category_names[i_cat]]=[]
   for filename in os.listdir(args.analyzer_name+str(args.Lumi)):
      if "FAKES" in filename or "MuTau" in filename or "QCD_with_shapes" in filename:continue
      if args.region=='ss' and 'QCD' in filename:continue
      file=ROOT.TFile(args.analyzer_name+str(args.Lumi)+'/'+filename)
      #print 'filename', file.GetName()
      for key in dirDict:
         new_title=filenameDict[filename.split('.')[0]]
         if key!='nosys': new_title=new_title+"_"+dirDict[key]
         lumititle=filename.split('.')[0]
         hist_path=args.region+"/"+str(i_cat)+"/selected/"+key+"/"+var[0]
         #print hist_path
         histo=file.Get(hist_path)
      
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
            histo.Scale(lumidict['data_obs']/lumidict[lumititle])      
         if 'data' in filename:
            histo.SetBinErrorOption(ROOT.TH1.kPoisson)

         lowBound=0
         highBound=histo.GetNbinsX()
         for bin in range(1,highBound):
            if histo.GetBinContent(bin) != 0:
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
               histo.SetBinContent(j,0.001*float((lumidict['data_obs'])*float(lumidict2[lumititle])))
               histo.SetBinError(j,1.8*float((lumidict['data_obs'])*float(lumidict2[lumititle])))
            
            
         histo.SetTitle(new_title)
         histo.SetName(new_title)
         new_histo=copy.copy(histo)
         histos[category_names[i_cat]].append(new_histo)

         
         if not histo:
            print "couldn't find histo for ",var[0]
            continue

   



outputfile.cd()
for key in histos.keys():
   if '0jet' in key: 
      dir0 = outputfile.mkdir('0jet');
   elif '1jet' in key:
      dir0 = outputfile.mkdir('1jet')
   dir0.cd();
   for histo in histos[key]:
      #print histo.GetName()
      histo.Write()
outputfile.Close()


