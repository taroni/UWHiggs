'''

Base class which makes nice plots.

Author: Evan K. Friis, UW

'''

import fnmatch
import re
import os
import math
import rootpy.plotting.views as views
from pdb import set_trace
from rootpy.plotting.hist import HistStack
import rootpy.plotting as plotting
from FinalStateAnalysis.MetaData.data_views import data_views
from FinalStateAnalysis.PlotTools.RebinView import RebinView
from FinalStateAnalysis.PlotTools.BlindView import BlindView,  blind_in_range
from FinalStateAnalysis.Utilities.struct import struct
import FinalStateAnalysis.Utilities.prettyjson as prettyjson
from FinalStateAnalysis.MetaData.data_styles import data_styles
from FinalStateAnalysis.PlotTools.Plotter  import Plotter
from FinalStateAnalysis.PlotTools.SubtractionView      import SubtractionView, PositiveView
from FinalStateAnalysis.PlotTools.MedianView     import MedianView
from FinalStateAnalysis.PlotTools.SystematicsView     import SystematicsView
from FinalStateAnalysis.StatTools.quad     import quad
import ROOT
import glob
from pdb import set_trace
from FinalStateAnalysis.PlotTools.THBin import zipBins
import datetime

DEBUG = False

def create_mapper(mapping):
    def _f(path):
        for key, out in mapping.iteritems():
            if key == path:
                path = path.replace(key,out)
                print 'path', path
        return path
    return _f

def remove_name_entry(dictionary):
    return dict( [ i for i in dictionary.iteritems() if i[0] != 'name'] )

def histo_diff_quad(mc_err, *systematics):
    nbins = mc_err.GetNbinsX()
    clone = mc_err.Clone()
    sys_up = [i for i, _ in systematics]
    sys_dw = [i for _, i in systematics]
    #bin loop
    for ibin in range(nbins+2): #from uflow to oflow
        content = clone.GetBinContent(ibin)
        error   = clone.GetBinError(ibin)

        shifts_up = [abs(i.GetBinContent(ibin) - content) for i in sys_up]
        shifts_dw = [abs(i.GetBinContent(ibin) - content) for i in sys_dw]
        max_shift = [max(i, j) for i, j in zip(shifts_up, shifts_dw)]
        #print shifts_up, shifts_dw, max_shift, error, content
        
        new_err = quad(error, *max_shift)
        #print clone.GetTitle(), ibin, new_err, clone.GetBinContent(ibin)
        clone.SetBinError(ibin, new_err)

    return clone

def mean(histo):
    '''compute histogram mean because root is not able to'''
    nbins = histo.GetNbinsX()
    wsum = sum( histo.GetBinCenter(i)*histo.GetBinContent(i) for i in xrange(1, nbins+1))
    entries = sum(histo.GetBinContent(i) for i in xrange(1, nbins+1))
    #print histo.GetTitle(), wsum, entries, nbins, histo.GetEntries(), histo.Integral()
    return float(wsum)/entries

def name_systematic(name):
    '''makes functor that makes a name systematic (with postfix)'''
    return lambda x: x+name

def dir_systematic(name):
    '''makes functor that makes a directory systematic'''
    return lambda x: os.path.join(name,x)

def parse_cgs_groups(file_path):
    if not os.path.isfile(file_path):
        raise NameError('%s is not a file!' % file_path)
    
    groups = {}
    regex = re.compile('$ GROUP (?P<groupname>\w+) (?P<includes>[a-zA-Z\_\, ]+)')
    with open(file_path) as infile:
        for line in infile:
            match = regex.match(line)
            if match:
                groups[match.group('groupname')] = [ i.strip() for i in match.group('includes').split(',') ]
    return groups

def remove_empty_bins(histogram, weight, first = 0, last = 0):
    ret  = histogram.Clone()
    last = last if last else ret.GetNbinsX() + 1
    for i in range(first, last+1):
        if ret.GetBinContent(i) <= 0:
            ret.SetBinContent(i, 0.9200*weight) #MEAN WEIGHT
            ret.SetBinError(i, 1.8*weight)
    return ret     
           
def change_histo_nbins(histogram, first = 0, last = 0):
    nbins = int((last - first)/histogram.GetBinWidth(2))
    if nbins == histogram.GetNbinsX(): 
        return histogram
    else:
        name = "" 
        title =""
        name = histogram.GetName() + 'xrange'
        title = histogram.GetTitle()
        newH = ROOT.TH1F(name, title, nbins , first, last)
        for i in range (1, nbins+1):
            newH.SetBinContent(i, histogram.GetBinContent(i))
            newH.SetBinError(i, histogram.GetBinError(i))
        return newH

def find_fill_range(histo):
    first, last = (0, 0)
    for i in range(histo.GetNbinsX() + 1):
        if histo.GetBinContent(i) > 0:
            if first:
                last = i
            else:
                first = i
    return first, last

class BasePlotter(Plotter):
    def __init__ (self, blind_region=None, forceLumi=-1, use_embedded=False): 
        cwd = os.getcwd()
        self.period = '8TeV'
        self.sqrts  = 8
        jobid = os.environ['jobid']
        self.use_embedded = use_embedded
        self.forceLumi=forceLumi
        print "\nPlotting e tau for %s\n" % jobid

        self.files     = glob.glob('results/%s/ETauAnalyzer/*.root' % jobid)
        self.lumifiles = glob.glob('inputs/%s/*.lumicalc.sum' % jobid)

        self.outputdir = 'plots/%s/ETauAnalyzer' % jobid
        if not os.path.exists(self.outputdir):
            os.makedirs(self.outputdir)
            
        samples = [os.path.basename(i).split('.')[0] for i in self.files]
        
        self.blind_region=blind_region
        blinder=None
        super(BasePlotter, self).__init__(self.files, self.lumifiles, self.outputdir, blinder, forceLumi=self.forceLumi)

        self.mc_samples = [
            'WWTo*', 'ZZ*','WZ*', 'GluGluHToTauTau_M125*', 'ttHJet*', 'ST_*', 'TT_*', 'VBFHToTauTau_M125*', 'WG*',   'WminusHToTauTau_M125*', 'WplusHToTauTau_M125*', 'ZHToTauTau_M125*', #'EWK*',
    #'WJetsToLNu*','W1JetsToLNu*','W2JetsToLNu*','W3JetsToLNu*','W4JetsToLNu*',
            'DYJetsToLL*','DY1JetsToLL*','DY2JetsToLL*','DY3JetsToLL*','DY4JetsToLL*', 'DY1JetsToLL_M-10to50*', 'DY2JetsToLL_M-10to50*', 'DYJetsToLL_M-10to50*','DYJetsToTT*','DY1JetsToTT*','DY2JetsToTT*','DY3JetsToTT*','DY4JetsToTT*'
        ]
        
        if use_embedded:            
            self.mc_samples.pop()
            embedded_view, weight = self.make_embedded('os/gg/ept30/h_collmass_pfmet')
            self.views['ZetauEmbedded'] = {
                'view' : embedded_view,
                'weight' : weight
                }
        self.views['fakes'] = {'view' : self.make_fakes('t')}
        self.datacard_names = {
           # '*HTo[WT][WT]'           : 'SMH126'   ,
            'SMH'                    : 'SMH',
            'TT'                     : 'ttbar'     ,
            'ST'                     : 'singlet'   ,
            'EWKDiboson'             : 'EWKDiboson'   ,
            'DY'                     : 'DY'   ,
            'DYTT'                   : 'DYTT'   ,
            'ZetauEmbedded'          : 'ztautau'   ,
            'GluGlu_LFV_HToETau_M200*': 'LFV200',
            'GluGlu_LFV_HToETau_M450*': 'LFV450',
            'GluGlu_LFV_HToETau_M600*': 'LFV600',
            'GluGlu_LFV_HToETau_M750*': 'LFV750',
            'GluGlu_LFV_HToETau_M900*': 'LFV900',
            'fakes'                  : 'fakes',

        }
        self.sample_groups = {#parse_cgs_groups('card_config/cgs.0.conf')
            'fullsimbkg' : ['SMH', 'ttbar', 'singlet', 'EWKDiboson', 'DYTT', 'DY', 'LFV200', 'LFV450', 'LFV600', 'LFV750', 'LFV900'],# 'WWVBF126', 'WWGG126','VHWW','VHtautau'], #wplusjets added in case of optimization study# 'wplusjets'],
            'simbkg' : ['SMH', 'ttbar', 'singlet', 'EWKDiboson', 'DYTT', 'DY', 'LFV200',  'LFV450', 'LFV600', 'LFV750', 'LFV900'],# 'WWVBF126', 'WWGG126','VHWW','VHtautau'],
            'realtau' : ['SMH', 'EWKDiboson', 'DYTT', 'LFV200', 'LFV450', 'LFV600', 'LFV750', 'LFV900'],#'diboson', 'ttbar', 'singlet', 'ztautau', 'SMGG126', 'SMVBF126','LFVGG', 'LFVVBF'],#, 'VHtautau'],
            'Zll' : ['DY']
        }
        self.systematics = {
            'PU_Uncertainty' : {
               'type' : 'shape',
               '+' : dir_systematic('puUp'),
               '-' : dir_systematic('puDown'),
               'apply_to' : ['fullsimbkg'],
            },
            'EES' : {
               'type' : 'shape',
               '+' : dir_systematic('eesUp'),
               '-' : dir_systematic('eesDown'),
               'apply_to' : ['fullsimbkg'],
            },
            ##'JES' : {
            ##    'type' : 'yield',
            ##    '+' : lambda x: os.path.join('jes_plus', x)+'_jes_plus' ,
            ##    '-' : lambda x: os.path.join('jes_minus', x)+'_jes_minus' ,
            ##    'apply_to' : ['fullsimbkg'],
            ##},
            'TES1p' : {
                'type' : 'shape',
                '+' : dir_systematic('scale_t_1prong_13TeVUp'),
                '-' : dir_systematic('scale_t_1prong_13TeVDown'),
                'apply_to' : ['realtau'],
            },
            'TES1p10' : {
                'type' : 'shape',
                '+' : dir_systematic('scale_t_1prong1pizero_13TeVUp'),
                '-' : dir_systematic('scale_t_1prong1pizero_13TeVDown'),
                'apply_to' : ['realtau'],
            },
            'TES3p' : {
                'type' : 'shape',
                '+' : dir_systematic('scale_t_3prong_13TeVUp'),
                '-' : dir_systematic('scale_t_3prong_13TeVDown'),
                'apply_to' : ['realtau'],
            },
            ##'UES' : { ## to comment in case of optimization study
            ##    'type' : 'yield',
            ##    '+' : name_systematic('_ues_plus'),
            ##    '-' : name_systematic('_ues_minus'),
            ##    'apply_to' : ['fullsimbkg'],
            ##},
            ##'shape_FAKES' : { ## to comment in case of optimization study
            ##    'type' : 'shape',
            ##    '+' : dir_systematic('Up'),
            ##    '-' : dir_systematic('Down'),
            ##    'apply_to' : ['fakes']#,'efakes','etfakes'],
            ##},
            ##'norm_etaufake' : { ## was shape etaufake
            ##    'type' : 'yield',
            ##    '+' : dir_systematic('etaufakep1s'),
            ##    '-' : dir_systematic('etaufakem1s'),
            ##    'apply_to' : ['Zee']#,'efakes','etfakes'],
            ##},
            ##'shape_ZeeMassShift' : { ## to comment in case of optimization study
            ##    'type' : 'shape',
            ##    '+' : name_systematic('_Zee_p1s'),
            ##    '-' : name_systematic('_Zee_m1s'),
            ##    'apply_to' : ['Zee']#,'efakes','etfakes'],
            ##},
            ####'stat' : {
            ####    'type' : 'stat',
            ####    '+' : lambda x: x,
            ####    '-' : lambda x: x,
            ####    'apply_to' : ['fakes','simbkg'],
            ####    #'apply_to' : [ 'simbkg'],#['fakes','simbkg'],  ## no fakes in case of optimization study
            ####}
        }

        
    def make_fakes(self, obj='t'):
        '''Sets up the fakes view'''
        print 'making fakes for %s' %obj
        data_view = self.get_view('data')
        tfakes = views.SubdirectoryView(data_view, 'tLoose')
        #efakes = views.SubdirectoryView(data_view, 'eLoose')
        #etfakes= views.SubdirectoryView(data_view, 'etLoose')
        #central_fakes=SubtractionView(views.SumView(tfakes,efakes),etfakes, restrict_positive=True)
        mc_views = self.mc_views()
        if self.use_embedded:            
            mc_views.append(self.get_view('ZetauEmbedded'))
        mc_sum = views.SumView(*mc_views)
        mc_sum_t = views.SubdirectoryView(mc_sum, 'tLoose')
        #mc_sum_e = views.SubdirectoryView(mc_sum, 'eLoose')
        #mc_sum_et = views.SubdirectoryView(mc_sum, 'etLoose')
        #allmc=SubtractionView(views.SumView(mc_sum_t,mc_sum_e),mc_sum_et, restrict_positive=True)
        #fakes_view = SubtractionView(central_fakes, allmc, restrict_positive=True)
        ##fakes_view =central_fakes
        fakes_view = SubtractionView(tfakes, mc_sum_t, restrict_positive=True)
        #fakes_view = tfakes
        style = data_styles['fakes']
        return views.TitleView(
            views.StyleView(
                fakes_view,
                **remove_name_entry(style)
            ),
            style['name']
        )
        #MedianView(highv=up_fakes, lowv=dw_fakes, centv=central_fakes, maxdiff=True),
        
    def make_embedded(self, normalization_path):
        '''Configures the embedded view'''
        embedded_view = self.get_view('ZetauEmbedded_Run2012*', 'unweighted_view')
        zjets_view = self.get_view('Z*jets_M50_skimmedTT')

        embedded_histo = embedded_view.Get(normalization_path)
        zjets_histo = zjets_view.Get(normalization_path)

        embed_int = embedded_histo.Integral()
        zjets_int = zjets_histo.Integral()
        

        scale_factor = zjets_int / embed_int
        
        scaled_view = views.TitleView(
            views.StyleView(views.ScaleView(embedded_view, scale_factor),
                **remove_name_entry(data_styles['ZetauEmbedded'])
            ),
            'Z #rightarrow #tau#tau (embedded)'
        )
        return scaled_view, scale_factor


    def simple_mcSignal (self, folder, variable, rebin=1, xaxis='',
                         leftside=True, xrange=None, preprocess=None, sort=True,forceLumi=-1):
        'plot only mc signal'
        signalview=[]
        mymax=0
        for n,sig in enumerate(self.mc_samples):
            signal_view=self.get_view(sig)
            if preprocess:
                signal_view=preprocess(signal_view)
            signal_view=self.get_wild_dir(
                self.rebin_view(signal_view,rebin),folder)
            signal=signal_view.Get(variable)
            signalview.append(signal)
            signal.Draw("SAME") if n!=0 else signal.Draw()
            if n==0:
                signal.GetXaxis().SetTitle(xaxis)
                if xrange: signal.GetXaxis().SetRangeUser(xrange[0], xrange[1])
                                        
            if signal.GetBinContent(signal.GetMaximumBin()) > mymax:
                mymax = signal.GetBinContent(signal.GetMaximumBin())
                signal.GetYaxis().SetRangeUser(0, mymax*1.2)
            self.keep.append(signal)
    
        
        all_var=[]
        all_var.extend(signalview) 
            
        self.add_legend(all_var, leftside, entries=len(signalview))

        
    def simpleplot_mc(self, folder, signal, variable, rebin=1, xaxis='',
                      leftside=True, xrange=None, preprocess=None, sort=True,forceLumi=-1,inflateSig=[1.]):
        ''' Compare Monte Carlo signal to bkg '''
        #path = os.path.join(folder, variable)
        #is_not_signal = lambda x: x is not signame
        #set_trace()

        mc_stack_view = self.make_stack(rebin, preprocess, folder)
        mc_stack=mc_stack_view.Get(variable)
        fakes_view = self.get_view('fakes')
        if preprocess:
            fakes_view = preprocess(fakes_view)
        fakes_view = RebinView(fakes_view, rebin)
        path = os.path.join(folder,variable)
        fakes = fakes_view.Get(path)

        mc_stack.Add(fakes)
        
        self.canvas.SetLogy(True)
        mc_stack.SetTitle('')
        mc_stack.Draw()
        
        mc_stack.GetHistogram().GetXaxis().SetTitle(xaxis)

        if xrange:
            mc_stack.GetXaxis().SetRangeUser(xrange[0], xrange[1])
            mc_stack.Draw()

        signalview=[]
        mymax=0
        for n,sig in enumerate(signal):
                signal_view=self.get_view(sig)
                if preprocess:
                    signal_view=preprocess(signal_view)
                signal_view=self.get_wild_dir(
                    self.rebin_view(signal_view,rebin),folder)
                signal_view=views.ScaleView(signal_view, inflateSig[n])
                signal=signal_view.Get(variable)

                signalview.append(signal)
                signal.Draw("SAME")
                if signal.GetBinContent(signal.GetMaximumBin()) > mymax:
                    mymax = signal.GetBinContent(signal.GetMaximumBin())
                    
                self.keep.append(signal)
        if mymax > mc_stack.GetMaximum():
            mc_stack.SetMaximum(mymax*1.2)

        self.keep.append(mc_stack)
        
        all_var=[]
        all_var.extend([mc_stack]) 
        all_var.extend(signalview) 
            
        self.add_legend(all_var, leftside, entries=len(mc_stack)+len(signalview))
 
    def plot_data(self, folder, variable, rebin=1, xaxis='',
                  leftside=True, xrange=None, preprocess=None):
        ''' Compare Monte Carlo signal to bkg '''
        #path = os.path.join(folder, variable)
        #is_not_signal = lambda x: x is not signame
        #set_trace()
        data_view = self.get_view('data')
        if preprocess:
            data_view = preprocess( data_view )
        data_view = self.get_wild_dir(
            self.rebin_view(data_view, rebin),
            folder
            )
        data = data_view.Get(variable)
        data.Draw()

         
        data.GetXaxis().SetTitle(xaxis)

        if xrange:
            data.GetXaxis().SetRangeUser(xrange[0], xrange[1])
            data.Draw()
        self.keep.append(data)
        
        
        
    def compare_data(self, folder, variable, folder2, rebin=1, xaxis='',
                     leftside=True, xrange=None, preprocess=None, show_ratio=False, ratio_range=0.2,rescale=1. ):
        ''' Compare Monte Carlo signal to bkg '''
        #path = os.path.join(folder, variable)
        #is_not_signal = lambda x: x is not signame
        #set_trace()
        data_view = self.get_view('data')
        data_view2 = self.get_view('data')
        if preprocess:
            data_view = preprocess( data_view )
        data_view = self.get_wild_dir(
            self.rebin_view(data_view, rebin),
            folder
            )
        data_view2 = self.get_wild_dir(
            self.rebin_view(data_view2, rebin),
            folder2
            )
        data = data_view.Get(variable)
        data2 = data_view2.Get(variable)
         
        data.GetXaxis().SetTitle(xaxis)
        #if (data.Integral()!=0 and data2.Integral()!=0) :
        #    data.Scale(1./data.Integral())
        #    data2.Scale(1./data2.Integral())
        data.Draw()
        data.GetYaxis().SetRangeUser(0, data.GetBinContent(data.GetMaximumBin())*1.2)
        if xrange:
            data.GetXaxis().SetRangeUser(xrange[0], xrange[1])
            data.Draw()

        data2.Draw("SAME")
        data2.SetMarkerColor(2)
        data2.Draw("SAME")
       

        if show_ratio:
            self.add_sn_ratio_plot(data2, data, xrange, ratio_range)

        self.keep.append(data)
        self.keep.append(data2)
        
        
    def add_ratio_bandplot(self, data_hist, mc_stack, err_hist,  x_range=None, ratio_range=0.2):
        #resize the canvas and the pad to fit the second pad
        self.canvas.SetCanvasSize( self.canvas.GetWw(), int(self.canvas.GetWh()*1.3) )
        self.canvas.cd()
        self.pad.SetPad(0, 0.33, 1., 1.)
        self.pad.Draw()
        self.canvas.cd()
        #create lower pad
        self.lower_pad = plotting.Pad(0, 0., 1., 0.33)
        self.lower_pad.Draw()
        self.lower_pad.cd()

        
        mc_hist    = None
        if isinstance(mc_stack, plotting.HistStack):
            mc_hist = sum(mc_stack.GetHists())
        else:
            mc_hist = mc_stack
        data_clone = data_hist.Clone()
        data_clone.Divide(mc_hist)
        
        band = err_hist.Clone()
        
        err = []
        ibin =1 
        while ibin < band.GetXaxis().GetNbins()+1:
            if mc_hist.GetBinContent(ibin) <> 0 : 
                err.append((ibin, band.GetBinError(ibin)/band.GetBinContent(ibin)))
            ibin+=1

        band.Divide(mc_hist.Clone())
        #print err
        for ibin in err:
            band.SetBinError(ibin[0], ibin[1])

        if not x_range:
            nbins = data_clone.GetNbinsX()
            x_range = (data_clone.GetBinLowEdge(1), 
                       data_clone.GetBinLowEdge(nbins)+data_clone.GetBinWidth(nbins))
        else:
            data_clone.GetXaxis().SetRangeUser(*x_range)


        ref_function = ROOT.TF1('f', "1.", *x_range)
        ref_function.SetLineWidth(2)
        ref_function.SetLineStyle(2)
        
        data_clone.Draw()
 
        if ratio_range:
            data_clone.GetYaxis().SetRangeUser(1-ratio_range, 1+ratio_range)
        ref_function.Draw('same')
        band.SetMarkerStyle(0)
        band.SetLineColor(1)
        band.SetFillStyle('3002')
        band.SetFillColor(1)

        band.Draw('samee2')
       
        self.keep.append(data_clone)
        self.keep.append(band)
        self.keep.append(ref_function)
        self.pad.cd()
        return data_clone

 
    def add_ratio_diff(self, data_hist, mc_stack, err_hist,  x_range=None, ratio_range=0.2):
        #resize the canvas and the pad to fit the second pad
        self.canvas.SetCanvasSize( self.canvas.GetWw(), int(self.canvas.GetWh()*1.3) )
        self.canvas.cd()
        self.pad.SetPad(0, 0.33, 1., 1.)
        self.pad.Draw()
        self.canvas.cd()
        #create lower pad
        self.lower_pad = plotting.Pad(0, 0., 1., 0.33)
        self.lower_pad.Draw()
        self.lower_pad.cd()

        
        mc_hist    = None
        if isinstance(mc_stack, plotting.HistStack):
            mc_hist = sum(mc_stack.GetHists())
        else:
            mc_hist = mc_stack
        data_clone = data_hist.Clone()
        data_clone.Sumw2()
        data_clone.Add(mc_hist, -1)
        data_clone.Divide(mc_hist)
        
        band = err_hist.Clone()
        
        err = []
        ibin =1 
        while ibin < band.GetXaxis().GetNbins()+1:
            if mc_hist.GetBinContent(ibin) <> 0 : 
                err.append((ibin, band.GetBinError(ibin)/band.GetBinContent(ibin)))
                #print ibin, band.GetBinError(ibin), band.GetBinContent(ibin), band.GetBinError(ibin)/band.GetBinContent(ibin)
                
            ibin+=1

        #band.Divide(mc_hist.Clone())
        #print band
        for ibin in err:
            band.SetBinError(ibin[0], ibin[1])
            band.SetBinContent(ibin[0], 0. )

        #if self.blind_region:
        #    for ibin in err:
        #        if ibin >= band.FindBin(self.blind_region[0]) and ibin <= band.FindBin(self.blind_region[1]):
        #            band.SetBinError(ibin, 10)

        if not x_range:
            nbins = data_clone.GetNbinsX()
            x_range = (data_clone.GetBinLowEdge(1), 
                       data_clone.GetBinLowEdge(nbins)+data_clone.GetBinWidth(nbins))
        else:
            data_clone.GetXaxis().SetRangeUser(*x_range)


        ref_function = ROOT.TF1('f', "0.", *x_range)
        ref_function.SetLineWidth(2)
        ref_function.SetLineStyle(2)
        
        data_clone.Draw()
 
        if ratio_range:
            data_clone.GetYaxis().SetRangeUser(-ratio_range, +ratio_range)
        ref_function.Draw('same')
        band.SetMarkerStyle(0)
        band.SetLineColor(1)
        band.SetFillStyle('x')
        band.SetFillColor(1)

        band.Draw('samee2')
       
        self.keep.append(data_clone)
        self.keep.append(band)
        self.keep.append(ref_function)
        self.pad.cd()
        return data_clone

    def add_shape_systematics(self, histo, path, view, folder_systematics = [], name_systematics = []):
        '''Adds shape systematics
        add_shape_systematics(self, histo, path, view, folder_systematics = [], name_systematics = []) --> histo
        histo is the central value 
        path is the path if the central value histo
        view contains all the systematics. 
        folder_systematics is a list of tuples with the folders containing shifts (up, down)
        name_systematics is a list of tuples containing the postfix to obtain the shifts (up, down)
        '''
         
        systematics = []
        for sys_up, sys_dw in folder_systematics:
            h_up = view.Get(os.path.join(sys_up, path))
            h_dw = view.Get(os.path.join(sys_dw, path))
            systematics.append(
                (h_up, h_dw)
                )

        #check if we have to apply met uncertainties
        for sys_up, sys_dw in name_systematics:
            h_up = view.Get(path + sys_up)
            h_dw = view.Get(path + sys_dw)
            systematics.append(
                (h_up, h_dw)
            )
        

        #ADD systematics
        return histo_diff_quad(histo, *systematics)
        



    def add_histo_error(self, histo, histoerr):
        clone = histo.GetStack().Last().Clone('errhist')
        for bin in range(1,clone.GetXaxis().GetNbins()):
            error = histoerr.GetBinError(bin)*clone.GetBinContent(bin)/histoerr.GetBinContent(bin) if histoerr.GetBinContent(bin) <>0 else histoerr.GetBinError(bin)
            clone.SetBinError(bin, error )
       
        return clone
    def plot_simple (self, folder, variable, rebin=1, xaxis='',
                     leftside=True, xrange=None, preprocess=None,
                     show_ratio=False, ratio_range=0.2, sort=True, obj=['e1', 'e2'], plot_data=False):
        path = os.path.join(folder,variable)

        mc_views = self.mc_views(rebin, preprocess)
        mc_stack_view = views.StackView(*mc_views, sorted=sort) 
        mc_stack = mc_stack_view.Get( path )

        #make histo clone for err computation
        mc_sum_view = views.SumView(*mc_views)
        mc_err = mc_sum_view.Get( path )

        mc_sum_view = views.SumView(*mc_views)
        mc_err = mc_sum_view.Get( path )
        


    def plot_with_bkg_uncert (self, folder, variable, rebin=1, xaxis='',
                              leftside=True, xrange=None, preprocess=None,
                              show_ratio=False, ratio_range=0.2, sort=True, obj=['e1', 'e2'], plot_data=False):

        if DEBUG: print 'start plotting', datetime.datetime.now()
        #xsection uncertainties
        #names must match with what defined in self.mc_samples
        xsec_unc_mapper = {
            'TTJets*' : 0.15,
            'T*_t*' : 0.05,
            '[WZ][WZ]' : 0.05, #diboson
            'W*Jets*' : 0.035, #WJets
            'DY*Jets' : 0.10, # theoretical 0.032
         }


        path = os.path.join(folder,variable)

        #get fakes
        fakes_view = self.get_view('fakes')
        if preprocess:
            fakes_view = preprocess(fakes_view)
        fakes_view = RebinView(fakes_view, rebin)
        fakes = fakes_view.Get(path)

        ##fakes = self.add_shape_systematics(
        ##    fakes, 
        ##    path, 
        ##    fakes_view, 
        ##    [('Up','Down')]
        ##)
        fakes = SystematicsView.add_error(fakes, 0.20)  # 20% is raccomended from the tau pog
        #add them to backgrounds
        #set_trace()
        if DEBUG: print  'fakes', datetime.datetime.now()    

        #make MC views with xsec error
        mc_views_nosys = self.mc_views(rebin, preprocess)
        
        mc_subt_view=[]
        for view in mc_views_nosys:
            new = SubtractionView(view,
                                  views.SubdirectoryView(view, 'tLoose'),
                                  restrict_positive=True)
            
            mc_subt_view.append(new)
            
        if DEBUG: print mc_subt_view, mc_views_nosys
        mc_views = []
        for view, name in zip(mc_subt_view, self.mc_samples):
            new = SystematicsView(
                view,
                xsec_unc_mapper.get(name, 0.) #default to 0
            )
            mc_views.append(new)
        if DEBUG: print mc_views
        if DEBUG: print 'mc_view',  datetime.datetime.now()
        #make MC stack
        
        mc_stack_view = views.StackView(*mc_views, sorted=sort)
        if DEBUG: print mc_stack_view
        mc_stack = mc_stack_view.Get( path )
        if DEBUG: print 'mc_stack_view',  datetime.datetime.now()
        #make histo clone for err computation
        mc_sum_view = views.SumView(*mc_views)
        mc_err = mc_sum_view.Get( path )

        mc_stack.Add(fakes)
                
        mc_err.Sumw2()
        mc_err.Add(fakes)

        if DEBUG: print 'mc_sum_view',  datetime.datetime.now()
        #Add MC-only systematics
        folder_systematics = [
        ]
        
        met_systematics = [ 
        ]

        name_systematics = [] #which are not MET
        ###add MET sys if necessary
        ##if 'collmass' in variable.lower() or \
        ##   'met' in variable.lower():
        ##    if not variable.lower().startswith('type1'):
        ##        name_systematics.extend(met_systematics) # TO ADD WHEN RERUN WITH THE NEW BINNING 

        
       ## mc_err = self.add_shape_systematics(
       ##     mc_err, 
       ##     path, 
       ##     mc_sum_view, 
       ##     folder_systematics,
       ##     name_systematics)

        #add jet category uncertainty
        ##jetcat_unc_mapper = {
        ##    0 : 0.017,
        ##    1 : 0.035,
        ##    2 : 0.05
        ##}
        ###find in which jet category we are
        ##regex = re.compile('\/\d\/')
        ##found = regex.findall(path)
        ##jet_unc = 0.
        ##if found:
        ##    njet = int(found[0].strip('/'))
        ##    ##jet_unc = jetcat_unc_mapper.get(njet, 0. ) ##commented as it is not computed yet
        ##mc_err = SystematicsView.add_error(mc_err, jet_unc)

        #check if we are using the embedded sample
        if self.use_embedded:
            embed_view = self.get_view('ZetauEmbedded')
            if preprocess:
                embed_view = preprocess(embed_view)
            embed_view = RebinView( embed_view, rebin)
            embed = embed_view.Get(path)

            #add xsec error
            embed = SystematicsView.add_error( embed, xsec_unc_mapper['Z*jets_M50_skimmedTT'])
 
            #add them to backgrounds
            mc_stack.Add(embed)
            mc_err += embed
            
            mc_sum_view = views.SumView(mc_sum_view, embed_view)
        if DEBUG: print 'embedded', datetime.datetime.now()
        #Add MC and embed systematics
        folder_systematics = [
        ##    ('trp1s', 'trm1s'), #trig scale factor
        ]
        
        #print folder_systematics
        #Add as many eid sys as requested
        ##for name in obj:
        ##    folder_systematics.extend([
        ##        ('%sidp1s'  % name, '%sidm1s'  % name), #eID scale factor
        ##        ('%sisop1s' % name, '%sisom1s' % name), #e Iso scale factor
        ##        
        ##    ])
        
            
        ##mc_err = self.add_shape_systematics(
        ##    mc_err, 
        ##    path, 
        ##    mc_sum_view, 
        ##    folder_systematics)

        #add lumi uncertainty
        mc_err = SystematicsView.add_error( mc_err,  0.025)
        
        self.canvas.SetLogy(True)
        #draw stack
        mc_stack.Draw()
        ##self.keep.append(mc_stack)
        
        #set cosmetics
        self.canvas.SetLogy(True)
        ##self.canvas.SetGridx(True)
        ##self.canvas.SetGridy(True)
        ##self.pad.SetGridx(True)
        ##self.pad.SetGridy(True)
        
        mc_stack.GetHistogram().GetXaxis().SetTitle(xaxis)
        if xrange:
            mc_stack.GetXaxis().SetRangeUser(xrange[0], xrange[1])
            ##mc_stack.Draw()
              
        #set cosmetics 
        mc_err.SetMarkerStyle(0)
        mc_err.SetLineColor(1)
        mc_err.SetFillStyle('x')
        mc_err.SetFillColor(1)
        mc_err.Draw('pe2 same')
        ##self.keep.append(mc_err)
        if DEBUG: print  'draw mc', datetime.datetime.now()
        #Get signal
        signals = [
            'GluGlu_LFV_HToETau_M200*',
            'GluGlu_LFV_HToETau_M450*',
            'GluGlu_LFV_HToETau_M600*',
            'GluGlu_LFV_HToETau_M750*',
            'GluGlu_LFV_HToETau_M900*'
 #'ggM300ETau', 'ggM450ETau', 'ggM600ETau', 'ggM750ETau', 'ggM900ETau'
        ]
        sig = []
        for name in signals:
            sig_view = self.get_view(name)
            if preprocess:
                sig_view = preprocess(sig_view)
            sig_view = RebinView(sig_view, rebin)
            if not plot_data:
                sig_view = views.ScaleView(sig_view, 100)
            
            histogram = sig_view.Get(path)
            histogram.Draw('same')
            ##self.keep.append(histogram)
            sig.append(histogram)
        if DEBUG: print  'signal', datetime.datetime.now()
        for lfvh in sig:
            if lfvh.GetMaximum() > mc_stack.GetMaximum():
                mc_stack.SetMaximum(1.2*lfvh.GetMaximum()) 

        if plot_data==True:

            
            
            # Draw data
            data_view = self.get_view('data')
            if preprocess:
                data_view = preprocess( data_view )
            data_view = self.rebin_view(data_view, rebin)
            data = data_view.Get(path)

            if self.blind_region:
                for bin in range(data.GetNbinsX()+1):
                    bg_count=mc_stack.GetStack().Last().GetBinContent(bin)
                    if bg_count<=0 : continue
                    sig_count=0.0001
                    for histo in sig:
                        sig_count=histo.GetBinContent(bin)
                        if sig_count<=0: continue
                        #print path, bin,  histo.GetXaxis().GetBinCenter(bin), bg_count, sig_count, float(sig_count)/float(sig_count+bg_count)
                        if (float(sig_count)/float(sig_count+bg_count)>0.01):
                            data.SetBinContent(bin,0.)
                            data.SetBinError(bin,0.)

            
            data.Draw('same')
            #print 'data', data.Integral()
            ##self.keep.append(data)
            if DEBUG: print  'data', datetime.datetime.now()
            ## Make sure we can see everything
            if data.GetMaximum() > mc_stack.GetMaximum():
                mc_stack.SetMaximum(1.2*data.GetMaximum()) 
                if lfvh.GetMaximum() > mc_stack.GetMaximum():
                    mc_stack.SetMaximum(1.2*lfvh.GetMaximum()) 


                    
        if plot_data:
            #self.add_legend([data, mc_stack], leftside, entries=len(mc_stack.GetHists())+1)
            self.add_legend([data, sig[0], sig[1],sig[2], sig[3],sig[4], sig[5], mc_stack], leftside, entries=len(mc_stack.GetHists())+7)
        else:
            self.add_legend([sig[0], sig[1],sig[2], sig[3],sig[4], sig[5], mc_stack], leftside, entries=len(mc_stack.GetHists())+6)
        if show_ratio and plot_data:
            self.add_ratio_diff(data, mc_stack, mc_err, xrange, ratio_range)
            #self.add_ratio_bandplot(data, mc_stack, mc_err,  xrange, ratio_range) # add_ratio_diff(data, mc_stack, mc_err, xrange, ratio_range)

        if DEBUG: print  'ratio', datetime.datetime.now()
     
  
        #print ROOT.gROOT.ls()
##        for myfile in  ROOT.gROOT.GetListOfFiles():
##            print myfile.GetName()
##            myfile.Close()
##            myfile.delete()
##            

                       
##-----

    def plot_without_uncert (self, folder, variable, rebin=1, xaxis='',
                        leftside=True, xrange=None, preprocess=None,
                              show_ratio=False, ratio_range=0.2, sort=True):
        
        

        mc_stack_view = self.make_stack(rebin, preprocess, folder, sort)

        mc_stack = mc_stack_view.Get(variable)
        mc_stack.Draw()
        
        self.canvas.SetLogy(True)
        mc_stack.GetHistogram().GetXaxis().SetTitle(xaxis)
        if xrange:
            mc_stack.GetXaxis().SetRangeUser(xrange[0], xrange[1])
            mc_stack.Draw()
        self.keep.append(mc_stack)
        

        finalhisto= mc_stack.GetStack().Last().Clone()
        finalhisto.Sumw2()

        histlist = mc_stack.GetHists();
        bkg_stack = mc_stack_view.Get(variable)
        bkg_stack.GetStack().RemoveLast()## mettere il check se c'e` il fake altirmenti histo=mc_stack.GetStack().Last().Clone()
        histo=bkg_stack.GetStack().Last().Clone()
        histo.Sumw2()
        
        fake_p1s_histo=None
      
        if not folder.startswith('tLoose') and not folder.startswith('eLoose') and not folder.startswith('etLoose') :
            isFakesIn= False
            ##isEFakesIn=False
            isETFakesIn=False
            if 'Fakes' in self.mc_samples:
                self.mc_samples.remove('Fakes')  
                if 'finalDYLL' in self.mc_samples: self.mc_samples.remove('finalDYLL')
                isFakesIn=True
            ##if 'eFakes' in self.mc_samples:
            ##    self.mc_samples.remove('eFakes')  
            ##    if 'finalDYLL' in self.mc_samples:  self.mc_samples.remove('finalDYLL')
            ##    isEFakesIn=True
            ##if 'etFakes' in self.mc_samples:
            ##    self.mc_samples.remove('etFakes')  
            ##    if 'finalDYLL' in self.mc_samples:  self.mc_samples.remove('finalDYLL')
            ##    isETFakesIn=True
                

        ibin =1
            
        if isFakesIn:
            self.mc_samples.append('Fakes')
           # self.mc_samples.append('etFakes')
           # self.mc_samples.append('finalDYLL')
       ## if isEFakesIn:
       ##     self.mc_samples.append('eFakes')
       ##     if not 'finalDYLL' in self.mc_samples:  self.mc_samples.append('finalDYLL')
       ## if isETFakesIn:
       ##     self.mc_samples.append('etFakes')
       ##     if not 'finalDYLL' in self.mc_samples:  self.mc_samples.append('finalDYLL')


        finalhisto.Draw('samee2')
        finalhisto.SetMarkerStyle(0)
        finalhisto.SetLineColor(1)
        finalhisto.SetFillStyle(3001)
        finalhisto.SetFillColor(1)

        
        self.keep.append(finalhisto)
        # Draw data
        data_view = self.get_view('data')
        if preprocess:
            data_view = preprocess( data_view )
        data_view = self.get_wild_dir(
            self.rebin_view(data_view, rebin),
            folder
            )
        data = data_view.Get(variable)
        data.Draw('same')
        #print 'data', data.Integral()
        self.keep.append(data)
        ## Make sure we can see everything
        if data.GetMaximum() > mc_stack.GetMaximum():
            mc_stack.SetMaximum(1.2*data.GetMaximum()) 
            
            # # Add legend
        self.add_legend([data, mc_stack], leftside, entries=len(mc_stack.GetHists())+1)
        if show_ratio:
            self.add_ratio_diff(data, mc_stack, finalhisto, xrange, ratio_range)
            
    def write_shapes(self, folder, variable, output_dir, br_strenght=1,
                     rebin=1, last = None,  preprocess=None): #, systematics):
        '''Makes shapes for computing the limit and returns a list of systematic effects to be added to unc.vals/conf 
        make_shapes(folder, variable, output_dir, [rebin=1, preprocess=None) --> unc_conf_lines (list), unc_vals_lines (list)
        '''
        output_dir.cd()
        path = os.path.join(folder,variable)

        # Draw data
        data_view = self.get_view('data')
        if preprocess:
            data_view = preprocess( data_view )
        data_view = self.rebin_view(data_view, rebin)

        data = data_view.Get(path)
       
        if last : data=change_histo_nbins(data, 0, last)
        first_filled, last_filled = find_fill_range(data)
        data.SetName('data_obs')
        data.Write()
        mc_views_nosys = self.mc_views(rebin, preprocess)
        
        mc_subt_view=[]
        for view in mc_views_nosys:
            new = SubtractionView(view,
                                  views.SubdirectoryView(view, 'tLoose'),
                                  restrict_positive=True)
            
            mc_subt_view.append(new)
        

        #make MC views with xsec error
        bkg_views  = dict(
            [(self.datacard_names[i], j) for i, j in zip(self.mc_samples,  mc_subt_view)]
        )
        bkg_histos = {}
        for name, view in bkg_views.iteritems():
            if DEBUG : print name, path
            mc_histo = view.Get(path)
            if DEBUG : print name, path
            if last : mc_histo = change_histo_nbins(mc_histo, 0, last)
            if DEBUG : print name, path
            first_filled_bkg, last_filled_bkg= find_fill_range(mc_histo)
            if DEBUG : print name, path
            bkg_histos[name] = mc_histo.Clone()
            mc_histo.SetName(name)
            if DEBUG : print name, mc_histo.GetName()
            mc_histo.Write()

        if self.use_embedded:            
            view = self.get_view('ZetauEmbedded')
            if preprocess:
                view = preprocess(view)
            view = self.rebin_view(view, rebin)
            name = self.datacard_names['ZetauEmbedded']
            bkg_views[name] = view
            mc_histo = view.Get(path)
            if last : mc_histo = change_histo_nbins(mc_histo, 0, last)
            first_filled_bkg, last_filled_bkg= find_fill_range(mc_histo)
            bkg_histos[name] = mc_histo.Clone()
            ##mc_histo = remove_empty_bins(
            ##    mc_histo, weight,
            ##    first_filled_bkg, last_filled_bkg)
            mc_histo.SetName(name)
            mc_histo.Write()
          
        fakes_view = self.get_view('fakes') 
        d_view = self.get_view('data')
        ##weights_view = views.SumView(
        ##    views.SubdirectoryView(d_view, 'tLoose'),
        ##    #views.SubdirectoryView(d_view, 'eLoose'),
        ##    #views.SubdirectoryView(d_view, 'etLoose')
        ##    )
        if preprocess:
            fakes_view = preprocess(fakes_view)    
            ##weights_view = preprocess(weights_view)
        ##weights = weights_view.Get(os.path.join(folder,'weight'))
        #print folder
        fakes_view = self.rebin_view(fakes_view, rebin)
        bkg_views['fakes'] = fakes_view
        ##bkg_weights['fakes'] = mean(weights)
        fake_shape = bkg_views['fakes'].Get(path)
        if last : fake_shape = change_histo_nbins(fake_shape, 0, last)
        bkg_histos['fakes'] = fake_shape.Clone()
        if last : bkg_histos['fakes'] =change_histo_nbins(bkg_histos['fakes'] , 0, last)
        first_filled_bkg, last_filled_bkg = find_fill_range(bkg_histos['fakes'])
        ##fake_shape = remove_empty_bins(
        ##    fake_shape, bkg_weights['fakes'],
        ##    first_filled_bkg, last_filled_bkg)
        fake_shape.SetName('fakes')
        fake_shape.Write()
        if DEBUG : print 'fakes', fake_shape.GetName()

        #Get signal
        signals = [
            'GluGlu_LFV_HToETau_M200*',
            'GluGlu_LFV_HToETau_M450*',
            'GluGlu_LFV_HToETau_M600*',
            'GluGlu_LFV_HToETau_M750*',
            'GluGlu_LFV_HToETau_M900*'#'ggM300ETau', 'ggM450ETau', 'ggM600ETau', 'ggM750ETau', 'ggM900ETau'
        ]
        for name in signals:
            sig_view = self.get_view(name)
            card_name = self.datacard_names[name]
            if preprocess:
                sig_view = preprocess(sig_view)
            sig_view = views.ScaleView(
                RebinView(sig_view, rebin),
                br_strenght
                )
            ##weights = self.get_view(name, 'weight')
            bkg_views[card_name] = sig_view
            ##bkg_weights[card_name] = weights
            histogram = sig_view.Get(path)
            if last : histogram = change_histo_nbins(histogram, 0, last)
            bkg_histos[card_name] = histogram.Clone()
            first_filled_bkg, last_filled_bkg = find_fill_range(bkg_histos[card_name])
            ##histogram = remove_empty_bins(
            ##    histogram, bkg_weights[card_name],
            ##    first_filled_bkg, last_filled_bkg)
            histogram.SetName(card_name)
            histogram.Write()
            if DEBUG : print name, histogram.GetName()


        unc_conf_lines = []
        unc_vals_lines = []


        
        
        return unc_conf_lines, unc_vals_lines
                       
    ##-----

    def write_shapes_for_yields(self, folder, variable, output_dir, br_strenght=1,
                                rebin=1, preprocess=None): #, systematics):
        '''Makes shapes for computing the limit and returns a list of systematic effects to be added to unc.vals/conf 
        make_shapes(folder, variable, output_dir, [rebin=1, preprocess=None) --> unc_conf_lines (list), unc_vals_lines (list)
        '''
        output_dir.cd()
        path = os.path.join(folder,variable)

        # Draw data
        data_view = self.get_view('data')
        if preprocess:
            data_view = preprocess( data_view )
        data_view = self.rebin_view(data_view, rebin)
        data = data_view.Get(path)
        first_filled, last_filled = find_fill_range(data)
        data.SetName('data_obs')
        data.Write()

        #make MC views with xsec error
        bkg_views  = dict(
            [(self.datacard_names[i], j) for i, j in zip(self.mc_samples, self.mc_views(rebin, preprocess))]
        )
        bkg_weights = dict(
            [(self.datacard_names[i], self.get_view(i, 'weight')) for i in self.mc_samples]
        )
        #cache histograms, since getting them is time consuming
        bkg_histos = {}
        for name, view in bkg_views.iteritems():
            mc_histo = view.Get(path)
            first_filled_bkg, last_filled_bkg= find_fill_range(mc_histo)
            #print name, first_filled_bkg, last_filled_bkg, mc_histo.GetXaxis().GetNbins()
            bkg_histos[name] = mc_histo.Clone()
            #mc_histo = remove_empty_bins(
            #    mc_histo, bkg_weights[name],
            #    first_filled_bkg, last_filled_bkg)
            mc_histo.SetName(name)
            mc_histo.Write()

        if self.use_embedded:            
            view = self.get_view('ZetauEmbedded')
            weight = self.get_view('ZetauEmbedded', 'weight')
            if preprocess:
                view = preprocess(view)
            view = self.rebin_view(view, rebin)
            name = self.datacard_names['ZetauEmbedded']
            bkg_weights[name] = weight
            bkg_views[name] = view
            mc_histo = view.Get(path)
            first_filled_bkg, last_filled_bkg= find_fill_range(mc_histo)
            bkg_histos[name] = mc_histo.Clone()
            #mc_histo = remove_empty_bins(
            #    mc_histo, weight,
            #    first_filled_bkg, last_filled_bkg)
            mc_histo.SetName(name)
            mc_histo.Write()
          
        fakes_view = self.get_view('fakes') 
        d_view = self.get_view('data')
        weights_view = views.SumView(
            views.SubdirectoryView(d_view, 'tLoose'),
            views.SubdirectoryView(d_view, 'eLoose'),
            views.SubdirectoryView(d_view, 'etLoose')
            )
        if preprocess:
            fakes_view = preprocess(fakes_view)    
            weights_view = preprocess(weights_view)
        weights = weights_view.Get(os.path.join(folder,'weight'))
        #print folder
        fakes_view = self.rebin_view(fakes_view, rebin)
        bkg_views['fakes'] = fakes_view
        bkg_weights['fakes'] = mean(weights)
        fake_shape = bkg_views['fakes'].Get(path)
        bkg_histos['fakes'] = fake_shape.Clone()
        first_filled_bkg, last_filled_bkg = find_fill_range(bkg_histos['fakes'])
        #fake_shape = remove_empty_bins(
        #    fake_shape, bkg_weights['fakes'],
        #    first_filled_bkg, last_filled_bkg)
        fake_shape.SetName('fakes')
        fake_shape.Write()

        #Get signal
        signals = [
            'ggHiggsToETau',
            'vbfHiggsToETau',
        ]
        for name in signals:
            sig_view = self.get_view(name)
            card_name = self.datacard_names[name]
            if preprocess:
                sig_view = preprocess(sig_view)
            sig_view = views.ScaleView(
                RebinView(sig_view, rebin),
                br_strenght
                )
            weights = self.get_view(name, 'weight')
            bkg_views[card_name] = sig_view
            bkg_weights[card_name] = weights
            histogram = sig_view.Get(path)
            bkg_histos[card_name] = histogram.Clone()
            first_filled_bkg, last_filled_bkg = find_fill_range(bkg_histos[card_name])
            #histogram = remove_empty_bins(
            #    histogram, bkg_weights[card_name],
            #    first_filled_bkg, last_filled_bkg)
            histogram.SetName(card_name)
            histogram.Write()


        unc_conf_lines = []
        unc_vals_lines = []
        category_name  = output_dir.GetName()
        for unc_name, info in self.systematics.iteritems():
            targets = []
            for target in info['apply_to']:
                if target in self.sample_groups:
                    targets.extend(self.sample_groups[target])
                else:
                    targets.append(target)

            unc_conf = 'lnN' if info['type'] == 'yield' or info['type'] == 'stat' else 'shape'            
            #stat shapes are uncorrelated between samples
            if info['type'] <> 'stat':
                unc_conf_lines.append('%s %s' % (unc_name, unc_conf))
            shift = 0.
            path_up = info['+'](path)
            path_dw = info['-'](path)
            for target in targets:
                up      = bkg_views[target].Get(
                    path_up
                )
                down    = bkg_views[target].Get(
                    path_dw
                )
                if info['type'] == 'yield':
                    central = bkg_histos[target]
                    integral = central.Integral()
                    integral_up = up.Integral()
                    integral_down = down.Integral()
                    if integral == 0  and integral_up == 0 and integral_down ==0 :
                        shift=shift
                    else:
                        shift = max(
                            shift,
                            (integral_up - integral) / integral,
                            (integral - integral_down) / integral
                        )
                elif info['type'] == 'shape':
                    #remove empty bins also for shapes 
                    #(but not in general to not spoil the stat uncertainties)
                    first_filled_bkg,last_filled_bkg= find_fill_range( bkg_histos[target])
                    ##up = remove_empty_bins(
                    ##    up, bkg_weights[target],
                    ##    first_filled_bkg, last_filled_bkg)
                    first_filled_bkg, last_filled_bkg= find_fill_range( bkg_histos[target])
                    ##down = remove_empty_bins(
                    ##    down, bkg_weights[target],
                    ##    first_filled_bkg, last_filled_bkg)
                    up.SetName('%s_%sUp' % (target, unc_name))
                    down.SetName('%s_%sDown' % (target, unc_name))
                    up.Write()
                    down.Write()
                elif info['type'] == 'stat':
                    nbins = up.GetNbinsX()
                    up.Rebin(nbins)
                    yield_val = up.GetBinContent(1)
                    yield_err = up.GetBinError(1)
                    #print target, yield_val, yield_err, 
                    if yield_val==0:
                        unc_value = 0.
                    else:
                        unc_value = 1. + (yield_err / yield_val)
                    stat_unc_name = '%s_%s_%s' % (target, category_name, unc_name)
                    unc_conf_lines.append('%s %s' % (stat_unc_name, unc_conf))
                    unc_vals_lines.append(
                        '%s %s %s %.2f' % (category_name, target, stat_unc_name, unc_value)
                    )
                else:
                    raise ValueError('systematic uncertainty type:"%s" not recognised!' % info['type'])

            if info['type'] <> 'stat':
                shift += 1
                unc_vals_lines.append(
                    '%s %s %s %.2f' % (category_name, ','.join(targets), unc_name, shift)
                )

        return unc_conf_lines, unc_vals_lines

    
##        output_dir.cd()
##        path = os.path.join(folder,variable)
##
##        #make MC views with xsec error
##        bkg_views  = dict(
##            [(self.datacard_names[i], j) for i, j in zip(self.mc_samples, self.mc_views(rebin, preprocess))]
##        )
##        bkg_weights = dict(
##            [(self.datacard_names[i], self.get_view(i, 'weight')) for i in self.mc_samples]
##        )
##        #cache histograms, since getting them is time consuming
##        bkg_histos = {}
##        for name, view in bkg_views.iteritems():
##            mc_histo = view.Get(path)
##            bkg_histos[name] = mc_histo.Clone()
##            #mc_histo = remove_empty_bins(
##            #    mc_histo, bkg_weights[name])
##            mc_histo.SetName(name)
##            mc_histo.Write()
##
##        if self.use_embedded:            
##            view = self.get_view('ZetauEmbedded')
##            weight = self.get_view('ZetauEmbedded', 'weight')
##            if preprocess:
##                view = preprocess(view)
##            view = self.rebin_view(view, rebin)
##            name = self.datacard_names['ZetauEmbedded']
##            bkg_weights[name] = weight
##            bkg_views[name] = view
##            mc_histo = view.Get(path)
##            bkg_histos[name] = mc_histo.Clone()
##            #mc_histo = remove_empty_bins(
##            #    mc_histo, weight)
##            mc_histo.SetName(name)
##            mc_histo.Write()
##          
##        fakes_view = self.get_view('fakes')#to comment for optimization study
##        d_view = self.get_view('data')
##        weights_view = views.SumView(
##            views.SubdirectoryView(d_view, 'tLoose'),
##            views.SubdirectoryView(d_view, 'eLoose'),
##            views.SubdirectoryView(d_view, 'etLoose')
##            )
##        if preprocess:
##            fakes_view = preprocess(fakes_view)
##            weights_view = preprocess(weights_view)
##        weights = weights_view.Get(os.path.join(folder,'weight')) #to comment for optimization study
##        fakes_view = self.rebin_view(fakes_view, rebin)
##        bkg_views['fakes'] = fakes_view
##        bkg_weights['fakes'] = mean(weights)
##        fake_shape = bkg_views['fakes'].Get(path)
##        bkg_histos['fakes'] = fake_shape.Clone()
##        #fake_shape = remove_empty_bins(
##        #    fake_shape, bkg_weights['fakes'])
##        fake_shape.SetName('fakes')
##        fake_shape.Write()
##
##        unc_conf_lines = []
##        unc_vals_lines = []
##        category_name  = output_dir.GetName()
##        for unc_name, info in self.systematics.iteritems():
##            print unc_name
##            targets = []
##            for target in info['apply_to']:
##                if target in self.sample_groups:
##                    targets.extend(self.sample_groups[target])
##                else:
##                    targets.append(target)
##
##            unc_conf = 'lnN' if info['type'] == 'yield' or info['type'] == 'stat' else 'shape'            
##            #stat shapes are uncorrelated between samples
##            if info['type'] <> 'stat':
##                unc_conf_lines.append('%s %s' % (unc_name, unc_conf))
##            shift = 0.
##            path_up = info['+'](path)
##            path_dw = info['-'](path)
##            for target in targets:
##                up      = bkg_views[target].Get(
##                    path_up
##                )
##                down    = bkg_views[target].Get(
##                    path_dw
##                )
##                if info['type'] == 'yield':
##                    central = bkg_histos[target]
##                    integral = central.Integral()
##                    integral_up = up.Integral()
##                    integral_down = down.Integral()
##                    if integral == 0  and integral_up == 0 and integral_down ==0 :
##                        shift=shift
##                    else:
##                        shift = max(
##                            shift,
##                            (integral_up - integral) / integral,
##                            (integral - integral_down) / integral
##                        )
##                elif info['type'] == 'shape':
##                    #remove empty bins also for shapes 
##                    #(but not in general to not spoil the stat uncertainties)
##                    #up = remove_empty_bins(up, bkg_weights[target])
##                    #down = remove_empty_bins(down, bkg_weights[target])
##                    up.SetName('%s_%sUp' % (target, unc_name))
##                    down.SetName('%s_%sDown' % (target, unc_name))
##                    up.Write()
##                    down.Write()
##                elif info['type'] == 'stat':
##                    nbins = up.GetNbinsX()
##                    up.Rebin(nbins)
##                    yield_val = up.GetBinContent(1)
##                    yield_err = up.GetBinError(1)
##                    print target, yield_val, yield_err, 
##                    if yield_val==0:
##                        unc_value = 0.
##                    else:
##                        unc_value = 1. + (yield_err / yield_val)
##                    stat_unc_name = '%s_%s_%s' % (target, category_name, unc_name)
##                    unc_conf_lines.append('%s %s' % (stat_unc_name, unc_conf))
##                    unc_vals_lines.append(
##                        '%s %s %s %.2f' % (category_name, target, stat_unc_name, unc_value)
##                    )
##                else:
##                    raise ValueError('systematic uncertainty type:"%s" not recognised!' % info['type'])
##
##            if info['type'] <> 'stat':
##                shift += 1
##                unc_vals_lines.append(
##                    '%s %s %s %.2f' % (category_name, ','.join(targets), unc_name, shift)
##                )
##
##        #Get signal
##        signals = [
##            'ggHiggsToETau',
##            'vbfHiggsToETau',
##        ]
##        for name in signals:
##            sig_view = self.get_view(name)
##            if preprocess:
##                sig_view = preprocess(sig_view)
##            sig_view = views.ScaleView(
##                RebinView(sig_view, rebin),
##                br_strenght
##                )
##            
##            histogram = sig_view.Get(path)
##            histogram.SetName(self.datacard_names[name])
##            histogram.Write()
##
##        # Draw data
##        data_view = self.get_view('data')
##        if preprocess:
##            data_view = preprocess( data_view )
##        data_view = self.rebin_view(data_view, rebin)
##        data = data_view.Get(path)
##        data.SetName('data_obs')
##        data.Write()
##
##        return unc_conf_lines, unc_vals_lines
                       
##-----


    
 
  
    def write_shapes_with_syst(self, folder, variable, output_dir, br_strenght=1,
                                rebin=1, last=None, preprocess=None): #, systematics):
        '''Makes shapes for computing the limit and returns a list of systematic effects to be added to unc.vals/conf 
        make_shapes(folder, variable, output_dir, [rebin=1, preprocess=None) --> unc_conf_lines (list), unc_vals_lines (list)
        '''
        output_dir.cd()
        path = os.path.join(folder,variable)

        # Draw data
        data_view = self.get_view('data')
        if preprocess:
            data_view = preprocess( data_view )
        data_view = self.rebin_view(data_view, rebin)

        data = data_view.Get(path)
       
        if last : data=change_histo_nbins(data, 0, last)
        first_filled, last_filled = find_fill_range(data)
        data.SetName('data_obs')
        data.Write()
        mc_views_nosys = self.mc_views(rebin, preprocess)
        
        mc_subt_view=[]
        ##for view in mc_views_nosys:
        ##    new = SubtractionView(view,
        ##                          views.SubdirectoryView(view, 'tLoose'),
        ##                          restrict_positive=True)
        ##    
        ##    mc_subt_view.append(new)
        
        print self.mc_samples, self.datacard_names
        #make MC views with xsec error
        bkg_views  = dict(
            [(self.datacard_names[i], j) for i, j in zip(self.mc_samples,  mc_views_nosys)]
        )
        bkg_histos = {}
        for name, view in bkg_views.iteritems():
            if DEBUG : print name, path
            mc_histo = view.Get(path)
            if DEBUG : print name, path
            if last : mc_histo = change_histo_nbins(mc_histo, 0, last)
            if DEBUG : print name, path
            first_filled_bkg, last_filled_bkg= find_fill_range(mc_histo)
            if DEBUG : print name, path
            bkg_histos[name] = mc_histo.Clone()
            mc_histo.SetName(name)
            if DEBUG : print name, mc_histo.GetName()
            mc_histo.Write()

        if self.use_embedded:            
            view = self.get_view('ZetauEmbedded')
            if preprocess:
                view = preprocess(view)
            view = self.rebin_view(view, rebin)
            name = self.datacard_names['ZetauEmbedded']
            bkg_views[name] = view
            mc_histo = view.Get(path)
            if last : mc_histo = change_histo_nbins(mc_histo, 0, last)
            first_filled_bkg, last_filled_bkg= find_fill_range(mc_histo)
            bkg_histos[name] = mc_histo.Clone()
            ##mc_histo = remove_empty_bins(
            ##    mc_histo, weight,
            ##    first_filled_bkg, last_filled_bkg)
            mc_histo.SetName(name)
            mc_histo.Write()
          

        #Get signal
        signals = [
            'GluGlu_LFV_HToETau_M200*',
            'GluGlu_LFV_HToETau_M450*',
            'GluGlu_LFV_HToETau_M600*',
            'GluGlu_LFV_HToETau_M750*',
            'GluGlu_LFV_HToETau_M900*'#'ggM300ETau', 'ggM450ETau', 'ggM600ETau', 'ggM750ETau', 'ggM900ETau'
        ]
        for name in signals:
            sig_view = self.get_view(name)
            card_name = self.datacard_names[name]
            if preprocess:
                sig_view = preprocess(sig_view)
            sig_view = views.ScaleView(
                RebinView(sig_view, rebin),
                br_strenght
                )
            ##weights = self.get_view(name, 'weight')
            bkg_views[card_name] = sig_view
            ##bkg_weights[card_name] = weights
            histogram = sig_view.Get(path)
            if last : histogram = change_histo_nbins(histogram, 0, last)
            bkg_histos[card_name] = histogram.Clone()
            first_filled_bkg, last_filled_bkg = find_fill_range(bkg_histos[card_name])
            ##histogram = remove_empty_bins(
            ##    histogram, bkg_weights[card_name],
            ##    first_filled_bkg, last_filled_bkg)
            histogram.SetName(card_name)
            histogram.Write()
            if DEBUG : print name, histogram.GetName()

  
        unc_conf_lines = []
        unc_vals_lines = []
        category_name  = output_dir.GetName()
        for unc_name, info in self.systematics.iteritems():
            targets = []
            print info['apply_to']
            for target in info['apply_to']:
                if target in self.sample_groups:
                    targets.extend(self.sample_groups[target])
                else:
                    targets.append(target)

            shift = 0.
            path_up = info['+'](path)
            path_dw = info['-'](path)
            for target in targets:
                print target
                up      = bkg_views[target].Get(
                    path_up
                )
                down    = bkg_views[target].Get(
                    path_dw
                )
                if info['type'] == 'yield':
                    central = bkg_histos[target]
                    integral = central.Integral()
                    integral_up = up.Integral()
                    integral_down = down.Integral()
                    if integral == 0  and integral_up == 0 and integral_down ==0 :
                        shift=shift
                    else:
                        shift = max(
                            shift,
                            (integral_up - integral) / integral,
                            (integral - integral_down) / integral
                        )
                elif info['type'] == 'shape':
                    #remove empty bins also for shapes 
                    #(but not in general to not spoil the stat uncertainties)
                    #up = remove_empty_bins(up, bkg_weights[target])
                    #down = remove_empty_bins(down, bkg_weights[target])
                    up.SetName('%s_%sUp' % (target, unc_name))
                    down.SetName('%s_%sDown' % (target, unc_name))
                    up.Write()
                    down.Write()
                elif info['type'] == 'stat':
                    nbins = up.GetNbinsX()
                    up.Rebin(nbins)
                    yield_val = up.GetBinContent(1)
                    yield_err = up.GetBinError(1)
                    #print target, yield_val, yield_err, 
                    if yield_val==0:
                        unc_value = 0.
                    else:
                        unc_value = 1. + (yield_err / yield_val)
                    #stat_unc_name = '%s_%s_%s' % (target, category_name, unc_name)
                    #unc_conf_lines.append('%s %s' % (stat_unc_name, unc_conf))
                    #unc_vals_lines.append(
                    #    '%s %s %s %.2f' % (category_name, target, stat_unc_name, unc_value)
                    #)
                else:
                    raise ValueError('systematic uncertainty type:"%s" not recognised!' % info['type'])

        fakes_view = self.get_view('fakes') 
        d_view = self.get_view('data')
        ##weights_view = views.SumView(
        ##    views.SubdirectoryView(d_view, 'tLoose'),
        ##    #views.SubdirectoryView(d_view, 'eLoose'),
        ##    #views.SubdirectoryView(d_view, 'etLoose')
        ##    )
        if preprocess:
            fakes_view = preprocess(fakes_view)    
            ##weights_view = preprocess(weights_view)
        ##weights = weights_view.Get(os.path.join(folder,'weight'))
        #print folder
        fakes_view = self.rebin_view(fakes_view, rebin)
        bkg_views['fakes'] = fakes_view
        ##bkg_weights['fakes'] = mean(weights)
        fake_shape = bkg_views['fakes'].Get(path)
        if last : fake_shape = change_histo_nbins(fake_shape, 0, last)
        bkg_histos['fakes'] = fake_shape.Clone()
        if last : bkg_histos['fakes'] =change_histo_nbins(bkg_histos['fakes'] , 0, last)
        first_filled_bkg, last_filled_bkg = find_fill_range(bkg_histos['fakes'])
        ##fake_shape = remove_empty_bins(
        ##    fake_shape, bkg_weights['fakes'],
        ##    first_filled_bkg, last_filled_bkg)
        fake_shape.SetName('fakes')
        fake_shape.Write()
        if DEBUG : print 'fakes', fake_shape.GetName()

        return unc_conf_lines, unc_vals_lines
    
 
