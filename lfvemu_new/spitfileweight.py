import os 
for filename in os.listdir("Oct30Inputs"):
    if "lumicalc.sum" in filename:
        with open("Oct30Inputs/"+filename) as lumifile:
            lumistr=float(lumifile.readline().strip())
        print filename,":  ",1/lumistr
