python getQCDvertex20.py
cp QCD.root results/Oct30/LFVHEMuAnalyzerMVA_vertices/
cp -r results/Oct30/LFVHEMuAnalyzerMVA_vertices LFVHEMuAnalyzerMVA_vertices20/
cp move20.sh LFVHEMuAnalyzerMVA_vertices20/
cd LFVHEMuAnalyzerMVA_vertices20/
source move20.sh
rm move20.sh
cd -
python GetFakesVertex20.py
cp FAKES.root LFVHEMuAnalyzerMVA_vertices20/
cp -r LFVHEMuAnalyzerMVA_vertices20/ LFVHEMuAnalyzerMVA_vertices_plot20/
source jobid.sh