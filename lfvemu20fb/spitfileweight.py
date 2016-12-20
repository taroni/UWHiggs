import os 
for filename in os.listdir("inputs/Oct30"):
    print filename
    if "lumicalc.sum" in filename:
        with open("inputs/Oct30/"+filename) as lumifile:
            lumistr=float(lumifile.readline().strip())
        print filename,":  ",1/lumistr
