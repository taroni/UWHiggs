#!/bin/bash                                                                                                                                   

usage='Usage: -a <analyzer name>  -lumi <luminosity in pb> -ns <num_samples> -nf <sampling frequency> -ph <phase position> (-cpt <old pulse type> -cns\
 <old no. of samples> -cnf<old sampling freq>) '

args=`getopt rdlp: -- "$@"`
if test $? != 0
     then
         echo $usage
         exit 1
fi

eval set -- "$args"


for i
 do
    case "$i" in
      -analyzer) shift; analyzer=$2;shift;;
      -lumi) shift; luminosity=$2;shift;;
      -jobid) shift;jobid=$2;shift;;
      -analtype) shift;analtype=$2;shift;;
      -kinplots) shift;kinplots=$2;shift;;
      -sys) shift;sys=$2;shift;;
      -isTT_DD) shift;isTT_DD=$2;shift;;
      -num_cat) shift;num_cat=$2;shift;;
    esac
done

echo Preprocessing results for Analyzer: $analyzer
echo Current luminosity is :$luminosity

echo Current Jobid is: $jobid
echo Type of Analyzer: $analtype

#remove earlier preprocessed files with analyzer of same name
rm -r Simple$analyzer$luminosity/*


#copy results into current directory in the form wanted
mkdir Simple$analyzer$luminosity/
cp -r results/$jobid/Simple$analyzer/* Simple$analyzer$luminosity/.

#combine relevant backgrounds
cp combine_backgrounds.sh Simple$analyzer$luminosity
cd Simple$analyzer$luminosity
source combine_backgrounds.sh
rm combine_backgrounds.sh
cd -

echo "computing QCD"
#get QCD (data-MC) in ss *2.30(SF)
python computeQCD.py --aName $analyzer --lumi $luminosity --jobid $jobid --aType $analtype  --numCategories $num_cat
echo "computing QCD with shapes"
python computeQCD_with_shapes.py --aName $analyzer --lumi $luminosity --jobid $jobid --aType $analtype  --numCategories $num_cat

#
#folder for plotting
mv QCD$analyzer.root Simple$analyzer$luminosity/QCD.root

mv QCD${analyzer}_with_shapes.root Simple$analyzer$luminosity/QCD_with_shapes.root
####compute TTBar from CR data
####if [ "X"${isTT_DD} != "X" ]  
####    then
####    echo computing ttbar from CR data
####    python computeTTbar.py --aName $analyzer --lumi $luminosity --jobid $jobid --aType $analtype  --numCategories $num_cat
####    mv TT_DD_$analyzer.root Analyzer_MuE_$analyzer$luminosity/TT_DD.root #folder for plotting
####fi
###
###


###final preprocessing : weight lumi, fill empty bins etc, create separate root file for each variable for plotting . INCLUSIVE
python do_lumiweight_inclusive.py --aName $analyzer --lumi $luminosity --jobid $jobid --aType $analtype 
##
##
###final preprocessing : weight lumi, fill empty bins etc, create separate root file for each variable for plotting . PRESEL_CATEGORY_WISE
python do_lumiweight_presel.py --aName $analyzer --lumi $luminosity --jobid $jobid --aType $analtype  --numCategories $num_cat
##
##
###final preprocessing : weight lumi, fill empty bins etc, create separate root file for each variable for plotting . FINAL_SEL_CATEGORY_WISE
python do_lumiweight_sel.py --aName $analyzer --lumi $luminosity --jobid $jobid --aType $analtype  --numCategories $num_cat


#final preprocessing : weight lumi, fill empty bins etc, create separate root file for each variable for plotting . FINAL_SEL_CATEGORY_WISE
echo "python do_lumiweight_sel_shapes.py --aName " $analyzer " --lumi " $luminosity " --jobid" $jobid " --aType " $analtype "  --numCategories" $num_cat

python do_lumiweight_sel_shapes.py --aName $analyzer --lumi $luminosity --jobid $jobid --aType $analtype  --numCategories $num_cat
