import os 
import sys
for filename in os.listdir("inputs/Oct30"):
    if "lumicalc.sum" in filename and "LFV" not in filename and "data_SingleM" not in filename:
        with open("inputs/Oct30/"+filename,"wb") as lumifile:
#            lumistr=float(lumifile.readline().strip())
            lumifile.write(sys.argv[1])
            lumifile.close()
        with open("inputs/Oct30/"+filename,"r") as lumifile:
            lumistr2=float(lumifile.readline().strip())
        print filename,":  ",1/lumistr2,"   ",lumistr2
