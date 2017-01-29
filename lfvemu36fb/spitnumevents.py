import os 
import sys
for filename in os.listdir(sys.argv[1]+"/mc_ntuples_jan21"):
    if "weight" in filename and "data" not in filename:
        with open(sys.argv[1]+"/mc_ntuples_jan21/"+filename) as lumifile:
            lumistr=float(lumifile.readline().strip().replace("Weights: ",""))

        print filename,":  ",lumistr,"    "
