python getQCD.py
cp QCD.root results/Oc*/LFVHEMuAnalyzerMVA_esffixed/
cp -r results/Oc*/LFVHEMuAnalyzerMVA_esffixed .
cp move.sh LFVHEMuAnalyzerMVA_esffixed/
cd LFVHEMuAnalyzerMVA_esffixed/
source move.sh
rm move.sh
cd -
python GetFakes.py
cp QCD.root results/Oc*/LFVHEMuAnalyzerMVA_esffixed/
cp FAKES.root LFVHEMuAnalyzerMVA_esffixed/
cp -r LFVHEMuAnalyzerMVA_esffixed/ LFVHEMuAnalyzerMVA_esffixed_plot/
