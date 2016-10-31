
# Tools to compile cython proxy class
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(ext_modules=[Extension(
    "EEETree",                 # name of extension
    ["EEETree.pyx"], #  our Cython source
    include_dirs=['/cvmfs/cms.cern.ch/slc6_amd64_gcc493/cms/cmssw/CMSSW_7_6_3/external/slc6_amd64_gcc493/bin/../../../../../../lcg/root/6.02.12-kpegke4/include'],
    library_dirs=['/cvmfs/cms.cern.ch/slc6_amd64_gcc493/cms/cmssw/CMSSW_7_6_3/external/slc6_amd64_gcc493/bin/../../../../../../lcg/root/6.02.12-kpegke4/lib'],
    libraries=['Tree', 'Core', 'TreePlayer'],
    language="c++", 
    extra_compile_args=['-std=c++11', '-fno-var-tracking-assignments'])],  # causes Cython to create C++ source
    cmdclass={'build_ext': build_ext})
