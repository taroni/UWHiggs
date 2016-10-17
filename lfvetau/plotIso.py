import ROOT

file0= ROOT.TFile.Open("/hdfs/store/user/taroni/LFV_sep16_v2/data_SingleMuon_Run2016E_PromptReco-v2_25ns/make_ntuples_cfg-081076B9-5A4D-E611-896E-FA163E30C29A.root")
t = file0.Get("mmt/final/Ntuple")
c1=ROOT.TCanvas("c1", "c1")
c1.SetLogy(1)
t.Draw("tByIsolationMVArun2v1DBoldDMwLTraw")

c1.SaveAs("tByIsolationMVArun2v1DBoldDMwLTraw.png")
#c1.SetLogy(0)
t.Draw("tByIsolationMVArun2v1DBoldDMwLTraw","tByVLooseIsolationMVArun2v1DBoldDMwLT==1", "SAMES")
#c1.SaveAs("tByIsolationMVArun2v1DBoldDMwLTraw_VLoose.png")
t.Draw("tByIsolationMVArun2v1DBoldDMwLTraw","tByLooseIsolationMVArun2v1DBoldDMwLT==1", "SAMES")
#c1.SaveAs("tByIsolationMVArun2v1DBoldDMwLTraw_Loose.png")
t.Draw("tByIsolationMVArun2v1DBoldDMwLTraw","tByTightIsolationMVArun2v1DBoldDMwLT==1", "SAMES")
#c1.SaveAs("tByIsolationMVArun2v1DBoldDMwLTraw_Tight.png")

c1.SaveAs("tByIsolationMVArun2v1DBoldDMwLTraw_WPs.root")



file0.Close()
