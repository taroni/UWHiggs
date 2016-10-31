import os 
for filename in os.listdir("SMHTT_aug16_v2"):
    if "lumicalc.sum" in filename:
        with open("SMHTT_aug16_v2/"+filename) as lumifile:
            lumistr=float(lumifile.readline().strip())
        print filename,":  ",1/lumistr
