cp results/LFV_8013v1/LFVHEMuAnalyzerMVA/data*  results/LFV_808v1/LFVHEMuAnalyzerMVA/ 
cp -r results/LFV_808v1/LFVHEMuAnalyzerMVA .
cp move.sh LFVHEMuAnalyzerMVA/
cd LFVHEMuAnalyzerMVA
source move.sh
rm move.sh
cd -
