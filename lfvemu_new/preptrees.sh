hadd -f BackgroundTree.root results/SMHTT_aug16_v2/LFVHEMuAnalyzerMVA_makeBDTtrees/*HToTau*   results/SMHTT_aug16_v2/LFVHEMuAnalyzerMVA_makeBDTtrees/*TuneCUETP8M1*
hadd -f SignalTree.root results/SMHTT_aug16_v2/LFVHEMuAnalyzerMVA_makeBDTtrees/*LFV*
hadd -f trainingTree.root BackgroundTree.root SignalTree.root
