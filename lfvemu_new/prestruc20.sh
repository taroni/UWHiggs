python getQCD20.py
cp QCD.root results/Oct30/LFVHEMuAnalyzerMVA_esffixed/
cp -r results/Oct30/LFVHEMuAnalyzerMVA_esffixed LFVHEMuAnalyzerMVA_esffixed20/
cp move20.sh LFVHEMuAnalyzerMVA_esffixed20/
cd LFVHEMuAnalyzerMVA_esffixed20/
source move20.sh
rm move20.sh
cd -
python GetFakes20.py
cp FAKES.root LFVHEMuAnalyzerMVA_esffixed20/
cp -r LFVHEMuAnalyzerMVA_esffixed20/ LFVHEMuAnalyzerMVA_esffixed_plot20/
