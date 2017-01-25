import os
import ROOT
import array

import pdb

ROOT.gROOT.SetBatch(1)
canvas=ROOT.TCanvas()
leg = ROOT.TLegend (0.7,0.2,1, 0.1)
leg.SetFillColor(0)

#pdb.set_trace()
for file in os.listdir("results/LFVtrilepton_oct31/mmefakerate_fits/"):
    if file.endswith("corrected_inputs.root"):
        if '_vs_' in file:
            if not ( 'eVLoose_eVTight' in file or  'eSuperLoose_eVTight' in file): continue
            filepath='results/LFVtrilepton_oct31/mmefakerate_fits/'+file
            myFF = ROOT.TFile.Open(filepath)
            num = myFF.Get("numerator")
            den = myFF.Get("denominator")
            eff = ROOT.TEfficiency(num, den)
            eff.SetName('efficiency')
            
            outfile=ROOT.TFile(filepath.replace(".corrected_inputs.root","_canvas.root"),"RECREATE")
            outfile.cd()
            eff.Write()

            for ibin in range(1, num.GetYaxis().GetNbins()+1):
                print ibin
                name = 'num_barrel%s' %str(ibin) if ibin==1 else 'num_endcap%s' %str(ibin)
                print name
                num1d = num.ProjectionX(name, ibin, ibin).Clone()
                binarray = array.array('d',[0, 10, 20, 30, 40, 50, 70, 100, 200 ])
                num1d= num1d.Rebin(8, num1d.GetName(), binarray)
                num1d.Draw()
                den1d = den.ProjectionX(name.replace('num', 'den'), ibin, ibin).Clone()
                den1d = den1d.Rebin(8,den1d.GetName(), binarray)
                #print den1d.GetXaxis().GetNbins()
                den1d.Draw()
                eff1d = ROOT.TEfficiency(num1d, den1d)
                eff.SetName(name.replace('num', 'eff_'))
                canvas.Clear()
                canvas.cd()
                #eff1d.Write()
                eff1d.SetMarkerStyle(20)
                gr_eff= eff1d.CreateGraph()
                
                gr_eff.SetMinimum(0)
                gr_eff.SetMaximum(1)
                gr_eff.Draw("AP")
                gr_eff.GetXaxis().SetTitle("e p_{T}")
                gr_eff.GetYaxis().SetTitle("e fakerate")
                gr_eff.SetName(eff1d.GetName())
                gr_eff.Write()
                erf = ROOT.TF1("erfh", "[0]+[1]*TMath::Erf([2]*x-[3])", 0, 200)
                erf.SetParameters(0.5,0.3, .03, 3.)
                tanh = ROOT.TF1("tanh", "[0]+[1]*TMath::TanH([2]*x-[3])", 0, 200)
                #tanh.SetParameters(0.4,-0.3,-0.03, 1.5)
                tanh.SetParameters(0.5,-0.3,-0.04, 2.)
                tanh.SetParLimits(0, 0.1, 0.7)
                tanh.SetParLimits(1,-0.5, 0.5)
                tanh.SetParLimits(2,-0.01, 0.08)
                tanh.SetParLimits(3, -5., 5)
                pol1=ROOT.TF1("pol1", "pol1", 0, 200)
                #fitter = ROOT.TVirtualFitter()
                test = ROOT.TH1D("test","test",200,0,200);
                text = ROOT.TPaveText (0.7,1,1, 0.8,"blNDC")
                text.SetFillColor(0)
                if ibin==1:
                    leg.Clear()
                    if 'eVLoose_eVTight' in file :
                        gr_eff.Fit(erf,"SR", "", 20, 200)
                    else:
                        gr_eff.Fit(erf,"SR", "", 0, 200)
                    erf.SetName("funB")
                    ##for ipar in range(0,4):
                    ##    erf.Write()
                    ##    funUp=erf.Clone()
                    ##    funDw=erf.Clone()
                    ##    print ipar 
                    ##    nameUp='funUp%s' %(str(int(ipar)))
                    ##    nameDw='funDw%s' %(str(int(ipar)))
                    ##    funUp.SetName(nameUp)
                    ##    funDw.SetName(nameDw)
                    ##    print funUp.GetName(), erf.GetParameter(ipar), erf.GetParError(ipar), erf.GetParameter(ipar), erf.GetParError(ipar)
                    ##    funUp.SetParameter(ipar,erf.GetParameter(ipar)+erf.GetParError(ipar))
                    ##    funDw.SetParameter(ipar,erf.GetParameter(ipar)-erf.GetParError(ipar))
                    ##    funUp.SetLineColor(ipar+3)
                    ##    funDw.SetLineColor(ipar+3)
                    ##    funDw.SetLineStyle(2)
                    ##    print ipar, 'drawing function'
                    ##    funUp.Draw("SAME")
                    ##    funDw.Draw("SAME")
                    ##    h=funUp.GetHistogram().Clone()
                    ##    h.SetName(funUp.GetName())
                    ##    h.Write()
                    ##    hDw=funDw.GetHistogram().Clone()
                    ##    hDw.SetName(funDw.GetName())
                    ##    hDw.Write()
                    ##    labelP="par %s + errPar %s"  %(str(int(ipar)), str(int(ipar)))
                    ##    labelM="par %s - errPar %s"  %(str(int(ipar)), str(int(ipar)))
                    ##    leg.AddEntry(funUp, labelP, "l" )
                    ##    leg.AddEntry(funDw, labelM, "l" )

                    ##    print 'added legend label', labelP
                    #leg.Draw()
                        
                    fitter = ROOT.TVirtualFitter.GetFitter()
                    print 'fitter got'
                    fitter.GetConfidenceIntervals(test, 0.68);
                    test.Draw("SAMEE2")
                    test.SetName("testB")
                    test.Write()
                    test.SetFillColor(2)
                    test.SetFillStyle(3244)
                    if 'eVLoose_eVTight' in file :
                        gr_eff.GetXaxis().SetRangeUser(20.,200.)
                    else :
                        gr_eff.GetXaxis().SetRangeUser(0.,200.)
                    gr_eff.Draw("PSAME")
                    for ipar in range(0, 4):
                        text.AddText("par %s = %.3f #pm %.3f" %(str(int(ipar)), fitter.GetParameter(ipar) , fitter.GetParError(ipar)))
                    text.Draw("SAME")
                    print 'text drawn'
                    
                    canvas.Update()
                    canvas.SaveAs(filepath.replace(".corrected_inputs.root", "_effBarrel.png"))
                    canvas.SaveAs(filepath.replace(".corrected_inputs.root", "_effBarrel.pdf"))
                    canvas.SaveAs(filepath.replace(".corrected_inputs.root", "_effBarrel.root"))
                    print 'plots saved'

                else:
                    leg.Clear()
                    result = ROOT.TFitResult()
                    erf2=ROOT.TF1("erf2", "[0]", 10, 200)
                    if 'eVLoose_eVTight' in file :
                        if 'Met30' in file:
                            result=gr_eff.Fit(erf2, "SR", "", 10, 200).Get()
                        else:
                            #gr_eff.Fit(pol1, "SR", "", 20, 200)
                            erf2=ROOT.TF1("erf2", "[0]*(1-[1]*pow(e,([2]*x+[3])))", 10, 200)
                            erf2.SetParameters(0.5, 12 , -0.15, 0.5)
                            #tanh=ROOT.TF1("tanh", "[0]+[1]*TMath::TanH([2]*x+[3])", 0, 200)
                            #tanh.SetParameters(0.4,0.12,0.6, -22.)
                            result=gr_eff.Fit(erf2, "SR", "", 20, 200).Get()
                            

                    else :
                        erf2=ROOT.TF1("erf2", "[0]+[1]*x", 10, 200)
                        result=gr_eff.Fit(erf2, "SR", "", 10, 200).Get()
                    print 'fit result saved'
                    erf2.SetName("funE")
                    erf2.GetHistogram().Write()
                   ## for ipar in range(0,result.NPar()):
                   ##     print ipar, result.NPar()
                   ##     pars=result.GetParams()
                   ##     funEUp=erf2.Clone()
                   ##     funEDw=erf2.Clone()
                   ##     nameUp='funEUp%s' %(str(int(ipar)))
                   ##     nameDw='funEDw%s' %(str(int(ipar)))
                   ##     funEUp.SetName(nameUp)
                   ##     funEDw.SetName(nameDw)
                   ##     funEUp.SetParameter(ipar,erf2.GetParameter(ipar)+erf2.GetParError(ipar))
                   ##     funEDw.SetParameter(ipar,erf2.GetParameter(ipar)-erf2.GetParError(ipar))
                   ##     funEUp.SetLineColor(ipar+3)
                   ##     funEDw.SetLineColor(ipar+3)
                   ##     funEDw.SetLineStyle(2)
                   ##     funEUp.Draw("SAME")
                   ##     funEDw.Draw("SAME")
                   ##     hE=funEUp.GetHistogram().Clone()
                   ##     hE.SetName(funEUp.GetName())
                   ##     hE.Write()
                   ##     hEDw=funEDw.GetHistogram().Clone()
                   ##     hEDw.SetName(funEDw.GetName())
                   ##     hEDw.Write()
                   ##
                   ##     funEUp.GetHistogram().Write()
                   ##     funEDw.GetHistogram().Write()
                   ##     labelP="par %s + errPar %s"  %(str(int(ipar)), str(int(ipar)))
                   ##     labelM="par %s - errPar %s"  %(str(int(ipar)), str(int(ipar)))
                   ##     print funEUp.GetName(), funEDw.GetName(), labelP, labelM
                   ##
                   ##     leg.AddEntry(funEUp, labelP, "l" )
                   ##     leg.AddEntry(funEDw, labelM, "l" )

                    #leg.Draw()


                        
                    fitter = ROOT.TVirtualFitter.GetFitter()
                    fitter = ROOT.TVirtualFitter.GetFitter()

                    
                    fitter.GetConfidenceIntervals(test, 0.68);
                    test.Draw("SAMEE2")
                    test.SetName("testE")
                    test.Write()
                    
                    test.SetFillColor(2)
                    test.SetFillStyle(3244)
                    gr_eff.GetXaxis().SetRangeUser(0.,200.)
                    gr_eff.Draw("PSAME")
                    if 'eVLoose_eVTight' in file :
                        gr_eff.GetXaxis().SetRangeUser(10.,200.)
                    else :
                        gr_eff.GetXaxis().SetRangeUser(0.,200.)

                    for ipar in range(0, fitter.GetNumberFreeParameters()):
                        text.AddText("par %s = %.3f #pm %.3f" %(str(int(ipar)), fitter.GetParameter(ipar) , fitter.GetParError(ipar)))
                    text.Draw("SAME")
                    canvas.Update()
                    canvas.SaveAs(filepath.replace(".corrected_inputs.root", "_effEndcap.png"))
                    canvas.SaveAs(filepath.replace(".corrected_inputs.root", "_effEndcap.pdf"))
                    canvas.SaveAs(filepath.replace(".corrected_inputs.root", "_effEndcap.root"))
 
            
            outfile.Close()
            myFF.Close()

