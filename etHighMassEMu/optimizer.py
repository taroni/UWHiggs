 #author Mauro Verzetti
'small interface module to deal with optimizization'

import os
import itertools

#RUN_OPTIMIZATION = ('RUN_OPTIMIZATION' in os.environ) and eval(os.environ['RUN_OPTIMIZATION'])
RUN_OPTIMIZATION = True

_le1= {
   'eMtToPfMet_type1'  : [50, 75, 100., 125],
   'e_t_DPhi'          : [2.25, 2.5, 2.75],
   'eDPhiToPfMet_type1': [1.5, 2., 2.25, 2.5],
   'tDPhiToPfMet_type1': [0.75, 1., 1.25, 1.5]
}
_le1_default = {
   'eMtToPfMet_type1'  : 0,
   'e_t_DPhi'          : 0,
   'eDPhiToPfMet_type1': 0,
   'tDPhiToPfMet_type1': 4
}
_le1_region_templates = ['eMtToPfMet_type1_%i', 'e_t_DPhi_%.2f', 'eDPhiToPfMet_type1_%.2f', 'tDPhiToPfMet_type1_%.2f']
def _get_le1_regions(eMtToPfMet_type1, e_t_DPhi, eDPhiToPfMet_type1, tDPhiToPfMet_type1):
   pass_eMt        = [i for i in _le1['eMtToPfMet_type1'  ] if eMtToPfMet_type1   > i] 
   pass_e_t_DPhi   = [i for i in _le1['e_t_DPhi'          ] if e_t_DPhi           > i] 
   pass_eMetDPhi   = [i for i in _le1['eDPhiToPfMet_type1'] if eDPhiToPfMet_type1 > i] 
   pass_tMetDPhi   = [i for i in _le1['tDPhiToPfMet_type1'] if tDPhiToPfMet_type1 < i] 

   cuts = [pass_eMt, pass_e_t_DPhi, pass_eMetDPhi, pass_tMetDPhi]
   pass_default_eMt        = eMtToPfMet_type1   > _le1_default['eMtToPfMet_type1'  ] 
   pass_default_e_t_DPhi   = e_t_DPhi           > _le1_default['e_t_DPhi'          ] 
   pass_default_eMetDPhi   = eDPhiToPfMet_type1 > _le1_default['eDPhiToPfMet_type1']
   pass_default_tMetDPhi   = tDPhiToPfMet_type1 < _le1_default['tDPhiToPfMet_type1']

   defaults = [pass_default_eMt, pass_default_e_t_DPhi, pass_default_eMetDPhi, pass_default_tMetDPhi]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if any(j for i,j in enumerate(defaults) if i != cut_idx):
          #print 'le1', cut_idx, opts, cuts, defaults
          ret.extend([_le1_region_templates[cut_idx] % i for i in opts])
      
   #print ret
   return ret
##########
_0jets= {
   'eMtToPfMet_type1'  : [50, 75, 100., 125],
   'e_t_DPhi'          : [2.25, 2.5, 2.75],
   'eDPhiToPfMet_type1': [1.5, 2., 2.25, 2.5],
   'tDPhiToPfMet_type1': [0.75, 1., 1.25, 1.5]
}
_0jets_default = {
   'eMtToPfMet_type1'  : 0,
   'e_t_DPhi'          : 0,
   'eDPhiToPfMet_type1': 0,
   'tDPhiToPfMet_type1': 4
}
_0jet_region_templates = ['eMtToPfMet_type1_%i', 'e_t_DPhi_%.2f', 'eDPhiToPfMet_type1_%.2f', 'tDPhiToPfMet_type1_%.2f']

def _get_0jet_regions(eMtToPfMet_type1, e_t_DPhi, eDPhiToPfMet_type1, tDPhiToPfMet_type1):
   pass_eMt        = [i for i in _0jets['eMtToPfMet_type1'  ] if eMtToPfMet_type1   > i] 
   pass_e_t_DPhi   = [i for i in _0jets['e_t_DPhi'          ] if e_t_DPhi           > i] 
   pass_eMetDPhi   = [i for i in _0jets['eDPhiToPfMet_type1'] if eDPhiToPfMet_type1 > i] 
   pass_tMetDPhi   = [i for i in _0jets['tDPhiToPfMet_type1'] if tDPhiToPfMet_type1 < i] 

   cuts = [pass_eMt, pass_e_t_DPhi, pass_eMetDPhi, pass_tMetDPhi]
   pass_default_eMt        = eMtToPfMet_type1   > _0jets_default['eMtToPfMet_type1'  ] 
   pass_default_e_t_DPhi   = e_t_DPhi           > _0jets_default['e_t_DPhi'          ] 
   pass_default_eMetDPhi   = eDPhiToPfMet_type1 > _0jets_default['eDPhiToPfMet_type1']
   pass_default_tMetDPhi   = tDPhiToPfMet_type1 < _0jets_default['tDPhiToPfMet_type1']

   defaults = [pass_default_eMt, pass_default_e_t_DPhi, pass_default_eMetDPhi, pass_default_tMetDPhi]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if any(j for i,j in enumerate(defaults) if i != cut_idx):
          #print '0 jet', cut_idx, opts
          ret.extend([_0jet_region_templates[cut_idx] % i for i in opts])
   #print '0jet', ret
   return ret
#####
_1jets= {
   'eMtToPfMet_type1'  : [50, 75, 100., 125],
   'e_t_DPhi'          : [2.25, 2.5, 2.75],
   'eDPhiToPfMet_type1': [1.5, 2., 2.25, 2.5],
   'tDPhiToPfMet_type1': [0.75, 1., 1.25, 1.5]
}
_1jets_default = {
   'eMtToPfMet_type1'  : 0,
   'e_t_DPhi'          : 0,
   'eDPhiToPfMet_type1': 0,
   'tDPhiToPfMet_type1': 4
}
_1jet_region_templates = ['eMtToPfMet_type1_%i', 'e_t_DPhi_%.2f', 'eDPhiToPfMet_type1_%.2f', 'tDPhiToPfMet_type1_%.2f']
def _get_1jet_regions(eMtToPfMet_type1, e_t_DPhi, eDPhiToPfMet_type1, tDPhiToPfMet_type1):
   pass_eMt        = [i for i in _1jets['eMtToPfMet_type1'  ] if eMtToPfMet_type1   > i] 
   pass_e_t_DPhi   = [i for i in _1jets['e_t_DPhi'          ] if e_t_DPhi           > i] 
   pass_eMetDPhi   = [i for i in _1jets['eDPhiToPfMet_type1'] if eDPhiToPfMet_type1 > i] 
   pass_tMetDPhi   = [i for i in _1jets['tDPhiToPfMet_type1'] if tDPhiToPfMet_type1 < i] 

   cuts = [pass_eMt, pass_e_t_DPhi, pass_eMetDPhi, pass_tMetDPhi]
   pass_default_eMt        = eMtToPfMet_type1   > _1jets_default['eMtToPfMet_type1'  ] 
   pass_default_e_t_DPhi   = e_t_DPhi           > _1jets_default['e_t_DPhi'          ] 
   pass_default_eMetDPhi   = eDPhiToPfMet_type1 > _1jets_default['eDPhiToPfMet_type1']
   pass_default_tMetDPhi   = tDPhiToPfMet_type1 < _1jets_default['tDPhiToPfMet_type1']

   defaults = [pass_default_eMt, pass_default_e_t_DPhi, pass_default_eMetDPhi, pass_default_tMetDPhi]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if any(j for i,j in enumerate(defaults) if i != cut_idx):
           ret.extend([_1jet_region_templates[cut_idx] % i for i in opts])
          
   return ret
###

_em_le1= {
   'eMtToPfMet_type1'  : [50, 75, 100., 125],
   'e_m_DPhi'          : [2., 2.2, 2.5],
   'eDPhiToPfMet_type1': [1.5, 2., 2.25, 2.5],
   'mDPhiToPfMet_type1': [0.3, 0.5, 0.7, 0.9]
}
_em_le1_default = {
   'eMtToPfMet_type1'  : 0,
   'e_m_DPhi'          : 0,
   'eDPhiToPfMet_type1': 0,
   'mDPhiToPfMet_type1': 4
}
_em_le1_region_templates = ['eMtToPfMet_type1_%i', 'e_m_DPhi_%.2f', 'eDPhiToPfMet_type1_%.2f', 'mDPhiToPfMet_type1_%.2f']
def _get_em_le1_regions(eMtToPfMet_type1, e_m_DPhi, eDPhiToPfMet_type1, mDPhiToPfMet_type1):
   pass_eMt        = [i for i in _em_le1['eMtToPfMet_type1'  ] if eMtToPfMet_type1   > i] 
   pass_e_m_DPhi   = [i for i in _em_le1['e_m_DPhi'          ] if e_m_DPhi           > i] 
   pass_eMetDPhi   = [i for i in _em_le1['eDPhiToPfMet_type1'] if eDPhiToPfMet_type1 > i] 
   pass_mMetDPhi   = [i for i in _em_le1['mDPhiToPfMet_type1'] if mDPhiToPfMet_type1 < i] 

   cuts = [pass_eMt, pass_e_m_DPhi, pass_eMetDPhi, pass_mMetDPhi]
   pass_default_eMt        = eMtToPfMet_type1   > _em_le1_default['eMtToPfMet_type1'  ] 
   pass_default_e_m_DPhi   = e_m_DPhi           > _em_le1_default['e_m_DPhi'          ] 
   pass_default_eMetDPhi   = eDPhiToPfMet_type1 > _em_le1_default['eDPhiToPfMet_type1']
   pass_default_mMetDPhi   = mDPhiToPfMet_type1 < _em_le1_default['mDPhiToPfMet_type1']

   defaults = [pass_default_eMt, pass_default_e_m_DPhi, pass_default_eMetDPhi, pass_default_mMetDPhi]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if any(j for i,j in enumerate(defaults) if i != cut_idx):
          ret.extend([_em_le1_region_templates[cut_idx] % i for i in opts])
      
   return ret

_em_0jets= {
   'eMtToPfMet_type1'  : [50, 75, 100., 125],
   'e_m_DPhi'          : [2., 2.2, 2.5],
   'eDPhiToPfMet_type1': [1.5, 2., 2.25, 2.5],
   'mDPhiToPfMet_type1': [0.3, 0.5, 0.7, 0.9]
}
_em_0jets_default = {
   'eMtToPfMet_type1'  : 0,
   'e_m_DPhi'          : 0,
   'eDPhiToPfMet_type1': 0,
   'mDPhiToPfMet_type1': 4
}
_em_0jet_region_templates = ['eMtToPfMet_type1_%i', 'e_m_DPhi_%.2f', 'eDPhiToPfMet_type1_%.2f', 'mDPhiToPfMet_type1_%.2f']

def _get_em_0jet_regions(eMtToPfMet_type1, e_t_DPhi, eDPhiToPfMet_type1, tDPhiToPfMet_type1):
   pass_eMt        = [i for i in _em_0jets['eMtToPfMet_type1'  ] if eMtToPfMet_type1   > i] 
   pass_e_m_DPhi   = [i for i in _em_0jets['e_m_DPhi'          ] if e_m_DPhi           > i] 
   pass_eMetDPhi   = [i for i in _em_0jets['eDPhiToPfMet_type1'] if eDPhiToPfMet_type1 > i] 
   pass_mMetDPhi   = [i for i in _em_0jets['mDPhiToPfMet_type1'] if mDPhiToPfMet_type1 < i] 

   cuts = [pass_eMt, pass_e_m_DPhi, pass_eMetDPhi, pass_mMetDPhi]
   pass_default_eMt        = eMtToPfMet_type1   > _em_0jets_default['eMtToPfMet_type1'  ] 
   pass_default_e_m_DPhi   = e_m_DPhi           > _em_0jets_default['e_m_DPhi'          ] 
   pass_default_eMetDPhi   = eDPhiToPfMet_type1 > _em_0jets_default['eDPhiToPfMet_type1']
   pass_default_mMetDPhi   = mDPhiToPfMet_type1 < _em_0jets_default['mDPhiToPfMet_type1']

   defaults = [pass_default_eMt, pass_default_e_m_DPhi, pass_default_eMetDPhi, pass_default_mMetDPhi]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if any(j for i,j in enumerate(defaults) if i != cut_idx):
          ret.extend([_em_0jet_region_templates[cut_idx] % i for i in opts])
   return ret

_em_1jets= {
   'eMtToPfMet_type1'  : [50, 75, 100., 125],
   'e_m_DPhi'          : [2., 2.2, 2.5],
   'eDPhiToPfMet_type1': [1.5, 2., 2.25, 2.5],
   'mDPhiToPfMet_type1': [0.3, 0.5, 0.7, 0.9]
}
_em_1jets_default = {
   'eMtToPfMet_type1'  : 0,
   'e_m_DPhi'          : 0,
   'eDPhiToPfMet_type1': 0,
   'mDPhiToPfMet_type1': 4
}
_em_1jet_region_templates = ['eMtToPfMet_type1_%i', 'e_m_DPhi_%.2f', 'eDPhiToPfMet_type1_%.2f', 'mDPhiToPfMet_type1_%.2f']
def _get_em_1jet_regions(eMtToPfMet_type1, e_m_DPhi, eDPhiToPfMet_type1, mDPhiToPfMet_type1):
   pass_eMt        = [i for i in _em_1jets['eMtToPfMet_type1'  ] if eMtToPfMet_type1   > i] 
   pass_e_m_DPhi   = [i for i in _em_1jets['e_m_DPhi'          ] if e_m_DPhi           > i] 
   pass_eMetDPhi   = [i for i in _em_1jets['eDPhiToPfMet_type1'] if eDPhiToPfMet_type1 > i] 
   pass_mMetDPhi   = [i for i in _em_1jets['mDPhiToPfMet_type1'] if mDPhiToPfMet_type1 < i] 

   cuts = [pass_eMt, pass_e_m_DPhi, pass_eMetDPhi, pass_mMetDPhi]
   pass_default_eMt        = eMtToPfMet_type1   > _em_1jets_default['eMtToPfMet_type1'  ] 
   pass_default_e_m_DPhi   = e_t_DPhi           > _em_1jets_default['e_m_DPhi'          ] 
   pass_default_eMetDPhi   = eDPhiToPfMet_type1 > _em_1jets_default['eDPhiToPfMet_type1']
   pass_default_mMetDPhi   = tDPhiToPfMet_type1 < _em_1jets_default['mDPhiToPfMet_type1']

   defaults = [pass_default_eMt, pass_default_e_m_DPhi, pass_default_eMetDPhi, pass_default_mMetDPhi]
   ret = []
   for cut_idx, opts in enumerate(cuts):
       if any(j for i,j in enumerate(defaults) if i != cut_idx):
           ret.extend([_em_1jet_region_templates[cut_idx] % i for i in opts])
          
   return ret

def empty(*args):
    return []

compute_regions_le1  = _get_le1_regions if RUN_OPTIMIZATION else empty
compute_regions_0jet = _get_0jet_regions if RUN_OPTIMIZATION else empty
compute_regions_1jet = _get_1jet_regions if RUN_OPTIMIZATION else empty
compute_regions_em_le1 = _get_em_le1_regions if RUN_OPTIMIZATION else empty
compute_regions_em_0jet = _get_em_0jet_regions if RUN_OPTIMIZATION else empty
compute_regions_em_1jet = _get_em_1jet_regions if RUN_OPTIMIZATION else empty

##

cutsle1 = [ _le1['eMtToPfMet_type1'  ],
            _le1['e_t_DPhi'          ],
            _le1['eDPhiToPfMet_type1'],
            _le1['tDPhiToPfMet_type1']]
ret0 = []
defaults = [_le1_default['eMtToPfMet_type1'  ],
            _le1_default['e_t_DPhi'          ],
            _le1_default['eDPhiToPfMet_type1'],
            _le1_default['tDPhiToPfMet_type1']]


cuts0 = [_0jets['eMtToPfMet_type1'  ],
         _0jets['e_t_DPhi'          ],
         _0jets['eDPhiToPfMet_type1'],
         _0jets['tDPhiToPfMet_type1']
]
cuts1 = [_1jets['eMtToPfMet_type1'  ],
         _1jets['e_t_DPhi'          ],
         _1jets['eDPhiToPfMet_type1'],
         _1jets['tDPhiToPfMet_type1']
]
em_cutsle1 = [ _em_le1['eMtToPfMet_type1'  ],
               _em_le1['e_m_DPhi'          ],
               _em_le1['eDPhiToPfMet_type1'],
               _em_le1['mDPhiToPfMet_type1']]
em_cuts0 = [_em_0jets['eMtToPfMet_type1'  ],
            _em_0jets['e_m_DPhi'          ],
            _em_0jets['eDPhiToPfMet_type1'],
            _em_0jets['mDPhiToPfMet_type1']]
em_cuts1 = [_em_1jets['eMtToPfMet_type1'  ],
            _em_1jets['e_m_DPhi'          ],
            _em_1jets['eDPhiToPfMet_type1'],
            _em_1jets['mDPhiToPfMet_type1']
            ]
for cut_idx, opts in enumerate(cuts0):
    if any(j for i,j in enumerate(defaults) if i != cut_idx):
        ret0.extend([_0jet_region_templates[cut_idx] % i for i in opts])
        
regions = {'le1': [], '0' : [], '1' : []}

if RUN_OPTIMIZATION:

    regions = {
       'le1': [_le1_region_templates[cut_idx] % i for cut_idx, opts in enumerate(cutsle1) for i in opts],
       '0' : [_0jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(cuts0) for i in opts],
       '1' : [_1jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(cuts1) for i in opts],
#       'le1/HighMass': [_le1_region_templates[cut_idx] % i for cut_idx, opts in enumerate(cutsle1) for i in opts],
#       '0/HighMass' : [_0jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(cuts0) for i in opts],
#       '1/HighMass' : [_1jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(cuts1) for i in opts],
    }
    #print 'regions', regions
    em_regions = {
       'le1': [_em_le1_region_templates[cut_idx] % i for cut_idx, opts in enumerate(cutsle1) for i in opts],
        '0' : [_em_0jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(em_cuts0) for i in opts],
        '1' : [_em_1jet_region_templates[cut_idx] % i  for cut_idx, opts in enumerate(em_cuts1) for i in opts],
    }
    
    #print regions['0']
    
if __name__ == "__main__":
    from pdb import set_trace
    set_trace()
    #print '\n'.join(grid_search.keys())
else:
    print "Running optimization: %s" % RUN_OPTIMIZATION
