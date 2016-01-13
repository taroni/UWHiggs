import ROOT

infile = ROOT.TFile.Open("t_os_tLoose_tTigh_tDecayMode.corrected_inputs.root")

num = infile.Get("numerator")
den = infile.Get("denominator")

eff = ROOT.TEfficiency(num, den)

#eff.Draw()

eff0= eff.GetEfficiency(1)
eff1= eff.GetEfficiency(2)
eff10=eff.GetEfficiency(11)

eff0_up = eff.GetEfficiencyErrorUp(1) + eff0
eff1_up = eff.GetEfficiencyErrorUp(2) +  eff1
eff10_up = eff.GetEfficiencyErrorUp(11)+ eff10

eff0_dw = -1.*eff.GetEfficiencyErrorLow(1) + eff0
eff1_dw = -1.*eff.GetEfficiencyErrorLow(2)+  eff1
eff10_dw = -1.*eff.GetEfficiencyErrorLow(11)+ eff10

print  'def tau_fake_decayMode(decaymode): \n\
    if decaymode==0:\n\
        return %.6f\n\
    if decaymode==1:\n\
        return %.6f\n\
    if decaymode==10:\n\
        return  %.6f\n\
def tau_fake_decayMode_up(decaymode): \n\
    if decaymode==0:\n\
        return  %.6f\n\
    if decaymode==1: \n\
        return  %.6f\n\
    if decaymode==10:\n\
        return  %.6f\n\
def tau_fake_decayMode_down(decaymode): \n\
    if decaymode==0:\n\
        return  %.6f\n\
    if decaymode==1:\n\
        return  %.6f\n\
    if decaymode==10:\n\
        return %.6f\n' %(eff0,eff1, eff10, eff0_up,eff1_up, eff10_up, eff0_dw,eff1_dw, eff10_dw)

