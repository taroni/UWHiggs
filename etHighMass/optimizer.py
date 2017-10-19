 #author Mauro Verzetti
'small interface module to deal with optimizization'

import os
import itertools

#RUN_OPTIMIZATION = ('RUN_OPTIMIZATION' in os.environ) and eval(os.environ['RUN_OPTIMIZATION'])
RUN_OPTIMIZATION = True

_0jets = {
   'tPt'  : [30], #range(20,50,5),
   'ePt'  : [30], #range(25,50,5),
}
_0jets_default = {
   'tPt' : 20,
   'ePt' : 20,
}
_0jet_region_templates = ['tPt%i', 'ePt%i']
def _get_0jet_regions(tPt, ePt):
   pass_tPt        = [i for i in _0jets['tPt'       ] if tPt        > i] 
   pass_ePt        = [i for i in _0jets['ePt'       ] if ePt        > i] 

   cuts = [pass_tPt,pass_ePt]
   pass_default_tPt        = tPt        > _0jets_default['tPt'       ] 
   pass_default_ePt        = ePt        > _0jets_default['ePt'       ] 

   defaults = [pass_default_tPt, pass_default_ePt]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if all(j for i,j in enumerate(defaults) if i != cut_idx):
           ret.extend([_0jet_region_templates[cut_idx] % i for i in opts])
          
   return ret

_1jets = {
    'tPt'  : [25], #range(25,50,5),
    'ePt'  : [25], #range(25,50,5),
}
_1jets_default = {
    'tPt' : 0,
    'ePt' : 0,
}
_1jet_region_templates = ['tPt%i', 'ePt%i']#,  'tMtToPfMet%i']#'tPt%i_ePt%i_tMtToPfMet%i'
def _get_1jet_regions(tPt, ePt):
   pass_tPt        = [i for i in _1jets['tPt'       ] if tPt        > i] 
   pass_ePt        = [i for i in _1jets['ePt'       ] if ePt        > i] 

   cuts = [pass_tPt, pass_ePt]
   pass_default_tPt        = tPt        > _1jets_default['tPt'       ] 
   pass_default_ePt        = ePt        > _1jets_default['ePt'       ] 

   defaults = [pass_default_tPt, pass_default_ePt]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if all(j for i,j in enumerate(defaults) if i != cut_idx):
           ret.extend([_1jet_region_templates[cut_idx] % i for i in opts])
           
   return ret
   
def empty(*args):
    return []

compute_regions_0jet = _get_0jet_regions if RUN_OPTIMIZATION else empty
compute_regions_1jet = _get_1jet_regions if RUN_OPTIMIZATION else empty

##
ret0 = []
defaults = [_0jets_default['tPt'], _0jets_default['ePt']]
cuts0 = [_0jets['tPt'], _0jets['ePt']]
cuts1 = [_1jets['tPt'], _1jets['ePt']]

for cut_idx, opts in enumerate(cuts0):
    if all(j for i,j in enumerate(defaults) if i != cut_idx):
        ret0.extend([_0jet_region_templates[cut_idx] % i for i in opts])
        
regions = {'0' : [], '1' : []}

if RUN_OPTIMIZATION:

    regions = {
        '0' : [_0jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(cuts0) for i in opts],#itertools.product(_0jets['tPt'], _0jets['ePt'], _0jets['dphi'], _0jets['tMtToPfMet'])],
        '1' : [_1jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(cuts1) for i in opts],#[_1jet_region_template % i for i in itertools.product(_1jets['tPt'], _1jets['ePt'], _1jets['tMtToPfMet'])],
    }
    
    print regions['0']
    
if __name__ == "__main__":
    from pdb import set_trace
    set_trace()
    #print '\n'.join(grid_search.keys())
else:
    print "Running optimization: %s" % RUN_OPTIMIZATION
