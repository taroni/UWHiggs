source jobid.sh
export jobid='run2'
source ../environment.sh
export TERM=vt100
export blind='YES'

i=1
while [ $i -lt 21 ]
do 
export jobid='run2_'$i'fb'
if [ $i == 2 ] ; then 
    export jobid='run2'
fi
#python plotRecoQuantitiesMVA.py 
#./prepare_limit.sh 0
#./prepare_limit.sh 1 
#./prepare_limit.sh 2
#mv limits limits_$i
#mkdir /afs/hep.wisc.edu/home/taroni/nobackup/13TeV/limit/CMSSW_7_1_5/src/HiggsAnalysis/CombinedLimit/test/limits_$i
cp limits_$i/limits/$jobid/*/shapesETau*.root /afs/hep.wisc.edu/home/taroni/nobackup/13TeV/limit/CMSSW_7_1_5/src/HiggsAnalysis/CombinedLimit/test/limits_$i/
cp limits_$i/limits/$jobid/*/126/datacard_et_*.txt /afs/hep.wisc.edu/home/taroni/nobackup/13TeV/limit/CMSSW_7_1_5/src/HiggsAnalysis/CombinedLimit/test/limits_$i/
i=$[$i+1]
echo $i 
done


cd /afs/hep.wisc.edu/home/taroni/nobackup/13TeV/limit/CMSSW_7_1_5/src/HiggsAnalysis/CombinedLimit/test/
eval `scramv1 runtime -sh`

i=1
while [ $i -lt 21 ]
do 
export jobid='run2_'$i'fb'
if [ $i == 2 ] ; then 
    export jobid='run2'
fi
cd /afs/hep.wisc.edu/home/taroni/nobackup/13TeV/limit/CMSSW_7_1_5/src/HiggsAnalysis/CombinedLimit/test/limits_$i/
combineCards.py -S datacard_et_0=datacard_et_0.txt datacard_et_1=datacard_et_1.txt datacard_et_2=datacard_et_2.txt >CARD.txt
combine -M   Asymptotic --run expected -C 0.95 -t -1   --minimizerStrategy 0 -n '-exp' -m 126 datacard_et_0.txt >& results0j_$i
combine -M   Asymptotic --run expected -C 0.95 -t -1   --minimizerStrategy 0 -n '-exp' -m 126 datacard_et_1.txt >& results1j_$i
combine -M   Asymptotic --run expected -C 0.95 -t -1   --minimizerStrategy 0 -n '-exp' -m 126 datacard_et_2.txt >& results2j_$i
combine -M   Asymptotic --run expected -C 0.95 -t -1   --minimizerStrategy 0 -n '-exp' -m 126 CARD.txt >& results_$i


i=$[$i+1]
echo $i 
done
