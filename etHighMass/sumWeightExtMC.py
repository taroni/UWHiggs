import os

files=[]
jobid = os.environ['jobid']
path = 'inputs/'+jobid+'/'

for name in os.listdir(path):
    if 'weight' in name:
        if not '_ext1' in name: continue
        if os.path.isfile(os.path.join(path, name)):
            if  os.path.isfile(os.path.join(path, name.replace('_ext1', ''))):
                files.append([os.path.join(path,name.replace('_ext1', '')), os.path.join(path,name)])
print files

for names in files:
    print names
    sum_weight=0.

    for fname in names:
        if not os.path.isfile(fname):
            raise ValueError('The file %s does not exist!' % fname)
        with open(fname) as file0:
            weight=[line.rstrip('\n') for line in file0][0].split(':')[1]
            try:
                sum_weight += float(weight)
            except:
                raise ValueError('I could not parse %s as a float!' % weight)
    
    with open(os.path.join(path,name.replace('_ext1', '')), 'w') as out:
        out.write("Weights: %s\n" % sum_weight)
    cmd="rm %s" %(names[1])
    os.system(cmd)
    
files=[]       
    
for name in os.listdir(path):
    if 'txt' in name:
        if not '_ext1' in name: continue
        if os.path.isfile(os.path.join(path, name)):
            if  os.path.isfile(os.path.join(path, name.replace('_ext1', ''))):
                files.append((os.path.join(path,name.replace('_ext1', '')), os.path.join(path,name)))


            
for names in files:

    outfile = open (os.path.join(path, names[0]), "a")
    
    lines = [line.strip() for line in open(os.path.join(path, names[1]))]

    for line in lines:
        outfile.write(line+'\n')

    outfile.close()
    cmd=
    os.system("rm "+os.path.join(path, names[1]))
