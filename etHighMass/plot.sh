#!/bin/bash

source ../../FinalStateAnalysis/environment.sh

#to plot all together#
#python fastPlotETau.py -s "os ss" -m "" -m "LowMass HighMass" -j "le1 0 1" 

python fastPlotETau.py -s "os" -m "" -j "le1 0 1"
python fastPlotETau.py -s "os" -m "LowMass" -j "le1 0 1"
python fastPlotETau.py -s "os" -m "HighMass" -j "le1 0 1"
python fastPlotETau.py -s "ss" -m "" -j "le1 0 1"
python fastPlotETau.py -s "ss" -m "LowMass" -j "le1 0 1"
python fastPlotETau.py -s "ss" -m "HighMass" -j "le1 0 1"
