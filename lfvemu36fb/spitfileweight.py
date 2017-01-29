import sys
import os 
for filename in os.listdir(sys.argv[1]+"/mc_ntuples_jan21"):
    if "lumicalc.sum" in filename:
        with open(sys.argv[1]+"/mc_ntuples_jan21/"+filename) as lumifile:
            lumistr=float(lumifile.readline().strip())

        print filename,":  ",lumistr,"    ",1/lumistr
