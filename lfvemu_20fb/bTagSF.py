

def GetSF(WP,x,flavour,syst):
    
    if (WP==1):
        if (abs(flavour)==4 or abs(flavour)==5):
            if (syst==0):
                return 0.901114+(1.32145e-05*x)
                
            if (syst==-1):
                if (x < 30): return 0.901114+((1.32145e-05*x)-2*0.023258373141288757)
                elif (x<50): return 0.901114+((1.32145e-05*x)-0.023258373141288757)
                elif (x < 70): return 0.901114+((1.32145e-05*x)-0.023003481328487396)
                elif (x < 100): return 0.901114+((1.32145e-05*x)-0.022424774244427681)
                elif (x < 140): return 0.901114+((1.32145e-05*x)-0.032237973064184189)
                elif (x < 200): return 0.901114+((1.32145e-05*x)-0.033661492168903351)
                elif (x < 300): return 0.901114+((1.32145e-05*x)-0.064984261989593506)
                elif (x < 670): return 0.901114+((1.32145e-05*x)-0.072893746197223663)
                else: return 0.901114+((1.32145e-05*x)-2*0.072893746197223663)
        
            if (syst==1):
               if (x < 30): return 0.901114+((1.32145e-05*x)+2*0.0232583)
               elif (x<50): return 0.901114+((1.32145e-05*x)+0.023258373141288757)
               elif (x < 70): return 0.901114+((1.32145e-05*x)+0.023003481328487396)
               elif (x < 100): return 0.901114+((1.32145e-05*x)+0.022424774244427681)
               elif (x < 140): return 0.901114+((1.32145e-05*x)+0.032237973064184189)
               elif (x < 200): return 0.901114+((1.32145e-05*x)+0.033661492168903351)
               elif (x < 300): return 0.901114+((1.32145e-05*x)+0.064984261989593506)
               elif (x < 670): return 0.901114+((1.32145e-05*x)+0.072893746197223663)
               else: return 0.901114+((1.32145e-05*x)+2*0.072893746197223663)
        
      
        else :
            if (syst==0): return 0.980777+-0.00109334*x+4.2909e-06*x*x+-2.78512e-09*x*x*x
            if (syst==-1): return (0.980777+-0.00109334*x+4.2909e-06*x*x+-2.78512e-09*x*x*x)*(1-(0.0672836+0.000102309*x+-1.01558e-07*x*x))
            if (syst==1): return (0.980777+-0.00109334*x+4.2909e-06*x*x+-2.78512e-09*x*x*x)*(1+(0.0672836+0.000102309*x+-1.01558e-07*x*x))
    else:
        return 0



def  bTagEventWeight( nBtaggedJets, bjetpt_1,  bjetflavour_1,  bjetpt_2,  bjetflavour_2,  WP,  syst, nBTags):
    if (nBtaggedJets > 2): return -10000
    if ( nBTags > 2 ): return -10000

 
    ##################################################################
 #   Event weight matrix:
 #   ------------------------------------------------------------------
 #   nBTags\b-tagged jets  |    0        1             2
 #   ------------------------------------------------------------------
 #     0                   |    1      1-SF      (1-SF1)(1-SF2)
 #                         |
 #     1                   |    0       SF    SF1(1-SF2)+(1-SF1)SF2
 #                         |
 #     2                   |    0        0           SF1SF2
    ##################################################################
 
  
    if ( nBTags > nBtaggedJets): return 0
    if ( nBTags==0 and nBtaggedJets==0): return 1

    weight = 0
    if (nBtaggedJets==1):
        SF = GetSF(WP,bjetpt_1,bjetflavour_1,syst)
        for  i in range(2):
            if ( i != nBTags ): continue
            weight += pow(SF,i)*pow(1-SF,1-i)
    
  
    elif (nBtaggedJets==2):
        SF1 = GetSF(WP,bjetpt_1,bjetflavour_1,syst)
        SF2 = GetSF(WP,bjetpt_2,bjetflavour_2,syst)
    
        for i in range(2):
            for j in range(2):
                if( (i+j) != nBTags ): continue
                weight += pow(SF1,i)*pow(1-SF1,1-i)*pow(SF2,j)*pow(1-SF2,1-j)

    return weight


