cp results/LFV_8013v1/div_2j_LFVHEMuAnalyzerMVA/data*  results/LFV_808v1/div_2j_LFVHEMuAnalyzerMVA/
cp -r results/LFV_808v1/div_2j_LFVHEMuAnalyzerMVA .
cp move.sh div_2j_LFVHEMuAnalyzerMVA/
cd div_2j_LFVHEMuAnalyzerMVA
source move.sh
rm move.sh
cd -
