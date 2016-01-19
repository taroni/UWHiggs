
# Tools to compile cython proxy class
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(ext_modules=[Extension(
    "EEETree",                 # name of extension
    ["EEETree.pyx"], #  our Cython source
    include_dirs=['/cvmfs/cms.cern.ch/slc6_amd64_gcc491/cms/cmssw/CMSSW_7_4_14/external/slc6_amd64_gcc491/bin/../../../../../../lcg/root/6.02.00-odfocd7/include'],
    library_dirs=['/cvmfs/cms.cern.ch/slc6_amd64_gcc491/cms/cmssw/CMSSW_7_4_14/external/slc6_amd64_gcc491/bin/../../../../../../lcg/root/6.02.00-odfocd7/lib'],
    libraries=['Tree', 'Core', 'TreePlayer'],
    language="c++", 
    #extra_compile_args=['-std=c++11'])],  # causes Cython to create C++ source
    extra_compile_args=['-std=c++11', '-fno-var-tracking-assignments'])],
    cmdclass={'build_ext': build_ext})
