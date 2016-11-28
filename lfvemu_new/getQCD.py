import os 
from sys import argv, stdout, stderr
import ROOT
import sys
import math
import copy
ROOT.gROOT.SetStyle("Plain")
cat_now=['0','1','21','22']   #category names in analyzer                                                                                    
                                                                                                                                              
syst_names_now=['jetup','jetdown','tup','tdown','uup','udown']      #sysfolder names in analyzer                                             
vars = [
      ('h_collmass_pfmet', 'M_{coll}(e#mu) (GeV)', 1),
      ('mPt', 'p_{T}(mu) (GeV)', 4),
      ('mEta', 'eta(mu)', 2),
      ('mPhi', 'phi(mu)', 4),
      ('ePt', 'p_{T}(e) (GeV)', 4),
      ('eEta', 'eta(e)', 2),
      ('ePhi', 'phi(e)', 4),
      ('em_DeltaPhi', 'emu Deltaphi', 2),
      ('em_DeltaR', 'emu Delta R', 2),
      ('h_vismass', 'M_{vis} (GeV)', 1),
      ('ePFMET_Mt', 'MT-e-MET (GeV)', 5),
      ('mPFMET_Mt', 'MT-mu-MET (GeV)', 5),
      ('ePFMET_DeltaPhi', 'Deltaphi-e-MET (GeV)', 2),
      ('mPFMET_DeltaPhi', 'Deltaphi-mu-MET (GeV)', 2),
      ('jetN_30', 'number of jets (p_{T} > 30 GeV)', 1),
]

vars2 = [
      ('h_collmass_pfmet', 'M_{coll}(e#mu) (GeV)', 1),
]


class GetQCD(object):
	def __init__(self):
		self.histos={}
                self.histomc=None
	        self.histodata=None
	        self.histoQCD=None
	        for var in vars:
	        	for sign in ['ss','allfakes/ss']:
	        		for j in range(2):
	        			for i in range(len(cat_now)):
	        				x=0
	        				y=0
	        				if j==0:
	        					hist_path=sign+"/gg/"+cat_now[i]+"/"+var[0]
	        				else:
	        					hist_path= sign+"/gg/"+cat_now[i]+"/selected/nosys/"+var[0]
						self.histomc=None
						self.histodata=None
						self.histoQCD=None
	        				for filename in os.listdir("results/Oct30/LFVHEMuAnalyzerMVA_btag"):
							if "FAKES" in filename or "QCD" in filename: continue
	        					file=ROOT.TFile("results/Oct30/LFVHEMuAnalyzerMVA_btag/"+filename)
							histo=file.Get(hist_path)
#							print hist_path,"   ",filename,"   ",var[0],"  ",histo.Integral()
	        					if "data"  not in filename and "FAKES" not in filename and "LFV" not in filename and "QCD" not in filename:
								if x==0:
	        							self.histomc=histo.Clone()
									self.histomc.SetDirectory(0)
	        							x+=1
								else:
	        							self.histomc.Add(histo)
								
	        					elif "data" in filename and "data_SingleMuon_Run2016E" not in filename and "data_SingleMuon_Run2016F" not in filename:
  								if y==0:
	        							y+=1
	        							self.histodata=histo.Clone()
									self.histodata.SetDirectory(0)
	        						else:
	        							self.histodata.Add(histo)
						self.histomc.Scale(12900)				
#						print "data",self.histodata.Integral()
#						print "MC",self.histomc.Integral()
						self.histoQCD=self.histodata.Clone()
						self.histoQCD.Add(self.histomc,-1)
						self.histoQCD.Scale(2.30)
						for bin in range(1,self.histomc.GetNbinsX()+1):
							if self.histomc.GetBinContent(bin)<0.1:
								self.histoQCD.SetBinContent(bin,0)
						for bin in range(1,self.histoQCD.GetNbinsX()+1):
							if self.histoQCD.GetBinContent(bin)<0:
                                                                self.histoQCD.SetBinContent(bin,0.001)
								self.histoQCD.SetBinError(bin,1.8)
							binContent=self.histoQCD.GetBinContent(bin)
							binError=self.histoQCD.GetBinError(bin)
							self.histoQCD.SetBinError(bin,math.sqrt(binError*binError+0.3*binContent*0.3*binContent))
						
#						print "QCD",self.histoQCD.Integral()
						new_histo=copy.copy(self.histoQCD)
						jojo=hist_path.split('/')
						jojo1='/'.join(jojo[0:(len(jojo)-1)])
						jojo1=jojo1.replace('ss','os',1)
						self.histos[(jojo1,var[0])]=new_histo
	        for var in vars2:
	        	for sign in ['ss']:
				for i in range(len(cat_now)):
					for k in range(len(syst_names_now)):
						x=0
	        				y=0
						hist_path= sign+"/gg/"+cat_now[i]+"/selected/"+syst_names_now[k]+"/"+var[0]
						self.histomc=None
						self.histodata=None
						self.histoQCD=None
	        				for filename in os.listdir("results/Oct30/LFVHEMuAnalyzerMVA_btag"):
							if "FAKES" in filename or "QCD" in filename: continue
	        					file=ROOT.TFile("results/Oct30/LFVHEMuAnalyzerMVA_btag/"+filename)
							histo=file.Get(hist_path)
#							print hist_path,"   ",filename,"   ",var[0],"  ",histo.Integral()
	        					if "data"  not in filename and "FAKES" not in filename and "LFV" not in filename and "QCD" not in filename:
								if x==0:
	        							self.histomc=histo.Clone()
									self.histomc.SetDirectory(0)
	        							x+=1
								else:
	        							self.histomc.Add(histo)
								
	        					elif "data" in filename and "data_SingleMuon_Run2016E" not in filename and "data_SingleMuon_Run2016F" not in filename:
	        						if y==0:
	        							y+=1
	        							self.histodata=histo.Clone()
									self.histodata.SetDirectory(0)
	        						else:
	        							self.histodata.Add(histo)
						self.histomc.Scale(12900)				
#						print "data",self.histodata.Integral()
#						print "MC",self.histomc.Integral()
						self.histoQCD=self.histodata.Clone()
						self.histoQCD.Add(self.histomc,-1)
						self.histoQCD.Scale(2.30)
						for bin in range(1,self.histomc.GetNbinsX()+1):
                                                        if self.histomc.GetBinContent(bin)<0.1:
                                                                self.histoQCD.SetBinContent(bin,0)
						for bin in range(1,self.histoQCD.GetNbinsX()+1):
							if self.histoQCD.GetBinContent(bin)<0:
								self.histoQCD.SetBinContent(bin,0.001)
							#	self.histoQCD.SetBinError(bin,1.8)
							binContent=self.histoQCD.GetBinContent(bin)
							binError=self.histoQCD.GetBinError(bin)
							self.histoQCD.SetBinError(bin,math.sqrt(binError*binError+0.3*binContent*0.3*binContent))
#						print "QCD",self.histoQCD.Integral()
						new_histo=copy.copy(self.histoQCD)
						jojo=hist_path.split('/')
						jojo1='/'.join(jojo[0:(len(jojo)-1)])
						jojo1=jojo1.replace('ss','os',1)
						self.histos[(jojo1,var[0])]=new_histo
			    
		self.outputfile=ROOT.TFile("QCD.root","recreate")
		self.outputfile.cd()
		for key in self.histos.keys():

#			self.outputfile.cd()
			self.dir0 = self.outputfile.mkdir(key[0])
#			print self.dir0
			self.dir0.Cd("QCD.root:/"+key[0])
#    print dir0
#			print histos[key]
			self.histos[key].SetDirectory(self.dir0)
			self.histos[key].Write()
		self.outputfile.Close()




QCD=GetQCD()
