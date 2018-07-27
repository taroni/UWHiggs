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
lumidict2['LFV200']=0.000001694
lumidict2['LFV300']=0.00000013966362
lumidict2['LFV450']=0.000000047648643
lumidict2['LFV600']=0.00000002089151
lumidict2['LFV750']=1./96544978.869
lumidict2['LFV900']=1./178613035.382#0.000000005598696 
lumidict2['QCD_mc']=0.013699241892
lumidict2['WG']=1.56725042226e-06
lumidict2['W']=1.56725042226e-06
lumidict2['T']=5.23465826064e-06
lumidict2['QCD']=float(1.0)/float(args.Lumi)



lumidict3['LFV200']=1.
lumidict3['LFV300']=1.
lumidict3['LFV450']=1.
lumidict3['LFV600']=1.
lumidict3['LFV750']=1.
lumidict3['LFV900']=1.

if 'SimpleEMAnalyzer450' in args.analyzer_name:
   lumidict3['LFV200']=1.
   lumidict3['LFV300']=1.
   lumidict3['LFV450']=1.
   lumidict3['LFV600']=1.
   lumidict3['LFV750']=1.
   lumidict3['LFV900']=1.

syst_names_analyzer=['nosys','mesup','mesdown','eesup','eesdown','eresrhoup','eresrhodown','nosys','eresphidown','puup','pudown',
                'chargeduesdown','chargeduesup','ecaluesdown','ecaluesup','hcaluesdown','hcaluesup','hfuesdown','hfuesup',
                'jes_JetAbsoluteFlavMapDown',
                'jes_JetAbsoluteMPFBiasDown',
                'jes_JetAbsoluteScaleDown',
                'jes_JetAbsoluteStatDown',
                'jes_JetFlavorQCDDown',
                'jes_JetFragmentationDown',
                'jes_JetPileUpDataMCDown',
                'jes_JetPileUpPtBBDown',
                'jes_JetPileUpPtEC1Down',
                'jes_JetPileUpPtEC2Down',
                'jes_JetPileUpPtHFDown',
                'jes_JetPileUpPtRefDown',
                'jes_JetRelativeBalDown',
                'jes_JetRelativeFSRDown',
                'jes_JetRelativeJEREC1Down',
                'jes_JetRelativeJEREC2Down',
                'jes_JetRelativeJERHFDown',
                'jes_JetRelativePtBBDown',
                'jes_JetRelativePtEC1Down',
                'jes_JetRelativePtEC2Down',
                'jes_JetRelativePtHFDown',
                'jes_JetRelativeStatECDown',
                'jes_JetRelativeStatFSRDown',
                'jes_JetRelativeStatHFDown',
                'jes_JetSinglePionECALDown',
                'jes_JetSinglePionHCALDown',
                'jes_JetTimePtEtaDown',
                'jes_JetAbsoluteFlavMapUp',
                'jes_JetAbsoluteMPFBiasUp',
                'jes_JetAbsoluteScaleUp',
                'jes_JetAbsoluteStatUp',
                'jes_JetFlavorQCDUp',
                'jes_JetFragmentationUp',
                'jes_JetPileUpDataMCUp',
                'jes_JetPileUpPtBBUp',
                'jes_JetPileUpPtEC1Up',
                'jes_JetPileUpPtEC2Up',
                'jes_JetPileUpPtHFUp',
                'jes_JetPileUpPtRefUp',
                'jes_JetRelativeBalUp',
                'jes_JetRelativeFSRUp',
                'jes_JetRelativeJEREC1Up',
                'jes_JetRelativeJEREC2Up',
                'jes_JetRelativeJERHFUp',
                'jes_JetRelativePtBBUp',
                'jes_JetRelativePtEC1Up',
                'jes_JetRelativePtEC2Up',
                'jes_JetRelativePtHFUp',
                'jes_JetRelativeStatECUp',
                'jes_JetRelativeStatFSRUp',
                'jes_JetRelativeStatHFUp',
                'jes_JetSinglePionECALUp',
                'jes_JetSinglePionHCALUp',
                'jes_JetTimePtEtaUp']      #sysfolder names in analyzer



syst_names_datacard=['',
                     'MESUp',
                     'MESDown',
                     'EESUp',
                     'EESDown',
                     'EESRhoUp',
                     'EESRhoDown',
                     'EESPhiUp',
                     'EESPhiDown',
                     'PU_UncertaintyUp',
                     'PU_UncertaintyDown',
                     'uesChargedDown',
                     'uesChargedUp',
                     'uesEcalDown',
                     'uesEcalUp',
                     'uesHcalDown',
                     'uesHcalUp',
                     'uesHFDown',
                     'uesHFUp',
             'jesAbsoluteFlavMapDown',
             'jesAbsoluteMPFBiasDown',
             'jesAbsoluteScaleDown',
             'jesAbsoluteStatDown',
             'jesFlavorQCDDown',
             'jesFragmentationDown',
             'jesPileUpDataMCDown',
             'jesPileUpPtBBDown',
             'jesPileUpPtEC1Down',
             'jesPileUpPtEC2Down',
             'jesPileUpPtHFDown',
             'jesPileUpPtRefDown',
             'jesRelativeBalDown',
             'jesRelativeFSRDown',
             'jesRelativeJEREC1Down',
             'jesRelativeJEREC2Down',
             'jesRelativeJERHFDown',
             'jesRelativePtBBDown',
             'jesRelativePtEC1Down',
             'jesRelativePtEC2Down',
             'jesRelativePtHFDown',
             'jesRelativeStatECDown',
             'jesRelativeStatFSRDown',
             'jesRelativeStatHFDown',
             'jesSinglePionECALDown',
             'jesSinglePionHCALDown',
             'jesTimePtEtaDown',
             'jesAbsoluteFlavMapUp',
             'jesAbsoluteMPFBiasUp',
             'jesAbsoluteScaleUp',
             'jesAbsoluteStatUp',
             'jesFlavorQCDUp',
             'jesFragmentationUp',
             'jesPileUpDataMCUp',
             'jesPileUpPtBBUp',
             'jesPileUpPtEC1Up',
             'jesPileUpPtEC2Up',
             'jesPileUpPtHFUp',
             'jesPileUpPtRefUp',
             'jesRelativeBalUp',
             'jesRelativeFSRUp',
             'jesRelativeJEREC1Up',
             'jesRelativeJEREC2Up',
             'jesRelativeJERHFUp',
             'jesRelativePtBBUp',
             'jesRelativePtEC1Up',
             'jesRelativePtEC2Up',
             'jesRelativePtHFUp',
             'jesRelativeStatECUp',
             'jesRelativeStatFSRUp',
             'jesRelativeStatHFUp',
             'jesSinglePionECALUp',
             'jesSinglePionHCALUp',
             'jesTimePtEtaUp']      #sysfolder names in analyzer

print len(syst_names_datacard)
print len(syst_names_analyzer)

col_vis_mass_binning=array.array('d', (range(0, 1000, 50)+range(1000,1500,100)))
#col_vis_mass_binning=array.array('d',(range(0,180,30)+range(180,980,50)+range(980,1580,100)))
#met_vars_binning=array.array('d',(range(0,190,20)+range(200,580,40)+range(600,1010,100)))
#pt_vars_binning=array.array('d',(range(0,190,20)+range(200,500,40)))

filenameDict={
   'data_obs': 'data_obs',
   'Diboson': 'EWKDiboson',
   'TT' : 'ttbar', 
   'WJETSMC':  'WJets',
   'DY' : 'DY', 
   'Zothers' : 'DY', 
   'ZTauTau' : 'DYTT',
   'SMH' : 'SMH',
#   'ggH_htt': 'SMH', 
#   'qqH_htt': 'SMH', 
#   'ggH_hww': 'SMH',
#   'qqH_hww': 'SMH', 
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


variable_list=[
#   ('BDT_value', 'BDT_value', 1),
   ('h_collmass_pfmet', 'M_{coll}(e#mu) (GeV)', col_vis_mass_binning),
   ('h_vismass', 'M_{vis} (GeV)', col_vis_mass_binning),
   ]

catDict={
   'mutaue_0jet_selected' : '0jet',
   "mutaue_1jet_selected" : '1jet'
   }

if args.numCategories==3:
   category_names=["mutaue_0jet_selected","mutaue_1jet_selected"]#,"mutaue_2jet_selected"]
elif args.numCategories==2:
   category_names=["mutaue_01jet_selected","mutaue_rest_selected"]
else:
   print "number of categories must be 1 or 2"
   exit


if not os.path.exists(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selected_with_shapes"):
   os.makedirs(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selected_with_shapes")

for var in variable_list:
   histos={}
   for i_cat in range(len(category_names)):
      histos[category_names[i_cat]]=[]
      for filename in os.listdir('Simple'+args.analyzer_name+str(args.Lumi)):

         file=ROOT.TFile('Simple'+args.analyzer_name+str(args.Lumi)+'/'+filename)
         title=filename.split('.')[0].replace("_with_shapes","")
         for k in range(len(syst_names_analyzer)):
            if syst_names_analyzer[k]!='' and ( "FAKES" in filename or "ETau" in filename or filename=='QCD.root'):continue
            hist_path="os/"+str(i_cat)+"/selected/"+syst_names_analyzer[k]+"/"+var[0]
            histo=file.Get(hist_path)

      # print histo.GetNbinsX()

            binning=var[2]
            if 'data_obs' in filename and syst_names_analyzer[k]!='nosys' : continue
            if 'data_obs' in filename and syst_names_datacard[k]!='': continue
            print "using histo: ", title+" "+syst_names_analyzer[k], "in ", filename
            if not histo:
               print "Couldn't find histo: ", title+" "+syst_names_analyzer[k], "in ", filename
               continue

            #if 'QCD'!=title:
            try:
               histo.Rebin(binning*2)
            except TypeError:
               histo=histo.Rebin(len(binning)-1,"",binning)
            except:
               print "Please fix your binning"

            #print 'no rescale %s' %title , histo.Integral(), lumidict['data_obs']/lumidict[title]
            if 'data' not in filename and 'QCD' not in filename and 'TT_DD' not in filename and "_with_shapes" not in filename:
               histo.Scale(lumidict['data_obs']/lumidict[title])
               #if title=='SMH': print 'SMH', histo.Integral()
            if 'data' in filename:
               histo.SetBinErrorOption(ROOT.TH1.kPoisson)
 
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
                  #if (histo.GetBinContent(j)<=0) and "data" not in filename :
                  histo.SetBinContent(j,0.00001*float((lumidict['data_obs'])*float(lumidict2[title])))
                  histo.SetBinError(j,1.8*float((lumidict['data_obs'])*float(lumidict2[title])))
                  #            print "found neg bin  ",j
            new_title = filenameDict[title]
            if 'LFV' in filename:
               histo.Scale(lumidict3[new_title])

            if syst_names_datacard[k]!='':
               new_title=new_title+"_"+syst_names_datacard[k]
            else:
               new_title=new_title
            histo.SetTitle(new_title)
            histo.SetName(new_title)
            new_histo=copy.copy(histo)
            histos[category_names[i_cat]].append(new_histo)


      if not histo:
         print "couldn't find histo for ",var[0]
         continue

   print var[0]
   outputfile=ROOT.TFile(args.outputdir+"/Simple"+args.analyzer_name+str(args.Lumi)+"/selected_with_shapes/"+var[0]+".root","RECREATE")

   print outputfile, outputfile.GetName()
   
   outputfile.cd()
   for key in histos.keys():
      dir0 = outputfile.mkdir(catDict[key]);
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

